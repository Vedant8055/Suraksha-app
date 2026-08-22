import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_certificate_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_education_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_data.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_progress.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/widgets/premium_dialog.dart';

class POSHQuizScreen extends StatefulWidget {
  const POSHQuizScreen({super.key});

  @override
  State<POSHQuizScreen> createState() => _POSHQuizScreenState();
}

class _POSHQuizScreenState extends State<POSHQuizScreen> {
  final Map<int, Map<int, Set<int>>> _answers = {};
  Set<int> _passedLevels = {};
  Map<int, int> _bestScores = {};
  Map<int, int> _attemptCounts = {};

  bool _submitting = false;
  bool _loadingProgress = true;
  bool _certificateReady = false;
  DateTime? _certificateIssuedAt;
  int _activeLevelIndex = 0;
  int _activeQuestionIndex = 0;

  List<PoshQuizLevel> get _levels => buildPoshQuizLevels(context);

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgress());
  }

  Future<void> _loadProgress() async {
    final state = await PoshQuizProgress.load();
    if (!mounted) return;
    setState(() {
      _passedLevels = state.passedLevels;
      _bestScores = state.bestScores;
      _attemptCounts = state.attemptCounts;
      _certificateReady = state.certificateReady;
      _certificateIssuedAt = state.certificateIssuedAt;
      _loadingProgress = false;
    });
    unawaited(
      AppActivityLog.instance.record(
        'posh_quiz',
        message: 'POSH quiz started',
      ),
    );
  }

  Future<void> _saveProgress() async {
    await PoshQuizProgress.save(
      PoshQuizProgressState(
        passedLevels: _passedLevels,
        bestScores: _bestScores,
        attemptCounts: _attemptCounts,
        certificateReady: _certificateReady,
        certificateIssuedAt: _certificateIssuedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('poshHubQuizTitle')),
        systemOverlayStyle: AppTheme.overlayStyleForBrightness(
          Theme.of(context).brightness,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors.backgroundGradient,
          ),
        ),
        child: _loadingProgress
            ? const Center(child: CircularProgressIndicator())
            : _buildQuizBody(context),
      ),
    );
  }

  Widget _buildQuizBody(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final totalPassed = _passedLevels.length;
    final allComplete = _certificateReady || totalPassed == _levels.length;
    final currentLevel = _levels[_activeLevelIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        PoshHeroCard(
          title: l10n.t('quizCertificationTrack'),
          subtitle: l10n.t('studyFirstThenClearQuizzesInOrder'),
          icon: Icons.workspace_premium_rounded,
          accentColor: const Color(0xFF8E7CF4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoshQuizProgressRow(
                levelCount: _levels.length,
                passedLevels: _passedLevels,
                activeLevelIndex: _activeLevelIndex,
                onLevelTap: (index, available) {
                  if (available) {
                    setState(() {
                      _activeLevelIndex = index;
                      _activeQuestionIndex = 0;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.t('clearPreviousQuizToUnlockThisLevel'),
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 14),
              Text(
                allComplete
                    ? l10n.t('poshQuizAllLevelsCleared')
                    : l10n.t('studyFirstThenClearQuizzesInOrder'),
                style: TextStyle(color: colors.mutedText, height: 1.3),
              ),
            ],
          ),
        ),
        if (allComplete) ...[
          const SizedBox(height: 14),
          _buildCertificateShortcut(context),
        ],
        const SizedBox(height: 8),
        _buildLevelSelector(context),
        const SizedBox(height: 8),
        _buildLevelIntroCard(context, currentLevel),
        const SizedBox(height: 14),
        _buildQuestionCard(
          context,
          currentLevel,
          _activeLevelIndex,
          _activeQuestionIndex,
        ),
      ],
    );
  }

  Widget _buildCertificateShortcut(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: 'POSH certificate'),
            builder: (_) => const POSHCertificateScreen(),
          ),
        ),
        icon: const Icon(Icons.workspace_premium_rounded),
        label: Text(l10n.t('viewCertificate')),
        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
    );
  }

  Widget _buildLevelSelector(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final levelTitle = '${l10n.t('level')} ${_activeLevelIndex + 1}';

    return GestureDetector(
      onTap: () => setState(() => _activeQuestionIndex = 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.fieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              levelTitle,
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              l10n.t('currentLevel'),
              style: TextStyle(color: colors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIntroCard(BuildContext context, PoshQuizLevel level) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.title,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            level.summary,
            style: TextStyle(color: colors.mutedText, height: 1.35),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PoshSmallPill(
                label: l10n
                    .t('poshQuizQuestionsCount')
                    .replaceAll('{count}', '${level.questions.length}'),
                icon: Icons.quiz_rounded,
              ),
              const SizedBox(width: 8),
              PoshSmallPill(
                label: level.questions.any((q) => q.multiSelect)
                    ? l10n.t('poshQuizMixedMcq')
                    : l10n.t('poshQuizSingleChoice'),
                icon: Icons.checklist_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    PoshQuizLevel level,
    int levelIndex,
    int questionIndex,
  ) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final question = level.questions[questionIndex];
    final answerMap = _answers.putIfAbsent(levelIndex, () => {});
    final selected = answerMap.putIfAbsent(questionIndex, () => <int>{});
    final answeredCount = answerMap.values
        .where((set) => set.isNotEmpty)
        .length;
    final allAnswered =
        answerMap.length == level.questions.length &&
        answerMap.values.every((set) => set.isNotEmpty);
    final isLast = questionIndex == level.questions.length - 1;
    final isFirst = questionIndex == 0;
    final locked = levelIndex > 0 && !_passedLevels.contains(levelIndex - 1);
    final canProceed = !locked && selected.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n
                    .t('poshQuizQuestionProgress')
                    .replaceAll('{current}', '${questionIndex + 1}')
                    .replaceAll('{total}', '${level.questions.length}'),
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                l10n
                    .t('poshQuizAnsweredCount')
                    .replaceAll('{count}', '$answeredCount'),
                style: TextStyle(color: colors.mutedText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...question.options.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PoshAnswerOptionTile(
                label: entry.value,
                selected: selected.contains(entry.key),
                multiSelect: question.multiSelect,
                onTap: () {
                  setState(() {
                    if (question.multiSelect) {
                      if (selected.contains(entry.key)) {
                        selected.remove(entry.key);
                      } else {
                        selected.add(entry.key);
                      }
                    } else {
                      selected
                        ..clear()
                        ..add(entry.key);
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (locked)
            Text(
              l10n.t('clearPreviousQuizToUnlockThisLevel'),
              style: TextStyle(color: colors.mutedText, fontSize: 12),
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [const Color(0xFFFDFEFF), const Color(0xFFF2F7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border.withValues(alpha: 0.72)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isFirst
                            ? null
                            : () => setState(() => _activeQuestionIndex -= 1),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(l10n.t('previous')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting || !canProceed
                            ? null
                            : (isLast
                                  ? () => _submitLevel(levelIndex)
                                  : () => setState(
                                      () => _activeQuestionIndex += 1,
                                    )),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          isLast ? l10n.t('submitQuiz') : l10n.t('next'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _resetLevel(levelIndex),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.t('retryQuiz')),
                  ),
                ),
                if (!allAnswered) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.t('pleaseAnswerEveryQuestionFirst'),
                      style: TextStyle(color: colors.mutedText, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (locked) ...[
            const SizedBox(height: 10),
            Text(
              l10n.t('clearPreviousQuizToUnlockThisLevel'),
              style: TextStyle(color: colors.mutedText, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitLevel(int levelIndex) async {
    final level = _levels[levelIndex];
    final answers = _answers[levelIndex] ?? const {};
    final l10n = AppLocalizations.of(context);

    if (answers.length != level.questions.length ||
        answers.values.any((set) => set.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('pleaseAnswerEveryQuestionFirst'))),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      var score = 0;
      for (var index = 0; index < level.questions.length; index++) {
        final question = level.questions[index];
        final selected = answers[index] ?? const <int>{};
        if (setEquals(selected, question.correctIndexes)) {
          score += 1;
        }
      }

      _attemptCounts[levelIndex] = (_attemptCounts[levelIndex] ?? 0) + 1;
      _bestScores[levelIndex] = score > (_bestScores[levelIndex] ?? 0)
          ? score
          : _bestScores[levelIndex] ?? score;

      if (score >= PoshQuizProgress.passScore) {
        _passedLevels.add(levelIndex);
        unawaited(AppActivityLog.instance.record(
          'posh_quiz',
          message: 'POSH quiz level ${levelIndex + 1} passed ($score marks)',
        ));
        if (levelIndex == _levels.length - 1) {
          _certificateReady = true;
          _certificateIssuedAt ??= DateTime.now();
        }
        await _saveProgress();
        if (!mounted) return;
        await showPremiumDialog<void>(
          context: context,
          title: levelIndex == _levels.length - 1
              ? l10n.t('poshCertified')
              : l10n.t('levelPassed'),
          message: levelIndex == _levels.length - 1
              ? l10n.t('poshQuizCertificateEarned')
              : l10n.t('poshQuizNextLevelUnlocked'),
          icon: Icons.verified_rounded,
          accentColor: const Color(0xFF2ED6C5),
          actions: [
            PremiumDialogAction(
              label: levelIndex == _levels.length - 1
                  ? l10n.t('viewCertificate')
                  : l10n.t('continueLabel'),
              isPrimary: true,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        );
        if (mounted) {
          setState(() {
            _activeLevelIndex = min(levelIndex + 1, _levels.length - 1);
            _activeQuestionIndex = 0;
          });
        }
      } else {
        unawaited(AppActivityLog.instance.record(
          'posh_quiz',
          message: 'POSH quiz level ${levelIndex + 1} attempted ($score marks)',
        ));
        await _saveProgress();
        if (!mounted) return;
        await showPremiumDialog<void>(
          context: context,
          title: l10n.t('quizNotClearedYet'),
          message: l10n
              .t('poshQuizReviewScore')
              .replaceAll('{score}', '$score')
              .replaceAll('{total}', '${level.questions.length}'),
          icon: Icons.refresh_rounded,
          accentColor: const Color(0xFFE53935),
          actions: [
            PremiumDialogAction(
              label: l10n.t('reviewStudy'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'POSH education'),
                    builder: (_) => const POSHEducationScreen(),
                  ),
                );
              },
            ),
            PremiumDialogAction(
              label: l10n.t('retry'),
              isPrimary: true,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        );
        if (mounted) {
          _resetLevel(levelIndex);
          setState(() => _activeQuestionIndex = 0);
        }
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetLevel(int levelIndex) {
    setState(() {
      _answers.remove(levelIndex);
      _activeQuestionIndex = 0;
    });
  }
}
