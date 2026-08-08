import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

/// Emergency contact row extracted from `ProfileScreen` (Phase 2
/// structure-only extraction). Identical UI to the original
/// `_buildContactItem` private method.
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

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF172235) : Colors.white;
    final mutedColor = isLight ? const Color(0xFF5F6F8A) : Colors.white38;
    return Container(
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
            child: const Icon(
              Icons.contact_phone,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                if (contact.isPrimary)
                  Text(
                    AppLocalizations.of(context).t('primaryEmergencyContact'),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  '${contact.phone} • ${contact.relation}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).t('sendTestSms'),
            onPressed: enabled ? onTestSms : null,
            icon: const Icon(Icons.sms_outlined, color: AppTheme.primaryColor),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).t('makePrimaryContact'),
            onPressed: enabled && !contact.isPrimary ? onMakePrimary : null,
            icon: Icon(
              contact.isPrimary ? Icons.star_rounded : Icons.star_border_rounded,
              color: contact.isPrimary ? Colors.amber : Colors.white70,
            ),
          ),
          IconButton(
            onPressed: enabled ? onEdit : null,
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
          ),
          IconButton(
            onPressed: enabled ? onDelete : null,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
