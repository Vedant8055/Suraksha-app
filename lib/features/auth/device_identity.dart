import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentity {
  DeviceIdentity._();

  static const _storageKey = 'suraksha_device_id';

  static Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_storageKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure().nextInt(999999).toString().padLeft(6, '0');
    final generated = '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}_$random';
    await prefs.setString(_storageKey, generated);
    return generated;
  }

  static String platformLabel() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return Platform.operatingSystem;
  }

  static Future<String> deviceLabel() async {
    final platform = platformLabel();
    final id = await deviceId();
    final suffix = id.length > 6 ? id.substring(id.length - 6) : id;
    return '$platform · $suffix';
  }
}
