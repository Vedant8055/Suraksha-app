# Safe Removal — Sentinel Evidence System

## Steps

1. Delete `app/lib/features/sentinel_evidence/`
2. In `profile_screen.dart`, remove:
   - `SentinelProfileCard` import
   - `const SentinelProfileCard()` widget
3. Optional: remove `android.permission.CAMERA` from `AndroidManifest.xml` if nothing else needs it
4. Optional (iOS): remove SES-added usage description strings if unused elsewhere
5. Run `flutter analyze`

SOS and other Suraksha features are not coupled to Sentinel in Phases 1–3.
