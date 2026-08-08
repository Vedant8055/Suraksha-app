import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_danger_detector.dart';

void main() {
  group('PoshDangerDetector', () {
    test('returns false for empty or neutral text', () {
      expect(PoshDangerDetector.mentionsImmediateDanger(''), isFalse);
      expect(
        PoshDangerDetector.mentionsImmediateDanger('  '),
        isFalse,
      );
      expect(
        PoshDangerDetector.mentionsImmediateDanger(
          'Workplace harassment complaint from last month.',
        ),
        isFalse,
      );
    });

    test('detects English immediate-danger phrases', () {
      expect(
        PoshDangerDetector.mentionsImmediateDanger(
          'I am in immediate danger at the office.',
        ),
        isTrue,
      );
      expect(
        PoshDangerDetector.mentionsImmediateDanger(
          'He is threatening me and I need help now.',
        ),
        isTrue,
      );
      expect(
        PoshDangerDetector.mentionsImmediateDanger('call police please'),
        isTrue,
      );
    });

    test('is case insensitive', () {
      expect(
        PoshDangerDetector.mentionsImmediateDanger('EMERGENCY situation'),
        isTrue,
      );
      expect(
        PoshDangerDetector.mentionsImmediateDanger('Stalking Me Today'),
        isTrue,
      );
    });

    test('detects Hindi / Hinglish cues in Latin script', () {
      expect(
        PoshDangerDetector.mentionsImmediateDanger('main abhi khatra mein hun'),
        isTrue,
      );
      expect(
        PoshDangerDetector.mentionsImmediateDanger('wo mujhe peecha kar raha hai'),
        isTrue,
      );
    });
  });
}
