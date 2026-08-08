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

/// Determines SES readiness for future evidence collection (no capture).
library;

import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_summary.dart';

class SentinelReadinessResult {
  const SentinelReadinessResult({
    required this.level,
    required this.sentinelEnabled,
    required this.cameraGranted,
    required this.microphoneGranted,
    required this.locationGranted,
  });

  final SentinelReadinessLevel level;
  final bool sentinelEnabled;
  final bool cameraGranted;
  final bool microphoneGranted;
  final bool locationGranted;

  String get displayLabel {
    switch (level) {
      case SentinelReadinessLevel.ready:
        return 'READY';
      case SentinelReadinessLevel.partiallyReady:
        return 'PARTIALLY READY';
      case SentinelReadinessLevel.notReady:
        return 'NOT READY';
    }
  }
}

class SentinelReadinessChecker {
  const SentinelReadinessChecker();

  SentinelReadinessResult evaluate({
    required bool isSentinelEnabled,
    required SentinelPermissionSummary permissions,
  }) {
    final camera = permissions.cameraGranted;
    final mic = permissions.microphoneGranted;
    final location = permissions.locationGranted;

    if (!isSentinelEnabled) {
      return SentinelReadinessResult(
        level: SentinelReadinessLevel.notReady,
        sentinelEnabled: false,
        cameraGranted: camera,
        microphoneGranted: mic,
        locationGranted: location,
      );
    }

    final grantedCount = permissions.grantedCount;
    final level = grantedCount == 3
        ? SentinelReadinessLevel.ready
        : grantedCount == 0
            ? SentinelReadinessLevel.notReady
            : SentinelReadinessLevel.partiallyReady;

    return SentinelReadinessResult(
      level: level,
      sentinelEnabled: true,
      cameraGranted: camera,
      microphoneGranted: mic,
      locationGranted: location,
    );
  }
}
