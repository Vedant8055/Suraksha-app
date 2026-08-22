import 'package:suraksha_women_safety_app/core/activity_log/activity_log_redactor.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_store.dart';

/// Central append-only activity logger. Never throws to callers.
class AppActivityLog {
  AppActivityLog._();

  static final AppActivityLog instance = AppActivityLog._();

  final ActivityLogStore store = ActivityLogStore();

  Future<void> record(String event, {Map<String, String>? details}) async {
    try {
      final scrubbed = ActivityLogRedactor.scrubMap(details ?? const {});
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
}
