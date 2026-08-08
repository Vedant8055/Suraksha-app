import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_deep_link.dart';
import 'package:suraksha_women_safety_app/core/notifications/push_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FCM wiring characterization', () {
    test('remote push master switch is enabled', () {
      expect(PushNotificationService.remotePushEnabled, isTrue);
    });

    test('journey deepLink maps to safety map route constant', () {
      const deepLink = 'safety_map';
      expect(deepLink, NotificationDeepLink.safetyMap);
    });

    test('deep link encode/decode keeps notification id', () {
      final encoded = NotificationDeepLink.encode(
        route: NotificationDeepLink.safetyMap,
        notificationId: 'n1',
        extra: {'type': 'safety_journey'},
      );
      final decoded = NotificationDeepLink.decode(encoded);
      expect(decoded?['route'], NotificationDeepLink.safetyMap);
      expect(decoded?['notificationId'], 'n1');
      expect(decoded?['type'], 'safety_journey');
    });

    test('initialize completes without Firebase config in tests', () async {
      await expectLater(
        PushNotificationService.instance.initialize(),
        completes,
      );
      // Without google-services.json / native Firebase, remote stays unconfigured.
      expect(
        PushNotificationService.instance.isRemotePushConfigured,
        isFalse,
      );
    });
  });
}
