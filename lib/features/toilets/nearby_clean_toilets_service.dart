import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';

class NearbyCleanToiletFacilities {
  const NearbyCleanToiletFacilities({
    required this.male,
    required this.female,
    required this.accessible,
    required this.waterAvailable,
  });

  final bool male;
  final bool female;
  final bool accessible;
  final bool waterAvailable;

  factory NearbyCleanToiletFacilities.fromJson(Map<String, dynamic> json) {
    bool readBool(String key) => json[key] == true;
    return NearbyCleanToiletFacilities(
      male: readBool('male'),
      female: readBool('female'),
      accessible: readBool('accessible'),
      waterAvailable: readBool('waterAvailable'),
    );
  }
}

class NearbyCleanToilet {
  const NearbyCleanToilet({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceMeters,
    required this.distanceLabel,
    required this.latitude,
    required this.longitude,
    required this.cleanlinessScore,
    required this.cleanlinessStatus,
    required this.availabilityStatus,
    required this.lastUpdatedAt,
    required this.facilities,
    required this.safetyDisplayStatus,
  });

  final String id;
  final String name;
  final String address;
  final int distanceMeters;
  final String distanceLabel;
  final double latitude;
  final double longitude;
  final int? cleanlinessScore;
  final String cleanlinessStatus;
  final String availabilityStatus;
  final DateTime? lastUpdatedAt;
  final NearbyCleanToiletFacilities facilities;
  final String safetyDisplayStatus;

  factory NearbyCleanToilet.fromJson(Map<String, dynamic> json) {
    final distanceMeters = _toInt(json['distanceMeters']) ?? 0;
    final score = _toInt(json['cleanlinessScore']);
    return NearbyCleanToilet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Public Toilet',
      address: json['address']?.toString() ?? '',
      distanceMeters: distanceMeters,
      distanceLabel:
          json['distanceLabel']?.toString() ??
          (distanceMeters >= 1000
              ? '${(distanceMeters / 1000).toStringAsFixed(1)} km away'
              : '$distanceMeters m away'),
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      cleanlinessScore: score,
      cleanlinessStatus:
          json['cleanlinessStatus']?.toString() ?? 'Status Unknown',
      availabilityStatus:
          json['availabilityStatus']?.toString() ?? 'Status Unknown',
      lastUpdatedAt: DateTime.tryParse(json['lastUpdatedAt']?.toString() ?? ''),
      facilities: NearbyCleanToiletFacilities.fromJson(
        Map<String, dynamic>.from(json['facilities'] as Map? ?? const {}),
      ),
      safetyDisplayStatus:
          json['safetyDisplayStatus']?.toString() ??
          _fallbackSafetyDisplayStatus(
            cleanlinessStatus:
                json['cleanlinessStatus']?.toString() ?? 'Status Unknown',
            availabilityStatus:
                json['availabilityStatus']?.toString() ?? 'Status Unknown',
            cleanlinessScore: score,
          ),
    );
  }

  bool get isRecommended =>
      safetyDisplayStatus == 'Recommended' &&
      availabilityStatus.toLowerCase() == 'open';

  bool get isOpen {
    final status = availabilityStatus.trim().toLowerCase();
    // Upstream already excludes closed when include_closed=false; treat unknown as open.
    if (status.isEmpty || status == 'status unknown') return true;
    return status == 'open' || status == 'operational' || status == 'available';
  }

  bool get isKnownClosed {
    final status = availabilityStatus.trim().toLowerCase();
    return status == 'closed' ||
        status == 'under maintenance' ||
        status == 'shut';
  }

  bool get isUsable =>
      safetyDisplayStatus == 'Usable' &&
      availabilityStatus.toLowerCase() == 'open';

  bool get needsCaution => safetyDisplayStatus == 'Use with caution';
}

class NearbyCleanToiletFilters {
  const NearbyCleanToiletFilters({
    this.radiusMeters = 3000,
    this.limit = 50,
    this.cleanlinessMin = 0,
    this.includeClosed = false,
    this.cleanOnly = false,
    this.openNowOnly = false,
    this.femaleFacilityOnly = false,
    this.accessibleOnly = false,
    this.waterAvailableOnly = false,
  });

  final int radiusMeters;
  final int limit;
  final int cleanlinessMin;
  final bool includeClosed;
  final bool cleanOnly;
  final bool openNowOnly;
  final bool femaleFacilityOnly;
  final bool accessibleOnly;
  final bool waterAvailableOnly;

  NearbyCleanToiletFilters copyWith({
    int? radiusMeters,
    int? limit,
    int? cleanlinessMin,
    bool? includeClosed,
    bool? cleanOnly,
    bool? openNowOnly,
    bool? femaleFacilityOnly,
    bool? accessibleOnly,
    bool? waterAvailableOnly,
  }) {
    return NearbyCleanToiletFilters(
      radiusMeters: radiusMeters ?? this.radiusMeters,
      limit: limit ?? this.limit,
      cleanlinessMin: cleanlinessMin ?? this.cleanlinessMin,
      includeClosed: includeClosed ?? this.includeClosed,
      cleanOnly: cleanOnly ?? this.cleanOnly,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      femaleFacilityOnly: femaleFacilityOnly ?? this.femaleFacilityOnly,
      accessibleOnly: accessibleOnly ?? this.accessibleOnly,
      waterAvailableOnly: waterAvailableOnly ?? this.waterAvailableOnly,
    );
  }

  Map<String, dynamic> toQueryParameters({
    required double latitude,
    required double longitude,
  }) {
    final includeClosedForQuery = openNowOnly ? false : includeClosed;
    return {
      'lat': latitude,
      'lng': longitude,
      'radius': radiusMeters,
      'limit': limit,
      'cleanliness_min': cleanOnly ? 85 : cleanlinessMin,
      'include_closed': includeClosedForQuery,
    };
  }
}

class NearbyCleanToiletException implements Exception {
  NearbyCleanToiletException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NearbyCleanToiletsFetchResult {
  const NearbyCleanToiletsFetchResult({
    required this.toilets,
    this.upstreamRawCount = 0,
    this.droppedInvalidCoordinates = 0,
    this.includeClosedDowngraded = false,
  });

  final List<NearbyCleanToilet> toilets;
  final int upstreamRawCount;
  final int droppedInvalidCoordinates;
  final bool includeClosedDowngraded;

  bool get upstreamReturnedRows => upstreamRawCount > 0;
  bool get allRowsDroppedForInvalidCoordinates =>
      upstreamRawCount > 0 && toilets.isEmpty && droppedInvalidCoordinates > 0;
}

class NearbyCleanToiletsService {
  NearbyCleanToiletsService({Dio? dio})
    : _dio = dio ?? NetworkManager.instance.dio;

  final Dio _dio;

  Future<List<NearbyCleanToilet>> fetchNearbyToilets({
    required double latitude,
    required double longitude,
    required NearbyCleanToiletFilters filters,
  }) async {
    final result = await fetchNearbyToiletsDetailed(
      latitude: latitude,
      longitude: longitude,
      filters: filters,
    );
    return result.toilets;
  }

  Future<NearbyCleanToiletsFetchResult> fetchNearbyToiletsDetailed({
    required double latitude,
    required double longitude,
    required NearbyCleanToiletFilters filters,
  }) async {
    try {
      await NetworkManager.instance.ensureReachable();
      return await _performFetchDetailed(
        latitude: latitude,
        longitude: longitude,
        filters: filters,
      );
    } on DioException catch (error) {
      if (BackendUrlResolver.isConnectionError(error)) {
        final recovered = await NetworkManager.instance.recoverConnection();
        if (recovered) {
          return _performFetchDetailed(
            latitude: latitude,
            longitude: longitude,
            filters: filters,
          );
        }
      }
      throw _mapDioError(error);
    } catch (error) {
      if (error is NearbyCleanToiletException) rethrow;
      throw NearbyCleanToiletException(
        'Could not reach toilet service right now. Please try again.',
      );
    }
  }

  Future<NearbyCleanToiletsFetchResult> _performFetchDetailed({
    required double latitude,
    required double longitude,
    required NearbyCleanToiletFilters filters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.nearbyToilets,
        queryParameters: filters.toQueryParameters(
          latitude: latitude,
          longitude: longitude,
        ),
      );

      final payload = response.data;
      final rawToilets = _extractToilets(payload);
      final meta = _extractMeta(payload);
      final toilets = rawToilets
          .whereType<Map<String, dynamic>>()
          .map(NearbyCleanToilet.fromJson)
          .where(hasValidCoordinates)
          .where((toilet) => matchesClientFilters(toilet, filters))
          .toList(growable: false);
      return NearbyCleanToiletsFetchResult(
        toilets: sortToilets(toilets),
        upstreamRawCount: _toInt(meta['upstreamRawCount']) ?? rawToilets.length,
        droppedInvalidCoordinates:
            _toInt(meta['droppedInvalidCoordinates']) ?? 0,
        includeClosedDowngraded: meta['includeClosedDowngraded'] == true,
      );
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      if (error is NearbyCleanToiletException) rethrow;
      throw NearbyCleanToiletException(
        'Could not reach toilet service right now. Please try again.',
      );
    }
  }

  static bool hasValidCoordinates(NearbyCleanToilet toilet) {
    if (toilet.latitude == 0 && toilet.longitude == 0) return false;
    if (toilet.latitude.abs() > 90 || toilet.longitude.abs() > 180) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> _extractMeta(Map<String, dynamic>? payload) {
    if (payload == null) return const {};
    final meta = payload['meta'];
    if (meta is! Map) return const {};
    return Map<String, dynamic>.from(meta);
  }

  static List<Map<String, dynamic>> _extractToilets(
    Map<String, dynamic>? payload,
  ) {
    if (payload == null) return const [];
    final toilets = payload['toilets'];
    if (toilets is! List) return const [];
    return toilets
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  static List<NearbyCleanToilet> sortToilets(List<NearbyCleanToilet> toilets) {
    final sorted = [...toilets];
    sorted.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return sorted;
  }

  static bool matchesClientFilters(
    NearbyCleanToilet toilet,
    NearbyCleanToiletFilters filters,
  ) {
    // Only hide toilets that are explicitly closed/maintenance.
    if (filters.openNowOnly && toilet.isKnownClosed) return false;
    if (filters.femaleFacilityOnly && !toilet.facilities.female) return false;
    if (filters.accessibleOnly && !toilet.facilities.accessible) return false;
    if (filters.waterAvailableOnly && !toilet.facilities.waterAvailable) {
      return false;
    }
    if (filters.cleanOnly &&
        !(toilet.cleanlinessStatus == 'Clean' &&
            toilet.availabilityStatus.toLowerCase() == 'open')) {
      return false;
    }
    return true;
  }

  static double markerHueForToilet(NearbyCleanToilet toilet) {
    if (toilet.isRecommended) return 120;
    if (toilet.isUsable) return 210;
    if (toilet.needsCaution) return 30;
    if (toilet.availabilityStatus == 'Not recommended' ||
        toilet.availabilityStatus.toLowerCase() == 'closed' ||
        toilet.availabilityStatus.toLowerCase() == 'under maintenance') {
      return 0;
    }
    return 275;
  }

  NearbyCleanToiletException _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return NearbyCleanToiletException(
        'Toilet service is currently unavailable.',
        statusCode: status,
      );
    }
    if (status == 429) {
      return NearbyCleanToiletException(
        'Toilet service is busy. Please try again shortly.',
        statusCode: status,
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.error is SocketException) {
      return NearbyCleanToiletException(
        'Could not reach toilet service right now. Please try again.',
        statusCode: status,
      );
    }

    return NearbyCleanToiletException(
      'Toilet service is currently unavailable.',
      statusCode: status,
    );
  }

  static Uri buildNavigationUri(NearbyCleanToilet toilet) {
    final destination = '${toilet.latitude},${toilet.longitude}';
    if (Platform.isIOS) {
      return Uri.parse('http://maps.apple.com/?daddr=$destination');
    }
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
    });
  }

  static Uri buildIssueReportUri(NearbyCleanToilet toilet) {
    final subject = Uri.encodeComponent('Public toilet issue: ${toilet.name}');
    final bodyLines = <String>[
      'Please review the following public toilet entry:',
      '',
      'Name: ${toilet.name}',
      'Address: ${toilet.address.isNotEmpty ? toilet.address : 'Address not available'}',
      'Coordinates: ${toilet.latitude}, ${toilet.longitude}',
      'Distance: ${toilet.distanceLabel}',
      'Cleanliness: ${toilet.cleanlinessStatus}',
      'Availability: ${toilet.availabilityStatus}',
      'Last updated: ${toilet.lastUpdatedAt?.toIso8601String() ?? 'Not available'}',
    ];
    final body = Uri.encodeComponent(bodyLines.join('\n'));
    return Uri.parse('mailto:support@suraksha.app?subject=$subject&body=$body');
  }

  static Set<Marker> buildMarkers(
    Iterable<NearbyCleanToilet> toilets, {
    required void Function(NearbyCleanToilet toilet) onTap,
  }) {
    return toilets.where(hasValidCoordinates).map((toilet) {
      return Marker(
        markerId: MarkerId(toilet.id),
        position: LatLng(toilet.latitude, toilet.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHueForToilet(toilet)),
        infoWindow: InfoWindow(
          title: toilet.name,
          snippet: toilet.distanceLabel,
        ),
        onTap: () => onTap(toilet),
      );
    }).toSet();
  }
}

int? _toInt(dynamic value) {
  final number = num.tryParse(value?.toString() ?? '');
  return number?.round();
}

double? _toDouble(dynamic value) {
  return double.tryParse(value?.toString() ?? '');
}

String _fallbackSafetyDisplayStatus({
  required String cleanlinessStatus,
  required String availabilityStatus,
  required int? cleanlinessScore,
}) {
  final availability = availabilityStatus.toLowerCase();
  if (availability == 'under maintenance' || availability == 'closed') {
    return 'Not recommended';
  }
  if (cleanlinessStatus == 'Status Unknown' || cleanlinessScore == null) {
    return 'Status not verified';
  }
  if (cleanlinessStatus == 'Clean' && availability == 'open') {
    return 'Recommended';
  }
  if (cleanlinessStatus == 'Usable' && availability == 'open') {
    return 'Usable';
  }
  if (cleanlinessStatus == 'Needs Cleaning') {
    return 'Use with caution';
  }
  return 'Status not verified';
}
