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

/// Empty evidence vault placeholder — no storage connected.
class SentinelVaultScreen extends StatelessWidget {
  const SentinelVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SentinelScaffold(
      title: 'Evidence Vault',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                Icons.lock_rounded,
                size: 88,
                color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.7,
                    ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No evidence available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Evidence recording has not yet been implemented.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Waiting for future implementation.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
