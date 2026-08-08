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

/// Permission checks / requests only — never opens camera or mic streams.
library;

import 'package:permission_handler/permission_handler.dart' as ph;

import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';
import '../models/sentinel_permission_summary.dart';
import '../storage/sentinel_permission_storage.dart';
import '../utils/sentinel_logger.dart';

class SentinelPermissionService {
  SentinelPermissionService({
    SentinelPermissionStorage? storage,
    SentinelLogger logger = const SentinelLogger(),
  })  : _storage = storage ?? SentinelPermissionStorage(),
        _logger = logger;

  final SentinelPermissionStorage _storage;
  final SentinelLogger _logger;

  Future<SentinelPermissionStatus> checkCameraPermission() async {
    _logger.log('Checking Camera Permission');
    return _check(PermissionType.camera, ph.Permission.camera);
  }

  Future<SentinelPermissionStatus> requestCameraPermission() async {
    _logger.log('Checking Camera Permission');
    return _request(PermissionType.camera, ph.Permission.camera);
  }

  Future<SentinelPermissionStatus> checkMicrophonePermission() async {
    _logger.log('Checking Microphone Permission');
    return _check(PermissionType.microphone, ph.Permission.microphone);
  }

  Future<SentinelPermissionStatus> requestMicrophonePermission() async {
    _logger.log('Checking Microphone Permission');
    return _request(PermissionType.microphone, ph.Permission.microphone);
  }

  Future<SentinelPermissionStatus> checkLocationPermission() async {
    _logger.log('Checking Location Permission');
    return _check(PermissionType.location, ph.Permission.locationWhenInUse);
  }

  Future<SentinelPermissionStatus> requestLocationPermission() async {
    _logger.log('Checking Location Permission');
    return _request(PermissionType.location, ph.Permission.locationWhenInUse);
  }

  /// Checks OS status for all three permissions and persists the summary.
  Future<SentinelPermissionSummary> refreshPermissions({
    bool markWizardCompleted = false,
  }) async {
    final existing = await _storage.load();
    final camera = await checkCameraPermission();
    final mic = await checkMicrophonePermission();
    final location = await checkLocationPermission();
    final now = DateTime.now();
    final summary = existing.copyWith(
      camera: camera,
      microphone: mic,
      location: location,
      permissionTimestamp: now,
      lastCheck: now,
      permissionVersion: SentinelPermissionStorage.currentPermissionVersion,
      wizardCompleted: markWizardCompleted || existing.wizardCompleted,
    );
    await _storage.save(summary);
    return summary;
  }

  Future<SentinelPermissionSummary> getPermissionSummary() => _storage.load();

  Future<void> markWizardCompleted() async {
    final existing = await _storage.load();
    await _storage.save(existing.copyWith(wizardCompleted: true));
  }

  Future<SentinelPermissionSummary> applyAndPersist(
    SentinelPermissionSummary summary,
  ) async {
    await _storage.save(summary);
    return summary;
  }

  Future<SentinelPermissionStatus> _check(
    PermissionType type,
    ph.Permission permission,
  ) async {
    final status = await permission.status;
    final mapped = _mapStatus(type, status);
    _logGrant(mapped);
    return mapped;
  }

  Future<SentinelPermissionStatus> _request(
    PermissionType type,
    ph.Permission permission,
  ) async {
    final status = await permission.request();
    final mapped = _mapStatus(type, status);
    _logGrant(mapped);
    return mapped;
  }

  SentinelPermissionStatus _mapStatus(
    PermissionType type,
    ph.PermissionStatus status,
  ) {
    final now = DateTime.now();
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return SentinelPermissionStatus(
        type: type,
        grant: SentinelPermissionGrant.granted,
        checkedAt: now,
      );
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return SentinelPermissionStatus(
        type: type,
        grant: SentinelPermissionGrant.permanentlyDenied,
        permanentlyDenied: true,
        checkedAt: now,
      );
    }
    if (status.isDenied) {
      return SentinelPermissionStatus(
        type: type,
        grant: SentinelPermissionGrant.denied,
        checkedAt: now,
      );
    }
    return SentinelPermissionStatus(
      type: type,
      grant: SentinelPermissionGrant.notRequested,
      checkedAt: now,
    );
  }

  void _logGrant(SentinelPermissionStatus status) {
    _logger.log(
      status.granted ? 'Permission Granted' : 'Permission Denied',
    );
  }
}
