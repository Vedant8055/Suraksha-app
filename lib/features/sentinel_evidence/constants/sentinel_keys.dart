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

/// Configuration key names only. Never store secret values here.
library;

class SentinelKeys {
  const SentinelKeys._();

  static const String featureEnabled = 'ses.featureEnabled';
  static const String testMode = 'ses.testMode';
  static const String encryptionEnabled = 'ses.encryptionEnabled';
  static const String uploadEnabled = 'ses.uploadEnabled';
  static const String vaultEnabled = 'ses.vaultEnabled';
  static const String lastUpdated = 'ses.lastUpdated';
  static const String settingsVersion = 'ses.settingsVersion';

  static const String cameraPermission = 'ses.permission.camera';
  static const String microphonePermission = 'ses.permission.microphone';
  static const String locationPermission = 'ses.permission.location';
  static const String permissionTimestamp = 'ses.permission.timestamp';
  static const String permissionVersion = 'ses.permission.version';
  static const String permissionLastCheck = 'ses.permission.lastCheck';
  static const String permissionWizardCompleted = 'ses.permission.wizardCompleted';

  /// Environment / secure-storage key *names* for later phases.
  static const String awsAccessKeyIdName = 'SES_AWS_ACCESS_KEY_ID';
  static const String awsSecretAccessKeyName = 'SES_AWS_SECRET_ACCESS_KEY';
  static const String awsRegionName = 'SES_AWS_REGION';
  static const String awsBucketName = 'SES_AWS_BUCKET';
}
