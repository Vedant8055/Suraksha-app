import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_labels.dart';
import 'package:suraksha_women_safety_app/features/ai_assistant/suraksha_ai_chat_screen.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/cybercrime_screen.dart';
import 'package:suraksha_women_safety_app/features/maps/safety_map_screen.dart';
import 'package:suraksha_women_safety_app/features/medical/medical_vault_screen.dart';
import 'package:suraksha_women_safety_app/features/notifications/notifications_inbox_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_chat_screen.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_screen.dart';
import 'package:suraksha_women_safety_app/features/sos/emergency_mode_screen.dart';
import 'package:suraksha_women_safety_app/features/toilets/nearby_clean_toilets_screen.dart';

/// Canonical route names used by deep links and [AppNavigator].
class AppRoutes {
  AppRoutes._();

  static const dashboard = 'dashboard';
  static const sos = 'sos';
  static const safetyMap = 'safety_map';
  static const cyber = 'cyber';
  static const posh = 'posh';
  static const surakshaAi = 'suraksha_ai';
  static const profile = 'profile';
  static const medicalVault = 'medical_vault';
  static const toilets = 'toilets';
  static const notificationsInbox = 'notifications_inbox';
  static const communityAlerts = 'community_alerts';
  static const profileNotifications = 'profile_notifications';

  /// Builds the screen for a known route name. Returns null for dashboard/home.
  static Widget? screenFor(String route, {Map<String, dynamic>? args}) {
    switch (route) {
      case sos:
        return const EmergencyModeScreen();
      case safetyMap:
        return SafetyMapScreen(
          initialTargetLatitude: args?['lat'] as double?,
          initialTargetLongitude: args?['lng'] as double?,
          initialTargetName: args?['name'] as String?,
        );
      case cyber:
        return const CyberCrimeScreen();
      case posh:
        return const POSHLegalPortalScreen();
      case surakshaAi:
        return const SurakshaAiChatScreen();
      case profile:
      case profileNotifications:
        return const ProfileScreen();
      case medicalVault:
        return const MedicalVaultScreen();
      case toilets:
        return const NearbyCleanToiletsScreen();
      case notificationsInbox:
        return const NotificationsInboxScreen();
      case dashboard:
      case communityAlerts:
        return null;
      default:
        return null;
    }
  }
}

/// Single navigation helper — wraps [Navigator] so call sites share one API.
class AppNavigator {
  AppNavigator._();

  static Future<T?> pushRoute<T extends Object?>(
    BuildContext context,
    String route, {
    Map<String, dynamic>? args,
    bool premiumTransition = false,
  }) {
    final screen = AppRoutes.screenFor(route, args: args);
    if (screen == null) {
      popToRoot(context);
      return Future<T?>.value(null);
    }
    return pushPremiumOrMaterial<T>(
      context,
      screen,
      premiumTransition: premiumTransition,
    );
  }

  static Future<T?> pushPremiumOrMaterial<T extends Object?>(
    BuildContext context,
    Widget screen, {
    bool premiumTransition = true,
  }) {
    if (!premiumTransition) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute<T>(
          settings: RouteSettings(name: _routeNameFor(screen)),
          builder: (_) => screen,
        ),
      );
    }
    return pushPremium<T>(context, screen);
  }

  static String? _routeNameFor(Widget screen) {
    return ActivityLogLabels.forWidget(screen);
  }

  /// Shared premium fade/slide transition used across the app.
  static Future<T?> pushPremium<T extends Object?>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        settings: RouteSettings(name: _routeNameFor(screen)),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 340),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
