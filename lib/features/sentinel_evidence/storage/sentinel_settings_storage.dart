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

/// Local persistence for SES control-plane settings (SharedPreferences).
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/feature_flags.dart';
import '../config/sentinel_configuration.dart';
import '../constants/sentinel_keys.dart';
import '../models/sentinel_settings.dart';
import '../utils/sentinel_logger.dart';

class SentinelSettingsStorage {
  SentinelSettingsStorage({
    SharedPreferences? prefs,
    SentinelLogger logger = const SentinelLogger(),
  }) : _prefs = prefs,
       _logger = logger;

  SharedPreferences? _prefs;
  final SentinelLogger _logger;

  static const int currentSettingsVersion = 1;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SentinelPersistedSettings> load() async {
    final prefs = await _ensurePrefs();
    final enabled = prefs.getBool(SentinelKeys.featureEnabled) ?? false;
    final testMode = prefs.getBool(SentinelKeys.testMode) ?? true;
    final lastUpdatedMs = prefs.getInt(SentinelKeys.lastUpdated);
    final version =
        prefs.getInt(SentinelKeys.settingsVersion) ?? currentSettingsVersion;

    return SentinelPersistedSettings(
      isSentinelEnabled: enabled,
      isSentinelTestMode: testMode,
      lastUpdated: lastUpdatedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastUpdatedMs),
      settingsVersion: version,
    );
  }

  Future<void> save(SentinelPersistedSettings settings) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(SentinelKeys.featureEnabled, settings.isSentinelEnabled);
    await prefs.setBool(SentinelKeys.testMode, settings.isSentinelTestMode);
    await prefs.setInt(
      SentinelKeys.lastUpdated,
      (settings.lastUpdated ?? DateTime.now()).millisecondsSinceEpoch,
    );
    await prefs.setInt(
      SentinelKeys.settingsVersion,
      settings.settingsVersion,
    );
  }

  /// Applies persisted values into [FeatureFlags] via configuration (no globals).
  Future<SentinelPersistedSettings> loadAndApplyFlags() async {
    final settings = await load();
    FeatureFlags.instance.apply(
      SentinelConfiguration.defaults.copyWith(
        featureEnabled: settings.isSentinelEnabled,
        testMode: settings.isSentinelTestMode,
      ),
    );
    _logger.log(
      settings.isSentinelEnabled ? 'Feature Enabled' : 'Feature Disabled',
    );
    return settings;
  }
}

class SentinelPersistedSettings {
  const SentinelPersistedSettings({
    required this.isSentinelEnabled,
    required this.isSentinelTestMode,
    this.lastUpdated,
    this.settingsVersion = SentinelSettingsStorage.currentSettingsVersion,
  });

  final bool isSentinelEnabled;
  final bool isSentinelTestMode;
  final DateTime? lastUpdated;
  final int settingsVersion;

  SentinelSettings toModel() => SentinelSettings(
        enabled: isSentinelEnabled,
        testMode: isSentinelTestMode,
      );

  SentinelPersistedSettings copyWith({
    bool? isSentinelEnabled,
    bool? isSentinelTestMode,
    DateTime? lastUpdated,
    int? settingsVersion,
  }) {
    return SentinelPersistedSettings(
      isSentinelEnabled: isSentinelEnabled ?? this.isSentinelEnabled,
      isSentinelTestMode: isSentinelTestMode ?? this.isSentinelTestMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      settingsVersion: settingsVersion ?? this.settingsVersion,
    );
  }
}
