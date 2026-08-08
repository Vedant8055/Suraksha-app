import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
class PoshHeroCard extends StatelessWidget {
  const PoshHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colors.card,
            Color.lerp(colors.card, accentColor, 0.08)!,
            Color.lerp(colors.card, accentColor, 0.14)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: accentColor.withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.mutedText,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class PoshInfoTile extends StatelessWidget {
  const PoshInfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.colors,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final PoshColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class PoshStudySectionCard extends StatelessWidget {
  const PoshStudySectionCard({
    super.key,
    required this.number,
    required this.title,
    required this.icon,
    required this.bullets,
  });

  final String number;
  final String title;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: AppTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $bullet',
                style: TextStyle(color: colors.mutedText, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PoshSmallPill extends StatelessWidget {
  const PoshSmallPill({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PoshAnswerOptionTile extends StatelessWidget {
  const PoshAnswerOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    return Material(
      color: colors.fieldFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : colors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                multiSelect
                    ? (selected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded)
                    : (selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded),
                color: selected ? AppTheme.primaryColor : colors.mutedText,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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

class PoshColors {
  final List<Color> backgroundGradient;
  final Color card;
  final Color fieldFill;
  final Color text;
  final Color mutedText;
  final Color border;

  PoshColors(BuildContext context)
    : backgroundGradient = Theme.of(context).brightness == Brightness.dark
          ? const [Color(0xFF06111F), Color(0xFF081628), Color(0xFF050B14)]
          : const [Color(0xFFF8FBFF), Color(0xFFF2F7FF), Color(0xFFEAF2FF)],
      card = Theme.of(context).colorScheme.surface,
      fieldFill = Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.04)
          : const Color(0xFFF1F5FB),
      text = Theme.of(context).colorScheme.onSurface,
      mutedText = Theme.of(context).brightness == Brightness.dark
          ? AppTheme.textSecondary
          : const Color(0xFF4E5F79),
      border = Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFD8E0EC);
}

class PoshQuizProgressRow extends StatelessWidget {
  const PoshQuizProgressRow({
    super.key,
    required this.levelCount,
    required this.passedLevels,
    required this.activeLevelIndex,
    required this.onLevelTap,
  });

  final int levelCount;
  final Set<int> passedLevels;
  final int activeLevelIndex;
  final void Function(int index, bool available) onLevelTap;

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    return Row(
      children: List.generate(levelCount, (index) {
        final passed = passedLevels.contains(index);
        final selected = index == activeLevelIndex;
        final available =
            index == 0 || passedLevels.contains(index - 1) || passed;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == levelCount - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onLevelTap(index, available),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF1D8CF8), Color(0xFF2ED6C5)],
                        )
                      : null,
                  color: selected ? null : colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: passed
                        ? const Color(0xFF2ED6C5)
                        : selected
                        ? Colors.transparent
                        : colors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      passed
                          ? Icons.check_circle_rounded
                          : available
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      color: selected ? Colors.white : AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.t('level')} ${index + 1}',
                      style: TextStyle(
                        color: selected ? Colors.white : colors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      passed
                          ? l10n.t('passed')
                          : available
                          ? l10n.t('available')
                          : l10n.t('locked'),
                      style: TextStyle(
                        color: selected ? Colors.white70 : colors.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
