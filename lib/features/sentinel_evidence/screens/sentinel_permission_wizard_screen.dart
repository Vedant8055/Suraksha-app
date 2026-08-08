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
import '../models/sentinel_permission_summary.dart';
import '../widgets/sentinel_test_mode_banner.dart';

/// Multi-step permission setup. Requests only on explicit Allow taps.
class SentinelPermissionWizardScreen extends ConsumerStatefulWidget {
  const SentinelPermissionWizardScreen({super.key});

  @override
  ConsumerState<SentinelPermissionWizardScreen> createState() =>
      _SentinelPermissionWizardScreenState();
}

class _SentinelPermissionWizardScreenState
    extends ConsumerState<SentinelPermissionWizardScreen> {
  int _step = 0;

  Future<void> _allowCurrent() async {
    final controller = ref.read(sentinelPermissionControllerProvider.notifier);
    switch (_step) {
      case 0:
        await controller.requestCamera();
      case 1:
        await controller.requestMicrophone();
      case 2:
        await controller.requestLocation();
    }
    if (!mounted) return;
    setState(() => _step += 1);
  }

  void _skipCurrent() {
    setState(() => _step += 1);
  }

  Future<void> _finish() async {
    await ref
        .read(sentinelPermissionControllerProvider.notifier)
        .completeWizard();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(sentinelPermissionControllerProvider);
    final summary = permissionState.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Sentinel Permission Setup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SentinelTestModeBanner(),
              const SizedBox(height: 14),
              const Text(
                'Configure permissions required for future emergency evidence collection.',
                style: TextStyle(height: 1.35),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${_step >= 3 ? 4 : _step + 1} of 4',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Expanded(child: _buildStepBody(summary)),
              if (_step < 3) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            permissionState.busy ? null : _skipCurrent,
                        child: const Text('Skip'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            permissionState.busy ? null : _allowCurrent,
                        child: const Text('Allow'),
                      ),
                    ),
                  ],
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: permissionState.busy ? null : _finish,
                    child: const Text('Done'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody(SentinelPermissionSummary summary) {
    switch (_step) {
      case 0:
        return const _WizardExplain(
          title: 'Camera Permission',
          body:
              'The camera will only be used after an SOS event if Sentinel is enabled.\n\n'
              'No photos or videos are captured during normal app usage.',
          icon: Icons.photo_camera_outlined,
        );
      case 1:
        return const _WizardExplain(
          title: 'Microphone Permission',
          body:
              'The microphone will only record emergency audio after an SOS trigger.\n\n'
              'It is never active during normal application usage.',
          icon: Icons.mic_none_rounded,
        );
      case 2:
        return const _WizardExplain(
          title: 'Location Permission',
          body:
              'Location is used only to attach GPS coordinates to emergency evidence after SOS.',
          icon: Icons.location_on_outlined,
        );
      default:
        final anyDenied = summary.camera.isDenied ||
            summary.microphone.isDenied ||
            summary.location.isDenied ||
            summary.camera.notRequested ||
            summary.microphone.notRequested ||
            summary.location.notRequested;
        return ListView(
          children: [
            const Text(
              'Permission Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _SummaryRow(label: 'Camera', grant: summary.camera.grant),
            _SummaryRow(label: 'Microphone', grant: summary.microphone.grant),
            _SummaryRow(label: 'Location', grant: summary.location.grant),
            if (anyDenied) ...[
              const SizedBox(height: 16),
              const Text(
                'Sentinel will remain enabled,\n'
                'however some future capabilities may not work.',
                style: TextStyle(height: 1.4),
              ),
            ],
          ],
        );
    }
  }
}

class _WizardExplain extends StatelessWidget {
  const _WizardExplain({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(body, style: const TextStyle(height: 1.45, fontSize: 15)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.grant});

  final String label;
  final SentinelPermissionGrant grant;

  @override
  Widget build(BuildContext context) {
    final text = switch (grant) {
      SentinelPermissionGrant.granted => 'Granted',
      SentinelPermissionGrant.denied ||
      SentinelPermissionGrant.permanentlyDenied =>
        'Denied',
      SentinelPermissionGrant.notRequested => 'Not Requested',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
