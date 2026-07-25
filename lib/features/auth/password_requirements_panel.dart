import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class PasswordRequirementsPanel extends StatelessWidget {
  const PasswordRequirementsPanel({
    super.key,
    required this.password,
    this.confirmPassword,
  });

  final String password;
  final String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = PasswordStrength.evaluate(password);
    final tone = switch (result.level) {
      PasswordStrengthLevel.weak => Colors.redAccent,
      PasswordStrengthLevel.fair => const Color(0xFFF59E0B),
      PasswordStrengthLevel.good => const Color(0xFF2563EB),
      PasswordStrengthLevel.strong => const Color(0xFF15803D),
    };

    final requirements = [
      _Requirement(
        keyName: 'passwordReqMinLength',
        met: password.length >= PasswordStrength.minLength,
      ),
      _Requirement(
        keyName: 'passwordReqLetter',
        met: RegExp(r'[A-Za-z]').hasMatch(password),
      ),
      _Requirement(
        keyName: 'passwordReqNumber',
        met: RegExp(r'\d').hasMatch(password),
      ),
    ];

    final confirmMismatch = confirmPassword != null &&
        confirmPassword!.isNotEmpty &&
        password != confirmPassword;

    return Semantics(
      label: l10n.t(PasswordStrength.levelLabelKey(result.level)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: result.score,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              color: tone,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t(PasswordStrength.levelLabelKey(result.level)),
            style: TextStyle(
              color: tone,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final req in requirements)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    req.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    size: 14,
                    color: req.met ? const Color(0xFF15803D) : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.t(req.keyName),
                      style: TextStyle(
                        color: req.met ? Colors.white70 : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (confirmPassword != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  !confirmMismatch && confirmPassword!.isNotEmpty
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 14,
                  color: !confirmMismatch && confirmPassword!.isNotEmpty
                      ? const Color(0xFF15803D)
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    confirmMismatch
                        ? l10n.t('passwordsDoNotMatch')
                        : l10n.t('passwordReqConfirmMatch'),
                    style: TextStyle(
                      color: confirmMismatch
                          ? Colors.redAccent
                          : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Requirement {
  const _Requirement({required this.keyName, required this.met});

  final String keyName;
  final bool met;
}
