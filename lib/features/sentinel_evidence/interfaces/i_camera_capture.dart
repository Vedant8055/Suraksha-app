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

/// Camera capture contract. No implementation in Phase 1.
library;

abstract class ICameraCapture {
  Future<void> prepare();
  Future<void> start();
  Future<void> stop();
  Future<void> disposeCapture();
}
