import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_service.dart';

NearbyCleanToilet _toilet({
  required String id,
  required int distance,
  String cleanlinessStatus = 'Clean',
  String availabilityStatus = 'Open',
  bool female = true,
  bool accessible = false,
  bool water = true,
}) {
  return NearbyCleanToilet.fromJson({
    'id': id,
    'name': 'Toilet $id',
    'address': 'Address $id',
    'distanceMeters': distance,
    'latitude': 19.1,
    'longitude': 73.1,
    'cleanlinessScore': cleanlinessStatus == 'Clean' ? 90 : 72,
    'cleanlinessStatus': cleanlinessStatus,
    'availabilityStatus': availabilityStatus,
    'lastUpdatedAt': '2026-06-30T11:20:00+05:30',
    'facilities': {
      'female': female,
      'accessible': accessible,
      'waterAvailable': water,
    },
    'safetyDisplayStatus':
        cleanlinessStatus == 'Clean' && availabilityStatus == 'Open'
        ? 'Recommended'
        : cleanlinessStatus == 'Usable' && availabilityStatus == 'Open'
        ? 'Usable'
        : 'Use with caution',
  });
}

void main() {
  test('sorts toilets by distance', () {
    final sorted = NearbyCleanToiletsService.sortToilets([
      _toilet(id: 'far', distance: 500),
      _toilet(id: 'near', distance: 120),
      _toilet(id: 'mid', distance: 250),
    ]);

    expect(sorted.map((item) => item.id), ['near', 'mid', 'far']);
  });

  test('filters toilets by facility and openness', () {
    final filters = const NearbyCleanToiletFilters(
      openNowOnly: true,
      femaleFacilityOnly: true,
      accessibleOnly: true,
      waterAvailableOnly: true,
    );

    final matches = NearbyCleanToiletsService.matchesClientFilters(
      _toilet(id: 'match', distance: 100, accessible: true),
      filters,
    );
    final misses = NearbyCleanToiletsService.matchesClientFilters(
      _toilet(
        id: 'miss',
        distance: 100,
        availabilityStatus: 'Closed',
        accessible: true,
      ),
      filters,
    );

    expect(matches, isTrue);
    expect(misses, isFalse);
  });

  test('rejects invalid coordinates', () {
    final invalid = NearbyCleanToilet.fromJson({
      'id': 'bad',
      'name': 'Bad Toilet',
      'latitude': 0,
      'longitude': 0,
      'distanceMeters': 100,
      'cleanlinessStatus': 'Clean',
      'availabilityStatus': 'Open',
      'facilities': const {},
    });

    expect(NearbyCleanToiletsService.hasValidCoordinates(invalid), isFalse);
    expect(NearbyCleanToiletsService.hasValidCoordinates(_toilet(id: 'ok', distance: 100)), isTrue);
  });

  test('marker hue matches safety status', () {
    expect(
      NearbyCleanToiletsService.markerHueForToilet(
        _toilet(id: 'recommended', distance: 100),
      ),
      120,
    );
    expect(
      NearbyCleanToiletsService.markerHueForToilet(
        _toilet(id: 'usable', distance: 100, cleanlinessStatus: 'Usable'),
      ),
      210,
    );
    expect(
      NearbyCleanToiletsService.markerHueForToilet(
        _toilet(
          id: 'caution',
          distance: 100,
          cleanlinessStatus: 'Needs Cleaning',
        ),
      ),
      30,
    );
  });

  test('builds navigation uri with destination coordinates', () {
    final uri = NearbyCleanToiletsService.buildNavigationUri(
      _toilet(id: 'nav', distance: 100),
    );

    expect(uri.toString(), contains('destination=19.1%2C73.1'));
  });

  test('builds issue report uri with toilet details', () {
    final uri = NearbyCleanToiletsService.buildIssueReportUri(
      _toilet(id: 'issue', distance: 100),
    );

    expect(uri.scheme, 'mailto');
    expect(uri.toString(), contains('Public%20toilet%20issue'));
    expect(uri.toString(), contains('Name%3A%20Toilet%20issue'));
  });

  test('builds markers and wires tap callbacks', () {
    final toilet = _toilet(id: 'tap', distance: 140);
    NearbyCleanToilet? tapped;

    final markers = NearbyCleanToiletsService.buildMarkers([
      toilet,
    ], onTap: (item) => tapped = item);

    expect(markers, hasLength(1));
    final marker = markers.first;
    expect(marker.markerId.value, 'tap');
    marker.onTap?.call();
    expect(tapped, same(toilet));
  });
}
