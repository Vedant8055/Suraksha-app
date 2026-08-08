/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Permissions & Feature Readiness (Phase 3)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

/// Persists SES permission grant labels (not OS revocation).
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/sentinel_keys.dart';
import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';
import '../models/sentinel_permission_summary.dart';

class SentinelPermissionStorage {
  SentinelPermissionStorage({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const int currentPermissionVersion = 1;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SentinelPermissionSummary> load() async {
    final prefs = await _ensurePrefs();
    final ts = prefs.getInt(SentinelKeys.permissionTimestamp);
    final last = prefs.getInt(SentinelKeys.permissionLastCheck);
    return SentinelPermissionSummary(
      camera: _readStatus(
        prefs,
        SentinelKeys.cameraPermission,
        PermissionType.camera,
      ),
      microphone: _readStatus(
        prefs,
        SentinelKeys.microphonePermission,
        PermissionType.microphone,
      ),
      location: _readStatus(
        prefs,
        SentinelKeys.locationPermission,
        PermissionType.location,
      ),
      permissionTimestamp:
          ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts),
      permissionVersion: prefs.getInt(SentinelKeys.permissionVersion) ??
          currentPermissionVersion,
      lastCheck:
          last == null ? null : DateTime.fromMillisecondsSinceEpoch(last),
      wizardCompleted:
          prefs.getBool(SentinelKeys.permissionWizardCompleted) ?? false,
    );
  }

  Future<void> save(SentinelPermissionSummary summary) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      SentinelKeys.cameraPermission,
      summary.camera.grant.name,
    );
    await prefs.setString(
      SentinelKeys.microphonePermission,
      summary.microphone.grant.name,
    );
    await prefs.setString(
      SentinelKeys.locationPermission,
      summary.location.grant.name,
    );
    final now = DateTime.now();
    await prefs.setInt(
      SentinelKeys.permissionTimestamp,
      (summary.permissionTimestamp ?? now).millisecondsSinceEpoch,
    );
    await prefs.setInt(
      SentinelKeys.permissionVersion,
      summary.permissionVersion,
    );
    await prefs.setInt(
      SentinelKeys.permissionLastCheck,
      (summary.lastCheck ?? now).millisecondsSinceEpoch,
    );
    await prefs.setBool(
      SentinelKeys.permissionWizardCompleted,
      summary.wizardCompleted,
    );
  }

  SentinelPermissionStatus _readStatus(
    SharedPreferences prefs,
    String key,
    PermissionType type,
  ) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return SentinelPermissionStatus(type: type);
    }
    final grant = SentinelPermissionGrant.values.firstWhere(
      (g) => g.name == raw,
      orElse: () => SentinelPermissionGrant.notRequested,
    );
    return SentinelPermissionStatus(
      type: type,
      grant: grant,
      permanentlyDenied: grant == SentinelPermissionGrant.permanentlyDenied,
    );
  }
}
