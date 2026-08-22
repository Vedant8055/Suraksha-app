import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_act_guide_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_data.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_progress.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class POSHEducationScreen extends StatefulWidget {
  const POSHEducationScreen({super.key});

  @override
  State<POSHEducationScreen> createState() => _POSHEducationScreenState();
}

class _POSHEducationScreenState extends State<POSHEducationScreen> {
  bool _loadingProgress = true;
  Set<int> _passedLevels = {};
  int _activeLevelIndex = 0;

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
      _loadingProgress = false;
    });
  }

  void _logStudyFolder(String title) {
    unawaited(
      AppActivityLog.instance.record(
        'posh_folder',
        message: 'POSH study folder opened: $title',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final levels = buildPoshQuizLevels(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('poshHubEducationTitle')),
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
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  FadeInDown(
                    child: PoshHeroCard(
                      title: l10n.t('poshActLearningHub'),
                      subtitle: l10n.t('poshQuizStudySubtitle'),
                      icon: Icons.workspace_premium_rounded,
                      accentColor: const Color(0xFF3B82F6),
                      child: Column(
                        children: [
                          PoshQuizProgressRow(
                            levelCount: levels.length,
                            passedLevels: _passedLevels,
                            activeLevelIndex: _activeLevelIndex,
                            onLevelTap: (index, available) {
                              if (available) {
                                setState(() => _activeLevelIndex = index);
                                unawaited(AppActivityLog.instance.record(
                                  'posh_folder',
                                  message:
                                      'POSH education — Level ${index + 1} opened',
                                ));
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
                          Row(
                            children: [
                              Expanded(
                                child: PoshInfoTile(
                                  title: l10n.t('studyFirst'),
                                  value: l10n.t('readAllSectionsBeforeQuiz1'),
                                  icon: Icons.auto_stories_rounded,
                                  color: const Color(0xFF2ED6C5),
                                  colors: colors,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: PoshInfoTile(
                                  title: l10n.t('threeLevels'),
                                  value: l10n.t('twentyMcqsEachQuiz'),
                                  icon: Icons.quiz_rounded,
                                  color: const Color(0xFFFF9A3D),
                                  colors: colors,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PoshStudySectionCard(
                    number: '1',
                    title: l10n.t('poshStudy1Title'),
                    onOpen: () => _logStudyFolder(l10n.t('poshStudy1Title')),
                    icon: Icons.balance_rounded,
                    bullets: [
                      l10n.t('poshStudy1Bullet1'),
                      l10n.t('poshStudy1Bullet2'),
                      l10n.t('poshStudy1Bullet3'),
                      l10n.t('poshStudy1Bullet4'),
                      l10n.t('poshStudy1Bullet5'),
                      l10n.t('poshStudy1Bullet6'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PoshStudySectionCard(
                    number: '2',
                    title: l10n.t('poshStudy2Title'),
                    onOpen: () => _logStudyFolder(l10n.t('poshStudy2Title')),
                    icon: Icons.rule_folder_rounded,
                    bullets: [
                      l10n.t('poshStudy2Bullet1'),
                      l10n.t('poshStudy2Bullet2'),
                      l10n.t('poshStudy2Bullet3'),
                      l10n.t('poshStudy2Bullet4'),
                      l10n.t('poshStudy2Bullet5'),
                      l10n.t('poshStudy2Bullet6'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PoshStudySectionCard(
                    number: '3',
                    title: l10n.t('poshStudy3Title'),
                    onOpen: () => _logStudyFolder(l10n.t('poshStudy3Title')),
                    icon: Icons.shield_rounded,
                    bullets: [
                      l10n.t('poshStudy3Bullet1'),
                      l10n.t('poshStudy3Bullet2'),
                      l10n.t('poshStudy3Bullet3'),
                      l10n.t('poshStudy3Bullet4'),
                      l10n.t('poshStudy3Bullet5'),
                      l10n.t('poshStudy3Bullet6'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PoshStudySectionCard(
                    number: '4',
                    title: l10n.t('poshStudy4Title'),
                    onOpen: () => _logStudyFolder(l10n.t('poshStudy4Title')),
                    icon: Icons.info_outline_rounded,
                    bullets: [
                      l10n.t('poshStudy4Bullet1'),
                      l10n.t('poshStudy4Bullet2'),
                      l10n.t('poshStudy4Bullet3'),
                      l10n.t('poshStudy4Bullet4'),
                      l10n.t('poshStudy4Bullet5'),
                      l10n.t('poshStudy4Bullet6'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'POSH Act guide'),
                          builder: (_) => const POSHActGuideScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.t('openDetailedPoshActGuide')),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
