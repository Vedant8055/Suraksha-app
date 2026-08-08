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

/// Top-level SES controller — settings / toggle only (no capture logic).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/feature_flags.dart';
import '../config/sentinel_configuration.dart';
import '../state/sentinel_control_state.dart';
import '../state/sentinel_state.dart';
import '../storage/sentinel_settings_storage.dart';
import '../utils/sentinel_logger.dart';

class SentinelController extends StateNotifier<SentinelControlState> {
  SentinelController({
    SentinelSettingsStorage? storage,
    SentinelLogger logger = const SentinelLogger(),
  })  : _storage = storage ?? SentinelSettingsStorage(logger: logger),
        _logger = logger,
        super(SentinelControlState.initial());

  final SentinelSettingsStorage _storage;
  final SentinelLogger _logger;

  Future<void> initialize() async {
    state = state.copyWith(phase: const SentinelLoading(), clearError: true);
    try {
      final settings = await _storage.loadAndApplyFlags();
      state = state.copyWith(
        settings: settings,
        phase: settings.isSentinelEnabled
            ? const SentinelReady()
            : const SentinelDisabled(),
      );
    } catch (error) {
      state = state.copyWith(
        phase: SentinelError(error.toString()),
        errorMessage: error.toString(),
      );
    }
  }

  /// Persists enable/disable and updates FeatureFlags via configuration.
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(phase: const SentinelLoading(), clearError: true);
    try {
      final next = state.settings.copyWith(
        isSentinelEnabled: enabled,
        isSentinelTestMode: true,
        lastUpdated: DateTime.now(),
        settingsVersion: SentinelSettingsStorage.currentSettingsVersion,
      );
      await _storage.save(next);
      FeatureFlags.instance.apply(
        SentinelConfiguration.defaults.copyWith(
          featureEnabled: next.isSentinelEnabled,
          testMode: next.isSentinelTestMode,
        ),
      );
      _logger.log(enabled ? 'Feature Enabled' : 'Feature Disabled');
      state = state.copyWith(
        settings: next,
        phase: enabled ? const SentinelReady() : const SentinelDisabled(),
      );
    } catch (error) {
      state = state.copyWith(
        phase: SentinelError(error.toString()),
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> shutdown() async {
    // Phase 2: no capture sessions to tear down.
    state = state.copyWith(phase: const SentinelDisabled());
  }
}

final sentinelControllerProvider =
    StateNotifierProvider<SentinelController, SentinelControlState>((ref) {
  final controller = SentinelController();
  controller.initialize();
  return controller;
});
