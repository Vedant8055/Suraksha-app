import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  AuthTokenStorage._();

  static const tokenKey = 'token';
  static const refreshTokenKey = 'refresh_token';
  static const storage = FlutterSecureStorage();

  static Future<String?> readAccessToken() => storage.read(key: tokenKey);

  static Future<String?> readRefreshToken() => storage.read(key: refreshTokenKey);

  static Future<void> saveTokens({
    required String access,
    String? refresh,
  }) async {
    await storage.write(key: tokenKey, value: access);
    if (refresh != null && refresh.isNotEmpty) {
      await storage.write(key: refreshTokenKey, value: refresh);
    }
  }

  static Future<void> clear() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: refreshTokenKey);
  }
}
