import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/auth/indian_phone_utils.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Premium emergency-contact card used on Profile.
class EmergencyContactItem extends StatelessWidget {
  const EmergencyContactItem({
    super.key,
    required this.contact,
    required this.enabled,
    this.onTestSms,
    this.onMakePrimary,
    this.onEdit,
    this.onDelete,
  });

  final EmergencyContact contact;

  /// Mirrors `!_isSaving` from the original screen.
  final bool enabled;
  final VoidCallback? onTestSms;
  final VoidCallback? onMakePrimary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String get _initials {
    final parts = contact.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF101828) : Colors.white;
    final mutedColor = isLight ? const Color(0xFF667085) : const Color(0xFF9BB0CC);
    final hairline = isLight
        ? const Color(0xFFE4EAF3)
        : Colors.white.withValues(alpha: 0.08);
    final phoneDisplay = IndianPhoneUtils.formatDisplay(contact.phone);
    final phoneLabel = phoneDisplay.isEmpty ? contact.phone : phoneDisplay;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF7FAFF)]
              : const [Color(0xFF152238), Color(0xFF101A2D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: contact.isPrimary
                            ? const [Color(0xFF1D8CF8), Color(0xFF2ED6C5)]
                            : isLight
                                ? const [Color(0xFF2B3A55), Color(0xFF1D2B44)]
                                : const [Color(0xFF2A3D5C), Color(0xFF1A2A46)],
                      ),
                    ),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  if (contact.isPrimary)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white : AppTheme.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFF2ED6C5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          label: contact.relation,
                          isLight: isLight,
                        ),
                        if (contact.isPrimary)
                          _MetaChip(
                            label: l10n.t('primaryEmergencyContact'),
                            isLight: isLight,
                            emphasized: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: hairline),
          const SizedBox(height: 8),
          Row(
            children: [
              _ActionButton(
                tooltip: l10n.t('sendTestSms'),
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: enabled ? onTestSms : null,
                isLight: isLight,
              ),
              _ActionButton(
                tooltip: l10n.t('makePrimaryContact'),
                icon: contact.isPrimary
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                active: contact.isPrimary,
                onPressed: enabled && !contact.isPrimary ? onMakePrimary : null,
                isLight: isLight,
              ),
              _ActionButton(
                tooltip: l10n.t('edit'),
                icon: Icons.edit_outlined,
                onPressed: enabled ? onEdit : null,
                isLight: isLight,
              ),
              const Spacer(),
              _ActionButton(
                tooltip: l10n.t('delete'),
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onPressed: enabled ? onDelete : null,
                isLight: isLight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.isLight,
    this.emphasized = false,
  });

  final String label;
  final bool isLight;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final bg = emphasized
        ? AppTheme.primaryColor.withValues(alpha: isLight ? 0.10 : 0.18)
        : (isLight ? const Color(0xFFF2F4F8) : Colors.white.withValues(alpha: 0.06));
    final fg = emphasized
        ? AppTheme.primaryColor
        : (isLight ? const Color(0xFF475467) : const Color(0xFFB6C6DE));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.isLight,
    this.onPressed,
    this.active = false,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final bool isLight;
  final VoidCallback? onPressed;
  final bool active;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (destructive) {
      color = const Color(0xFFE25563);
    } else if (active) {
      color = const Color(0xFFD4A017);
    } else {
      color = isLight ? const Color(0xFF44556C) : const Color(0xFFC5D4EA);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isLight
              ? const Color(0xFFF4F7FB)
              : Colors.white.withValues(alpha: 0.05),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, size: 18, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
