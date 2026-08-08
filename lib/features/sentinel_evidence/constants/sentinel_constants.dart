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

/// SES constants placeholders. No secrets or production URLs.
library;

class SentinelConstants {
  const SentinelConstants._();

  static const String moduleName = 'sentinel_evidence';
  static const String logTag = '[SENTINEL]';
  static const String configNamespace = 'ses';

  /// Placeholder — real endpoints must come from secure configuration later.
  static const String uploadEndpointKey = 'SES_UPLOAD_ENDPOINT';
  static const String vaultEndpointKey = 'SES_VAULT_ENDPOINT';
}
