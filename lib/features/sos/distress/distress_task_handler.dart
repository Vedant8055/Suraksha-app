import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Keeps the app process alive for background microphone access (Android/iOS).
class DistressTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop_monitoring') {
      FlutterForegroundTask.sendDataToMain({'cmd': 'stop_monitoring'});
    }
  }
}

@pragma('vm:entry-point')
void startDistressTaskCallback() {
  FlutterForegroundTask.setTaskHandler(DistressTaskHandler());
}
