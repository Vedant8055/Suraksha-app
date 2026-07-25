export 'posh_act_guide_screen.dart' show POSHActGuideScreen;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/navigation/app_navigator.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_certificate_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_common_widgets.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_complaint_prep_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_education_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_progress.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/widgets/app_async_states.dart';

/// POSH legal learning hub — entry point from the dashboard.
class POSHLegalPortalScreen extends StatefulWidget {
  const POSHLegalPortalScreen({super.key});

  @override
  State<POSHLegalPortalScreen> createState() => _POSHLegalPortalScreenState();
}

class _POSHLegalPortalScreenState extends State<POSHLegalPortalScreen> {
  bool _loading = true;
  bool _certificateReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCertificateStatus());
  }

  Future<void> _loadCertificateStatus() async {
    final state = await PoshQuizProgress.load();
    if (!mounted) return;
    setState(() {
      _certificateReady = state.certificateReady;
      _loading = false;
    });
  }

  void _open(Widget screen) {
    AppNavigator.pushPremium(context, screen).then(
      (_) => unawaited(_loadCertificateStatus()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = PoshColors(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('poshPortal')),
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
        child: _loading
            ? AppAsyncStates.loading()
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const PoshLegalDisclaimerBanner(),
                  const SizedBox(height: 14),
                  const PoshLegalSourceCard(),
                  const SizedBox(height: 18),
                  PoshHubDestinationCard(
                    title: l10n.t('poshHubEducationTitle'),
                    subtitle: l10n.t('poshHubEducationSubtitle'),
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () => _open(const POSHEducationScreen()),
                  ),
                  const SizedBox(height: 12),
                  PoshHubDestinationCard(
                    title: l10n.t('poshHubQuizTitle'),
                    subtitle: l10n.t('poshHubQuizSubtitle'),
                    icon: Icons.school_rounded,
                    color: const Color(0xFF8E7CF4),
                    onTap: () => _open(const POSHQuizScreen()),
                  ),
                  const SizedBox(height: 12),
                  PoshHubDestinationCard(
                    title: l10n.t('poshHubComplaintTitle'),
                    subtitle: l10n.t('poshHubComplaintSubtitle'),
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFFE53935),
                    onTap: () => _open(const POSHComplaintPrepScreen()),
                  ),
                  const SizedBox(height: 12),
                  PoshHubDestinationCard(
                    title: l10n.t('poshHubCertificateTitle'),
                    subtitle: _certificateReady
                        ? l10n.t('poshHubCertificateSubtitle')
                        : l10n.t('poshCertificateNotReady'),
                    icon: _certificateReady
                        ? Icons.workspace_premium_rounded
                        : Icons.lock_rounded,
                    color: const Color(0xFF2ED6C5),
                    onTap: () => _open(const POSHCertificateScreen()),
                  ),
                ],
              ),
      ),
    );
  }
}
