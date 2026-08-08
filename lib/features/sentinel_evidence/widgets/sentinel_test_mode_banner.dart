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

import '../constants/sentinel_strings.dart';

/// Visually obvious TEST MODE banner for all SES screens.
class SentinelTestModeBanner extends StatelessWidget {
  const SentinelTestModeBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFF7ED) : const Color(0xFF3B2314),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              SentinelStrings.testModeBadge,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              compact
                  ? 'No emergency evidence is currently collected.'
                  : 'TEST MODE\nNo emergency evidence is currently collected.',
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF9A3412)
                    : const Color(0xFFFED7AA),
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact badge chip used in Profile section headers.
class SentinelTestModeChip extends StatelessWidget {
  const SentinelTestModeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        SentinelStrings.testModeBadge,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
