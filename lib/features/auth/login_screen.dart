import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_screen_shell.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_text_field.dart';
import 'package:suraksha_women_safety_app/features/auth/forgot_password_screen.dart';
import 'package:suraksha_women_safety_app/features/auth/signup_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref.read(authProvider.notifier).login(
          _identifierController.text,
          _passwordController.text,
        );
    if (ok && mounted) {
      TextInput.finishAutofillContext(shouldSave: true);
    }
  }

  void _openForgotPassword() {
    ref.read(authProvider.notifier).clearError();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _openSignup() {
    if (ref.read(authProvider).isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('logoutBeforeNewSignup')),
        ),
      );
      return;
    }
    ref.read(authProvider.notifier).clearError();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return AuthScreenShell(
      child: AutofillGroup(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  l10n.t('welcomeBack'),
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
                  l10n.t('signInToContinue'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: AuthTextField(
                  controller: _identifierController,
                  hint: l10n.t('emailOrPhone'),
                  icon: Icons.person_outline,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.telephoneNumber,
                    AutofillHints.email,
                  ],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                  onTogglePasswordVisibility: () {
                    setState(() => _passwordVisible = !_passwordVisible);
                  },
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authState.isLoading ? null : _openForgotPassword,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(l10n.t('forgotPassword')),
                ),
              ),
              const SizedBox(height: 20),
              if (authState.error != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.t('login')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: authState.isLoading ? null : _openSignup,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(l10n.t('dontHaveAccount')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
