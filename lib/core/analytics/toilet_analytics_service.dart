import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class ToiletAnalyticsService {
  const ToiletAnalyticsService();

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final cleanParameters = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) continue;
      cleanParameters[entry.key] = value;
    }

    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAnalytics.instance.logEvent(
          name: name,
          parameters: cleanParameters.isEmpty ? null : cleanParameters,
        );
      } else if (kDebugMode) {
        debugPrint(
          'analytics:$name${cleanParameters.isEmpty ? '' : ' $cleanParameters'}',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('analytics:$name failed: $error');
      }
    }
  }
}
