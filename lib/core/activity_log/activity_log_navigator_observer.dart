import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';

class ActivityLogNavigatorObserver extends NavigatorObserver {
  ActivityLogNavigatorObserver();
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('screen_opened', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _log('screen_replaced', newRoute, oldRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('screen_closed', route, previousRoute);
  }

  void _log(
    String event,
    Route<dynamic> route,
    Route<dynamic>? other,
  ) {
    final name = route.settings.name ?? route.runtimeType.toString();
    if (name.contains('ActivityLogs')) return;
    final from = other?.settings.name ?? other?.runtimeType.toString() ?? '';
    unawaitedSafe(
      AppActivityLog.instance.record(
        event,
        details: {
          'screen': name,
          if (from.isNotEmpty) 'from': from,
        },
      ),
    );
  }
}

void unawaitedSafe(Future<void> future) {
  future.catchError((_) {});
}
