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

/// AWS S3 uploader placeholder.
///
/// No AWS SDK usage, no credentials, no network calls.
/// Configuration will be injected in a later phase.
library;

class SentinelS3Uploader {
  Future<void> uploadFile({
    required String localPath,
    required String remoteKey,
  }) {
    throw UnimplementedError('SentinelS3Uploader.uploadFile — Phase 1');
  }

  Future<void> abort(String remoteKey) {
    throw UnimplementedError('SentinelS3Uploader.abort — Phase 1');
  }
}
