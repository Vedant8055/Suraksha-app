import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/core/media/profile_photo_provider.dart';
import 'package:suraksha_women_safety_app/core/navigation/app_navigator.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_preferences_provider.dart';
import 'package:suraksha_women_safety_app/features/notifications/notifications_inbox_screen.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_repository.dart';
import 'package:suraksha_women_safety_app/features/profile/daily_route_guard_card.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contact_item.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contact_guard.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_display_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_hero.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_session_cache.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_format_helpers.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_settings_widgets.dart';
import 'package:suraksha_women_safety_app/features/profile/account_privacy_screen.dart';
import 'package:suraksha_women_safety_app/features/profile/signed_in_devices_screen.dart';
import 'package:suraksha_women_safety_app/features/sentinel_evidence/widgets/sentinel_profile_card.dart';
import 'package:suraksha_women_safety_app/features/maps/safety_map_screen.dart';
import 'package:suraksha_women_safety_app/features/medical/medical_vault_screen.dart';
import 'package:suraksha_women_safety_app/features/sos/sensor_service.dart';
import 'package:suraksha_women_safety_app/features/sos/scream_detection_service.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_sms_service.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/distress_foreground_controller.dart';
import 'package:suraksha_women_safety_app/features/sos/distress/scream_audio_classifier.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';
import 'package:suraksha_women_safety_app/localization/localized_display_name.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/theme/theme_mode_provider.dart';
import 'package:suraksha_women_safety_app/widgets/save_feedback_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _profileRepo = ProfileRepository();
  bool _isSaving = false;
  String? _localName;
  String? _localEmail;
  String? _localPhone;
  String? _localBloodGroup;
  String? _localPhotoPath;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _showSaveSuccess(String title, String message) async {
    if (!mounted) return;
    await showSaveSuccessDialog(context, title: title, message: message);
  }

  Future<void> _showProfilePhotoPreview(
    ImageProvider<Object> profileImage,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isLight = Theme.of(dialogContext).brightness == Brightness.light;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: isLight
                    ? const [Colors.white, Color(0xFFF5F9FF)]
                    : const [Color(0xFF111B2E), Color(0xFF0A1321)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isLight
                    ? const Color(0xFFDCE5F6)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isLight ? 0.12 : 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(image: profileImage, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final user = ref.read(authProvider).user;
      if (user != null && user.id.isNotEmpty) {
        await ref.read(emergencyContactsProvider.notifier).bindUser(user.id);
      }
      await _loadLocalProfile();
      await ref.read(emergencyContactsProvider.notifier).loadContacts();
    });
  }

  Future<void> _loadLocalProfile() async {
    final local = await ProfileSessionCache.readLocalProfile();
    final user = ref.read(authProvider).user;
    if (!mounted) return;
    setState(() {
      _localName = local['name'];
      _localEmail = local['email'];
      _localPhone = local['phone'];
      _localBloodGroup = local['blood'];
      _localPhotoPath = local['photoPath'];
    });
    final displayName = (user?.name ?? '').trim().isNotEmpty
        ? user!.name.trim()
        : (_localName ?? '');
    unawaited(
      ref.read(profileDisplayProvider.notifier).update(
        name: displayName,
        photoPath: _localPhotoPath ?? '',
      ),
    );
  }

  Future<void> _saveLocalProfile({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
    String? localPhotoPath,
  }) async {
    await ProfileSessionCache.writeLocalProfile(
      fullName: fullName,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      localPhotoPath: localPhotoPath,
    );
    if (!mounted) return;
    setState(() {
      _localName = fullName;
      _localEmail = email;
      _localPhone = phone;
      _localBloodGroup = bloodGroup;
      if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
        _localPhotoPath = localPhotoPath;
      }
    });
    unawaited(
      ref
          .read(profileDisplayProvider.notifier)
          .update(name: fullName, photoPath: localPhotoPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = ref.watch(appLocaleProvider);
    final rawDisplayName = (user?.name ?? '').trim().isNotEmpty
        ? user!.name.trim()
        : (_localName != null && _localName!.trim().isNotEmpty)
        ? _localName!
        : l10n.t('profileUserNamePlaceholder');
    final displayName = LocalizedDisplayName.forLocale(
      rawDisplayName,
      currentLocale,
    );
    final displayEmail = (user?.email ?? '').trim().isNotEmpty
        ? user!.email.trim()
        : (_localEmail != null && _localEmail!.trim().isNotEmpty)
        ? _localEmail!
        : l10n.t('profileEmailPlaceholder');
    final displayPhone = (user?.phone ?? '').trim().isNotEmpty
        ? user!.phone.trim()
        : (_localPhone != null && _localPhone!.trim().isNotEmpty)
        ? _localPhone!
        : l10n.t('notProvided');
    final contacts = ref.watch(emergencyContactsProvider);
    final impactDetectionState = ref.watch(impactDetectionProvider);
    final screamDetectionState = ref.watch(screamDetectionProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final selectedLanguage = AppLanguageX.fromLocale(currentLocale);
    final isDarkMode = themeMode == ThemeMode.dark;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final profileText = isLight ? const Color(0xFF172235) : Colors.white;
    final profileMuted = isLight ? const Color(0xFF5F6F8A) : Colors.white70;
    final ImageProvider<Object>? profileImage =
        _localPhotoPath != null && _localPhotoPath!.isNotEmpty
        ? FileImage(File(_localPhotoPath!))
        : profilePhotoImageProvider(user?.profilePhoto);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('myProfile')),
        systemOverlayStyle: AppTheme.overlayStyleForBrightness(
          Theme.of(context).brightness,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLight
                  ? const [Color(0xFFF7FAFF), Color(0xFFEAF2FF)]
                  : const [Color(0xFF09111F), Color(0xFF121C30)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? const [
                    Color(0xFFF8FBFF),
                    Color(0xFFF1F6FF),
                    Color(0xFFEAF2FF),
                  ]
                : const [
                    Color(0xFF07101F),
                    Color(0xFF0A1528),
                    Color(0xFF050B16),
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHero(
                displayName: displayName,
                displayEmail: displayEmail,
                profileImage: profileImage,
                profileText: profileText,
                profileMuted: profileMuted,
                isLight: isLight,
                onPreviewPhoto: profileImage == null
                    ? null
                    : () => _showProfilePhotoPreview(profileImage),
                onEditPhoto: _isSaving ? null : _pickAndUploadPhoto,
                onEditDetails: _isSaving
                    ? null
                    : () => _showEditProfileDialog(
                        user,
                        displayName: rawDisplayName,
                        displayEmail: displayEmail,
                        displayPhone: displayPhone == l10n.t('notProvided')
                            ? ''
                            : displayPhone,
                      ),
              ),
              const SizedBox(height: 14),
              ProfileLanguageSelector(
                selectedLanguage: selectedLanguage,
                profileText: profileText,
                profileMuted: profileMuted,
                isLight: isLight,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;
                        ref.read(appLocaleProvider.notifier).setLanguage(value);
                      },
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLight
                        ? const [Colors.white, Color(0xFFF8FBFF)]
                        : const [Color(0xFF111B2E), Color(0xFF0D1626)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isLight
                        ? const Color(0xFFDCE5F6)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isLight ? 0.05 : 0.22,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n.t('darkMode'),
                        style: TextStyle(
                          color: profileText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        isDarkMode
                            ? l10n.t('darkModeSubtitleOn')
                            : l10n.t('darkModeSubtitleOff'),
                        style: TextStyle(color: profileMuted),
                      ),
                      value: isDarkMode,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (enabled) {
                        ref
                            .read(appThemeModeProvider.notifier)
                            .setThemeMode(
                              enabled ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.graphic_eq,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(
                        l10n.t('screamDetection'),
                        style: TextStyle(
                          color: profileText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        !FeatureFlags.backgroundMicrophone
                            ? l10n.t('featureFlagDisabledHint')
                            : screamDetectionState.monitoring
                            ? l10n.t('microphoneSafetyMonitorActive')
                            : l10n.t('microphoneSafetyMonitorInactive'),
                        style: TextStyle(color: profileMuted),
                      ),
                      value: FeatureFlags.backgroundMicrophone &&
                          screamDetectionState.enabled,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: !FeatureFlags.backgroundMicrophone || _isSaving
                          ? null
                          : (enabled) => _setScreamDetectionEnabled(enabled),
                    ),
                    if (screamDetectionState.enabled) ...[
                      if (screamDetectionState.batteryRestricted)
                        ListTile(
                          leading: const Icon(
                            Icons.battery_alert_rounded,
                            color: Colors.orange,
                          ),
                          title: Text(
                            l10n.t('distressBatteryRestrictedWarning'),
                            style: TextStyle(
                              color: profileText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () => unawaited(
                              DistressForegroundController.openBatterySettings(),
                            ),
                            child: Text(l10n.t('openSettings')),
                          ),
                        ),
                      if (!screamDetectionState.permissionGranted &&
                          screamDetectionState.error != null)
                        ListTile(
                          leading: const Icon(
                            Icons.mic_off_rounded,
                            color: Colors.orange,
                          ),
                          title: Text(
                            screamDetectionState.error!,
                            style: TextStyle(
                              color: profileText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () => unawaited(
                              ref
                                  .read(screamDetectionProvider.notifier)
                                  .openMicrophoneSettings(),
                            ),
                            child: Text(l10n.t('openSettings')),
                          ),
                        ),
                      ListTile(
                        leading: const Icon(
                          Icons.tune_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(
                          l10n.t('distressSensitivity'),
                          style: TextStyle(
                            color: profileText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          l10n.t('distressSensitivitySubtitle'),
                          style: TextStyle(color: profileMuted),
                        ),
                        trailing: DropdownButton<DistressSensitivity>(
                          value: screamDetectionState.sensitivity,
                          underline: const SizedBox.shrink(),
                          items: DistressSensitivity.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    l10n.t('distressSensitivity_${level.name}'),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  ref
                                      .read(screamDetectionProvider.notifier)
                                      .setSensitivity(value);
                                },
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.science_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(
                          l10n.t('distressTestMode'),
                          style: TextStyle(
                            color: profileText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          screamDetectionState.lastSpeechSnippet != null
                              ? '${l10n.t('distressLastHeard')}: ${screamDetectionState.lastSpeechSnippet}'
                              : l10n.t('distressTestModeSubtitle'),
                          style: TextStyle(color: profileMuted),
                        ),
                        value: screamDetectionState.testMode,
                        activeThumbColor: AppTheme.primaryColor,
                        onChanged: _isSaving
                            ? null
                            : (enabled) => ref
                                  .read(screamDetectionProvider.notifier)
                                  .setTestMode(enabled),
                      ),
                      if (screamDetectionState.falsePositiveCount >= 3)
                        ListTile(
                          leading: const Icon(
                            Icons.tune_rounded,
                            color: Colors.orange,
                          ),
                          title: Text(
                            l10n.t('distressLowerSensitivityHint'),
                            style: TextStyle(color: profileMuted),
                          ),
                        ),
                    ],
                    const Divider(height: 1),
                    Consumer(
                      builder: (context, ref, _) {
                        final prefs = ref.watch(safetyPreferencesProvider);
                        final notifier =
                            ref.read(safetyPreferencesProvider.notifier);
                        Widget tile({
                          required IconData icon,
                          required String titleKey,
                          required String subtitleKey,
                          required bool value,
                          required ValueChanged<bool>? onChanged,
                        }) {
                          return SwitchListTile(
                            secondary: Icon(icon, color: AppTheme.primaryColor),
                            title: Text(
                              l10n.t(titleKey),
                              style: TextStyle(
                                color: profileText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              l10n.t(subtitleKey),
                              style: TextStyle(color: profileMuted),
                            ),
                            value: value,
                            activeThumbColor: AppTheme.primaryColor,
                            onChanged: prefs.loading ? null : onChanged,
                          );
                        }

                        return Column(
                          children: [
                            tile(
                              icon: Icons.explore_outlined,
                              titleKey: 'journeySafetyAlerts',
                              subtitleKey: 'journeySafetyAlertsSubtitle',
                              value: prefs.journeyAlertsEnabled,
                              onChanged: notifier.setJourneyAlertsEnabled,
                            ),
                            tile(
                              icon: Icons.crisis_alert_rounded,
                              titleKey: 'notifPrefSos',
                              subtitleKey: 'notifPrefSosSubtitle',
                              value: prefs.sosAlertsEnabled,
                              onChanged: notifier.setSosAlertsEnabled,
                            ),
                            tile(
                              icon: Icons.alt_route_rounded,
                              titleKey: 'notifPrefRoute',
                              subtitleKey: 'notifPrefRouteSubtitle',
                              value: prefs.routeWarningsEnabled,
                              onChanged: notifier.setRouteWarningsEnabled,
                            ),
                            tile(
                              icon: Icons.groups_outlined,
                              titleKey: 'notifPrefCommunity',
                              subtitleKey: 'notifPrefCommunitySubtitle',
                              value: prefs.communityAlertsEnabled,
                              onChanged: notifier.setCommunityAlertsEnabled,
                            ),
                            tile(
                              icon: Icons.alarm_on_outlined,
                              titleKey: 'notifPrefReminders',
                              subtitleKey: 'notifPrefRemindersSubtitle',
                              value: prefs.safetyRemindersEnabled,
                              onChanged: notifier.setSafetyRemindersEnabled,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.inbox_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(
                                l10n.t('notifInboxTitle'),
                                style: TextStyle(
                                  color: profileText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                l10n.t('notifInboxOpenSubtitle'),
                                style: TextStyle(color: profileMuted),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _pushWithTransition(
                                context,
                                const NotificationsInboxScreen(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(
                        Icons.car_crash,
                        color: AppTheme.primaryColor,
                      ),
                      title: Text(
                        l10n.t('impactDetection'),
                        style: TextStyle(
                          color: profileText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        impactDetectionState.monitoring
                            ? l10n.t('motionSensorsActive')
                            : l10n.t('motionSensorsInactive'),
                        style: TextStyle(color: profileMuted),
                      ),
                      value: impactDetectionState.enabled,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: _isSaving
                          ? null
                          : (enabled) => _setImpactDetectionEnabled(enabled),
                    ),
                    if (impactDetectionState.enabled) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.tune_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(
                          l10n.t('impactSensitivity'),
                          style: TextStyle(
                            color: profileText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: DropdownButton<ImpactSensitivity>(
                          value: impactDetectionState.sensitivity,
                          underline: const SizedBox.shrink(),
                          items: ImpactSensitivity.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    l10n.t(
                                      'distressSensitivity_${level.name}',
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _isSaving
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  ref
                                      .read(impactDetectionProvider.notifier)
                                      .setSensitivity(value);
                                },
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.science_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(
                          l10n.t('impactTestMode'),
                          style: TextStyle(
                            color: profileText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          l10n.t('impactTestModeSubtitle'),
                          style: TextStyle(color: profileMuted),
                        ),
                        value: impactDetectionState.testMode,
                        onChanged: _isSaving
                            ? null
                            : (enabled) => ref
                                  .read(impactDetectionProvider.notifier)
                                  .setTestMode(enabled),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ProfileSettingsTile(
                title: l10n.t('medicalHealthVault'),
                value: l10n.t('keepEmergencyMedicalInformationOrganized'),
                icon: Icons.medical_services_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MedicalVaultScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              DailyRouteGuardCard(
                onOpenMap: () =>
                    _pushWithTransition(context, const SafetyMapScreen()),
              ),
              const SizedBox(height: 14),
              ProfileSettingsTile(
                title: l10n.t('emergencyContacts'),
                value: '${contacts.length} ${l10n.t('contactsSaved')}',
                icon: Icons.people_rounded,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.t('emergencyContactList'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: profileText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...contacts.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: EmergencyContactItem(
                    contact: c,
                    enabled: !_isSaving,
                    onTestSms: () => SOSSmsService().openTestComposer(c),
                    onMakePrimary: () => ref
                        .read(emergencyContactsProvider.notifier)
                        .setPrimary(c.id),
                    onEdit: () => _showEditContactDialog(c),
                    onDelete: () => _deleteContact(c.id),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _showAddContactDialog,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.t('addEmergencyContact')),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignedInDevicesScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.devices_rounded),
                  label: Text(l10n.t('signedInDevicesTitle')),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccountPrivacyScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(l10n.t('accountPrivacyTitle')),
                ),
              ),
              const SizedBox(height: 14),
              const SentinelProfileCard(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.t('logoutSession')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pushWithTransition(BuildContext context, Widget screen) {
    return AppNavigator.pushPremium(context, screen);
  }

  Future<void> _setScreamDetectionEnabled(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    if (enabled) {
      if (!await ensureEmergencyContactsSaved(context, ref) ||
          !context.mounted ||
          !await _confirmDistressMonitoring(microphone: true) ||
          !context.mounted ||
          !await _confirmBatteryGuidanceIfNeeded()) {
        return;
      }
    }
    final success = await ref
        .read(screamDetectionProvider.notifier)
        .setEnabled(enabled, allowBatteryPrompt: enabled);
    if (!mounted) return;

    final state = ref.read(screamDetectionProvider);
    final message = success
        ? enabled
              ? l10n.t('screamDetectionEnabled')
              : l10n.t('screamDetectionDisabled')
        : state.error ?? l10n.t('screamDetectionEnableFailed');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setImpactDetectionEnabled(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    if (enabled) {
      if (!await ensureEmergencyContactsSaved(context, ref) ||
          !context.mounted ||
          !await _confirmDistressMonitoring(microphone: false)) {
        return;
      }
    }
    final success = await ref
        .read(impactDetectionProvider.notifier)
        .setEnabled(enabled);
    if (!mounted) return;

    final state = ref.read(impactDetectionProvider);
    final message = success
        ? enabled
              ? l10n.t('impactDetectionEnabled')
              : l10n.t('impactDetectionDisabled')
        : state.error ?? l10n.t('impactDetectionEnableFailed');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDistressMonitoring({
    required bool microphone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final consentKey = microphone
        ? 'distress_consent_scream_v1'
        : 'distress_consent_impact_v1';
    if (prefs.getBool(consentKey) == true) return true;

    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    final accepted =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: Icon(
              microphone ? Icons.mic_rounded : Icons.sensors_rounded,
              color: AppTheme.primaryColor,
              size: 42,
            ),
            title: Text(l10n.t('distressConsentTitle')),
            content: Text(
              microphone
                  ? l10n.t('distressMicrophoneConsentBody')
                  : l10n.t('distressImpactConsentBody'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.t('enableMonitoring')),
              ),
            ],
          ),
        ) ??
        false;

    if (accepted) {
      await prefs.setBool(consentKey, true);
    }
    return accepted;
  }

  Future<bool> _confirmBatteryGuidanceIfNeeded() async {
    final restricted =
        await DistressForegroundController.isBatteryRestricted();
    if (!restricted) return true;
    if (!mounted) return false;

    final l10n = AppLocalizations.of(context);
    final accepted =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.battery_alert_rounded,
              color: Colors.orange,
              size: 42,
            ),
            title: Text(l10n.t('distressBatteryGuidanceTitle')),
            content: Text(l10n.t('distressBatteryGuidanceBody')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.t('continue')),
              ),
            ],
          ),
        ) ??
        false;
    return accepted;
  }

  Future<void> _showEditProfileDialog(
    UserModel? user, {
    required String displayName,
    required String displayEmail,
    required String displayPhone,
  }) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final nameController = TextEditingController(text: displayName);
    final emailController = TextEditingController(text: displayEmail);
    final phoneController = TextEditingController(text: displayPhone);
    final bloodController = TextEditingController(
      text: (_localBloodGroup != null && _localBloodGroup!.isNotEmpty)
          ? _localBloodGroup
          : (user?.bloodGroup ?? ''),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D8CF8), Color(0xFF2ED6C5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.badge_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.t('editProfile'))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.t('fullName'),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.t('email'),
                  prefixIcon: const Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.t('phoneNumber'),
                  prefixIcon: const Icon(Icons.call_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bloodController,
                decoration: InputDecoration(
                  labelText: l10n.t('bloodGroup'),
                  prefixIcon: const Icon(Icons.bloodtype_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _updateProfile(
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  bloodGroup: bloodController.text.trim(),
                );
                if (mounted) {
                  navigator.pop();
                  await _showSaveSuccess(
                    l10n.t('profileSavedTitle'),
                    l10n.t('profileSavedMessage'),
                  );
                }
              } catch (error) {
                _showError(ProfileFormatHelpers.extractError(error));
              }
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddContactDialog() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();
    var saving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.group_add_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.t('addEmergencyContactTitle'))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  enabled: !saving,
                  decoration: InputDecoration(
                    labelText: l10n.t('name'),
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  enabled: !saving,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.t('phoneNumber'),
                    prefixIcon: const Icon(Icons.call_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: relationController,
                  enabled: !saving,
                  decoration: InputDecoration(
                    labelText: l10n.t('relation'),
                    prefixIcon: const Icon(Icons.family_restroom_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: Text(l10n.t('cancel')),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      final phone = phoneController.text.trim();
                      final relation = relationController.text.trim();
                      if (name.isEmpty || phone.isEmpty) {
                        _showError(l10n.t('nameAndPhoneRequired'));
                        return;
                      }

                      setDialogState(() => saving = true);
                      try {
                        final saved = await ref
                            .read(emergencyContactsProvider.notifier)
                            .addContact(
                              EmergencyContact(
                                id: '',
                                name: name,
                                phone: phone,
                                relation: relation.isEmpty
                                    ? l10n.t('emergencyContactDefault')
                                    : relation,
                                priority:
                                    ref.read(emergencyContactsProvider).isEmpty
                                    ? 0
                                    : 1,
                              ),
                            );
                        if (!mounted) return;
                        if (!saved) {
                          _showError(l10n.t('duplicatePhoneNumber'));
                          setDialogState(() => saving = false);
                          return;
                        }

                        navigator.pop();
                        await _showSaveSuccess(
                          l10n.t('contactSavedTitle'),
                          l10n.t('contactSavedMessage'),
                        );
                      } catch (error) {
                        _showError(ProfileFormatHelpers.extractError(error));
                        if (mounted) setDialogState(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.t('save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditContactDialog(EmergencyContact contact) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone);
    final relationController = TextEditingController(text: contact.relation);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D8CF8), Color(0xFF2ED6C5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.t('editEmergencyContactTitle'))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.t('name'),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.t('phoneNumber'),
                  prefixIcon: const Icon(Icons.call_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relationController,
                decoration: InputDecoration(
                  labelText: l10n.t('relation'),
                  prefixIcon: const Icon(Icons.family_restroom_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final saved = await ref
                    .read(emergencyContactsProvider.notifier)
                    .updateContact(
                      EmergencyContact(
                        id: contact.id,
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        relation: relationController.text.trim().isEmpty
                            ? l10n.t('emergencyContactDefault')
                            : relationController.text.trim(),
                        priority: contact.priority,
                      ),
                    );
                if (!mounted) return;
                if (!saved) {
                  _showError(l10n.t('duplicatePhoneNumber'));
                  return;
                }
                navigator.pop();
                await _showSaveSuccess(
                  l10n.t('contactSavedTitle'),
                  l10n.t('contactSavedMessage'),
                );
              } catch (error) {
                _showError(ProfileFormatHelpers.extractError(error));
              }
            },
            child: Text(l10n.t('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
  }) async {
    setState(() => _isSaving = true);
    try {
      await _saveLocalProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        bloodGroup: bloodGroup,
      );
      final currentUser = ref.read(authProvider).user;
      if (currentUser != null) {
        ref
            .read(authProvider.notifier)
            .updateUser(
              currentUser.copyWith(
                name: fullName,
                email: email,
                phone: phone,
                bloodGroup: bloodGroup,
              ),
            );
      }
      unawaited(
        ref.read(profileDisplayProvider.notifier).update(name: fullName),
      );
      if (!mounted) return;
      await _showSaveSuccess(
        AppLocalizations.of(context).t('profileSavedTitle'),
        AppLocalizations.of(context).t('profileSavedMessage'),
      );
      unawaited(
        _syncProfileToServer(
          fullName: fullName,
          email: email,
          phone: phone,
          bloodGroup: bloodGroup,
        ),
      );
    } catch (error) {
      _showError(ProfileFormatHelpers.extractError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncProfileToServer({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
  }) async {
    try {
      final currentEmail =
          (ref.read(authProvider).user?.email ?? '').trim().toLowerCase();
      final nextEmail = email.trim().toLowerCase();
      final payload = <String, dynamic>{
        'fullName': fullName,
        'bloodGroup': bloodGroup,
      };

      if (nextEmail.isNotEmpty && nextEmail != currentEmail) {
        final verified = await _verifyEmailChangeOtp(nextEmail);
        if (verified == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).t('verifyEmailFirst'),
                ),
              ),
            );
          }
          return;
        }
        payload['email'] = nextEmail;
        payload['emailVerificationToken'] = verified.token;
        payload['password'] = verified.password;
      } else if (nextEmail.isNotEmpty) {
        payload['email'] = nextEmail;
      }

      final data = await _profileRepo.patchProfile(payload);
      if (data == null) return;
      final updatedUser = UserModel.fromJson(data);
      ref.read(authProvider.notifier).updateUser(updatedUser);
      await _saveLocalProfile(
        fullName: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        bloodGroup: updatedUser.bloodGroup ?? bloodGroup,
      );
      unawaited(
        ref
            .read(profileDisplayProvider.notifier)
            .update(name: updatedUser.name),
      );
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).t('savedLocallyRetryLater'),
            ),
          ),
        );
      }
    } catch (_) {
      // Keep the local save as the source of truth.
    }
  }

  Future<({String token, String password})?> _verifyEmailChangeOtp(
    String email,
  ) async {
    final l10n = AppLocalizations.of(context);
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('signUpVerifyEmail')),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.t('password')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, passwordController.text),
            child: Text(l10n.t('continue')),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty || !mounted) {
      return null;
    }

    final send = await ref.read(authProvider.notifier).requestEmailChange(
          email: email,
          password: password,
        );
    if (!send.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(send.error ?? l10n.t('otpSendFailed'))),
        );
      }
      return null;
    }
    if (!mounted) return null;

    final codeController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('signUpVerifyEmail')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.t('otpSent')),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(labelText: l10n.t('enterOtp')),
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
            child: Text(l10n.t('verifyOtp')),
          ),
        ],
      ),
    );
    final code = codeController.text.trim();
    codeController.dispose();
    if (confirmed != true || code.length < 4) return null;

    final verified = await ref.read(authProvider.notifier).verifyOtp(
          email: email,
          code: code,
          purpose: 'change_email',
        );
    if (!verified.success || verified.verificationToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verified.error ?? l10n.t('otpInvalid'))),
        );
      }
      return null;
    }
    return (token: verified.verificationToken!, password: password);
  }

  Future<void> _pickAndUploadPhoto() async {
    final photoSavedLocallyMessage = AppLocalizations.of(
      context,
    ).t('photoSavedLocally');
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() => _isSaving = true);
      await _saveLocalProfile(
        fullName: _localName ?? (ref.read(authProvider).user?.name ?? ''),
        email: _localEmail ?? (ref.read(authProvider).user?.email ?? ''),
        phone: _localPhone ?? (ref.read(authProvider).user?.phone ?? ''),
        bloodGroup:
            _localBloodGroup ?? (ref.read(authProvider).user?.bloodGroup ?? ''),
        localPhotoPath: picked.path,
      );
      unawaited(
        ref
            .read(profileDisplayProvider.notifier)
            .update(photoPath: picked.path),
      );
      if (!mounted) return;
      await _showSaveSuccess(
        AppLocalizations.of(context).t('profileSavedTitle'),
        AppLocalizations.of(context).t('profileSavedMessage'),
      );
      unawaited(_syncProfilePhotoToServer(picked.path));
    } catch (error) {
      _showError('$photoSavedLocallyMessage ${ProfileFormatHelpers.extractError(error)}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncProfilePhotoToServer(String photoPath) async {
    try {
      final data = await _profileRepo.uploadPhoto(photoPath);
      if (data == null) return;
      final updatedUser = UserModel.fromJson(data);
      ref.read(authProvider.notifier).updateUser(updatedUser);
      unawaited(
        ref.read(profileDisplayProvider.notifier).update(photoPath: photoPath),
      );
    } catch (_) {
      // Local photo is already visible immediately.
    }
  }

  Future<void> _deleteContact(String id) async {
    try {
      await ref.read(emergencyContactsProvider.notifier).deleteContact(id);
    } catch (error) {
      _showError(ProfileFormatHelpers.extractError(error));
    }
  }
}
