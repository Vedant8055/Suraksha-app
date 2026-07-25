import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local draft storage for POSH complaint preparation.
class PoshComplaintDraftStorage {
  PoshComplaintDraftStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'posh_complaint_draft_v1';

  Future<Map<String, String>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<void> save(Map<String, String> fields) async {
    await _storage.write(key: _key, value: jsonEncode(fields));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
