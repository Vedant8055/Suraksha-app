/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Permissions & Feature Readiness (Phase 3)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

/// Easy-to-toggle SES feature flags. Test-safe defaults.
library;

import '../models/sentinel_enums.dart';
import 'sentinel_configuration.dart';

class FeatureFlags {
  FeatureFlags({SentinelConfiguration? configuration})
      : _config = configuration ?? SentinelConfiguration.defaults;

  SentinelConfiguration _config;
  bool _cameraPermissionGranted = false;
  bool _microphonePermissionGranted = false;
  bool _locationPermissionGranted = false;
  SentinelReadinessLevel _readiness = SentinelReadinessLevel.notReady;

  SentinelConfiguration get configuration => _config;

  void apply(SentinelConfiguration configuration) {
    _config = configuration;
  }

  void applyPermissionFlags({
    required bool cameraPermissionGranted,
    required bool microphonePermissionGranted,
    required bool locationPermissionGranted,
    required SentinelReadinessLevel readiness,
  }) {
    _cameraPermissionGranted = cameraPermissionGranted;
    _microphonePermissionGranted = microphonePermissionGranted;
    _locationPermissionGranted = locationPermissionGranted;
    _readiness = readiness;
  }

  bool get isSentinelEnabled => _config.featureEnabled;
  bool get isSentinelTestMode => _config.testMode;
  bool get isEncryptionEnabled => _config.encryptionEnabled;
  bool get isUploadEnabled => _config.uploadEnabled;
  bool get isVaultEnabled => _config.vaultEnabled;

  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get microphonePermissionGranted => _microphonePermissionGranted;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isSentinelReady =>
      isSentinelEnabled && _readiness == SentinelReadinessLevel.ready;

  SentinelReadinessLevel get readinessLevel => _readiness;

  /// Capture remains disabled until later phases even if OS permission exists.
  bool get isCameraEnabled => false;
  bool get isAudioEnabled => false;
  bool get isLocationEnabled => false;

  static final FeatureFlags instance = FeatureFlags();
}
