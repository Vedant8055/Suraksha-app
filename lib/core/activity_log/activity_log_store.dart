import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_entry.dart';

/// Encrypted, append-only, 7-day activity log on device.
class ActivityLogStore {
  ActivityLogStore({
    FlutterSecureStorage? secureStorage,
    Directory? directory,
    enc.Key? testKey,
  })  : _secure = secureStorage ?? const FlutterSecureStorage(),
        _overrideDir = directory,
        _cachedKey = testKey;

  static const retentionDays = 7;
  static const maxEventsPerDay = 4000;
  static const _keyName = 'activity_log_aes_key_v1';

  final FlutterSecureStorage _secure;
  final Directory? _overrideDir;
  Future<void> _chain = Future<void>.value();
  enc.Key? _cachedKey;

  Future<T> _serialized<T>(Future<T> Function() action) {
    final result = _chain.then((_) => action());
    _chain = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<Directory> _dir() async {
    final override = _overrideDir;
    if (override != null) return override;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/activity_logs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<enc.Key> _key() async {
    if (_cachedKey != null) return _cachedKey!;
    var stored = await _secure.read(key: _keyName);
    if (stored == null || stored.isEmpty) {
      stored = enc.Key.fromSecureRandom(32).base64;
      await _secure.write(key: _keyName, value: stored);
    }
    _cachedKey = enc.Key.fromBase64(stored);
    return _cachedKey!;
  }

  String _dayName(DateTime utc) => DateFormat('yyyy-MM-dd').format(utc.toUtc());

  File _fileFor(Directory dir, DateTime utc) =>
      File('${dir.path}/${_dayName(utc)}.log.enc');

  String _encryptLine(String plain, enc.Key key) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plain, iv: iv);
    final packed = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64Encode(packed);
  }

  String? _decryptLine(String line, enc.Key key) {
    try {
      final packed = base64Decode(line.trim());
      if (packed.length <= 16) return null;
      final iv = enc.IV(Uint8List.fromList(packed.sublist(0, 16)));
      final data = packed.sublist(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(enc.Encrypted(data), iv: iv);
    } catch (_) {
      return null;
    }
  }

  Future<void> append({
    required String event,
    required String details,
  }) {
    return _serialized(() async {
      await purgeExpired();
      final now = DateTime.now().toUtc();
      final dir = await _dir();
      final file = _fileFor(dir, now);
      final key = await _key();
      final existing = await _readFile(file, key);
      if (existing.length >= maxEventsPerDay) return;

      final prevHash = existing.isEmpty ? 'genesis' : existing.last.hash;
      final timestamp = now;
      final payload =
          '${timestamp.toIso8601String()}|$event|$details|$prevHash';
      final entry = ActivityLogEntry(
        timestamp: timestamp,
        event: event,
        details: details,
        prevHash: prevHash,
        hash: ActivityLogEntry.computeHash(payload),
      );
      final line = _encryptLine(jsonEncode(entry.toJson()), key);
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    });
  }

  Future<List<ActivityLogEntry>> _readFile(File file, enc.Key key) async {
    if (!await file.exists()) return const [];
    final raw = await file.readAsString();
    final lines = raw.split('\n').where((line) => line.trim().isNotEmpty);
    final entries = <ActivityLogEntry>[];
    var expectedPrev = 'genesis';
    for (final line in lines) {
      final plain = _decryptLine(line, key);
      if (plain == null) {
        entries.add(
          ActivityLogEntry(
            timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            event: 'integrity_error',
            details: 'Could not decrypt a log line.',
            prevHash: expectedPrev,
            hash: '',
            tampered: true,
          ),
        );
        continue;
      }
      try {
        final parsed = ActivityLogEntry.fromJson(
          jsonDecode(plain) as Map<String, dynamic>,
        );
        final chainBreak = parsed.prevHash != expectedPrev;
        entries.add(
          chainBreak ? _markTampered(parsed) : parsed,
        );
        expectedPrev = parsed.hash;
      } catch (_) {
        entries.add(
          ActivityLogEntry(
            timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
            event: 'integrity_error',
            details: 'Could not parse a log line.',
            prevHash: expectedPrev,
            hash: '',
            tampered: true,
          ),
        );
      }
    }
    return entries;
  }

  ActivityLogEntry _markTampered(ActivityLogEntry entry) {
    return ActivityLogEntry(
      timestamp: entry.timestamp,
      event: entry.event,
      details: entry.details,
      prevHash: entry.prevHash,
      hash: entry.hash,
      tampered: true,
    );
  }

  Future<List<ActivityLogEntry>> readRange(DateTime from, DateTime to) {
    return _serialized(() async {
      await purgeExpired();
      final start = from.toUtc();
      final end = to.toUtc();
      if (!end.isAfter(start)) return const [];
      final dir = await _dir();
      final key = await _key();
      final collected = <ActivityLogEntry>[];
      for (var day = DateTime.utc(start.year, start.month, start.day);
          !day.isAfter(end);
          day = day.add(const Duration(days: 1))) {
        final file = _fileFor(dir, day);
        final rows = await _readFile(file, key);
        collected.addAll(
          rows.where(
            (row) =>
                !row.timestamp.isBefore(start) && !row.timestamp.isAfter(end),
          ),
        );
      }
      collected.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return collected;
    });
  }

  Future<List<ActivityLogEntry>> readRecent() {
    final now = DateTime.now().toUtc();
    return readRange(
      now.subtract(const Duration(days: retentionDays)),
      now.add(const Duration(minutes: 1)),
    );
  }

  Future<void> purgeExpired() async {
    final dir = await _dir();
    if (!await dir.exists()) return;
    final cutoff = DateTime.now().toUtc().subtract(
      const Duration(days: retentionDays),
    );
    final cutoffName = _dayName(cutoff);
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.endsWith('.log.enc')) continue;
      final day = name.replaceAll('.log.enc', '');
      if (day.compareTo(cutoffName) < 0) {
        await entity.delete();
      }
    }
  }
}
