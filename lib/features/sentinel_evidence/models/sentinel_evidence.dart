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

/// Core evidence package model (structure only).
library;

import 'sentinel_enums.dart';
import 'sentinel_metadata.dart';
import 'sentinel_upload_status.dart';
import 'sentinel_encryption_info.dart';

class SentinelEvidence {
  const SentinelEvidence({
    required this.id,
    this.type = EvidenceType.package,
    this.localPath,
    this.createdAt,
    this.metadata,
    this.uploadStatus,
    this.encryptionInfo,
  });

  final String id;
  final EvidenceType type;
  final String? localPath;
  final DateTime? createdAt;
  final SentinelMetadata? metadata;
  final SentinelUploadStatus? uploadStatus;
  final SentinelEncryptionInfo? encryptionInfo;
}
