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

/// Vault repository interface (empty implementation).
library;

import '../models/sentinel_vault_item.dart';

abstract class VaultRepository {
  Future<List<SentinelVaultItem>> list();
  Future<void> upsert(SentinelVaultItem item);
  Future<void> delete(String id);
}

class VaultRepositoryImpl implements VaultRepository {
  @override
  Future<void> delete(String id) {
    throw UnimplementedError('VaultRepository.delete — Phase 1 placeholder');
  }

  @override
  Future<List<SentinelVaultItem>> list() {
    throw UnimplementedError('VaultRepository.list — Phase 1 placeholder');
  }

  @override
  Future<void> upsert(SentinelVaultItem item) {
    throw UnimplementedError('VaultRepository.upsert — Phase 1 placeholder');
  }
}
