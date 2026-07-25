import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';

void main() {
  test('weak password fails requirements', () {
    final result = PasswordStrength.evaluate('abc');
    expect(result.isAcceptable, isFalse);
    expect(result.level, PasswordStrengthLevel.weak);
  });

  test('acceptable password passes requirements', () {
    final result = PasswordStrength.evaluate('Suraksha1');
    expect(result.isAcceptable, isTrue);
    expect(result.unmetRequirementKeys, isEmpty);
  });

  test('strong password scores higher', () {
    final fair = PasswordStrength.evaluate('Password1');
    final strong = PasswordStrength.evaluate('Password1!extra');
    expect(strong.score, greaterThan(fair.score));
  });
}
