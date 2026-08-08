import 'dart:convert';

/// Deep-link targets used by local/FCM notification payloads.
/// Kept in sync with [AppRoutes] string values.
class NotificationDeepLink {
  static const safetyMap = 'safety_map';
  static const sos = 'sos';
  static const cyber = 'cyber';
  static const posh = 'posh';
  static const dashboard = 'dashboard';
  static const communityAlerts = 'community_alerts';
  static const profileNotifications = 'profile_notifications';
  static const surakshaAi = 'suraksha_ai';
  static const notificationsInbox = 'notifications_inbox';

  static String encode({
    required String route,
    String? notificationId,
    Map<String, String>? extra,
  }) {
    return jsonEncode({
      'route': route,
      if (notificationId != null && notificationId.isNotEmpty)
        'notificationId': notificationId,
      ...?extra,
    });
  }

  static Map<String, dynamic>? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return {'route': raw.trim()};
    }
    return null;
  }
}

typedef NotificationNavigationHandler =
    void Function(Map<String, dynamic> payload);

/// Holds the app navigator callback so notification taps can deep-link.
class NotificationNavigation {
  static NotificationNavigationHandler? onOpen;
  static Map<String, dynamic>? pendingPayload;

  static void handle(Map<String, dynamic> payload) {
    final handler = onOpen;
    if (handler == null) {
      pendingPayload = payload;
      return;
    }
    handler(payload);
  }

  static void flushPending() {
    final pending = pendingPayload;
    final handler = onOpen;
    if (pending == null || handler == null) return;
    pendingPayload = null;
    handler(pending);
  }
}
