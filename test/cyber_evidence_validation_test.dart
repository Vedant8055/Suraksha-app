import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cyber_evidence_validation.dart';

void main() {
  group('CyberEvidenceValidation', () {
    test('sanitizeSearch trims and bounds length', () {
      expect(CyberEvidenceValidation.sanitizeSearch('  hello  '), 'hello');
      final long = 'a' * 200;
      expect(
        CyberEvidenceValidation.sanitizeSearch(long).length,
        CyberEvidenceValidation.maxSearchLength,
      );
    });

    test('isAllowedType accepts known extensions', () {
      expect(CyberEvidenceValidation.isAllowedType('shot.JPG'), isTrue);
      expect(CyberEvidenceValidation.isAllowedType('note.pdf'), isTrue);
      expect(CyberEvidenceValidation.isAllowedType('clip.exe'), isFalse);
    });

    test('formatBytes formats sizes', () {
      expect(CyberEvidenceValidation.formatBytes(500), '500 B');
      expect(CyberEvidenceValidation.formatBytes(2048), '2.0 KB');
      expect(CyberEvidenceValidation.formatBytes(5 * 1024 * 1024), '5.0 MB');
    });
  });
}
