import 'package:suraksha_women_safety_app/config/api_config.dart';

class AppEnvironment {
  static String get environment => ApiConfig.environment;

  static String get apiBaseUrl => ApiConfig.baseUrl;

  static String get socketBaseUrl => ApiConfig.socketUrl;

  // AI provider secrets belong on the backend and are never compiled into
  // the mobile client.
  static String get geminiApiKey => '';

  static String get geminiModel =>
      const String.fromEnvironment(
        'GEMINI_MODEL',
        defaultValue: 'gemini-1.5-flash',
      );
}
