import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/cybercrime_constants.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/models/cybercrime_models.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/services/cyber_protection_service.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/backend_connectivity.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cyber_evidence_validation.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cyber_vault_lock.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/utils/cybercrime_utils.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cyber_multi_select_dropdown.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/widgets/cybercrime_widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';

class CyberVaultTab extends StatefulWidget {
  const CyberVaultTab({
    super.key,
    required this.service,
    required this.onApiError,
  });

  final CyberProtectionService service;
  final Future<bool> Function(DioException error) onApiError;

  @override
  State<CyberVaultTab> createState() => _CyberVaultTabState();
}

class _CyberVaultTabState extends State<CyberVaultTab> {
  final _imagePicker = ImagePicker();
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
  final _searchController = TextEditingController();
  final _vaultLock = CyberVaultLock();

  List<EvidenceItem> _items = const [];
  String _category = CybercrimeConstants.evidenceUploadCategories.first;
  Set<String> _selectedCategoryFilters = {'All'};
  Set<String> _selectedLinkFilters = {'all'};
  bool _privateMode = false;
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isExporting = false;
  bool _lockEnabled = false;
  bool _biometricsAvailable = false;
  bool _viewUnlocked = true;
  double? _uploadProgress;
  CancelToken? _uploadCancelToken;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _uploadCancelToken?.cancel();
    _titleController.dispose();
    _tagController.dispose();
    _searchController.dispose();
    super.dispose();
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

  String? _resolveLinkedFilter() {
    if (_selectedLinkFilters.contains('all') || _selectedLinkFilters.isEmpty) {
      return null;
    }
    final linked = _selectedLinkFilters.contains('linked');
    final unlinked = _selectedLinkFilters.contains('unlinked');
    if (linked && unlinked) return null;
    if (linked) return 'true';
    if (unlinked) return 'false';
    return null;
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      await ensureBackendReachable();
      final categoryFilters = _selectedCategoryFilters
          .where((c) => c != 'All')
          .toSet();
      final showAll =
          _selectedCategoryFilters.contains('All') || categoryFilters.isEmpty;

      var items = await widget.service.listEvidence(
        category: (!showAll && categoryFilters.length == 1)
            ? categoryFilters.first
            : null,
        search: CyberEvidenceValidation.sanitizeSearch(_searchController.text),
        linked: _resolveLinkedFilter(),
      );

      if (!showAll && categoryFilters.isNotEmpty) {
        items = items
            .where((item) => categoryFilters.contains(item.category))
            .toList();
      }

      if (!mounted) return;
      setState(() => _items = items);
    } on DioException catch (error) {
      if (await showCyberAuthExpiredBanner(
        context,
        error,
        requestPath: '/cybercrime/evidence',
      )) {
        return;
      }
      if (mounted) showCyberSnack(context, friendlyCyberError(context, error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _setupOrClearLock() async {
    final l10n = AppLocalizations.of(context);
    if (_lockEnabled) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.t('cyberVaultDisableLock')),
              content: Text(l10n.t('cyberVaultLockSubtitle')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.t('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.t('cyberVaultDisableLock')),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;
      await _vaultLock.disable();
      if (!mounted) return;
      setState(() {
        _lockEnabled = false;
        _viewUnlocked = true;
      });
      showCyberSnack(context, l10n.t('cyberVaultLockDisabled'));
      return;
    }

    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('cyberVaultSetPinTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.t('cyberVaultLockSubtitle')),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(labelText: l10n.t('medicalPinLabel')),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                labelText: l10n.t('cyberVaultConfirmPinLabel'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('cyberVaultEnableLock')),
          ),
        ],
      ),
    );
    final pin = controller.text.trim();
    final confirm = confirmController.text.trim();
    controller.dispose();
    confirmController.dispose();
    if (saved != true || !mounted) return;
    if (pin.length < 4) {
      showCyberSnack(context, l10n.t('medicalPinLabel'));
      return;
    }
    if (pin != confirm) {
      showCyberSnack(context, l10n.t('cyberVaultPinMismatch'));
      return;
    }
    await _vaultLock.enablePin(pin);
    if (!mounted) return;
    setState(() {
      _lockEnabled = true;
      _viewUnlocked = false;
    });
    showCyberSnack(context, l10n.t('cyberVaultLockEnabled'));
  }

  Future<bool> _confirmUploadMetadata({
    required String fileName,
    required int sizeBytes,
    required String title,
  }) async {
    final l10n = AppLocalizations.of(context);
    final message = l10n
        .t('cyberEvidenceConfirmMessage')
        .replaceFirst('{name}', fileName)
        .replaceFirst('{size}', CyberEvidenceValidation.formatBytes(sizeBytes))
        .replaceFirst(
          '{category}',
          localizedEvidenceCategory(context, _category),
        )
        .replaceFirst(
          '{private}',
          _privateMode ? l10n.t('yes') : l10n.t('no'),
        );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('cyberEvidenceConfirmTitle')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              if (title.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${l10n.t('evidenceTitleLabel')}: $title',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.t('pickFile')),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _uploadFile(XFile file) async {
    final l10n = AppLocalizations.of(context);
    final invalidKey = await CyberEvidenceValidation.validateFile(
      path: file.path,
      fileName: file.name,
    );
    if (invalidKey != null) {
      if (mounted) showCyberSnack(context, l10n.t(invalidKey));
      return;
    }
    final size = await CyberEvidenceValidation.fileSizeBytes(file.path) ?? 0;
    final title = _titleController.text.trim().isEmpty
        ? file.name
        : _titleController.text.trim();
    final confirmed = await _confirmUploadMetadata(
      fileName: file.name,
      sizeBytes: size,
      title: title,
    );
    if (!confirmed || !mounted) return;

    final cancelToken = CancelToken();
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _uploadCancelToken = cancelToken;
    });
    try {
      await widget.service.uploadEvidence(
        file: file,
        title: title,
        category: _category,
        tags: _tagController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        privateMode: _privateMode,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = sent / total);
        },
      );
      _titleController.clear();
      _tagController.clear();
      await _load();
      if (mounted) showCyberSnack(context, l10n.t('evidenceEncryptedSaved'));
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        if (mounted) showCyberSnack(context, l10n.t('cyberUploadCancelled'));
        return;
      }
      if (await widget.onApiError(error)) return;
      if (mounted) {
        showCyberSnack(
          context,
          '${l10n.t('uploadFailed')} ${friendlyCyberError(context, error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = null;
          _uploadCancelToken = null;
        });
      }
    }
  }

  void _cancelUpload() {
    _uploadCancelToken?.cancel('user_cancelled');
  }

  Future<void> _pickFromGallery() async {
    final ok = await requestGalleryPermission();
    if (!ok || !mounted) return;
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _uploadFile(image);
  }

  Future<void> _pickFromFiles() async {
    final ok = await requestStoragePermission();
    if (!ok || !mounted) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:
          CyberEvidenceValidation.allowedExtensions.toList(growable: false),
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    await _uploadFile(XFile(file.path!, name: file.name));
  }

  Future<void> _previewEvidence(EvidenceItem item) async {
    final l10n = AppLocalizations.of(context);
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
      if (mounted) {
        showCyberSnack(
          context,
          '${l10n.t('previewFailed')} ${friendlyCyberError(context, error)}',
        );
      }
    }
  }

  Future<void> _downloadEvidence(EvidenceItem item) async {
    final l10n = AppLocalizations.of(context);
    if (!await _ensureViewUnlocked()) return;
    try {
      final downloaded = await widget.service.downloadEvidence(item.id);
      if (!mounted) return;
      await shareDownloadedEvidence(context, downloaded);
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) {
        showCyberSnack(
          context,
          '${l10n.t('downloadFailed')} ${friendlyCyberError(context, error)}',
        );
      }
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

  Future<void> _exportPackage() async {
    final l10n = AppLocalizations.of(context);
    if (!await _ensureViewUnlocked()) return;
    setState(() => _isExporting = true);
    try {
      final payload = await widget.service.exportVaultPackage();
      if (!mounted) return;
      await shareVaultExport(context, payload);
    } on DioException catch (error) {
      if (await widget.onApiError(error)) return;
      if (mounted) {
        showCyberSnack(
          context,
          '${l10n.t('exportFailed')} ${friendlyCyberError(context, error)}',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return CyberScroll(
      children: [
        CyberSectionHeader(
          title: l10n.t('secureEvidenceVault'),
          subtitle: l10n.t('uploadTagSearchPackageEvidence'),
          icon: Icons.lock_person_rounded,
          color: PremiumCyberTheme.accent,
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isLight
                ? const Color(0xFFEFF6FF)
                : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.privacy_tip_outlined, color: Color(0xFF3B82F6)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.t('cyberEvidencePrivacyNotice'),
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF1E3A5F)
                        : const Color(0xFFBFDBFE),
                    height: 1.35,
                    fontSize: 13,
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
              CyberCardTitle(l10n.t('addNewEvidence')),
              CyberTextInput(
                controller: _titleController,
                label: l10n.t('evidenceTitleLabel'),
                hint: l10n.t('evidenceTitleHint'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: cyberInputDecoration(context, l10n.t('category')),
                items: CybercrimeConstants.evidenceUploadCategories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(localizedEvidenceCategory(context, item)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              CyberTextInput(
                controller: _tagController,
                label: l10n.t('tags'),
                hint: l10n.t('tagsHint'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isLight
                      ? PremiumCyberTheme.background
                      : AppTheme.surfaceSoft.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLight
                        ? PremiumCyberTheme.cardBorder
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('private'),
                        style: TextStyle(
                          color: isLight
                              ? PremiumCyberTheme.bodyText
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _privateMode,
                      activeThumbColor: PremiumCyberTheme.accent,
                      onChanged: (value) =>
                          setState(() => _privateMode = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isUploading) ...[
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _cancelUpload,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(l10n.t('cyberEvidenceUploadCancel')),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (!FeatureFlags.cyberEvidenceUpload ||
                              _isUploading)
                          ? null
                          : _pickFromFiles,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: Text(l10n.t('pickFile')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: isLight
                            ? PremiumCyberTheme.bodyText
                            : Colors.white70,
                        side: BorderSide(
                          color: isLight
                              ? PremiumCyberTheme.cardBorder
                              : Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (!FeatureFlags.cyberEvidenceUpload ||
                              _isUploading)
                          ? null
                          : _pickFromGallery,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.t('pickFromGallery')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: PremiumCyberTheme.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CyberCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CyberCardTitle(l10n.t('manageVault')),
              Text(
                l10n.t('cyberVaultLockTitle'),
                style: TextStyle(
                  color: isLight
                      ? PremiumCyberTheme.titleText
                      : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.t('cyberVaultLockSubtitle'),
                style: TextStyle(
                  color: isLight
                      ? PremiumCyberTheme.bodyText
                      : Colors.white70,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _setupOrClearLock,
                  icon: Icon(
                    _lockEnabled
                        ? Icons.lock_open_rounded
                        : Icons.lock_rounded,
                  ),
                  label: Text(
                    _lockEnabled
                        ? l10n.t('cyberVaultDisableLock')
                        : l10n.t('cyberVaultEnableLock'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CyberTextInput(
                controller: _searchController,
                label: l10n.t('searchVault'),
                hint: l10n.t('searchByTitle'),
                maxLength: CyberEvidenceValidation.maxSearchLength,
                onSubmitted: (_) => _load(),
              ),
              const SizedBox(height: 10),
              CyberMultiSelectDropdown(
                label: l10n.t('filterCategories'),
                options: CybercrimeConstants.evidenceCategories,
                selected: _selectedCategoryFilters,
                allOptionValue: 'All',
                optionLabel: (value) =>
                    localizedEvidenceCategory(context, value),
                onChanged: (next) {
                  setState(() => _selectedCategoryFilters = next);
                  unawaited(_load());
                },
              ),
              const SizedBox(height: 10),
              CyberMultiSelectDropdown(
                label: l10n.t('filterLinkStatus'),
                options: const ['all', 'linked', 'unlinked'],
                selected: _selectedLinkFilters,
                allOptionValue: 'all',
                optionLabel: (value) {
                  switch (value) {
                    case 'linked':
                      return l10n.t('filterLinked');
                    case 'unlinked':
                      return l10n.t('filterUnlinked');
                    default:
                      return l10n.t('filterAll');
                  }
                },
                onChanged: (next) {
                  setState(() => _selectedLinkFilters = next);
                  unawaited(_load());
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isExporting ? null : _exportPackage,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.inventory_2_rounded),
                  label: Text(l10n.t('exportEvidencePackage')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: isLight
                        ? PremiumCyberTheme.bodyText
                        : Colors.white70,
                    side: BorderSide(
                      color: isLight
                          ? PremiumCyberTheme.cardBorder
                          : Colors.white24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_items.isEmpty)
          CyberEmptyState(text: l10n.t('noEvidenceFound'))
        else
          ..._items.map(
            (item) => CyberEvidenceCard(
              item: item,
              onPreview: () => _previewEvidence(item),
              onDownload: () => _downloadEvidence(item),
              onDelete: () => _deleteEvidence(item),
            ),
          ),
      ],
    );
  }
}
