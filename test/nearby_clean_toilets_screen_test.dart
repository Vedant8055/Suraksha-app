import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_screen.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_service.dart';

NearbyCleanToilet _toilet({
  required String id,
  required int distance,
  bool female = true,
  bool accessible = false,
  bool water = true,
  String cleanlinessStatus = 'Clean',
  String availabilityStatus = 'Open',
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
  });
}

Position _position() {
  return Position(
    longitude: 73.7898,
    latitude: 19.9975,
    timestamp: DateTime.parse('2026-06-30T12:00:00Z'),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
    floor: 0,
    isMocked: false,
  );
}

class _FakeToiletsService extends NearbyCleanToiletsService {
  _FakeToiletsService(
    this.items, {
    this.upstreamRawCount = 0,
  });

  final List<NearbyCleanToilet> items;
  final int upstreamRawCount;
  NearbyCleanToiletFilters? lastFilters;

  @override
  Future<NearbyCleanToiletsFetchResult> fetchNearbyToiletsDetailed({
    required double latitude,
    required double longitude,
    required NearbyCleanToiletFilters filters,
  }) async {
    lastFilters = filters;
    final toilets = NearbyCleanToiletsService.sortToilets(
      items.where((toilet) {
        return NearbyCleanToiletsService.matchesClientFilters(toilet, filters);
      }).toList(),
    );
    return NearbyCleanToiletsFetchResult(
      toilets: toilets,
      upstreamRawCount: upstreamRawCount,
    );
  }
}

void main() {
  testWidgets('shows empty state when no toilets are found', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NearbyCleanToiletsScreen(
          service: _FakeToiletsService(const []),
          locationResolver: () async => _position(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Sanitation registry returned no published toilets here.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('toilet service is connected'),
      findsOneWidget,
    );
    expect(find.text('Increase radius'), findsOneWidget);
    expect(find.text('Open map'), findsOneWidget);
  });

  testWidgets('filters the list by facility toggle', (tester) async {
    final service = _FakeToiletsService(
      [
        _toilet(id: 'female', distance: 150, female: true),
        _toilet(id: 'male', distance: 100, female: false),
      ],
      upstreamRawCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NearbyCleanToiletsScreen(
          service: service,
          locationResolver: () async => _position(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Navigate'), findsOneWidget);

    await tester.ensureVisible(find.text('Female facility'));
    await tester.tap(find.text('Female facility'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(service.lastFilters?.femaleFacilityOnly, isTrue);
  });

  testWidgets('launches navigation with correct coordinates', (tester) async {
    final launches = <Uri>[];

    await tester.pumpWidget(
      MaterialApp(
        home: NearbyCleanToiletsScreen(
          service: _FakeToiletsService(
            [_toilet(id: 'nav', distance: 120)],
            upstreamRawCount: 1,
          ),
          locationResolver: () async => _position(),
          launchExternalUri: (uri) async {
            launches.add(uri);
            return true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Navigate'));
    await tester.pumpAndSettle();

    expect(launches, hasLength(1));
    expect(launches.single.toString(), contains('destination=19.1%2C73.1'));
  });
}
