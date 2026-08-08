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

/// SES state hierarchy (structure only — no business logic).
library;

sealed class SentinelState {
  const SentinelState();
}

class SentinelInitial extends SentinelState {
  const SentinelInitial();
}

class SentinelLoading extends SentinelState {
  const SentinelLoading();
}

class SentinelDisabled extends SentinelState {
  const SentinelDisabled();
}

class SentinelPermissionsPending extends SentinelState {
  const SentinelPermissionsPending();
}

class SentinelReady extends SentinelState {
  const SentinelReady();
}

class SentinelPartiallyReady extends SentinelState {
  const SentinelPartiallyReady();
}

class SentinelError extends SentinelState {
  const SentinelError(this.message);

  final String message;
}
