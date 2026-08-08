/*
-------------------------------------------------------

Sentinel Evidence System (SES)

Module:
Experimental Feature

Purpose:
Emergency evidence collection architecture

Current Phase:
Feature Toggle & Settings (Phase 2)

Status:
TEST MODE

Safe Removal:
Delete sentinel_evidence folder and
remove Profile card integration.

-------------------------------------------------------
*/

/// In-module navigation for SES screens (named routes for isolation).
library;

import 'package:flutter/material.dart';

import '../constants/sentinel_routes.dart';
import '../screens/sentinel_hub_screen.dart';
import '../screens/sentinel_info_screen.dart';
import '../screens/sentinel_permission_status_screen.dart';
import '../screens/sentinel_permission_wizard_screen.dart';
import '../screens/sentinel_settings_screen.dart';
import '../screens/sentinel_status_screen.dart';
import '../screens/sentinel_vault_screen.dart';

class SentinelNavigator {
  const SentinelNavigator._();

  static Widget? screenFor(String route) {
    switch (route) {
      case SentinelRoutes.root:
        return const SentinelHubScreen();
      case SentinelRoutes.settings:
        return const SentinelSettingsScreen();
      case SentinelRoutes.vault:
        return const SentinelVaultScreen();
      case SentinelRoutes.info:
        return const SentinelInfoScreen();
      case SentinelRoutes.status:
        return const SentinelStatusScreen();
      case SentinelRoutes.permissions:
        return const SentinelPermissionStatusScreen();
      case SentinelRoutes.permissionWizard:
        return const SentinelPermissionWizardScreen();
      default:
        return null;
    }
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String route,
  ) {
    final screen = screenFor(route);
    if (screen == null) {
      return Future<T?>.value(null);
    }
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        settings: RouteSettings(name: route),
        builder: (_) => screen,
      ),
    );
  }
}
