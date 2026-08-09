import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
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
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _passwordVisible = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
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
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('emailInvalid'))),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();
    final result = await ref
        .read(authProvider.notifier)
        .sendForgotPasswordOtp(email);

    if (!mounted) return;

    if (!result.success) {
      if (result.allowEnterOtp) {
        setState(() => _otpSent = true);
        if (result.retryAfterSeconds != null) {
          _startResendTimer(result.retryAfterSeconds!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? l10n.t('otpSendCheckInbox')),
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

    setState(() => _otpSent = true);
    _startResendTimer(result.resendAfterSeconds);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('otpSent'))),
    );
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('emailInvalid'))),
      );
      return;
    }

    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('otpInvalid'))),
      );
      return;
    }

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
          email: email,
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
                      controller: _emailController,
                      hint: l10n.t('email'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: authState.isLoading ||
                                (_otpSent && _resendSeconds > 0)
                            ? null
                            : _sendOtp,
                        child: Text(
                          _otpSent
                              ? (_resendSeconds > 0
                                  ? l10n
                                      .t('resendOtpIn')
                                      .replaceAll('{seconds}', '$_resendSeconds')
                                  : l10n.t('resendOtp'))
                              : l10n.t('sendOtp'),
                        ),
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.t('otpEnterHint'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: AppTheme.textSecondary,
                        ),
                      ),
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
                          onPressed: authState.isLoading ? null : _resetPassword,
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
