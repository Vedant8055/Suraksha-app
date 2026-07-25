import 'package:geolocator/geolocator.dart';

/// Snapshot of GPS + location permission without side effects.
class LocationAccessSnapshot {
  final bool gpsEnabled;
  final LocationPermission permission;

  const LocationAccessSnapshot({
    required this.gpsEnabled,
    required this.permission,
  });

  bool get isGranted =>
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;

  bool get isDeniedForever =>
      permission == LocationPermission.deniedForever;

  bool get canRequest => permission == LocationPermission.denied;
}

/// Single entry point for location access checks.
///
/// Only the dashboard / safety-monitor gate should pass [mayRequest]: true.
/// Feature screens should check-only so users are not repeatedly prompted.
class LocationPermissionService {
  LocationPermissionService._();

  static LocationSettings settingsFor(
    LocationAccuracy accuracy, {
    Duration? timeLimit,
    int distanceFilter = 0,
  }) {
    return LocationSettings(
      accuracy: accuracy,
      timeLimit: timeLimit,
      distanceFilter: distanceFilter,
    );
  }

  /// Checks GPS + permission. Optionally requests once when [mayRequest] is true
  /// and the OS still allows a prompt (`denied`, not `deniedForever`).
  static Future<LocationAccessSnapshot> ensureAccess({
    bool mayRequest = false,
  }) async {
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();

    if (mayRequest && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return LocationAccessSnapshot(
      gpsEnabled: gpsEnabled,
      permission: permission,
    );
  }

  /// Resolves a position using granted permission only (or a prompt when
  /// [mayRequest] is true). Prefers [preferred] when provided.
  static Future<Position?> resolvePosition({
    bool mayRequest = false,
    Position? preferred,
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    if (preferred != null) return preferred;

    final access = await ensureAccess(mayRequest: mayRequest);
    if (!access.gpsEnabled || !access.isGranted) {
      return Geolocator.getLastKnownPosition();
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit,
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
