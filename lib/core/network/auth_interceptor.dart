import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/auth_token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({FlutterSecureStorage? storage, Dio? dio})
    : _storage = storage ?? AuthTokenStorage.storage,
      _dio = dio;

  final FlutterSecureStorage _storage;
  final Dio? _dio;

  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.preferredBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  static bool _isRefreshing = false;

  static bool _isAuthRoute(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/otp/') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }

    final token = await _storage.read(key: AuthTokenStorage.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers.putIfAbsent('Accept', () => 'application/json');
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra['authRetried'] == true;

    if (status != 401 ||
        alreadyRetried ||
        _isAuthRoute(path) ||
        err.requestOptions.extra['skipAuthRefresh'] == true) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshTokens();
    if (!refreshed) {
      await AuthTokenStorage.clear();
      handler.next(err);
      return;
    }

    try {
      final dio = _dio;
      if (dio == null) {
        handler.next(err);
        return;
      }

      final token = await _storage.read(key: AuthTokenStorage.tokenKey);
      final requestOptions = err.requestOptions;
      requestOptions.extra['authRetried'] = true;
      requestOptions.headers['Authorization'] = 'Bearer $token';
      final response = await dio.fetch(requestOptions);
      handler.resolve(response);
    } catch (retryError) {
      if (retryError is DioException) {
        handler.next(retryError);
      } else {
        handler.next(err);
      }
    }
  }

  static Future<bool> _refreshTokens() async {
    if (_isRefreshing) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final token = await AuthTokenStorage.storage.read(
        key: AuthTokenStorage.tokenKey,
      );
      return token != null && token.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await AuthTokenStorage.storage.read(
        key: AuthTokenStorage.refreshTokenKey,
      );
      if (refreshToken == null || refreshToken.isEmpty) return false;

      _refreshDio.options.baseUrl = ApiConfig.preferredBaseUrl;
      final response = await _refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final access = data['token']?.toString() ?? '';
      final nextRefresh = data['refreshToken']?.toString();
      if (access.isEmpty) return false;

      await AuthTokenStorage.saveTokens(
        access: access,
        refresh: nextRefresh ?? refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static Future<bool> tryRefreshSession() => _refreshTokens();
}
