import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/password_requirements_panel.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';
import 'package:suraksha_women_safety_app/features/auth/signup_verification_payload.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class SignupDetailsScreen extends ConsumerStatefulWidget {
  const SignupDetailsScreen({super.key, required this.payload});

  final SignupVerificationPayload payload;

  @override
  ConsumerState<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends ConsumerState<SignupDetailsScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _sensitiveConsent = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showPolicyDialog(String titleKey, String bodyKey) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t(titleKey)),
        content: SingleChildScrollView(child: Text(l10n.t(bodyKey))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('ok')),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (!_termsAccepted || !_privacyAccepted || !_sensitiveConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('signupConsentRequired'))),
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

    if (!PasswordStrength.evaluate(password).isAcceptable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('authPasswordRequirements'))),
      );
      return;
    }

    final ok = await ref.read(authProvider.notifier).register(
          fullName: widget.payload.fullName,
          phone: widget.payload.phone,
          email: widget.payload.email,
          password: password,
          emailVerificationToken: widget.payload.emailVerificationToken,
          termsAccepted: _termsAccepted,
          privacyAccepted: _privacyAccepted,
          sensitiveProcessingConsent: _sensitiveConsent,
        );
    if (ok && mounted) {
      TextInput.finishAutofillContext(shouldSave: true);
    }
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
                      l10n.t('signUpStep2of2'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      child: Text(
                        l10n.t('signUpCompleteProfile'),
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
                        l10n.t('signUpCompleteProfileSubtitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.greenAccent,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.payload.fullName,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.payload.phoneDisplay,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.payload.email,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: AuthTextField(
                        controller: _passwordController,
                        hint: l10n.t('password'),
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
                    ),
                    const SizedBox(height: 12),
                    PasswordRequirementsPanel(
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: AuthTextField(
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
                    ),
                    const SizedBox(height: 18),
                    CheckboxListTile(
                      value: _termsAccepted,
                      onChanged: authState.isLoading
                          ? null
                          : (value) => setState(() => _termsAccepted = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.t('signupAcceptTermsPrefix')),
                          GestureDetector(
                            onTap: () => _showPolicyDialog(
                              'signupTermsTitle',
                              'signupTermsBody',
                            ),
                            child: Text(
                              l10n.t('signupTermsLink'),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: _privacyAccepted,
                      onChanged: authState.isLoading
                          ? null
                          : (value) => setState(() => _privacyAccepted = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.t('signupAcceptPrivacyPrefix')),
                          GestureDetector(
                            onTap: () => _showPolicyDialog(
                              'signupPrivacyTitle',
                              'signupPrivacyBody',
                            ),
                            child: Text(
                              l10n.t('signupPrivacyLink'),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: _sensitiveConsent,
                      onChanged: authState.isLoading
                          ? null
                          : (value) => setState(() => _sensitiveConsent = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.t('signupSensitiveConsent')),
                      subtitle: Text(l10n.t('signupSensitiveConsentSubtitle')),
                    ),
                    const SizedBox(height: 12),
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
                      delay: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          child: authState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(l10n.t('signUp')),
                        ),
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
