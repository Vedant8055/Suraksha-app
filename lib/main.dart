import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:suraksha_women_safety_app/config/api_config.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/core/network/network_manager.dart';
import 'package:suraksha_women_safety_app/core/network/tls_pinning.dart';
import 'package:suraksha_women_safety_app/core/notifications/local_alert_service.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_deep_link.dart';
import 'package:suraksha_women_safety_app/core/notifications/notification_onboarding_sheet.dart';
import 'package:suraksha_women_safety_app/core/notifications/push_notification_service.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_navigator_observer.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';
import 'package:suraksha_women_safety_app/core/navigation/app_navigator.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_gate.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_preferences_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contact_guard.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_display_provider.dart';
import 'package:suraksha_women_safety_app/theme/app_theme.dart';
import 'package:suraksha_women_safety_app/theme/theme_mode_provider.dart';
import 'package:suraksha_women_safety_app/features/routes/route_safety_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:suraksha_women_safety_app/features/sos/scream_detection_service.dart';
import 'package:suraksha_women_safety_app/features/sos/sensor_service.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/localization/locale_provider.dart';
import 'package:suraksha_women_safety_app/widgets/brand_splash_gate.dart';
import 'package:suraksha_women_safety_app/widgets/premium_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await BackendUrlResolver.clearOverride();
  ApiConfig.assertSafeConfiguration();
  if (TlsPinning.isLeafNearingExpiry()) {
    developer.log(
      'TLS leaf pin expires ${TlsPinning.activeLeafExpiresAt.toIso8601String()} — rotate pins before release builds break.',
      name: 'TlsPinning',
    );
  }
  NetworkManager.instance.dio.options.baseUrl = ApiConfig.preferredBaseUrl;
  // Do not block first frame on network/Firebase — warm up in background.
  unawaited(NetworkManager.instance.warmUpInBackground());
  unawaited(_warmUpFirebaseAndPush());
  unawaited(LocalAlertService.instance.ensureReady());
  unawaited(AppActivityLog.instance.record('app_started'));
  unawaited(AppActivityLog.instance.store.purgeExpired());
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _warmUpFirebaseAndPush() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    // Must be registered before any FCM messages arrive; only once per isolate.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (_) {
    // Missing google-services.json / iOS plist — local notifications still work.
  }
  await PushNotificationService.instance.initialize();
}

class MyApp extends ConsumerStatefulWidget {
  final bool startBackgroundServices;

  const MyApp({super.key, this.startBackgroundServices = true});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final _AppLifecycleHandler _lifecycleHandler;
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _impactDialogVisible = false;
  bool _distressDialogVisible = false;
  bool _routeGuardDialogVisible = false;
  bool _missingContactsDialogVisible = false;
  bool _notificationOnboardingVisible = false;
  bool _handlingNotificationOpen = false;

  @override
  void initState() {
    super.initState();
    _lifecycleHandler = _AppLifecycleHandler(
      ref,
      onResumed: _checkMissingEmergencyContactsReminder,
    );
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    NotificationNavigation.onOpen = _onNotificationOpened;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapAuthenticatedSession());
    });
  }

  Future<void> _bootstrapAuthenticatedSession() async {
    if (!mounted) return;
    _syncSafetySummaryLanguage(ref.read(appLocaleProvider));
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated && auth.user != null) {
      unawaited(
        ref.read(profileDisplayProvider.notifier).applyUser(auth.user!),
      );
      // Bind contacts first so the missing-contact reminder never races an empty list.
      await ref
          .read(emergencyContactsProvider.notifier)
          .bindUser(auth.user!.id);
      if (!mounted) return;
      unawaited(
        PushNotificationService.instance.registerTokenIfAuthenticated(),
      );
      unawaited(_maybeShowNotificationOnboarding());
    } else if (auth.token != null && auth.token!.isNotEmpty) {
      unawaited(
        PushNotificationService.instance.registerTokenIfAuthenticated(),
      );
    }
    NotificationNavigation.flushPending();
    await _checkMissingEmergencyContactsReminder();
  }

  @override
  void dispose() {
    if (NotificationNavigation.onOpen == _onNotificationOpened) {
      NotificationNavigation.onOpen = null;
    }
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Locale>(appLocaleProvider, (previous, next) {
      cacheAppLocale(next);
      _syncSafetySummaryLanguage(next);
    });

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && next.token!.isNotEmpty) {
        unawaited(
          PushNotificationService.instance.registerTokenIfAuthenticated(),
        );
      }
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      if (!wasAuthenticated && next.isAuthenticated && next.user != null) {
        // Clear signup / forgot-password routes so AuthGate's Dashboard is visible.
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
        unawaited(
          ref.read(profileDisplayProvider.notifier).applyUser(next.user!),
        );
        unawaited(
          ref.read(routeSafetyProvider.notifier).bindUser(next.user!.id),
        );
        _startBackgroundServicesIfNeeded();
        unawaited(() async {
          await ref
              .read(emergencyContactsProvider.notifier)
              .bindUser(next.user!.id);
          if (!mounted) return;
          await _checkMissingEmergencyContactsReminder();
        }());
        unawaited(_maybeShowNotificationOnboarding());
      }
      if (wasAuthenticated && !next.isAuthenticated) {
        unawaited(PushNotificationService.instance.clearTokenOnLogout());
        unawaited(ref.read(profileDisplayProvider.notifier).clear());
        unawaited(
          ref.read(emergencyContactsProvider.notifier).resetForLogout(),
        );
        unawaited(
          ref.read(routeSafetyProvider.notifier).resetForLogout(),
        );
        unawaited(ref.read(safetyMonitorProvider.notifier).stop().catchError((_) {}));
        final navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      }
    });

    ref.listen<List<EmergencyContact>>(emergencyContactsProvider, (
      previous,
      next,
    ) {
      if (previous == null) return;
      if (previous.isNotEmpty && next.isEmpty) {
        unawaited(_checkMissingEmergencyContactsReminder());
      }
    });

    if (widget.startBackgroundServices) {
      ref.listen<ImpactDetectionState>(impactDetectionProvider, (
        previous,
        next,
      ) {
        final wasActive = previous?.countdownActive ?? false;
        if (next.countdownActive && !_impactDialogVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showImpactCountdownDialog();
          });
        } else if (wasActive && !next.countdownActive && _impactDialogVisible) {
          _dismissImpactCountdownDialog();
        }

        if (next.testMode &&
            next.lastImpactAt != null &&
            next.lastImpactAt != previous?.lastImpactAt) {
          final ctx = _navigatorKey.currentContext;
          if (ctx != null) {
            _showTestModeSnackBar(
              AppLocalizations.of(ctx).t('impactTestDetectionFeedback'),
            );
          }
        }
      });

      ref.listen<ScreamDetectionState>(screamDetectionProvider, (
        previous,
        next,
      ) {
        final wasActive = previous?.countdownActive ?? false;
        if (next.countdownActive && !_distressDialogVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showDistressCountdownDialog();
          });
        } else if (wasActive &&
            !next.countdownActive &&
            _distressDialogVisible) {
          _dismissDistressCountdownDialog();
        }

        if (previous?.permissionGranted == true &&
            next.permissionGranted == false &&
            (next.error?.isNotEmpty ?? false)) {
          _showMicPermissionLostSnackBar(next.error!);
        }

        if (next.testMode &&
            next.lastTestDetectionAt != null &&
            next.lastTestDetectionAt != previous?.lastTestDetectionAt) {
          final ctx = _navigatorKey.currentContext;
          if (ctx != null) {
            final l10n = AppLocalizations.of(ctx);
            final label = next.lastTriggerType == DistressTriggerType.phrase
                ? l10n.t('distressTestPhraseFeedback')
                : l10n.t('distressTestScreamFeedback');
            _showTestModeSnackBar(label);
          }
        }
      });

      ref.listen<RouteSafetyState>(routeSafetyProvider, (previous, next) {
        final wasPending = previous?.pendingSafetyCheck ?? false;
        if (next.pendingSafetyCheck &&
            !wasPending &&
            !_routeGuardDialogVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showRouteGuardCheckDialog();
          });
        } else if (wasPending &&
            !next.pendingSafetyCheck &&
            _routeGuardDialogVisible) {
          _dismissRouteGuardCheckDialog();
        }
      });
    }

    final appThemeMode = ref.watch(appThemeModeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle(appThemeMode),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Suraksha',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appThemeMode,
        locale: appLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const BrandSplashGate(child: AuthGate()),
        navigatorObservers: [ActivityLogNavigatorObserver()],
      ),
    );
  }

  SystemUiOverlayStyle _systemUiOverlayStyle(ThemeMode mode) {
    final isLight = mode == ThemeMode.light;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isLight
          ? const Color(0xFFF6F8FC)
          : Colors.black,
      systemNavigationBarIconBrightness: isLight
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }
//Demo
  void _startBackgroundServicesIfNeeded() {
    if (!widget.startBackgroundServices) return;
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (!auth.isAuthenticated) return;
      unawaited(
        ref.read(safetyMonitorProvider.notifier).start().catchError((_) {}),
      );
      unawaited(
        ref.read(routeSafetyProvider.notifier).start().catchError((_) {}),
      );
    });
  }

  void _syncSafetySummaryLanguage(Locale locale) {
    ref
        .read(safetyMonitorProvider.notifier)
        .setSummaryLanguage(locale.languageCode);
  }

  Future<void> _checkMissingEmergencyContactsReminder() async {
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.user == null) return;

    // Ensure the active user's contacts are bound/loaded before deciding.
    final contactsNotifier = ref.read(emergencyContactsProvider.notifier);
    if (contactsNotifier.activeUserId != auth.user!.id) {
      await contactsNotifier.bindUser(auth.user!.id);
    }

    final hasContacts = await hasSavedEmergencyContactsResolved(ref);
    // null => still not evaluable; true => contacts exist. Only remind when false.
    if (!mounted || hasContacts != false) return;

    _presentMissingEmergencyContactsReminder();
  }

  void _presentMissingEmergencyContactsReminder() {
    if (!mounted || _missingContactsDialogVisible) return;

    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) return;

    _missingContactsDialogVisible = true;
    showMissingEmergencyContactsDialog(dialogContext).whenComplete(() {
      _missingContactsDialogVisible = false;
    });
  }

  Future<void> _maybeShowNotificationOnboarding() async {
    if (!mounted || _notificationOnboardingVisible) return;
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;

    // Wait briefly so AuthGate / splash settle before showing the sheet.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || _notificationOnboardingVisible) return;

    final prefs = ref.read(safetyPreferencesProvider);
    if (prefs.notificationOnboardingDone) return;
    final sheetContext = _navigatorKey.currentContext;
    if (sheetContext == null || !sheetContext.mounted) return;

    _notificationOnboardingVisible = true;
    try {
      await NotificationOnboardingSheet.showIfNeeded(
        sheetContext,
        alreadyDone: prefs.notificationOnboardingDone,
        onCompleted: () => ref
            .read(safetyPreferencesProvider.notifier)
            .markNotificationOnboardingDone(),
      );
    } finally {
      _notificationOnboardingVisible = false;
    }
  }

  void _onNotificationOpened(Map<String, dynamic> payload) {
    if (_handlingNotificationOpen) {
      NotificationNavigation.pendingPayload = payload;
      return;
    }
    unawaited(_handleNotificationOpen(payload));
  }

  Future<void> _handleNotificationOpen(Map<String, dynamic> payload) async {
    if (!mounted) return;
    _handlingNotificationOpen = true;
    try {
      // Allow MaterialApp / AuthGate to mount before navigating.
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;

      if (!ref.read(authProvider).isAuthenticated) {
        NotificationNavigation.pendingPayload = payload;
        return;
      }

      var context = _navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        NotificationNavigation.pendingPayload = payload;
        return;
      }

      final notificationId = payload['notificationId']?.toString() ?? '';
      if (notificationId.isNotEmpty) {
        final ack = await PushNotificationService.instance
            .acknowledgeNotification(notificationId);
        if (!mounted) return;
        context = _navigatorKey.currentContext;
        if (context == null || !context.mounted) return;
        if (ack == NotificationAckResult.expired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).t('notifExpiredHandled'),
              ),
            ),
          );
        }
      }

      final route = (payload['route']?.toString() ?? '').trim();
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;

      if (route == AppRoutes.dashboard ||
          route == AppRoutes.communityAlerts ||
          route == NotificationDeepLink.dashboard ||
          route == NotificationDeepLink.communityAlerts) {
        navigator.popUntil((r) => r.isFirst);
        return;
      }

      if (route == AppRoutes.surakshaAi && !FeatureFlags.surakshaAi) {
        return;
      }

      final mapped = route.isEmpty && notificationId.isNotEmpty
          ? AppRoutes.notificationsInbox
          : (route.isEmpty ? AppRoutes.notificationsInbox : route);

      final screen = AppRoutes.screenFor(mapped) ??
          AppRoutes.screenFor(AppRoutes.notificationsInbox);
      if (screen == null) return;

      final navContext = _navigatorKey.currentContext;
      if (navContext == null || !navContext.mounted) return;
      await AppNavigator.pushPremium(navContext, screen);
    } finally {
      _handlingNotificationOpen = false;
      NotificationNavigation.flushPending();
    }
  }

  void _showTestModeSnackBar(String message) {
    final context = _navigatorKey.currentContext;
    if (context == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showMicPermissionLostSnackBar(String message) {
    final context = _navigatorKey.currentContext;
    if (context == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: l10n.t('openSettings'),
          onPressed: () {
            unawaited(
              ref.read(screamDetectionProvider.notifier).openMicrophoneSettings(),
            );
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _showImpactCountdownDialog() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null || _impactDialogVisible) return;

    _impactDialogVisible = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(impactDetectionProvider);
          final l10n = AppLocalizations.of(context);
          return PremiumDialogSurface(
            title: l10n.t('impactDetected'),
            message: l10n.t('impactDetectedMessage'),
            icon: Icons.warning_amber_rounded,
            accentColor: const Color(0xFFE53935),
            actions: [
              TextButton(
                onPressed: () {
                  unawaited(
                    ref
                        .read(impactDetectionProvider.notifier)
                        .recordFalsePositive(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF172235)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: Text(l10n.t('notAnEmergency')),
              ),
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    ref
                        .read(impactDetectionProvider.notifier)
                        .confirmPendingImpact(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 179, 178),
                  foregroundColor: const Color.fromARGB(255, 232, 49, 49),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l10n.t('sendSosNow')),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  liveRegion: true,
                  label: l10n
                      .t('sosWillBeSentIn')
                      .replaceAll('{seconds}', '${state.countdownSeconds}'),
                  child: Text(
                    l10n
                        .t('sosWillBeSentIn')
                        .replaceAll('{seconds}', '${state.countdownSeconds}'),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF23324A)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.lastImpactPosition == null
                      ? l10n.t('savingLastKnownLocation')
                      : l10n.t('lastLocationSavedForHelp'),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF516078)
                        : Colors.white.withValues(alpha: 0.78),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    _impactDialogVisible = false;
  }

  void _dismissImpactCountdownDialog() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) {
      _impactDialogVisible = false;
      return;
    }

    navigator.pop();
    _impactDialogVisible = false;
  }

  Future<void> _showDistressCountdownDialog() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null || _distressDialogVisible) return;

    _distressDialogVisible = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(screamDetectionProvider);
          final l10n = AppLocalizations.of(context);
          final triggerLabel =
              state.lastTriggerType == DistressTriggerType.phrase
              ? l10n.t('distressPhraseDetected')
              : l10n.t('screamDetected');
          return PremiumDialogSurface(
            title: triggerLabel,
            message: l10n.t('sosCountdownActiveMessage'),
            icon: Icons.record_voice_over_rounded,
            accentColor: const Color(0xFFE53935),
            actions: [
              TextButton(
                onPressed: () {
                  unawaited(
                    ref
                        .read(screamDetectionProvider.notifier)
                        .recordFalsePositive(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF172235)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: Text(l10n.t('notAnEmergency')),
              ),
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    ref
                        .read(screamDetectionProvider.notifier)
                        .confirmPendingDistress(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 179, 178),
                  foregroundColor: const Color.fromARGB(255, 232, 49, 49),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l10n.t('sendSosNow')),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  liveRegion: true,
                  label: l10n
                      .t('sosWillBeSentIn')
                      .replaceAll(
                        '{seconds}',
                        '${state.countdownSeconds}',
                      ),
                  child: Text(
                    l10n
                        .t('sosWillBeSentIn')
                        .replaceAll(
                          '{seconds}',
                          '${state.countdownSeconds}',
                        ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF23324A)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (state.lastDetectedPhrase != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n
                        .t('distressMatchedPhrase')
                        .replaceAll('{phrase}', state.lastDetectedPhrase!),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF516078)
                          : Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (state.lastScreamScore != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n
                        .t('distressScreamConfidence')
                        .replaceAll(
                          '{percent}',
                          '${(state.lastScreamScore! * 100).round()}',
                        ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF516078)
                          : Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
    _distressDialogVisible = false;
  }

  void _dismissDistressCountdownDialog() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) {
      _distressDialogVisible = false;
      return;
    }

    navigator.pop();
    _distressDialogVisible = false;
  }

  Future<void> _showRouteGuardCheckDialog() async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null || _routeGuardDialogVisible) return;

    _routeGuardDialogVisible = true;
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(routeSafetyProvider);
          final l10n = AppLocalizations.of(context);
          return PremiumDialogSurface(
            title: l10n.t('routeGuardDialogTitle'),
            message: l10n.t('routeGuardDialogMessage'),
            icon: Icons.alt_route_rounded,
            accentColor: const Color(0xFFE53935),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(routeSafetyProvider.notifier).markUserSafe();
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF172235)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: Text(l10n.t('imSafe')),
              ),
              ElevatedButton(
                onPressed: () {
                  unawaited(
                    ref
                        .read(routeSafetyProvider.notifier)
                        .requestEmergencyHelp(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 179, 178),
                  foregroundColor: const Color.fromARGB(255, 232, 49, 49),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l10n.t('routeGuardNeedHelp')),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  liveRegion: true,
                  label: l10n
                      .t('routeGuardConfirmWithin')
                      .replaceAll('{seconds}', '${state.countdownSeconds}'),
                  child: Text(
                    l10n
                        .t('routeGuardConfirmWithin')
                        .replaceAll('{seconds}', '${state.countdownSeconds}'),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF23324A)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (state.deviationMeters != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n
                        .t('routeGuardDeviationMeters')
                        .replaceAll(
                          '{meters}',
                          '${state.deviationMeters!.round()}',
                        ),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF516078)
                          : Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
    _routeGuardDialogVisible = false;
  }

  void _dismissRouteGuardCheckDialog() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) {
      _routeGuardDialogVisible = false;
      return;
    }

    navigator.pop();
    _routeGuardDialogVisible = false;
  }
}

class _AppLifecycleHandler extends WidgetsBindingObserver {
  final WidgetRef ref;
  final Future<void> Function() onResumed;

  _AppLifecycleHandler(this.ref, {required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(safetyMonitorProvider.notifier).start().catchError((_) {}),
      );
      unawaited(
        ref
            .read(impactDetectionProvider.notifier)
            .resumeIfEnabled()
            .catchError((_) {}),
      );
      unawaited(onResumed());
      unawaited(
        ref
            .read(screamDetectionProvider.notifier)
            .resumeIfEnabled()
            .catchError((_) {}),
      );
      unawaited(
        ref
            .read(routeSafetyProvider.notifier)
            .resumeIfEnabled()
            .catchError((_) {}),
      );
    }
  }
}
