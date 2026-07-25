import 'package:geolocator/geolocator.dart';
import 'package:suraksha_women_safety_app/config/feature_flags.dart';
import 'package:suraksha_women_safety_app/core/location/location_permission_service.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/features/sos/sos_sms_service.dart';

/// Thin SOS side-effects service (SMS + position) kept out of UI widgets.
class SosActionsService {
  SosActionsService({SOSSmsService? smsService})
      : _sms = smsService ?? SOSSmsService();

  final SOSSmsService _sms;

  Future<Position?> resolveSosPosition({Position? fallback}) {
    return LocationPermissionService.resolvePosition(
      preferred: fallback,
      accuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 8),
    );
  }

  Future<SmsDeliveryResult> sendEmergencySmsIfEnabled({
    required Position? position,
    required List<EmergencyContact> contacts,
    String? trackingUrl,
    String? senderName,
  }) async {
    if (!FeatureFlags.sosAutoSms) {
      return SmsDeliveryResult(total: contacts.length);
    }
    final url = FeatureFlags.publicLiveSharing ? trackingUrl : null;
    return _sms.sendEmergencySms(
      position,
      contacts: contacts,
      trackingUrl: url,
      senderName: senderName,
    );
  }

  String? sanitizeTrackingUrl(String? url) {
    if (!FeatureFlags.publicLiveSharing) return null;
    return url;
  }
}
