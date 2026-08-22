import 'package:flutter/widgets.dart';

/// Human titles for screens logged as user activity (not Flutter route types).
class ActivityLogLabels {
  ActivityLogLabels._();

  static const widgetTitles = <String, String>{
    'SafetyMapScreen': 'Safety map',
    'CyberCrimeScreen': 'Cyber crime protection',
    'CyberLawDetailPage': 'Cyber crime learning topic',
    'POSHLegalPortalScreen': 'POSH portal',
    'POSHEducationScreen': 'POSH education',
    'POSHQuizScreen': 'POSH quiz',
    'POSHComplaintPrepScreen': 'POSH complaint prep',
    'POSHCertificateScreen': 'POSH certificate',
    'POSHActGuideScreen': 'POSH Act guide',
    'SurakshaAiChatScreen': 'Suraksha AI',
    'ProfileScreen': 'Profile',
    'MedicalVaultScreen': 'Medical vault',
    'NearbyCleanToiletsScreen': 'Nearby toilets',
    'NotificationsInboxScreen': 'Notifications',
    'EmergencyModeScreen': 'Emergency mode',
    'ActivityLogsScreen': 'Logs',
    'ReportDetailScreen': 'Cyber crime report',
  };

  static String? forWidget(Widget screen) {
    return widgetTitles[screen.runtimeType.toString()];
  }

  static String lineForEvent(String event, Map<String, String> details) {
    if (details['message']?.trim().isNotEmpty == true) {
      return details['message']!.trim();
    }
    switch (event) {
      case 'app_started':
        return 'App started';
      case 'logs_opened':
        return 'Logs opened';
      case 'logs_exported':
        return 'Logs exported';
      case 'login_success':
        return 'Signed in';
      case 'login_failed':
        return 'Sign-in failed';
      case 'signup_success':
        return 'Account created';
      case 'signup_failed':
        return 'Signup failed';
      case 'logout':
        return 'Signed out';
      case 'sos_triggered':
        return 'SOS triggered';
      case 'sos_cancelled':
        return 'SOS cancelled';
      case 'sos_blocked_no_contacts':
        return 'SOS blocked — no emergency contacts saved';
      case 'sos_sms_sent':
        return 'SOS messages sent';
      case 'profile_photo_updated':
        return 'Profile photo updated';
      case 'scream_detection_on':
        return 'Scream detection turned on';
      case 'scream_detection_off':
        return 'Scream detection turned off';
      case 'impact_detection_on':
        return 'Impact detection turned on';
      case 'impact_detection_off':
        return 'Impact detection turned off';
      case 'screen_opened':
        return '${details['screen'] ?? 'Screen'} opened';
      case 'screen_closed':
        return '${details['screen'] ?? 'Screen'} closed';
      default:
        return event
            .split('_')
            .where((part) => part.isNotEmpty)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join(' ');
    }
  }
}
