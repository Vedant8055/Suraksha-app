import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';

void main() {
  test('empty input stays empty', () {
    expect(IndianPhoneUtils.formatDisplay(''), '');
    expect(IndianPhoneUtils.formatDisplay('+91 '), '');
  });

  test('formats full number as +91 70200 94073', () {
    expect(
      IndianPhoneUtils.formatDisplay('917020094073'),
      '+91 70200 94073',
    );
    expect(
      IndianPhoneUtils.formatDisplay('7020094073'),
      '+91 70200 94073',
    );
  });

  test('forApi returns 10-digit national number', () {
    expect(IndianPhoneUtils.forApi('+91 70200 94073'), '7020094073');
    expect(IndianPhoneUtils.forApi('917020094073'), '7020094073');
  });
}
