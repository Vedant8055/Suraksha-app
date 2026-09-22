import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/features/auth/password_requirements_panel.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _passwordVisible = false;
  bool _usedPhone = false;
  String? _maskedEmail;
  String? _phoneHint;
  String? _channel;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _identifierController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  /// Returns ('email'|'phone'|null, normalized value).
  (String?, String) _parseIdentifier(String raw) {
    final trimmed = raw.trim();
    if (_isValidEmail(trimmed)) {
      return ('email', trimmed.toLowerCase());
    }
    final phone = IndianPhoneUtils.forApi(trimmed);
    if (phone.length == 10) {
      return ('phone', phone);
    }
    return (null, trimmed);
  }

  void _startResendTimer([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final (kind, value) = _parseIdentifier(_identifierController.text);
    if (kind == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('emailOrPhoneInvalid'))),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();
    setState(() => _isSendingOtp = true);
    final result = await ref.read(authProvider.notifier).sendForgotPasswordOtp(
          email: kind == 'email' ? value : null,
          phone: kind == 'phone' ? value : null,
        );

    if (!mounted) return;
    setState(() => _isSendingOtp = false);

    if (!result.success) {
      if (result.allowEnterOtp) {
        setState(() {
          _otpSent = true;
          _usedPhone = kind == 'phone';
          _maskedEmail = result.maskedEmail;
          _phoneHint = result.phoneHint;
          _channel = result.channel;
        });
        if (result.retryAfterSeconds != null) {
          _startResendTimer(result.retryAfterSeconds!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? l10n.t('otpSendFailed')),
          ),
        );
        return;
      }
      if (result.retryAfterSeconds != null) {
        _startResendTimer(result.retryAfterSeconds!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? l10n.t('otpSendFailed'))),
      );
      return;
    }

    setState(() {
      _otpSent = true;
      _usedPhone = kind == 'phone';
      _maskedEmail = result.maskedEmail;
      _phoneHint = result.phoneHint;
      _channel = result.channel;
    });
    _startResendTimer(result.resendAfterSeconds);

    final destination = _deliveryHint(l10n);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(destination),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  String _deliveryHint(AppLocalizations l10n) {
    final channel = _channel ?? '';
    if (channel == 'sms' && _phoneHint != null) {
      return l10n.t('otpSentToPhone').replaceAll('{phone}', _phoneHint!);
    }
    if (channel == 'both') {
      final emailPart = _maskedEmail ?? l10n.t('email').toLowerCase();
      final phonePart = _phoneHint ?? l10n.t('phoneNumber').toLowerCase();
      return l10n
          .t('otpSentToPhoneAndEmail')
          .replaceAll('{phone}', phonePart)
          .replaceAll('{email}', emailPart);
    }
    if (_maskedEmail != null) {
      return l10n.t('otpSentToEmail').replaceAll('{email}', _maskedEmail!);
    }
    final (kind, value) = _parseIdentifier(_identifierController.text);
    if (kind == 'email') {
      return l10n.t('otpSentToEmail').replaceAll('{email}', value);
    }
    return l10n.t('otpSentCheckSmsOrEmail');
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final (kind, value) = _parseIdentifier(_identifierController.text);
    if (kind == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('emailOrPhoneInvalid'))),
      );
      return;
    }

    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('otpInvalid'))),
      );
      return;
    }

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('passwordsDoNotMatch'))),
      );
      return;
    }

    if (!PasswordStrength.evaluate(password).isAcceptable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('authPasswordRequirements'))),
      );
      return;
    }

    final ok = await ref.read(authProvider.notifier).resetPassword(
          email: kind == 'email' ? value : null,
          phone: kind == 'phone' ? value : null,
          code: _otpController.text.trim(),
          newPassword: password,
        );

    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('passwordResetSuccess'))),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final phoneMode = IndianPhoneUtils.forApi(_identifierController.text).length >= 3 &&
        !_isValidEmail(_identifierController.text.trim());

    return AuthScreenShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AutofillGroup(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('forgotPasswordTitle'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('forgotPasswordSubtitle'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthTextField(
                      controller: _identifierController,
                      hint: l10n.t('emailOrPhone'),
                      icon: phoneMode
                          ? Icons.phone_outlined
                          : Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.telephoneNumber,
                        AutofillHints.username,
                      ],
                      enabled: !authState.isLoading && !_isSendingOtp,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: authState.isLoading ||
                                _isSendingOtp ||
                                (_otpSent && _resendSeconds > 0)
                            ? null
                            : _sendOtp,
                        child: _isSendingOtp
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      l10n.t('otpSendingWait'),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _otpSent
                                    ? (_resendSeconds > 0
                                        ? l10n.t('resendOtpIn').replaceAll(
                                            '{seconds}',
                                            '$_resendSeconds',
                                          )
                                        : l10n.t('resendOtp'))
                                    : l10n.t('sendOtp'),
                              ),
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 12),
                      Text(
                        _usedPhone
                            ? l10n.t('otpEnterHintRecovery')
                            : l10n.t('otpEnterHintSpam'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (_maskedEmail != null || _phoneHint != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (_phoneHint != null)
                              l10n
                                  .t('recoveryPhoneHint')
                                  .replaceAll('{phone}', _phoneHint!),
                            if (_maskedEmail != null)
                              l10n
                                  .t('recoveryEmailHint')
                                  .replaceAll('{email}', _maskedEmail!),
                          ].join('\n'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.35,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _otpController,
                        hint: l10n.t('enterOtp'),
                        icon: Icons.password_outlined,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        enabled: !authState.isLoading,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        hint: l10n.t('newPassword'),
                        icon: Icons.lock_outline,
                        isPassword: true,
                        passwordVisible: _passwordVisible,
                        showPasswordToggle: true,
                        onTogglePasswordVisibility: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !authState.isLoading,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      PasswordRequirementsPanel(
                        password: _passwordController.text,
                        confirmPassword: _confirmPasswordController.text,
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hint: l10n.t('confirmPassword'),
                        icon: Icons.lock_outline,
                        isPassword: true,
                        passwordVisible: _passwordVisible,
                        showPasswordToggle: true,
                        onTogglePasswordVisibility: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !authState.isLoading,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (authState.error != null) ...[
                      Text(
                        authState.error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_otpSent)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authState.isLoading ? null : _resetPassword,
                          child: authState.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(l10n.t('resetPassword')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
