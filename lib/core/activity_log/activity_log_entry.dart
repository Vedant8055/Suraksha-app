import 'dart:convert';

import 'package:crypto/crypto.dart';

class ActivityLogEntry {
  const ActivityLogEntry({
    required this.timestamp,
    required this.event,
    required this.details,
    required this.prevHash,
    required this.hash,
    this.tampered = false,
  });

  final DateTime timestamp;
  final String event;
  final String details;
  final String prevHash;
  final String hash;
  final bool tampered;

  String get payload =>
      '${timestamp.toUtc().toIso8601String()}|$event|$details|$prevHash';

  static String computeHash(String payload) {
    return sha256.convert(utf8.encode(payload)).toString();
  }

  Map<String, dynamic> toJson() => {
        'ts': timestamp.toUtc().toIso8601String(),
        'event': event,
        'details': details,
        'prev': prevHash,
        'hash': hash,
      };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.tryParse(json['ts']?.toString() ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final event = json['event']?.toString() ?? 'unknown';
    final details = json['details']?.toString() ?? '';
    final prevHash = json['prev']?.toString() ?? '';
    final hash = json['hash']?.toString() ?? '';
    final expected = computeHash(
      '${timestamp.toIso8601String()}|$event|$details|$prevHash',
    );
    return ActivityLogEntry(
      timestamp: timestamp,
      event: event,
      details: details,
      prevHash: prevHash,
      hash: hash,
      tampered: hash != expected,
    );
  }
}
