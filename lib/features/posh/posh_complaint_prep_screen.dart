import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_common_widgets.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_complaint_draft_storage.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_danger_detector.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_ui.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class POSHComplaintPrepScreen extends StatefulWidget {
  const POSHComplaintPrepScreen({super.key});

  @override
  State<POSHComplaintPrepScreen> createState() =>
      _POSHComplaintPrepScreenState();
}

class _POSHComplaintPrepScreenState extends State<POSHComplaintPrepScreen> {
  final _draftStorage = PoshComplaintDraftStorage();
  final Dio _dio = DioClient().dio;

  final _complainantNameController = TextEditingController();
  final _complainantPhoneController = TextEditingController();
  final _complainantEmailController = TextEditingController();
  final _accusedNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _incidentDateController = TextEditingController();
  final _incidentLocationController = TextEditingController();
  final _witnessesController = TextEditingController();
  final _detailsController = TextEditingController();

  bool _submitting = false;
  bool _loadingDraft = true;
  bool _showDangerBanner = false;
  Timer? _autosaveTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDraft());
    for (final controller in _allControllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _allControllers => [
    _complainantNameController,
    _complainantPhoneController,
    _complainantEmailController,
    _accusedNameController,
    _companyController,
    _incidentDateController,
    _incidentLocationController,
    _witnessesController,
    _detailsController,
  ];

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    for (final controller in _allControllers) {
      controller.removeListener(_onFieldChanged);
      controller.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged() {
    _updateDangerBanner();
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), _saveDraftSilently);
  }

  void _updateDangerBanner() {
    final combined = [
      _detailsController.text,
      _incidentLocationController.text,
      _witnessesController.text,
    ].join('\n');
    final show = PoshDangerDetector.mentionsImmediateDanger(combined);
    if (show != _showDangerBanner && mounted) {
      setState(() => _showDangerBanner = show);
    }
  }

  Map<String, String> _currentDraftFields() {
    return {
      'complainantName': _complainantNameController.text,
      'complainantPhone': _complainantPhoneController.text,
      'complainantEmail': _complainantEmailController.text,
      'accusedName': _accusedNameController.text,
      'company': _companyController.text,
      'incidentDate': _incidentDateController.text,
      'incidentLocation': _incidentLocationController.text,
      'witnesses': _witnessesController.text,
      'details': _detailsController.text,
    };
  }

  Future<void> _loadDraft() async {
    final draft = await _draftStorage.load();
    if (!mounted) return;

    void apply(String key, TextEditingController controller) {
      final value = draft[key];
      if (value != null && value.isNotEmpty) {
        controller.text = value;
      }
    }

    apply('complainantName', _complainantNameController);
    apply('complainantPhone', _complainantPhoneController);
    apply('complainantEmail', _complainantEmailController);
    apply('accusedName', _accusedNameController);
    apply('company', _companyController);
    apply('incidentDate', _incidentDateController);
    apply('incidentLocation', _incidentLocationController);
    apply('witnesses', _witnessesController);
    apply('details', _detailsController);

    final hasDraft = draft.values.any((value) => value.trim().isNotEmpty);
    setState(() {
      _loadingDraft = false;
      _updateDangerBanner();
    });

    if (hasDraft && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('poshComplaintDraftRestored'))),
      );
    }
  }

  Future<void> _saveDraftSilently() async {
    await _draftStorage.save(_currentDraftFields());
  }

  Future<void> _saveDraft() async {
    await _draftStorage.save(_currentDraftFields());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).t('poshDraftSaved'))),
    );
  }

  String _extractComplaintErrorMessage(
    DioException error,
    AppLocalizations l10n,
  ) {
    final response = error.response;
    final data = response?.data;
    final statusCode = response?.statusCode;

    String? message;
    if (data is Map) {
      final rawMessage = data['message']?.toString();
      if (rawMessage != null && rawMessage.trim().isNotEmpty) {
        message = rawMessage.trim();
      }

      if (message == 'Validation failed') {
        final details = data['details'];
        if (details is Map) {
          final fieldErrors = details['fieldErrors'];
          if (fieldErrors is Map && fieldErrors.isNotEmpty) {
            final firstEntry = fieldErrors.entries.first;
            final firstError = firstEntry.value;
            if (firstError is List && firstError.isNotEmpty) {
              final firstMessage = firstError.first?.toString().trim();
              if (firstMessage != null && firstMessage.isNotEmpty) {
                return firstMessage;
              }
            }
            final firstMessage = firstError?.toString().trim();
            if (firstMessage != null && firstMessage.isNotEmpty) {
              return firstMessage;
            }
          }

          final formErrors = details['formErrors'];
          if (formErrors is List && formErrors.isNotEmpty) {
            final firstMessage = formErrors.first?.toString().trim();
            if (firstMessage != null && firstMessage.isNotEmpty) {
              return firstMessage;
            }
          }
        }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return l10n.t('poshComplaintTimedOut');
    }

    if (error.type == DioExceptionType.connectionError) {
      return l10n.t('poshComplaintNetworkUnavailable');
    }

    if (statusCode == 401 || statusCode == 403) {
      return l10n.t('poshComplaintSessionExpired');
    }

    if (message != null && message.isNotEmpty) {
      return message;
    }

    final errorText = error.error?.toString().trim();
    if (errorText != null && errorText.isNotEmpty) {
      return errorText;
    }

    return l10n.t('submissionFailedTryAgain');
  }

  Future<void> _submitToSuraksha() async {
    final l10n = AppLocalizations.of(context);
    final complainantName = _complainantNameController.text.trim();
    final complainantPhone = _complainantPhoneController.text.trim();
    final complainantEmail = _complainantEmailController.text.trim();
    final accusedName = _accusedNameController.text.trim();
    final workplace = _companyController.text.trim();
    final incidentDate = _incidentDateController.text.trim();
    final incidentLocation = _incidentLocationController.text.trim();
    final witnesses = _witnessesController.text.trim();
    final details = _detailsController.text.trim();

    if (complainantName.isEmpty ||
        complainantPhone.isEmpty ||
        accusedName.isEmpty ||
        details.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('pleaseFillAllRequiredDetails'))),
      );
      return;
    }

    final complaintLines = <String>[
      l10n.t('poshComplaintTitle'),
      l10n.t('poshComplaintComplainant').replaceAll('{name}', complainantName),
      l10n.t('poshComplaintPhone').replaceAll('{phone}', complainantPhone),
      l10n
          .t('poshComplaintEmail')
          .replaceAll(
            '{email}',
            complainantEmail.isEmpty ? l10n.t('notProvided') : complainantEmail,
          ),
      l10n.t('poshComplaintAccused').replaceAll('{name}', accusedName),
      l10n
          .t('poshComplaintWorkplace')
          .replaceAll(
            '{name}',
            workplace.isEmpty ? l10n.t('notProvided') : workplace,
          ),
      l10n
          .t('poshComplaintIncidentDate')
          .replaceAll(
            '{date}',
            incidentDate.isEmpty ? l10n.t('notProvided') : incidentDate,
          ),
      l10n
          .t('poshComplaintIncidentLocation')
          .replaceAll(
            '{location}',
            incidentLocation.isEmpty ? l10n.t('notProvided') : incidentLocation,
          ),
      l10n
          .t('poshComplaintWitnesses')
          .replaceAll(
            '{witnesses}',
            witnesses.isEmpty ? l10n.t('noneProvided') : witnesses,
          ),
      l10n.t('poshComplaintDetails').replaceAll('{details}', details),
    ];
    final compiledDescription = complaintLines.join('\n');

    setState(() => _submitting = true);
    try {
      final response = await _dio.post(
        ApiConstants.incidentReport,
        data: {
          'category': 'POSH Workplace Complaint',
          'description': compiledDescription,
        },
      );
      if (mounted &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        await _saveDraftSilently();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('poshSavedToSurakshaNotice'))),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('submissionFailedTryAgain'))),
        );
      }
    } on DioException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_extractComplaintErrorMessage(error, l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openSosFromComplaint() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);

    InputDecoration fieldDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.mutedText),
      floatingLabelStyle: const TextStyle(color: AppTheme.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.4),
      ),
      filled: true,
      fillColor: colors.fieldFill,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('poshHubComplaintTitle')),
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
        child: _loadingDraft
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const PoshLegalDisclaimerBanner(compact: true),
                  const SizedBox(height: 12),
                  _buildFilingBoundaryNotice(context),
                  if (_showDangerBanner) ...[
                    const SizedBox(height: 12),
                    PoshEmergencyEscalationBanner(onOpenSos: _openSosFromComplaint),
                  ],
                  const SizedBox(height: 14),
                  PoshHeroCard(
                    title: l10n.t('fileWorkplaceComplaint'),
                    subtitle: l10n.t('fileWorkplaceComplaintSubtitle'),
                    icon: Icons.report_gmailerrorred_rounded,
                    accentColor: const Color(0xFFE53935),
                    child: Text(
                      l10n.t('keepRecordsFactual'),
                      style: TextStyle(color: colors.mutedText),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildComplaintForm(context, fieldDecoration),
                ],
              ),
      ),
    );
  }

  Widget _buildFilingBoundaryNotice(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFEFF6FF) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('poshFilingBoundaryTitle'),
            style: TextStyle(
              color: isLight ? const Color(0xFF1E3A8A) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.t('poshFilingBoundaryMessage'),
            style: TextStyle(
              color: isLight ? const Color(0xFF334155) : Colors.white70,
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm(
    BuildContext context,
    InputDecoration Function(String label) fieldDecoration,
  ) {
    final colors = PoshColors(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _complainantNameController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('yourFullName')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _complainantPhoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('yourPhoneNumber')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _complainantEmailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('yourEmailAddress')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _accusedNameController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('accusedPersonName')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _companyController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('companyWorkplaceName')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _incidentDateController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('incidentDateDdMmYyyy')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _incidentLocationController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('incidentLocation')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _witnessesController,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('witnessesIfAny')),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailsController,
            maxLines: 5,
            style: TextStyle(color: colors.text),
            decoration: fieldDecoration(l10n.t('detailedIncidentDescription')),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.t('poshSaveDraft')),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submitToSuraksha,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _submitting ? l10n.t('submitting') : l10n.t('poshSaveToSuraksha'),
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 54)),
            ),
          ),
        ],
      ),
    );
  }
}
