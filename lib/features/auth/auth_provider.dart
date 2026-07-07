import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/auth_interceptor.dart';
import 'package:suraksha_women_safety_app/core/network/auth_token_storage.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';

const Object _unset = Object();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier()..restoreSession();
});

class OtpSendResult {
  final bool success;
  final String? devCode;
  final String? error;
  final int resendAfterSeconds;

  const OtpSendResult({
    required this.success,
    this.devCode,
    this.error,
    this.resendAfterSeconds = 60,
  });
}

class OtpVerifyResult {
  final bool success;
  final String? verificationToken;
  final String? error;

  const OtpVerifyResult({
    required this.success,
    this.verificationToken,
    this.error,
  });
}

class AuthState {
  final bool isInitializing;
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final String? error;

  AuthState({
    this.isInitializing = true,
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
  });

  bool get isAuthenticated =>
      !isInitializing &&
      token != null &&
      token!.isNotEmpty &&
      user != null;

  AuthState copyWith({
    bool? isInitializing,
    bool? isLoading,
    Object? user = _unset,
    Object? token = _unset,
    Object? error = _unset,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoading: isLoading ?? this.isLoading,
      user: identical(user, _unset) ? this.user : user as UserModel?,
      token: identical(token, _unset) ? this.token : token as String?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? DioClient().dio,
      _storage = storage ?? AuthTokenStorage.storage,
      super(AuthState());

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<void> restoreSession() async {
    try {
      final token = await _storage.read(key: AuthTokenStorage.tokenKey);
      if (token == null || token.isEmpty) {
        state = state.copyWith(isInitializing: false, token: null, user: null);
        return;
      }

      state = state.copyWith(isInitializing: true, token: token, error: null);
      final user = await _fetchProfile().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('Session restore timed out'),
      );
      state = state.copyWith(
        isInitializing: false,
        token: token,
        user: user,
        error: null,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        final refreshed = await AuthInterceptor.tryRefreshSession().timeout(
          const Duration(seconds: 6),
          onTimeout: () => false,
        );
        if (refreshed) {
          try {
            final token = await _storage.read(key: AuthTokenStorage.tokenKey);
            final user = await _fetchProfile().timeout(
              const Duration(seconds: 8),
            );
            state = state.copyWith(
              isInitializing: false,
              token: token,
              user: user,
              error: null,
            );
            return;
          } catch (_) {
            // fall through to clear
          }
        }
        await _clearStoredCredentials();
      }
      state = AuthState(isInitializing: false);
    } on TimeoutException catch (_) {
      await _clearStoredCredentials();
      state = AuthState(isInitializing: false);
    } catch (_) {
      state = AuthState(isInitializing: false);
    }
  }

  Future<UserModel> _fetchProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> login(String identifier, String password) async {
    final trimmedId = identifier.trim();
    final trimmedPassword = password.trim();
    if (trimmedId.isEmpty || trimmedPassword.isEmpty) {
      state = state.copyWith(error: 'Please enter email/phone and password.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authPost(
        ApiConstants.login,
        data: {'identifier': trimmedId, 'password': trimmedPassword},
      );
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromDio(error, fallback: 'Login failed. Please try again.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  Future<OtpSendResult> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    try {
      final response = await _authPost(
        ApiConstants.otpSend,
        data: {'phone': phone, 'purpose': purpose},
      );
      final data = response.data as Map<String, dynamic>;
      return OtpSendResult(
        success: true,
        devCode: data['devCode']?.toString(),
        resendAfterSeconds: (data['resendAfterSeconds'] as num?)?.toInt() ?? 60,
      );
    } on DioException catch (error) {
      return OtpSendResult(
        success: false,
        error: _messageFromDio(error, fallback: 'Could not send OTP.'),
      );
    } catch (_) {
      return const OtpSendResult(
        success: false,
        error: 'Could not send OTP.',
      );
    }
  }

  Future<OtpVerifyResult> verifyOtp({
    required String phone,
    required String code,
    required String purpose,
  }) async {
    try {
      final response = await _authPost(
        ApiConstants.otpVerify,
        data: {'phone': phone, 'code': code.trim(), 'purpose': purpose},
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['verificationToken']?.toString() ?? '';
      if (token.isEmpty) {
        return const OtpVerifyResult(
          success: false,
          error: 'Verification failed. Try again.',
        );
      }
      return OtpVerifyResult(success: true, verificationToken: token);
    } on DioException catch (error) {
      return OtpVerifyResult(
        success: false,
        error: _messageFromDio(error, fallback: 'Incorrect or expired OTP.'),
      );
    } catch (_) {
      return const OtpVerifyResult(
        success: false,
        error: 'Incorrect or expired OTP.',
      );
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String phoneVerificationToken,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedPhone = phone.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedName.length < 2 ||
        trimmedPhone.length < 8 ||
        trimmedPassword.length < 8) {
      state = state.copyWith(
        error: 'Please fill all required fields (password at least 8 characters).',
      );
      return false;
    }

    if (phoneVerificationToken.isEmpty) {
      state = state.copyWith(error: 'Verify your phone number with OTP first.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = <String, dynamic>{
        'fullName': trimmedName,
        'phone': trimmedPhone,
        'password': trimmedPassword,
        'phoneVerificationToken': phoneVerificationToken,
      };
      if (trimmedEmail.isNotEmpty) {
        payload['email'] = trimmedEmail;
      }

      final response = await _authPost(ApiConstants.register, data: payload);
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromDio(
          error,
          fallback: 'Signup failed. Please try again.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Signup failed. Please try again.',
      );
      return false;
    }
  }

  Future<OtpSendResult> sendForgotPasswordOtp(String phone) {
    return sendOtp(phone: phone, purpose: 'reset_password');
  }

  Future<bool> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    if (newPassword.trim().length < 8) {
      state = state.copyWith(error: 'Password must be at least 8 characters.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authPost(
        ApiConstants.resetPassword,
        data: {
          'phone': phone.trim(),
          'code': code.trim(),
          'newPassword': newPassword.trim(),
        },
      );
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _messageFromDio(
          error,
          fallback: 'Could not reset password. Try again.',
        ),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not reset password. Try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(
        key: AuthTokenStorage.refreshTokenKey,
      );
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authPost(
          ApiConstants.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Always clear local session even if server logout fails.
    }
    await _clearStoredCredentials();
    state = AuthState(isInitializing: false);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _applyAuthResponse(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw StateError('Auth response missing token');
    }

    final refreshToken = data['refreshToken']?.toString();
    await AuthTokenStorage.saveTokens(
      access: token,
      refresh: refreshToken,
    );

    final user = UserModel.fromJson(data);
    state = state.copyWith(
      isInitializing: false,
      isLoading: false,
      token: token,
      user: user,
      error: null,
    );
  }

  Future<void> _clearStoredCredentials() async {
    await AuthTokenStorage.clear();
  }

  Future<Response<dynamic>> _authPost(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    _dio.options.baseUrl = NetworkManager.instance.currentBaseUrl;

    Future<Response<dynamic>> send() => _dio.post(
      path,
      data: data,
      options: Options(extra: const {'skipAuthRefresh': true}),
    );

    try {
      return await send();
    } on DioException catch (error) {
      if (!BackendUrlResolver.isConnectionError(error)) rethrow;
      await BackendUrlResolver.clearOverride();
      if (await NetworkManager.instance.recoverConnection()) {
        _dio.options.baseUrl = NetworkManager.instance.currentBaseUrl;
        return send();
      }
      rethrow;
    }
  }

  String _messageFromDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final message = data['message'].toString().trim();
      if (message.isNotEmpty) return message;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      final base = NetworkManager.instance.currentBaseUrl;
      return 'Request timed out. Check your connection and try again.\nServer: $base';
    }
    if (error.type == DioExceptionType.connectionError) {
      final base = NetworkManager.instance.currentBaseUrl;
      return 'Could not reach server at $base. Ensure backend is running and phone/PC use the same Wi‑Fi.';
    }
    return fallback;
  }
}
