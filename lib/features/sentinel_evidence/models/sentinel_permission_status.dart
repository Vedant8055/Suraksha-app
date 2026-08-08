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

/// Permission snapshot for SES.
library;

import 'sentinel_enums.dart';

class SentinelPermissionStatus {
  const SentinelPermissionStatus({
    required this.type,
    this.grant = SentinelPermissionGrant.notRequested,
    this.permanentlyDenied = false,
    this.checkedAt,
  });

  final PermissionType type;
  final SentinelPermissionGrant grant;
  final bool permanentlyDenied;
  final DateTime? checkedAt;

  bool get granted => grant == SentinelPermissionGrant.granted;
  bool get isDenied =>
      grant == SentinelPermissionGrant.denied ||
      grant == SentinelPermissionGrant.permanentlyDenied;
  bool get notRequested => grant == SentinelPermissionGrant.notRequested;

  String get displayLabel {
    switch (grant) {
      case SentinelPermissionGrant.granted:
        return 'Granted';
      case SentinelPermissionGrant.denied:
        return 'Denied';
      case SentinelPermissionGrant.permanentlyDenied:
        return 'Denied';
      case SentinelPermissionGrant.notRequested:
        return 'Not Requested';
    }
  }

  SentinelPermissionStatus copyWith({
    PermissionType? type,
    SentinelPermissionGrant? grant,
    bool? permanentlyDenied,
    DateTime? checkedAt,
  }) {
    return SentinelPermissionStatus(
      type: type ?? this.type,
      grant: grant ?? this.grant,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
