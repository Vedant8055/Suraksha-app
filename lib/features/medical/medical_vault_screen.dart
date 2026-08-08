import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';
import 'package:suraksha_women_safety_app/core/storage/medical_vault_storage.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/medical/medical_vault_auth.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/widgets/save_feedback_dialog.dart';

class MedicalVaultScreen extends ConsumerStatefulWidget {
  const MedicalVaultScreen({super.key});

  @override
  ConsumerState<MedicalVaultScreen> createState() =>
      _MedicalVaultScreenState();
}

class _MedicalVaultScreenState extends ConsumerState<MedicalVaultScreen> {
  final Dio _dio = DioClient().dio;
  final MedicalVaultAuth _vaultAuth = MedicalVaultAuth();
  late final MedicalVaultStorage _storage;

  String _bloodGroup = '';
  String _allergies = '';
  String _medicalConditions = '';
  String _medications = '';
  String _emergencyNotes = '';
  DateTime? _lastUpdatedAt;

  bool _isSaving = false;
  bool _isLoading = true;
  bool _unlocked = false;
  bool _detailsRevealed = false;
  bool _emergencyMode = false;
  bool _lockEnabled = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Medical Vault requires an authenticated user.');
    }
    _storage = MedicalVaultStorage(userId);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final lockEnabled = await _storage.isLockEnabled();
    final biometrics = await _vaultAuth.canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _lockEnabled = lockEnabled;
      _biometricsAvailable = biometrics;
      _unlocked = !lockEnabled;
    });

    if (!lockEnabled) {
      await _initializeMedicalData();
      return;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _initializeMedicalData() async {
    setState(() => _isLoading = true);
    await _loadLocalMedicalData();
    await _loadMedicalDataFromServer();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadLocalMedicalData() async {
    final data = await _storage.read();
    if (!mounted) return;
    setState(() {
      _bloodGroup = data.bloodGroup;
      _allergies = data.allergies;
      _medicalConditions = data.conditions;
      _medications = data.medications;
      _emergencyNotes = data.emergencyNotes;
      _lastUpdatedAt = data.lastUpdatedAt;
    });
  }

  MedicalVaultData get _currentData => MedicalVaultData(
        bloodGroup: _bloodGroup,
        allergies: _allergies,
        conditions: _medicalConditions,
        medications: _medications,
        emergencyNotes: _emergencyNotes,
        lastUpdatedAt: _lastUpdatedAt,
      );

  Future<void> _saveLocalMedicalData(MedicalVaultData data) async {
    await _storage.write(data);
    if (!mounted) return;
    setState(() => _lastUpdatedAt = DateTime.now().toUtc());
  }

  List<String> _parseCsvList(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _toCsv(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(', ');
    }
    return '';
  }

  Future<void> _loadMedicalDataFromServer() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      final data = response.data as Map<String, dynamic>;
      final bloodGroup = (data['bloodGroup'] ?? '').toString().trim();
      final allergies = _toCsv(data['allergies']);
      final medicalConditions = _toCsv(data['medicalConditions']);
      final medications = _toCsv(data['currentMedications']);
      final emergencyNotes = (data['emergencyNotes'] ?? '').toString().trim();

      if (!mounted) return;
      setState(() {
        if (bloodGroup.isNotEmpty) _bloodGroup = bloodGroup;
        if (allergies.isNotEmpty) _allergies = allergies;
        if (medicalConditions.isNotEmpty) {
          _medicalConditions = medicalConditions;
        }
        if (medications.isNotEmpty) _medications = medications;
        if (emergencyNotes.isNotEmpty) _emergencyNotes = emergencyNotes;
      });

      await _saveLocalMedicalData(_currentData);
    } on DioException {
      // Keep local fallback.
    }
  }

  Future<bool> _confirmReveal() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.t('medicalRevealTitle')),
            content: Text(l10n.t('medicalRevealMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.t('medicalRevealConfirm')),
              ),
            ],
          ),
        ) ??
        false;
    return confirmed;
  }

  Future<void> _revealDetails() async {
    if (_detailsRevealed) return;
    final ok = await _confirmReveal();
    if (!ok || !mounted) return;
    setState(() => _detailsRevealed = true);
  }

  Future<void> _enterEmergencyMode() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.t('medicalEmergencyModeTitle')),
            content: Text(l10n.t('medicalEmergencyModeMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.t('medicalEmergencyModeConfirm')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    setState(() {
      _emergencyMode = true;
      _detailsRevealed = true;
    });
  }

  Future<void> _unlockWithPin() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('medicalUnlockTitle')),
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
            child: Text(l10n.t('medicalUnlockAction')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (pin == null || pin.isEmpty || !mounted) return;

    final ok = await _storage.verifyPin(pin);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('medicalPinIncorrect'))),
      );
      return;
    }
    setState(() => _unlocked = true);
    await _initializeMedicalData();
  }

  Future<void> _unlockWithBiometrics() async {
    final l10n = AppLocalizations.of(context);
    final ok = await _vaultAuth.authenticate(
      reason: l10n.t('medicalBiometricReason'),
    );
    if (!ok || !mounted) return;
    setState(() => _unlocked = true);
    await _initializeMedicalData();
  }

  Future<void> _setupOrClearLock() async {
    final l10n = AppLocalizations.of(context);
    if (_lockEnabled) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.t('medicalDisableLockTitle')),
              content: Text(l10n.t('medicalDisableLockMessage')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.t('cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.t('medicalDisableLockConfirm')),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;
      await _storage.clearPin();
      if (!mounted) return;
      setState(() => _lockEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('medicalLockDisabled'))),
      );
      return;
    }

    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('medicalEnableLockTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.t('medicalEnableLockMessage')),
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
                labelText: l10n.t('medicalPinConfirmLabel'),
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
            onPressed: () {
              if (controller.text.trim().length < 4 ||
                  controller.text.trim() != confirmController.text.trim()) {
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
    final pin = controller.text.trim();
    controller.dispose();
    confirmController.dispose();
    if (saved != true) return;

    try {
      await _storage.setPin(pin);
      if (!mounted) return;
      setState(() => _lockEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('medicalLockEnabled'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('medicalPinTooShort'))),
      );
    }
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context);
    if (!_detailsRevealed) {
      final revealed = await _confirmReveal();
      if (!revealed || !mounted) return;
      setState(() => _detailsRevealed = true);
    }
    final text = _currentData.toShareText();
    await Share.share(text, subject: l10n.t('medicalHealthVault'));
  }

  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.t('medicalDeleteTitle')),
            content: Text(l10n.t('medicalDeleteMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.t('medicalDeleteConfirm')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await _storage.clear();
      try {
        await _dio.patch(
          ApiConstants.profile,
          data: {
            'bloodGroup': '',
            'allergies': <String>[],
            'medicalConditions': <String>[],
            'currentMedications': <String>[],
            'emergencyNotes': '',
          },
        );
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _bloodGroup = '';
        _allergies = '';
        _medicalConditions = '';
        _medications = '';
        _emergencyNotes = '';
        _lastUpdatedAt = null;
        _detailsRevealed = false;
        _emergencyMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('medicalDeleteDone'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatUpdated(AppLocalizations l10n) {
    final at = _lastUpdatedAt;
    if (at == null) return l10n.t('medicalNeverUpdated');
    final local = at.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return l10n
        .t('medicalLastUpdatedAt')
        .replaceAll('{date}', '${local.day}/${local.month}/${local.year}')
        .replaceAll('{time}', '$hh:$mm');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.t('medicalHealthVault'))),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 56, color: Color(0xFFE53935)),
              const SizedBox(height: 16),
              Text(
                l10n.t('medicalLockedTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('medicalLockedSubtitle'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _unlockWithPin,
                  icon: const Icon(Icons.pin_rounded),
                  label: Text(l10n.t('medicalUnlockWithPin')),
                ),
              ),
              if (_biometricsAvailable) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _unlockWithBiometrics,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(l10n.t('medicalUnlockWithBiometric')),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('medicalHealthVault')),
        systemOverlayStyle: AppTheme.overlayStyleForBrightness(
          Theme.of(context).brightness,
        ),
        actions: [
          if (_emergencyMode)
            TextButton(
              onPressed: () => setState(() => _emergencyMode = false),
              child: Text(l10n.t('medicalExitEmergencyMode')),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? const [
                    Color(0xFFF8FBFF),
                    Color(0xFFF3F7FD),
                    Color(0xFFEFF4FA),
                  ]
                : const [
                    Color(0xFF07101F),
                    Color(0xFF0B1627),
                    Color(0xFF050A14),
                  ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  children: [
                    FadeInDown(child: _buildVaultHero(context)),
                    const SizedBox(height: 12),
                    _buildDisclaimer(isLight),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatUpdated(l10n),
                        style: TextStyle(
                          color: isLight
                              ? const Color(0xFF64748B)
                              : Colors.white60,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_emergencyMode) ...[
                      _buildEmergencyBanner(isLight),
                      const SizedBox(height: 14),
                    ] else ...[
                      FadeInDown(child: _buildEmergencyAccessCard(isLight)),
                      const SizedBox(height: 16),
                    ],
                    if (!_detailsRevealed && !_emergencyMode) ...[
                      _buildHiddenOverlay(isLight),
                      const SizedBox(height: 16),
                    ] else ...[
                      _buildMedicalSection(
                        l10n.t('bloodGroup'),
                        _bloodGroup,
                        Icons.bloodtype_rounded,
                        const Color(0xFFE53935),
                      ),
                      const SizedBox(height: 14),
                      _buildMedicalSection(
                        l10n.t('allergies'),
                        _allergies,
                        Icons.warning_amber_rounded,
                        const Color(0xFFF3B13E),
                      ),
                      const SizedBox(height: 14),
                      _buildMedicalSection(
                        l10n.t('medicalConditions'),
                        _medicalConditions,
                        Icons.medical_information_rounded,
                        const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 14),
                      _buildMedicalSection(
                        l10n.t('currentMedications'),
                        _medications,
                        Icons.medication_rounded,
                        const Color(0xFF2ED6C5),
                      ),
                      const SizedBox(height: 14),
                      _buildMedicalSection(
                        l10n.t('emergencyNotes'),
                        _emergencyNotes,
                        Icons.sticky_note_2_rounded,
                        const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (!_emergencyMode) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _showEditMedicalDialog,
                          icon: const Icon(Icons.edit_rounded),
                          label: Text(l10n.t('editMedicalProfile')),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _exportData,
                          icon: const Icon(Icons.ios_share_rounded),
                          label: Text(l10n.t('medicalExportAction')),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _setupOrClearLock,
                          icon: Icon(
                            _lockEnabled
                                ? Icons.lock_open_rounded
                                : Icons.lock_rounded,
                          ),
                          label: Text(
                            _lockEnabled
                                ? l10n.t('medicalDisableLockAction')
                                : l10n.t('medicalEnableLockAction'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _deleteAllData,
                          icon: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.redAccent,
                          ),
                          label: Text(
                            l10n.t('medicalDeleteConfirm'),
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDisclaimer(bool isLight) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFF7ED) : const Color(0xFF3F1D0D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        l10n.t('medicalDisclaimer'),
        style: TextStyle(
          color: isLight ? const Color(0xFF9A3412) : Colors.white70,
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHiddenOverlay(bool isLight) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isLight ? Colors.white : AppTheme.cardColor,
        border: Border.all(
          color: isLight ? const Color(0xFFDCE5F6) : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.visibility_off_rounded, size: 36),
          const SizedBox(height: 10),
          Text(
            l10n.t('medicalDetailsHidden'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('medicalDetailsHiddenSubtitle'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _revealDetails,
            icon: const Icon(Icons.visibility_rounded),
            label: Text(l10n.t('medicalRevealConfirm')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyAccessCard(bool isLight) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isLight
              ? const [Color(0xFFFFF1F2), Color(0xFFFFE4E6)]
              : const [Color(0xFF3F1216), Color(0xFF1F0A0C)],
        ),
        border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('medicalEmergencyAccessTitle'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(l10n.t('medicalEmergencyAccessSubtitle')),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enterEmergencyMode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.emergency_rounded),
              label: Text(l10n.t('medicalEmergencyModeConfirm')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(bool isLight) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: isLight ? 0.12 : 0.28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        l10n.t('medicalEmergencyModeActive'),
        style: const TextStyle(
          color: Color(0xFFE53935),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildVaultHero(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF172235) : Colors.white;
    final mutedColor = isLight ? const Color(0xFF5F6F8A) : Colors.white70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isLight
              ? const [Colors.white, Color(0xFFF5F9FF), Color(0xFFEAF3FF)]
              : const [Color(0xFF111B2E), Color(0xFF0E1727), Color(0xFF08111D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isLight
              ? const Color(0xFFDCE5F6)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFF3B13E)],
              ),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).t('medicalHealthVault'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)
                      .t('keepEmergencyMedicalInformationOrganized'),
                  style: TextStyle(color: mutedColor, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isLight
              ? const [Colors.white, Color(0xFFF7FAFF)]
              : const [AppTheme.cardColor, Color(0xFF0F1A2B)],
        ),
        border: Border.all(
          color: isLight
              ? const Color(0xFFDCE5F6)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isLight ? 0.12 : 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF5F6F8A) : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value.trim().isEmpty
                      ? AppLocalizations.of(context).t('notProvided')
                      : value,
                  style: TextStyle(
                    color: isLight ? const Color(0xFF172235) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMedicalDialog() async {
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final bloodController = TextEditingController(text: _bloodGroup);
    final allergiesController = TextEditingController(text: _allergies);
    final conditionsController = TextEditingController(text: _medicalConditions);
    final medsController = TextEditingController(text: _medications);
    final notesController = TextEditingController(text: _emergencyNotes);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('editMedicalProfile')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodController,
                decoration: InputDecoration(labelText: l10n.t('bloodGroup')),
              ),
              TextField(
                controller: allergiesController,
                decoration: InputDecoration(labelText: l10n.t('allergies')),
              ),
              TextField(
                controller: conditionsController,
                decoration:
                    InputDecoration(labelText: l10n.t('medicalConditions')),
              ),
              TextField(
                controller: medsController,
                decoration:
                    InputDecoration(labelText: l10n.t('currentMedications')),
              ),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration:
                    InputDecoration(labelText: l10n.t('emergencyNotes')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text(l10n.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveMedicalProfile(
                bloodGroup: bloodController.text.trim(),
                allergies: allergiesController.text.trim(),
                medicalConditions: conditionsController.text.trim(),
                medications: medsController.text.trim(),
                emergencyNotes: notesController.text.trim(),
              );
              if (mounted) navigator.pop();
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMedicalProfile({
    required String bloodGroup,
    required String allergies,
    required String medicalConditions,
    required String medications,
    required String emergencyNotes,
  }) async {
    setState(() => _isSaving = true);
    try {
      final data = MedicalVaultData(
        bloodGroup: bloodGroup,
        allergies: allergies,
        conditions: medicalConditions,
        medications: medications,
        emergencyNotes: emergencyNotes,
      );
      await _saveLocalMedicalData(data);

      if (!mounted) return;
      setState(() {
        _bloodGroup = bloodGroup;
        _allergies = allergies;
        _medicalConditions = medicalConditions;
        _medications = medications;
        _emergencyNotes = emergencyNotes;
        _detailsRevealed = true;
      });
      await showSaveSuccessDialog(
        context,
        title: AppLocalizations.of(context).t('medicalProfileSaved'),
        message: AppLocalizations.of(context).t('medicalDetailsReady'),
      );
      unawaited(
        _syncMedicalProfileToServer(
          bloodGroup: bloodGroup,
          allergies: allergies,
          medicalConditions: medicalConditions,
          medications: medications,
          emergencyNotes: emergencyNotes,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncMedicalProfileToServer({
    required String bloodGroup,
    required String allergies,
    required String medicalConditions,
    required String medications,
    required String emergencyNotes,
  }) async {
    try {
      await _dio.patch(
        ApiConstants.profile,
        data: {
          'bloodGroup': bloodGroup,
          'allergies': _parseCsvList(allergies),
          'medicalConditions': _parseCsvList(medicalConditions),
          'currentMedications': _parseCsvList(medications),
          'emergencyNotes': emergencyNotes,
        },
      );
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .t('medicalProfileSavedLocallySyncRetryLater'),
            ),
          ),
        );
      }
    } catch (_) {}
  }
}
