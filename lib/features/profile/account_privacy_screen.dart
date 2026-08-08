import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class AccountPrivacyScreen extends ConsumerStatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  ConsumerState<AccountPrivacyScreen> createState() =>
      _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends ConsumerState<AccountPrivacyScreen> {
  bool _busy = false;

  Future<String?> _askPassword(String titleKey) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t(titleKey)),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.t('password'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.t('continue')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password == null || password.isEmpty) return null;
    return password;
  }

  Future<void> _run(Future<void> Function() action, String successKey) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t(successKey))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('privacyActionFailed'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadData() async {
    final password = await _askPassword('privacyDownloadTitle');
    if (password == null || !mounted) return;
    final data = await ref
        .read(authProvider.notifier)
        .exportAccountData(password: password);
    final encoded = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: encoded));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).t('privacyExportCopied')),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('privacyDeleteAccountTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('privacyDeleteAccountMessage')),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: l10n.t('privacyDeleteAccountConfirmLabel'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.t('password'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              confirmController.text.trim() == 'DELETE' &&
                  passwordController.text.isNotEmpty,
            ),
            child: Text(l10n.t('privacyDeleteAccountConfirm')),
          ),
        ],
      ),
    );
    final password = passwordController.text;
    confirmController.dispose();
    passwordController.dispose();
    if (confirmed != true || !mounted) return;
    await _run(
      () => ref.read(authProvider.notifier).deleteAccount(password: password),
      'privacyDeleteAccountDone',
    );
  }

  Future<void> _runWithPassword(
    Future<void> Function(String password) action,
    String titleKey,
    String successKey,
  ) async {
    final password = await _askPassword(titleKey);
    if (password == null || !mounted) return;
    await _run(() => action(password), successKey);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('accountPrivacyTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.t('accountPrivacySubtitle'),
            style: TextStyle(
              color: isLight ? const Color(0xFF64748B) : Colors.white70,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle(l10n.t('privacyDownloadTitle'), isLight),
          _actionTile(
            icon: Icons.download_rounded,
            title: l10n.t('privacyDownloadAction'),
            subtitle: l10n.t('privacyDownloadSubtitle'),
            onTap: _busy ? null : () => _run(_downloadData, 'privacyExportCopied'),
          ),
          const SizedBox(height: 18),
          _sectionTitle(l10n.t('privacyDeleteDataTitle'), isLight),
          _actionTile(
            icon: Icons.location_off_rounded,
            title: l10n.t('privacyDeleteLocation'),
            subtitle: l10n.t('privacyDeleteLocationSubtitle'),
            onTap: _busy
                ? null
                : () => _runWithPassword(
                      (password) => ref
                          .read(authProvider.notifier)
                          .deleteLocationData(password: password),
                      'privacyDeleteLocation',
                      'privacyDeleteLocationDone',
                    ),
          ),
          _actionTile(
            icon: Icons.medical_information_outlined,
            title: l10n.t('privacyDeleteMedical'),
            subtitle: l10n.t('privacyDeleteMedicalSubtitle'),
            onTap: _busy
                ? null
                : () => _runWithPassword(
                      (password) => ref
                          .read(authProvider.notifier)
                          .deleteMedicalData(password: password),
                      'privacyDeleteMedical',
                      'privacyDeleteMedicalDone',
                    ),
          ),
          _actionTile(
            icon: Icons.report_gmailerrorred_outlined,
            title: l10n.t('privacyDeleteIncidents'),
            subtitle: l10n.t('privacyDeleteIncidentsSubtitle'),
            onTap: _busy
                ? null
                : () => _runWithPassword(
                      (password) => ref
                          .read(authProvider.notifier)
                          .deleteIncidentData(password: password),
                      'privacyDeleteIncidents',
                      'privacyDeleteIncidentsDone',
                    ),
          ),
          _actionTile(
            icon: Icons.folder_delete_outlined,
            title: l10n.t('privacyDeleteEvidence'),
            subtitle: l10n.t('privacyDeleteEvidenceSubtitle'),
            onTap: _busy
                ? null
                : () => _runWithPassword(
                      (password) => ref
                          .read(authProvider.notifier)
                          .deleteEvidenceData(password: password),
                      'privacyDeleteEvidence',
                      'privacyDeleteEvidenceDone',
                    ),
          ),
          const SizedBox(height: 18),
          _sectionTitle(l10n.t('privacyDeleteAccountTitle'), isLight),
          _actionTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.t('privacyDeleteAccountConfirm'),
            subtitle: l10n.t('privacyDeleteAccountMessage'),
            destructive: true,
            onTap: _busy ? null : _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isLight ? const Color(0xFF172235) : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool destructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: destructive ? Colors.redAccent : AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: destructive ? Colors.redAccent : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
