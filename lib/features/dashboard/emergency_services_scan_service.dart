import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';

/// Nearby emergency / support services within a fixed radius (default 1 km).
/// Counts are resolved on the backend using the server Google Maps API key.
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

  factory NearbyEmergencyServicesSnapshot.fromJson(Map<String, dynamic> json) {
    int read(String key) {
      final value = json[key];
      if (value is num) return value.round();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return NearbyEmergencyServicesSnapshot(
      policeCount: read('policeCount'),
      hospitalCount: read('hospitalCount'),
      pharmacyCount: read('pharmacyCount'),
      petrolPumpCount: read('petrolPumpCount'),
      washroomCount: read('washroomCount'),
      bloodBankCount: read('bloodBankCount'),
      radiusMeters: read('radiusMeters') == 0 ? 1000 : read('radiusMeters'),
      scanned: json['scanned'] != false,
    );
  }
}

class EmergencyServicesScanService {
  EmergencyServicesScanService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;
  static const int defaultRadiusMeters = 1000;

  Future<NearbyEmergencyServicesSnapshot> scanWithinRadius({
    required double latitude,
    required double longitude,
    int radiusMeters = defaultRadiusMeters,
    String languageCode = 'en',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.nearbyEmergencyServices,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusMeters,
          'lang': languageCode,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      final data = response.data;
      if (data is Map) {
        return NearbyEmergencyServicesSnapshot.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      return NearbyEmergencyServicesSnapshot(
        radiusMeters: radiusMeters,
        scanned: true,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 503) {
        // Server key missing — still mark scanned so UI shows the section.
        return NearbyEmergencyServicesSnapshot(
          radiusMeters: radiusMeters,
          scanned: true,
        );
      }
      rethrow;
    }
  }
}
