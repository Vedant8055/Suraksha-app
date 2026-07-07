import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

enum SafetyVerdictLevel { safe, caution, highRisk }

class SafetyVerdict {
  final SafetyVerdictLevel level;
  final String headline;
  final String summary;
  final Color tone;

  const SafetyVerdict({
    required this.level,
    required this.headline,
    required this.summary,
    required this.tone,
  });

  bool get showRiskReasons =>
      level == SafetyVerdictLevel.caution ||
      level == SafetyVerdictLevel.highRisk;
}

class SafetyVerdictHelper {
  const SafetyVerdictHelper._();

  static SafetyVerdict fromScore(
    AppLocalizations l10n, {
    required int score,
    String? riskLabel,
    String? summary,
  }) {
    final level = _levelFromInputs(score: score, riskLabel: riskLabel);
    final headline = switch (level) {
      SafetyVerdictLevel.safe => l10n.t('safetyVerdictSafe'),
      SafetyVerdictLevel.caution => l10n.t('safetyVerdictCaution'),
      SafetyVerdictLevel.highRisk => l10n.t('safetyVerdictHighRisk'),
    };
    final defaultSummary = switch (level) {
      SafetyVerdictLevel.safe => l10n.t('safetyVerdictSafeSummary'),
      SafetyVerdictLevel.caution => l10n.t('safetyVerdictCautionSummary'),
      SafetyVerdictLevel.highRisk => l10n.t('safetyVerdictHighRiskSummary'),
    };
    final tone = switch (level) {
      SafetyVerdictLevel.safe => const Color(0xFF15803D),
      SafetyVerdictLevel.caution => const Color(0xFFEAB308),
      SafetyVerdictLevel.highRisk => const Color(0xFFB91C1C),
    };

    return SafetyVerdict(
      level: level,
      headline: headline,
      summary: _cleanSummary(summary) ?? defaultSummary,
      tone: tone,
    );
  }

  static SafetyVerdictLevel _levelFromInputs({
    required int score,
    String? riskLabel,
  }) {
    final label = riskLabel?.trim().toLowerCase() ?? '';
    if (label.contains('critical') ||
        label.contains('high risk') ||
        label.contains('high alert')) {
      return SafetyVerdictLevel.highRisk;
    }
    if (label.contains('moderate') ||
        label.contains('caution') ||
        label.contains('mixed')) {
      return SafetyVerdictLevel.caution;
    }
    if (label.contains('very safe') ||
        (label.contains('safe') && !label.contains('unsafe'))) {
      return SafetyVerdictLevel.safe;
    }

    if (score >= 75) return SafetyVerdictLevel.safe;
    if (score >= 55) return SafetyVerdictLevel.caution;
    return SafetyVerdictLevel.highRisk;
  }

  static String? _cleanSummary(String? summary) {
    final text = summary?.trim();
    if (text == null || text.isEmpty) return null;
    final lower = text.toLowerCase();
    if (lower.contains('still building') ||
        lower.contains('still learning') ||
        lower.contains('initializing safety monitor')) {
      return null;
    }
    return text;
  }

  static SafetyVerdict fromRouteState(
    AppLocalizations l10n, {
    required bool pendingSafetyCheck,
    required String riskLabel,
    required bool hasLearnedRoute,
    required bool learningRoute,
  }) {
    if (pendingSafetyCheck) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.highRisk,
        headline: l10n.t('routeVerdictChanged'),
        summary: l10n.t('routeVerdictChangedSummary'),
        tone: const Color(0xFFE53935),
      );
    }
    if (learningRoute || !hasLearnedRoute) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.caution,
        headline: l10n.t('routeVerdictLearning'),
        summary: l10n.t('routeVerdictLearningSummary'),
        tone: const Color(0xFF3B82F6),
      );
    }
    final label = riskLabel.toLowerCase();
    if (label.contains('safest') || label.contains('safe')) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.safe,
        headline: l10n.t('routeVerdictOnTrack'),
        summary: l10n.t('routeVerdictOnTrackSummary'),
        tone: const Color(0xFF2FB79E),
      );
    }
    if (label.contains('caution')) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.caution,
        headline: l10n.t('routeVerdictCaution'),
        summary: l10n.t('routeVerdictCautionSummary'),
        tone: const Color(0xFFF3B13E),
      );
    }
    return SafetyVerdict(
      level: SafetyVerdictLevel.highRisk,
      headline: l10n.t('routeVerdictAlert'),
      summary: l10n.t('routeVerdictAlertSummary'),
      tone: const Color(0xFFE66E41),
    );
  }

  static bool isAreaSafetyAlert(String category) {
    final normalized = category.toLowerCase();
    return normalized.contains('area safety') ||
        normalized.contains('safety score') ||
        normalized == 'alertcategoryareasafety';
  }

  /// Night window for footfall, traffic, and street lighting: 19:00–07:00 local.
  static bool isNightTime([DateTime? at]) {
    final hour = (at ?? DateTime.now()).hour;
    return hour >= 19 || hour < 7;
  }

  static const int emergencyServiceCountCap = 4;

  static String formatCappedServiceCount(int count) {
    if (count > emergencyServiceCountCap) return '4+';
    return '$count';
  }

  static bool isLateNight([DateTime? at]) {
    final hour = (at ?? DateTime.now()).hour;
    return hour >= 23 || hour < 5;
  }

  /// Crime / violence signals only (not night alone, not missing data).
  static bool hasCrimeRiskEvidence(SafetyMonitorState state) {
    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, [
        'incident',
        'violent',
        'crime',
        'assault',
        'murder',
        'half murder',
        'snatch',
        'theft',
        'robbery',
        'harass',
        'drug',
        'peddl',
        'grid model',
        'elevated risk',
      ])) {
        return true;
      }
    }

    for (final dimension in state.dimensions) {
      if (dimension.key == 'crime' && dimension.score < 50) return true;
    }

    return false;
  }

  static bool hasViolentCrimeEvidence(SafetyMonitorState state) {
    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, [
        'murder',
        'half murder',
        'violent',
        'assault',
        'rape',
        'kidnap',
      ])) {
        return true;
      }
    }
    return false;
  }

  static bool hasNightEnvironmentRisk(
    SafetyMonitorState state, {
    DateTime? at,
  }) {
    if (!isNightTime(at)) return false;
    return _hasNightEnvironmentEvidence(state);
  }

  static bool _hasNightEnvironmentEvidence(SafetyMonitorState state) {
    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, [
        'light',
        'lighting',
        'unlit',
        'poorly lit',
        'dark',
        'visibility after sunset',
        'pedestrian',
        'footfall',
        'crowd',
        'poi visibility',
        'low activity',
        'isolated',
        'traffic',
        'congestion',
        'vehicle flow',
        'road busy',
        'transit',
      ])) {
        return true;
      }
    }
    for (final dimension in state.dimensions) {
      if (dimension.score >= 55) continue;
      if (dimension.key == 'infrastructure' ||
          dimension.key == 'visibility' ||
          dimension.key == 'temporal') {
        return true;
      }
    }
    return false;
  }

  /// Evidence-based night cautions (footfall, traffic, lighting) after 7 PM only.
  static List<String> nightEnvironmentReasonsForMonitor(
    AppLocalizations l10n, {
    required SafetyMonitorState state,
    DateTime? at,
  }) {
    if (!isNightTime(at) || !_hasNightEnvironmentEvidence(state)) {
      return const [];
    }

    final reasons = <String>[];
    final seen = <String>{};

    void add(String reason) {
      final trimmed = reason.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) return;
      seen.add(trimmed);
      reasons.add(trimmed);
    }

    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, [
        'light',
        'lighting',
        'unlit',
        'poorly lit',
        'dark',
        'visibility after sunset',
      ])) {
        add(l10n.t('safetyReasonPoorLighting'));
      }
      if (_containsAny(text, [
        'pedestrian',
        'footfall',
        'crowd',
        'poi visibility',
        'low activity',
        'isolated',
      ])) {
        add(l10n.t('safetyReasonLowFootfall'));
      }
      if (_containsAny(text, [
        'traffic',
        'congestion',
        'vehicle flow',
        'road busy',
        'transit',
      ])) {
        add(l10n.t('safetyReasonNightTraffic'));
      }
    }

    for (final dimension in state.dimensions) {
      if (dimension.score >= 55) continue;
      add(switch (dimension.key) {
        'infrastructure' => l10n.t('safetyReasonPoorLighting'),
        'visibility' => l10n.t('safetyReasonLowFootfall'),
        'temporal' => l10n.t('safetyReasonNightTraffic'),
        _ => '',
      });
    }

    return reasons.take(3).toList(growable: false);
  }

  /// Hard evidence for elevated concern (crime, missing core support, night risks).
  static bool hasStrongRiskEvidence(
    SafetyMonitorState state, {
    DateTime? at,
  }) {
    if (hasCrimeRiskEvidence(state)) return true;
    if (!state.hasCoreEmergencyWithin1km &&
        state.emergencyServices1km.scanned) {
      return true;
    }
    if (hasNightEnvironmentRisk(state, at: at)) return true;
    return false;
  }

  static SafetyVerdict forMonitorState(
    AppLocalizations l10n, {
    required SafetyMonitorState state,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final services = state.emergencyServices1km;
    final hasCore = state.hasCoreEmergencyWithin1km;
    final crime = hasCrimeRiskEvidence(state);
    final violent = hasViolentCrimeEvidence(state);
    final nightEnv = hasNightEnvironmentRisk(state, at: now);
    final missingCore = services.scanned && !hasCore;

    // Core rule: hospital or police within 1 km, and no serious risk signals → safe.
    if (hasCore && !crime && !nightEnv) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.safe,
        headline: l10n.t('safetyVerdictSafe'),
        summary: l10n.t('safetyVerdictSafeWithEmergencySummary'),
        tone: const Color(0xFF15803D),
      );
    }

    if (violent) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.highRisk,
        headline: l10n.t('safetyVerdictHighRisk'),
        summary: l10n.t('safetyVerdictHighRiskSummary'),
        tone: const Color(0xFFB91C1C),
      );
    }

    if (missingCore || crime || nightEnv) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.caution,
        headline: l10n.t('safetyVerdictCaution'),
        summary: missingCore
            ? l10n.t('safetyVerdictNoCoreEmergencySummary')
            : l10n.t('safetyVerdictCautionSummary'),
        tone: const Color(0xFFEAB308),
      );
    }

    // Services not scanned yet / incomplete — stay mild, never invent isolation.
    var verdict = fromScore(
      l10n,
      score: state.safetyScore,
      riskLabel: state.riskLabel,
      summary: state.summary,
    );
    if (verdict.level == SafetyVerdictLevel.highRisk) {
      return SafetyVerdict(
        level: SafetyVerdictLevel.caution,
        headline: l10n.t('safetyVerdictCaution'),
        summary: _daytimeSafeSummary(l10n, state.summary),
        tone: const Color(0xFFEAB308),
      );
    }
    if (_isIsolationOrHighConcernSummary(verdict.summary)) {
      return SafetyVerdict(
        level: verdict.level,
        headline: verdict.headline,
        summary: _daytimeSafeSummary(l10n, state.summary),
        tone: verdict.tone,
      );
    }
    return verdict;
  }

  static String _daytimeSafeSummary(AppLocalizations l10n, String? summary) {
    final cleaned = _cleanSummary(summary);
    if (cleaned != null &&
        !_isIsolationOrHighConcernSummary(cleaned) &&
        !cleaned.toLowerCase().contains('elevated caution')) {
      return cleaned;
    }
    return l10n.t('safetyVerdictCautionSummary');
  }

  static bool _isIsolationOrHighConcernSummary(String text) {
    final lower = text.toLowerCase();
    return lower.contains('may not feel safe') ||
        lower.contains('isolated') ||
        lower.contains('especially for women');
  }

  static String actionGuidanceForMonitor(
    AppLocalizations l10n, {
    required SafetyMonitorState state,
    required SafetyVerdictLevel level,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final night = isNightTime(now);
    final crime = hasCrimeRiskEvidence(state);
    final allowIsolationAdvice = night || crime || hasViolentCrimeEvidence(state);

    String? candidate = state.aiSummaryAction?.trim();
    if (candidate == null || candidate.isEmpty) {
      if (state.recommendations.isNotEmpty) {
        candidate = state.recommendations.first;
      }
    }

    if (candidate != null &&
        candidate.isNotEmpty &&
        (allowIsolationAdvice || !_isIsolationAdvice(candidate))) {
      return candidate;
    }

    return switch (level) {
      SafetyVerdictLevel.safe => l10n.t('safetyActionSafe'),
      SafetyVerdictLevel.caution => l10n.t('safetyActionCaution'),
      SafetyVerdictLevel.highRisk => allowIsolationAdvice
          ? l10n.t('safetyActionHighRisk')
          : l10n.t('safetyActionCaution'),
    };
  }

  static bool _isIsolationAdvice(String text) {
    final lower = text.toLowerCase();
    return lower.contains('avoid isolated') ||
        lower.contains('isolated routes') ||
        lower.contains('isolated shortcuts') ||
        lower.contains('may not feel safe') ||
        (lower.contains('share') && lower.contains('live location'));
  }

  static List<String> riskReasonsForMonitor(
    AppLocalizations l10n, {
    required SafetyMonitorState state,
    required SafetyVerdict verdict,
    DateTime? at,
  }) {
    if (verdict.level == SafetyVerdictLevel.safe) return const [];

    SafetyCommunityAlert? areaAlert;
    for (final alert in state.communityAlerts) {
      if (isAreaSafetyAlert(alert.category)) {
        areaAlert = alert;
        break;
      }
    }
    final reasons = buildRiskReasons(
      l10n,
      contributingFactors: state.contributingFactors,
      dimensions: state.dimensions,
      riskReasonsFromAlert: areaAlert?.riskReasons ?? const [],
      relatedAlerts: state.communityAlerts,
      nearbyPoliceCount: state.emergencyServices1km.policeCount,
      nearbyHospitalCount: state.emergencyServices1km.hospitalCount,
      nearbySupportCount: state.emergencyServices1km.totalCount,
      // Never surface limited-data messaging to users.
      limitedAssessmentNote: null,
      verdictLevel: verdict.level,
      ensureForRiskyArea: verdict.showRiskReasons,
      at: at,
      allowNightReasons: isNightTime(at),
    );

    final merged = <String>[
      ...registeredCrimeReasonsForMonitor(l10n, state),
      ...reasons,
      ...nightEnvironmentReasonsForMonitor(
        l10n,
        state: state,
        at: at,
      ),
    ];
    if (state.emergencyServices1km.scanned &&
        !state.hasCoreEmergencyWithin1km) {
      final coreReason = l10n.t('safetyReasonNoCoreEmergency1km');
      if (!merged.contains(coreReason)) {
        merged.insert(0, coreReason);
      }
    }
    final deduped = <String>[];
    final seen = <String>{};
    for (final reason in merged) {
      final trimmed = reason.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      seen.add(trimmed);
      deduped.add(trimmed);
    }
    return deduped.take(6).toList(growable: false);
  }

  static List<String> registeredCrimeReasonsForMonitor(
    AppLocalizations l10n,
    SafetyMonitorState state,
  ) {
    final reasons = <String>[];
    final seen = <String>{};

    void addKey(String key) {
      final message = l10n.t(key);
      if (seen.contains(message)) return;
      seen.add(message);
      reasons.add(message);
    }

    for (final key in _registeredCrimeReasonKeys(state)) {
      addKey(key);
    }

    return reasons;
  }

  static Iterable<String> _registeredCrimeReasonKeys(SafetyMonitorState state) sync* {
    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, ['half murder', 'half-murder', 'attempt to murder'])) {
        yield 'safetyReasonRegisteredHalfMurder';
      } else if (_containsAny(text, ['murder', 'homicide'])) {
        yield 'safetyReasonRegisteredMurder';
      }
      if (_containsAny(text, ['drug', 'narcotic', 'peddl', 'substance abuse'])) {
        yield 'safetyReasonRegisteredDrug';
      }
      if (_containsAny(text, ['robbery', 'armed robbery', 'mugging'])) {
        yield 'safetyReasonRegisteredRobbery';
      }
      if (_containsAny(text, ['theft', 'steal', 'burglary'])) {
        yield 'safetyReasonRegisteredTheft';
      }
      if (_containsAny(text, ['snatch', 'chain'])) {
        yield 'safetyReasonRegisteredChainSnatching';
      }
      if (_containsAny(text, ['harass', 'molest', 'assault'])) {
        yield 'safetyReasonRegisteredAssault';
      }
    }
  }

  static bool hasRegisteredCrimeEvidence(SafetyMonitorState state) {
    return _registeredCrimeReasonKeys(state).isNotEmpty;
  }

  static List<String> positiveReasonsForMonitor(
    AppLocalizations l10n, {
    required SafetyMonitorState state,
    DateTime? at,
  }) {
    final reasons = <String>[];
    final seen = <String>{};
    final services = state.emergencyServices1km;
    final crimeReasons = registeredCrimeReasonsForMonitor(l10n, state);

    void add(String reason) {
      final trimmed = reason.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) return;
      seen.add(trimmed);
      reasons.add(trimmed);
    }

    if (services.scanned && services.totalCount > 0) {
      add(l10n.t('safetyReasonPlentyEmergencyServices'));
    } else if (state.hasCoreEmergencyWithin1km) {
      add(l10n.t('safetyReasonPlentyEmergencyServices'));
    }

    if (crimeReasons.isNotEmpty) {
      for (final crimeReason in crimeReasons) {
        add(crimeReason);
      }
    } else if (shouldShowNoCrimesReported(state)) {
      add(l10n.t('safetyReasonNoCrimesReported'));
    }

    if (hasGoodDaytimeActivityEvidence(state, at: at)) {
      add(l10n.t('safetyReasonGoodDaytimeFootfall'));
    }

    if (reasons.isEmpty && state.hasCoreEmergencyWithin1km) {
      add(l10n.t('safetyReasonSupportNearby'));
    }

    return reasons.take(6).toList(growable: false);
  }

  static bool shouldShowNoCrimesReported(SafetyMonitorState state) {
    if (!hasAssessedCrimeStatus(state)) return false;
    if (hasCrimeRiskEvidence(state)) return false;
    return !hasRegisteredCrimeEvidence(state);
  }

  static bool hasAssessedCrimeStatus(SafetyMonitorState state) {
    return state.areaAssessmentReady ||
        state.dimensions.isNotEmpty ||
        state.contributingFactors.isNotEmpty;
  }

  static bool isDaytime([DateTime? at]) => !isNightTime(at);

  /// Daytime-only positive footfall/crowd signal from live data or urban density.
  static bool hasGoodDaytimeActivityEvidence(
    SafetyMonitorState state, {
    DateTime? at,
  }) {
    if (!isDaytime(at)) return false;
    if (_hasLowDaytimeActivityEvidence(state)) return false;

    for (final factor in state.contributingFactors) {
      if (_isPositiveFootfallFactor(factor)) return true;
    }

    for (final dimension in state.dimensions) {
      if (dimension.key == 'visibility' && dimension.score >= 55) {
        return true;
      }
      if (dimension.key == 'temporal' && dimension.score >= 55) {
        return true;
      }
    }

    return _looksLikeUrbanBusyArea(state);
  }

  static bool _hasLowDaytimeActivityEvidence(SafetyMonitorState state) {
    for (final factor in state.contributingFactors) {
      final text = factor.toLowerCase();
      if (_containsAny(text, [
        'low pedestrian',
        'low activity',
        'very_low',
        'sparse crowd',
        'feel isolated',
        'isolated area',
        'crowd and mapped-place activity signals are low',
      ])) {
        return true;
      }
    }
    for (final dimension in state.dimensions) {
      if (dimension.key == 'visibility' && dimension.score < 45) {
        return true;
      }
    }
    return false;
  }

  static bool _isPositiveFootfallFactor(String factor) {
    final text = factor.toLowerCase();
    if (_containsAny(text, [
      'low pedestrian',
      'low activity',
      'very_low',
      'isolated',
      'sparse crowd',
    ])) {
      return false;
    }
    return _containsAny(text, [
      'daytime visibility and activity signals are favorable',
      'normal pedestrian activity',
      'considerable footfall',
      'busy road',
      'busy corridor',
      'high activity',
      'moderate activity',
      'crowd aggregate',
      'road traffic',
      'well-used',
      'public activity',
      'pedestrian activity',
    ]);
  }

  static bool _looksLikeUrbanBusyArea(SafetyMonitorState state) {
    final services = state.emergencyServices1km;
    if (services.scanned && services.totalCount >= 8) return true;
    if (state.nearbySupportCount >= 6) return true;
    if (state.nearbyResources.length >= 10) return true;

    final region = state.regionLabel?.trim().toLowerCase() ?? '';
    final inMappedCity = region.contains('nashik') ||
        region.contains('city') ||
        region.contains('urban') ||
        region.contains('metro');
    if (!inMappedCity) return false;

    if (services.scanned && services.totalCount >= 4) return true;
    if (state.nearbySupportCount >= 3) return true;
    if (state.nearbyResources.length >= 5) return true;
    return false;
  }

  static List<String> buildRiskReasons(
    AppLocalizations l10n, {
    required List<String> contributingFactors,
    required List<SafetyDimensionScore> dimensions,
    List<String> riskReasonsFromAlert = const [],
    @Deprecated('Action recommendations must not appear as risk reasons')
    List<String> recommendations = const [],
    List<SafetyCommunityAlert> relatedAlerts = const [],
    int nearbyPoliceCount = 0,
    int nearbyHospitalCount = 0,
    int nearbySupportCount = 0,
    String? limitedAssessmentNote,
    bool ensureForRiskyArea = false,
    SafetyVerdictLevel? verdictLevel,
    DateTime? at,
    bool allowNightReasons = true,
  }) {
    final reasons = <String>[];
    final seen = <String>{};
    final hasEmergencySupportNearby =
        nearbySupportCount > 0 ||
        nearbyPoliceCount > 0 ||
        nearbyHospitalCount > 0;
    final night = allowNightReasons && isNightTime(at);

    void addReason(String reason) {
      final trimmed = reason.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) return;
      if (_isIsolationAdvice(trimmed)) return;
      seen.add(trimmed);
      reasons.add(trimmed);
    }

    if (riskReasonsFromAlert.isNotEmpty) {
      for (final reason in riskReasonsFromAlert) {
        addReason(
          _humanizeFactor(
            l10n,
            reason,
            hasEmergencySupportNearby: hasEmergencySupportNearby,
          ),
        );
      }
    }

    for (final factor in contributingFactors) {
      if (_isPositiveFactor(factor)) continue;
      addReason(
        _humanizeFactor(
          l10n,
          factor,
          hasEmergencySupportNearby: hasEmergencySupportNearby,
        ),
      );
    }

    for (final dimension in dimensions) {
      if (dimension.score >= 55) continue;
      if (dimension.key == 'support' && hasEmergencySupportNearby) continue;
      // Visibility/footfall is not live traffic — only cite at night.
      if (dimension.key == 'visibility' && !night) continue;
      if (dimension.key == 'temporal' && !night) continue;
      if (dimension.key == 'infrastructure' && !night) continue;
      addReason(_reasonForWeakDimension(l10n, dimension.key));
    }

    // Intentionally do NOT copy action recommendations into risk reasons.

    for (final alert in relatedAlerts) {
      if (isAreaSafetyAlert(alert.category)) continue;
      if (alert.priority != 'critical' && alert.priority != 'caution') continue;
      addReason(
        _humanizeFactor(
          l10n,
          alert.summary,
          hasEmergencySupportNearby: hasEmergencySupportNearby,
        ),
      );
    }

    if (limitedAssessmentNote != null &&
        limitedAssessmentNote.trim().isNotEmpty) {
      addReason(l10n.t('safetyReasonLimitedData'));
    }

    return reasons
        .where((reason) => !_isLimitedSupportReason(l10n, reason))
        .take(6)
        .toList(growable: false);
  }

  static String _reasonForWeakDimension(AppLocalizations l10n, String key) {
    return switch (key) {
      'crime' => l10n.t('safetyReasonCrimeActivity'),
      'infrastructure' => l10n.t('safetyReasonPoorLighting'),
      'support' => l10n.t('safetyReasonLimitedSupport'),
      'visibility' => l10n.t('safetyReasonLowFootfall'),
      'temporal' => l10n.t('safetyReasonNightTraffic'),
      _ => '',
    };
  }

  static String _humanizeFactor(
    AppLocalizations l10n,
    String factor, {
    required bool hasEmergencySupportNearby,
  }) {
    final text = factor.toLowerCase();
    if (_containsAny(text, [
      'additional caution is advised',
      'use extra caution',
      'be cautious',
      'general caution',
      'may not feel safe',
      'stay alert',
    ])) {
      return '';
    }
    if (_containsAny(text, ['drug', 'narcotic'])) {
      return l10n.t('safetyReasonDrugActivity');
    }
    if (_containsAny(text, ['snatch', 'chain'])) {
      return l10n.t('safetyReasonChainSnatching');
    }
    if (_containsAny(text, ['theft', 'robbery', 'steal'])) {
      return l10n.t('safetyReasonTheftProne');
    }
    if (_containsAny(text, ['harass', 'molest', 'assault'])) {
      return l10n.t('safetyReasonHarassmentReports');
    }
    if (_containsAny(text, [
      'light',
      'lighting',
      'lit',
      'visibility after sunset',
      'dark',
    ])) {
      return l10n.t('safetyReasonPoorLighting');
    }
    if (_containsAny(text, [
      'pedestrian',
      'footfall',
      'crowd',
      'poi visibility',
      'low activity',
    ])) {
      return l10n.t('safetyReasonLowFootfall');
    }
    if (_containsAny(text, [
      'traffic',
      'congestion',
      'vehicle flow',
      'road busy',
      'transit',
    ])) {
      return l10n.t('safetyReasonNightTraffic');
    }
    if (_containsAny(text, [
      'incident',
      'crime',
      'grid model',
      'elevated risk',
    ])) {
      return l10n.t('safetyReasonCrimeActivity');
    }
    if (_containsAny(text, [
      'emergency support',
      'police',
      'hospital',
      'support points',
    ])) {
      if (hasEmergencySupportNearby) return '';
      return '';
    }
    if (_containsAny(text, [
      'late-night',
      'night',
      'after sunset',
      'midnight',
    ])) {
      return l10n.t('safetyReasonNightRisk');
    }
    if (_containsAny(text, [
      'gps',
      'precision',
      'accuracy',
      'limited verified',
    ])) {
      return l10n.t('safetyReasonLimitedData');
    }
    if (_containsAny(text, ['red light', 'unsafe nightlife', 'nightlife'])) {
      return l10n.t('safetyReasonUnsafeNightlife');
    }
    if (_containsAny(text, ['well-lit', 'isolated shortcut', 'poorly lit'])) {
      return l10n.t('safetyReasonPoorLighting');
    }
    if (_containsAny(text, ['share your live location', 'keep sos'])) {
      return '';
    }
    return l10n.localizeDynamic(factor);
  }

  static bool _containsAny(String text, List<String> needles) {
    for (final needle in needles) {
      if (text.contains(needle)) return true;
    }
    return false;
  }

  static bool _isLimitedSupportReason(AppLocalizations l10n, String reason) {
    final text = reason.trim().toLowerCase();
    final localized = l10n.t('safetyReasonLimitedSupport').trim().toLowerCase();
    return text == localized ||
        text.contains('limited nearby emergency support') ||
        text.contains('limited mapped police') ||
        text.contains('emergency support is sparse') ||
        text.contains('support points may slow rapid assistance');
  }

  static bool _isPositiveFactor(String factor) {
    final text = factor.toLowerCase();
    return _containsAny(text, [
      'favorable',
      'emergency support infrastructure is mapped',
      'community-identified safer',
      'daytime visibility and activity signals are favorable',
      'conditions look manageable',
      'comparatively stable',
      'comparatively steadier',
    ]);
  }
}
