import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_api.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_models.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';

export 'package:suraksha_women_safety_app/features/dashboard/nearby_places_models.dart';

final nearbyPlacesProvider =
    StateNotifierProvider<NearbyPlacesNotifier, NearbyPlacesState>(
      (ref) => NearbyPlacesNotifier(ref),
    );

class NearbyPlacesNotifier extends StateNotifier<NearbyPlacesState> {
  NearbyPlacesNotifier(this._ref) : super(const NearbyPlacesState());

  final Ref _ref;
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

    // Prefer the live monitor fix when ready; otherwise resolve GPS directly so
    // tapping Nearby still works before the 1s delayed monitor start finishes.
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
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activeType: type,
      places: const [],
    );

    // Nudge a sleeping Render dyno without blocking on the auth-bound client.
    unawaited(NetworkManager.instance.wakeBackendForAuth());

    try {
      final parsed = await NearbyPlacesApi.fetchPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        type: type,
        radiusMeters: 5000,
        languageCode: lang,
      );

      if (parsed.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          places: const [],
          error: _l10n('nearbyFetchFailed'),
        );
        return;
      }

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
      mayRequest: true,
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  String _googlePlacesLanguageCode() {
    return normalizeNearbyLanguageCode(
      _ref.read(appLocaleProvider).languageCode,
    );
  }

  String _l10n(String key, {Map<String, String> params = const {}}) {
    return l10nForLocale(_ref.read(appLocaleProvider), key, params: params);
  }
}
