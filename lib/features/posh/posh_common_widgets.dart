import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_legal_meta.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Prominent non-legal-advice disclaimer for POSH surfaces.
class PoshLegalDisclaimerBanner extends StatelessWidget {
  const PoshLegalDisclaimerBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFF7ED) : const Color(0xFF3F1D0D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gavel_rounded, color: Color(0xFFEA580C), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.t('legalDisclaimer'),
              style: TextStyle(
                color: isLight ? const Color(0xFF9A3412) : const Color(0xFFFFE6D5),
                height: 1.35,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12.5 : 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows statute source and last-reviewed date.
class PoshLegalSourceCard extends StatelessWidget {
  const PoshLegalSourceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('poshLegalSourceLabel'),
            style: TextStyle(
              color: isLight ? const Color(0xFF0F172A) : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            PoshLegalMeta.sourceShort,
            style: TextStyle(
              color: isLight ? const Color(0xFF334155) : Colors.white70,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.t('poshLegalSourceNote'),
            style: TextStyle(
              color: isLight ? const Color(0xFF64748B) : Colors.white60,
              height: 1.35,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n
                .t('poshLastReviewed')
                .replaceFirst('{date}', PoshLegalMeta.lastReviewedLabel),
            style: TextStyle(
              color: isLight ? const Color(0xFF475569) : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Call 112 / open Suraksha SOS when danger language is detected.
class PoshEmergencyEscalationBanner extends StatelessWidget {
  const PoshEmergencyEscalationBanner({
    super.key,
    required this.onOpenSos,
  });

  final VoidCallback onOpenSos;

  Future<void> _call112() async {
    final uri = Uri(scheme: 'tel', path: '112');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('poshDangerDetectedTitle'),
            style: const TextStyle(
              color: Color(0xFFB91C1C),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('poshDangerDetectedMessage'),
            style: const TextStyle(
              color: Color(0xFF7F1D1D),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _call112,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: Text(l10n.t('poshCall112')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenSos,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    minimumSize: const Size(0, 44),
                  ),
                  icon: const Icon(Icons.sos_rounded),
                  label: Text(l10n.t('poshOpenSos')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PoshHubDestinationCard extends StatelessWidget {
  const PoshHubDestinationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isLight ? const Color(0xFF0F172A) : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isLight
                            ? const Color(0xFF64748B)
                            : Colors.white70,
                        height: 1.3,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLight ? const Color(0xFF94A3B8) : Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
