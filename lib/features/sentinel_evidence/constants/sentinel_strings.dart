/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Architecture Preparation

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove integration points.

-------------------------------------------------------
*/

/// UI string placeholders (not wired into Suraksha l10n yet).
library;

class SentinelStrings {
  const SentinelStrings._();

  static const String moduleTitle = 'Sentinel Evidence System';
  static const String testModeBadge = 'TEST MODE';
  static const String disabledMessage = 'Sentinel is disabled.';
  static const String comingSoon = 'Sentinel architecture prepared — not active.';
  static const String moduleVersion = '0.1.0-alpha';
  static const String buildLabel = 'Experimental';
  static const String profileSubtitle =
      'Experimental emergency evidence collection system.\n'
      'This feature is currently available only in TEST MODE.';
}
