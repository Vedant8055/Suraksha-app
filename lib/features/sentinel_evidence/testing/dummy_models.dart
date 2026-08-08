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

/// Dummy model factories for future tests.
library;

import '../models/sentinel_capture_session.dart';
import '../models/sentinel_enums.dart';
import '../models/sentinel_evidence.dart';
import '../models/sentinel_vault_item.dart';

class DummyModels {
  const DummyModels._();

  static SentinelEvidence evidence({String id = 'ses-dummy-1'}) {
    return SentinelEvidence(
      id: id,
      type: EvidenceType.package,
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  static SentinelCaptureSession session({String id = 'ses-session-1'}) {
    return SentinelCaptureSession(
      sessionId: id,
      state: CaptureState.idle,
    );
  }

  static SentinelVaultItem vaultItem({String id = 'ses-vault-1'}) {
    return SentinelVaultItem(id: id, title: 'Dummy vault item');
  }
}
