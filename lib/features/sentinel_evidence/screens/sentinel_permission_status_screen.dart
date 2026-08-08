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

import '../controllers/sentinel_permission_controller.dart';
import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';
import '../widgets/sentinel_scaffold.dart';

/// Colour-coded permission status with refresh / grant actions.
class SentinelPermissionStatusScreen extends ConsumerWidget {
  const SentinelPermissionStatusScreen({super.key});

  Color _colorFor(SentinelPermissionGrant grant) {
    switch (grant) {
      case SentinelPermissionGrant.granted:
        return const Color(0xFF16A34A);
      case SentinelPermissionGrant.notRequested:
        return const Color(0xFFEAB308);
      case SentinelPermissionGrant.denied:
      case SentinelPermissionGrant.permanentlyDenied:
        return const Color(0xFFDC2626);
    }
  }

  IconData _iconFor(SentinelPermissionGrant grant) {
    switch (grant) {
      case SentinelPermissionGrant.granted:
        return Icons.check_circle_rounded;
      case SentinelPermissionGrant.notRequested:
        return Icons.help_outline_rounded;
      case SentinelPermissionGrant.denied:
      case SentinelPermissionGrant.permanentlyDenied:
        return Icons.cancel_rounded;
    }
  }

  Future<void> _grant(
    WidgetRef ref,
    PermissionType type,
    SentinelPermissionStatus status,
  ) async {
    final controller = ref.read(sentinelPermissionControllerProvider.notifier);
    if (status.permanentlyDenied) {
      await controller.openAppSettingsIfNeeded();
      await controller.refreshPermissions();
      return;
    }
    switch (type) {
      case PermissionType.camera:
        await controller.requestCamera();
      case PermissionType.microphone:
        await controller.requestMicrophone();
      case PermissionType.location:
        await controller.requestLocation();
      case PermissionType.storage:
      case PermissionType.notification:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sentinelPermissionControllerProvider);
    final summary = state.summary;
    final readiness = state.readiness;

    return SentinelScaffold(
      title: 'Sentinel Permission Status',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Status: ${readiness.displayLabel}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _PermissionTile(
            label: 'Camera',
            status: summary.camera,
            color: _colorFor(summary.camera.grant),
            icon: _iconFor(summary.camera.grant),
            onGrant: () => _grant(ref, PermissionType.camera, summary.camera),
          ),
          _PermissionTile(
            label: 'Microphone',
            status: summary.microphone,
            color: _colorFor(summary.microphone.grant),
            icon: _iconFor(summary.microphone.grant),
            onGrant: () =>
                _grant(ref, PermissionType.microphone, summary.microphone),
          ),
          _PermissionTile(
            label: 'Location',
            status: summary.location,
            color: _colorFor(summary.location.grant),
            icon: _iconFor(summary.location.grant),
            onGrant: () =>
                _grant(ref, PermissionType.location, summary.location),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.busy
                  ? null
                  : () => ref
                      .read(sentinelPermissionControllerProvider.notifier)
                      .refreshPermissions(),
              child: const Text('Refresh Permission Status'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Refresh only checks current OS permission status. '
            'It never starts camera, microphone, or recording.',
            style: TextStyle(fontSize: 12.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.label,
    required this.status,
    required this.color,
    required this.icon,
    required this.onGrant,
  });

  final String label;
  final SentinelPermissionStatus status;
  final Color color;
  final IconData icon;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    status.displayLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!status.granted)
              TextButton(
                onPressed: onGrant,
                child: const Text('Grant Permission'),
              ),
          ],
        ),
      ),
    );
  }
}
