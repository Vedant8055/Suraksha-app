import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';
import 'package:suraksha_women_safety_app/features/dashboard/emergency_services_scan_service.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';

class SafetyResource {
  final String id;
  final String type;
  final String name;
  final String address;
  final String phone;
  final int distanceMeters;

  const SafetyResource({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.phone,
    required this.distanceMeters,
  });

  factory SafetyResource.fromJson(Map<String, dynamic> json) {
    return SafetyResource(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'resource',
      name: json['name']?.toString() ?? 'Safety resource',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      distanceMeters: (json['distanceMeters'] as num?)?.round() ?? 0,
    );
  }
}

class SafetyDimensionScore {
  final String key;
  final int score;
  final String label;
  final int confidence;
  final List<String> sources;

  const SafetyDimensionScore({
    required this.key,
    required this.score,
    required this.label,
    required this.confidence,
    this.sources = const [],
  });

  factory SafetyDimensionScore.fromJson(Map<String, dynamic> json) {
    return SafetyDimensionScore(
      key: json['key']?.toString() ?? 'dimension',
      score: (json['score'] as num?)?.round() ?? 50,
      label: json['label']?.toString() ?? 'Moderate',
      confidence: (json['confidence'] as num?)?.round() ?? 50,
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

class SafetyCommunityAlert {
  final String category;
  final String priority;
  final int distanceMeters;
  final DateTime timestamp;
  final String summary;
  final String recommendedAction;
  final String? dataSource;
  final int? confidence;
  final String? disclaimer;
  final List<String> riskReasons;
  final String? verdictHeadline;

  const SafetyCommunityAlert({
    required this.category,
    required this.priority,
    required this.distanceMeters,
    required this.timestamp,
    required this.summary,
    required this.recommendedAction,
    this.dataSource,
    this.confidence,
    this.disclaimer,
    this.riskReasons = const [],
    this.verdictHeadline,
  });

  factory SafetyCommunityAlert.fromJson(Map<String, dynamic> json) {
    return SafetyCommunityAlert(
      category: json['category']?.toString() ?? 'Alert',
      priority: json['priority']?.toString() ?? 'information',
      distanceMeters: (json['distanceMeters'] as num?)?.round() ?? 0,
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      summary: json['summary']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
      dataSource: json['dataSource']?.toString(),
      confidence: (json['confidence'] as num?)?.round(),
      disclaimer: json['disclaimer']?.toString(),
      riskReasons: (json['riskReasons'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      verdictHeadline: json['verdictHeadline']?.toString(),
    );
  }
}

class SafetyJourneyAlert {
  final String type;
  final String priority;
  final String title;
  final String body;
  final String recommendedAction;

  const SafetyJourneyAlert({
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    required this.recommendedAction,
  });

  factory SafetyJourneyAlert.fromJson(Map<String, dynamic> json) {
    return SafetyJourneyAlert(
      type: json['type']?.toString() ?? 'alert',
      priority: json['priority']?.toString() ?? 'information',
      title: json['title']?.toString() ?? 'Safety alert',
      body: json['body']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
    );
  }
}

class SafetyHeatmapTile {
  final double latitude;
  final double longitude;
  final int safetyScore;
  final String riskLevel;
  final String colorHex;
  final DateTime timestamp;

  const SafetyHeatmapTile({
    required this.latitude,
    required this.longitude,
    required this.safetyScore,
    required this.riskLevel,
    required this.colorHex,
    required this.timestamp,
  });

  factory SafetyHeatmapTile.fromJson(Map<String, dynamic> json) {
    return SafetyHeatmapTile(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      safetyScore: (json['safetyScore'] as num?)?.round() ?? 50,
      riskLevel: json['riskLevel']?.toString() ?? 'Moderate Risk',
      colorHex: json['colorHex']?.toString() ?? '#EAB308',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class UpcomingRiskAlert {
  final int distanceMeters;
  final int safetyScore;
  final String riskLevel;
  final List<String> reasons;
  final String summary;
  final String recommendedAction;

  const UpcomingRiskAlert({
    required this.distanceMeters,
    required this.safetyScore,
    required this.riskLevel,
    required this.reasons,
    required this.summary,
    required this.recommendedAction,
  });

  factory UpcomingRiskAlert.fromJson(Map<String, dynamic> json) {
    return UpcomingRiskAlert(
      distanceMeters: (json['distanceMeters'] as num?)?.round() ?? 0,
      safetyScore: (json['safetyScore'] as num?)?.round() ?? 50,
      riskLevel: json['riskLevel']?.toString() ?? 'Moderate Risk',
      reasons: (json['reasons'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      summary: json['summary']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
    );
  }
}

class SafetyMonitorState {
  final bool gpsEnabled;
  final bool permissionGranted;
  final bool trackingActive;
  final bool isRefreshing;
  final Position? position;
  final DateTime? lastUpdatedAt;
  final int nearbyPoliceCount;
  final int nearbyHospitalCount;
  final int nearbySupportCount;
  final int safetyScore;
  final String riskLabel;
  final String statusMessage;
  final int? aiConfidence;
  final bool aiConfidenceVisible;
  final String? limitedAssessmentMessage;
  final List<String> contributingFactors;
  final List<String> recommendations;
  final List<SafetyCommunityAlert> communityAlerts;
  final List<SafetyResource> nearbyResources;
  final List<SafetyHeatmapTile> heatmapTiles;
  final UpcomingRiskAlert? upcomingRisk;
  final String? summary;
  final String? regionLabel;
  final String? dataDisclaimer;
  final List<SafetyDimensionScore> dimensions;
  final String? fusionModelVersion;
  final bool journeyMode;
  final bool areaAssessmentReady;
  final String? aiSummarySource;
  final String? aiSummaryAction;
  final SafetyJourneyAlert? journeyInAppAlert;
  final String? rerouteHint;
  final NearbyEmergencyServicesSnapshot emergencyServices1km;

  bool get hasCoreEmergencyWithin1km =>
      emergencyServices1km.hasCoreEmergencySupport;

  const SafetyMonitorState({
    this.gpsEnabled = false,
    this.permissionGranted = false,
    this.trackingActive = false,
    this.isRefreshing = false,
    this.position,
    this.lastUpdatedAt,
    this.nearbyPoliceCount = 0,
    this.nearbyHospitalCount = 0,
    this.nearbySupportCount = 0,
    this.safetyScore = 50,
    this.riskLabel = 'Monitoring',
    this.statusMessage = 'statusInitializing',
    this.aiConfidence,
    this.aiConfidenceVisible = false,
    this.limitedAssessmentMessage,
    this.contributingFactors = const [],
    this.recommendations = const [],
    this.communityAlerts = const [],
    this.nearbyResources = const [],
    this.heatmapTiles = const [],
    this.upcomingRisk,
    this.summary,
    this.regionLabel,
    this.dataDisclaimer,
    this.dimensions = const [],
    this.fusionModelVersion,
    this.journeyMode = false,
    this.areaAssessmentReady = false,
    this.aiSummarySource,
    this.aiSummaryAction,
    this.journeyInAppAlert,
    this.rerouteHint,
    this.emergencyServices1km = const NearbyEmergencyServicesSnapshot(),
  });

  SafetyMonitorState copyWith({
    bool? gpsEnabled,
    bool? permissionGranted,
    bool? trackingActive,
    bool? isRefreshing,
    Position? position,
    DateTime? lastUpdatedAt,
    int? nearbyPoliceCount,
    int? nearbyHospitalCount,
    int? nearbySupportCount,
    int? safetyScore,
    String? riskLabel,
    String? statusMessage,
    int? aiConfidence,
    bool? aiConfidenceVisible,
    String? limitedAssessmentMessage,
    bool clearLimitedAssessmentMessage = false,
    List<String>? contributingFactors,
    List<String>? recommendations,
    List<SafetyCommunityAlert>? communityAlerts,
    List<SafetyResource>? nearbyResources,
    List<SafetyHeatmapTile>? heatmapTiles,
    UpcomingRiskAlert? upcomingRisk,
    bool clearUpcomingRisk = false,
    String? summary,
    String? regionLabel,
    String? dataDisclaimer,
    List<SafetyDimensionScore>? dimensions,
    String? fusionModelVersion,
    bool? journeyMode,
    bool? areaAssessmentReady,
    String? aiSummarySource,
    String? aiSummaryAction,
    SafetyJourneyAlert? journeyInAppAlert,
    bool clearJourneyInAppAlert = false,
    String? rerouteHint,
    bool clearRerouteHint = false,
    NearbyEmergencyServicesSnapshot? emergencyServices1km,
  }) {
    return SafetyMonitorState(
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      trackingActive: trackingActive ?? this.trackingActive,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      position: position ?? this.position,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      nearbyPoliceCount: nearbyPoliceCount ?? this.nearbyPoliceCount,
      nearbyHospitalCount: nearbyHospitalCount ?? this.nearbyHospitalCount,
      nearbySupportCount: nearbySupportCount ?? this.nearbySupportCount,
      safetyScore: safetyScore ?? this.safetyScore,
      riskLabel: riskLabel ?? this.riskLabel,
      statusMessage: statusMessage ?? this.statusMessage,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiConfidenceVisible: aiConfidenceVisible ?? this.aiConfidenceVisible,
      limitedAssessmentMessage: clearLimitedAssessmentMessage
          ? null
          : (limitedAssessmentMessage ?? this.limitedAssessmentMessage),
      contributingFactors: contributingFactors ?? this.contributingFactors,
      recommendations: recommendations ?? this.recommendations,
      communityAlerts: communityAlerts ?? this.communityAlerts,
      nearbyResources: nearbyResources ?? this.nearbyResources,
      heatmapTiles: heatmapTiles ?? this.heatmapTiles,
      upcomingRisk: clearUpcomingRisk
          ? null
          : (upcomingRisk ?? this.upcomingRisk),
      summary: summary ?? this.summary,
      regionLabel: regionLabel ?? this.regionLabel,
      dataDisclaimer: dataDisclaimer ?? this.dataDisclaimer,
      dimensions: dimensions ?? this.dimensions,
      fusionModelVersion: fusionModelVersion ?? this.fusionModelVersion,
      journeyMode: journeyMode ?? this.journeyMode,
      areaAssessmentReady: areaAssessmentReady ?? this.areaAssessmentReady,
      aiSummarySource: aiSummarySource ?? this.aiSummarySource,
      aiSummaryAction: aiSummaryAction ?? this.aiSummaryAction,
      journeyInAppAlert: clearJourneyInAppAlert
          ? null
          : (journeyInAppAlert ?? this.journeyInAppAlert),
      rerouteHint: clearRerouteHint ? null : (rerouteHint ?? this.rerouteHint),
      emergencyServices1km: emergencyServices1km ?? this.emergencyServices1km,
    );
  }
}

final safetyMonitorProvider =
    StateNotifierProvider<SafetyMonitorNotifier, SafetyMonitorState>(
      (ref) => SafetyMonitorNotifier(),
    );

class SafetyMonitorNotifier extends StateNotifier<SafetyMonitorState> {
  SafetyMonitorNotifier({EmergencyServicesScanService? emergencyScanService})
    : _emergencyScanService =
          emergencyScanService ?? EmergencyServicesScanService(),
      super(const SafetyMonitorState());

  final Dio _dio = DioClient().dio;
  final EmergencyServicesScanService _emergencyScanService;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _nearbyRefreshTimer;
  bool _started = false;
  DateTime? _lastNearbyRefreshAt;
  DateTime? _lastPingAt;
  Position? _lastAssessmentPosition;
  bool _journeyMode = false;
  double? _journeyDestinationLat;
  double? _journeyDestinationLng;
  String _summaryLang = 'en';
  bool _emergencyScanInFlight = false;

  Duration get _refreshInterval =>
      _journeyMode ? const Duration(seconds: 45) : const Duration(minutes: 2);

  int get _moveThresholdMeters => _journeyMode ? 40 : 75;

  /// Minimum movement before we notify listeners with an updated position.
  /// Tiny GPS jitter below this threshold does not warrant a state emission.
  static const int _positionNotifyThresholdMeters = 9;

  Duration get _staleAssessmentDuration =>
      _journeyMode ? const Duration(seconds: 40) : const Duration(seconds: 45);

  void setSummaryLanguage(String lang) {
    _summaryLang = lang;
  }

  void setJourneyMode(
    bool active, {
    double? destinationLat,
    double? destinationLng,
  }) {
    _journeyMode = active;
    _journeyDestinationLat = active ? destinationLat : null;
    _journeyDestinationLng = active ? destinationLng : null;
    state = state.copyWith(
      journeyMode: active,
      clearJourneyInAppAlert: !active,
      clearRerouteHint: !active,
    );
    _startNearbyRefreshLoop();
    final pos = state.position;
    if (pos != null) {
      unawaited(_refreshSafetyIntelligence(pos, force: true));
    }
  }

  Future<void> start() async {
    if (_started && state.trackingActive) return;
    _started = true;

    try {
      await _ensureGpsAndPermission();
      if (!state.gpsEnabled || !state.permissionGranted) {
        state = state.copyWith(trackingActive: false);
        _started = false;
        return;
      }

      await _bootstrapPosition();
      _startLivePositionStream();
      _startNearbyRefreshLoop();
    } catch (_) {
      _started = false;
      state = state.copyWith(trackingActive: false);
    }
  }

  Future<void> retry() async {
    _started = false;
    await stop();
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      await Geolocator.openLocationSettings();
    }
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
    try {
      await start();
    } catch (_) {
      state = state.copyWith(trackingActive: false);
    }
  }

  Future<void> refresh() async {
    final pos = state.position;
    if (pos != null) {
      _lastNearbyRefreshAt = DateTime.now();
      // Refresh services in parallel so the AI card list updates even if
      // the full intelligence request is slow.
      unawaited(ensureEmergencyServicesScanned(force: true));
      await _refreshSafetyIntelligence(pos, force: true);
      return;
    }
    await start();
  }

  /// Ensures the 1 km emergency-services snapshot is populated for the AI card.
  Future<void> ensureEmergencyServicesScanned({bool force = false}) async {
    final pos = state.position;
    if (pos == null) return;
    if (!force && state.emergencyServices1km.scanned) return;
    final scan = await _scanEmergencyServices1km(pos);
    final enriched = _enrichEmergencyServices(scan, state.nearbyResources);
    state = state.copyWith(
      emergencyServices1km: enriched,
      nearbyPoliceCount: enriched.policeCount,
      nearbyHospitalCount: enriched.hospitalCount,
      nearbySupportCount: enriched.totalCount,
    );
  }

  /// Auto-triggers the 1 km emergency-services scan once per position epoch
  /// when it hasn't been scanned yet. Guarded so it only ever has a single
  /// in-flight call at a time (no build-time or duplicate network calls).
  void _triggerEmergencyScanIfNeeded() {
    if (state.position == null) return;
    if (state.emergencyServices1km.scanned) return;
    if (_emergencyScanInFlight) return;
    _emergencyScanInFlight = true;
    unawaited(
      ensureEmergencyServicesScanned().whenComplete(() {
        _emergencyScanInFlight = false;
      }),
    );
  }

  /// Auto-triggers the area intelligence refresh once per position epoch
  /// when the area assessment isn't ready yet and no refresh is in flight.
  void _triggerIntelligenceRefreshIfNeeded(Position position) {
    if (state.areaAssessmentReady || state.isRefreshing) return;
    _lastNearbyRefreshAt = DateTime.now();
    unawaited(_refreshSafetyIntelligence(position));
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _nearbyRefreshTimer?.cancel();
    _nearbyRefreshTimer = null;
    state = state.copyWith(trackingActive: false);
  }

  Future<void> _ensureGpsAndPermission() async {
    // Central gate: only this path may prompt for location permission.
    final access = await LocationPermissionService.ensureAccess(
      mayRequest: true,
    );
    final granted = access.isGranted;
    final deniedForever = access.isDeniedForever;

    state = state.copyWith(
      gpsEnabled: access.gpsEnabled,
      permissionGranted: granted,
      statusMessage: !access.gpsEnabled
          ? 'statusGpsOff'
          : deniedForever
          ? 'statusLocationDeniedForever'
          : !granted
          ? 'statusLocationPermissionRequired'
          : 'statusGpsConnected',
      riskLabel:
          !access.gpsEnabled || !granted ? 'Location Off' : state.riskLabel,
    );
  }

  Future<void> _bootstrapPosition() async {
    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos != null) {
        state = state.copyWith(
          position: pos,
          lastUpdatedAt: DateTime.now(),
          trackingActive: true,
          statusMessage: 'statusFetchingIntelligence',
        );
        // _refreshSafetyIntelligence scans emergency services internally, so
        // no separate auto-trigger is needed on this path.
        await _refreshSafetyIntelligence(pos, force: true);
      }
    } catch (_) {}
  }

  void _startLivePositionStream() {
    final settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
            intervalDuration: const Duration(seconds: 8),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'Suraksha Safety Monitor',
              notificationText: 'Capturing realtime area safety data.',
              enableWakeLock: false,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 15,
          );

    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) {
            // Skip redundant position notifies for tiny GPS jitter, but keep
            // running the move/stale assessment logic against the new
            // position so intelligence refreshes are never missed.
            final previousPosition = state.position;
            final positionMoved = previousPosition == null
                ? true
                : Geolocator.distanceBetween(
                        previousPosition.latitude,
                        previousPosition.longitude,
                        pos.latitude,
                        pos.longitude,
                      ) >=
                      _positionNotifyThresholdMeters;

            if (positionMoved || !state.trackingActive) {
              state = state.copyWith(
                position: pos,
                trackingActive: true,
                lastUpdatedAt: DateTime.now(),
              );
            }

            final now = DateTime.now();
            final movedEnough = _lastAssessmentPosition == null
                ? true
                : Geolocator.distanceBetween(
                        _lastAssessmentPosition!.latitude,
                        _lastAssessmentPosition!.longitude,
                        pos.latitude,
                        pos.longitude,
                      ) >=
                      _moveThresholdMeters;
            final staleAssessment =
                _lastNearbyRefreshAt == null ||
                now.difference(_lastNearbyRefreshAt!) >
                    _staleAssessmentDuration;
            if (!state.areaAssessmentReady && !state.isRefreshing) {
              _triggerIntelligenceRefreshIfNeeded(pos);
            } else if (movedEnough || staleAssessment) {
              _lastNearbyRefreshAt = now;
              unawaited(_refreshSafetyIntelligence(pos));
            }
            _triggerEmergencyScanIfNeeded();
          },
          onError: (_) {
            state = state.copyWith(
              trackingActive: false,
              statusMessage: 'statusLiveStreamPaused',
            );
          },
        );
  }

  void _startNearbyRefreshLoop() {
    _nearbyRefreshTimer?.cancel();
    _nearbyRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
      final pos = state.position;
      if (pos == null) return;
      await _refreshSafetyIntelligence(pos, force: true);
    });
  }

  Future<void> _refreshSafetyIntelligence(
    Position position, {
    bool force = false,
  }) async {
    state = state.copyWith(isRefreshing: true);
    final emergencyScanFuture = _scanEmergencyServices1km(position);
    try {
      await NetworkManager.instance.ensureReachable();
      final response = await _fetchLiveAssessment(position);
      final emergencyServices = await emergencyScanFuture;
      await _applyLiveAssessmentResponse(
        response,
        position,
        force: force,
        emergencyServices: emergencyServices,
      );
    } on DioException catch (error) {
      if (BackendUrlResolver.isConnectionError(error)) {
        final recovered = await NetworkManager.instance.recoverConnection();
        if (recovered) {
          try {
            final response = await _fetchLiveAssessment(position);
            final emergencyServices = await emergencyScanFuture;
            await _applyLiveAssessmentResponse(
              response,
              position,
              force: force,
              emergencyServices: emergencyServices,
            );
            return;
          } catch (_) {}
        }
      }
      final emergencyServices = await emergencyScanFuture;
      await _fallbackRefreshNearbyCounts(
        position.latitude,
        position.longitude,
        emergencyServices: emergencyServices,
      );
    } catch (_) {
      final emergencyServices = await emergencyScanFuture;
      await _fallbackRefreshNearbyCounts(
        position.latitude,
        position.longitude,
        emergencyServices: emergencyServices,
      );
    } finally {
      if (state.isRefreshing) {
        state = state.copyWith(isRefreshing: false);
      }
    }
  }

  Future<NearbyEmergencyServicesSnapshot> _scanEmergencyServices1km(
    Position position,
  ) async {
    try {
      return await _emergencyScanService
          .scanWithinRadius(
            latitude: position.latitude,
            longitude: position.longitude,
            radiusMeters: EmergencyServicesScanService.defaultRadiusMeters,
            languageCode: _summaryLang,
          )
          .timeout(const Duration(seconds: 18));
    } catch (_) {
      // Still mark scanned so the card always shows the 1 km services section.
      return NearbyEmergencyServicesSnapshot(
        radiusMeters: EmergencyServicesScanService.defaultRadiusMeters,
        scanned: true,
        policeCount: state.nearbyPoliceCount,
        hospitalCount: state.nearbyHospitalCount,
      );
    }
  }

  NearbyEmergencyServicesSnapshot _enrichEmergencyServices(
    NearbyEmergencyServicesSnapshot scan,
    List<SafetyResource> resources,
  ) {
    var police = scan.policeCount;
    var hospitals = scan.hospitalCount;
    if (police == 0) {
      police = resources
          .where(
            (resource) =>
                resource.distanceMeters <= 1000 &&
                resource.type.toLowerCase().contains('police'),
          )
          .length;
    }
    if (hospitals == 0) {
      hospitals = resources
          .where((resource) {
            if (resource.distanceMeters > 1000) return false;
            final type = resource.type.toLowerCase();
            return type.contains('hospital') || type.contains('clinic');
          })
          .length;
    }
    return NearbyEmergencyServicesSnapshot(
      policeCount: police,
      hospitalCount: hospitals,
      pharmacyCount: scan.pharmacyCount,
      petrolPumpCount: scan.petrolPumpCount,
      washroomCount: scan.washroomCount,
      bloodBankCount: scan.bloodBankCount,
      radiusMeters: scan.radiusMeters,
      scanned: true,
    );
  }

  Future<Response<dynamic>> _fetchLiveAssessment(Position position) {
    return _dio.get(
      ApiConstants.safetyIntelligenceLive,
      queryParameters: {
        'lat': position.latitude,
        'lng': position.longitude,
        'heading': position.heading.isFinite ? position.heading : 0,
        'accuracy': position.accuracy,
        'includeSummary': 'true',
        'lang': _summaryLang,
        'journeyMode': _journeyMode ? 'true' : 'false',
        if (_journeyDestinationLat != null && _journeyDestinationLng != null)
          'destinationLat': _journeyDestinationLat,
        if (_journeyDestinationLat != null && _journeyDestinationLng != null)
          'destinationLng': _journeyDestinationLng,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 20),
      ),
    );
  }

  Future<void> _applyLiveAssessmentResponse(
    Response<dynamic> response,
    Position position, {
    required bool force,
    NearbyEmergencyServicesSnapshot? emergencyServices,
  }) async {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid safety intelligence response');
    }

    final current = data['current'];
    final meta = data['meta'];
    var communityAlerts =
        (data['communityAlerts'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SafetyCommunityAlert.fromJson)
            .toList(growable: false);
    final nearbyResources =
        (data['nearbyResources'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SafetyResource.fromJson)
            .toList(growable: false);
    final heatmapTiles = (data['heatmapTiles'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SafetyHeatmapTile.fromJson)
        .toList(growable: false);

    final currentMap = current is Map<String, dynamic> ? current : const {};
    final metaMap = meta is Map<String, dynamic> ? meta : const {};
    final fusionMap = metaMap['fusion'] is Map<String, dynamic>
        ? metaMap['fusion'] as Map<String, dynamic>
        : const {};
    final upcomingRiskMap = data['upcomingRisk'];
    final policeFromResources = nearbyResources
        .where((item) => item.type == 'police')
        .length;
    final hospitalFromResources = nearbyResources
        .where((item) => item.type == 'hospital')
        .length;
    final supportFromResources = nearbyResources
        .where(
          (item) =>
              item.type == 'police' ||
              item.type == 'hospital' ||
              item.type == 'responder' ||
              item.type == 'fuel_station',
        )
        .length;
    final policeCount = policeFromResources > 0
        ? policeFromResources
        : (metaMap['nearbyPoliceCount'] as num?)?.round() ??
              state.nearbyPoliceCount;
    final hospitalCount = hospitalFromResources > 0
        ? hospitalFromResources
        : (metaMap['nearbyHospitalCount'] as num?)?.round() ??
              state.nearbyHospitalCount;
    final supportCount = supportFromResources > 0
        ? supportFromResources
        : (metaMap['nearbySupportCount'] as num?)?.round() ??
              state.nearbySupportCount;
    final safetyScore =
        (currentMap['safetyScore'] as num?)?.round() ?? state.safetyScore;
    final riskLabel = currentMap['riskLevel']?.toString() ?? state.riskLabel;
    final aiSummaryMap = currentMap['aiSummary'];
    final aiSummaryText = aiSummaryMap is Map<String, dynamic>
        ? aiSummaryMap['summary']?.toString()
        : null;
    final aiSummaryAction = aiSummaryMap is Map<String, dynamic>
        ? aiSummaryMap['actionLine']?.toString()
        : null;
    final aiSummarySource = aiSummaryMap is Map<String, dynamic>
        ? aiSummaryMap['source']?.toString()
        : null;

    final now = DateTime.now();
    final isNight = SafetyVerdictHelper.isNightTime(now);
    final contributingForEvidence =
        (currentMap['contributingFactors'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false);
    final hasStrongRisk = _hasStrongRiskEvidence(
      isNight: isNight,
      contributingFactors: contributingForEvidence,
      riskLabel: riskLabel,
      safetyScore: safetyScore,
    );
    final recommendations =
        (currentMap['recommendations'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList(growable: false);
    final resolvedRecommendations = _sanitizeRecommendations(
      recommendations.isNotEmpty
          ? recommendations
          : _defaultRecommendations(
              safetyScore,
              isNight: isNight,
              hasStrongRisk: hasStrongRisk,
            ),
      isNight: isNight,
      hasStrongRisk: hasStrongRisk,
    );
    final resolvedSummary = _summaryForAssessment(
      safetyScore: safetyScore,
      riskLabel: riskLabel,
      aiSummary: aiSummaryText,
      backendSummary: currentMap['summary']?.toString(),
      isNight: isNight,
      hasStrongRisk: hasStrongRisk,
    );
    final resolvedAction = _sanitizeActionLine(
      (aiSummaryAction?.trim().isNotEmpty ?? false)
          ? aiSummaryAction!.trim()
          : resolvedRecommendations.first,
      isNight: isNight,
      hasStrongRisk: hasStrongRisk,
      safetyScore: safetyScore,
    );

    if (communityAlerts.isEmpty) {
      final parsedDimensions =
          (currentMap['dimensions'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(SafetyDimensionScore.fromJson)
              .toList(growable: false);
      final parsedFactors =
          (currentMap['contributingFactors'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(growable: false);
      communityAlerts = _buildFallbackCommunityAlerts(
        policeCount: policeCount,
        hospitalCount: hospitalCount,
        supportCount: supportCount,
        safetyScore: safetyScore,
        riskLabel: riskLabel,
        contributingFactors: parsedFactors,
        dimensions: parsedDimensions,
      );
    }

    final services = _enrichEmergencyServices(
      emergencyServices ??
          NearbyEmergencyServicesSnapshot(
            policeCount: policeCount,
            hospitalCount: hospitalCount,
            scanned: true,
          ),
      nearbyResources,
    );
    final displayPolice = services.policeCount;
    final displayHospital = services.hospitalCount;
    final displaySupport = services.totalCount;

    _lastAssessmentPosition = position;
    state = state.copyWith(
      isRefreshing: false,
      nearbyPoliceCount: displayPolice,
      nearbyHospitalCount: displayHospital,
      nearbySupportCount: displaySupport,
      emergencyServices1km: services,
      safetyScore: safetyScore,
      riskLabel: riskLabel,
      aiConfidence: currentMap['aiConfidence'] as int?,
      aiConfidenceVisible: currentMap['aiConfidenceVisible'] == true,
      limitedAssessmentMessage: currentMap['limitedAssessmentMessage']
          ?.toString(),
      clearLimitedAssessmentMessage:
          currentMap['limitedAssessmentMessage'] == null,
      contributingFactors:
          (currentMap['contributingFactors'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(growable: false),
      recommendations: resolvedRecommendations,
      communityAlerts: communityAlerts,
      nearbyResources: nearbyResources,
      heatmapTiles: heatmapTiles,
      upcomingRisk: upcomingRiskMap is Map<String, dynamic>
          ? UpcomingRiskAlert.fromJson(upcomingRiskMap)
          : null,
      clearUpcomingRisk: upcomingRiskMap == null,
      summary: resolvedSummary,
      regionLabel: metaMap['region']?.toString(),
      dataDisclaimer: metaMap['dataDisclaimer']?.toString(),
      dimensions: (currentMap['dimensions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SafetyDimensionScore.fromJson)
          .toList(growable: false),
      fusionModelVersion: fusionMap['modelVersion']?.toString(),
      aiSummaryAction: resolvedAction,
      aiSummarySource: aiSummarySource,
      lastUpdatedAt: DateTime.now(),
      areaAssessmentReady: true,
      statusMessage: 'statusLiveIntelligenceActive',
    );
    if (_journeyMode) {
      await _postJourneyUpdate(position);
    }
    unawaited(_sendAnonymousPing(position));
  }

  Future<void> _postJourneyUpdate(Position position) async {
    try {
      final response = await _dio.post(
        ApiConstants.safetyIntelligenceJourneyUpdate,
        data: {
          'lat': position.latitude,
          'lng': position.longitude,
          'heading': position.heading.isFinite ? position.heading : 0,
          'accuracy': position.accuracy,
          'lang': _summaryLang,
          if (_journeyDestinationLat != null && _journeyDestinationLng != null)
            'destinationLat': _journeyDestinationLat,
          if (_journeyDestinationLat != null && _journeyDestinationLng != null)
            'destinationLng': _journeyDestinationLng,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return;
      final alertMap = data['inAppAlert'];
      final summaryMap = data['aiSummary'];
      state = state.copyWith(
        journeyInAppAlert: alertMap is Map<String, dynamic>
            ? SafetyJourneyAlert.fromJson(alertMap)
            : null,
        clearJourneyInAppAlert: alertMap == null,
        rerouteHint: data['rerouteHint']?.toString(),
        clearRerouteHint: data['rerouteHint'] == null,
        summary: summaryMap is Map<String, dynamic>
            ? summaryMap['summary']?.toString() ?? state.summary
            : state.summary,
        aiSummaryAction: summaryMap is Map<String, dynamic>
            ? summaryMap['actionLine']?.toString()
            : state.aiSummaryAction,
        aiSummarySource: summaryMap is Map<String, dynamic>
            ? summaryMap['source']?.toString()
            : state.aiSummarySource,
        upcomingRisk: data['upcomingRisk'] is Map<String, dynamic>
            ? UpcomingRiskAlert.fromJson(
                data['upcomingRisk'] as Map<String, dynamic>,
              )
            : state.upcomingRisk,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return;
    } catch (_) {}
  }

  Future<void> _sendAnonymousPing(Position position) async {
    final now = DateTime.now();
    if (_lastPingAt != null &&
        now.difference(_lastPingAt!) < const Duration(minutes: 3)) {
      return;
    }
    _lastPingAt = now;
    try {
      await _dio.post(
        ApiConstants.safetyIntelligencePings,
        data: {'lat': position.latitude, 'lng': position.longitude},
      );
    } catch (_) {}
  }

  Future<void> _fallbackRefreshNearbyCounts(
    double lat,
    double lng, {
    NearbyEmergencyServicesSnapshot? emergencyServices,
  }) async {
    try {
      await NetworkManager.instance.ensureReachable(force: true);
      final policeRes = await _dio.get(
        ApiConstants.nearbyPolice,
        queryParameters: {'lat': lat, 'lng': lng},
      );
      final hospitalRes = await _dio.get(
        ApiConstants.nearbyHospitals,
        queryParameters: {'lat': lat, 'lng': lng},
      );

      final policeData = policeRes.data;
      final hospitalData = hospitalRes.data;
      final policeCount = policeData is List ? policeData.length : 0;
      final hospitalCount = hospitalData is List ? hospitalData.length : 0;
      final resources = <SafetyResource>[];
      if (policeData is List) {
        for (final item in policeData.whereType<Map<String, dynamic>>()) {
          resources.add(
            SafetyResource(
              id: item['_id']?.toString() ?? '',
              type: 'police',
              name: item['name']?.toString() ?? 'Police Station',
              address: item['address']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              distanceMeters: (item['distanceMeters'] as num?)?.round() ?? 0,
            ),
          );
        }
      }
      if (hospitalData is List) {
        for (final item in hospitalData.whereType<Map<String, dynamic>>()) {
          resources.add(
            SafetyResource(
              id: item['_id']?.toString() ?? '',
              type: 'hospital',
              name: item['name']?.toString() ?? 'Hospital',
              address: item['address']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              distanceMeters: (item['distanceMeters'] as num?)?.round() ?? 0,
            ),
          );
        }
      }
      final services = _enrichEmergencyServices(
        emergencyServices ??
            NearbyEmergencyServicesSnapshot(
              policeCount: policeCount,
              hospitalCount: hospitalCount,
              scanned: true,
            ),
        resources,
      );
      final displayPolice = services.policeCount;
      final displayHospital = services.hospitalCount;
      final displaySupport = services.totalCount;
      final now = DateTime.now();
      final isNight = SafetyVerdictHelper.isNightTime(now);
      final hasCore = displayPolice > 0 || displayHospital > 0;
      var fallbackScore = _calculateFallbackScore(displayPolice, displayHospital);
      if (hasCore && fallbackScore < 75) fallbackScore = 75;
      if (!hasCore && fallbackScore > 54) fallbackScore = 54;
      // Daytime fallback without hard evidence must not land in High Risk.
      if (!isNight && !hasCore && fallbackScore < 55) {
        fallbackScore = 55;
      }
      final risk = hasCore
          ? 'Safe'
          : fallbackScore >= 55
          ? 'Moderate Risk'
          : 'High Risk';
      final fallbackSummary = _summaryForAssessment(
        safetyScore: fallbackScore,
        riskLabel: risk,
        isNight: isNight,
        hasStrongRisk: !hasCore,
      );
      final fallbackRecommendations = _defaultRecommendations(
        fallbackScore,
        isNight: isNight,
        hasStrongRisk: !hasCore,
      );

      state = state.copyWith(
        isRefreshing: false,
        nearbyPoliceCount: displayPolice,
        nearbyHospitalCount: displayHospital,
        nearbySupportCount: displaySupport,
        emergencyServices1km: services,
        nearbyResources: resources,
        safetyScore: fallbackScore,
        riskLabel: risk,
        summary: fallbackSummary,
        recommendations: fallbackRecommendations,
        aiSummaryAction: fallbackRecommendations.first,
        communityAlerts: _buildFallbackCommunityAlerts(
          policeCount: displayPolice,
          hospitalCount: displayHospital,
          supportCount: displaySupport,
          safetyScore: fallbackScore,
          riskLabel: risk,
        ),
        areaAssessmentReady: true,
        statusMessage: displaySupport > 0
            ? 'statusNearbyServicesLoaded'
            : 'statusAreaAssessedLocal',
      );
    } on DioException catch (error) {
      if (BackendUrlResolver.isConnectionError(error)) {
        final recovered = await NetworkManager.instance.recoverConnection();
        if (recovered) {
          await _fallbackRefreshNearbyCounts(
            lat,
            lng,
            emergencyServices: emergencyServices,
          );
          return;
        }
      }
      final now = DateTime.now();
      final isNight = SafetyVerdictHelper.isNightTime(now);
      state = state.copyWith(
        isRefreshing: false,
        areaAssessmentReady: true,
        summary: _summaryForAssessment(
          safetyScore: state.safetyScore,
          riskLabel: state.riskLabel,
          isNight: isNight,
          hasStrongRisk: false,
        ),
        recommendations: state.recommendations.isNotEmpty
            ? _sanitizeRecommendations(
                state.recommendations,
                isNight: isNight,
                hasStrongRisk: false,
              )
            : _defaultRecommendations(
                state.safetyScore,
                isNight: isNight,
                hasStrongRisk: false,
              ),
        aiSummaryAction: _sanitizeActionLine(
          state.aiSummaryAction ??
              _defaultRecommendations(
                state.safetyScore,
                isNight: isNight,
                hasStrongRisk: false,
              ).first,
          isNight: isNight,
          hasStrongRisk: false,
          safetyScore: state.safetyScore,
        ),
        communityAlerts: _buildFallbackCommunityAlerts(
          policeCount: state.nearbyPoliceCount,
          hospitalCount: state.nearbyHospitalCount,
          supportCount: state.nearbySupportCount,
          safetyScore: state.safetyScore,
          riskLabel: state.riskLabel,
        ),
        statusMessage: 'statusCannotReachServer',
      );
    }
  }

  List<SafetyCommunityAlert> _buildFallbackCommunityAlerts({
    required int policeCount,
    required int hospitalCount,
    required int supportCount,
    required int safetyScore,
    required String riskLabel,
    List<String> contributingFactors = const [],
    List<SafetyDimensionScore> dimensions = const [],
  }) {
    final now = DateTime.now();
    final isNight = SafetyVerdictHelper.isNightTime(now);
    final isLateNight = SafetyVerdictHelper.isLateNight(now);
    final showRoadLighting = isNight;
    final verdictSummary = safetyScore >= 75
        ? 'safetyVerdictSafeSummary'
        : safetyScore >= 55
        ? 'safetyVerdictCautionSummary'
        : 'safetyVerdictHighRiskSummary';
    final verdictHeadline = safetyScore >= 75
        ? 'safetyVerdictSafe'
        : safetyScore >= 55
        ? 'safetyVerdictCaution'
        : 'safetyVerdictHighRisk';
    final riskReasons = _buildFallbackRiskReasons(
      safetyScore: safetyScore,
      isNight: isNight,
      isLateNight: isLateNight,
      policeCount: policeCount,
      hospitalCount: hospitalCount,
      supportCount: supportCount,
      contributingFactors: contributingFactors,
      dimensions: dimensions,
    );
    final hasSpecificRiskSignals = riskReasons.isNotEmpty;

    return [
      SafetyCommunityAlert(
        category: 'alertCategoryAreaSafety',
        priority: hasSpecificRiskSignals
            ? safetyScore < 45
                  ? 'critical'
                  : safetyScore < 60
                  ? 'caution'
                  : 'information'
            : 'information',
        distanceMeters: 0,
        timestamp: now,
        summary: hasSpecificRiskSignals
            ? verdictSummary
            : 'alertSummaryAreaSafeVerified',
        recommendedAction: hasSpecificRiskSignals
            ? safetyScore < 60
                  ? 'alertActionAreaStayAlert'
                  : 'alertActionAreaManageable'
            : 'alertActionAreaSafe',
        dataSource: 'suraksha_engine',
        verdictHeadline: hasSpecificRiskSignals
            ? verdictHeadline
            : 'riskLabelSafe',
        riskReasons: riskReasons,
      ),
      SafetyCommunityAlert(
        category: 'alertCategoryPublicTransportNetwork',
        priority: 'information',
        distanceMeters: 400,
        timestamp: now,
        summary: 'alertSummaryPublicTransportNetwork',
        recommendedAction: 'alertActionPublicTransportNetwork',
      ),
      if (showRoadLighting)
        SafetyCommunityAlert(
          category: 'alertCategoryRoadLighting',
          priority: isLateNight ? 'critical' : 'caution',
          distanceMeters: 300,
          timestamp: now,
          summary: isLateNight
              ? 'alertSummaryLightingLateNight'
              : 'alertSummaryLightingEvening',
          recommendedAction: 'alertActionRoadLighting',
        ),
      SafetyCommunityAlert(
        category: 'alertCategoryPedestrianActivity',
        priority: isLateNight ? 'caution' : 'information',
        distanceMeters: 250,
        timestamp: now,
        summary: isLateNight
            ? 'alertSummaryPedestrianLateNight'
            : isNight
            ? 'alertSummaryPedestrianNight'
            : 'alertSummaryPedestrianDay',
        recommendedAction: isNight
            ? 'alertActionPedestrianNight'
            : 'alertActionPedestrianDay',
      ),
    ];
  }

  int _calculateFallbackScore(int policeCount, int hospitalCount) {
    var score = 40 + (policeCount * 8) + (hospitalCount * 6);
    if (state.position != null && state.position!.accuracy <= 20) {
      score += 8;
    }
    if (state.trackingActive) {
      score += 6;
    }
    if (score > 98) score = 98;
    return score;
  }

  List<String> _buildFallbackRiskReasons({
    required int safetyScore,
    required bool isNight,
    required bool isLateNight,
    required int policeCount,
    required int hospitalCount,
    required int supportCount,
    required List<String> contributingFactors,
    required List<SafetyDimensionScore> dimensions,
  }) {
    if (safetyScore >= 75) return const [];

    final reasons = <String>[];
    void add(String reason) {
      if (reason.isNotEmpty && !reasons.contains(reason)) {
        reasons.add(reason);
      }
    }

    for (final factor in contributingFactors) {
      add(factor);
    }
    for (final dimension in dimensions) {
      if (dimension.score >= 55) continue;
      add(switch (dimension.key) {
        'crime' => 'alertReasonCrimeSignalsElevated',
        'infrastructure' => 'safetyReasonPoorLighting',
        'support' => 'safetyReasonLimitedSupport',
        'visibility' => 'safetyReasonLowFootfall',
        'temporal' => 'safetyReasonNightRisk',
        _ => 'safetyReasonLowRiskSignals',
      });
    }
    if (isLateNight && safetyScore < 60) {
      add('alertSummaryPedestrianLateNight');
    }
    if (showRoadLightingFallback(isNight) && safetyScore < 60) {
      add('safetyReasonPoorLighting');
    }
    if (supportCount == 0 && policeCount == 0 && hospitalCount == 0) {
      add('safetyReasonLimitedSupport');
    }
    if (reasons.isEmpty && safetyScore < 55) {
      add('safetyReasonCrimeActivity');
    }
    return reasons.take(6).toList(growable: false);
  }

  bool showRoadLightingFallback(bool isNight) => isNight;

  bool _hasStrongRiskEvidence({
    required bool isNight,
    required List<String> contributingFactors,
    required String riskLabel,
    required int safetyScore,
  }) {
    for (final factor in contributingFactors) {
      final text = factor.toLowerCase();
      if (text.contains('incident') ||
          text.contains('violent') ||
          text.contains('crime') ||
          text.contains('assault') ||
          text.contains('snatch') ||
          text.contains('theft') ||
          text.contains('robbery') ||
          text.contains('harass') ||
          text.contains('drug') ||
          text.contains('grid model') ||
          text.contains('elevated risk')) {
        return true;
      }
    }
    final label = riskLabel.toLowerCase();
    if ((label.contains('high risk') || label.contains('critical')) &&
        safetyScore < 45 &&
        contributingFactors.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool _isIsolationAdvice(String text) {
    final lower = text.toLowerCase();
    return lower.contains('avoid isolated') ||
        lower.contains('isolated routes') ||
        lower.contains('isolated shortcuts') ||
        lower.contains('may not feel safe') ||
        (lower.contains('share') && lower.contains('live location'));
  }

  List<String> _sanitizeRecommendations(
    List<String> recommendations, {
    required bool isNight,
    required bool hasStrongRisk,
  }) {
    if (isNight || hasStrongRisk) {
      return recommendations.isNotEmpty
          ? recommendations
          : _defaultRecommendations(
              60,
              isNight: isNight,
              hasStrongRisk: hasStrongRisk,
            );
    }
    final filtered = recommendations
        .where((item) => !_isIsolationAdvice(item))
        .toList(growable: false);
    if (filtered.isNotEmpty) return filtered;
    return _defaultRecommendations(
      60,
      isNight: false,
      hasStrongRisk: false,
    );
  }

  String _sanitizeActionLine(
    String action, {
    required bool isNight,
    required bool hasStrongRisk,
    required int safetyScore,
  }) {
    if (isNight || hasStrongRisk || !_isIsolationAdvice(action)) {
      return action;
    }
    return _defaultRecommendations(
      safetyScore,
      isNight: false,
      hasStrongRisk: false,
    ).first;
  }

  String _summaryForAssessment({
    required int safetyScore,
    required String riskLabel,
    String? aiSummary,
    String? backendSummary,
    bool isNight = false,
    bool hasStrongRisk = false,
  }) {
    final allowHighConcern = isNight || hasStrongRisk;

    String? pick(String? text) {
      final value = text?.trim();
      if (value == null || value.isEmpty) return null;
      final lower = value.toLowerCase();
      if (lower.contains('still learning') || lower.contains('still building')) {
        return null;
      }
      if (!allowHighConcern &&
          (lower.contains('may not feel safe') ||
              lower.contains('isolated') ||
              lower.contains('elevated caution') ||
              lower.contains('especially for women'))) {
        return null;
      }
      return value;
    }

    final aiText = pick(aiSummary);
    if (aiText != null) return aiText;

    final backendText = pick(backendSummary);
    if (backendText != null) return backendText;

    final label = riskLabel.toLowerCase();
    if (label.contains('safe') && !label.contains('unsafe')) {
      return 'This area feels generally safe right now based on your live location.';
    }
    if (label.contains('moderate') || label.contains('caution')) {
      return 'Use extra caution here—some risk signals were detected nearby.';
    }
    if (allowHighConcern &&
        (label.contains('high') || label.contains('critical'))) {
      return 'This area may not feel safe right now, especially for women and elderly users.';
    }

    if (safetyScore >= 75) {
      return 'This area feels generally safe right now based on your live location.';
    }
    if (safetyScore >= 55 || !allowHighConcern) {
      return 'Use extra caution here—some risk signals were detected nearby.';
    }
    return 'This area may not feel safe right now, especially for women and elderly users.';
  }

  List<String> _defaultRecommendations(
    int safetyScore, {
    bool isNight = false,
    bool hasStrongRisk = false,
  }) {
    if (safetyScore >= 75) {
      return const [
        'Stay aware and keep trusted contacts reachable.',
      ];
    }
    if (safetyScore >= 55 || (!isNight && !hasStrongRisk)) {
      return const [
        'Stay aware and keep trusted contacts informed.',
      ];
    }
    return const [
      'Avoid isolated routes and share live location with someone you trust.',
    ];
  }
}
