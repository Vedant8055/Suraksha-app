import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/core/network/auth_interceptor.dart';
import 'package:suraksha_women_safety_app/core/network/auth_token_storage.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';
import 'package:suraksha_women_safety_app/core/storage/medical_vault_storage.dart';
import 'package:suraksha_women_safety_app/features/auth/device_identity.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cyber_vault_lock.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_complaint_draft_storage.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_session_cache.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';

const Object _unset = Object();

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  AuthInterceptor.onSessionInvalidated = () {
    unawaited(notifier.forceLocalSignOut());
  };
  return notifier..restoreSession();
});

class OtpSendResult {
  final bool success;
  final String? error;
  final int resendAfterSeconds;
  final int? retryAfterSeconds;

  /// When true, show the OTP entry field even if [success] is false
  /// (e.g. timeout after the server may already have emailed the code).
  final bool allowEnterOtp;

  const OtpSendResult({
    required this.success,
    this.error,
    this.resendAfterSeconds = 60,
    this.retryAfterSeconds,
    this.allowEnterOtp = false,
  });
}

class OtpVerifyResult {
  final bool success;
  final String? verificationToken;
  final String? error;
  final int? retryAfterSeconds;

  const OtpVerifyResult({
    required this.success,
    this.verificationToken,
    this.error,
    this.retryAfterSeconds,
  });
}

class AuthSessionInfo {
  final String id;
  final String? deviceId;
  final String? platform;
  final String? deviceLabel;
  final DateTime? lastActiveAt;
  final DateTime? createdAt;
  final bool isCurrent;

  const AuthSessionInfo({
    required this.id,
    this.deviceId,
    this.platform,
    this.deviceLabel,
    this.lastActiveAt,
    this.createdAt,
    required this.isCurrent,
  });

  factory AuthSessionInfo.fromJson(Map<String, dynamic> json) {
    return AuthSessionInfo(
      id: json['id']?.toString() ?? '',
      deviceId: json['deviceId']?.toString(),
      platform: json['platform']?.toString(),
      deviceLabel: json['deviceLabel']?.toString(),
      lastActiveAt: DateTime.tryParse(json['lastActiveAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      isCurrent: json['isCurrent'] == true,
    );
  }
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

  Future<Map<String, String>> _devicePayload() async {
    return {
      'deviceId': await DeviceIdentity.deviceId(),
      'platform': DeviceIdentity.platformLabel(),
      'deviceLabel': await DeviceIdentity.deviceLabel(),
    };
  }

  Future<void> restoreSession() async {
    try {
      final token = await _storage.read(key: AuthTokenStorage.tokenKey);
      if (token == null || token.isEmpty) {
        state = state.copyWith(isInitializing: false, token: null, user: null);
        return;
      }

      // Show the cached profile immediately (if any) so the UI doesn't sit
      // on a splash/loading state while the network profile fetch runs.
      // The network fetch below still refreshes `user` in the background.
      final cachedUser = await ProfileSessionCache.readUser();
      if (cachedUser != null) {
        state = state.copyWith(
          isInitializing: false,
          token: token,
          user: cachedUser,
          error: null,
        );
      } else {
        state = state.copyWith(isInitializing: true, token: token, error: null);
      }

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
      await ProfileSessionCache.syncFromUser(user);
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
            await ProfileSessionCache.syncFromUser(user);
            return;
          } catch (_) {
            // fall through to clear only on hard auth failure
          }
        }
        await forceLocalSignOut();
        return;
      }
      // Network/server errors: keep tokens and cached profile; retry later.
      final cached = await ProfileSessionCache.readUser();
      state = state.copyWith(
        isInitializing: false,
        token: await _storage.read(key: AuthTokenStorage.tokenKey),
        user: cached ?? state.user,
        error: null,
      );
    } on TimeoutException catch (_) {
      final cached = await ProfileSessionCache.readUser();
      state = state.copyWith(
        isInitializing: false,
        token: await _storage.read(key: AuthTokenStorage.tokenKey),
        user: cached ?? state.user,
        error: null,
      );
    } catch (_) {
      final cached = await ProfileSessionCache.readUser();
      state = state.copyWith(
        isInitializing: false,
        token: await _storage.read(key: AuthTokenStorage.tokenKey),
        user: cached ?? state.user,
        error: null,
      );
    }
  }

  /// Clears local auth state after interceptor/session invalidation.
  Future<void> forceLocalSignOut() async {
    final userId = state.user?.id;
    await ProfileSessionCache.clearAll(userId: userId);
    if (userId != null && userId.isNotEmpty) {
      await MedicalVaultStorage.clearForUser(userId);
    }
    await PoshComplaintDraftStorage().clear();
    await CyberVaultLock().disable();
    await _clearStoredCredentials();
    state = AuthState(isInitializing: false);
  }

  Future<UserModel> _fetchProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> _localized(
    String key, {
    Map<String, String> params = const {},
  }) async {
    final l10n = await AppLocalizations.current();
    return applyL10nParams(l10n.t(key), params);
  }

  Future<bool> login(String identifier, String password) async {
    final trimmedId = identifier.trim();
    final normalizedPhone = IndianPhoneUtils.forApi(trimmedId);
    final loginIdentifier = normalizedPhone.length == 10 ? normalizedPhone : trimmedId;
    // Do not trim password — trailing/leading spaces may be intentional.
    if (loginIdentifier.isEmpty || password.isEmpty) {
      state = state.copyWith(
        error: await _localized('authEnterEmailPhonePassword'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authPost(
        ApiConstants.login,
        data: {
          'identifier': loginIdentifier,
          'password': password,
          ...(await _devicePayload()),
        },
      );
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      TextInput.finishAutofillContext(shouldSave: true);
      unawaited(AppActivityLog.instance.record('login_success'));
      return true;
    } on DioException catch (error) {
      unawaited(AppActivityLog.instance.record('login_failed'));
      state = state.copyWith(
        isLoading: false,
        error: (await _messageFromDio(error, fallbackKey: 'authLoginFailed')).message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: await _localized('authLoginFailed'),
      );
      return false;
    }
  }

  Future<OtpSendResult> sendOtp({
    required String email,
    required String purpose,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'purpose': purpose,
      };
      final trimmedPhone = phone?.trim() ?? '';
      if (trimmedPhone.isNotEmpty) {
        data['phone'] = trimmedPhone;
      }
      final response = await _authPost(
        ApiConstants.otpSend,
        data: data,
      );
      final body = response.data as Map<String, dynamic>;
      // Backend anti-enumeration returns 200 with dispatched:false when the
      // email is ineligible (e.g. already registered for signup).
      final dispatched = body.containsKey('dispatched')
          ? body['dispatched'] == true
          : true;
      if (!dispatched) {
        final errorKey = purpose == 'register'
            ? 'otpEmailAlreadyRegistered'
            : purpose == 'reset_password'
                ? 'otpEmailNotRegistered'
                : 'otpEmailUnavailable';
        return OtpSendResult(
          success: false,
          allowEnterOtp: false,
          error: await _localized(errorKey),
          resendAfterSeconds:
              (body['resendAfterSeconds'] as num?)?.toInt() ?? 60,
        );
      }
      return OtpSendResult(
        success: true,
        allowEnterOtp: true,
        resendAfterSeconds: (body['resendAfterSeconds'] as num?)?.toInt() ?? 60,
      );
    } on DioException catch (error) {
      final parsed = await _messageFromDio(
        error,
        fallbackKey: 'otpSendFailed',
      );
      final softFailure = _isOtpSendSoftFailure(error);
      return OtpSendResult(
        success: false,
        allowEnterOtp: softFailure,
        error: softFailure
            ? await _localized('otpSendCheckInbox')
            : parsed.message,
        retryAfterSeconds: parsed.retryAfterSeconds,
        resendAfterSeconds: parsed.retryAfterSeconds ?? 60,
      );
    } catch (_) {
      return OtpSendResult(
        success: false,
        allowEnterOtp: true,
        error: await _localized('otpSendCheckInbox'),
      );
    }
  }

  bool _isOtpSendSoftFailure(DioException error) {
    if (BackendUrlResolver.isConnectionError(error)) return true;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        break;
    }
    // Rate-limited: a previous send may already have delivered the email.
    if (error.response?.statusCode == 429) return true;
    return false;
  }

  Future<OtpVerifyResult> verifyOtp({
    required String email,
    required String code,
    required String purpose,
  }) async {
    try {
      final path = purpose == 'change_email'
          ? ApiConstants.profileEmailVerifyChange
          : ApiConstants.otpVerify;
      final payload = purpose == 'change_email'
          ? {
              'email': email.trim().toLowerCase(),
              'code': code.trim(),
            }
          : {
              'email': email.trim().toLowerCase(),
              'code': code.trim(),
              'purpose': purpose,
            };
      final response = await _authPost(path, data: payload);
      final data = response.data as Map<String, dynamic>;
      final token = data['verificationToken']?.toString() ?? '';
      if (token.isEmpty) {
        return OtpVerifyResult(
          success: false,
          error: await _localized('authVerificationFailed'),
        );
      }
      return OtpVerifyResult(success: true, verificationToken: token);
    } on DioException catch (error) {
      final parsed = await _messageFromDio(error, fallbackKey: 'otpInvalid');
      return OtpVerifyResult(
        success: false,
        error: parsed.message,
        retryAfterSeconds: parsed.retryAfterSeconds,
      );
    } catch (_) {
      return OtpVerifyResult(
        success: false,
        error: await _localized('otpInvalid'),
      );
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String emailVerificationToken,
    required bool termsAccepted,
    required bool privacyAccepted,
    required bool sensitiveProcessingConsent,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedPhone = phone.trim();
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedName.length < 2 ||
        trimmedPhone.length < 8 ||
        trimmedEmail.isEmpty ||
        !termsAccepted ||
        !privacyAccepted ||
        !sensitiveProcessingConsent) {
      state = state.copyWith(
        error: await _localized('authFillRequiredFields'),
      );
      return false;
    }

    final strength = PasswordStrength.evaluate(password);
    if (!strength.isAcceptable) {
      state = state.copyWith(error: await _localized('authPasswordRequirements'));
      return false;
    }

    if (emailVerificationToken.isEmpty) {
      state = state.copyWith(error: await _localized('verifyEmailFirst'));
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = <String, dynamic>{
        'fullName': trimmedName,
        'phone': trimmedPhone,
        'email': trimmedEmail,
        'password': password,
        'emailVerificationToken': emailVerificationToken,
        'termsAccepted': true,
        'privacyAccepted': true,
        'sensitiveProcessingConsent': sensitiveProcessingConsent,
        ...(await _devicePayload()),
      };

      final response = await _authPost(ApiConstants.register, data: payload);
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      TextInput.finishAutofillContext(shouldSave: true);
      unawaited(AppActivityLog.instance.record('signup_success'));
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: (await _messageFromDio(error, fallbackKey: 'authSignupFailed')).message,
      );
      unawaited(AppActivityLog.instance.record('signup_failed'));
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: await _localized('authSignupFailed'),
      );
      return false;
    }
  }

  Future<OtpSendResult> sendForgotPasswordOtp(String email) async {
    // Forgot-password must not soft-fail like signup: timeouts must not pretend
    // an OTP was emailed.
    try {
      final response = await _authPost(
        ApiConstants.otpSend,
        data: {
          'email': email.trim().toLowerCase(),
          'purpose': 'reset_password',
        },
      );
      final body = response.data as Map<String, dynamic>;
      // Older backends omit `dispatched`; treat missing as true for compatibility.
      final dispatched = body.containsKey('dispatched')
          ? body['dispatched'] == true
          : true;
      return OtpSendResult(
        success: dispatched,
        allowEnterOtp: dispatched,
        error: dispatched ? null : await _localized('otpEmailNotRegistered'),
        resendAfterSeconds: (body['resendAfterSeconds'] as num?)?.toInt() ?? 60,
      );
    } on DioException catch (error) {
      final parsed = await _messageFromDio(
        error,
        fallbackKey: 'otpSendFailed',
      );
      // Only rate-limit keeps the OTP field open (a prior send may have worked).
      final allowEnter = error.response?.statusCode == 429;
      return OtpSendResult(
        success: false,
        allowEnterOtp: allowEnter,
        error: parsed.message,
        retryAfterSeconds: parsed.retryAfterSeconds,
        resendAfterSeconds: parsed.retryAfterSeconds ?? 60,
      );
    } catch (_) {
      return OtpSendResult(
        success: false,
        allowEnterOtp: false,
        error: await _localized('otpSendFailed'),
      );
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final strength = PasswordStrength.evaluate(newPassword);
    if (!strength.isAcceptable) {
      state = state.copyWith(error: await _localized('authPasswordRequirements'));
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authPost(
        ApiConstants.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
          'newPassword': newPassword,
        },
      );
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      TextInput.finishAutofillContext(shouldSave: true);
      return true;
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: (await _messageFromDio(
          error,
          fallbackKey: 'authResetPasswordFailed',
        )).message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: await _localized('authResetPasswordFailed'),
      );
      return false;
    }
  }

  Future<List<AuthSessionInfo>> fetchSessions() async {
    final deviceId = await DeviceIdentity.deviceId();
    final response = await _dio.get(
      ApiConstants.authSessions,
      queryParameters: {'currentDeviceId': deviceId},
    );
    final data = response.data as Map<String, dynamic>;
    final sessions = (data['sessions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AuthSessionInfo.fromJson)
        .toList(growable: false);
    return sessions;
  }

  Future<void> revokeSession(String sessionId) async {
    final deviceId = await DeviceIdentity.deviceId();
    await _dio.delete(
      '${ApiConstants.authSessions}/$sessionId',
      data: {'currentDeviceId': deviceId},
    );
  }

  Future<int> revokeOtherSessions() async {
    final deviceId = await DeviceIdentity.deviceId();
    final response = await _dio.post(
      ApiConstants.authSessionsRevokeOthers,
      data: {'currentDeviceId': deviceId},
    );
    return (response.data['revokedCount'] as num?)?.toInt() ?? 0;
  }

  Future<int> revokeAllSessions() async {
    final response = await _dio.post(ApiConstants.authSessionsRevokeAll);
    return (response.data['revokedCount'] as num?)?.toInt() ?? 0;
  }

  Future<Map<String, dynamic>> exportAccountData({required String password}) async {
    final response = await _dio.post(
      ApiConstants.profileExport,
      data: {'password': password},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
  }

  Future<void> deleteLocationData({required String password}) async {
    await _dio.delete(
      ApiConstants.profileDeleteLocation,
      data: {'password': password},
    );
  }

  Future<void> deleteMedicalData({required String password}) async {
    await _dio.delete(
      ApiConstants.profileDeleteMedical,
      data: {'password': password},
    );
  }

  Future<void> deleteIncidentData({required String password}) async {
    await _dio.delete(
      ApiConstants.profileDeleteIncidents,
      data: {'password': password},
    );
  }

  Future<void> deleteEvidenceData({required String password}) async {
    await _dio.delete(
      ApiConstants.profileDeleteEvidence,
      data: {'password': password},
    );
  }

  Future<void> deleteAccount({required String password}) async {
    await _dio.delete(
      ApiConstants.profileDeleteAccount,
      data: {'confirmText': 'DELETE', 'password': password},
    );
    await logout();
  }

  Future<OtpSendResult> requestEmailChange({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.profileEmailRequestChange,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      final data = response.data;
      if (data is Map && data['unchanged'] == true) {
        return const OtpSendResult(
          success: true,
          allowEnterOtp: true,
          resendAfterSeconds: 0,
        );
      }
      final resend = (data is Map ? data['resendAfterSeconds'] as num? : null)?.toInt() ?? 60;
      return OtpSendResult(
        success: true,
        allowEnterOtp: true,
        resendAfterSeconds: resend,
      );
    } on DioException catch (error) {
      final soft = _isOtpSendSoftFailure(error);
      return OtpSendResult(
        success: false,
        allowEnterOtp: soft,
        error: soft
            ? await _localized('otpSendCheckInbox')
            : (await _messageFromDio(error, fallbackKey: 'otpSendFailed')).message,
      );
    } catch (_) {
      return OtpSendResult(
        success: false,
        allowEnterOtp: true,
        error: await _localized('otpSendCheckInbox'),
      );
    }
  }

  Future<void> logout() async {
    unawaited(AppActivityLog.instance.record('logout'));
    final userId = state.user?.id;
    final refreshToken = await _storage.read(
      key: AuthTokenStorage.refreshTokenKey,
    );

    await ProfileSessionCache.clearAll(userId: userId);
    if (userId != null && userId.isNotEmpty) {
      await MedicalVaultStorage.clearForUser(userId);
    }
    await PoshComplaintDraftStorage().clear();
    await CyberVaultLock().disable();
    await _clearStoredCredentials();
    state = AuthState(isInitializing: false);

    if (refreshToken == null || refreshToken.isEmpty) return;

    try {
      await _authPost(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      ).timeout(const Duration(seconds: 12));
    } catch (_) {}
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
    await ProfileSessionCache.syncFromUser(user);
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
    // Wake sleeping Render dyno before auth — avoids connect timeouts on login.
    await NetworkManager.instance.wakeBackendForAuth();

    Future<Response<dynamic>> send() => _dio.post(
      path,
      data: data,
      options: Options(
        extra: const {'skipAuthRefresh': true},
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 75),
      ),
    );

    bool isTimeout(Object error) =>
        error is TimeoutException ||
        (error is DioException &&
            (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout));

    try {
      return await send().timeout(const Duration(seconds: 90));
    } on DioException catch (error) {
      if (isTimeout(error) || BackendUrlResolver.isConnectionError(error)) {
        await NetworkManager.instance.wakeBackendForAuth(force: true);
        await BackendUrlResolver.clearOverride();
        if (await NetworkManager.instance.recoverConnection() ||
            isTimeout(error)) {
          _dio.options.baseUrl = NetworkManager.instance.currentBaseUrl;
          return send().timeout(const Duration(seconds: 90));
        }
      }
      rethrow;
    } on TimeoutException {
      await NetworkManager.instance.wakeBackendForAuth(force: true);
      try {
        return await send().timeout(const Duration(seconds: 90));
      } on TimeoutException {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.receiveTimeout,
        );
      }
    }
  }

  Future<_AuthMessage> _messageFromDio(
    DioException error, {
    required String fallbackKey,
  }) async {
    final data = error.response?.data;
    var message = '';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString().trim();
    }

    final retryAfterSeconds = _retryAfterSeconds(error, message);

    if (message.isNotEmpty) {
      message = _sanitizeAuthMessage(message);
      if (retryAfterSeconds != null) {
        message = await _localized(
          'authRetryAfterSeconds',
          params: {'seconds': '$retryAfterSeconds', 'message': message},
        );
      }
      return _AuthMessage(message: message, retryAfterSeconds: retryAfterSeconds);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return _AuthMessage(
        message: await _localized('authRequestTimedOut'),
      );
    }
    if (error.response?.statusCode == 503) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['code'] == 'DATABASE_UNAVAILABLE') {
        return _AuthMessage(message: await _localized('authDatabaseUnavailable'));
      }
    }
    if (error.response?.statusCode == 429) {
      final seconds = retryAfterSeconds ?? 60;
      return _AuthMessage(
        message: await _localized('authTooManyRequests', params: {'seconds': '$seconds'}),
        retryAfterSeconds: seconds,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return _AuthMessage(
        message: await _localized('authCouldNotReachServer'),
      );
    }
    return _AuthMessage(message: await _localized(fallbackKey));
  }

  int? _retryAfterSeconds(DioException error, String message) {
    final header = error.response?.headers.value('retry-after');
    if (header != null) {
      final parsed = int.tryParse(header);
      if (parsed != null) return parsed;
    }

    final waitMatch = RegExp(r'wait (\d+)s', caseSensitive: false).firstMatch(message);
    if (waitMatch != null) {
      return int.tryParse(waitMatch.group(1)!);
    }
    return null;
  }

  String _sanitizeAuthMessage(String message) {
    final lower = message.toLowerCase();
    // Keep actionable register/login conflict copy from the API.
    if (lower.contains('already exists') ||
        lower.contains('already registered') ||
        lower.contains('please sign in')) {
      return message;
    }
    if (lower.contains('no account found')) {
      return 'If this number is eligible, follow the on-screen steps or try signing in.';
    }
    return message;
  }
}

class _AuthMessage {
  const _AuthMessage({required this.message, this.retryAfterSeconds});

  final String message;
  final int? retryAfterSeconds;
}
