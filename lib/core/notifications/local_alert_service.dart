import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_deep_link.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_preferences_provider.dart';

/// Lightweight local notifications for on-device safety alerts.
class LocalAlertService {
  LocalAlertService._();

  static final LocalAlertService instance = LocalAlertService._();
  final _notifications = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> ensureReady() async {
    if (_ready) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = NotificationDeepLink.decode(response.payload);
        if (payload != null) NotificationNavigation.handle(payload);
      },
    );

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'suraksha_route_guard',
        'Route guard alerts',
        description: 'Alerts when you leave your usual daily route.',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'suraksha_reminders',
        'Safety reminders',
        description: 'Optional safety reminders and check-ins.',
        importance: Importance.defaultImportance,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'suraksha_critical',
        'Critical safety alerts',
        description: 'Critical SOS and danger alerts.',
        importance: Importance.max,
      ),
    );
    _ready = true;

    final launch = await _notifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final payload = NotificationDeepLink.decode(
        launch!.notificationResponse?.payload,
      );
      if (payload != null) NotificationNavigation.handle(payload);
    }
  }

  Future<void> showRouteDeviationAlert({
    required String title,
    required String body,
  }) async {
    final enabled =
        await SafetyPreferencesNotifier.isRouteWarningsEnabledLocal();
    if (!enabled) return;

    await ensureReady();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'suraksha_route_guard',
        'Route guard alerts',
        channelDescription: 'Alerts when you leave your usual daily route.',
        importance: Importance.high,
        priority: Priority.high,
        // Hide detailed body on secure lock screens.
        visibility: NotificationVisibility.private,
        category: AndroidNotificationCategory.navigation,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notifications.show(
      4102,
      title,
      body,
      details,
      payload: NotificationDeepLink.encode(route: NotificationDeepLink.safetyMap),
    );
  }

  Future<void> cancelRouteDeviationAlert() async {
    if (!_ready) return;
    await _notifications.cancel(4102);
  }

  Future<void> showSafetyReminder({
    required String title,
    required String body,
  }) async {
    final enabled =
        await SafetyPreferencesNotifier.isSafetyRemindersEnabledLocal();
    if (!enabled) return;
    await ensureReady();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'suraksha_reminders',
        'Safety reminders',
        channelDescription: 'Optional safety reminders and check-ins.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        visibility: NotificationVisibility.private,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(
      4201,
      title,
      body,
      details,
      payload: NotificationDeepLink.encode(
        route: NotificationDeepLink.dashboard,
      ),
    );
  }

  Future<void> showCriticalLocalAlert({
    required String title,
    required String lockScreenBody,
    required String fullBody,
    required String deepLink,
    int id = 4301,
  }) async {
    final enabled = await SafetyPreferencesNotifier.isSosAlertsEnabledLocal();
    if (!enabled) {
      if (kDebugMode) {
        debugPrint('SOS/critical local alert suppressed by preference');
      }
      return;
    }
    await ensureReady();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'suraksha_critical',
        'Critical safety alerts',
        channelDescription: 'Critical SOS and danger alerts.',
        importance: Importance.max,
        priority: Priority.max,
        visibility: NotificationVisibility.private,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: false,
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
    // Lock-screen shows generic copy; payload carries full context for in-app.
    await _notifications.show(
      id,
      title,
      lockScreenBody,
      details,
      payload: NotificationDeepLink.encode(
        route: deepLink,
        extra: {'fullBody': fullBody},
      ),
    );
  }
}
