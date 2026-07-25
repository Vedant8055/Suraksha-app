import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/models/cybercrime_models.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/services/cyber_protection_service.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cyber_vault_lock.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cybercrime_utils.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cyber_portal_filing_card.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cybercrime_widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

class CyberReportDetailScreen extends StatefulWidget {
  const CyberReportDetailScreen({
    super.key,
    required this.reportId,
    required this.service,
    required this.onApiError,
  });

  final String reportId;
  final CyberProtectionService service;
  final Future<bool> Function(DioException error) onApiError;

  @override
  State<CyberReportDetailScreen> createState() => _CyberReportDetailScreenState();
}

class _CyberReportDetailScreenState extends State<CyberReportDetailScreen> {
  final _vaultLock = CyberVaultLock();
  CyberReportDetail? _detail;
  bool _loading = true;
  bool _lockEnabled = false;
  bool _biometricsAvailable = false;
  bool _viewUnlocked = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final enabled = await _vaultLock.isEnabled();
    final biometrics = await _vaultLock.canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _lockEnabled = enabled;
      _biometricsAvailable = biometrics;
      _viewUnlocked = !enabled;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detail = await widget.service.getReportDetail(widget.reportId);
      if (!mounted) return;
      setState(() => _detail = detail);
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) {
        showCyberSnack(context, friendlyCyberError(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _ensureViewUnlocked() async {
    if (!_lockEnabled || _viewUnlocked) return true;
    final l10n = AppLocalizations.of(context);

    if (_biometricsAvailable) {
      final bioOk = await _vaultLock.authenticateBiometric(
        reason: l10n.t('cyberVaultBiometricReason'),
      );
      if (!mounted) return false;
      if (bioOk) {
        setState(() => _viewUnlocked = true);
        return true;
      }
    }

    if (!mounted) return false;
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('cyberVaultUnlockTitle')),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: InputDecoration(labelText: l10n.t('medicalPinLabel')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.t('cyberVaultUnlockAction')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (pin == null || pin.isEmpty || !mounted) return false;

    final ok = await _vaultLock.verifyPin(pin);
    if (!ok) {
      if (!mounted) return false;
      showCyberSnack(context, l10n.t('cyberVaultPinIncorrect'));
      return false;
    }
    setState(() => _viewUnlocked = true);
    return true;
  }

  Future<void> _previewEvidence(EvidenceItem item) async {
    if (!await _ensureViewUnlocked()) return;
    try {
      final downloaded = await widget.service.downloadEvidence(item.id);
      if (!mounted) return;
      if (downloaded.mimeType.startsWith('image/')) {
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            child: InteractiveViewer(
              child: Image.memory(
                Uint8List.fromList(downloaded.bytes),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
        return;
      }
      await shareDownloadedEvidence(context, downloaded);
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) showCyberSnack(context, friendlyCyberError(context, error));
    }
  }

  Future<void> _deleteEvidence(EvidenceItem item) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteEvidenceTitle')),
        content: Text(
          l10n.t('deleteEvidenceConfirm').replaceFirst('{title}', item.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('no')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('yes')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.service.deleteEvidence(item.id);
      await _load();
      if (mounted) showCyberSnack(context, l10n.t('evidenceDeleted'));
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) {
        showCyberSnack(
          context,
          '${l10n.t('deleteFailed')} ${friendlyCyberError(context, error)}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('reportDetails')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
          ? Center(child: Text(l10n.t('reportSummaryUnavailable')))
          : CyberScroll(
              children: [
                CyberSectionHeader(
                  title: formatReportCategories(context, detail.report),
                  subtitle:
                      detail.report.createdAt.toLocal().toString().split('.').first,
                  icon: Icons.assignment_turned_in_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                CyberCard(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${l10n.t('reportStatusLabel')}:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF334155)
                              : Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      CyberReportStatusChip(report: detail.report),
                      if (reportFiledOnPortal(detail.report))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15803D).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.t('cyberPortalFiledBadge'),
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                CyberCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CyberCardTitle(l10n.t('generatedComplaint')),
                      Text(
                        detail.report.firStyleReport ?? detail.report.description,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF516078)
                              : Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (detail.report.pdfBase64 != null &&
                          detail.report.pdfBase64!.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => shareReportPdf(
                              context,
                              CyberReportResult(
                                id: detail.report.id,
                                firStyleReport: detail.report.firStyleReport ?? detail.report.description,
                                pdfBase64: detail.report.pdfBase64,
                              ),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_rounded),
                            label: Text(l10n.t('pdfReady')),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!detail.report.isDraft) ...[
                  const SizedBox(height: 12),
                  CyberPortalFilingCard(
                    reportId: detail.report.id,
                    service: widget.service,
                    onApiError: widget.onApiError,
                    complaintText:
                        detail.report.firStyleReport ?? detail.report.description,
                    pdfReport: detail.report.pdfBase64 != null &&
                            detail.report.pdfBase64!.isNotEmpty
                        ? CyberReportResult(
                            id: detail.report.id,
                            firStyleReport:
                                detail.report.firStyleReport ??
                                detail.report.description,
                            pdfBase64: detail.report.pdfBase64,
                          )
                        : null,
                    initialAcknowledgement:
                        detail.report.portalAcknowledgementNumber,
                    filedOnPortalAt: detail.report.filedOnPortalAt,
                    onAcknowledgementSaved: _load,
                  ),
                  const SizedBox(height: 12),
                  CyberCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CyberCardTitle(l10n.t('cyberAcknowledgementHistory')),
                        if (detail.report.acknowledgementHistory.isEmpty)
                          Text(
                            l10n.t('cyberAcknowledgementHistoryEmpty'),
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0xFF6B7C95)
                                  : Colors.white60,
                            ),
                          )
                        else
                          ...detail.report.acknowledgementHistory.reversed.map(
                            (entry) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: const Icon(Icons.receipt_long_rounded),
                              title: Text(entry.number),
                              subtitle: Text(
                                l10n.t('cyberAckSavedAt').replaceFirst(
                                      '{when}',
                                      entry.savedAt
                                          .toLocal()
                                          .toString()
                                          .split('.')
                                          .first,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                CyberCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: CyberCardTitle(l10n.t('linkedEvidence'))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2FB79E).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${detail.evidence.length}',
                              style: const TextStyle(
                                color: Color(0xFF2FB79E),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (detail.evidence.isEmpty)
                        CyberEmptyState(text: l10n.t('noLinkedEvidence'))
                      else
                        ...detail.evidence.map(
                          (item) => CyberEvidenceCard(
                            item: item,
                            onPreview: () => _previewEvidence(item),
                            onDownload: () => _previewEvidence(item),
                            onDelete: () => _deleteEvidence(item),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
