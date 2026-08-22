import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Unlocks using the phone's existing screen lock (PIN, password, pattern,
/// fingerprint, or face). Does not create an app-specific PIN.
class DeviceCredentialAuth {
  DeviceCredentialAuth({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true only after the OS unlock prompt succeeds.
  Future<bool> authenticate({required String reason}) async {
    try {
      final available = await isAvailable();
      if (!available) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
