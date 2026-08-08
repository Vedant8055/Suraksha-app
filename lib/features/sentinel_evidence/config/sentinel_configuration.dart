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

/// Central SES configuration. Values only — no runtime behaviour.
library;

class SentinelConfiguration {
  const SentinelConfiguration({
    this.featureEnabled = false,
    this.testMode = true,
    this.recordDuration = const Duration(seconds: 30),
    this.encryptionEnabled = false,
    this.uploadEnabled = false,
    this.vaultEnabled = false,
    this.loggingEnabled = true,
    this.maxRetries = 3,
    this.offlineQueueEnabled = false,
    this.captureFrontCamera = false,
    this.captureRearCamera = false,
  });

  /// Master switch. Must stay false until later phases enable SES.
  final bool featureEnabled;

  /// Architecture phase runs in test mode only.
  final bool testMode;

  final Duration recordDuration;
  final bool encryptionEnabled;
  final bool uploadEnabled;
  final bool vaultEnabled;
  final bool loggingEnabled;
  final int maxRetries;
  final bool offlineQueueEnabled;
  final bool captureFrontCamera;
  final bool captureRearCamera;

  /// Default safe configuration for Phase 1.
  static const SentinelConfiguration defaults = SentinelConfiguration();

  SentinelConfiguration copyWith({
    bool? featureEnabled,
    bool? testMode,
    Duration? recordDuration,
    bool? encryptionEnabled,
    bool? uploadEnabled,
    bool? vaultEnabled,
    bool? loggingEnabled,
    int? maxRetries,
    bool? offlineQueueEnabled,
    bool? captureFrontCamera,
    bool? captureRearCamera,
  }) {
    return SentinelConfiguration(
      featureEnabled: featureEnabled ?? this.featureEnabled,
      testMode: testMode ?? this.testMode,
      recordDuration: recordDuration ?? this.recordDuration,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      uploadEnabled: uploadEnabled ?? this.uploadEnabled,
      vaultEnabled: vaultEnabled ?? this.vaultEnabled,
      loggingEnabled: loggingEnabled ?? this.loggingEnabled,
      maxRetries: maxRetries ?? this.maxRetries,
      offlineQueueEnabled: offlineQueueEnabled ?? this.offlineQueueEnabled,
      captureFrontCamera: captureFrontCamera ?? this.captureFrontCamera,
      captureRearCamera: captureRearCamera ?? this.captureRearCamera,
    );
  }
}
