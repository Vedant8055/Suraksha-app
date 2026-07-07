import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notifications only. FCM/Firebase is intentionally skipped (no google-services.json).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  bool _available = false;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  bool get isAvailable => _available;

  Future<void> initialize() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (_) {},
      );

      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                'suraksha_journey_alerts',
                'Journey safety alerts',
                description:
                    'Alerts when entering higher-risk zones during a journey.',
                importance: Importance.high,
              ),
            );
      }

      _available = true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Local push channel setup failed: $error');
      }
    }
  }

  Future<void> registerTokenIfAuthenticated() async {
    // FCM disabled — no remote token registration.
  }
}
