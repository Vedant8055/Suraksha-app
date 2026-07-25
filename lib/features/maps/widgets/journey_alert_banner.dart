import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

/// Banner shown over the safety map during an active journey when the
/// safety monitor has an in-app alert or reroute hint to surface.
class JourneyAlertBanner extends StatelessWidget {
  const JourneyAlertBanner({
    super.key,
    required this.safetyState,
    required this.isLight,
  });

  final SafetyMonitorState safetyState;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final alert = safetyState.journeyInAppAlert;
    final isCritical = alert?.priority == 'critical';
    final color = isCritical
        ? const Color(0xFFB91C1C)
        : const Color(0xFFB45309);
    final title =
        alert?.title ?? AppLocalizations.of(context).t('journeyRerouteHint');
    final body = alert?.body ?? safetyState.rerouteHint ?? '';

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: color.withValues(alpha: isLight ? 0.12 : 0.22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isLight ? const Color(0xFF172235) : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: isLight ? const Color(0xFF475569) : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
