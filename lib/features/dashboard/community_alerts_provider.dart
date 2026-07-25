import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';

enum CommunityAlertKind {
  traffic,
  transport,
  lonelyRoad,
  silentZone,
  roadBlock,
  lighting,
}

String _normalizeLanguageCode(String code) {
  final normalized = code.trim().toLowerCase().split(RegExp(r'[_-]')).first;
  return normalized == 'hi' || normalized == 'mr' ? normalized : 'en';
}

Locale _localeFromLanguageCode(String languageCode) {
  return Locale(_normalizeLanguageCode(languageCode));
}

class CommunityAlertItem {
  final CommunityAlertKind kind;
  final String title;
  final String detail;
  final DateTime updatedAt;

  const CommunityAlertItem({
    required this.kind,
    required this.title,
    required this.detail,
    required this.updatedAt,
  });

  factory CommunityAlertItem.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind']?.toString() ?? CommunityAlertKind.traffic.name;
    return CommunityAlertItem(
      kind: CommunityAlertKind.values.firstWhere(
        (value) => value.name == kindName,
        orElse: () => CommunityAlertKind.traffic,
      ),
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'title': title,
      'detail': detail,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String timeText(String languageCode) {
    final diff = DateTime.now().difference(updatedAt);
    final locale = _localeFromLanguageCode(languageCode);
    if (diff.inMinutes < 1) {
      return l10nForLocale(locale, 'communityAlertJustNow');
    }
    if (diff.inMinutes < 60) {
      return l10nForLocale(
        locale,
        'communityAlertMinsAgo',
        params: {'minutes': '${diff.inMinutes}'},
      );
    }
    return l10nForLocale(
      locale,
      'communityAlertHoursAgo',
      params: {'hours': '${diff.inHours}'},
    );
  }
}

class CommunityAlertsState {
  final bool isLoading;
  final String? error;
  final List<CommunityAlertItem> alerts;
  final DateTime? lastUpdatedAt;

  const CommunityAlertsState({
    this.isLoading = false,
    this.error,
    this.alerts = const [],
    this.lastUpdatedAt,
  });

  CommunityAlertsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<CommunityAlertItem>? alerts,
    DateTime? lastUpdatedAt,
  }) {
    return CommunityAlertsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      alerts: alerts ?? this.alerts,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

final communityAlertsProvider =
    StateNotifierProvider<CommunityAlertsNotifier, CommunityAlertsState>(
      (ref) => CommunityAlertsNotifier(ref),
    );

class CommunityAlertsNotifier extends StateNotifier<CommunityAlertsState> {
  CommunityAlertsNotifier(this._ref) : super(const CommunityAlertsState()) {
    unawaited(_restoreCachedAlerts());
  }

  final Ref _ref;
  static const _cacheKey = 'community_alerts_cache_v1';
  static const _cacheUpdatedKey = 'community_alerts_cache_updated_v1';

  Future<void> _restoreCachedAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final alerts = decoded
          .whereType<Map<String, dynamic>>()
          .map(CommunityAlertItem.fromJson)
          .toList(growable: false);
      DateTime? updatedAt = DateTime.tryParse(
        prefs.getString(_cacheUpdatedKey) ?? '',
      );
      updatedAt ??= alerts.isNotEmpty ? alerts.first.updatedAt : null;

      if (alerts.isEmpty) return;
      state = state.copyWith(
        alerts: alerts,
        lastUpdatedAt: updatedAt,
        clearError: true,
      );
    } catch (_) {}
  }

  Future<void> _saveCachedAlerts(
    List<CommunityAlertItem> alerts,
    DateTime updatedAt,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(alerts.map((item) => item.toJson()).toList(growable: false)),
      );
      await prefs.setString(_cacheUpdatedKey, updatedAt.toIso8601String());
    } catch (_) {}
  }

  static const Duration _cacheTtl = Duration(minutes: 2);

  Future<void> refresh({bool force = false}) async {
    if (state.isLoading) return;

    if (!force &&
        state.alerts.isNotEmpty &&
        state.lastUpdatedAt != null &&
        DateTime.now().difference(state.lastUpdatedAt!) < _cacheTtl) {
      // Recent enough — skip the network round trip.
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final position = await _resolvePosition();
      if (position == null) {
        state = state.copyWith(
          isLoading: false,
          error: _l10n('nearbyGpsUnavailable'),
        );
        return;
      }

      final nearby = await _nearbyCountsFromBackend(position);
      final traffic = await _trafficSignalsFromBackend(position);
      final now = DateTime.now();
      final alerts = _buildAlerts(traffic, nearby, now);

      state = state.copyWith(
        isLoading: false,
        alerts: alerts,
        lastUpdatedAt: now,
        clearError: true,
      );
      unawaited(_saveCachedAlerts(alerts, now));
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: _l10n('communityAlertLoadFailed'),
      );
    }
  }

  Future<_NearbySignals> _nearbyCountsFromBackend(Position position) async {
    try {
      final response = await DioClient().dio.get(
        ApiConstants.nearbyEmergencyServices,
        queryParameters: {
          'lat': position.latitude,
          'lng': position.longitude,
          'radius': 1200,
        },
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final police = (data['policeCount'] as num?)?.toInt() ?? 0;
      final hospitals = (data['hospitalCount'] as num?)?.toInt() ?? 0;
      final fuel = (data['petrolPumpCount'] as num?)?.toInt() ?? 0;
      return _NearbySignals(
        busStops: 0,
        busStopKeywords: 0,
        transitStations: 0,
        trainStations: 0,
        metroStations: 0,
        taxiStands: 0,
        autoRickshawStands: 0,
        rickshawStandKeywords: 0,
        cabStands: 0,
        activePlaces: hospitals + fuel,
        restaurants: 0,
        cafes: 0,
        malls: 0,
        convenienceStores: 0,
        gasStations: fuel,
        parkingAreas: 0,
        hospitals: hospitals,
        schools: 0,
        courts: 0,
        policeStations: police,
      );
    } catch (_) {
      return const _NearbySignals(
        busStops: 0,
        busStopKeywords: 0,
        transitStations: 0,
        trainStations: 0,
        metroStations: 0,
        taxiStands: 0,
        autoRickshawStands: 0,
        rickshawStandKeywords: 0,
        cabStands: 0,
        activePlaces: 0,
        restaurants: 0,
        cafes: 0,
        malls: 0,
        convenienceStores: 0,
        gasStations: 0,
        parkingAreas: 0,
        hospitals: 0,
        schools: 0,
        courts: 0,
        policeStations: 0,
      );
    }
  }

  Future<Position?> _resolvePosition() async {
    final monitor = _ref.read(safetyMonitorProvider);
    // Never re-prompt here — dashboard / safety monitor owns permission UX.
    return LocationPermissionService.resolvePosition(
      mayRequest: false,
      preferred: (monitor.gpsEnabled &&
              monitor.permissionGranted &&
              monitor.position != null)
          ? monitor.position
          : null,
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 8),
    );
  }

  Future<_TrafficSignals> _trafficSignalsFromBackend(Position position) async {
    final destinations = _destinationSamples(position);
    final ratios = <double>[];
    var failedRoutes = 0;

    final responses = await Future.wait(
      destinations.map((destination) async {
        try {
          return await DioClient().dio.get(
            ApiConstants.nearbyDirections,
            queryParameters: {
              'originLat': position.latitude,
              'originLng': position.longitude,
              'destinationLat': destination.$1,
              'destinationLng': destination.$2,
              'alternatives': false,
            },
          );
        } catch (_) {
          return null;
        }
      }),
    );

    for (final response in responses) {
      if (response == null) {
        failedRoutes += 1;
        continue;
      }
      final data = response.data;
      final routes = data is Map ? data['routes'] : null;
      if (routes is! List || routes.isEmpty) {
        failedRoutes += 1;
        continue;
      }
      final first = routes.first;
      if (first is! Map) {
        failedRoutes += 1;
        continue;
      }
      final duration = (first['durationSeconds'] as num?)?.toDouble() ?? 0;
      final traffic =
          (first['durationInTrafficSeconds'] as num?)?.toDouble() ?? duration;
      if (duration <= 0) {
        failedRoutes += 1;
        continue;
      }
      ratios.add(traffic / duration);
    }

    if (ratios.isEmpty) {
      return _TrafficSignals(
        averageDelayRatio: 1,
        maxDelayRatio: 1,
        sampledRoutes: 0,
        failedRoutes: failedRoutes,
      );
    }

    final total = ratios.fold<double>(0, (sum, value) => sum + value);
    ratios.sort();
    return _TrafficSignals(
      averageDelayRatio: total / ratios.length,
      maxDelayRatio: ratios.last,
      sampledRoutes: ratios.length,
      failedRoutes: failedRoutes,
    );
  }

  List<CommunityAlertItem> _buildAlerts(
    _TrafficSignals traffic,
    _NearbySignals nearby,
    DateTime now,
  ) {
    final alerts = <CommunityAlertItem>[];
    final isLateNight = now.hour >= 22 || now.hour < 5;
    final transitCount = nearby.transitPointCount;
    final silentZoneCount = nearby.hospitals + nearby.schools + nearby.courts;
    final showRoadLighting = now.hour >= 19 || now.hour < 6;

    if (traffic.sampledRoutes == 0) {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.traffic,
          title: _l10n('communityAlertTrafficDataLimited'),
          detail: _l10n('communityAlertTrafficSampleFailed'),
          updatedAt: now,
        ),
      );
    } else if (traffic.maxDelayRatio >= 1.45 ||
        traffic.averageDelayRatio >= 1.3) {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.traffic,
          title: _l10n('communityAlertHeavyTraffic'),
          detail: _l10n('communityAlertHeavyTrafficDetail'),
          updatedAt: now,
        ),
      );
    } else {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.traffic,
          title: _l10n('communityAlertTrafficNormal'),
          detail: _l10n('communityAlertTrafficNormalDetail'),
          updatedAt: now,
        ),
      );
    }

    if (traffic.failedRoutes > 0 || traffic.maxDelayRatio >= 1.8) {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.roadBlock,
          title: _l10n('communityAlertRouteBlockage'),
          detail: _l10n('communityAlertRouteBlockageDetail'),
          updatedAt: now,
        ),
      );
    }

    alerts.add(
      CommunityAlertItem(
        kind: CommunityAlertKind.transport,
        title: _l10n('communityAlertTransportAvailable'),
        detail: _l10n('communityAlertTransportAvailableDetail'),
        updatedAt: now,
      ),
    );

    if (nearby.activePlaces < 4 && transitCount < 2) {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.lonelyRoad,
          title: _l10n('communityAlertLowActivity'),
          detail: _l10n('communityAlertLowActivityDetail'),
          updatedAt: now,
        ),
      );
    }

    if (silentZoneCount >= 2) {
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.silentZone,
          title: _l10n('communityAlertSilentZone'),
          detail: _l10n(
            'communityAlertSilentZoneDetail',
            params: {'count': '$silentZoneCount'},
          ),
          updatedAt: now,
        ),
      );
    }

    if (showRoadLighting) {
      final lightingSummary = _buildLightingSummary(nearby, isLateNight);
      alerts.add(
        CommunityAlertItem(
          kind: CommunityAlertKind.lighting,
          title: lightingSummary.title,
          detail: lightingSummary.detail,
          updatedAt: now,
        ),
      );
    }

    return alerts.take(5).toList();
  }

  _LightingSummary _buildLightingSummary(
    _NearbySignals nearby,
    bool isLateNight,
  ) {
    final lightingSupportScore =
        nearby.restaurants +
        nearby.cafes +
        nearby.malls +
        nearby.convenienceStores +
        nearby.gasStations * 2 +
        nearby.parkingAreas +
        nearby.transitPointCount;

    if (lightingSupportScore >= 14) {
      return _LightingSummary(
        title: _l10n('communityAlertLightingStrong'),
        detail: _l10n('communityAlertLightingStrongDetail'),
      );
    }

    if (lightingSupportScore >= 7) {
      return _LightingSummary(
        title: _l10n('communityAlertLightingModerate'),
        detail: _l10n('communityAlertLightingModerateDetail'),
      );
    }

    return _LightingSummary(
      title: isLateNight
          ? _l10n('communityAlertLightingLimited')
          : _l10n('communityAlertLightingCoverageLimited'),
      detail: _l10n('communityAlertLightingLimitedDetail'),
    );
  }

  List<(double, double)> _destinationSamples(Position position) {
    const delta = 0.018;
    return [
      (position.latitude + delta, position.longitude),
      (position.latitude - delta, position.longitude),
      (position.latitude, position.longitude + delta),
      (position.latitude, position.longitude - delta),
    ];
  }

  String _l10n(String key, {Map<String, String> params = const {}}) {
    return l10nForLocale(_ref.read(appLocaleProvider), key, params: params);
  }

}

class _TrafficSignals {
  final double averageDelayRatio;
  final double maxDelayRatio;
  final int sampledRoutes;
  final int failedRoutes;

  const _TrafficSignals({
    required this.averageDelayRatio,
    required this.maxDelayRatio,
    required this.sampledRoutes,
    required this.failedRoutes,
  });
}

class _NearbySignals {
  final int busStops;
  final int busStopKeywords;
  final int transitStations;
  final int trainStations;
  final int metroStations;
  final int taxiStands;
  final int autoRickshawStands;
  final int rickshawStandKeywords;
  final int cabStands;
  final int activePlaces;
  final int restaurants;
  final int cafes;
  final int malls;
  final int convenienceStores;
  final int gasStations;
  final int parkingAreas;
  final int hospitals;
  final int schools;
  final int courts;
  final int policeStations;

  const _NearbySignals({
    required this.busStops,
    required this.busStopKeywords,
    required this.transitStations,
    required this.trainStations,
    required this.metroStations,
    required this.taxiStands,
    required this.autoRickshawStands,
    required this.rickshawStandKeywords,
    required this.cabStands,
    required this.activePlaces,
    required this.restaurants,
    required this.cafes,
    required this.malls,
    required this.convenienceStores,
    required this.gasStations,
    required this.parkingAreas,
    required this.hospitals,
    required this.schools,
    required this.courts,
    required this.policeStations,
  });

  int get transitPointCount =>
      busStops +
      busStopKeywords +
      transitStations +
      trainStations +
      metroStations +
      taxiStands +
      autoRickshawStands +
      rickshawStandKeywords +
      cabStands;

  int get nightActivityCount =>
      activePlaces +
      restaurants +
      cafes +
      malls +
      convenienceStores +
      gasStations +
      parkingAreas;
}

class _LightingSummary {
  final String title;
  final String detail;

  const _LightingSummary({required this.title, required this.detail});
}
