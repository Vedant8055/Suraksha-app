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

/// Location provider contract. No implementation in Phase 1.
library;

import '../models/sentinel_location.dart';

abstract class ILocationProvider {
  Future<SentinelLocation?> currentLocation();
}
