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

/// Encryption contract. No implementation in Phase 1.
library;

abstract class IEncryptor {
  Future<List<int>> encrypt(List<int> plaintext);
  Future<List<int>> decrypt(List<int> ciphertext);
}
