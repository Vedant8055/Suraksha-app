import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suraksha_women_safety_app/features/medical/medical_vault_auth.dart';

/// Optional PIN/biometric gate for Secure Evidence Vault viewing.
class CyberVaultLock {
  CyberVaultLock({
    FlutterSecureStorage? secureStorage,
    MedicalVaultAuth? auth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _auth = auth ?? MedicalVaultAuth();

  final FlutterSecureStorage _secureStorage;
  final MedicalVaultAuth _auth;

  static const _enabledKey = 'cyber_vault_lock_enabled_v1';
  static const _pinHashKey = 'cyber_vault_lock_pin_hash_v1';
  static const _pbkdfIterations = 60000;

  Future<bool> isEnabled() async {
    return (await _secureStorage.read(key: _enabledKey)) == '1';
  }

  Future<bool> canUseBiometrics() => _auth.canUseBiometrics();

  Future<void> enablePin(String pin) async {
    final normalized = pin.trim();
    if (normalized.length < 4) {
      throw ArgumentError('PIN too short');
    }
    await _secureStorage.write(
      key: _pinHashKey,
      value: _hashV2(normalized),
    );
    await _secureStorage.write(key: _enabledKey, value: '1');
  }

  Future<void> disable() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.write(key: _enabledKey, value: '0');
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(key: _pinHashKey);
    if (stored == null || stored.isEmpty) return false;
    final normalized = pin.trim();
    if (stored.startsWith('v2:')) {
      return stored == _hashV2(normalized, saltHex: stored.split(':')[1]);
    }
    if (stored == _legacyHash(normalized)) {
      await _secureStorage.write(key: _pinHashKey, value: _hashV2(normalized));
      return true;
    }
    return false;
  }

  Future<bool> authenticateBiometric({required String reason}) {
    return _auth.authenticate(reason: reason);
  }

  String _legacyHash(String pin) =>
      sha256.convert(utf8.encode('cyber_vault::$pin')).toString();

  String _hashV2(String pin, {String? saltHex}) {
    final salt = saltHex ?? _randomSaltHex();
    final derived = _pbkdf2Sha256(
      password: utf8.encode('cyber_vault::$pin'),
      salt: utf8.encode(salt),
      iterations: _pbkdfIterations,
      length: 32,
    );
    return 'v2:$salt:${base64UrlEncode(derived)}';
  }

  static String _randomSaltHex() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List _pbkdf2Sha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  }) {
    final hmac = Hmac(sha256, password);
    final blockCount = (length / 32).ceil();
    final out = BytesBuilder(copy: false);
    for (var block = 1; block <= blockCount; block++) {
      final blockSalt = BytesBuilder(copy: false)
        ..add(salt)
        ..add([
          (block >> 24) & 0xff,
          (block >> 16) & 0xff,
          (block >> 8) & 0xff,
          block & 0xff,
        ]);
      var u = hmac.convert(blockSalt.toBytes()).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.add(t);
    }
    return Uint8List.fromList(out.toBytes().sublist(0, length));
  }
}
