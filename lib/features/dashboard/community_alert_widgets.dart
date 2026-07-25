import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alert_display_helpers.dart';
import 'package:suraksha_women_safety_app/features/dashboard/dashboard_chrome_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/widgets/safety_risk_reasons_expansion.dart';

/// Toggle tile that expands/collapses the community alerts section
/// (Phase 2 extract, same visuals/behavior).
class CommunityAlertsToggleTile extends StatelessWidget {
  const CommunityAlertsToggleTile({
    super.key,
    required this.isLight,
    required this.expanded,
    required this.loading,
    required this.onPressed,
  });

  final bool isLight;
  final bool expanded;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF3B82F6);
    final textColor = expanded
        ? Colors.white
        : (isLight ? const Color(0xFF172235) : Colors.white);
    final inactiveBase = color.withValues(alpha: isLight ? 0.12 : 0.18);
    final inactiveEdge = color.withValues(alpha: isLight ? 0.2 : 0.28);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: expanded
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      inactiveBase,
                      color.withValues(alpha: isLight ? 0.06 : 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: expanded
                  ? Colors.white.withValues(alpha: 0.32)
                  : inactiveEdge,
            ),
            boxShadow: [
              BoxShadow(
                color: expanded
                    ? color.withValues(alpha: 0.32)
                    : isLight
                    ? color.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.18),
                blurRadius: expanded ? 18 : 10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: expanded
                      ? Colors.white.withValues(alpha: 0.22)
                      : color.withValues(alpha: isLight ? 0.14 : 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: expanded ? Colors.white : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).t('communityAlerts'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      expanded
                          ? AppLocalizations.of(context).t('tapForAlerts')
                          : AppLocalizations.of(context).t('tapForAlerts'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: expanded
                            ? Colors.white.withValues(alpha: 0.82)
                            : (isLight
                                  ? const Color(0xFF627491)
                                  : Colors.white.withValues(alpha: 0.68)),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: expanded
                      ? Colors.white.withValues(alpha: 0.9)
                      : color.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status/empty/loading panel used within the community alerts section
/// (Phase 2 extract, same visuals/behavior).
class CommunityAlertsStatusPanel extends StatelessWidget {
  const CommunityAlertsStatusPanel({
    super.key,
    required this.isLight,
    required this.icon,
    required this.loading,
    required this.title,
    this.subtitle,
    required this.tone,
  });

  final bool isLight;
  final IconData? icon;
  final bool loading;
  final String title;
  final String? subtitle;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return PoppingAlertCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLight
              ? tone.withValues(alpha: 0.08)
              : tone.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tone.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? Icons.notifications_active_rounded,
                color: tone,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isLight ? const Color(0xFF172235) : Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isLight
                            ? const Color(0xFF546784)
                            : Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single community alert card (Phase 2 extract, same visuals/behavior).
class CommunityAlertCard extends StatelessWidget {
  const CommunityAlertCard({
    super.key,
    required this.alert,
    this.safetyState,
  });

  final SafetyCommunityAlert alert;
  final SafetyMonitorState? safetyState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAreaSafety = SafetyVerdictHelper.isAreaSafetyAlert(alert.category);
    SafetyVerdict? areaVerdict;
    final displayCategory = CommunityAlertDisplayHelpers.sanitizeCommunityAlertText(
      alert.category,
      l10n: l10n,
    );
    var summaryText = CommunityAlertDisplayHelpers.sanitizeCommunityAlertText(alert.summary, l10n: l10n);
    var areaReasons = alert.riskReasons;

    if (isAreaSafety && safetyState != null) {
      areaVerdict = SafetyVerdictHelper.fromScore(
        l10n,
        score: safetyState!.safetyScore,
        riskLabel: safetyState!.riskLabel,
        summary: safetyState!.summary,
      );
      summaryText = CommunityAlertDisplayHelpers.sanitizeCommunityAlertText(
        areaVerdict.summary,
        l10n: l10n,
      );
      areaReasons = SafetyVerdictHelper.buildRiskReasons(
        l10n,
        contributingFactors: safetyState!.contributingFactors,
        dimensions: safetyState!.dimensions,
        riskReasonsFromAlert: alert.riskReasons,
        recommendations: safetyState!.recommendations,
        relatedAlerts: safetyState!.communityAlerts,
        nearbyPoliceCount: safetyState!.nearbyPoliceCount,
        nearbyHospitalCount: safetyState!.nearbyHospitalCount,
        nearbySupportCount: safetyState!.nearbySupportCount,
        limitedAssessmentNote: safetyState!.limitedAssessmentMessage,
        verdictLevel: areaVerdict.level,
        ensureForRiskyArea: areaVerdict.showRiskReasons,
      );
    } else if (isAreaSafety) {
      areaVerdict = SafetyVerdictHelper.fromScore(
        l10n,
        score: alert.priority == 'critical'
            ? 40
            : alert.priority == 'caution'
            ? 58
            : 78,
        riskLabel: alert.verdictHeadline,
        summary: alert.summary,
      );
      summaryText = CommunityAlertDisplayHelpers.sanitizeCommunityAlertText(
        areaVerdict.summary,
        l10n: l10n,
      );
      areaReasons = SafetyVerdictHelper.buildRiskReasons(
        l10n,
        contributingFactors: const [],
        dimensions: const [],
        riskReasonsFromAlert: alert.riskReasons,
        verdictLevel: areaVerdict.level,
        ensureForRiskyArea: areaVerdict.showRiskReasons,
      );
    }

    final color = CommunityAlertDisplayHelpers.colorForCommunityAlert(alert.priority);
    final icon = CommunityAlertDisplayHelpers.iconForCommunityAlert(alert.priority, displayCategory);
    final badgeLabel = isAreaSafety && areaVerdict != null
        ? areaVerdict.headline
        : alert.priority == 'critical'
        ? l10n.t('priorityCritical')
        : alert.priority == 'caution'
        ? l10n.t('priorityCaution')
        : l10n.t('priorityInfo');
    final priorityBgColor = alert.priority == 'critical'
        ? const Color(0xFFB91C1C)
        : alert.priority == 'caution'
        ? const Color(0xFFB45309)
        : const Color(0xFF1D4ED8);
    final now = DateTime.now();
    final diff = now.difference(alert.timestamp);
    final timeAgo = diff.inMinutes < 1
        ? l10n.t('timeJustNow')
        : diff.inMinutes < 60
        ? l10n.t('timeMinutesAgo').replaceAll('{count}', '${diff.inMinutes}')
        : diff.inHours < 24
        ? l10n.t('timeHoursAgo').replaceAll('{count}', '${diff.inHours}')
        : l10n.t('timeDaysAgo').replaceAll('{count}', '${diff.inDays}');
    final distanceLabel = alert.distanceMeters == 0
        ? l10n.t('currentLocationLabel')
        : alert.distanceMeters >= 1000
        ? '${(alert.distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${alert.distanceMeters} m';

    return PoppingAlertCard(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: isLight ? 0.20 : 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isLight ? 0.08 : 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isLight ? 0.06 : 0.10),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isLight ? 0.14 : 0.20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                      displayCategory,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isLight ? const Color(0xFF172235) : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: priorityBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: 13,
                    color: color.withValues(alpha: 0.80),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distanceLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: isLight ? const Color(0xFF94A3B8) : Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLight ? const Color(0xFF64748B) : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                summaryText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isLight
                      ? const Color(0xFF1E293B)
                      : Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ),
            if (isAreaSafety &&
                areaVerdict != null &&
                areaVerdict.showRiskReasons &&
                areaReasons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: SafetyRiskReasonsExpansion(
                  reasons: areaReasons,
                  accentColor: areaVerdict.tone,
                  isLight: isLight,
                ),
              ),
            if (isAreaSafety && alert.dataSource != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLight ? const Color(0xFFE2E8F0) : Colors.white12,
                    ),
                  ),
                  child: Text(
                    CommunityAlertDisplayHelpers.labelForDataSource(
                      AppLocalizations.of(context),
                      alert.dataSource!,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isLight ? const Color(0xFF475569) : Colors.white70,
                    ),
                  ),
                ),
              ),
            if (!isAreaSafety && alert.dataSource != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (alert.dataSource != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLight
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLight
                                ? const Color(0xFFE2E8F0)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          CommunityAlertDisplayHelpers.labelForDataSource(
                      AppLocalizations.of(context),
                      alert.dataSource!,
                    ),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? const Color(0xFF475569)
                                : Colors.white70,
                          ),
                          ),
                        ),
                  ],
                ),
              ),
            if (alert.disclaimer != null && alert.disclaimer!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Text(
                  l10n.localizeDynamic(alert.disclaimer),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                    color: isLight ? const Color(0xFF64748B) : Colors.white54,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isLight ? 0.07 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.localizeDynamic(alert.recommendedAction),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isLight
                              ? const Color(0xFF334158)
                              : Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
