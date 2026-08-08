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

/// Upload progress / outcome model (structure only).
library;

import 'sentinel_enums.dart';

class SentinelUploadStatus {
  const SentinelUploadStatus({
    this.state = UploadState.idle,
    this.remoteKey,
    this.progress = 0,
    this.lastError,
    this.attemptCount = 0,
    this.updatedAt,
  });

  final UploadState state;
  final String? remoteKey;
  final double progress;
  final String? lastError;
  final int attemptCount;
  final DateTime? updatedAt;
}
