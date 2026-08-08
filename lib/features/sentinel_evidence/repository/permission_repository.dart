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

/// Permission repository interface (empty implementation).
library;

import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';

abstract class PermissionRepository {
  Future<SentinelPermissionStatus> read(PermissionType type);
  Future<void> write(SentinelPermissionStatus status);
}

class PermissionRepositoryImpl implements PermissionRepository {
  @override
  Future<SentinelPermissionStatus> read(PermissionType type) {
    throw UnimplementedError('PermissionRepository.read — Phase 1 placeholder');
  }

  @override
  Future<void> write(SentinelPermissionStatus status) {
    throw UnimplementedError('PermissionRepository.write — Phase 1 placeholder');
  }
}
