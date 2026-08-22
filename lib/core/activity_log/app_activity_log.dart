import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_labels.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_redactor.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_store.dart';

/// Central append-only activity logger. Never throws to callers.
class AppActivityLog {
  AppActivityLog._();

  static final AppActivityLog instance = AppActivityLog._();

  final ActivityLogStore store = ActivityLogStore();

  /// [event] is a stable id. [message] is the human-readable line shown in UI/export.
  /// Last-known GPS is attached when available (no new location request).
  Future<void> record(
    String event, {
    String? message,
    Map<String, String>? details,
  }) async {
    try {
      final merged = <String, String>{...?details};
      if (message != null && message.trim().isNotEmpty) {
        merged['message'] = message.trim();
      }
      merged.putIfAbsent(
        'message',
        () => ActivityLogLabels.lineForEvent(event, merged),
      );

      final position = await _lastKnownPosition();
      if (position != null) {
        merged.putIfAbsent('lat', () => position.latitude.toStringAsFixed(6));
        merged.putIfAbsent('lng', () => position.longitude.toStringAsFixed(6));
      }

      final scrubbed = ActivityLogRedactor.scrubMap(merged);
      final detailText = scrubbed.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
      await store.append(
        event: ActivityLogRedactor.scrubText(event),
        details: detailText,
      );
    } catch (_) {
      // Logging must never break app flows.
    }
  }

  Future<Position?> _lastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }
}
