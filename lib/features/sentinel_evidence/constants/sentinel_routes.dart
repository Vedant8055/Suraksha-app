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

/// Named routes for future SES screens (unused in Phase 1).
library;

class SentinelRoutes {
  const SentinelRoutes._();

  static const String root = '/sentinel';
  static const String vault = '/sentinel/vault';
  static const String settings = '/sentinel/settings';
  static const String info = '/sentinel/info';
  static const String status = '/sentinel/status';
  static const String permissions = '/sentinel/permissions';
  static const String permissionWizard = '/sentinel/permissions/wizard';
  static const String playback = '/sentinel/playback';
}
