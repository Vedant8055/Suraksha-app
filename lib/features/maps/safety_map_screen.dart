import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/features/maps/map_handoff_actions.dart';
import 'package:suraksha_women_safety_app/features/maps/map_route_models.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/journey_alert_banner.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/journey_panel.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/live_safety_controls_sheet.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_locating_view.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_offline_banner.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_places_list_panel.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_quick_controls.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_top_search_bar.dart';
import 'package:suraksha_women_safety_app/features/routes/route_safety_provider.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_service.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_screen.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyMapScreen extends ConsumerStatefulWidget {
  const SafetyMapScreen({
    super.key,
    this.initialTargetLatitude,
    this.initialTargetLongitude,
    this.initialTargetName,
  });

  final double? initialTargetLatitude;
  final double? initialTargetLongitude;
  final String? initialTargetName;

  @override
  ConsumerState<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends ConsumerState<SafetyMapScreen> {
  final _dio = DioClient().dio;
  final _toiletService = NearbyCleanToiletsService();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final Set<Marker> _markers = {};
  final Set<Marker> _publicToiletMarkers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  final List<MapPlaceSuggestion> _suggestions = [];
  final List<NearbyCleanToilet> _publicToilets = [];

  GoogleMapController? _mapController;
  Position? _position;
  LatLng? _selectedDestination;
  String? _selectedDestinationName;
  Position? _lastJourneyPosition;
  StreamSubscription<Position>? _liveLocationSubscription;
  Timer? _searchDebounce;

  bool _locationPermissionGranted = false;
  bool _followMe = true;
  bool _trafficEnabled = false;
  bool _publicToiletsEnabled = false;
  bool _publicToiletsLoading = false;
  bool _publicToiletsFetchSucceeded = false;
  bool _isOffline = false;
  bool _showPlacesList = false;
  MapType _mapType = MapType.normal;
  bool _isLoading = true;
  String? _statusText;
  String? _publicToiletsError;
  bool _isSearchOpen = false;
  bool _isLoadingSuggestions = false;
  bool _journeyActive = false;
  bool _journeyPanelCollapsed = false;
  double _coveredDistanceMeters = 0;
  double? _routeDistanceMeters;
  int? _routeEtaSeconds;
  double? _remainingDistanceMeters;
  int? _remainingEtaSeconds;
  double? _smoothedTravelSpeedMps;
  int? _stableEtaSeconds;
  DateTime? _lastEtaUpdateAt;
  int _routeRequestId = 0;
  List<SafetyHeatmapTile>? _cachedHeatmapTilesRef;
  Set<Circle>? _cachedHeatmapCircles;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _liveLocationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _statusText = l10nSync('mapInitializingServices');
      _isOffline = false;
    });

    // Prefer monitor position; never re-prompt â€” dashboard owns permission UX.
    final monitor = ref.read(safetyMonitorProvider);
    final access = await LocationPermissionService.ensureAccess(
      mayRequest: false,
    );

    if (!access.gpsEnabled && monitor.position == null) {
      setState(() {
        _isLoading = false;
        _statusText = l10nSync('mapLocationServiceDisabled');
      });
      return;
    }

    if (!access.isGranted && monitor.position == null) {
      setState(() {
        _isLoading = false;
        _statusText = l10nSync('mapLocationPermissionDenied');
      });
      return;
    }

    setState(() => _locationPermissionGranted = access.isGranted);

    try {
      Position? current = await LocationPermissionService.resolvePosition(
        mayRequest: false,
        preferred: monitor.position,
        accuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      if (current == null) {
        setState(() {
          _isLoading = false;
          _statusText = AppLocalizations.of(context).t('unableToFetchLocation');
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _position = current;
        _isLoading = false;
        _statusText = AppLocalizations.of(
          context,
        ).t('loadingNearbySafetyPoints');
      });

      _setOrUpdateSelfMarker(current);
      if (access.isGranted) {
        _startLiveLocationStream();
      }
      _applyInitialTargetIfAny();
      unawaited(_fetchNearby(current.latitude, current.longitude));
      if (_publicToiletsEnabled) {
        unawaited(_refreshPublicToiletsLayer());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusText = AppLocalizations.of(
          context,
        ).t('couldNotFetchYourLocation');
      });
    }
  }

  void _applyInitialTargetIfAny() {
    final lat = widget.initialTargetLatitude;
    final lng = widget.initialTargetLongitude;
    if (lat == null || lng == null) return;
    _showTargetOnMap(
      LatLng(lat, lng),
      widget.initialTargetName?.trim().isNotEmpty == true
          ? widget.initialTargetName!
          : 'Selected Location',
    );
  }

  Future<void> _showTargetOnMap(LatLng target, String title) async {
    setState(() {
      _selectedDestination = target;
      _selectedDestinationName = title;
      _journeyActive = false;
      _journeyPanelCollapsed = false;
      _resetJourneyMetrics();
      _markers.removeWhere((m) => m.markerId.value == 'search_result');
      _markers.add(
        Marker(
          markerId: const MarkerId('search_result'),
          position: target,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
    _buildRouteTo(target);
  }

  void _setOrUpdateSelfMarker(Position pos) {
    final me = LatLng(pos.latitude, pos.longitude);
    _markers.removeWhere((m) => m.markerId.value == 'me');
    _markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: me,
        infoWindow: InfoWindow(
          title: AppLocalizations.of(context).t('youAreHere'),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    _circles.removeWhere((c) => c.circleId.value == 'me_accuracy');
    _circles.add(
      Circle(
        circleId: const CircleId('me_accuracy'),
        center: me,
        radius: pos.accuracy > 0 ? pos.accuracy : 20,
        fillColor: Colors.blue.withValues(alpha: 0.12),
        strokeColor: Colors.blue.withValues(alpha: 0.35),
        strokeWidth: 1,
      ),
    );
  }

  void _startLiveLocationStream() {
    _liveLocationSubscription?.cancel();

    final LocationSettings locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
            intervalDuration: const Duration(seconds: 2),
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: l10nSync(
                'surakshaLiveLocationNotificationTitle',
              ),
              notificationText: l10nSync(
                'surakshaLiveLocationNotificationText',
              ),
              enableWakeLock: true,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          );

    _liveLocationSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) {
            if (!mounted) return;

            final previous = _position;
            final distanceMoved = previous == null
                ? null
                : Geolocator.distanceBetween(
                    previous.latitude,
                    previous.longitude,
                    pos.latitude,
                    pos.longitude,
                  );
            final accuracyDelta = previous == null
                ? null
                : (pos.accuracy - previous.accuracy).abs();
            final positionChangedMeaningfully = previous == null ||
                (distanceMoved != null && distanceMoved >= 4) ||
                (accuracyDelta != null && accuracyDelta > 15);

            final newStatusText = _journeyActive
                ? AppLocalizations.of(context).t('journeyTrackingActive')
                : AppLocalizations.of(context).t('liveTrackingActive');
            final statusWouldChange = _statusText != newStatusText;

            // Only rebuild when the position moved meaningfully, the status
            // text would change, or a journey is actively being tracked
            // (journey progress/ETA must keep updating live).
            if (positionChangedMeaningfully ||
                statusWouldChange ||
                _journeyActive) {
              setState(() {
                _position = pos;
                _setOrUpdateSelfMarker(pos);
                if (_journeyActive) _updateJourneyProgress(pos);
                _statusText = newStatusText;
              });
            } else {
              _position = pos;
            }

            if (_followMe && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
              );
            }
          },
        );
  }

  void _selectDestination(LatLng target, String title) {
    setState(() {
      _selectedDestination = target;
      _selectedDestinationName = title;
      _journeyActive = false;
      _journeyPanelCollapsed = false;
      _resetJourneyMetrics();
    });
    _buildRouteTo(target);
  }

  Future<void> _presentNearbyLocationChooser(
    LatLng target,
    String title,
  ) async {
    final choice = await showMapHandoffDialog(context, placeName: title);

    if (!mounted || choice == null) return;

    if (choice == MapHandoffOption.surakshaMap) {
      _selectDestination(target, title);
      return;
    }

    final launched = await launchGoogleMapsDirections(
      latitude: target.latitude,
      longitude: target.longitude,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).t('couldNotOpenGoogleMaps'),
          ),
        ),
      );
    }
  }

  void _startJourney() {
    final pos = _position;
    final destination = _selectedDestination;
    if (pos == null || destination == null) return;

    setState(() {
      _journeyActive = true;
      _journeyPanelCollapsed = true;
      _followMe = true;
      _coveredDistanceMeters = 0;
      _lastJourneyPosition = pos;
      _smoothedTravelSpeedMps = null;
      _lastEtaUpdateAt = null;
      _remainingDistanceMeters = _distanceBetween(
        LatLng(pos.latitude, pos.longitude),
        destination,
      );
      _stableEtaSeconds = _routeEtaSeconds;
      _remainingEtaSeconds = _computeStableEtaSeconds(pos);
      _statusText = AppLocalizations.of(context).t('journeyTrackingActive');
    });

    unawaited(ref.read(routeSafetyProvider.notifier).refreshNow());
    ref
        .read(safetyMonitorProvider.notifier)
        .setJourneyMode(
          true,
          destinationLat: destination.latitude,
          destinationLng: destination.longitude,
        );
    _goToMyLocation();
  }

  void _stopJourney() {
    setState(() {
      _journeyActive = false;
      _journeyPanelCollapsed = false;
      _lastJourneyPosition = null;
      _smoothedTravelSpeedMps = null;
      _stableEtaSeconds = null;
      _lastEtaUpdateAt = null;
      _statusText = AppLocalizations.of(context).t('journeyStopped');
    });
    unawaited(ref.read(routeSafetyProvider.notifier).clearActiveMapRoute());
    ref.read(safetyMonitorProvider.notifier).setJourneyMode(false);
  }

  void _resetJourneyMetrics() {
    _lastJourneyPosition = null;
    _coveredDistanceMeters = 0;
    _routeDistanceMeters = null;
    _routeEtaSeconds = null;
    _remainingDistanceMeters = null;
    _remainingEtaSeconds = null;
    _smoothedTravelSpeedMps = null;
    _stableEtaSeconds = null;
    _lastEtaUpdateAt = null;
  }

  void _setJourneyPanelCollapsed(bool collapsed) {
    if (_journeyPanelCollapsed == collapsed) return;
    setState(() => _journeyPanelCollapsed = collapsed);
  }

  void _updateJourneyProgress(Position pos) {
    final destination = _selectedDestination;
    if (!_journeyActive || destination == null) return;

    final last = _lastJourneyPosition;
    if (last != null) {
      final moved = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (moved >= 3) {
        _coveredDistanceMeters += moved;
      }
    }

    _lastJourneyPosition = pos;
    final directRemaining = _distanceBetween(
      LatLng(pos.latitude, pos.longitude),
      destination,
    );
    final routeRemaining = _routeDistanceMeters == null
        ? null
        : (_routeDistanceMeters! - _coveredDistanceMeters)
              .clamp(0, double.infinity)
              .toDouble();

    _remainingDistanceMeters = routeRemaining == null
        ? directRemaining
        : routeRemaining < directRemaining
        ? directRemaining
        : routeRemaining;
    _remainingEtaSeconds = _computeStableEtaSeconds(pos);

    if (directRemaining <= 35) {
      _journeyActive = false;
      _stableEtaSeconds = 0;
      _statusText = l10nSync('destinationReached');
    }
  }

  int? _estimateEtaSeconds(Position pos) {
    final remaining = _remainingDistanceMeters;
    if (remaining == null) return _routeEtaSeconds;

    if (pos.speed.isFinite && pos.speed > 1) {
      return (remaining / pos.speed).round();
    }

    if (_routeDistanceMeters != null &&
        _routeDistanceMeters! > 0 &&
        _routeEtaSeconds != null) {
      final progress = (remaining / _routeDistanceMeters!).clamp(0.0, 1.0);
      return (_routeEtaSeconds! * progress).round();
    }

    const walkingSpeedMetersPerSecond = 1.4;
    return (remaining / walkingSpeedMetersPerSecond).round();
  }

  int? _computeStableEtaSeconds(Position pos) {
    final estimated = _estimateEtaSeconds(pos);
    if (estimated == null) return _stableEtaSeconds ?? _routeEtaSeconds;

    final remaining = _remainingDistanceMeters;
    if (remaining == null) return estimated;

    final now = DateTime.now();
    final rawSpeed = pos.speed.isFinite ? pos.speed : 0;
    final trustworthySpeed = rawSpeed >= 1.8 && rawSpeed <= 33;
    if (trustworthySpeed) {
      final previous = _smoothedTravelSpeedMps ?? rawSpeed;
      _smoothedTravelSpeedMps = (previous * 0.72) + (rawSpeed * 0.28);
    }

    final routeBasedEta =
        (_routeDistanceMeters != null &&
            _routeDistanceMeters! > 0 &&
            _routeEtaSeconds != null)
        ? (_routeEtaSeconds! *
                  (remaining / _routeDistanceMeters!).clamp(0.0, 1.0))
              .round()
        : null;
    final speedBasedEta =
        (_smoothedTravelSpeedMps != null && _smoothedTravelSpeedMps! >= 1.8)
        ? (remaining / _smoothedTravelSpeedMps!).round()
        : null;

    var candidate = routeBasedEta ?? estimated;
    if (speedBasedEta != null && routeBasedEta != null) {
      candidate = ((routeBasedEta * 0.7) + (speedBasedEta * 0.3)).round();
    } else if (speedBasedEta != null) {
      candidate = speedBasedEta;
    }

    final lastStable = _stableEtaSeconds;
    if (lastStable == null) {
      _stableEtaSeconds = candidate;
      _lastEtaUpdateAt = now;
      return candidate;
    }

    final elapsedSeconds = _lastEtaUpdateAt == null
        ? 999
        : now.difference(_lastEtaUpdateAt!).inSeconds;
    if (elapsedSeconds < 6) {
      return lastStable;
    }

    final delta = candidate - lastStable;
    final maxStep = lastStable > 20 * 60 ? 90 : 45;
    final bounded = delta.abs() <= maxStep
        ? candidate
        : lastStable + (delta.isNegative ? -maxStep : maxStep);
    final progressAdjusted = min(lastStable, bounded);
    final floorProtected = remaining <= 80
        ? min(progressAdjusted, 60)
        : progressAdjusted;

    _stableEtaSeconds = floorProtected.clamp(0, 24 * 60 * 60);
    _lastEtaUpdateAt = now;
    return _stableEtaSeconds;
  }

  double _distanceBetween(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  Future<void> _fetchNearby(double lat, double lng) async {
    try {
      final markers = <Marker>{};
      final results = await Future.wait([
        _fetchNearbyMarkers(
          endpoint: ApiConstants.nearbyPolice,
          lat: lat,
          lng: lng,
          markerPrefix: 'police',
          markerHue: BitmapDescriptor.hueBlue,
          fallbackTitle: l10nSync('mapPoliceStationFallback'),
          serviceLabel: l10nSync('mapPoliceStationsLabel'),
        ),
        _fetchNearbyMarkers(
          endpoint: ApiConstants.nearbyHospitals,
          lat: lat,
          lng: lng,
          markerPrefix: 'hospital',
          markerHue: BitmapDescriptor.hueRed,
          fallbackTitle: l10nSync('mapHospitalsLabel'),
          serviceLabel: l10nSync('mapHospitalsLabel'),
        ),
      ]);

      final errors = <String>[];
      for (final result in results) {
        markers.addAll(result.markers);
        if (result.errorMessage != null) {
          errors.add(result.errorMessage!);
        }
      }

      setState(() {
        _isOffline = false;
        _markers.removeWhere(
          (m) =>
              m.markerId.value.startsWith('police_') ||
              m.markerId.value.startsWith('hospital_'),
        );
        _markers.addAll(markers);
        if (errors.isEmpty) {
          if (!_journeyActive &&
              (_statusText?.contains(
                    AppLocalizations.of(context).t('loadingNearbySafetyPoints'),
                  ) ??
                  false)) {
            _statusText = AppLocalizations.of(context).t('liveTrackingActive');
          }
        } else if (markers.isNotEmpty) {
          _statusText = l10nSync(
            'mapNearbyServicesPartialIssues',
            params: {'errors': errors.join(' â€¢ ')},
          );
        } else {
          _statusText = errors.join(' â€¢ ');
        }
      });
    } on DioException catch (error) {
      if (!mounted) return;
      final offline =
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
      setState(() {
        _isOffline = offline;
        _statusText = offline
            ? AppLocalizations.of(context).t('mapOfflineBannerTitle')
            : l10nSync('mapNearbyServicesLoadFailed');
      });
    }
  }

  Future<MapNearbyFetchResult> _fetchNearbyMarkers({
    required String endpoint,
    required double lat,
    required double lng,
    required String markerPrefix,
    required double markerHue,
    required String fallbackTitle,
    required String serviceLabel,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {'lat': lat, 'lng': lng},
      );

      final data = response.data;
      if (data is! List) {
        return MapNearbyFetchResult(
          errorMessage:
              '$serviceLabel returned an unexpected response from the server.',
        );
      }

      final markers = <Marker>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final coords = item['location']?['coordinates'];
        if (coords is List && coords.length == 2) {
          final itemLat = (coords[1] as num).toDouble();
          final itemLng = (coords[0] as num).toDouble();
          final name = item['name']?.toString() ?? fallbackTitle;
          final id = item['_id']?.toString() ?? '${name}_$itemLat,$itemLng';

          markers.add(
            Marker(
              markerId: MarkerId('${markerPrefix}_$id'),
              position: LatLng(itemLat, itemLng),
              infoWindow: InfoWindow(title: name, snippet: serviceLabel),
              icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
              onTap: () => unawaited(
                _presentNearbyLocationChooser(LatLng(itemLat, itemLng), name),
              ),
            ),
          );
        }
      }

      return MapNearbyFetchResult(markers: markers);
    } on DioException catch (error) {
      return MapNearbyFetchResult(
        errorMessage: _describeNearbyFetchError(
          serviceLabel: serviceLabel,
          error: error,
        ),
      );
    }
  }

  String _describeNearbyFetchError({
    required String serviceLabel,
    required DioException error,
  }) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return '$serviceLabel could not load because the request timed out.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return '$serviceLabel could not load because the network connection is unavailable.';
    }

    if (error.type == DioExceptionType.badResponse) {
      if (statusCode == 401 || statusCode == 403) {
        return '$serviceLabel could not load because the server rejected the request.';
      }
      if (statusCode == 404) {
        return '$serviceLabel endpoint was not found on the server.';
      }
      if (statusCode != null) {
        return '$serviceLabel service returned HTTP $statusCode.';
      }
      return '$serviceLabel service returned an invalid response.';
    }

    return '$serviceLabel could not load right now.';
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return;

      final loc = locations.first;
      final target = LatLng(loc.latitude, loc.longitude);
      await _showTargetOnMap(target, query);
      _closeSearch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotFindLocation')),
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _isLoadingSuggestions = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      _fetchPlaceSuggestions(query);
    });
  }

  Future<void> _fetchPlaceSuggestions(String input) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final response = await _dio.get(
        ApiConstants.nearbyAutocomplete,
        queryParameters: {
          'input': input,
          if (_position != null) 'lat': _position!.latitude,
          if (_position != null) 'lng': _position!.longitude,
        },
      );

      final data = response.data;
      final predictions = data is Map<String, dynamic>
          ? data['suggestions']
          : null;
      if (predictions is! List) {
        if (!mounted) return;
        setState(() {
          _suggestions.clear();
          _isLoadingSuggestions = false;
        });
        return;
      }

      final parsed = predictions
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => MapPlaceSuggestion(
              placeId: item['placeId']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              subtitle: item['subtitle']?.toString() ?? '',
            ),
          )
          .where((item) => item.placeId.isNotEmpty && item.title.isNotEmpty)
          .take(6)
          .toList();

      if (!mounted) return;
      setState(() {
        _suggestions
          ..clear()
          ..addAll(parsed);
        _isLoadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions.clear();
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _selectSuggestion(MapPlaceSuggestion suggestion) async {
    try {
      final response = await _dio.get(
        ApiConstants.nearbyPlaceDetails,
        queryParameters: {'placeId': suggestion.placeId},
      );

      final result = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      final lat = (result?['lat'] as num?)?.toDouble();
      final lng = (result?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        await _searchLocation();
        return;
      }

      final target = LatLng(lat, lng);
      setState(() {
        _searchController.text = suggestion.title;
        _searchController.selection = TextSelection.collapsed(
          offset: _searchController.text.length,
        );
        _suggestions.clear();
      });
      await _showTargetOnMap(target, suggestion.title);
      _closeSearch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotOpenPlace')),
        ),
      );
    }
  }

  Future<void> _buildRouteTo(LatLng target) async {
    if (_position == null) return;
    final me = LatLng(_position!.latitude, _position!.longitude);
    final requestId = ++_routeRequestId;

    setState(() {
      final directDistance = _distanceBetween(me, target);
      _routeDistanceMeters = directDistance;
      _routeEtaSeconds = null;
      _remainingDistanceMeters = directDistance;
      _remainingEtaSeconds = _journeyActive && _position != null
          ? _computeStableEtaSeconds(_position!)
          : null;
      _polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('quick_route_preview'),
            color: const Color(0xFF5B2A86),
            width: 6,
            points: [me, target],
            patterns: [PatternItem.dash(22), PatternItem.gap(10)],
          ),
        );
      _statusText = l10nSync('mapLoadingBestRoute');
    });

    try {
      final response = await _dio.get(
        ApiConstants.nearbyDirections,
        queryParameters: {
          'originLat': me.latitude,
          'originLng': me.longitude,
          'destinationLat': target.latitude,
          'destinationLng': target.longitude,
          'alternatives': true,
        },
      );

      final data = response.data;
      final routes = data is Map<String, dynamic> ? data['routes'] : null;
      if (routes is! List || routes.isEmpty) {
        throw StateError('No routes found');
      }

      final parsedRoutes = <MapDirectionRoute>[];
      var routeCounter = 0;
      for (final routeItem in routes.whereType<Map>()) {
        final item = Map<String, dynamic>.from(routeItem);
        final points = item['encodedPolyline']?.toString() ?? '';
        if (points.isEmpty) continue;

        final durationInTrafficValue =
            (item['durationInTrafficSeconds'] as num?)?.toInt();
        final durationValue = (item['durationSeconds'] as num?)?.toInt();
        final distanceText = item['distanceText']?.toString();
        final distanceValue = (item['distanceMeters'] as num?)?.toDouble();
        final durationText = item['durationText']?.toString();
        final routePoints = _decodePolyline(points);
        if (routePoints.isEmpty) continue;
        final routeScore = _scoreRouteSafety(
          routePoints: routePoints,
          etaSeconds: durationInTrafficValue ?? durationValue,
          distanceMeters: distanceValue ?? _polylineDistance(routePoints),
        );

        parsedRoutes.add(
          MapDirectionRoute(
            routeId: 'route_${routeCounter++}',
            encodedPolyline: points,
            etaSeconds: durationInTrafficValue ?? durationValue ?? 1 << 30,
            distanceMeters: distanceValue,
            distanceText: distanceText ?? '',
            durationText: durationText ?? '',
            safetyScore: routeScore.score,
            safetyReason: routeScore.reason,
          ),
        );
      }

      if (parsedRoutes.isEmpty) {
        throw StateError('No valid route geometry');
      }
      final routeAssessments = await _assessRouteCandidates(
        origin: me,
        destination: target,
        parsedRoutes: parsedRoutes,
      );
      final selectedRoute = routeAssessments.recommendedRouteId == null
          ? ([...parsedRoutes]..sort((a, b) {
                  final safetyCompare = b.safetyScore.compareTo(a.safetyScore);
                  if (safetyCompare != 0) return safetyCompare;
                  return a.etaSeconds.compareTo(b.etaSeconds);
                }))
                .first
          : parsedRoutes.firstWhere(
              (route) => route.routeId == routeAssessments.recommendedRouteId,
              orElse: () => parsedRoutes.first,
            );

      final routePoints = _decodePolyline(selectedRoute.encodedPolyline);
      final routeAssessment = routeAssessments.byRouteId[selectedRoute.routeId];
      if (!mounted || requestId != _routeRequestId) return;
      setState(() {
        _routeDistanceMeters =
            selectedRoute.distanceMeters ?? _polylineDistance(routePoints);
        _routeEtaSeconds = selectedRoute.etaSeconds;
        final pos = _position;
        if (_journeyActive && pos != null) {
          _remainingDistanceMeters = _routeDistanceMeters == null
              ? _distanceBetween(LatLng(pos.latitude, pos.longitude), target)
              : (_routeDistanceMeters! - _coveredDistanceMeters)
                    .clamp(0, double.infinity)
                    .toDouble();
          _remainingEtaSeconds = _computeStableEtaSeconds(pos);
        } else {
          _remainingDistanceMeters = _routeDistanceMeters;
          _remainingEtaSeconds = _routeEtaSeconds;
        }
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('quick_route'),
              color: const Color(0xFF4A148C),
              width: 8,
              points: routePoints,
            ),
          );
        _statusText =
            '${routeAssessment?.label ?? 'Safer route'} selected: ${selectedRoute.distanceText} - ${selectedRoute.durationText} | score ${routeAssessment?.averageSafetyScore ?? selectedRoute.safetyScore} | ${routeAssessment?.summary ?? selectedRoute.safetyReason}';
      });
      _publishMapRouteToGuard(
        routePoints: routePoints,
        destinationName:
            _selectedDestinationName ??
            l10nSync('mapSelectedDestinationFallback'),
        safetyScore:
            routeAssessment?.averageSafetyScore ?? selectedRoute.safetyScore,
        safetyReason: routeAssessment?.summary ?? selectedRoute.safetyReason,
      );
    } catch (_) {
      if (!mounted || requestId != _routeRequestId) return;
      final fallbackPoints = [me, target];
      final fallbackScore = _scoreRouteSafety(
        routePoints: fallbackPoints,
        etaSeconds: null,
        distanceMeters: _distanceBetween(me, target),
      );
      setState(() {
        _routeDistanceMeters = _distanceBetween(me, target);
        _routeEtaSeconds = null;
        _statusText = 'Road route unavailable, showing direct line fallback.';
        _polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId('quick_route'),
              color: const Color(0xFF4A148C),
              width: 8,
              points: fallbackPoints,
            ),
          );
      });
      _publishMapRouteToGuard(
        routePoints: fallbackPoints,
        destinationName:
            _selectedDestinationName ??
            l10nSync('mapSelectedDestinationFallback'),
        safetyScore: fallbackScore.score,
        safetyReason: fallbackScore.reason,
      );
    }
  }

  Future<MapRouteAssessmentResult> _assessRouteCandidates({
    required LatLng origin,
    required LatLng destination,
    required List<MapDirectionRoute> parsedRoutes,
  }) async {
    if (parsedRoutes.isEmpty) {
      return const MapRouteAssessmentResult(
        recommendedRouteId: null,
        byRouteId: {},
      );
    }

    final sortedByEta = [...parsedRoutes]
      ..sort((a, b) => a.etaSeconds.compareTo(b.etaSeconds));
    final profileIdsByRouteId = <String, String>{};
    if (sortedByEta.isNotEmpty) {
      profileIdsByRouteId[sortedByEta.first.routeId] = 'fastest';
      profileIdsByRouteId[sortedByEta.last.routeId] = 'safest';
      profileIdsByRouteId[sortedByEta[sortedByEta.length ~/ 2].routeId] =
          'balanced';
    }

    try {
      final response = await _dio.post(
        ApiConstants.safetyIntelligenceRoutes,
        data: {
          'origin': {'lat': origin.latitude, 'lng': origin.longitude},
          'destination': {
            'lat': destination.latitude,
            'lng': destination.longitude,
            'name': _selectedDestinationName,
          },
          'candidates': parsedRoutes
              .map(
                (route) => {
                  'id': route.routeId,
                  'profileId': profileIdsByRouteId[route.routeId] ?? 'balanced',
                  'durationSeconds': route.etaSeconds,
                  'distanceMeters': route.distanceMeters,
                  'path': _decodePolyline(route.encodedPolyline)
                      .map(
                        (point) => {
                          'lat': point.latitude,
                          'lng': point.longitude,
                        },
                      )
                      .toList(growable: false),
                },
              )
              .toList(growable: false),
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid route assessment response');
      }

      final routes = (data['routes'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MapRouteAssessmentDisplay.fromJson)
          .toList(growable: false);
      return MapRouteAssessmentResult(
        recommendedRouteId: data['recommendedRouteId']?.toString(),
        byRouteId: {for (final route in routes) route.id: route},
      );
    } catch (_) {
      return const MapRouteAssessmentResult(
        recommendedRouteId: null,
        byRouteId: {},
      );
    }
  }

  void _publishMapRouteToGuard({
    required List<LatLng> routePoints,
    required String destinationName,
    required int safetyScore,
    required String safetyReason,
  }) {
    if (routePoints.isEmpty) return;
    final timestamp = DateTime.now();
    unawaited(
      ref
          .read(routeSafetyProvider.notifier)
          .setActiveMapRoute(
            routePoints: routePoints
                .map(
                  (point) => RoutePoint(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    timestamp: timestamp,
                  ),
                )
                .toList(growable: false),
            destinationName: destinationName,
            safetyScore: safetyScore,
            safetyReason: safetyReason,
          ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        if (index >= encoded.length) {
          return points;
        }
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        if (index >= encoded.length) {
          return points;
        }
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  double _polylineDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    double total = 0;
    for (var i = 1; i < points.length; i++) {
      total += _distanceBetween(points[i - 1], points[i]);
    }
    return total;
  }

  MapRouteSafetyScore _scoreRouteSafety({
    required List<LatLng> routePoints,
    required int? etaSeconds,
    required double distanceMeters,
  }) {
    var score = 68;
    final now = DateTime.now();
    final isNight = now.hour >= 21 || now.hour < 6;
    final emergencyMarkers = _markers.where(
      (marker) =>
          marker.markerId.value.startsWith('police_') ||
          marker.markerId.value.startsWith('hospital_'),
    );

    var nearbyEmergencyCount = 0;
    for (final marker in emergencyMarkers) {
      final nearest = _nearestPointDistance(routePoints, marker.position);
      if (nearest <= 700) nearbyEmergencyCount++;
    }

    score += min(nearbyEmergencyCount * 5, 22);
    if (isNight) score -= 12;
    if (distanceMeters > 12000) score -= 4;
    if (etaSeconds != null && etaSeconds > 45 * 60) score -= 4;
    score = score.clamp(0, 98);

    final reason = nearbyEmergencyCount > 0
        ? '$nearbyEmergencyCount emergency points near route'
        : isNight
        ? 'Night route, limited mapped emergency points'
        : 'Balanced by route length and nearby services';

    return MapRouteSafetyScore(score: score, reason: reason);
  }

  double _nearestPointDistance(List<LatLng> routePoints, LatLng target) {
    var nearest = double.infinity;
    for (final point in routePoints) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        target.latitude,
        target.longitude,
      );
      if (distance < nearest) nearest = distance;
    }
    return nearest;
  }

  Future<void> _goToMyLocation() async {
    final pos = _position;
    if (pos == null || _mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 16),
      ),
    );
  }

  void _dropPin(LatLng point) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'custom_pin');
      _markers.add(
        Marker(
          markerId: const MarkerId('custom_pin'),
          position: point,
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context).t('customPin'),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });
    _selectDestination(point, AppLocalizations.of(context).t('customPin'));
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final position = _position;
    final safetyState = ref.watch(safetyMonitorProvider);
    final mapCircles = {..._circles, ..._buildHeatmapCircles(safetyState)};
    final journeyPanelOffset = _selectedDestination == null
        ? 18.0
        : _journeyPanelCollapsed
        ? 126.0
        : 244.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('safetyIntelligenceMap')),
        systemOverlayStyle: AppTheme.overlayStyleForBrightness(
          Theme.of(context).brightness,
        ),
      ),
      body: Stack(
        children: [
          if (position == null)
            MapLocatingView(
              isLoading: _isLoading,
              isLight: isLight,
              statusText: _statusText,
              onRetry: _initializeMap,
              onDialPolice: () => _dialNumber('100'),
              onDialHelpline: () => _dialNumber('1091'),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              onTap: (_) {},
              onLongPress: _dropPin,
              onCameraMoveStarted: () {
                if (_followMe) setState(() => _followMe = false);
              },
              markers: {..._markers, ..._publicToiletMarkers},
              circles: mapCircles,
              polylines: _polylines,
              trafficEnabled: _trafficEnabled,
              compassEnabled: true,
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: _mapType,
            ),
          if (position != null) ...[
            MapTopSearchBar(
              isSearchOpen: _isSearchOpen,
              controller: _searchController,
              focusNode: _searchFocusNode,
              isLoadingSuggestions: _isLoadingSuggestions,
              suggestions: _suggestions,
              onChanged: _onSearchChanged,
              onSearch: _searchLocation,
              onOpen: _openSearch,
              onClose: _closeSearch,
              onSuggestionTap: _selectSuggestion,
            ),
            MapQuickControls(
              isSearchOpen: _isSearchOpen,
              followMe: _followMe,
              showPlacesList: _showPlacesList,
              trafficEnabled: _trafficEnabled,
              onMyLocationTap: () {
                setState(() => _followMe = !_followMe);
                if (_followMe) {
                  _goToMyLocation();
                }
              },
              onTogglePlacesList: () =>
                  setState(() => _showPlacesList = !_showPlacesList),
              onToggleTraffic: () =>
                  setState(() => _trafficEnabled = !_trafficEnabled),
              onLayersTap: _showLayerOptionsSheet,
              onToiletsTap: _openNearbyCleanToilets,
              onSafetyTap: _openLiveSafetySheet,
            ),
            if (_isOffline)
              MapOfflineBanner(
                isSearchOpen: _isSearchOpen,
                isLight: isLight,
                onDialPolice: () => _dialNumber('100'),
                onDialHelpline: () => _dialNumber('1091'),
              ),
            if (_showPlacesList)
              MapPlacesListPanel(
                isLight: isLight,
                isOffline: _isOffline,
                isSearchOpen: _isSearchOpen,
                markers: _markers,
                onClose: () => setState(() => _showPlacesList = false),
                onPlaceTap: (position, title) =>
                    unawaited(_presentNearbyLocationChooser(position, title)),
              ),
          ],
          if (_journeyActive &&
              (safetyState.journeyInAppAlert != null ||
                  (safetyState.rerouteHint?.isNotEmpty ?? false)))
            Positioned(
              top: 78,
              left: 16,
              right: 16,
              child: JourneyAlertBanner(
                safetyState: safetyState,
                isLight: isLight,
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: journeyPanelOffset,
            child: IgnorePointer(
              child: Semantics(
                label:
                    _statusText ??
                    'Long press to drop pin. Tap markers to preview route.',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFFFFFFF).withValues(alpha: 0.9)
                        : AppTheme.cardColor.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight
                          ? const Color(0xFFDCE5F6)
                          : Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates_rounded,
                        size: 17,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _statusText ??
                              'Long press to drop pin. Tap markers to preview route.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isLight ? Color(0xFF546784) : Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading && position != null)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          if (position != null && _selectedDestination != null)
            JourneyPanel(
              isLight: isLight,
              journeyActive: _journeyActive,
              journeyPanelCollapsed: _journeyPanelCollapsed,
              selectedDestinationName: _selectedDestinationName,
              coveredDistanceMeters: _coveredDistanceMeters,
              routeDistanceMeters: _routeDistanceMeters,
              remainingDistanceMeters: _remainingDistanceMeters,
              remainingEtaSeconds: _remainingEtaSeconds,
              onSetCollapsed: _setJourneyPanelCollapsed,
              onStartJourney: _startJourney,
              onStopJourney: _stopJourney,
            ),
        ],
      ),
    );
  }

  void _openSearch() {
    setState(() => _isSearchOpen = true);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchOpen = false;
      _suggestions.clear();
    });
  }

  Future<void> _dialNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotOpenDialer')),
        ),
      );
    }
  }

  void _openNearbyCleanToilets() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NearbyCleanToiletsScreen(
          initialFilters: NearbyCleanToiletFilters(radiusMeters: 5000),
        ),
      ),
    );
  }

  Future<void> _showLayerOptionsSheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isLight = Theme.of(sheetContext).brightness == Brightness.light;
        final surfaceColor = Theme.of(sheetContext).colorScheme.surface;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                void setMapType(MapType type) {
                  setState(() => _mapType = type);
                  setSheetState(() {});
                }

                Future<void> setPublicToilets(bool enabled) async {
                  await _setPublicToiletsEnabled(enabled);
                  if (mounted) setSheetState(() {});
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).t('mapLayers'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(
                            AppLocalizations.of(context).t('mapTypeNormal'),
                          ),
                          selected: _mapType == MapType.normal,
                          onSelected: (_) => setMapType(MapType.normal),
                        ),
                        ChoiceChip(
                          label: Text(
                            AppLocalizations.of(context).t('mapTypeHybrid'),
                          ),
                          selected: _mapType == MapType.hybrid,
                          onSelected: (_) => setMapType(MapType.hybrid),
                        ),
                        ChoiceChip(
                          label: Text(
                            AppLocalizations.of(context).t('mapTypeTerrain'),
                          ),
                          selected: _mapType == MapType.terrain,
                          onSelected: (_) => setMapType(MapType.terrain),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _trafficEnabled,
                      onChanged: (value) {
                        setState(() => _trafficEnabled = value);
                        setSheetState(() {});
                      },
                      title: Text(AppLocalizations.of(context).t('mapTraffic')),
                      subtitle: Text(
                        AppLocalizations.of(context).t('mapTrafficSubtitle'),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _publicToiletsEnabled,
                      onChanged: (value) => unawaited(setPublicToilets(value)),
                      title: Text(
                        AppLocalizations.of(context).t('mapPublicToilets'),
                      ),
                      subtitle: Text(
                        _publicToiletsEnabled
                            ? _publicToiletsLoading
                                  ? AppLocalizations.of(
                                      context,
                                    ).t('toiletsLoadingNearby')
                                  : _publicToiletsError ??
                                        (_publicToiletsFetchSucceeded &&
                                                _publicToilets.isEmpty
                                            ? AppLocalizations.of(
                                                context,
                                              ).t('toiletsNoToiletsInArea')
                                            : AppLocalizations.of(context)
                                                  .t('toiletsOnMapCount')
                                                  .replaceAll(
                                                    '{count}',
                                                    '${_publicToilets.length}',
                                                  ))
                            : 'Display nearby clean public toilets as a layer',
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF65758F)
                              : Colors.white60,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _setPublicToiletsEnabled(bool enabled) async {
    if (!mounted) return;
    setState(() {
      _publicToiletsEnabled = enabled;
      if (!enabled) {
        _publicToilets.clear();
        _publicToiletMarkers.clear();
        _publicToiletsError = null;
        _publicToiletsLoading = false;
        _publicToiletsFetchSucceeded = false;
      }
    });

    if (!enabled) return;
    await _refreshPublicToiletsLayer();
  }

  Future<void> _refreshPublicToiletsLayer() async {
    final pos = _position;
    if (!_publicToiletsEnabled || pos == null) return;

    if (!mounted) return;
    setState(() {
      _publicToiletsLoading = true;
      _publicToiletsError = null;
      _publicToiletsFetchSucceeded = false;
    });

    try {
      final toilets = await _toiletService.fetchNearbyToilets(
        latitude: pos.latitude,
        longitude: pos.longitude,
        filters: const NearbyCleanToiletFilters(),
      );

      if (!mounted) return;
      setState(() {
        _publicToilets
          ..clear()
          ..addAll(toilets);
        _publicToiletMarkers
          ..clear()
          ..addAll(
            NearbyCleanToiletsService.buildMarkers(
              toilets,
              onTap: _showPublicToiletDetails,
            ),
          );
        _publicToiletsError = null;
        _publicToiletsLoading = false;
        _publicToiletsFetchSucceeded = true;
      });
    } on NearbyCleanToiletException catch (error) {
      if (!mounted) return;
      setState(() {
        _publicToilets.clear();
        _publicToiletMarkers.clear();
        _publicToiletsError = error.message;
        _publicToiletsLoading = false;
        _publicToiletsFetchSucceeded = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _publicToilets.clear();
        _publicToiletMarkers.clear();
        _publicToiletsError = AppLocalizations.of(
          context,
        ).t('toiletsConnectionError');
        _publicToiletsLoading = false;
        _publicToiletsFetchSucceeded = false;
      });
    }
  }

  Future<void> _showPublicToiletDetails(NearbyCleanToilet toilet) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ToiletDetailsSheet(
        toilet: toilet,
        onNavigate: () => _navigateToToilet(toilet),
        onReportIssue: () => _reportToiletIssue(toilet),
        onViewOnMap: () {
          Navigator.of(context).pop();
          _focusOnPublicToilet(toilet);
        },
      ),
    );
  }

  Future<void> _navigateToToilet(NearbyCleanToilet toilet) async {
    final uri = NearbyCleanToiletsService.buildNavigationUri(toilet);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _reportToiletIssue(NearbyCleanToilet toilet) async {
    final uri = NearbyCleanToiletsService.buildIssueReportUri(toilet);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _focusOnPublicToilet(NearbyCleanToilet toilet) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(toilet.latitude, toilet.longitude), 16),
    );
  }

  void _openLiveSafetySheet() {
    final safetyState = ref.read(safetyMonitorProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return LiveSafetyControlsSheet(
          position: _position,
          safetyScore: safetyState.safetyScore,
          riskLevel: AppLocalizations.of(
            context,
          ).localizeRiskLabel(safetyState.riskLabel),
          aiConfidence: safetyState.aiConfidenceVisible
              ? safetyState.aiConfidence
              : null,
          contributingFactors: safetyState.contributingFactors,
          recommendations: safetyState.recommendations,
          upcomingRisk: safetyState.upcomingRisk,
          statusText: _statusText,
          onMyLocation: _goToMyLocation,
          onRefreshNearby: () async {
            final pos = _position;
            if (pos == null) return;
            await _fetchNearby(pos.latitude, pos.longitude);
          },
          onRetryLiveLocation: _initializeMap,
        );
      },
    );
  }

  Set<Circle> _buildHeatmapCircles(SafetyMonitorState safetyState) {
    final tiles = safetyState.heatmapTiles;
    // Heatmap tiles are only replaced (new list instance) when the backend
    // actually returns fresh data — reuse the previously built circles when
    // the tiles list reference hasn't changed to avoid rebuilding on every
    // unrelated safety-state emission.
    if (_cachedHeatmapCircles != null &&
        identical(_cachedHeatmapTilesRef, tiles)) {
      return _cachedHeatmapCircles!;
    }

    final circles = tiles
        .map(
          (tile) => Circle(
            circleId: CircleId('heat_${tile.latitude}_${tile.longitude}'),
            center: LatLng(tile.latitude, tile.longitude),
            radius: 115,
            fillColor: _colorFromHex(tile.colorHex).withValues(alpha: 0.22),
            strokeColor: _colorFromHex(tile.colorHex).withValues(alpha: 0.58),
            strokeWidth: 1,
          ),
        )
        .toSet();

    _cachedHeatmapTilesRef = tiles;
    _cachedHeatmapCircles = circles;
    return circles;
  }

  Color _colorFromHex(String value) {
    final normalized = value.replaceAll('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.tryParse(hex, radix: 16) ?? 0xFFEAB308);
  }
}
