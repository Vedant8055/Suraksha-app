import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';

class BackendUrlResolver {
  BackendUrlResolver._();

  static const _prefKey = 'backend_base_url_override';

  static bool get _isMobileDevice =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<String?> savedOverride() async {
    if (!kDebugMode) return null;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey)?.trim();
    if (value == null || value.isEmpty) return null;
    return value.replaceAll(RegExp(r'/$'), '');
  }

  static Future<void> saveOverride(String url) async {
    if (!kDebugMode) return;
    final normalized = url.trim().replaceAll(RegExp(r'/$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, normalized);
  }

  static Future<void> clearOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  static List<String> candidateUrls() {
    if (!kDebugMode) return [ApiConfig.preferredBaseUrl];
    final urls = <String>[];
    void add(String? raw) {
      if (raw == null || raw.trim().isEmpty) return;
      final normalized = raw.trim().replaceAll(RegExp(r'/$'), '');
      if (!urls.contains(normalized)) urls.add(normalized);
    }

    // LAN IP first for physical phones on the same Wi-Fi as the dev PC.
    add(ApiConfig.lanBaseUrl);
    add(ApiConfig.baseUrlFromEnv);
    if (!_isMobileDevice) {
      add(ApiConfig.localhostBaseUrl);
    } else if (Platform.isAndroid) {
      // Works when USB debugging + `adb reverse tcp:5000 tcp:5000` is active.
      add(ApiConfig.localhostBaseUrl);
    }
    return urls;
  }

  static Future<bool> _probe(String baseUrl) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      ),
    );
    try {
      final response = await dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      dio.close(force: true);
    }
  }

  static Future<bool> recoverConnection(Dio dio) async {
    if (!kDebugMode) {
      dio.options.baseUrl = ApiConfig.preferredBaseUrl;
      // Production: allow long enough for a cold Render wake on /health.
      final probe = Dio(
        BaseOptions(
          baseUrl: ApiConfig.preferredBaseUrl.replaceAll(RegExp(r'/api/?$'), ''),
          connectTimeout: const Duration(seconds: 55),
          receiveTimeout: const Duration(seconds: 55),
        ),
      );
      try {
        final response = await probe.get('/health');
        return (response.statusCode ?? 500) < 500;
      } catch (_) {
        return false;
      } finally {
        probe.close(force: true);
      }
    }
    await clearOverride();
    for (final candidate in candidateUrls()) {
      if (!await _probe(candidate)) continue;
      dio.options.baseUrl = candidate;
      await saveOverride(candidate);
      return true;
    }
    return false;
  }

  static Future<String> resolveWorkingBaseUrl() async {
    for (final candidate in candidateUrls()) {
      if (await _probe(candidate)) return candidate;
    }
    return ApiConfig.preferredBaseUrl;
  }

  static Future<bool> applyToDio(Dio dio) async {
    final url = await resolveWorkingBaseUrl();
    dio.options.baseUrl = url;
    return true;
  }

  static bool isConnectionError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response == null && error.error != null);
  }
}
