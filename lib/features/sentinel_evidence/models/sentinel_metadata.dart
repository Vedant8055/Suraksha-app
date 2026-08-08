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

/// Evidence metadata container (structure only).
library;

import 'sentinel_location.dart';
import 'sentinel_device_information.dart';

class SentinelMetadata {
  const SentinelMetadata({
    this.sessionId,
    this.userId,
    this.capturedAt,
    this.location,
    this.device,
    this.notes,
    this.tags = const <String>[],
  });

  final String? sessionId;
  final String? userId;
  final DateTime? capturedAt;
  final SentinelLocation? location;
  final SentinelDeviceInformation? device;
  final String? notes;
  final List<String> tags;
}
