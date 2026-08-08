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

/// User / app SES settings model (structure only).
library;

class SentinelSettings {
  const SentinelSettings({
    this.enabled = false,
    this.testMode = true,
    this.autoStartOnSos = false,
    this.notifyOnCapture = false,
  });

  final bool enabled;
  final bool testMode;
  final bool autoStartOnSos;
  final bool notifyOnCapture;
}
