import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Place autocomplete suggestion used by the safety map search bar.
class MapPlaceSuggestion {
  const MapPlaceSuggestion({
    required this.placeId,
    required this.title,
    required this.subtitle,
  });

  final String placeId;
  final String title;
  final String subtitle;
}

/// Result of a nearby-places marker fetch.
class MapNearbyFetchResult {
  const MapNearbyFetchResult({this.markers = const {}, this.errorMessage});

  final Set<Marker> markers;
  final String? errorMessage;
}

/// One candidate driving/walking route from Directions.
class MapDirectionRoute {
  const MapDirectionRoute({
    required this.routeId,
    required this.encodedPolyline,
    required this.etaSeconds,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationText,
    required this.safetyScore,
    required this.safetyReason,
  });

  final String routeId;
  final String encodedPolyline;
  final int etaSeconds;
  final double? distanceMeters;
  final String distanceText;
  final String durationText;
  final int safetyScore;
  final String safetyReason;
}

class MapRouteSafetyScore {
  const MapRouteSafetyScore({required this.score, required this.reason});

  final int score;
  final String reason;
}

class MapRouteAssessmentResult {
  const MapRouteAssessmentResult({
    required this.recommendedRouteId,
    required this.byRouteId,
  });

  final String? recommendedRouteId;
  final Map<String, MapRouteAssessmentDisplay> byRouteId;
}

class MapRouteAssessmentDisplay {
  const MapRouteAssessmentDisplay({
    required this.id,
    required this.label,
    required this.averageSafetyScore,
    required this.summary,
  });

  factory MapRouteAssessmentDisplay.fromJson(Map<String, dynamic> json) {
    return MapRouteAssessmentDisplay(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Safer Route',
      averageSafetyScore: (json['averageSafetyScore'] as num?)?.round() ?? 50,
      summary:
          json['summary']?.toString() ?? 'Balanced route guidance applied.',
    );
  }

  final String id;
  final String label;
  final int averageSafetyScore;
  final String summary;
}
