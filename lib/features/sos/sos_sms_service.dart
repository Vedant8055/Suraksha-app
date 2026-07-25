import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsDeliveryResult {
  const SmsDeliveryResult({
    required this.total,
    this.sentCount = 0,
    this.permissionDenied = false,
    this.composerOpened = false,
  });

  final int total;
  final int sentCount;
  final bool permissionDenied;
  final bool composerOpened;

  bool get anySent => sentCount > 0;
  bool get allSent => total > 0 && sentCount == total;
}

class SOSSmsService {
  static const MethodChannel _channel = MethodChannel('suraksha/sms');

  Future<SmsDeliveryResult> sendEmergencySms(
    Position? position, {
    required List<EmergencyContact> contacts,
    String? trackingUrl,
    String? senderName,
  }) async {
    return _sendStatusSms(
      contacts: contacts,
      senderName: senderName,
      position: position,
      trackingUrl: trackingUrl,
      template: _SmsTemplate.emergency,
    );
  }

  Future<SmsDeliveryResult> sendSafeSms(
    List<EmergencyContact> contacts, {
    String? senderName,
    Position? position,
  }) async {
    return _sendStatusSms(
      contacts: contacts,
      senderName: senderName,
      position: position,
      template: _SmsTemplate.safe,
    );
  }

  Future<SmsDeliveryResult> _sendStatusSms({
    required List<EmergencyContact> contacts,
    String? senderName,
    Position? position,
    String? trackingUrl,
    required _SmsTemplate template,
  }) async {
    final orderedContacts = [...contacts]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    final phoneNumbers = orderedContacts
        .map((contact) => EmergencyContact.normalizePhoneNumber(contact.phone))
        .where((phone) => phone.isNotEmpty)
        .toSet()
        .toList();
    if (phoneNumbers.isEmpty) return const SmsDeliveryResult(total: 0);

    // Android can send silently via native SMS; other platforms open the composer.
    if (!Platform.isAndroid) {
      return openEmergencyComposer(
        contacts: contacts,
        position: position,
        trackingUrl: trackingUrl,
        senderName: senderName,
        safe: template == _SmsTemplate.safe,
      );
    }

    final permission = await Permission.sms.request();
    if (!permission.isGranted) {
      return SmsDeliveryResult(
        total: phoneNumbers.length,
        permissionDenied: true,
      );
    }

    final senderLabel = senderName?.trim().isNotEmpty == true
        ? senderName!.trim()
        : 'Your contact';
    final locationSnippet = position != null
        ? '${l10nSync('smsLastKnownLocation', params: {'url': 'https://maps.google.com/?q=${position.latitude},${position.longitude}'})} Coordinates: ${position.latitude}, ${position.longitude}.'
        : '';

    final message = template == _SmsTemplate.emergency
        ? '$senderLabel is in danger. Please send help immediately. '
            '${trackingUrl == null ? '' : '${l10nSync('smsTrackLiveLocation', params: {'url': trackingUrl})} '}'
            '${position != null ? 'Current location: https://maps.google.com/?q=${position.latitude},${position.longitude}. Coordinates: ${position.latitude}, ${position.longitude}.' : ''}'
        : '$senderLabel is now safe. The emergency alert has been cleared. $locationSnippet';

    var sentCount = 0;
    for (final phoneNumber in phoneNumbers) {
      try {
        final raw = await _channel.invokeMethod<dynamic>('sendSms', {
          'phoneNumber': phoneNumber,
          'message': message,
        });
        final queued = raw == true ||
            (raw is Map && (raw['queued'] == true || raw['success'] == true));
        if (queued) sentCount++;
      } catch (_) {
        // Continue trying the remaining emergency contacts.
      }
    }

    return SmsDeliveryResult(
      total: phoneNumbers.length,
      sentCount: sentCount,
    );
  }

  Future<SmsDeliveryResult> openEmergencyComposer({
    required List<EmergencyContact> contacts,
    Position? position,
    String? trackingUrl,
    String? senderName,
    bool safe = false,
  }) async {
    final orderedContacts = [...contacts]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    final phoneNumbers = orderedContacts
        .map((contact) => EmergencyContact.normalizePhoneNumber(contact.phone))
        .where((phone) => phone.isNotEmpty)
        .toSet()
        .toList();
    if (phoneNumbers.isEmpty) return const SmsDeliveryResult(total: 0);

    final senderLabel = senderName?.trim().isNotEmpty == true
        ? senderName!.trim()
        : 'Your contact';
    final locationUrl = position == null
        ? null
        : 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    final message = safe
        ? '$senderLabel is now safe. The emergency alert has been cleared.'
            '${locationUrl == null ? '' : ' Last known location: $locationUrl'}'
        : '$senderLabel may be in danger. Please contact them and arrange help.'
            '${trackingUrl == null ? '' : ' Track live location: $trackingUrl'}'
            '${locationUrl == null ? '' : ' Current location: $locationUrl'}';
    final uri = Uri(
      scheme: 'sms',
      // Most SMS apps accept comma-separated recipients.
      path: phoneNumbers.join(','),
      queryParameters: {'body': message},
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return SmsDeliveryResult(
      total: phoneNumbers.length,
      sentCount: opened ? phoneNumbers.length : 0,
      composerOpened: opened,
    );
  }

  Future<bool> openTestComposer(EmergencyContact contact) async {
    final phone = EmergencyContact.normalizePhoneNumber(contact.phone);
    if (phone.isEmpty) return false;
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {
        'body':
            'Suraksha test alert: ${contact.name} is saved as an emergency contact. No emergency is active.',
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

enum _SmsTemplate { emergency, safe }
