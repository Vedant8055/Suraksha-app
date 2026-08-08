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

/// Module readiness overview for SES.
class SentinelStatusScreen extends StatelessWidget {
  const SentinelStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SentinelScaffold(
      title: 'Sentinel System Status',
      body: Column(
        children: const [
          _StatusRow(label: 'Architecture', value: 'Ready'),
          _StatusRow(label: 'Settings', value: 'Ready'),
          _StatusRow(label: 'Permissions', value: 'Ready'),
          _StatusRow(label: 'Recording', value: 'Pending'),
          _StatusRow(label: 'Encryption', value: 'Pending'),
          _StatusRow(label: 'Upload', value: 'Pending'),
          _StatusRow(label: 'Vault', value: 'Pending'),
          _StatusRow(label: 'AI', value: 'Pending'),
          _StatusRow(label: 'SOS Integration', value: 'Pending'),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ready = value == 'Ready';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ready
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: ready
                    ? const Color(0xFF166534)
                    : const Color(0xFF9A3412),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
