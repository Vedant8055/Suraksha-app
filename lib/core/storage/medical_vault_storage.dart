import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalVaultData {
  const MedicalVaultData({
    this.bloodGroup = '',
    this.allergies = '',
    this.conditions = '',
    this.medications = '',
    this.emergencyNotes = '',
    this.lastUpdatedAt,
  });

  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String medications;
  final String emergencyNotes;
  final DateTime? lastUpdatedAt;

  bool get isEmpty =>
      bloodGroup.trim().isEmpty &&
      allergies.trim().isEmpty &&
      conditions.trim().isEmpty &&
      medications.trim().isEmpty &&
      emergencyNotes.trim().isEmpty;

  MedicalVaultData copyWith({
    String? bloodGroup,
    String? allergies,
    String? conditions,
    String? medications,
    String? emergencyNotes,
    DateTime? lastUpdatedAt,
  }) {
    return MedicalVaultData(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
      emergencyNotes: emergencyNotes ?? this.emergencyNotes,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toExportJson() => {
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'conditions': conditions,
        'medications': medications,
        'emergencyNotes': emergencyNotes,
        'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      };

  String toShareText() {
    final updated = lastUpdatedAt?.toLocal().toString() ?? 'n/a';
    return [
      'Suraksha Medical Health Vault',
      'Blood group: ${bloodGroup.isEmpty ? 'Not provided' : bloodGroup}',
      'Allergies: ${allergies.isEmpty ? 'Not provided' : allergies}',
      'Conditions: ${conditions.isEmpty ? 'Not provided' : conditions}',
      'Medications: ${medications.isEmpty ? 'Not provided' : medications}',
      'Emergency notes: ${emergencyNotes.isEmpty ? 'Not provided' : emergencyNotes}',
      'Last updated: $updated',
      '',
      'Disclaimer: User-provided information only. Not verified medical advice.',
    ].join('\n');
  }
}

class MedicalVaultStorage {
  MedicalVaultStorage(
    this.userId, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final String userId;
  final FlutterSecureStorage _secureStorage;

  static const _legacyKeys = {
    'blood': 'medical_blood_group_v1',
    'allergies': 'medical_allergies_v1',
    'conditions': 'medical_conditions_v1',
    'medications': 'medical_medications_v1',
  };

  static const _fields = [
    'blood',
    'allergies',
    'conditions',
    'medications',
    'emergencyNotes',
    'lastUpdatedAt',
  ];

  static const _pbkdfIterations = 60000;

  String _key(String field) => 'medical_vault_v2_${userId}_$field';

  String get _pinHashKey => 'medical_vault_v2_${userId}_pin_hash';
  String get _lockEnabledKey => 'medical_vault_v2_${userId}_lock_enabled';

  Future<MedicalVaultData> read() async {
    await _migrateLegacyValues();
    final lastUpdatedRaw =
        await _secureStorage.read(key: _key('lastUpdatedAt'));
    return MedicalVaultData(
      bloodGroup: await _secureStorage.read(key: _key('blood')) ?? '',
      allergies: await _secureStorage.read(key: _key('allergies')) ?? '',
      conditions: await _secureStorage.read(key: _key('conditions')) ?? '',
      medications: await _secureStorage.read(key: _key('medications')) ?? '',
      emergencyNotes:
          await _secureStorage.read(key: _key('emergencyNotes')) ?? '',
      lastUpdatedAt: DateTime.tryParse(lastUpdatedRaw ?? ''),
    );
  }

  Future<void> write(MedicalVaultData data, {bool touchUpdatedAt = true}) async {
    final updatedAt = touchUpdatedAt
        ? DateTime.now().toUtc()
        : (data.lastUpdatedAt ?? DateTime.now().toUtc());
    await Future.wait([
      _writeOrDelete('blood', data.bloodGroup),
      _writeOrDelete('allergies', data.allergies),
      _writeOrDelete('conditions', data.conditions),
      _writeOrDelete('medications', data.medications),
      _writeOrDelete('emergencyNotes', data.emergencyNotes),
      _secureStorage.write(
        key: _key('lastUpdatedAt'),
        value: updatedAt.toIso8601String(),
      ),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      for (final field in _fields) _secureStorage.delete(key: _key(field)),
    ]);
  }

  Future<bool> isLockEnabled() async {
    final value = await _secureStorage.read(key: _lockEnabledKey);
    return value == '1';
  }

  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final normalized = pin.trim();
    if (normalized.length < 4) {
      throw ArgumentError('PIN must be at least 4 digits');
    }
    await _secureStorage.write(
      key: _pinHashKey,
      value: _hashPinV2(normalized),
    );
    await _secureStorage.write(key: _lockEnabledKey, value: '1');
  }

  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.write(key: _lockEnabledKey, value: '0');
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(key: _pinHashKey);
    if (stored == null || stored.isEmpty) return false;
    final normalized = pin.trim();
    if (stored.startsWith('v2:')) {
      return _verifyPinV2(normalized, stored);
    }
    // Legacy unsalted hash — accept once, then upgrade in place.
    if (stored == _legacyHashPin(normalized)) {
      await _secureStorage.write(
        key: _pinHashKey,
        value: _hashPinV2(normalized),
      );
      return true;
    }
    return false;
  }

  String _legacyHashPin(String pin) {
    final bytes = utf8.encode('$userId::$pin');
    return sha256.convert(bytes).toString();
  }

  String _hashPinV2(String pin, {String? saltHex}) {
    final salt = saltHex ?? _randomSaltHex();
    final derived = _pbkdf2Sha256(
      password: utf8.encode('$userId::$pin'),
      salt: utf8.encode(salt),
      iterations: _pbkdfIterations,
      length: 32,
    );
    return 'v2:$salt:${base64UrlEncode(derived)}';
  }

  bool _verifyPinV2(String pin, String stored) {
    final parts = stored.split(':');
    if (parts.length != 3) return false;
    final expected = _hashPinV2(pin, saltHex: parts[1]);
    return stored == expected;
  }

  static String _randomSaltHex() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Lightweight PBKDF2-HMAC-SHA256 without extra packages.
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

  Future<void> _writeOrDelete(String field, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return _secureStorage.delete(key: _key(field));
    }
    return _secureStorage.write(key: _key(field), value: normalized);
  }

  Future<void> _migrateLegacyValues() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await Future.wait([
      for (final field in const [
        'blood',
        'allergies',
        'conditions',
        'medications',
      ])
        _secureStorage.read(key: _key(field)),
    ]);
    if (existing.every((value) => value == null)) {
      await write(
        MedicalVaultData(
          bloodGroup: prefs.getString(_legacyKeys['blood']!) ?? '',
          allergies: prefs.getString(_legacyKeys['allergies']!) ?? '',
          conditions: prefs.getString(_legacyKeys['conditions']!) ?? '',
          medications: prefs.getString(_legacyKeys['medications']!) ?? '',
        ),
        touchUpdatedAt: false,
      );
    }
    for (final key in _legacyKeys.values) {
      await prefs.remove(key);
    }
  }

  static Future<void> clearForUser(
    String userId, {
    FlutterSecureStorage? secureStorage,
  }) async {
    final storage = secureStorage ?? const FlutterSecureStorage();
    await Future.wait([
      for (final field in _fields)
        storage.delete(key: 'medical_vault_v2_${userId}_$field'),
      storage.delete(key: 'medical_vault_v2_${userId}_pin_hash'),
      storage.delete(key: 'medical_vault_v2_${userId}_lock_enabled'),
    ]);
  }
}
