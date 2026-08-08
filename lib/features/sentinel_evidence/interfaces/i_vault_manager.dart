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

/// Vault management contract. No implementation in Phase 1.
library;

import '../models/sentinel_vault_item.dart';

abstract class IVaultManager {
  Future<List<SentinelVaultItem>> listItems();
  Future<void> addItem(SentinelVaultItem item);
  Future<void> removeItem(String id);
}
