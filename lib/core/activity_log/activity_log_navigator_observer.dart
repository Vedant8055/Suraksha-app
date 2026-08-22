import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';

class ActivityLogNavigatorObserver extends NavigatorObserver {
  ActivityLogNavigatorObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(opened: true, route: route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _log(opened: true, route: newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(opened: false, route: route);
  }

  void _log({required bool opened, required Route<dynamic> route}) {
    if (route is PopupRoute) return;
    if (route is! PageRoute) return;
    final name = route.settings.name?.trim() ?? '';
    if (name.isEmpty || name == '/' || name == 'dashboard') return;
    if (name == 'Logs' || name.contains('ActivityLogs')) return;
    if (name.contains('Dialog') ||
        name.contains('Modal') ||
        name.contains('Sheet') ||
        name.contains('Popup')) {
      return;
    }

    unawaitedSafe(
      AppActivityLog.instance.record(
        opened ? 'screen_opened' : 'screen_closed',
        message: opened ? '$name opened' : '$name closed',
        details: {'screen': name},
      ),
    );
  }
}

void unawaitedSafe(Future<void> future) {
  future.catchError((_) {});
}
