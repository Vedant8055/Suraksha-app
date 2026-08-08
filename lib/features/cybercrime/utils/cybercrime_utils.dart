import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/features/auth/auth_provider.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:suraksha_women_safety_app/core/network/backend_url_resolver.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/cybercrime_constants.dart';
import 'package:suraksha_women_safety_app/features/cybercrime/models/cybercrime_models.dart';

void showCyberSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Future<bool> handleCyberAuthError(
  BuildContext context,
  Object? ref,
  DioException error, {
  String? requestPath,
  bool redirectToLogin = true,
}) async {
  if (error.response?.statusCode != 401) return false;
  if (ref is WidgetRef) {
    await ref.read(authProvider.notifier).logout();
  }
  if (redirectToLogin && context.mounted) {
    final l10n = AppLocalizations.of(context);
    showCyberSnack(context, l10n.t('authSessionExpired'));
  }
  return true;
}

Future<bool> showCyberAuthExpiredBanner(
  BuildContext context,
  DioException error, {
  String? requestPath,
}) async {
  if (error.response?.statusCode != 401) return false;
  return true;
}

String friendlyCyberError(BuildContext context, DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;
  String? message;
  if (data is Map) {
    message = data['message']?.toString();
  } else if (data is List<int>) {
    try {
      final decoded = jsonDecode(String.fromCharCodes(data));
      if (decoded is Map) message = decoded['message']?.toString();
    } catch (_) {}
  } else if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        message = decoded['message']?.toString();
      } else {
        message = data;
      }
    } catch (_) {
      message = data;
    }
  }
  if (message == null || message.isEmpty) {
    message = error.message;
  }
  if (message != null && message.isNotEmpty) {
    final lower = message.toLowerCase();
    if (lower.contains('evidence file not found') ||
        lower.contains('file not found')) {
      return AppLocalizations.of(context).t('cyberEvidenceServerMissing');
    }
    if (lower.contains('decrypt')) {
      return AppLocalizations.of(context).t('cyberEvidenceDecryptFailed');
    }
    // Prefer server message when it is already human-readable.
    if (!lower.contains('dioexception') && !lower.startsWith('http')) {
      return message;
    }
  }
  final l10n = AppLocalizations.of(context);
  if (status == 401) return l10n.t('networkServerIssue');
  if (status == 404) return l10n.t('cyberEvidenceServerMissing');
  if (status == 413) return l10n.t('fileTooLarge10Mb');
  if (status == 422) return l10n.t('cyberEvidenceDecryptFailed');
  if (BackendUrlResolver.isConnectionError(error)) {
    return l10n.t('cannotReachServer');
  }
  return l10n.t('networkServerIssue');
}

ScamAnalysisResult localAnalyze(
  String text,
  String question,
  List<String> links,
) {
  final input = '$text $question ${links.join(' ')}'.toLowerCase();
  var score = 0;
  final reasons = <String>[];
  if (RegExp(r'otp|password|pin|cvv').hasMatch(input)) {
    score += 35;
    reasons.add('cyberReasonCredentialRequest');
  }
  if (RegExp(r'upi|refund|kyc|account.*block').hasMatch(input)) {
    score += 25;
    reasons.add('cyberReasonPaymentPressure');
  }
  if (RegExp(r'blackmail|morphed|leak|viral').hasMatch(input)) {
    score += 35;
    reasons.add('cyberReasonBlackmail');
  }
  final level = score >= 45
      ? 'HIGH'
      : score >= 20
      ? 'MEDIUM'
      : 'LOW';
  return ScamAnalysisResult(
    riskLevel: level,
    threatSummary: reasons.isEmpty
        ? 'cyberThreatNoIndicators'
        : reasons.join(' '),
    recommendedActions: const [
      'cyberActionNoOtp',
      'cyberActionSaveEvidence',
      'cyberActionVerifyOfficial',
    ],
    safetyTips: const [
      'cyberTipNeverPayBlackmail',
      'cyberTipReport1930',
      'cyberTipBlockSenders',
    ],
    analysisSource: 'offline-heuristic',
  );
}

Future<void> shareReportPdf(
  BuildContext context,
  CyberReportResult report,
) async {
  final encoded = report.pdfBase64;
  if (encoded == null || encoded.isEmpty) {
    showCyberSnack(
      context,
      AppLocalizations.of(context).t('reportSummaryUnavailable'),
    );
    return;
  }
  try {
    final bytes = base64Decode(encoded);
    final dir = await getTemporaryDirectory();
    final safeId = report.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final file = File('${dir.path}/suraksha_cyber_complaint_$safeId.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/pdf',
          name: file.uri.pathSegments.last,
        ),
      ],
      subject: AppLocalizations.of(context).t('cyberShareComplaintSubject'),
      text: AppLocalizations.of(context).t('cyberShareComplaintBody'),
    );
  } catch (_) {
    if (context.mounted) {
      showCyberSnack(
        context,
        AppLocalizations.of(context).t('couldNotSharePdf'),
      );
    }
  }
}

Future<void> shareDownloadedEvidence(
  BuildContext context,
  DownloadedEvidence downloaded,
) async {
  final dir = await getTemporaryDirectory();
  final safeName = downloaded.fileName.replaceAll(RegExp(r'[^\w.-]+'), '_');
  final file = File('${dir.path}/$safeName');
  await file.writeAsBytes(downloaded.bytes, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: downloaded.mimeType, name: safeName)],
    subject: AppLocalizations.of(context).t('cyberShareEvidenceSubject'),
    text: AppLocalizations.of(context).t('cyberShareEvidenceBody'),
  );
}

Future<void> shareVaultExport(
  BuildContext context,
  Map<String, dynamic> payload,
) async {
  try {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/suraksha_evidence_package_$stamp.json');
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(payload), flush: true);
    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'application/json',
          name: file.uri.pathSegments.last,
        ),
      ],
      subject: AppLocalizations.of(context).t('cyberSharePackageSubject'),
      text: AppLocalizations.of(context).t('cyberSharePackageBody'),
    );
  } catch (_) {
    if (context.mounted) {
      showCyberSnack(
        context,
        AppLocalizations.of(context).t('couldNotExportEvidence'),
      );
    }
  }
}

Future<bool> requestGalleryPermission() async {
  final status = await Permission.photos.request();
  if (status.isGranted) return true;
  final storage = await Permission.storage.request();
  return storage.isGranted;
}

Future<bool> requestStoragePermission() async {
  final photos = await Permission.photos.request();
  if (photos.isGranted) return true;
  final storage = await Permission.storage.request();
  return storage.isGranted;
}

DeepfakeResources fallbackDeepfakeResourcesFor(AppLocalizations l10n) {
  return DeepfakeResources(
    title: l10n.t('deepfakeTitle'),
    sections: [
      InfoSection(
        title: l10n.t('deepfakeSectionWhatTitle'),
        body: l10n.t('deepfakeSectionWhatBody'),
      ),
      InfoSection(
        title: l10n.t('deepfakeSectionDoTitle'),
        body: l10n.t('deepfakeSectionDoBody'),
      ),
      InfoSection(
        title: l10n.t('deepfakeSectionEvidenceTitle'),
        body: l10n.t('deepfakeSectionEvidenceBody'),
      ),
    ],
    helplines: [
      HelplineEntry(label: l10n.t('helplineCyberCrime'), value: '1930'),
      HelplineEntry(label: l10n.t('helplinePoliceEmergency'), value: '100'),
    ],
  );
}

final fallbackDeepfakeResources = fallbackDeepfakeResourcesFor(
  AppLocalizations(const Locale('en')),
);

String localizedReportCategory(BuildContext context, String category) {
  return AppLocalizations.of(
    context,
  ).t(CybercrimeConstants.reportCategoryKey(category));
}

String formatReportCategories(
  BuildContext context,
  CyberReportListItem report,
) {
  return report.allCategories
      .map((category) => localizedReportCategory(context, category))
      .join(' • ');
}

String reportStatusLocalizationKey(CyberReportListItem report) {
  if (report.isDraft) return 'reportStatusDraft';
  switch (report.status) {
    case 'Under Investigation':
      return 'reportStatusUnderInvestigation';
    case 'Resolved':
      return 'reportStatusResolved';
    default:
      return 'reportStatusReported';
  }
}

String localizedReportStatus(BuildContext context, CyberReportListItem report) {
  return AppLocalizations.of(context).t(reportStatusLocalizationKey(report));
}

Color reportStatusColor(CyberReportListItem report) {
  if (report.isDraft) return const Color(0xFFEAB308);
  switch (report.status) {
    case 'Under Investigation':
      return const Color(0xFFF97316);
    case 'Resolved':
      return const Color(0xFF15803D);
    default:
      return const Color(0xFF2563EB);
  }
}

bool reportFiledOnPortal(CyberReportListItem report) {
  final ack = report.portalAcknowledgementNumber?.trim() ?? '';
  return ack.isNotEmpty;
}

String localizedEvidenceCategory(BuildContext context, String category) {
  return AppLocalizations.of(
    context,
  ).t(CybercrimeConstants.evidenceCategoryKey(category));
}

Future<void> dialPhoneNumber(String number) async {
  await launchUrl(
    Uri(scheme: 'tel', path: number),
    mode: LaunchMode.externalApplication,
  );
}

Future<void> openExternalLink(String link) async {
  await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
}
