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

/// SentinelUploadService — architecture placeholder. No upload behaviour.
library;

class SentinelUploadService {
  Future<void> enqueue() {
    throw UnimplementedError('SentinelUploadService.enqueue — Phase 1');
  }

  Future<void> cancel() {
    throw UnimplementedError('SentinelUploadService.cancel — Phase 1');
  }

  Future<void> retry() {
    throw UnimplementedError('SentinelUploadService.retry — Phase 1');
  }
}
