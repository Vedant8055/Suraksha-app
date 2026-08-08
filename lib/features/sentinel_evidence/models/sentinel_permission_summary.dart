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

/// Aggregated permission + readiness snapshot for SES.
library;

import 'sentinel_enums.dart';
import 'sentinel_permission_status.dart';

class SentinelPermissionSummary {
  const SentinelPermissionSummary({
    this.camera = const SentinelPermissionStatus(type: PermissionType.camera),
    this.microphone =
        const SentinelPermissionStatus(type: PermissionType.microphone),
    this.location =
        const SentinelPermissionStatus(type: PermissionType.location),
    this.permissionTimestamp,
    this.permissionVersion = 1,
    this.lastCheck,
    this.wizardCompleted = false,
  });

  final SentinelPermissionStatus camera;
  final SentinelPermissionStatus microphone;
  final SentinelPermissionStatus location;
  final DateTime? permissionTimestamp;
  final int permissionVersion;
  final DateTime? lastCheck;
  final bool wizardCompleted;

  bool get cameraGranted => camera.granted;
  bool get microphoneGranted => microphone.granted;
  bool get locationGranted => location.granted;

  int get grantedCount =>
      (cameraGranted ? 1 : 0) +
      (microphoneGranted ? 1 : 0) +
      (locationGranted ? 1 : 0);

  SentinelPermissionSummary copyWith({
    SentinelPermissionStatus? camera,
    SentinelPermissionStatus? microphone,
    SentinelPermissionStatus? location,
    DateTime? permissionTimestamp,
    int? permissionVersion,
    DateTime? lastCheck,
    bool? wizardCompleted,
  }) {
    return SentinelPermissionSummary(
      camera: camera ?? this.camera,
      microphone: microphone ?? this.microphone,
      location: location ?? this.location,
      permissionTimestamp: permissionTimestamp ?? this.permissionTimestamp,
      permissionVersion: permissionVersion ?? this.permissionVersion,
      lastCheck: lastCheck ?? this.lastCheck,
      wizardCompleted: wizardCompleted ?? this.wizardCompleted,
    );
  }
}
