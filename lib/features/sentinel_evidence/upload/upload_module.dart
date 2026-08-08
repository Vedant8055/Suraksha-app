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

/// Upload pipeline submodule marker (queue/sync/retry later).
library;

class SentinelUploadModule {
  const SentinelUploadModule._();

  static const String name = 'upload';
}
