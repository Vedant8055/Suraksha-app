import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_screen.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/widgets/premium_dialog.dart';

Future<bool> hasSavedEmergencyContacts(WidgetRef ref) {
  return ref.read(emergencyContactsProvider.notifier).hasSavedContacts();
}

Future<void> showMissingEmergencyContactsDialog(
  BuildContext context, {
  bool barrierDismissible = true,
}) async {
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context);
  await showPremiumDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    title: l10n.t('saveEmergencyContactFirst'),
    message: l10n.t('saveEmergencyContactFirstMessage'),
    icon: Icons.contact_emergency_rounded,
    accentColor: const Color(0xFFE53935),
    actions: [
      PremiumDialogAction(
        label: l10n.t('later'),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      PremiumDialogAction(
        label: l10n.t('openContacts'),
        isPrimary: true,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          if (!context.mounted) return;
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    ],
  );
}

Future<bool> ensureEmergencyContactsSaved(
  BuildContext context,
  WidgetRef ref,
) async {
  final hasContacts = await hasSavedEmergencyContacts(ref);
  if (hasContacts) return true;

  if (context.mounted) {
    await showMissingEmergencyContactsDialog(context);
  }
  return false;
}
