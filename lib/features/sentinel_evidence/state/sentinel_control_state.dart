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

/// Control-plane state for the SES feature toggle.
library;

import '../state/sentinel_state.dart';
import '../storage/sentinel_settings_storage.dart';

class SentinelControlState {
  const SentinelControlState({
    required this.phase,
    required this.settings,
    this.errorMessage,
  });

  final SentinelState phase;
  final SentinelPersistedSettings settings;
  final String? errorMessage;

  bool get isEnabled => settings.isSentinelEnabled;
  bool get isLoading => phase is SentinelLoading;
  bool get isError => phase is SentinelError;

  factory SentinelControlState.initial() => const SentinelControlState(
        phase: SentinelInitial(),
        settings: SentinelPersistedSettings(
          isSentinelEnabled: false,
          isSentinelTestMode: true,
        ),
      );

  SentinelControlState copyWith({
    SentinelState? phase,
    SentinelPersistedSettings? settings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SentinelControlState(
      phase: phase ?? this.phase,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
