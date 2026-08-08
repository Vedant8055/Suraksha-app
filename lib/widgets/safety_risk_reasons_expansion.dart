import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/dashboard/emergency_services_scan_service.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
class SafetyRiskReasonsExpansion extends StatefulWidget {
  final List<String> reasons;
  final Color accentColor;
  final bool isLight;

  const SafetyRiskReasonsExpansion({
    super.key,
    required this.reasons,
    required this.accentColor,
    required this.isLight,
  });

  @override
  State<SafetyRiskReasonsExpansion> createState() =>
      _SafetyRiskReasonsExpansionState();
}

class _SafetyRiskReasonsExpansionState extends State<SafetyRiskReasonsExpansion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.reasons.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final titleColor = widget.isLight
        ? const Color(0xFF334155)
        : Colors.white.withValues(alpha: 0.92);
    final bodyColor = widget.isLight
        ? const Color(0xFF475569)
        : Colors.white.withValues(alpha: 0.78);

    return Material(
      color: widget.accentColor.withValues(alpha: widget.isLight ? 0.06 : 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: widget.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.t('safetyWhyNotSafeTitle'),
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.accentColor,
                    size: 22,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                ...widget.reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              color: bodyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SafetyServiceCountLine {
  const SafetyServiceCountLine({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
}

class SafetyIntelligenceDetailsExpansion extends StatefulWidget {
  final String title;
  final List<String> reasons;
  final String actionTitle;
  final String actionText;
  final Color accentColor;
  final bool isLight;
  final NearbyEmergencyServicesSnapshot? emergencyServices;
  final String? emergencyServicesTitle;

  const SafetyIntelligenceDetailsExpansion({
    super.key,
    required this.title,
    required this.reasons,
    required this.actionTitle,
    required this.actionText,
    required this.accentColor,
    required this.isLight,
    this.emergencyServices,
    this.emergencyServicesTitle,
  });

  @override
  State<SafetyIntelligenceDetailsExpansion> createState() =>
      _SafetyIntelligenceDetailsExpansionState();
}

class _SafetyIntelligenceDetailsExpansionState
    extends State<SafetyIntelligenceDetailsExpansion> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final hasReasons = widget.reasons.isNotEmpty;
    final services = widget.emergencyServices;
    final hasServices = services != null;
    final titleColor = widget.isLight
        ? const Color(0xFF334155)
        : Colors.white.withValues(alpha: 0.92);
    final bodyColor = widget.isLight
        ? const Color(0xFF475569)
        : Colors.white.withValues(alpha: 0.78);

    final l10n = AppLocalizations.of(context);
    final serviceLines = hasServices
        ? <SafetyServiceCountLine>[
            SafetyServiceCountLine(
              icon: Icons.local_police_rounded,
              label: l10n.t('servicePolice'),
              count: services.policeCount,
              color: const Color(0xFF2563EB),
            ),
            SafetyServiceCountLine(
              icon: Icons.local_hospital_rounded,
              label: l10n.t('serviceHospitals'),
              count: services.hospitalCount,
              color: const Color(0xFFE11D48),
            ),
            SafetyServiceCountLine(
              icon: Icons.local_pharmacy_rounded,
              label: l10n.t('servicePharmacies'),
              count: services.pharmacyCount,
              color: const Color(0xFF0F766E),
            ),
            SafetyServiceCountLine(
              icon: Icons.local_gas_station_rounded,
              label: l10n.t('servicePetrolPumps'),
              count: services.petrolPumpCount,
              color: const Color(0xFFD97706),
            ),
            SafetyServiceCountLine(
              icon: Icons.wc_rounded,
              label: l10n.t('serviceWashrooms'),
              count: services.washroomCount,
              color: const Color(0xFF7C3AED),
            ),
            SafetyServiceCountLine(
              icon: Icons.bloodtype_rounded,
              label: l10n.t('serviceBloodBanks'),
              count: services.bloodBankCount,
              color: const Color(0xFFBE123C),
            ),
          ]
        : const <SafetyServiceCountLine>[];

    return Material(
      color: widget.accentColor.withValues(alpha: widget.isLight ? 0.06 : 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: widget.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasServices
                          ? (widget.emergencyServicesTitle ??
                                l10n.t('safetyEmergencyServicesWithin1Km'))
                          : hasReasons
                          ? widget.title
                          : widget.actionTitle,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.accentColor,
                    size: 22,
                  ),
                ],
              ),
              if (_expanded) ...[
                if (hasServices) ...[
                  const SizedBox(height: 10),
                  ...serviceLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(line.icon, size: 16, color: line.color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              line.label,
                              style: TextStyle(
                                color: bodyColor,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            SafetyVerdictHelper.formatCappedServiceCount(
                              line.count,
                            ),
                            style: TextStyle(
                              color: line.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (hasReasons) ...[
                  if (hasServices) ...[
                    const SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: widget.accentColor.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    const SizedBox(height: 8),
                  ],
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...widget.reasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reason,
                              style: TextStyle(
                                color: bodyColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (hasServices || hasReasons) ...[
                  const SizedBox(height: 4),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: widget.accentColor.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 10),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                Text(
                  widget.actionTitle,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.actionText,
                  style: TextStyle(
                    color: bodyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SafetyVerdictBadge extends StatelessWidget {
  final String headline;
  final Color tone;
  final bool compact;

  const SafetyVerdictBadge({
    super.key,
    required this.headline,
    required this.tone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        headline,
        style: TextStyle(
          color: tone,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
