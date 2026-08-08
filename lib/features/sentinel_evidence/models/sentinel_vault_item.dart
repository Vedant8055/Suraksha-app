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

/// Vault list item model (structure only).
library;

import 'sentinel_enums.dart';

class SentinelVaultItem {
  const SentinelVaultItem({
    required this.id,
    this.title,
    this.type = EvidenceType.package,
    this.createdAt,
    this.sizeBytes,
    this.isEncrypted = false,
  });

  final String id;
  final String? title;
  final EvidenceType type;
  final DateTime? createdAt;
  final int? sizeBytes;
  final bool isEncrypted;
}
