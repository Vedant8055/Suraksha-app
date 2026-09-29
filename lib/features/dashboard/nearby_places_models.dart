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

String normalizeNearbyLanguageCode(String code) {
  final normalized = code.trim().toLowerCase().split(RegExp(r'[_-]')).first;
  return normalized == 'hi' || normalized == 'mr' ? normalized : 'en';
}
