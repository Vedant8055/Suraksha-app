import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/features/dashboard/emergency_services_scan_service.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

void main() {
  final l10n = AppLocalizations(const Locale('en'));

  test('buildRiskReasons keeps crime and lighting reasons', () {
    final reasons = SafetyVerdictHelper.buildRiskReasons(
      l10n,
      contributingFactors: const [
        'Recent drug-related activity reported in this area.',
        'Chain-snatching cases have been reported nearby.',
        'This stretch is known for theft-related incidents.',
        'Poor street lighting may reduce visibility here.',
        'Low pedestrian activity makes this area feel isolated.',
      ],
      dimensions: const [
        SafetyDimensionScore(
          key: 'crime',
          score: 40,
          label: 'High Risk',
          confidence: 70,
        ),
      ],
      nearbySupportCount: 0,
      nearbyPoliceCount: 0,
      nearbyHospitalCount: 0,
      verdictLevel: SafetyVerdictLevel.highRisk,
      ensureForRiskyArea: true,
    );

    expect(
      reasons,
      containsAllInOrder([
        'Recent drug-related activity reported in this area.',
        'Chain-snatching cases have been reported nearby.',
        'This stretch is known for theft-related incidents.',
        'Poor street lighting may reduce visibility here.',
        'Low pedestrian activity makes this area feel isolated.',
      ]),
    );
  });

  test('buildRiskReasons suppresses support warning when help is nearby', () {
    final reasons = SafetyVerdictHelper.buildRiskReasons(
      l10n,
      contributingFactors: const [
        'Emergency support infrastructure is mapped nearby.',
        'At least one emergency support point is mapped nearby.',
      ],
      dimensions: const [
        SafetyDimensionScore(
          key: 'support',
          score: 42,
          label: 'High Risk',
          confidence: 70,
        ),
      ],
      nearbySupportCount: 1,
      nearbyPoliceCount: 0,
      nearbyHospitalCount: 0,
      verdictLevel: SafetyVerdictLevel.caution,
      ensureForRiskyArea: true,
    );

    expect(
      reasons,
      isNot(contains('Limited nearby emergency support points may slow rapid assistance.')),
    );
  });

  test('buildRiskReasons never shows limited support as the only risk reason', () {
    final reasons = SafetyVerdictHelper.buildRiskReasons(
      l10n,
      contributingFactors: const [],
      dimensions: const [
        SafetyDimensionScore(
          key: 'support',
          score: 20,
          label: 'Critical',
          confidence: 70,
        ),
      ],
      riskReasonsFromAlert: const [
        'Limited nearby emergency support points may slow rapid assistance.',
      ],
      nearbySupportCount: 0,
      nearbyPoliceCount: 0,
      nearbyHospitalCount: 0,
      verdictLevel: SafetyVerdictLevel.highRisk,
      ensureForRiskyArea: true,
    );

    expect(
      reasons,
      isNot(contains('Limited nearby emergency support points may slow rapid assistance.')),
    );
  });

  test('buildRiskReasons never copies action advice into why-not-safe', () {
    final reasons = SafetyVerdictHelper.buildRiskReasons(
      l10n,
      contributingFactors: const [],
      dimensions: const [],
      recommendations: const [
        'Avoid isolated routes and share live location with someone you trust.',
      ],
      nearbySupportCount: 0,
      nearbyPoliceCount: 0,
      nearbyHospitalCount: 0,
      verdictLevel: SafetyVerdictLevel.highRisk,
      ensureForRiskyArea: true,
      at: DateTime(2026, 7, 4, 12, 0),
      allowNightReasons: false,
    );

    expect(reasons, isEmpty);
    expect(
      reasons.join(' '),
      isNot(contains('isolated')),
    );
  });

  test('core emergency within 1km marks area safe without crime signals', () {
    const state = SafetyMonitorState(
      safetyScore: 40,
      riskLabel: 'High Risk',
      areaAssessmentReady: true,
      regionLabel: 'Nashik',
      emergencyServices1km: NearbyEmergencyServicesSnapshot(
        policeCount: 1,
        hospitalCount: 0,
        pharmacyCount: 2,
        petrolPumpCount: 1,
        washroomCount: 1,
        scanned: true,
      ),
    );

    final verdict = SafetyVerdictHelper.forMonitorState(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 12, 12),
    );
    final reasons = SafetyVerdictHelper.positiveReasonsForMonitor(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 12, 12),
    );

    expect(verdict.level, SafetyVerdictLevel.safe);
    expect(
      reasons,
      contains(
        'There are plenty of emergency services present in this area.',
      ),
    );
    expect(
      reasons,
      contains('No crimes reported in this area for now.'),
    );
    expect(
      reasons,
      contains(
        'There is considerable footfall and crowd on nearby roads, which helps this area feel safer during the day.',
      ),
    );
    expect(reasons.join(' ').toLowerCase(), isNot(contains('pharmacy')));
  });

  test('formatCappedServiceCount shows 4+ above cap', () {
    expect(SafetyVerdictHelper.formatCappedServiceCount(3), '3');
    expect(SafetyVerdictHelper.formatCappedServiceCount(4), '4');
    expect(SafetyVerdictHelper.formatCappedServiceCount(20), '4+');
  });

  test('isNightTime uses 7 PM to 7 AM window', () {
    expect(
      SafetyVerdictHelper.isNightTime(DateTime(2026, 7, 4, 18, 59)),
      isFalse,
    );
    expect(
      SafetyVerdictHelper.isNightTime(DateTime(2026, 7, 4, 19, 0)),
      isTrue,
    );
    expect(
      SafetyVerdictHelper.isNightTime(DateTime(2026, 7, 4, 6, 59)),
      isTrue,
    );
    expect(
      SafetyVerdictHelper.isNightTime(DateTime(2026, 7, 4, 7, 0)),
      isFalse,
    );
  });

  test('buildRiskReasons does not invent night cautions without evidence', () {
    final reasons = SafetyVerdictHelper.buildRiskReasons(
      l10n,
      contributingFactors: const [],
      dimensions: const [],
      nearbySupportCount: 1,
      nearbyPoliceCount: 1,
      nearbyHospitalCount: 0,
      verdictLevel: SafetyVerdictLevel.caution,
      ensureForRiskyArea: true,
      at: DateTime(2026, 7, 4, 21, 0),
      allowNightReasons: true,
    );

    expect(reasons, isEmpty);
  });

  test('registered crime reasons appear only when factors exist', () {
    const withCrime = SafetyMonitorState(
      contributingFactors: ['Registered theft cases in this grid cell.'],
    );
    const withoutCrime = SafetyMonitorState(
      areaAssessmentReady: true,
      contributingFactors: ['Emergency support infrastructure is mapped nearby.'],
    );

    final crimeReasons = SafetyVerdictHelper.registeredCrimeReasonsForMonitor(
      l10n,
      withCrime,
    );
    final none = SafetyVerdictHelper.registeredCrimeReasonsForMonitor(
      l10n,
      withoutCrime,
    );

    expect(crimeReasons, isNotEmpty);
    expect(none, isEmpty);
    expect(SafetyVerdictHelper.shouldShowNoCrimesReported(withoutCrime), isTrue);
    expect(SafetyVerdictHelper.shouldShowNoCrimesReported(withCrime), isFalse);
  });

  test('daytime footfall reason is skipped at night even in urban area', () {
    const state = SafetyMonitorState(
      regionLabel: 'Nashik',
      areaAssessmentReady: true,
      emergencyServices1km: NearbyEmergencyServicesSnapshot(
        policeCount: 2,
        hospitalCount: 10,
        pharmacyCount: 12,
        scanned: true,
      ),
    );

    expect(
      SafetyVerdictHelper.hasGoodDaytimeActivityEvidence(
        state,
        at: DateTime(2026, 7, 4, 14, 0),
      ),
      isTrue,
    );
    expect(
      SafetyVerdictHelper.hasGoodDaytimeActivityEvidence(
        state,
        at: DateTime(2026, 7, 4, 20, 0),
      ),
      isFalse,
    );
  });

  test('night environment caution requires evidence after 7 PM', () {
    const state = SafetyMonitorState(
      dimensions: [
        SafetyDimensionScore(
          key: 'infrastructure',
          score: 35,
          label: 'Poor',
          confidence: 70,
        ),
      ],
    );

    final nightReasons = SafetyVerdictHelper.nightEnvironmentReasonsForMonitor(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 20, 0),
    );
    final dayReasons = SafetyVerdictHelper.nightEnvironmentReasonsForMonitor(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 14, 0),
    );

    expect(nightReasons, isNotEmpty);
    expect(dayReasons, isEmpty);
  });

  test('missing police and hospital within 1km is caution with core reason', () {
    const state = SafetyMonitorState(
      safetyScore: 70,
      riskLabel: 'Safe',
      emergencyServices1km: NearbyEmergencyServicesSnapshot(
        policeCount: 0,
        hospitalCount: 0,
        pharmacyCount: 3,
        scanned: true,
      ),
    );

    final verdict = SafetyVerdictHelper.forMonitorState(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 12, 12),
    );
    final reasons = SafetyVerdictHelper.riskReasonsForMonitor(
      l10n,
      state: state,
      verdict: verdict,
      at: DateTime(2026, 7, 4, 12, 12),
    );

    expect(verdict.level, SafetyVerdictLevel.caution);
    expect(
      reasons,
      contains('No police station or hospital is available within 1 km.'),
    );
  });

  test('crime evidence keeps caution even when core emergency exists', () {
    const state = SafetyMonitorState(
      safetyScore: 80,
      riskLabel: 'Safe',
      contributingFactors: [
        'Recent drug-related activity reported in this area.',
      ],
      emergencyServices1km: NearbyEmergencyServicesSnapshot(
        policeCount: 1,
        hospitalCount: 1,
        scanned: true,
      ),
    );

    final verdict = SafetyVerdictHelper.forMonitorState(
      l10n,
      state: state,
      at: DateTime(2026, 7, 4, 12, 12),
    );

    expect(verdict.level, SafetyVerdictLevel.caution);
  });
}
