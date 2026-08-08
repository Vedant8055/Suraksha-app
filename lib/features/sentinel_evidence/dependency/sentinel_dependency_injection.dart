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

/// Dependency registration placeholders. No concrete wiring yet.
library;

import '../config/feature_flags.dart';
import '../config/sentinel_configuration.dart';
import '../utils/sentinel_logger.dart';

class SentinelDependencyInjection {
  SentinelDependencyInjection._();

  static bool _registered = false;

  static bool get isRegistered => _registered;

  /// Registers configuration / logger placeholders only.
  static void register({
    SentinelConfiguration configuration = SentinelConfiguration.defaults,
    SentinelLogger logger = const SentinelLogger(),
  }) {
    FeatureFlags.instance.apply(configuration);
    logger.log('DependencyInjection.register (placeholder)');
    _registered = true;
  }

  static void reset() {
    FeatureFlags.instance.apply(SentinelConfiguration.defaults);
    _registered = false;
  }
}
