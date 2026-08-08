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

/// Upload contract. No implementation in Phase 1.
library;

import '../models/sentinel_evidence.dart';
import '../models/sentinel_upload_status.dart';

abstract class IUploader {
  Future<SentinelUploadStatus> upload(SentinelEvidence evidence);
  Future<void> cancel(String evidenceId);
}
