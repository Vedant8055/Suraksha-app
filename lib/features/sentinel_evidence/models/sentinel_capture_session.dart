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

/// Single capture session descriptor (structure only).
library;

import 'sentinel_enums.dart';

class SentinelCaptureSession {
  const SentinelCaptureSession({
    required this.sessionId,
    this.state = CaptureState.idle,
    this.startedAt,
    this.endedAt,
    this.plannedDuration,
  });

  final String sessionId;
  final CaptureState state;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Duration? plannedDuration;
}
