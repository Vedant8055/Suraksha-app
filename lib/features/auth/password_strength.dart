enum PasswordStrengthLevel { weak, fair, good, strong }

class PasswordStrengthResult {
  final PasswordStrengthLevel level;
  final double score;
  final List<String> unmetRequirementKeys;

  const PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.unmetRequirementKeys,
  });

  bool get isAcceptable => unmetRequirementKeys.isEmpty;
}

class PasswordStrength {
  const PasswordStrength._();

  static const minLength = 8;

  static PasswordStrengthResult evaluate(String password) {
    final value = password;
    final unmet = <String>[];

    if (value.length < minLength) {
      unmet.add('passwordReqMinLength');
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      unmet.add('passwordReqLetter');
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      unmet.add('passwordReqNumber');
    }

    var score = 0.0;
    if (value.length >= minLength) score += 0.35;
    if (value.length >= 12) score += 0.15;
    if (RegExp(r'[A-Za-z]').hasMatch(value)) score += 0.2;
    if (RegExp(r'\d').hasMatch(value)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.1;

    final level = switch (score) {
      >= 0.9 => PasswordStrengthLevel.strong,
      >= 0.7 => PasswordStrengthLevel.good,
      >= 0.45 => PasswordStrengthLevel.fair,
      _ => PasswordStrengthLevel.weak,
    };

    return PasswordStrengthResult(
      level: level,
      score: score.clamp(0, 1),
      unmetRequirementKeys: unmet,
    );
  }

  static String levelLabelKey(PasswordStrengthLevel level) {
    return switch (level) {
      PasswordStrengthLevel.weak => 'passwordStrengthWeak',
      PasswordStrengthLevel.fair => 'passwordStrengthFair',
      PasswordStrengthLevel.good => 'passwordStrengthGood',
      PasswordStrengthLevel.strong => 'passwordStrengthStrong',
    };
  }
}
