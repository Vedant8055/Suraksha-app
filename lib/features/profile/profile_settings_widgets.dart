import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Language selector card extracted from profile screen (same UI).
class ProfileLanguageSelector extends StatelessWidget {
  const ProfileLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.profileText,
    required this.profileMuted,
    required this.isLight,
    required this.onChanged,
  });

  final AppLanguage selectedLanguage;
  final Color profileText;
  final Color profileMuted;
  final bool isLight;
  final ValueChanged<AppLanguage?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (AppLanguage.english, l10n.t('english'), Icons.language_rounded),
      (AppLanguage.hindi, l10n.t('hindi'), Icons.translate_rounded),
      (AppLanguage.marathi, l10n.t('marathi'), Icons.auto_awesome_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isLight ? Colors.white : AppTheme.cardColor,
        border: Border.all(
          color: isLight
              ? const Color(0xFFDCE5F6)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('languageSelectionTitle'),
            style: TextStyle(
              color: profileText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.t('contentLanguage'),
            style: TextStyle(color: profileMuted, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: options
                .map(
                  (option) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: option.$1 == AppLanguage.marathi ? 0 : 8,
                      ),
                      child: _ProfileLanguageButton(
                        label: option.$2,
                        icon: option.$3,
                        selected: selectedLanguage == option.$1,
                        isLight: isLight,
                        onTap: onChanged == null
                            ? null
                            : () => onChanged!(option.$1),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileLanguageButton extends StatelessWidget {
  const _ProfileLanguageButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isLight,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isLight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = selected
        ? AppTheme.primaryColor
        : (isLight ? const Color(0xFFF1F5FE) : const Color(0xFF0E1727));
    final textColor = selected
        ? Colors.white
        : (isLight ? const Color(0xFF172235) : Colors.white);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF1D8CF8), Color(0xFF2ED6C5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : baseColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : (isLight
                        ? const Color(0xFFD4E0F3)
                        : Colors.white.withValues(alpha: 0.08)),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.26),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings/info row extracted from profile screen (same UI).
class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF172235) : Colors.white;
    final mutedColor = isLight ? const Color(0xFF5F6F8A) : Colors.white38;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isLight ? const Color(0xFFDCE5F6) : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isLight ? 0.10 : 0.18,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, size: 20, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact status chip used on the daily route guard card.
class ProfileRouteChip extends StatelessWidget {
  const ProfileRouteChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isLight ? 0.10 : 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isLight ? const Color(0xFF172235) : Colors.white,
              fontSize: 10.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
