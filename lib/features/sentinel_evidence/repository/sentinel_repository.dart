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

/// Primary SES repository interface (empty implementation).
library;

import '../models/sentinel_evidence.dart';

abstract class SentinelRepository {
  Future<List<SentinelEvidence>> listEvidence();
  Future<SentinelEvidence?> getById(String id);
  Future<void> save(SentinelEvidence evidence);
  Future<void> delete(String id);
}

class SentinelRepositoryImpl implements SentinelRepository {
  @override
  Future<void> delete(String id) {
    throw UnimplementedError('SentinelRepository.delete — Phase 1 placeholder');
  }

  @override
  Future<SentinelEvidence?> getById(String id) {
    throw UnimplementedError('SentinelRepository.getById — Phase 1 placeholder');
  }

  @override
  Future<List<SentinelEvidence>> listEvidence() {
    throw UnimplementedError(
      'SentinelRepository.listEvidence — Phase 1 placeholder',
    );
  }

  @override
  Future<void> save(SentinelEvidence evidence) {
    throw UnimplementedError('SentinelRepository.save — Phase 1 placeholder');
  }
}
