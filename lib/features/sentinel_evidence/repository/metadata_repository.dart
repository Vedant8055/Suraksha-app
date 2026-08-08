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

/// Metadata repository interface (empty implementation).
library;

import '../models/sentinel_metadata.dart';

abstract class MetadataRepository {
  Future<SentinelMetadata?> getForEvidence(String evidenceId);
  Future<void> save(String evidenceId, SentinelMetadata metadata);
}

class MetadataRepositoryImpl implements MetadataRepository {
  @override
  Future<SentinelMetadata?> getForEvidence(String evidenceId) {
    throw UnimplementedError(
      'MetadataRepository.getForEvidence — Phase 1 placeholder',
    );
  }

  @override
  Future<void> save(String evidenceId, SentinelMetadata metadata) {
    throw UnimplementedError('MetadataRepository.save — Phase 1 placeholder');
  }
}
