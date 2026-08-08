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

import '../widgets/sentinel_scaffold.dart';

/// High-level information about SES (no implementation details).
class SentinelInfoScreen extends StatelessWidget {
  const SentinelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SentinelScaffold(
      title: 'Sentinel Information',
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            title: 'Purpose',
            body:
                'Sentinel is an experimental emergency evidence collection system '
                'designed to help protect users during critical situations.',
          ),
          _Section(
            title: 'Privacy',
            body:
                'Your privacy matters. Sentinel settings stay on this device for now. '
                'Evidence collection is not active in TEST MODE.',
          ),
          _Section(
            title: 'Security',
            body:
                'Future versions may encrypt evidence and use secure cloud storage. '
                'Those capabilities are not enabled yet.',
          ),
          _Section(
            title: 'Permissions',
            body:
                'Sentinel never accesses camera, microphone, or location unless '
                'Sentinel is enabled and an SOS event occurs.\n\n'
                'The current phase only prepares permissions. '
                'No media capture runs in TEST MODE.',
          ),
          _Section(
            title: 'Experimental Nature',
            body:
                'This feature is under active development. Behaviour may change. '
                'You can disable Sentinel anytime from Profile.',
          ),
          _Section(
            title: 'Future Plans',
            body:
                'Planned work includes SOS-linked capture, encryption, '
                'secure upload, and an evidence vault — delivered in later phases.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
