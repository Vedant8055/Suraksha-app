/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Feature Toggle & Settings (Phase 2)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

import 'config/feature_flags.dart';
import 'utils/sentinel_logger.dart';

/// Future SOS integration hook.
///
/// Does not alter SOS behaviour. Returns immediately in Phase 2.
class SentinelEntryPoint {
  const SentinelEntryPoint._();

  static final SentinelLogger _logger = const SentinelLogger();

  /// Intended future API: `SentinelEntryPoint.start()`.
  /// Currently a no-op so Suraksha SOS remains unchanged.
  static Future<void> start() async {
    if (!FeatureFlags.instance.isSentinelEnabled) {
      return;
    }
    _logger.log('EntryPoint.start skipped (settings phase — no capture)');
  }
}
