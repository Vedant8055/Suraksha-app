/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Permissions & Feature Readiness (Phase 3)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/sentinel_routes.dart';
import '../constants/sentinel_strings.dart';
import '../controllers/sentinel_controller.dart';
import '../controllers/sentinel_permission_controller.dart';
import '../models/sentinel_enums.dart';
import '../navigation/sentinel_navigator.dart';
import 'sentinel_test_mode_banner.dart';

/// Profile-only SES control card (toggle, readiness, navigation).
class SentinelProfileCard extends ConsumerWidget {
  const SentinelProfileCard({super.key});

  Future<void> _onToggle(BuildContext context, WidgetRef ref, bool next) async {
    if (!next) {
      await ref.read(sentinelControllerProvider.notifier).setEnabled(false);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enable Sentinel Evidence System?'),
        content: const SingleChildScrollView(
          child: Text(
            'This feature is experimental.\n\n'
            'When enabled, during an SOS the application may later:\n'
            '• record emergency evidence\n'
            '• capture location\n'
            '• collect emergency metadata\n'
            '• encrypt evidence\n'
            '• upload securely to cloud\n\n'
            'None of these capabilities are implemented yet.\n'
            'This phase only enables the feature and prepares permissions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await ref.read(sentinelControllerProvider.notifier).setEnabled(true);
    if (!context.mounted) return;
    await SentinelNavigator.push(context, SentinelRoutes.permissionWizard);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.watch(sentinelControllerProvider);
    final permission = ref.watch(sentinelPermissionControllerProvider);
    final enabled = control.isEnabled;
    final loading = control.isLoading || permission.busy;
    final readiness = permission.readiness;
    final summary = permission.summary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardColor = isLight ? Colors.white : const Color(0xFF111B2E);
    final border = isLight
        ? const Color(0xFFDCE5F6)
        : Colors.white.withValues(alpha: 0.08);
    final titleColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final muted = isLight ? const Color(0xFF64748B) : Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardColor,
        border: Border.all(color: border),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  SentinelStrings.moduleTitle,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SentinelTestModeChip(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            SentinelStrings.profileSubtitle,
            style: TextStyle(color: muted, fontSize: 12.5, height: 1.35),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              enabled ? 'Sentinel enabled' : 'Sentinel disabled',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            value: enabled,
            onChanged: loading ? null : (v) => _onToggle(context, ref, v),
          ),
          Text(
            enabled
                ? 'Sentinel is enabled.\n\n'
                    'Evidence capture will only activate during SOS.\n\n'
                    'Current Status:\nTEST MODE'
                : 'Sentinel is disabled.\n'
                    'No emergency audio, photos or videos will be captured.',
            style: TextStyle(color: muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          _ReadinessBanner(
            enabled: enabled,
            label: readiness.displayLabel,
            level: readiness.level,
            titleColor: titleColor,
            isLight: isLight,
          ),
          const SizedBox(height: 12),
          _SettingsSummaryCard(
            enabled: enabled,
            readinessLabel: readiness.displayLabel,
            titleColor: titleColor,
            muted: muted,
            isLight: isLight,
          ),
          const SizedBox(height: 12),
          _PermissionStatusCard(
            camera: summary.camera.displayLabel,
            microphone: summary.microphone.displayLabel,
            location: summary.location.displayLabel,
            titleColor: titleColor,
            muted: muted,
            isLight: isLight,
            onCheck: () =>
                SentinelNavigator.push(context, SentinelRoutes.permissions),
            onSetup: enabled
                ? () => SentinelNavigator.push(
                      context,
                      SentinelRoutes.permissionWizard,
                    )
                : null,
          ),
          const SizedBox(height: 8),
          _NavTile(
            icon: Icons.info_outline_rounded,
            label: 'Learn More',
            onTap: () => SentinelNavigator.push(context, SentinelRoutes.info),
          ),
          _NavTile(
            icon: Icons.settings_outlined,
            label: 'Sentinel Settings',
            onTap: () =>
                SentinelNavigator.push(context, SentinelRoutes.settings),
          ),
          _NavTile(
            icon: Icons.lock_outline_rounded,
            label: 'Evidence Vault',
            onTap: () => SentinelNavigator.push(context, SentinelRoutes.vault),
          ),
          _NavTile(
            icon: Icons.monitor_heart_outlined,
            label: 'Sentinel System Status',
            onTap: () =>
                SentinelNavigator.push(context, SentinelRoutes.status),
          ),
          _NavTile(
            icon: Icons.open_in_new_rounded,
            label: 'Open Sentinel Hub',
            onTap: () => SentinelNavigator.push(context, SentinelRoutes.root),
          ),
        ],
      ),
    );
  }
}

class _ReadinessBanner extends StatelessWidget {
  const _ReadinessBanner({
    required this.enabled,
    required this.label,
    required this.level,
    required this.titleColor,
    required this.isLight,
  });

  final bool enabled;
  final String label;
  final SentinelReadinessLevel level;
  final Color titleColor;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      SentinelReadinessLevel.ready => const Color(0xFF16A34A),
      SentinelReadinessLevel.partiallyReady => const Color(0xFFD97706),
      SentinelReadinessLevel.notReady => const Color(0xFFDC2626),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: isLight ? 0.1 : 0.2),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Text(
            'Status',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            enabled ? label : 'NOT READY',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSummaryCard extends StatelessWidget {
  const _SettingsSummaryCard({
    required this.enabled,
    required this.readinessLabel,
    required this.titleColor,
    required this.muted,
    required this.isLight,
  });

  final bool enabled;
  final String readinessLabel;
  final Color titleColor;
  final Color muted;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0B1220),
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E8F0)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sentinel Settings',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _kv('Current Mode', 'TEST MODE', muted, titleColor),
          _kv('Status', enabled ? 'Enabled' : 'Disabled', muted, titleColor),
          _kv('Readiness', enabled ? readinessLabel : 'NOT READY', muted, titleColor),
          const SizedBox(height: 8),
          Text(
            'Future Features',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          _kv('Recording', 'Coming Soon', muted, titleColor),
          _kv('Encryption', 'Coming Soon', muted, titleColor),
          _kv('Cloud Upload', 'Coming Soon', muted, titleColor),
          _kv('Evidence Vault', 'Coming Soon', muted, titleColor),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color muted, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(k, style: TextStyle(color: muted, fontSize: 12.5))),
          Text(
            v,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionStatusCard extends StatelessWidget {
  const _PermissionStatusCard({
    required this.camera,
    required this.microphone,
    required this.location,
    required this.titleColor,
    required this.muted,
    required this.isLight,
    required this.onCheck,
    this.onSetup,
  });

  final String camera;
  final String microphone;
  final String location;
  final Color titleColor;
  final Color muted;
  final bool isLight;
  final VoidCallback onCheck;
  final VoidCallback? onSetup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0B1220),
        border: Border.all(
          color: isLight
              ? const Color(0xFFE2E8F0)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permission Status',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _row('Camera', camera, muted, titleColor),
          _row('Microphone', microphone, muted, titleColor),
          _row('Location', location, muted, titleColor),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCheck,
              child: const Text('Check Permissions'),
            ),
          ),
          if (onSetup != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onSetup,
                child: const Text('Permission Setup'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color muted, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: muted, fontSize: 12.5)),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
