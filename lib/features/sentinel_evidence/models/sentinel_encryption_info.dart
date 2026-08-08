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

/// Encryption metadata for an evidence item (structure only).
library;

import 'sentinel_enums.dart';

class SentinelEncryptionInfo {
  const SentinelEncryptionInfo({
    this.state = EncryptionState.disabled,
    this.algorithm,
    this.keyId,
    this.checksum,
  });

  final EncryptionState state;
  final String? algorithm;
  final String? keyId;
  final String? checksum;
}
