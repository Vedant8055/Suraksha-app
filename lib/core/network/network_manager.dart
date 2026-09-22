import 'dart:async';

import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/core/network/auth_interceptor.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/tls_pinning.dart';

class NetworkManager {
  NetworkManager._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.preferredBaseUrl,
        // Render free/starter cold starts can exceed 15s; keep a higher floor
        // so login/SOS are not killed mid-handshake.
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 45),
      ),
    );
    TlsPinning.attachToDio(_dio);
    _dio.interceptors.addAll([
      AuthInterceptor(dio: _dio),
      InterceptorsWrapper(
        onError: (error, handler) => handler.next(_normalizeError(error)),
      ),
    ]);
  }

  static final NetworkManager instance = NetworkManager._internal();

  late final Dio _dio;
  bool? _lastReachable;
  DateTime? _lastWakeAt;

  Future<bool> ensureReachable({bool force = false}) async {
    if (!force && _lastReachable != null) return _lastReachable!;
    _dio.options.baseUrl = ApiConfig.preferredBaseUrl;
    try {
      final response = await _dio
          .get(
            '/health',
            options: Options(
              receiveTimeout: const Duration(seconds: 3),
              sendTimeout: const Duration(seconds: 3),
              extra: const {
                'skipAuth': true,
                'skipAuthRefresh': true,
              },
            ),
          )
          .timeout(const Duration(seconds: 4));
      _lastReachable = (response.statusCode ?? 500) < 500;
    } catch (_) {
      // Fail open so SOS and core flows still attempt real API calls.
      _lastReachable = true;
    }
    return _lastReachable!;
  }

  /// Wakes a sleeping hosted backend (e.g. Render) before auth-critical calls.
  /// Safe to call often — skips if a successful wake happened recently.
  Future<bool> wakeBackendForAuth({bool force = false}) async {
    final recent = _lastWakeAt;
    if (!force &&
        recent != null &&
        DateTime.now().difference(recent) < const Duration(seconds: 90)) {
      return true;
    }

    _dio.options.baseUrl = ApiConfig.preferredBaseUrl;
    // Origin /health (ApiConfig base ends with /api).
    final healthUrl =
        ApiConfig.preferredBaseUrl.replaceAll(RegExp(r'/api/?$'), '/health');

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _dio.getUri(
          Uri.parse(healthUrl),
          options: Options(
            connectTimeout: const Duration(seconds: 55),
            sendTimeout: const Duration(seconds: 55),
            receiveTimeout: const Duration(seconds: 55),
            extra: const {
              'skipAuth': true,
              'skipAuthRefresh': true,
            },
          ),
        );
        if ((response.statusCode ?? 500) < 500) {
          _lastWakeAt = DateTime.now();
          _lastReachable = true;
          return true;
        }
      } catch (_) {
        // Retry once — first hit often only wakes the dyno.
      }
    }
    return false;
  }

  /// Probes backend URLs after the UI is visible — never blocks cold start.
  Future<void> warmUpInBackground() async {
    try {
      final ok = await BackendUrlResolver.applyToDio(_dio);
      _lastReachable = ok;
      // Production: wake Render so the first login is less likely to time out.
      unawaited(wakeBackendForAuth(force: true));
    } catch (_) {
      _lastReachable = false;
    }
  }

  Future<bool> recoverConnection() async {
    _lastReachable = null;
    final ok = await BackendUrlResolver.recoverConnection(_dio);
    _lastReachable = ok;
    return ok;
  }

  String get currentBaseUrl => _dio.options.baseUrl;

  Dio get dio => _dio;

  DioException _normalizeError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error: l10nSync('networkRequestTimedOut'),
        type: error.type,
      );
    }
    return error;
  }
}
