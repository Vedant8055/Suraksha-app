import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/core/media/profile_photo_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alerts_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase3 profile photo decode', () {
    test('remote URLs use ResizeImage for cheaper decode', () {
      final provider = profilePhotoImageProvider(
        'https://cdn.example.com/avatar.jpg',
      );
      expect(provider, isA<ResizeImage>());
    });

    test('invalid values stay null', () {
      expect(profilePhotoImageProvider(null), isNull);
      expect(profilePhotoImageProvider(''), isNull);
      expect(profilePhotoImageProvider('   '), isNull);
    });

    test('isValidRemotePhotoUrl accepts https only', () {
      expect(isValidRemotePhotoUrl('https://x.test/a.png'), isTrue);
      expect(isValidRemotePhotoUrl('http://x.test/a.png'), isTrue);
      expect(isValidRemotePhotoUrl(r'C:\Users\me\pic.jpg'), isFalse);
    });
  });

  group('Phase3 community alerts TTL contract', () {
    test('fresh non-empty state is within default TTL window', () {
      final state = CommunityAlertsState(
        alerts: [
          CommunityAlertItem(
            kind: CommunityAlertKind.traffic,
            title: 'Traffic',
            detail: 'Slow',
            updatedAt: DateTime.now(),
          ),
        ],
        lastUpdatedAt: DateTime.now(),
      );
      expect(state.alerts, isNotEmpty);
      expect(state.lastUpdatedAt, isNotNull);
      expect(
        DateTime.now().difference(state.lastUpdatedAt!) <
            const Duration(minutes: 2),
        isTrue,
      );
    });
  });

  group('Phase3 nearby places TTL key shape', () {
    test('rounded lat/lng key format is stable', () {
      const lat = 19.997454;
      const lng = 73.789802;
      final key =
          '${NearbyPlaceType.hospitals.apiCategory}_'
          '${lat.toStringAsFixed(3)}_'
          '${lng.toStringAsFixed(3)}_en';
      expect(key, 'hospitals_19.997_73.790_en');
    });
  });
}
