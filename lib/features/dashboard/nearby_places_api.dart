import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/tls_pinning.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_models.dart';

/// Public nearby lookups that must never share the auth QueuedInterceptor.
/// Demo sessions + safety-intelligence 401s otherwise stall or kill these calls.
class NearbyPlacesApi {
  NearbyPlacesApi._();

  static Dio? _dio;

  static Dio get _client {
    final existing = _dio;
    if (existing != null) return existing;
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.preferredBaseUrl,
        connectTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: const {'Accept': 'application/json'},
      ),
    );
    TlsPinning.attachToDio(dio);
    _dio = dio;
    return dio;
  }

  static Future<List<NearbyPlaceItem>> fetchPlaces({
    required double latitude,
    required double longitude,
    required NearbyPlaceType type,
    int radiusMeters = 5000,
    String languageCode = 'en',
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.nearbyPlaces,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'category': type.apiCategory,
          'radius': radiusMeters,
          'lang': languageCode,
        },
      );
      final parsed = _parseBackendPlaces(response.data);
      if (parsed.isNotEmpty) return parsed;
    } catch (_) {
      // Fall through to OpenStreetMap.
    }

    return fetchFromOpenStreetMap(
      latitude: latitude,
      longitude: longitude,
      type: type,
      radiusMeters: radiusMeters,
    );
  }

  static Future<Map<String, int>> fetchEmergencyCounts({
    required double latitude,
    required double longitude,
    int radiusMeters = 1000,
    String languageCode = 'en',
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.nearbyEmergencyServices,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusMeters,
          'lang': languageCode,
        },
      );
      final data = response.data;
      if (data is Map) {
        int read(String key) {
          final value = data[key];
          if (value is num) return value.round();
          return int.tryParse(value?.toString() ?? '') ?? 0;
        }

        final snapshot = {
          'police': read('policeCount'),
          'hospitals': read('hospitalCount'),
          'pharmacies': read('pharmacyCount'),
          'petrolPumps': read('petrolPumpCount'),
          'washrooms': read('washroomCount'),
          'bloodBanks': read('bloodBankCount'),
        };
        if (snapshot.values.any((count) => count > 0)) {
          return snapshot;
        }
      }
    } catch (_) {
      // Fall through to OpenStreetMap counts.
    }

    return countFromOpenStreetMap(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }

  static List<NearbyPlaceItem> _parseBackendPlaces(dynamic data) {
    final list = data is Map && data['places'] is List
        ? data['places'] as List
        : data is List
            ? data
            : const [];
    return list
        .whereType<Map>()
        .map((raw) => NearbyPlaceItem.fromJson(Map<String, dynamic>.from(raw)))
        .where((place) => place.latitude != 0 || place.longitude != 0)
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  static Future<List<NearbyPlaceItem>> fetchFromOpenStreetMap({
    required double latitude,
    required double longitude,
    required NearbyPlaceType type,
    int radiusMeters = 5000,
  }) async {
    final filters = _osmFiltersFor(type);
    if (filters.isEmpty) return const [];

    final around = math.min(math.max(radiusMeters, 500), 10000);
    final filterLines = filters
        .map(
          (f) =>
              'node$f(around:$around,$latitude,$longitude);'
              'way$f(around:$around,$latitude,$longitude);',
        )
        .join('\n');
    final query = '[out:json][timeout:25];\n($filterLines\n);\nout center tags 30;';

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );

    try {
      final response = await dio.post(
        'https://overpass-api.de/api/interpreter',
        data: {'data': query},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final elements = response.data is Map && response.data['elements'] is List
          ? response.data['elements'] as List
          : const [];

      final places = <NearbyPlaceItem>[];
      for (final raw in elements) {
        if (raw is! Map) continue;
        final tags = raw['tags'] is Map
            ? Map<String, dynamic>.from(raw['tags'] as Map)
            : const <String, dynamic>{};
        final lat = (raw['lat'] as num?)?.toDouble() ??
            (raw['center'] is Map
                ? (raw['center']['lat'] as num?)?.toDouble()
                : null);
        final lng = (raw['lon'] as num?)?.toDouble() ??
            (raw['center'] is Map
                ? (raw['center']['lon'] as num?)?.toDouble()
                : null);
        if (lat == null || lng == null) continue;

        final name = (tags['name'] ?? tags['name:en'] ?? _defaultName(type))
            .toString();
        final address = [
          tags['addr:street'],
          tags['addr:suburb'],
          tags['addr:city'],
        ]
            .where((part) => part != null && part.toString().trim().isNotEmpty)
            .join(', ');

        places.add(
          NearbyPlaceItem(
            id: '${raw['type']}/${raw['id']}',
            name: name,
            address: address,
            latitude: lat,
            longitude: lng,
            distanceMeters: _haversineMeters(latitude, longitude, lat, lng),
          ),
        );
      }

      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return places;
    } catch (_) {
      return const [];
    } finally {
      dio.close(force: true);
    }
  }

  static Future<Map<String, int>> countFromOpenStreetMap({
    required double latitude,
    required double longitude,
    int radiusMeters = 1000,
  }) async {
    final around = math.min(math.max(radiusMeters, 200), 5000);
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="police"](around:$around,$latitude,$longitude);
  way["amenity"="police"](around:$around,$latitude,$longitude);
  node["amenity"="hospital"](around:$around,$latitude,$longitude);
  way["amenity"="hospital"](around:$around,$latitude,$longitude);
  node["amenity"="clinic"](around:$around,$latitude,$longitude);
  node["amenity"="pharmacy"](around:$around,$latitude,$longitude);
  way["amenity"="pharmacy"](around:$around,$latitude,$longitude);
  node["amenity"="fuel"](around:$around,$latitude,$longitude);
  way["amenity"="fuel"](around:$around,$latitude,$longitude);
  node["amenity"="toilets"](around:$around,$latitude,$longitude);
  way["amenity"="toilets"](around:$around,$latitude,$longitude);
  node["healthcare"="blood_donation"](around:$around,$latitude,$longitude);
  node["amenity"="blood_bank"](around:$around,$latitude,$longitude);
);
out center tags 80;
''';

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );

    final counts = {
      'police': 0,
      'hospitals': 0,
      'pharmacies': 0,
      'petrolPumps': 0,
      'washrooms': 0,
      'bloodBanks': 0,
    };

    try {
      final response = await dio.post(
        'https://overpass-api.de/api/interpreter',
        data: {'data': query},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final elements = response.data is Map && response.data['elements'] is List
          ? response.data['elements'] as List
          : const [];

      final seen = <String, Set<String>>{
        'police': {},
        'hospitals': {},
        'pharmacies': {},
        'petrolPumps': {},
        'washrooms': {},
        'bloodBanks': {},
      };

      for (final raw in elements) {
        if (raw is! Map) continue;
        final tags = raw['tags'] is Map
            ? Map<String, dynamic>.from(raw['tags'] as Map)
            : const <String, dynamic>{};
        final amenity = tags['amenity']?.toString();
        final healthcare = tags['healthcare']?.toString();
        String? bucket;
        if (amenity == 'police') {
          bucket = 'police';
        } else if (amenity == 'hospital' || amenity == 'clinic') {
          bucket = 'hospitals';
        } else if (amenity == 'pharmacy') {
          bucket = 'pharmacies';
        } else if (amenity == 'fuel') {
          bucket = 'petrolPumps';
        } else if (amenity == 'toilets') {
          bucket = 'washrooms';
        } else if (amenity == 'blood_bank' || healthcare == 'blood_donation') {
          bucket = 'bloodBanks';
        }
        if (bucket == null) continue;
        final id = '${raw['type']}/${raw['id']}';
        seen[bucket]!.add(id);
      }

      for (final entry in seen.entries) {
        counts[entry.key] = entry.value.length;
      }
    } catch (_) {
      // Keep zeros on Overpass failure.
    } finally {
      dio.close(force: true);
    }

    return counts;
  }

  static List<String> _osmFiltersFor(NearbyPlaceType type) {
    return switch (type) {
      NearbyPlaceType.hospitals => [
          '["amenity"="hospital"]',
          '["amenity"="clinic"]',
        ],
      NearbyPlaceType.policeStations => ['["amenity"="police"]'],
      NearbyPlaceType.pharmacies => ['["amenity"="pharmacy"]'],
      NearbyPlaceType.petrolPumps => ['["amenity"="fuel"]'],
      NearbyPlaceType.washrooms => ['["amenity"="toilets"]'],
      NearbyPlaceType.bloodBanks => [
          '["healthcare"="blood_donation"]',
          '["amenity"="blood_bank"]',
        ],
    };
  }

  static String _defaultName(NearbyPlaceType type) {
    return switch (type) {
      NearbyPlaceType.hospitals => 'Hospital',
      NearbyPlaceType.policeStations => 'Police station',
      NearbyPlaceType.pharmacies => 'Pharmacy',
      NearbyPlaceType.petrolPumps => 'Petrol pump',
      NearbyPlaceType.washrooms => 'Washroom',
      NearbyPlaceType.bloodBanks => 'Blood bank',
    };
  }

  static double _haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earth = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earth * 2 * math.asin(math.sqrt(a));
  }

  static double _toRad(double degrees) => degrees * math.pi / 180;
}
