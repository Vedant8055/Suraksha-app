/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Feature Toggle & Settings (Phase 2)

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
import '../navigation/sentinel_navigator.dart';
import '../widgets/sentinel_scaffold.dart';

/// Hub screen for SES navigation (control plane only).
class SentinelHubScreen extends ConsumerWidget {
  const SentinelHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(sentinelControllerProvider).isEnabled;
    final readiness =
        ref.watch(sentinelPermissionControllerProvider).readiness.displayLabel;
    return SentinelScaffold(
      title: SentinelStrings.moduleTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            enabled ? 'Status: Enabled' : 'Status: Disabled',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Readiness: ${enabled ? readiness : 'NOT READY'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'This hub is the control plane for Sentinel. '
            'No emergency evidence is collected in this phase.',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_rounded),
            title: const Text('Permission Status'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                SentinelNavigator.push(context, SentinelRoutes.permissions),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.checklist_rtl_rounded),
            title: const Text('Permission Setup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: enabled
                ? () => SentinelNavigator.push(
                      context,
                      SentinelRoutes.permissionWizard,
                    )
                : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Sentinel Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                SentinelNavigator.push(context, SentinelRoutes.settings),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline),
            title: const Text('Evidence Vault'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => SentinelNavigator.push(context, SentinelRoutes.vault),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Sentinel Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => SentinelNavigator.push(context, SentinelRoutes.info),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.monitor_heart_outlined),
            title: const Text('Sentinel System Status'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                SentinelNavigator.push(context, SentinelRoutes.status),
          ),
        ],
      ),
    );
  }
}
