import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';

class NearbyPlaceItem {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool? isOpenNow;
  final double? rating;

  const NearbyPlaceItem({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    this.isOpenNow,
    this.rating,
  });

  factory NearbyPlaceItem.fromJson(Map<String, dynamic> json) {
    return NearbyPlaceItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed place').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      isOpenNow: json['isOpenNow'] as bool?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  String distanceTextFor(String languageCode) {
    if (distanceMeters < 1000) {
      final value = '${distanceMeters.round()} m';
      return switch (_normalizeLanguageCode(languageCode)) {
        'hi' => '$value दूर',
        'mr' => '$value दूर',
        _ => '$value away',
      };
    }
    final value = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    return switch (_normalizeLanguageCode(languageCode)) {
      'hi' => '$value दूर',
      'mr' => '$value दूर',
      _ => '$value away',
    };
  }
}

String _normalizeLanguageCode(String code) {
  final normalized = code.trim().toLowerCase().split(RegExp(r'[_-]')).first;
  return normalized == 'hi' || normalized == 'mr' ? normalized : 'en';
}

enum NearbyPlaceType {
  hospitals,
  policeStations,
  pharmacies,
  petrolPumps,
  washrooms,
  bloodBanks,
}

extension NearbyPlaceTypeApi on NearbyPlaceType {
  String get apiCategory => switch (this) {
        NearbyPlaceType.hospitals => 'hospitals',
        NearbyPlaceType.policeStations => 'policeStations',
        NearbyPlaceType.pharmacies => 'pharmacies',
        NearbyPlaceType.petrolPumps => 'petrolPumps',
        NearbyPlaceType.washrooms => 'washrooms',
        NearbyPlaceType.bloodBanks => 'bloodBanks',
      };
}

class NearbyPlacesState {
  final bool isLoading;
  final String? error;
  final NearbyPlaceType? activeType;
  final List<NearbyPlaceItem> places;

  const NearbyPlacesState({
    this.isLoading = false,
    this.error,
    this.activeType,
    this.places = const [],
  });

  NearbyPlacesState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    NearbyPlaceType? activeType,
    List<NearbyPlaceItem>? places,
  }) {
    return NearbyPlacesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activeType: activeType ?? this.activeType,
      places: places ?? this.places,
    );
  }
}

final nearbyPlacesProvider =
    StateNotifierProvider<NearbyPlacesNotifier, NearbyPlacesState>(
      (ref) => NearbyPlacesNotifier(ref),
    );

class NearbyPlacesNotifier extends StateNotifier<NearbyPlacesState> {
  NearbyPlacesNotifier(this._ref) : super(const NearbyPlacesState());

  final Ref _ref;
  final Dio _dio = DioClient().dio;
  String? _lastFetchKey;
  DateTime? _lastFetchAt;
  static const Duration _cacheTtl = Duration(seconds: 90);

  @visibleForTesting
  void debugSetState(NearbyPlacesState newState) {
    state = newState;
  }

  void toggleNearby(NearbyPlaceType type) {
    if (state.isLoading) return;

    if (state.activeType == type) {
      state = const NearbyPlacesState();
      return;
    }

    fetchNearby(type);
  }

  Future<void> fetchNearby(NearbyPlaceType type, {bool force = false}) async {
    final monitor = _ref.read(safetyMonitorProvider);

    if (!monitor.gpsEnabled || !monitor.permissionGranted) {
      state = state.copyWith(
        isLoading: false,
        activeType: type,
        places: const [],
        error: _l10n('nearbyGpsUnavailable'),
      );
      return;
    }

    final position = await _resolveCurrentScanPosition(monitor.position);
    if (position == null) {
      state = state.copyWith(
        isLoading: false,
        activeType: type,
        places: const [],
        error: _l10n('nearbyGpsUnavailable'),
      );
      return;
    }

    final lang = _googlePlacesLanguageCode();
    final fetchKey =
        '${type.apiCategory}_${position.latitude.toStringAsFixed(3)}_'
        '${position.longitude.toStringAsFixed(3)}_$lang';
    final now = DateTime.now();
    if (!force &&
        state.activeType == type &&
        state.places.isNotEmpty &&
        _lastFetchKey == fetchKey &&
        _lastFetchAt != null &&
        now.difference(_lastFetchAt!) < _cacheTtl) {
      // Same location/category/language within the TTL window — reuse the
      // cached places instead of hitting the network again.
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activeType: type,
      places: const [],
    );

    try {
      final response = await _dio.get(
        ApiConstants.nearbyPlaces,
        queryParameters: {
          'lat': position.latitude,
          'lng': position.longitude,
          'category': type.apiCategory,
          'radius': type == NearbyPlaceType.washrooms ? 5000 : 5000,
          'lang': lang,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final data = response.data;
      final list = data is Map && data['places'] is List
          ? data['places'] as List
          : data is List
              ? data
              : const [];

      final parsed = list
          .whereType<Map>()
          .map((raw) => NearbyPlaceItem.fromJson(Map<String, dynamic>.from(raw)))
          .where((place) => place.latitude != 0 || place.longitude != 0)
          .toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      _lastFetchKey = fetchKey;
      _lastFetchAt = now;
      state = state.copyWith(
        isLoading: false,
        places: parsed,
        clearError: true,
      );
    } on DioException catch (error) {
      final code = error.response?.data is Map
          ? error.response!.data['code']?.toString()
          : null;
      state = state.copyWith(
        isLoading: false,
        places: const [],
        error: code == 'MAPS_KEY_MISSING'
            ? _l10n('nearbyGoogleMapsKeyMissing')
            : _l10n('nearbyFetchFailed'),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        places: const [],
        error: _l10n('nearbyFetchFailed'),
      );
    }
  }

  Future<Position?> _resolveCurrentScanPosition(Position? fallback) {
    return LocationPermissionService.resolvePosition(
      preferred: fallback,
      accuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 8),
    );
  }

  String _googlePlacesLanguageCode() {
    return _normalizeLanguageCode(_ref.read(appLocaleProvider).languageCode);
  }

  String _l10n(String key, {Map<String, String> params = const {}}) {
    return l10nForLocale(_ref.read(appLocaleProvider), key, params: params);
  }
}
