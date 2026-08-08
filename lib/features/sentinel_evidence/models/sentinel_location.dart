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

/// Location snapshot attached to evidence (structure only).
library;

class SentinelLocation {
  const SentinelLocation({
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.altitudeMeters,
    this.capturedAt,
  });

  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final DateTime? capturedAt;
}
