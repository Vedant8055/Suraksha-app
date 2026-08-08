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

/// Custom SES exceptions (no thrown production paths yet).
library;

class SentinelException implements Exception {
  SentinelException([this.message = 'Sentinel error', this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'SentinelException($code): $message';
}

class RecordingException extends SentinelException {
  RecordingException([super.message = 'Recording error', super.code]);
}

class UploadException extends SentinelException {
  UploadException([super.message = 'Upload error', super.code]);
}

class EncryptionException extends SentinelException {
  EncryptionException([super.message = 'Encryption error', super.code]);
}

class VaultException extends SentinelException {
  VaultException([super.message = 'Vault error', super.code]);
}

class PermissionException extends SentinelException {
  PermissionException([super.message = 'Permission error', super.code]);
}
