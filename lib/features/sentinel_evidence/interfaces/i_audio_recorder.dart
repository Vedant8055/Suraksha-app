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

/// Audio recorder contract. No implementation in Phase 1.
library;

abstract class IAudioRecorder {
  Future<void> prepare();
  Future<void> start();
  Future<void> stop();
  Future<void> disposeRecorder();
}
