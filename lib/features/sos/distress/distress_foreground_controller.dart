import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/distress_task_handler.dart';

class DistressForegroundController {
  DistressForegroundController._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'suraksha_distress_monitor',
        channelName: 'Distress monitor',
        channelDescription:
            'Listens for screams and distress phrases to help trigger SOS safely.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1500),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
  }

  static Future<bool> start({
    required String sensitivity,
    required bool testMode,
    bool allowBatteryPrompt = false,
  }) async {
    await ensureInitialized();

    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // Only prompt after the user has seen the in-app battery explainer.
    if (allowBatteryPrompt &&
        !await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: l10nSync('distressMonitorNotificationTitle'),
        notificationText: testMode
            ? l10nSync('distressMonitorTestModeNotification')
            : l10nSync('distressMonitorNotificationText'),
        notificationButtons: const [
          NotificationButton(id: 'stop_monitoring', text: 'Stop'),
        ],
      );
      FlutterForegroundTask.sendDataToTask({
        'cmd': 'config',
        'sensitivity': sensitivity,
        'testMode': testMode,
      });
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      notificationTitle: l10nSync('distressMonitorNotificationTitle'),
      notificationText: testMode
          ? l10nSync('distressMonitorTestModeNotification')
          : l10nSync('distressMonitorNotificationText'),
      notificationButtons: const [
        NotificationButton(id: 'stop_monitoring', text: 'Stop'),
      ],
      callback: startDistressTaskCallback,
    );
    return result is ServiceRequestSuccess;
  }

  static Future<void> stop() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  static Future<bool> isBatteryRestricted() async {
    await ensureInitialized();
    return !await FlutterForegroundTask.isIgnoringBatteryOptimizations;
  }

  static Future<bool> openBatterySettings() async {
    await ensureInitialized();
    return FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
  }

  static void addDataListener(void Function(Object data) listener) {
    FlutterForegroundTask.addTaskDataCallback(listener);
  }

  static void removeDataListener(void Function(Object data) listener) {
    FlutterForegroundTask.removeTaskDataCallback(listener);
  }
}
