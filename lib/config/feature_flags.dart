/// Compile-time feature flags for high-risk Suraksha capabilities.
///
/// Override at build time, e.g.:
/// `flutter run --dart-define=FLAG_SOS_AUTO_SMS=false`
///
/// Defaults keep currently shipping behavior ON.
class FeatureFlags {
  FeatureFlags._();

  /// Android auto-SMS to emergency contacts on SOS.
  static const bool sosAutoSms = bool.fromEnvironment(
    'FLAG_SOS_AUTO_SMS',
    defaultValue: true,
  );

  /// Attach / share public live tracking URL (`/live-sos/{token}`).
  static const bool publicLiveSharing = bool.fromEnvironment(
    'FLAG_PUBLIC_LIVE_SHARING',
    defaultValue: true,
  );

  /// Background microphone / scream & distress phrase monitoring.
  static const bool backgroundMicrophone = bool.fromEnvironment(
    'FLAG_BACKGROUND_MICROPHONE',
    defaultValue: true,
  );

  /// Suraksha AI chat entry points.
  static const bool surakshaAi = bool.fromEnvironment(
    'FLAG_SURAKSHA_AI',
    defaultValue: true,
  );

  /// Cybercrime evidence file uploads.
  static const bool cyberEvidenceUpload = bool.fromEnvironment(
    'FLAG_CYBER_EVIDENCE_UPLOAD',
    defaultValue: true,
  );
}
