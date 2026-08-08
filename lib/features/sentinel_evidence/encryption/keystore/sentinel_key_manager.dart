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

/// Key management placeholder. No secrets or crypto algorithms.
library;

class SentinelKeyManager {
  Future<String?> currentKeyId() {
    throw UnimplementedError('SentinelKeyManager.currentKeyId — Phase 1');
  }

  Future<void> rotateKeys() {
    throw UnimplementedError('SentinelKeyManager.rotateKeys — Phase 1');
  }
}
