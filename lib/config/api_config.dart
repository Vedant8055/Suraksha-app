import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _productionApi =
      'https://suraksha-backend-gtdi.onrender.com/api';
  static const _productionSocket =
      'https://suraksha-backend-gtdi.onrender.com';

  static String get environment =>
      const String.fromEnvironment('APP_ENV', defaultValue: 'production');

  static String get baseUrlFromEnv {
    const value = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _productionApi,
    );
    return value.replaceAll(RegExp(r'/$'), '');
  }

  /// PC LAN IP for physical phones, e.g. http://192.168.1.5:5000/api
  static String get lanBaseUrl {
    const value = String.fromEnvironment('LAN_BASE_URL', defaultValue: '');
    return value.replaceAll(RegExp(r'/$'), '');
  }

  /// Useful when running on iOS simulator / desktop.
  static String get localhostBaseUrl {
    const port = String.fromEnvironment('API_PORT', defaultValue: '5000');
    return 'http://127.0.0.1:$port/api';
  }

  static String get baseUrl => preferredBaseUrl;

  /// Best URL for the current device (LAN IP on physical phones).
  static String get preferredBaseUrl {
    final lan = lanBaseUrl;
    if (kDebugMode && lan.isNotEmpty) return lan;
    final envBase = baseUrlFromEnv;
    if (envBase.isNotEmpty) return envBase;
    return kDebugMode ? localhostBaseUrl : _productionApi;
  }

  static String get socketUrl {
    const value = String.fromEnvironment(
      'SOCKET_BASE_URL',
      defaultValue: _productionSocket,
    );
    return value.replaceAll(RegExp(r'/$'), '');
  }

  static void assertSafeConfiguration() {
    if (kDebugMode) return;
    final apiUri = Uri.tryParse(preferredBaseUrl);
    final socketUri = Uri.tryParse(socketUrl);
    if (environment != 'production' ||
        apiUri?.scheme != 'https' ||
        socketUri?.scheme != 'https' ||
        apiUri?.host != 'suraksha-backend-gtdi.onrender.com' ||
        socketUri?.host != 'suraksha-backend-gtdi.onrender.com') {
      throw StateError(
        'Unsafe release configuration: production HTTPS endpoints are required.',
      );
    }
  }
}
