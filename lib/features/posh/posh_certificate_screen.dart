import 'dart:async';

import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_progress.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class POSHCertificateScreen extends StatefulWidget {
  const POSHCertificateScreen({super.key});

  @override
  State<POSHCertificateScreen> createState() => _POSHCertificateScreenState();
}

class _POSHCertificateScreenState extends State<POSHCertificateScreen> {
  bool _loading = true;
  bool _certificateReady = false;
  DateTime? _certificateIssuedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgress());
  }

  Future<void> _loadProgress() async {
    final state = await PoshQuizProgress.load();
    if (!mounted) return;
    setState(() {
      _certificateReady = state.certificateReady;
      _certificateIssuedAt = state.certificateIssuedAt;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('poshHubCertificateTitle')),
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
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  if (_certificateReady)
                    _buildCertificateCard(context)
                  else
                    _buildLockedState(context),
                ],
              ),
      ),
    );
  }

  Widget _buildLockedState(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_rounded, size: 48, color: colors.mutedText),
          const SizedBox(height: 12),
          Text(
            l10n.t('poshCertificateNotReady'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);
    final issuedAt = _certificateIssuedAt ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D8CF8), Color(0xFF2ED6C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D8CF8).withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.t('poshCertified'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('poshCertifiedMessage'),
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('certificateDetails'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n
                      .t('issuedOn')
                      .replaceFirst(
                        '{date}',
                        issuedAt.toLocal().toString().split('.').first,
                      ),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('validForPoshCertificate'),
                  style: TextStyle(color: colors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
