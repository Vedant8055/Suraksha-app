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

/// Date/time helpers placeholder.
library;

class SentinelDateUtils {
  static String toIso(DateTime? value) =>
      value?.toUtc().toIso8601String() ?? '';
}
