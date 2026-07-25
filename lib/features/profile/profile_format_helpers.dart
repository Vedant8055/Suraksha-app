import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/features/routes/route_safety_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';

/// Pure helpers extracted from profile screen (Phase 2).
class ProfileFormatHelpers {
  ProfileFormatHelpers._();

  static String extractError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
      return error.message ?? l10nSync('networkRequestFailed');
    }
    if (error is ArgumentError) {
      return error.message?.toString() ?? l10nSync('invalidDetails');
    }
    return error.toString();
  }

  static String routeConfidenceKey(RouteSafetyState routeState) {
    if (routeState.intelligenceLimited ||
        (!routeState.hasLearnedRoute && routeState.routeLogCount < 2)) {
      return 'routeGuardConfidenceLow';
    }
    if (routeState.hasLearnedRoute && routeState.routeLogCount >= 5) {
      return 'routeGuardConfidenceHigh';
    }
    return 'routeGuardConfidenceMedium';
  }

  static String formatRouteLastChecked(Position position) {
    final at = position.timestamp;
    final local = at.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String formatRouteCountdown(AppLocalizations l10n, int seconds) {
    if (seconds <= 0) return 'now';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0 && remainingSeconds > 0) {
      return l10n
          .t('countdownMinutesSeconds')
          .replaceAll('{minutes}', '$minutes')
          .replaceAll('{seconds}', '$remainingSeconds');
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }
}
