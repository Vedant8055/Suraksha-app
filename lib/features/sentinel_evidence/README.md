# Sentinel Evidence System (SES)

## Purpose

Self-contained, removable Sentinel Evidence System inside Suraksha.

## Phase status

### Phase 1 — Architecture
Complete.

### Phase 2 — Feature Toggle & Settings
Complete. Profile control plane + local settings.

### Phase 3 — Permissions & Feature Readiness
**Completed.**

- Permission wizard (Camera → Microphone → Location → Summary)
- Permission status screen (Granted / Not Requested / Denied colours)
- `SentinelPermissionService` + `SentinelPermissionController`
- `SentinelReadinessChecker` → READY / PARTIALLY READY / NOT READY
- Permission persistence (SharedPreferences)
- FeatureFlags permission + readiness fields
- Requests only after explicit user action (Allow / Grant / wizard)
- **Recording Pending**
- **Encryption Pending**
- **Upload Pending**
- **Vault Pending**
- **SOS Integration Pending**

## Important

TEST MODE only. Enabling Sentinel and granting permissions does **not** start camera, microphone, recording, encryption, or uploads. SOS behaviour is unchanged.

## Safe Removal

See [`SAFE_REMOVAL.md`](SAFE_REMOVAL.md).
