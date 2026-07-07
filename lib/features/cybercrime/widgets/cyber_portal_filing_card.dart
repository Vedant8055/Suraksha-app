import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/models/cybercrime_models.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/services/cyber_protection_service.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cybercrime_utils.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cybercrime_widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

class CyberPortalFilingCard extends StatefulWidget {
  const CyberPortalFilingCard({
    super.key,
    required this.reportId,
    required this.service,
    required this.onApiError,
    required this.complaintText,
    this.pdfReport,
    this.initialAcknowledgement,
    this.filedOnPortalAt,
    this.onAcknowledgementSaved,
  });

  final String reportId;
  final CyberProtectionService service;
  final Future<bool> Function(DioException error) onApiError;
  final String complaintText;
  final CyberReportResult? pdfReport;
  final String? initialAcknowledgement;
  final DateTime? filedOnPortalAt;
  final VoidCallback? onAcknowledgementSaved;

  @override
  State<CyberPortalFilingCard> createState() => _CyberPortalFilingCardState();
}

class _CyberPortalFilingCardState extends State<CyberPortalFilingCard> {
  late final TextEditingController _ackController;
  bool _saving = false;
  String? _savedAcknowledgement;
  DateTime? _savedFiledAt;

  @override
  void initState() {
    super.initState();
    _savedAcknowledgement = widget.initialAcknowledgement?.trim();
    _savedFiledAt = widget.filedOnPortalAt;
    _ackController = TextEditingController(text: _savedAcknowledgement ?? '');
  }

  @override
  void dispose() {
    _ackController.dispose();
    super.dispose();
  }

  Future<void> _copyComplaint() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: widget.complaintText));
    if (!mounted) return;
    showCyberSnack(context, l10n.t('cyberPortalComplaintCopied'));
  }

  Future<void> _saveAcknowledgement() async {
    final l10n = AppLocalizations.of(context);
    final value = _ackController.text.trim();
    if (value.length < 3) {
      showCyberSnack(context, l10n.t('cyberPortalAckTooShort'));
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await widget.service.savePortalAcknowledgement(
        reportId: widget.reportId,
        acknowledgementNumber: value,
      );
      if (!mounted) return;
      setState(() {
        _savedAcknowledgement = updated.portalAcknowledgementNumber;
        _savedFiledAt = updated.filedOnPortalAt;
      });
      widget.onAcknowledgementSaved?.call();
      showCyberSnack(context, l10n.t('cyberPortalAckSaved'));
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) showCyberSnack(context, friendlyCyberError(context, error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final steps = [
      l10n.t('cyberPortalGuideStep1'),
      l10n.t('cyberPortalGuideStep2'),
      l10n.t('cyberPortalGuideStep3'),
      l10n.t('cyberPortalGuideStep4'),
    ];

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CyberCardTitle(l10n.t('cyberPortalGuideTitle')),
          const SizedBox(height: 6),
          Text(
            l10n.t('cyberPortalGuideSubtitle'),
            style: TextStyle(
              color: isLight ? const Color(0xFF516078) : Colors.white70,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isLight
                            ? const Color(0xFF475569)
                            : Colors.white.withValues(alpha: 0.88),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (widget.pdfReport != null)
                CyberActionButton(
                  label: l10n.t('pdfReady'),
                  icon: Icons.picture_as_pdf_rounded,
                  onTap: () => shareReportPdf(context, widget.pdfReport!),
                ),
              CyberActionButton(
                label: l10n.t('cyberPortalCopyComplaint'),
                icon: Icons.copy_rounded,
                onTap: _copyComplaint,
              ),
              CyberActionButton(
                label: l10n.t('cyberPortal'),
                icon: Icons.open_in_new_rounded,
                onTap: () => openExternalLink('https://cybercrime.gov.in'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CyberTextInput(
            controller: _ackController,
            label: l10n.t('cyberPortalAckLabel'),
            hint: l10n.t('cyberPortalAckHint'),
          ),
          if (_savedAcknowledgement != null &&
              _savedAcknowledgement!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n
                  .t('cyberPortalAckSavedOn')
                  .replaceAll('{number}', _savedAcknowledgement!)
                  .replaceAll(
                    '{date}',
                    (_savedFiledAt ?? DateTime.now()).toLocal().toString().split('.').first,
                  ),
              style: const TextStyle(
                color: Color(0xFF15803D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveAcknowledgement,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(l10n.t('cyberPortalSaveAck')),
            ),
          ),
        ],
      ),
    );
  }
}

class CyberReportStatusChip extends StatelessWidget {
  const CyberReportStatusChip({
    super.key,
    required this.report,
    this.compact = false,
  });

  final CyberReportListItem report;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = reportStatusColor(report);
    final label = localizedReportStatus(context, report);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10.5 : 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
