import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/config/app_environment.dart';

/// Nearby emergency / support services within a fixed radius (default 1 km).
/// Uses the same Google Places Nearby Search approach as dashboard Nearby Services.
class NearbyEmergencyServicesSnapshot {
  const NearbyEmergencyServicesSnapshot({
    this.policeCount = 0,
    this.hospitalCount = 0,
    this.pharmacyCount = 0,
    this.petrolPumpCount = 0,
    this.washroomCount = 0,
    this.bloodBankCount = 0,
    this.radiusMeters = 1000,
    this.scanned = false,
  });

  final int policeCount;
  final int hospitalCount;
  final int pharmacyCount;
  final int petrolPumpCount;
  final int washroomCount;
  final int bloodBankCount;
  final int radiusMeters;
  final bool scanned;

  /// Core rule: at least one hospital or one police station within radius.
  bool get hasCoreEmergencySupport => policeCount > 0 || hospitalCount > 0;

  int get totalCount =>
      policeCount +
      hospitalCount +
      pharmacyCount +
      petrolPumpCount +
      washroomCount +
      bloodBankCount;

  List<({String key, int count})> get nonZeroBreakdown => [
    if (policeCount > 0) (key: 'police', count: policeCount),
    if (hospitalCount > 0) (key: 'hospitals', count: hospitalCount),
    if (pharmacyCount > 0) (key: 'pharmacies', count: pharmacyCount),
    if (petrolPumpCount > 0) (key: 'petrolPumps', count: petrolPumpCount),
    if (washroomCount > 0) (key: 'washrooms', count: washroomCount),
    if (bloodBankCount > 0) (key: 'bloodBanks', count: bloodBankCount),
  ];
}

class EmergencyServicesScanService {
  EmergencyServicesScanService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  static const int defaultRadiusMeters = 1000;

  Future<NearbyEmergencyServicesSnapshot> scanWithinRadius({
    required double latitude,
    required double longitude,
    int radiusMeters = defaultRadiusMeters,
    String languageCode = 'en',
  }) async {
    final apiKey = AppEnvironment.googleMapsApiKey.trim();
    if (apiKey.isEmpty) {
      // Mark scanned so the UI still shows the 1 km section (counts stay 0).
      return NearbyEmergencyServicesSnapshot(
        radiusMeters: radiusMeters,
        scanned: true,
      );
    }

    final base = <String, Object>{
      'location': '$latitude,$longitude',
      'radius': radiusMeters,
      'key': apiKey,
      'language': languageCode,
    };

    final queries = <({String category, Map<String, Object> params})>[
      (category: 'police', params: {...base, 'type': 'police'}),
      (category: 'hospital', params: {...base, 'type': 'hospital'}),
      (category: 'pharmacy', params: {...base, 'type': 'pharmacy'}),
      (category: 'petrol', params: {...base, 'type': 'gas_station'}),
      (category: 'pharmacy', params: {...base, 'keyword': 'medical store'}),
      (category: 'pharmacy', params: {...base, 'keyword': 'chemist'}),
      (category: 'blood', params: {...base, 'keyword': 'blood bank'}),
      (category: 'washroom', params: {...base, 'type': 'restroom'}),
      (category: 'washroom', params: {...base, 'keyword': 'public toilet'}),
      (category: 'washroom', params: {...base, 'keyword': 'washroom'}),
    ];

    final idsByCategory = <String, Set<String>>{
      'police': {},
      'hospital': {},
      'pharmacy': {},
      'petrol': {},
      'blood': {},
      'washroom': {},
    };

    final responses = await Future.wait(
      queries.map((query) async {
        try {
          final response = await _dio.get<Map<String, dynamic>>(
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
            queryParameters: query.params,
            options: Options(
              sendTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );
          return (category: query.category, data: response.data);
        } catch (_) {
          return (category: query.category, data: null);
        }
      }),
    );

    for (final response in responses) {
      final data = response.data;
      if (data is! Map<String, dynamic>) continue;
      final status = data['status']?.toString() ?? '';
      if (status != 'OK' && status != 'ZERO_RESULTS') continue;
      final results = data['results'];
      if (results is! List) continue;

      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;
        final geometry = item['geometry'];
        final location = geometry is Map<String, dynamic>
            ? geometry['location']
            : null;
        final lat = location is Map<String, dynamic>
            ? (location['lat'] as num?)?.toDouble()
            : null;
        final lng = location is Map<String, dynamic>
            ? (location['lng'] as num?)?.toDouble()
            : null;
        if (lat == null || lng == null) continue;

        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          lat,
          lng,
        );
        if (distance > radiusMeters) continue;

        if (response.category == 'washroom' && !_isLikelyWashroomPlace(item)) {
          continue;
        }

        final placeId =
            item['place_id']?.toString() ??
            '${item['name']}_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}';
        idsByCategory[response.category]?.add(placeId);
      }
    }

    return NearbyEmergencyServicesSnapshot(
      policeCount: idsByCategory['police']!.length,
      hospitalCount: idsByCategory['hospital']!.length,
      pharmacyCount: idsByCategory['pharmacy']!.length,
      petrolPumpCount: idsByCategory['petrol']!.length,
      washroomCount: idsByCategory['washroom']!.length,
      bloodBankCount: idsByCategory['blood']!.length,
      radiusMeters: radiusMeters,
      scanned: true,
    );
  }

  static bool _isLikelyWashroomPlace(Map<String, dynamic> item) {
    final types = item['types'];
    if (types is List) {
      final normalized = types.map((value) => value.toString().toLowerCase());
      if (normalized.any(
        (value) =>
            value.contains('restroom') ||
            value.contains('toilet') ||
            value == 'gas_station' ||
            value == 'shopping_mall' ||
            value == 'hospital' ||
            value == 'park',
      )) {
        return true;
      }
    }

    final name = item['name']?.toString().toLowerCase() ?? '';
    const keywords = [
      'toilet',
      'restroom',
      'washroom',
      'wc',
      'lavatory',
      'loo',
      'shauchalay',
      'shulabh',
    ];
    return keywords.any(name.contains);
  }
}
