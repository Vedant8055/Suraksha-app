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

/// SES settings controller — mirrors persistence for settings screen refresh.
library;

import '../storage/sentinel_settings_storage.dart';

class SentinelSettingsController {
  SentinelSettingsController({SentinelSettingsStorage? storage})
      : _storage = storage ?? SentinelSettingsStorage();

  final SentinelSettingsStorage _storage;
  SentinelPersistedSettings? _cached;

  SentinelPersistedSettings? get cached => _cached;

  Future<SentinelPersistedSettings> load() async {
    _cached = await _storage.load();
    return _cached!;
  }

  Future<void> save(SentinelPersistedSettings settings) async {
    await _storage.save(settings);
    _cached = settings;
  }
}
