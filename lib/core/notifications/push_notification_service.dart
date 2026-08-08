import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_deep_link.dart';
import 'package:suraksha_women_safety_app/features/auth/device_identity.dart';

enum NotificationAckResult { ok, expired, notFound, failed }

/// Background isolate entry for FCM. Keep this lightweight.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // System tray already shows `notification` payloads while backgrounded.
  // Ensure Firebase is available if a future handler needs it.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
}

/// Local notifications + optional remote FCM.
///
/// Remote push activates automatically when Firebase initializes successfully
/// (requires `android/app/google-services.json`). Without that file the app
/// keeps working with local notifications only.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  /// Master switch: attempt remote FCM when Firebase config is present.
  static const bool remotePushEnabled = true;

  bool _available = false;
  bool _firebaseReady = false;
  bool _listenersAttached = false;
  String? _lastRegisteredToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _dio = DioClient().dio;

  bool get isAvailable => _available;
  bool get isRemotePushConfigured => remotePushEnabled && _firebaseReady;

  Future<void> initialize() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = NotificationDeepLink.decode(response.payload);
          if (payload != null) NotificationNavigation.handle(payload);
        },
      );

      if (Platform.isAndroid) {
        final android = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            'suraksha_journey_alerts',
            'Journey safety alerts',
            description:
                'Alerts when entering higher-risk zones during a journey.',
            importance: Importance.high,
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
      }

      _available = true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Local push channel setup failed: $error');
      }
    }

    if (remotePushEnabled) {
      await _ensureFirebaseAndAttachListeners();
    }
  }

  Future<bool> _ensureFirebaseAndAttachListeners() async {
    if (_firebaseReady) {
      _attachListenersIfNeeded();
      return true;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _firebaseReady = true;
      _attachListenersIfNeeded();
      if (kDebugMode) {
        debugPrint('Firebase/FCM ready.');
      }
      return true;
    } catch (error) {
      _firebaseReady = false;
      if (kDebugMode) {
        debugPrint(
          'Firebase/FCM unavailable (add google-services.json for Android): $error',
        );
      }
      return false;
    }
  }

  void _attachListenersIfNeeded() {
    if (!_firebaseReady || _listenersAttached) return;
    _listenersAttached = true;

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      unawaited(_uploadToken(token));
    });

    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    _openedAppSub?.cancel();
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = _payloadFromRemoteMessage(message);
      if (payload != null) NotificationNavigation.handle(payload);
    });

    unawaited(_handleInitialMessage());
  }

  Future<void> _handleInitialMessage() async {
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial == null) return;
      final payload = _payloadFromRemoteMessage(initial);
      if (payload != null) NotificationNavigation.handle(payload);
    } catch (_) {}
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Suraksha';
    // Prefer full in-app body; fall back to lock-screen-safe notification body.
    final body = message.data['fullBody']?.toString().trim().isNotEmpty == true
        ? message.data['fullBody']!.toString()
        : (message.notification?.body ??
            message.data['body']?.toString() ??
            '');
    final critical = message.data['critical']?.toString() == '1' ||
        message.data['alertType']?.toString() == 'critical' ||
        message.data['priority']?.toString() == 'critical';
    final channelId =
        critical ? 'suraksha_critical' : 'suraksha_journey_alerts';
    final payload = _payloadFromRemoteMessage(message);

    try {
      await _localNotifications.show(
        message.hashCode & 0x7fffffff,
        title,
        body.isEmpty ? null : body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            critical ? 'Critical safety alerts' : 'Journey safety alerts',
            channelDescription: critical
                ? 'Critical SOS and danger alerts.'
                : 'Alerts when entering higher-risk zones during a journey.',
            importance: critical ? Importance.max : Importance.high,
            priority: critical ? Priority.max : Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload == null
            ? null
            : NotificationDeepLink.encode(
                route: payload['route']?.toString() ??
                    NotificationDeepLink.dashboard,
                notificationId: payload['notificationId']?.toString(),
                extra: {
                  for (final entry in payload.entries)
                    if (entry.key != 'route' && entry.key != 'notificationId')
                      entry.key: entry.value?.toString() ?? '',
                },
              ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Foreground FCM local display failed: $error');
      }
    }
  }

  Map<String, dynamic>? _payloadFromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty && message.notification == null) return null;
    final route = data['deepLink']?.toString() ??
        data['route']?.toString() ??
        NotificationDeepLink.notificationsInbox;
    return {
      'route': route,
      if (data['notificationId'] != null)
        'notificationId': data['notificationId'].toString(),
      ...data,
    };
  }

  Future<bool> requestPermission() async {
    var granted = false;
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      granted = status.isGranted || status.isLimited;
    } else {
      final ios = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }

    if (remotePushEnabled) {
      final ready = await _ensureFirebaseAndAttachListeners();
      if (ready) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = granted ||
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }
    }
    return granted;
  }

  Future<PermissionStatus> currentPermissionStatus() async {
    return Permission.notification.status;
  }

  Future<void> registerTokenIfAuthenticated() async {
    if (!remotePushEnabled) {
      if (kDebugMode) {
        debugPrint('Remote FCM disabled by flag.');
      }
      return;
    }

    final ready = await _ensureFirebaseAndAttachListeners();
    if (!ready) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('FCM token unavailable yet.');
        }
        return;
      }
      await _uploadToken(token);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM token registration failed: $error');
      }
    }
  }

  Future<void> _uploadToken(String token) async {
    if (token.isEmpty) return;
    if (_lastRegisteredToken == token) return;
    try {
      await _dio.post(
        ApiConstants.profileFcmToken,
        data: {
          'fcmToken': token,
          'platform': DeviceIdentity.platformLabel(),
          'deviceId': await DeviceIdentity.deviceId(),
        },
      );
      _lastRegisteredToken = token;
      if (kDebugMode) {
        debugPrint('FCM token registered with backend.');
      }
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'FCM token upload failed (${error.response?.statusCode}): $error',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('FCM token upload failed: $error');
      }
    }
  }

  /// Clears any locally remembered token. Backend logout clears session fcmToken.
  Future<void> clearTokenOnLogout() async {
    _lastRegisteredToken = null;
    if (!_firebaseReady) return;
    try {
      // Delete device token so this install stops receiving pushes after logout.
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  Future<NotificationAckResult> acknowledgeNotification(
    String notificationId,
  ) async {
    if (notificationId.isEmpty) return NotificationAckResult.failed;
    try {
      await _dio.post(ApiConstants.notificationAck(notificationId));
      return NotificationAckResult.ok;
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 410) return NotificationAckResult.expired;
      if (code == 404) return NotificationAckResult.notFound;
      if (kDebugMode) {
        debugPrint('Notification ack failed: $error');
      }
      return NotificationAckResult.failed;
    } catch (_) {
      return NotificationAckResult.failed;
    }
  }

  Future<void> openSystemNotificationSettings() async {
    await openAppSettings();
  }
}
