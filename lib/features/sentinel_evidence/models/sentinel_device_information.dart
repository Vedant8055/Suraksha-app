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

/// Device context for evidence provenance (structure only).
library;

class SentinelDeviceInformation {
  const SentinelDeviceInformation({
    this.platform,
    this.model,
    this.osVersion,
    this.appVersion,
    this.deviceId,
  });

  final String? platform;
  final String? model;
  final String? osVersion;
  final String? appVersion;
  final String? deviceId;
}
