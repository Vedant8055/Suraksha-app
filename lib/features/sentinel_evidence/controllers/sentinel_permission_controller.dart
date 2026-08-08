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

/// Permission controller — check / store / refresh / notify UI (no capture).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../config/feature_flags.dart';
import '../controllers/sentinel_controller.dart';
import '../models/sentinel_enums.dart';
import '../models/sentinel_permission_status.dart';
import '../models/sentinel_permission_summary.dart';
import '../permissions/sentinel_readiness_checker.dart';
import '../services/sentinel_permission_service.dart';
import '../state/sentinel_state.dart';
import '../utils/sentinel_logger.dart';

class SentinelPermissionState {
  const SentinelPermissionState({
    required this.summary,
    required this.readiness,
    this.busy = false,
    this.errorMessage,
  });

  final SentinelPermissionSummary summary;
  final SentinelReadinessResult readiness;
  final bool busy;
  final String? errorMessage;

  factory SentinelPermissionState.initial() {
    const summary = SentinelPermissionSummary();
    const readiness = SentinelReadinessResult(
      level: SentinelReadinessLevel.notReady,
      sentinelEnabled: false,
      cameraGranted: false,
      microphoneGranted: false,
      locationGranted: false,
    );
    return const SentinelPermissionState(
      summary: summary,
      readiness: readiness,
    );
  }

  SentinelPermissionState copyWith({
    SentinelPermissionSummary? summary,
    SentinelReadinessResult? readiness,
    bool? busy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SentinelPermissionState(
      summary: summary ?? this.summary,
      readiness: readiness ?? this.readiness,
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SentinelPermissionController
    extends StateNotifier<SentinelPermissionState> {
  SentinelPermissionController({
    required this.isSentinelEnabled,
    SentinelPermissionService? service,
    SentinelReadinessChecker checker = const SentinelReadinessChecker(),
    SentinelLogger logger = const SentinelLogger(),
  })  : _service = service ?? SentinelPermissionService(logger: logger),
        _checker = checker,
        _logger = logger,
        super(SentinelPermissionState.initial());

  bool isSentinelEnabled;
  final SentinelPermissionService _service;
  final SentinelReadinessChecker _checker;
  final SentinelLogger _logger;

  Future<void> initialize() async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final summary = await _service.getPermissionSummary();
      _publish(summary);
    } catch (error) {
      state = state.copyWith(busy: false, errorMessage: error.toString());
    }
  }

  Future<void> refreshPermissions() async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final summary = await _service.refreshPermissions();
      _publish(summary);
    } catch (error) {
      state = state.copyWith(busy: false, errorMessage: error.toString());
    }
  }

  Future<SentinelPermissionStatus> requestCamera() =>
      _requestOne(_service.requestCameraPermission, (s, v) => s.copyWith(camera: v));

  Future<SentinelPermissionStatus> requestMicrophone() => _requestOne(
        _service.requestMicrophonePermission,
        (s, v) => s.copyWith(microphone: v),
      );

  Future<SentinelPermissionStatus> requestLocation() => _requestOne(
        _service.requestLocationPermission,
        (s, v) => s.copyWith(location: v),
      );

  void reevaluateReadiness() {
    _publish(state.summary);
  }

  Future<void> completeWizard() async {
    final summary = state.summary.copyWith(
      wizardCompleted: true,
      permissionTimestamp: DateTime.now(),
      lastCheck: DateTime.now(),
    );
    await _service.applyAndPersist(summary);
    _publish(summary);
  }

  Future<void> openAppSettingsIfNeeded() async {
    await ph.openAppSettings();
  }

  Future<SentinelPermissionStatus> _requestOne(
    Future<SentinelPermissionStatus> Function() request,
    SentinelPermissionSummary Function(
      SentinelPermissionSummary,
      SentinelPermissionStatus,
    ) merge,
  ) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final status = await request();
      if (status.permanentlyDenied) {
        _logger.log('Permission Denied');
      }
      final summary = merge(state.summary, status).copyWith(
        permissionTimestamp: DateTime.now(),
        lastCheck: DateTime.now(),
      );
      await _service.applyAndPersist(summary);
      _publish(summary);
      return status;
    } catch (error) {
      state = state.copyWith(busy: false, errorMessage: error.toString());
      rethrow;
    }
  }

  void _publish(SentinelPermissionSummary summary) {
    final readiness = _checker.evaluate(
      isSentinelEnabled: isSentinelEnabled,
      permissions: summary,
    );
    FeatureFlags.instance.applyPermissionFlags(
      cameraPermissionGranted: summary.cameraGranted,
      microphonePermissionGranted: summary.microphoneGranted,
      locationPermissionGranted: summary.locationGranted,
      readiness: readiness.level,
    );
    state = state.copyWith(
      summary: summary,
      readiness: readiness,
      busy: false,
      clearError: true,
    );
  }

  SentinelState mapToSentinelPhase() {
    if (!isSentinelEnabled) return const SentinelDisabled();
    if (!state.summary.wizardCompleted) {
      return const SentinelPermissionsPending();
    }
    switch (state.readiness.level) {
      case SentinelReadinessLevel.ready:
        return const SentinelReady();
      case SentinelReadinessLevel.partiallyReady:
        return const SentinelPartiallyReady();
      case SentinelReadinessLevel.notReady:
        return const SentinelPermissionsPending();
    }
  }
}

final sentinelPermissionControllerProvider = StateNotifierProvider<
    SentinelPermissionController, SentinelPermissionState>((ref) {
  final controller = SentinelPermissionController(
    isSentinelEnabled: ref.read(sentinelControllerProvider).isEnabled,
  );
  controller.initialize();
  ref.listen<bool>(
    sentinelControllerProvider.select((s) => s.isEnabled),
    (previous, next) {
      controller.isSentinelEnabled = next;
      // Toggle OFF does not revoke OS permissions — only re-evaluate readiness.
      controller.reevaluateReadiness();
    },
  );
  return controller;
});
