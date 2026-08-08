# Sentinel Evidence System — Testing Notes

## Phase 1

- No automated tests are required yet.
- `mock_services.dart` and `dummy_models.dart` exist so later phases can add tests without restructuring.
- Do not call production Suraksha SOS / camera / upload code from these mocks.

## Later phases

- Add unit tests for validators, metadata builders, and encryption (when implemented).
- Add widget tests only after SES UI is intentionally wired.
- Keep all SES tests under this module or `test/features/sentinel_evidence/`.
