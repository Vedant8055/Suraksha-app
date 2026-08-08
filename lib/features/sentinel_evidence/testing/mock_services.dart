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

/// Mock service stubs for future unit / widget tests.
library;

import '../services/sentinel_camera_service.dart';
import '../services/sentinel_recorder_service.dart';

class MockSentinelRecorderService extends SentinelRecorderService {
  @override
  Future<void> prepare() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> disposeService() async {}
}

class MockSentinelCameraService extends SentinelCameraService {
  @override
  Future<void> prepare() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
