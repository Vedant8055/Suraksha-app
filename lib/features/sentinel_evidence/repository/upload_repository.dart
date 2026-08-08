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

/// Upload repository interface (empty implementation).
library;

import '../models/sentinel_evidence.dart';
import '../models/sentinel_upload_status.dart';

abstract class UploadRepository {
  Future<SentinelUploadStatus> enqueue(SentinelEvidence evidence);
  Future<SentinelUploadStatus?> statusFor(String evidenceId);
}

class UploadRepositoryImpl implements UploadRepository {
  @override
  Future<SentinelUploadStatus> enqueue(SentinelEvidence evidence) {
    throw UnimplementedError('UploadRepository.enqueue — Phase 1 placeholder');
  }

  @override
  Future<SentinelUploadStatus?> statusFor(String evidenceId) {
    throw UnimplementedError(
      'UploadRepository.statusFor — Phase 1 placeholder',
    );
  }
}
