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

/// SES operational and pipeline enums (architecture placeholders).
library;

enum SentinelMode {
  disabled,
  test,
  production,
}

enum CaptureState {
  idle,
  preparing,
  capturing,
  paused,
  completed,
  failed,
}

enum UploadState {
  idle,
  queued,
  uploading,
  uploaded,
  failed,
  retrying,
}

enum VaultState {
  empty,
  loading,
  ready,
  locked,
  error,
}

enum EncryptionState {
  disabled,
  pending,
  encrypted,
  failed,
}

enum EvidenceType {
  video,
  audio,
  image,
  metadata,
  package,
}

enum PermissionType {
  camera,
  microphone,
  location,
  storage,
  notification,
}

/// Stored / displayed grant state for SES permissions.
enum SentinelPermissionGrant {
  notRequested,
  granted,
  denied,
  permanentlyDenied,
}

/// Overall readiness for future evidence collection (Phase 3).
enum SentinelReadinessLevel {
  notReady,
  partiallyReady,
  ready,
}

enum RecordingState {
  idle,
  starting,
  recording,
  stopping,
  stopped,
  error,
}
