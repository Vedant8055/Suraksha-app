import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/core/network/auth_interceptor.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_dio_interceptor.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/tls_pinning.dart';

class NetworkManager {
  NetworkManager._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.preferredBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    _attachTlsPinning(_dio);
    _dio.interceptors.addAll([
      AuthInterceptor(dio: _dio),
      ActivityLogDioInterceptor(),
      InterceptorsWrapper(
        onError: (error, handler) => handler.next(_normalizeError(error)),
      ),
    ]);
  }

  static final NetworkManager instance = NetworkManager._internal();

  late final Dio _dio;
  bool? _lastReachable;

  void _attachTlsPinning(Dio dio) {
    // Certificate pinning is a dart:io concern (mobile/desktop).
    if (kIsWeb) return;
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // System trust still applies; validateCertificate adds pin checks.
        return client;
      },
      validateCertificate: (cert, host, port) {
        return TlsPinning.validateCertificate(cert, host, port);
      },
    );
  }

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

  /// Probes backend URLs after the UI is visible — never blocks cold start.
  Future<void> warmUpInBackground() async {
    try {
      final ok = await BackendUrlResolver.applyToDio(_dio);
      _lastReachable = ok;
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
