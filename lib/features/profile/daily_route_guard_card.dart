import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_format_helpers.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_settings_widgets.dart';
import 'package:suraksha_women_safety_app/features/routes/route_safety_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/widgets/safety_risk_reasons_expansion.dart';

/// Daily Route Guard summary card extracted from `ProfileScreen` (Phase 2
/// structure-only extraction). Identical UI to the original
/// `_buildDailyRouteGuardCard` private method. Watches [routeSafetyProvider]
/// directly, matching the original behavior.
class DailyRouteGuardCard extends ConsumerWidget {
  const DailyRouteGuardCard({super.key, required this.onOpenMap});

  /// Invoked when the "Open map" action is pressed (opens `SafetyMapScreen`
  /// via the screen's premium transition, as in the original).
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Select only the fields this card actually displays (excluding the
    // once-a-second `countdownSeconds` ticker, which is watched separately
    // below) so unrelated route-safety state changes rebuild this card less
    // often.
    final routeState = ref.watch(
      routeSafetyProvider.select(
        (s) => (
          monitoringActive: s.monitoringActive,
          learningRoute: s.learningRoute,
          hasLearnedRoute: s.hasLearnedRoute,
          routeLogCount: s.routeLogCount,
          riskLabel: s.riskLabel,
          statusMessage: s.statusMessage,
          pendingSafetyCheck: s.pendingSafetyCheck,
          deviationMeters: s.deviationMeters,
          riskFactors: s.riskFactors,
          lastPosition: s.lastPosition,
          monitoringMapRoute: s.monitoringMapRoute,
          activeMapRoutePointCount: s.activeMapRoutePointCount,
          activeMapRouteReason: s.activeMapRouteReason,
          routineProfileCount: s.routineProfileCount,
          learningProgressLabel: s.learningProgressLabel,
          intelligenceLimited: s.intelligenceLimited,
        ),
      ),
    );
    final isLight = Theme.of(context).brightness == Brightness.light;
    final verdict = SafetyVerdictHelper.fromRouteState(
      l10n,
      pendingSafetyCheck: routeState.pendingSafetyCheck,
      riskLabel: routeState.riskLabel,
      hasLearnedRoute: routeState.hasLearnedRoute,
      learningRoute: routeState.learningRoute,
    );
    final tone = verdict.tone;
    final confidenceKey = ProfileFormatHelpers.routeConfidenceKey(
      RouteSafetyState(
        intelligenceLimited: routeState.intelligenceLimited,
        hasLearnedRoute: routeState.hasLearnedRoute,
        routeLogCount: routeState.routeLogCount,
      ),
    );
    final deviation = routeState.deviationMeters;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [Colors.white, Color.lerp(const Color(0xFFF5FAFF), tone, 0.08)!]
              : [
                  Color.lerp(AppTheme.cardColor, tone, 0.12)!,
                  const Color(0xFF101827),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: routeState.pendingSafetyCheck
              ? tone.withValues(alpha: 0.5)
              : isLight
              ? const Color(0xFFDCE5F6)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: isLight ? 0.15 : 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.route_rounded, color: tone, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeState.pendingSafetyCheck
                          ? l10n.t('safeRouteChanged')
                          : l10n.t('dailyRouteGuard'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF172235) : Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.localizeStatusMessage(routeState.statusMessage),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLight
                            ? const Color(0xFF627491)
                            : Colors.white.withValues(alpha: 0.72),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SafetyVerdictBadge(
                headline: verdict.headline,
                tone: tone,
                compact: true,
              ),
            ],
          ),
          if (routeState.learningProgressLabel != null &&
              !routeState.monitoringMapRoute) ...[
            const SizedBox(height: 8),
            Text(
              l10n.localizeDynamic(routeState.learningProgressLabel),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF3B5A84)
                    : Colors.white.withValues(alpha: 0.74),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ProfileRouteChip(
                icon: routeState.monitoringActive
                    ? Icons.sensors_rounded
                    : Icons.sensors_off_rounded,
                label: l10n.t(
                  routeState.monitoringActive
                      ? 'routeGuardMonitoringActive'
                      : 'routeGuardMonitoringInactive',
                ),
                color: routeState.monitoringActive
                    ? const Color(0xFF15803D)
                    : const Color(0xFF64748B),
              ),
              ProfileRouteChip(
                icon: routeState.hasLearnedRoute
                    ? Icons.task_alt_rounded
                    : Icons.sync_rounded,
                label: l10n.t(
                  routeState.hasLearnedRoute
                      ? 'routeGuardRouteLearned'
                      : 'routeGuardRouteNotLearned',
                ),
                color: routeState.hasLearnedRoute
                    ? const Color(0xFF15803D)
                    : const Color(0xFF3B82F6),
              ),
              ProfileRouteChip(
                icon: Icons.shield_rounded,
                label: l10n.localizeRiskLabel(routeState.riskLabel),
                color: tone,
              ),
              ProfileRouteChip(
                icon: Icons.verified_outlined,
                label: l10n
                    .t('routeGuardDataConfidence')
                    .replaceAll('{level}', l10n.t(confidenceKey)),
                color: const Color(0xFF8E7CF4),
              ),
              if (routeState.lastPosition != null)
                ProfileRouteChip(
                  icon: Icons.schedule_rounded,
                  label: l10n
                      .t('routeGuardLastChecked')
                      .replaceAll(
                        '{time}',
                        ProfileFormatHelpers.formatRouteLastChecked(
                          routeState.lastPosition!,
                        ),
                      ),
                  color: const Color(0xFF64748B),
                ),
              ProfileRouteChip(
                icon: routeState.hasLearnedRoute
                    ? Icons.route_rounded
                    : Icons.sync_rounded,
                label: routeState.monitoringMapRoute
                    ? l10n
                          .t('routeGuardMapPoints')
                          .replaceAll(
                            '{count}',
                            '${routeState.activeMapRoutePointCount}',
                          )
                    : routeState.routineProfileCount > 0
                    ? l10n
                          .t('routeGuardRoutinesLearned')
                          .replaceAll(
                            '{count}',
                            '${routeState.routineProfileCount}',
                          )
                    : routeState.hasLearnedRoute
                    ? l10n
                          .t('routeGuardRouteLogs')
                          .replaceAll(
                            '{count}',
                            '${routeState.routeLogCount}',
                          )
                    : l10n.t('routeGuardLearningRoute'),
                color: const Color(0xFF3B82F6),
              ),
              if (routeState.intelligenceLimited)
                ProfileRouteChip(
                  icon: Icons.info_outline_rounded,
                  label: l10n.t('routeGuardIntelligenceLimited'),
                  color: const Color(0xFF8E7CF4),
                ),
              if (deviation != null)
                ProfileRouteChip(
                  icon: Icons.social_distance_rounded,
                  label: l10n
                      .t('routeGuardMetersFromPattern')
                      .replaceAll('{meters}', '${deviation.round()}'),
                  color: routeState.pendingSafetyCheck
                      ? const Color(0xFFE53935)
                      : const Color(0xFF8E7CF4),
                ),
            ],
          ),
          if (routeState.riskFactors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              routeState.riskFactors
                  .take(2)
                  .map(l10n.localizeDynamic)
                  .join(' | '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF546784)
                    : Colors.white.withValues(alpha: 0.66),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (routeState.monitoringMapRoute &&
              routeState.activeMapRouteReason != null) ...[
            const SizedBox(height: 6),
            Text(
              routeState.activeMapRouteReason!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF546784)
                    : Colors.white.withValues(alpha: 0.66),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    unawaited(
                      ref.read(routeSafetyProvider.notifier).refreshNow(),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(l10n.t('refresh')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: Text(l10n.t('openMap')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await ref
                    .read(routeSafetyProvider.notifier)
                    .resetLearnedRoute();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.t('homeWorkplaceRouteLearningReset')),
                  ),
                );
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: Text(l10n.t('resetHomeWorkplaceRouteLearning')),
              style: TextButton.styleFrom(
                foregroundColor: isLight
                    ? const Color(0xFF172235)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
            ),
          ),
          if (routeState.pendingSafetyCheck) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE53935,
                ).withValues(alpha: isLight ? 0.08 : 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final countdownSeconds = ref.watch(
                          routeSafetyProvider.select(
                            (s) => s.countdownSeconds,
                          ),
                        );
                        final countdownText =
                            ProfileFormatHelpers.formatRouteCountdown(
                          l10n,
                          countdownSeconds,
                        );
                        return Text(
                          '${l10n.t('safetyCheckEndsIn')} $countdownText ${l10n.t('unlessYouConfirm')}',
                          style: TextStyle(
                            color: isLight
                                ? const Color(0xFF6B1D1D)
                                : Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(routeSafetyProvider.notifier).markUserSafe(),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: Text(l10n.t('imSafe')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2FB79E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () {
                      unawaited(
                        ref
                            .read(routeSafetyProvider.notifier)
                            .requestEmergencyHelp(),
                      );
                    },
                    icon: const Icon(Icons.sos_rounded, size: 16),
                    label: Text(l10n.t('routeGuardNeedHelp')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
