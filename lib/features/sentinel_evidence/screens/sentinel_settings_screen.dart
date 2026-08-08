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

import '../constants/sentinel_strings.dart';
import '../controllers/sentinel_controller.dart';
import '../controllers/sentinel_permission_controller.dart';
import '../constants/sentinel_routes.dart';
import '../navigation/sentinel_navigator.dart';
import '../widgets/sentinel_scaffold.dart';

/// SES settings with permissions + system readiness (read-only advanced fields).
class SentinelSettingsScreen extends ConsumerWidget {
  const SentinelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.watch(sentinelControllerProvider);
    final permission = ref.watch(sentinelPermissionControllerProvider);
    final settings = control.settings;
    final summary = permission.summary;
    final readiness = permission.readiness;

    return SentinelScaffold(
      title: 'Sentinel Settings',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Feature Enabled', settings.isSentinelEnabled ? 'Yes' : 'No'),
          _row('Test Mode', settings.isSentinelTestMode ? 'Yes' : 'No'),
          _row('Module Version', SentinelStrings.moduleVersion),
          _row('Build', SentinelStrings.buildLabel),
          _row('Settings Version', settings.settingsVersion.toString()),
          _row(
            'Last Updated',
            settings.lastUpdated?.toLocal().toString() ?? '—',
          ),
          const Divider(height: 28),
          const Text(
            'System Readiness',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 10),
          _row('Sentinel', settings.isSentinelEnabled ? 'Enabled' : 'Disabled'),
          _row('Camera', summary.camera.displayLabel),
          _row('Microphone', summary.microphone.displayLabel),
          _row('Location', summary.location.displayLabel),
          _row('Current Status', readiness.displayLabel),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  SentinelNavigator.push(context, SentinelRoutes.permissions),
              child: const Text('Open Permission Status'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => SentinelNavigator.push(
                context,
                SentinelRoutes.permissionWizard,
              ),
              child: const Text('Run Permission Setup'),
            ),
          ),
          const Divider(height: 28),
          const Text(
            'Permissions',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 10),
          _row('Camera', summary.camera.displayLabel),
          _row('Microphone', summary.microphone.displayLabel),
          _row('Location', summary.location.displayLabel),
          _row('Current Readiness', readiness.displayLabel),
          const Divider(height: 28),
          _row('Future Recording', 'Pending'),
          _row('Future Encryption', 'Pending'),
          _row('Future Upload', 'Pending'),
          _row('Future Vault', 'Pending'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
