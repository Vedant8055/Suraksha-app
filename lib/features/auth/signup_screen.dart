import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/features/auth/signup_details_screen.dart';
import 'package:suraksha_women_safety_app/features/auth/signup_verification_payload.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isVerifying = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
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

  void _resetOtpState() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final phone = IndianPhoneUtils.forApi(_phoneController.text);

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('emailInvalid'))),
      );
      return;
    }
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('phoneNumberInvalid'))),
      );
      return;
    }

    _resetOtpState();
    ref.read(authProvider.notifier).clearError();

    final result = await ref.read(authProvider.notifier).sendOtp(
          email: email,
          purpose: 'register',
        );

    if (!mounted) return;
    if (!result.success) {
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

  Future<void> _verifyOtpAndContinue() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = IndianPhoneUtils.forApi(_phoneController.text);
    final phoneDisplay = IndianPhoneUtils.formatDisplay(_phoneController.text);

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('fullNameRequired'))),
      );
      return;
    }

    if (!_isValidEmail(email) ||
        phone.length != 10 ||
        _otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('otpInvalid'))),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final result = await ref.read(authProvider.notifier).verifyOtp(
          email: email,
          code: _otpController.text.trim(),
          purpose: 'register',
        );
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (!result.success || result.verificationToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? l10n.t('otpInvalid'))),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignupDetailsScreen(
          payload: SignupVerificationPayload(
            fullName: name,
            phone: phone,
            phoneDisplay: phoneDisplay,
            email: email,
            emailVerificationToken: result.verificationToken!,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final busy = authState.isLoading || _isVerifying;

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
                      onPressed: busy ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.t('signUpStep1of2'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      child: Text(
                        l10n.t('signUpVerifyEmail'),
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
                        l10n.t('signUpVerifyEmailSubtitle'),
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
                        autofillHints: const [AutofillHints.name],
                        enabled: !busy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 350),
                      child: AuthTextField(
                        controller: _emailController,
                        hint: l10n.t('email'),
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        enabled: !busy,
                        onChanged: (_) => _resetOtpState(),
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
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [IndianPhoneInputFormatter()],
                        enabled: !busy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: busy || (_otpSent && _resendSeconds > 0)
                              ? null
                              : _sendOtp,
                          icon: const Icon(Icons.mark_email_unread_outlined, size: 20),
                          label: Text(
                            _otpSent
                                ? (_resendSeconds > 0
                                    ? l10n.t('resendOtpIn').replaceAll(
                                        '{seconds}',
                                        '$_resendSeconds',
                                      )
                                    : l10n.t('resendOtp'))
                                : l10n.t('sendOtp'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white70,
                            elevation: 2,
                            shadowColor:
                                AppTheme.primaryColor.withValues(alpha: 0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_otpSent) ...[
                      const SizedBox(height: 16),
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
                        enabled: !busy,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: busy ? null : _verifyOtpAndContinue,
                          child: _isVerifying
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(l10n.t('continueToAccountDetails')),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed:
                            busy ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: Text(l10n.t('alreadyHaveAccount')),
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
