import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
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
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
    final phone = IndianPhoneUtils.forApi(_phoneController.text);
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('phoneNumberInvalid'))),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();
    final result = await ref
        .read(authProvider.notifier)
        .sendForgotPasswordOtp(phone);

    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? l10n.t('otpSendFailed'))),
      );
      return;
    }

    setState(() => _otpSent = true);
    _startResendTimer(result.resendAfterSeconds);

    var message = l10n.t('otpSent');
    if (result.devCode != null && result.devCode!.isNotEmpty) {
      message = '${l10n.t('otpSent')} (dev: ${result.devCode})';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final phone = IndianPhoneUtils.forApi(_phoneController.text);
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('phoneNumberInvalid'))),
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

    final ok = await ref.read(authProvider.notifier).resetPassword(
          phone: phone,
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
          return SingleChildScrollView(
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
                    controller: _phoneController,
                    hint: l10n.t('phoneNumber'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [IndianPhoneInputFormatter()],
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
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _otpController,
                      hint: l10n.t('enterOtp'),
                      icon: Icons.sms_outlined,
                      keyboardType: TextInputType.number,
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
                      enabled: !authState.isLoading,
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
                      enabled: !authState.isLoading,
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
          );
        },
      ),
    );
  }
}
