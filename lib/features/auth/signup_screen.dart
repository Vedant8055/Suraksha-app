import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _phoneVerified = false;
  bool _otpSent = false;
  String? _phoneVerificationToken;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  void _togglePasswordVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
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

  void _resetPhoneVerification() {
    setState(() {
      _phoneVerified = false;
      _otpSent = false;
      _phoneVerificationToken = null;
      _otpController.clear();
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

    _resetPhoneVerification();
    ref.read(authProvider.notifier).clearError();

    final result = await ref.read(authProvider.notifier).sendOtp(
          phone: phone,
          purpose: 'register',
        );

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

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    final phone = IndianPhoneUtils.forApi(_phoneController.text);
    if (phone.length != 10 || _otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('otpInvalid'))),
      );
      return;
    }

    final result = await ref.read(authProvider.notifier).verifyOtp(
          phone: phone,
          code: _otpController.text.trim(),
          purpose: 'register',
        );

    if (!mounted) return;
    if (!result.success || result.verificationToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? l10n.t('otpInvalid'))),
      );
      return;
    }

    setState(() {
      _phoneVerified = true;
      _phoneVerificationToken = result.verificationToken;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('phoneVerified'))),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final phone = IndianPhoneUtils.forApi(_phoneController.text);

    if (!_phoneVerified || _phoneVerificationToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('verifyPhoneFirst'))),
      );
      return;
    }

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('phoneNumberInvalid'))),
      );
      return;
    }

    if (password != confirm) {
      ref.read(authProvider.notifier).clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('passwordsDoNotMatch'))),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          fullName: _nameController.text,
          phone: phone,
          email: _emailController.text,
          password: password,
          phoneVerificationToken: _phoneVerificationToken!,
        );
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
                  FadeInDown(
                    child: Text(
                      l10n.t('createAccount'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      l10n.t('signUpToContinue'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: AuthTextField(
                      controller: _nameController,
                      hint: l10n.t('fullName'),
                      icon: Icons.person_outline,
                      enabled: !authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: AuthTextField(
                      controller: _phoneController,
                      hint: l10n.t('phoneNumber'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [IndianPhoneInputFormatter()],
                      enabled: !authState.isLoading && !_phoneVerified,
                      onChanged: (_) => _resetPhoneVerification(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: authState.isLoading ||
                                  _phoneVerified ||
                                  (_otpSent && _resendSeconds > 0)
                              ? null
                              : _sendOtp,
                          child: Text(
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
                      if (_otpSent && !_phoneVerified) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _verifyOtp,
                            child: Text(l10n.t('verifyOtp')),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_otpSent && !_phoneVerified) ...[
                    const SizedBox(height: 12),
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
                  ],
                  if (_phoneVerified) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.t('phoneVerified'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: AuthTextField(
                      controller: _emailController,
                      hint: l10n.t('emailOptional'),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: AuthTextField(
                      controller: _passwordController,
                      hint: l10n.t('password'),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: _passwordVisible,
                      showPasswordToggle: true,
                      onTogglePasswordVisibility: _togglePasswordVisibility,
                      enabled: !authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: AuthTextField(
                      controller: _confirmPasswordController,
                      hint: l10n.t('confirmPassword'),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      passwordVisible: _passwordVisible,
                      showPasswordToggle: true,
                      onTogglePasswordVisibility: _togglePasswordVisibility,
                      enabled: !authState.isLoading,
                    ),
                  ),
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
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading || !_phoneVerified
                            ? null
                            : _submit,
                        child: authState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(l10n.t('signUp')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(l10n.t('alreadyHaveAccount')),
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
