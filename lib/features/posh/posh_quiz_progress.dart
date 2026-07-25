import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Shared quiz progress keys and persistence for POSH certification.
class PoshQuizProgress {
  PoshQuizProgress._();

  static const progressKey = 'posh_quiz_progress_v1';
  static const certificateKey = 'posh_certificate_issued_at_v1';
  static const passScore = 16;
  static const levelCount = 3;

  static Future<PoshQuizProgressState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProgress = prefs.getString(progressKey);
    final certificateMillis = prefs.getInt(certificateKey);

    final passedLevels = <int>{};
    final bestScores = <int, int>{};
    final attemptCounts = <int, int>{};
    DateTime? certificateIssuedAt;

    if (rawProgress != null && rawProgress.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawProgress);
        if (decoded is Map<String, dynamic>) {
          passedLevels.addAll(
            (decoded['passedLevels'] as List? ?? const [])
                .map((e) => int.tryParse(e.toString()))
                .whereType<int>(),
          );

          final scoresMap = decoded['bestScores'];
          if (scoresMap is Map) {
            for (final entry in scoresMap.entries) {
              final key = int.tryParse(entry.key.toString());
              final value = int.tryParse(entry.value.toString());
              if (key != null && value != null) {
                bestScores[key] = value;
              }
            }
          }

          final attemptsMap = decoded['attemptCounts'];
          if (attemptsMap is Map) {
            for (final entry in attemptsMap.entries) {
              final key = int.tryParse(entry.key.toString());
              final value = int.tryParse(entry.value.toString());
              if (key != null && value != null) {
                attemptCounts[key] = value;
              }
            }
          }
        }
      } catch (_) {
        // Ignore corrupted progress and start fresh.
      }
    }

    if (certificateMillis != null) {
      certificateIssuedAt = DateTime.fromMillisecondsSinceEpoch(
        certificateMillis,
      );
    }

    final certificateReady = passedLevels.length == levelCount;
    return PoshQuizProgressState(
      passedLevels: passedLevels,
      bestScores: bestScores,
      attemptCounts: attemptCounts,
      certificateIssuedAt: certificateIssuedAt,
      certificateReady: certificateReady,
    );
  }

  static Future<void> save(PoshQuizProgressState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      progressKey,
      jsonEncode({
        'passedLevels': state.passedLevels.toList(),
        'bestScores': state.bestScores.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        'attemptCounts': state.attemptCounts.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      }),
    );
    if (state.certificateIssuedAt != null) {
      await prefs.setInt(
        certificateKey,
        state.certificateIssuedAt!.millisecondsSinceEpoch,
      );
    }
  }
}

class PoshQuizProgressState {
  const PoshQuizProgressState({
    required this.passedLevels,
    required this.bestScores,
    required this.attemptCounts,
    required this.certificateReady,
    this.certificateIssuedAt,
  });

  final Set<int> passedLevels;
  final Map<int, int> bestScores;
  final Map<int, int> attemptCounts;
  final bool certificateReady;
  final DateTime? certificateIssuedAt;

  PoshQuizProgressState copyWith({
    Set<int>? passedLevels,
    Map<int, int>? bestScores,
    Map<int, int>? attemptCounts,
    bool? certificateReady,
    DateTime? certificateIssuedAt,
  }) {
    return PoshQuizProgressState(
      passedLevels: passedLevels ?? this.passedLevels,
      bestScores: bestScores ?? this.bestScores,
      attemptCounts: attemptCounts ?? this.attemptCounts,
      certificateReady: certificateReady ?? this.certificateReady,
      certificateIssuedAt: certificateIssuedAt ?? this.certificateIssuedAt,
    );
  }
}
