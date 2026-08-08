import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/core/storage/medical_vault_storage.dart';

void main() {
  test('MedicalVaultData export includes structured fields', () {
    final data = MedicalVaultData(
      bloodGroup: 'O+',
      allergies: 'Peanuts',
      conditions: 'Asthma',
      medications: 'Inhaler',
      emergencyNotes: 'Call mother',
      lastUpdatedAt: DateTime.utc(2026, 7, 20, 8, 0),
    );

    final json = data.toExportJson();
    expect(json['bloodGroup'], 'O+');
    expect(json['emergencyNotes'], 'Call mother');
    expect(data.toShareText(), contains('Disclaimer'));
    expect(data.isEmpty, isFalse);
  });

  test('empty medical vault detects empty state', () {
    expect(const MedicalVaultData().isEmpty, isTrue);
  });
}
