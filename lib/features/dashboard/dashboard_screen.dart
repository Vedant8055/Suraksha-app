import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

import 'package:suraksha_women_safety_app/core/accessibility/accessibility.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/core/navigation/app_navigator.dart';
import 'package:suraksha_women_safety_app/core/media/profile_photo_provider.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contact_guard.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_provider.dart';
import 'package:suraksha_women_safety_app/features/sos/emergency_mode_screen.dart';
import 'package:suraksha_women_safety_app/features/sos/scream_detection_service.dart';
import 'package:suraksha_women_safety_app/features/sos/sensor_service.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/cybercrime_screen.dart';
import 'package:suraksha_women_safety_app/features/maps/map_handoff_actions.dart';
import 'package:suraksha_women_safety_app/features/maps/safety_map_screen.dart';
import 'package:suraksha_women_safety_app/features/ai_assistant/suraksha_ai_chat_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_chat_screen.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_screen.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_places_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alerts_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alert_display_helpers.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alert_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/dashboard_chrome_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/emergency_dial_cards.dart';
import 'package:suraksha_women_safety_app/features/dashboard/emergency_services_scan_service.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_services_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_meta_chip.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_verdict_helper.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_display_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/localized_display_name.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';
import 'package:suraksha_women_safety_app/widgets/safety_risk_reasons_expansion.dart';

final _manualSosLaunchingProvider = StateProvider<bool>((ref) => false);
final communityAlertsExpandedProvider = StateProvider<bool>((ref) => false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _showProfilePhotoPreview(
    BuildContext context,
    ImageProvider<Object> profileImage,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image(image: profileImage, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Future<void> _pushPremium(BuildContext context, Widget screen) {
    return AppNavigator.pushPremium(context, screen);
  }

  Future<void> _confirmAndOpenOnMap(
    BuildContext context,
    NearbyPlaceItem place,
  ) async {
    final choice = await showMapHandoffDialog(
      context,
      placeName: place.name,
      placeAddress: place.address,
    );

    if (!context.mounted || choice == null) return;

    if (choice == MapHandoffOption.surakshaMap) {
      await _pushPremium(
        context,
        SafetyMapScreen(
          initialTargetLatitude: place.latitude,
          initialTargetLongitude: place.longitude,
          initialTargetName: place.name,
        ),
      );
      return;
    }

    final launched = await launchGoogleMapsDirections(
      latitude: place.latitude,
      longitude: place.longitude,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotOpenGoogleMaps')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 68) / 2;
    final safetyState = ref.watch(safetyMonitorProvider);
    ref.watch(appLocaleProvider);
    ref.listen(appLocaleProvider, (previous, next) {
      if (previous?.languageCode == next.languageCode) return;
      final nearbyState = ref.read(nearbyPlacesProvider);
      final activeType = nearbyState.activeType;
      if (activeType != null && nearbyState.places.isNotEmpty) {
        unawaited(
          ref.read(nearbyPlacesProvider.notifier).fetchNearby(activeType),
        );
      }
    });

    if (!safetyState.gpsEnabled || !safetyState.permissionGranted) {
      return DashboardLocationRequiredView(
        statusMessage: safetyState.statusMessage,
        onRetry: () {
          unawaited(
            ref.read(safetyMonitorProvider.notifier).retry().catchError((_) {}),
          );
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const DashboardBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref),
                  _buildActiveMonitorBanner(context, ref),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, cardWidth),
                  const SizedBox(height: 24),
                  _buildSOSButton(context, ref),
                  const SizedBox(height: 14),
                  const PoliceEmergencyDialCard(),
                  const SizedBox(height: 14),
                  _buildSafetyIntelligenceCard(context, ref),
                  const SizedBox(height: 20),
                  const WomenHelplineDialCard(),
                  const SizedBox(height: 24),
                  _buildRecentAlerts(context, ref),
                  const SizedBox(height: 24),
                  NearbyServicesBlock(onOpenPlace: _confirmAndOpenOnMap),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final user = ref.watch(authProvider).user;
    final profileDisplay = ref.watch(profileDisplayProvider);
    final greetingPrefix = AppLocalizations.of(context).t('greetingHello');
    final rawName = (user?.name ?? '').trim().isNotEmpty
        ? user!.name.trim()
        : profileDisplay.name.trim().isNotEmpty
        ? profileDisplay.name.trim()
        : l10n.t('userFallback');
    final displayName = LocalizedDisplayName.forLocale(
      rawName,
      ref.watch(appLocaleProvider),
    );
    final localPhotoPath = profileDisplay.photoPath;
    final remotePhotoUrl = user?.profilePhoto;
    final ImageProvider<Object>? profileImage =
        profilePhotoImageProvider(localPhotoPath) ??
        profilePhotoImageProvider(remotePhotoUrl);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF3F7FF), Color(0xFFEAF1FF)]
              : const [Color(0xFF1A1A1A), Color(0xFF000000), Color(0xFF2A2A2A)],
          stops: const [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0xFFD7E3F5)
              : Colors.white.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? const Color(0xFF7E8FB0).withValues(alpha: 0.24)
                : Colors.black.withValues(alpha: 0.55),
            blurRadius: isLight ? 16 : 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isLight
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.65)
                : const Color(0xFF8FA2BE).withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('appTitle'),
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$greetingPrefix, $displayName',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isLight ? const Color(0xFF172235) : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFE6FAF2)
                        : const Color(0xFF194E43),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 14,
                        color: Color(0xFF69E5C8),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.t('safeZoneActive'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3A8E7C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _pushPremium(context, const ProfileScreen()),
            onLongPress: profileImage == null
                ? null
                : () => _showProfilePhotoPreview(context, profileImage),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A436B), Color(0xFF1A2B48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isLight
                      ? const Color(0xFFD9E5F8)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: ClipOval(
                child: profileImage != null
                    ? Image(
                        image: profileImage,
                        fit: BoxFit.cover,
                        width: 58,
                        height: 58,
                      )
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSosActivation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmKey = FeatureFlags.sosAutoSms && FeatureFlags.publicLiveSharing
        ? 'sosConfirmMessage'
        : FeatureFlags.sosAutoSms
            ? 'sosConfirmMessageSmsOnly'
            : FeatureFlags.publicLiveSharing
                ? 'sosConfirmMessageLiveOnly'
                : 'sosConfirmMessageMinimal';
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.sos_rounded,
              color: AppTheme.accentColor,
              size: 42,
            ),
            title: Text(l10n.t('sosConfirmTitle')),
            content: Text(l10n.t(confirmKey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.t('cancel')),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.warning_amber_rounded),
                label: Text(l10n.t('activateSos')),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildSOSButton(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sosState = ref.watch(sosProvider);
    final isLaunching = ref.watch(_manualSosLaunchingProvider);
    final semanticLabel = sosState.isActive || isLaunching
        ? l10n.t('a11yOpenEmergencyMode')
        : l10n.t('activateSos');

    final button = Container(
      width: 172,
      height: 172,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFF5A4A),
            const Color(0xFFE53935),
            const Color(0xFFB71C1C),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(
              alpha: sosState.isActive || isLaunching ? 0.48 : 0.24,
            ),
            blurRadius: sosState.isActive || isLaunching ? 36 : 16,
            spreadRadius: sosState.isActive || isLaunching ? 10 : 3,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new, size: 58, color: Colors.white),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ExcludeSemantics(
                child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.t('dashboardSosLabel'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );

    final animated = Accessibility.motionAware(
      context: context,
      child: button,
      animate: (child) => Pulse(
        infinite: true,
        duration: const Duration(milliseconds: 800),
        child: child,
      ),
    );

    return Center(
      child: Semantics(
        button: true,
        enabled: !isLaunching || sosState.isActive,
        label: semanticLabel,
        hint: sosState.isActive
            ? null
            : 'Double tap to confirm and activate emergency SOS',
        child: GestureDetector(
          onTap: () async {
            if (isLaunching) return;
            if (sosState.isActive) {
              _pushPremium(context, const EmergencyModeScreen());
              return;
            }
            final canTriggerSos = await ensureEmergencyContactsSaved(
              context,
              ref,
            );
            if (!canTriggerSos) return;
            if (!context.mounted ||
                !await _confirmSosActivation(context) ||
                !context.mounted) {
              return;
            }
            ref.read(_manualSosLaunchingProvider.notifier).state = true;
            unawaited(ref.read(sosProvider.notifier).triggerSOS());
            // Keep the launch animation to exactly 3 pulse cycles before opening SOS mode.
            await Future<void>.delayed(const Duration(milliseconds: 2400));
            ref.read(_manualSosLaunchingProvider.notifier).state = false;
            if (!context.mounted) {
              return;
            }
            _pushPremium(context, const EmergencyModeScreen());
          },
          child: sosState.isActive || isLaunching ? animated : button,
        ),
      ),
    );
  }

  Widget _buildActiveMonitorBanner(BuildContext context, WidgetRef ref) {
    final scream = ref.watch(screamDetectionProvider);
    final impact = ref.watch(impactDetectionProvider);
    if (!scream.monitoring && !impact.monitoring) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFFEAF5FF)
              : AppTheme.primaryColor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shield_rounded,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('safetyMonitoringActive'),
                    style: TextStyle(
                      color: isLight
                          ? const Color(0xFF172235)
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    [
                      if (scream.monitoring) l10n.t('microphoneMonitor'),
                      if (impact.monitoring) l10n.t('impactMonitor'),
                    ].join(' â€¢ '),
                    style: TextStyle(
                      color: isLight
                          ? const Color(0xFF5F6F8A)
                          : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                if (scream.enabled) {
                  await ref
                      .read(screamDetectionProvider.notifier)
                      .setEnabled(false);
                }
                if (impact.enabled) {
                  await ref
                      .read(impactDetectionProvider.notifier)
                      .setEnabled(false);
                }
              },
              child: Text(l10n.t('stopMonitoring')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, double cardWidth) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('emergencyServices'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isLight ? const Color(0xFF172235) : Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionCard(
              context,
              Icons.map_rounded,
              l10n.t('map'),
              const Color(0xFF3B82F6),
              const SafetyMapScreen(),
              cardWidth,
            ),
            if (FeatureFlags.surakshaAi)
              _buildActionCard(
                context,
                Icons.auto_awesome_rounded,
                l10n.t('surakshaAi'),
                const Color(0xFF7C5CFC),
                const SurakshaAiChatScreen(),
                cardWidth,
              ),
            _buildActionCard(
              context,
              Icons.security_rounded,
              l10n.t('cyber'),
              const Color(0xFFEC9F2A),
              const CyberCrimeScreen(),
              cardWidth,
            ),
            _buildActionCard(
              context,
              Icons.gavel_rounded,
              l10n.t('dashboardPoshLabel'),
              const Color(0xFF2FB79E),
              const POSHLegalPortalScreen(),
              cardWidth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyIntelligenceCard(BuildContext context, WidgetRef ref) {
    final safetyState = ref.watch(safetyMonitorProvider);
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isLoading =
        safetyState.isRefreshing && !safetyState.areaAssessmentReady;

    // Area intelligence refresh and the 1 km emergency-services scan are
    // triggered by SafetyMonitorNotifier itself (on position updates), not
    // as a build-time side effect here.

    final verdict = SafetyVerdictHelper.forMonitorState(
      l10n,
      state: safetyState,
    );
    final actionGuidance = SafetyVerdictHelper.actionGuidanceForMonitor(
      l10n,
      state: safetyState,
      level: verdict.level,
    );
    final riskReasons = SafetyVerdictHelper.riskReasonsForMonitor(
      l10n,
      state: safetyState,
      verdict: verdict,
    );
    final safeReasons = SafetyVerdictHelper.positiveReasonsForMonitor(
      l10n,
      state: safetyState,
      at: DateTime.now(),
    );
    final tone = verdict.tone;
    final summaryText = isLoading
        ? l10n.t('safetyUpdatingAreaIntelligence')
        : verdict.summary;
    final detailsTitle = verdict.level == SafetyVerdictLevel.safe
        ? l10n.t('safetyWhySafeTitle')
        : l10n.t('safetyWhyNotSafeTitle');
    final detailsReasons = verdict.level == SafetyVerdictLevel.safe
        ? safeReasons
        : riskReasons;
    // Always show the services block (zeros until scan completes).
    final emergencyServices = safetyState.emergencyServices1km.scanned
        ? safetyState.emergencyServices1km
        : const NearbyEmergencyServicesSnapshot(scanned: true);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [
                  const Color(0xFFFFFFFF),
                  Color.lerp(const Color(0xFFF5FAFF), tone, 0.12)!,
                ]
              : [
                  Color.lerp(AppTheme.cardColor, tone, 0.18)!,
                  const Color(0xFF101827),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tone.withValues(alpha: isLight ? 0.24 : 0.36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: isLight ? 0.12 : 0.20),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: tone,
                        ),
                      )
                    : Icon(Icons.shield_rounded, color: tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('aiSafetyIntelligence'),
                      style: TextStyle(
                        color: isLight ? const Color(0xFF172235) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isLoading ? l10n.t('safetyUpdatingAreaIntelligence') : verdict.headline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tone,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Semantics(
            label: '${verdict.headline}. $summaryText',
            child: Text(
              summaryText,
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF334158)
                    : Colors.white.withValues(alpha: 0.88),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (safetyState.lastUpdatedAt != null)
                  SafetyMetaChip(
                    icon: Icons.schedule_rounded,
                    label: CommunityAlertDisplayHelpers.formatUpdatedAgo(
                      l10n,
                      safetyState.lastUpdatedAt!,
                    ),
                    isLight: isLight,
                  ),
                SafetyMetaChip(
                  icon: Icons.source_rounded,
                  label: CommunityAlertDisplayHelpers.labelForDataSource(
                    AppLocalizations.of(context),
                    safetyState.communityAlerts
                            .where((a) => a.dataSource != null)
                            .map((a) => a.dataSource!)
                            .followedBy(const ['suraksha_engine'])
                            .first,
                  ),
                  isLight: isLight,
                ),
                if (safetyState.aiConfidenceVisible &&
                    safetyState.aiConfidence != null)
                  SafetyMetaChip(
                    icon: Icons.verified_rounded,
                    label:
                        '${safetyState.aiConfidence}% ${l10n.t('safetyConfidenceSuffix')}',
                    isLight: isLight,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t('safetyScoreDisclaimer'),
              style: TextStyle(
                color: isLight
                    ? const Color(0xFF64748B)
                    : Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            SafetyIntelligenceDetailsExpansion(
              title: detailsTitle,
              reasons: detailsReasons,
              actionTitle: l10n.t('safetyWhatToDo'),
              actionText: actionGuidance,
              accentColor: tone,
              isLight: isLight,
              emergencyServices: emergencyServices,
              emergencyServicesTitle: l10n.t('safetyEmergencyWithin1kmTitle'),
            ),
          ],
          if (safetyState.upcomingRisk != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF7F1D1D,
                ).withValues(alpha: isLight ? 0.08 : 0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${safetyState.upcomingRisk!.summary} ${safetyState.upcomingRisk!.recommendedAction}',
                style: TextStyle(
                  color: isLight ? const Color(0xFF6B1D1D) : Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: safetyState.isRefreshing
                  ? null
                  : () => ref.read(safetyMonitorProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: Text(l10n.t('refreshIntelligence')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Widget? screen,
    double width,
  ) {
    return PoppingActionCard(
      icon: icon,
      label: label,
      color: color,
      width: width,
      onTap: screen == null ? null : () => _pushPremium(context, screen),
    );
  }

  Widget _buildRecentAlerts(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final safetyState = ref.watch(safetyMonitorProvider);
    final localAlertsState = ref.watch(communityAlertsProvider);
    final expanded = ref.watch(communityAlertsExpandedProvider);
    final alerts = CommunityAlertDisplayHelpers.resolveCommunityAlerts(
      safetyState,
      localAlertsState,
    );
    final isRefreshing = safetyState.isRefreshing || localAlertsState.isLoading;
    const accent = Color(0xFF3B82F6);
    const accentSecondary = Color(0xFF26BF96);

    ref.listen<SafetyMonitorState>(safetyMonitorProvider, (previous, next) {
      if (!ref.read(communityAlertsExpandedProvider)) return;
      if (next.communityAlerts.isEmpty &&
          !next.isRefreshing &&
          next.position != null &&
          !ref.read(communityAlertsProvider).isLoading &&
          ref.read(communityAlertsProvider).alerts.isEmpty) {
        unawaited(ref.read(communityAlertsProvider.notifier).refresh());
      }
    });

    void refreshAlerts({bool forceCommunityAlerts = true}) {
      unawaited(ref.read(safetyMonitorProvider.notifier).refresh());
      unawaited(
        ref
            .read(communityAlertsProvider.notifier)
            .refresh(force: forceCommunityAlerts),
      );
    }

    void toggleCommunityAlerts() {
      if (isRefreshing) return;
      if (expanded) {
        ref.read(communityAlertsExpandedProvider.notifier).state = false;
        return;
      }
      ref.read(communityAlertsExpandedProvider.notifier).state = true;
      if (alerts.isEmpty) {
        // TTL-respecting refresh: skip the network hit if a recent cached
        // result already exists (handled inside the provider).
        refreshAlerts(forceCommunityAlerts: false);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? const [Color(0xFFFFFFFF), Color(0xFFF6FAFF), Color(0xFFEAF3FF)]
              : const [Color(0xFF15233A), Color(0xFF0B172A), Color(0xFF101827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0xFFCFE0F6)
              : Colors.white.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? const Color(0xFF7892B8).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF26BF96),
                      Color(0xFF3B82F6),
                      Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF0F766E),
                          Color(0xFF2563EB),
                          Color(0xFF7C3AED),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        l10n.t('communityAlerts'),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expanded
                          ? (alerts.isNotEmpty
                                ? l10n.t(
                                    'checkingTrafficTransportNearbyActivity',
                                  )
                                : l10n.t(
                                    'checkingTrafficTransportNearbyActivity',
                                  ))
                          : l10n.t('tapForAlerts'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? const Color(0xFF627491)
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              CommunityAlertsRefreshButton(
                isLight: isLight,
                canRefresh: true,
                isRefreshing: isRefreshing,
                shouldEmphasizeRefresh: alerts.isEmpty && !isRefreshing,
                onPressed: refreshAlerts,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommunityAlertsToggleTile(
            isLight: isLight,
            expanded: expanded,
            loading: isRefreshing && expanded,
            onPressed: toggleCommunityAlerts,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      if (safetyState.dataDisclaimer != null &&
                          safetyState.dataDisclaimer!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CommunityAlertsStatusPanel(
                            isLight: isLight,
                            icon: Icons.info_outline_rounded,
                            loading: false,
                            title: safetyState.regionLabel != null
                                ? '${l10n.t('safetyRegionLabel')}: ${safetyState.regionLabel}'
                                : l10n.t('safetyDataDisclaimerTitle'),
                            subtitle: safetyState.dataDisclaimer,
                            tone: accentSecondary,
                          ),
                        ),
                      if (isRefreshing && alerts.isEmpty)
                        CommunityAlertsStatusPanel(
                          isLight: isLight,
                          icon: null,
                          loading: true,
                          title: l10n.t('loadingLiveAreaAlerts'),
                          tone: accent,
                        )
                      else if (alerts.isEmpty)
                        CommunityAlertsStatusPanel(
                          isLight: isLight,
                          icon: Icons.location_searching_rounded,
                          loading: false,
                          title:
                              localAlertsState.error ??
                              l10n.t('liveAlertsWillAppearHere'),
                          subtitle: localAlertsState.error != null
                              ? l10n.t('tapRefreshTryAgain')
                              : l10n.t('keepGpsOnForRealtimeCommunityUpdates'),
                          tone: accentSecondary,
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: CommunityAlertCard(
                              alert: alerts[index],
                              safetyState: safetyState,
                            ),
                          ),
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

}
