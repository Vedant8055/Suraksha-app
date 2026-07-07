import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/data/cyber_law_data.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/models/cybercrime_models.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cybercrime_utils.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cybercrime_widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

/// Deepfake emergency guidance merged into the Learn tab (replaces standalone tab).
class CyberDeepfakeEmergencyPanel extends StatelessWidget {
  const CyberDeepfakeEmergencyPanel({
    super.key,
    required this.resources,
    this.onOpenFullGuide,
    this.compact = false,
  });

  final DeepfakeResources resources;
  final VoidCallback? onOpenFullGuide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final title = resources.title.isNotEmpty
        ? resources.title
        : l10n.t('deepfakeEmergencySupportTitle');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isLight ? Colors.white : const Color(0xFF1A2536),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFE53935),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isLight
                            ? const Color(0xFF0F172A)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.t('deepfakeSubtitle'),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isLight
                            ? const Color(0xFF516078)
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CyberWarningBanner(text: l10n.t('deepfakeWarning')),
          if (!compact) ...[
            const SizedBox(height: 10),
            ...resources.sections.take(3).map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: isLight
                            ? const Color(0xFF334155)
                            : Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.body,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isLight
                            ? const Color(0xFF516078)
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...(resources.helplines.isEmpty
                  ? [
                      CyberActionButton(
                        label: l10n.t('call1930'),
                        icon: Icons.call,
                        onTap: () => dialPhoneNumber('1930'),
                      ),
                      CyberActionButton(
                        label: l10n.t('police100'),
                        icon: Icons.local_police_rounded,
                        onTap: () => dialPhoneNumber('100'),
                      ),
                    ]
                  : resources.helplines.map(
                      (helpline) => CyberActionButton(
                        label: helpline.label,
                        icon: Icons.call,
                        onTap: () => dialPhoneNumber(helpline.value),
                      ),
                    )),
              CyberActionButton(
                label: l10n.t('cyberPortal'),
                icon: Icons.open_in_new_rounded,
                onTap: () => openExternalLink('https://cybercrime.gov.in'),
              ),
              if (onOpenFullGuide != null)
                CyberActionButton(
                  label: l10n.t('cyberLawDeepfakeFullGuide'),
                  icon: Icons.menu_book_rounded,
                  onTap: onOpenFullGuide!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

CyberLawTopic? deepfakeLawTopic() {
  for (final topic in kCyberLawTopics) {
    if (topic.id == 'deepfakeThreat') return topic;
  }
  return null;
}
