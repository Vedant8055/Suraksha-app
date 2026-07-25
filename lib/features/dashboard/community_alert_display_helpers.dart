import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alerts_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';

/// Pure display helpers for community / safety alerts (Phase 2 extract).
class CommunityAlertDisplayHelpers {
  CommunityAlertDisplayHelpers._();

  static List<SafetyCommunityAlert> resolveCommunityAlerts(
    SafetyMonitorState safetyState,
    CommunityAlertsState localAlertsState,
  ) {
    if (safetyState.communityAlerts.isNotEmpty) {
      return safetyState.communityAlerts;
    }
    return localAlertsState.alerts
        .map(mapLocalCommunityAlert)
        .toList(growable: false);
  }

  static SafetyCommunityAlert mapLocalCommunityAlert(CommunityAlertItem item) {
    final priority = switch (item.kind) {
      CommunityAlertKind.roadBlock => 'critical',
      CommunityAlertKind.lonelyRoad => 'caution',
      CommunityAlertKind.silentZone => 'caution',
      CommunityAlertKind.traffic => 'information',
      CommunityAlertKind.transport => 'information',
      CommunityAlertKind.lighting => 'information',
    };

    return SafetyCommunityAlert(
      category: item.title,
      priority: priority,
      distanceMeters: 0,
      timestamp: item.updatedAt,
      summary: item.detail,
      recommendedAction: l10nSync('communityAlertStayAwareFallback'),
    );
  }

  static String sanitizeCommunityAlertText(
    String value, {
    required AppLocalizations l10n,
  }) {
    var text = value.trim();
    if (text.isEmpty) return text;

    text = text.replaceAll(
      RegExp(
        r'\(?\s*\d+\s*/\s*100\s*\)?',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(
        r'\(?\s*\d+\s+pings?\s+in\s+\d+\s*(?:h|hr|hrs|hour|hours)\s*\)?',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(r'\s{2,}'),
      ' ',
    );
    text = text.replaceAll(RegExp(r'\s+([,.;:])'), r'$1');
    text = text.replaceAll(RegExp(r'\(\s*\)'), '');
    return l10n.localizeDynamic(text.trim());
  }

  static String labelForDataSource(
    AppLocalizations l10n,
    String dataSource,
  ) {
    return switch (dataSource) {
      'openstreetmap' => l10n.t('safetySourceOpenStreetMap'),
      'google' || 'google_maps' || 'google_places' =>
        l10n.t('safetySourceGoogle'),
      'sunset_api' => l10n.t('safetySourceSunset'),
      'crowd_aggregate' => l10n.t('safetySourceCrowd'),
      'suraksha_reports' => l10n.t('safetySourceSurakshaReports'),
      'suraksha_engine' => l10n.t('safetySourceSurakshaEngine'),
      'suraksha_community' => l10n.t('safetySourceSurakshaCommunity'),
      'regional_guidance' => l10n.t('safetySourceRegionalGuidance'),
      'grid_model' => l10n.t('safetySourceGridModel'),
      'open_data_district' => l10n.t('safetySourceOpenDataDistrict'),
      _ => dataSource.replaceAll('_', ' '),
    };
  }

  static String formatUpdatedAgo(AppLocalizations l10n, DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) {
      return '${l10n.t('safetyUpdatedAgo')} · ${l10n.t('timeJustNow')}';
    }
    if (diff.inMinutes < 60) {
      return '${l10n.t('safetyUpdatedAgo')} · ${l10n.t('timeMinutesAgo').replaceAll('{count}', '${diff.inMinutes}')}';
    }
    if (diff.inHours < 24) {
      return '${l10n.t('safetyUpdatedAgo')} · ${l10n.t('timeHoursAgo').replaceAll('{count}', '${diff.inHours}')}';
    }
    return '${l10n.t('safetyUpdatedAgo')} · ${l10n.t('timeDaysAgo').replaceAll('{count}', '${diff.inDays}')}';
  }

  static IconData iconForCommunityAlert(String priority, String category) {
    final c = category.toLowerCase();
    if (c.contains('police activity') ||
        c.contains('police station') ||
        c.contains('emergencyinfra')) {
      return Icons.local_police_rounded;
    }
    if (c.contains('hospital')) {
      return Icons.local_hospital_rounded;
    }
    if (c.contains('public transport') ||
        c.contains('transport network') ||
        c.contains('publictransport')) {
      return Icons.directions_bus_filled_rounded;
    }
    if (c.contains('safe route') ||
        c.contains('safer corridor') ||
        c.contains('communitysaferoute')) {
      return Icons.alt_route_rounded;
    }
    if (c.contains('incident') ||
        c.contains('theft') ||
        c.contains('verifiedincident') ||
        c.contains('gridrisk') ||
        c.contains('districtcrime')) {
      return Icons.warning_amber_rounded;
    }
    if (c.contains('lighting') ||
        c.contains('road light') ||
        c.contains('roadlighting')) {
      return Icons.lightbulb_rounded;
    }
    if (c.contains('crowd') || c.contains('pedestrian')) {
      return Icons.groups_rounded;
    }
    if (c.contains('areasafety') || c.contains('area safety')) {
      return Icons.shield_rounded;
    }
    if (c.contains('pedestrian')) {
      return Icons.directions_walk_rounded;
    }
    if (c.contains('construction')) {
      return Icons.construction_rounded;
    }
    if (c.contains('emergency response')) {
      return Icons.emergency_rounded;
    }
    if (c.contains('safety score')) {
      return Icons.shield_rounded;
    }
    if (c.contains('upcoming risk')) {
      return Icons.dangerous_rounded;
    }
    if (c.contains('support coverage') || c.contains('area incident')) {
      return Icons.info_rounded;
    }
    return priority == 'critical'
        ? Icons.warning_amber_rounded
        : Icons.notifications_active_rounded;
  }

  static Color colorForCommunityAlert(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFE53935);
      case 'caution':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
