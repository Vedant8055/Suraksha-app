import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/core/network/tls_pinning.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/features/auth/password_strength.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';

/// Phase 1 characterization: lock current helper behavior before Phase 2 refactors.
void main() {
  group('TlsPinning characterization', () {
    test('exposes production host constant', () {
      expect(TlsPinning.productionHost, 'suraksha-backend-gtdi.onrender.com');
    });

    test('builtin leaf fingerprints are non-empty colon-hex', () {
      expect(TlsPinning.allowedLeafFingerprints, isNotEmpty);
      for (final pin in TlsPinning.allowedLeafFingerprints) {
        expect(pin.contains(':'), isTrue);
        expect(pin.length, greaterThan(20));
      }
    });

    test('WE1 SPKI backup pin is base64-shaped', () {
      expect(TlsPinning.we1SpkiSha256Base64.endsWith('='), isTrue);
      expect(TlsPinning.we1SpkiSha256Base64.length, greaterThan(20));
    });
  });

  group('Auth helpers characterization', () {
    test('Indian phone forApi keeps 10-digit mobiles', () {
      expect(IndianPhoneUtils.forApi('9876543210'), '9876543210');
      expect(IndianPhoneUtils.forApi('+91 98765 43210'), '9876543210');
    });

    test('password strength rejects short passwords', () {
      final weak = PasswordStrength.evaluate('abc');
      expect(weak.isAcceptable, isFalse);
      final stronger = PasswordStrength.evaluate('Password1');
      expect(stronger.isAcceptable, isTrue);
    });
  });

  group('EmergencyContact characterization', () {
    test('normalizes and validates Indian mobiles', () {
      expect(
        EmergencyContact.normalizePhoneNumber('+91 98765-43210'),
        '+919876543210',
      );
      expect(EmergencyContact.isValidIndianMobile('9876543210'), isTrue);
      expect(EmergencyContact.isValidIndianMobile('12345'), isFalse);
    });
  });
}
