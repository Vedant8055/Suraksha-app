import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

/// Warning banner shown over the safety map when the device appears to be
/// offline, offering quick-dial actions for emergency numbers.
class MapOfflineBanner extends StatelessWidget {
  const MapOfflineBanner({
    super.key,
    required this.isSearchOpen,
    required this.isLight,
    required this.onDialPolice,
    required this.onDialHelpline,
  });

  final bool isSearchOpen;
  final bool isLight;
  final VoidCallback onDialPolice;
  final VoidCallback onDialHelpline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Positioned(
      top: isSearchOpen ? 78 : 16,
      left: 16,
      right: 72,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFFFF7ED) : const Color(0xFF3F1D0D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('mapOfflineBannerTitle'),
                style: TextStyle(
                  color: isLight ? const Color(0xFF9A3412) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.t('mapOfflineBannerBody'),
                style: TextStyle(
                  color: isLight
                      ? const Color(0xFF9A3412).withValues(alpha: 0.85)
                      : Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OfflineActionChip(
                    label: l10n.t('policeEmergency'),
                    onTap: onDialPolice,
                  ),
                  OfflineActionChip(
                    label: l10n.t('womenHelpline'),
                    onTap: onDialHelpline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill-shaped action chip used by the offline banner (and the
/// locating view) to expose emergency quick-dial actions.
class OfflineActionChip extends StatelessWidget {
  const OfflineActionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
