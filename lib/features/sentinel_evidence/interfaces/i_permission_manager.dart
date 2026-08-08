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

/// Permission management contract. No implementation in Phase 1.
library;

import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';

abstract class IPermissionManager {
  Future<SentinelPermissionStatus> check(PermissionType type);
  Future<SentinelPermissionStatus> request(PermissionType type);
}
