class ScamAnalysisResult {
  final String riskLevel;
  final String threatSummary;
  final List<String> recommendedActions;
  final List<String> safetyTips;
  final String? extractedText;
  final String? analysisSource;

  const ScamAnalysisResult({
    required this.riskLevel,
    required this.threatSummary,
    required this.recommendedActions,
    required this.safetyTips,
    this.extractedText,
    this.analysisSource,
  });

  factory ScamAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ScamAnalysisResult(
      riskLevel: json['riskLevel']?.toString() ?? 'LOW',
      threatSummary: json['threatSummary']?.toString() ?? 'No summary available.',
      recommendedActions: (json['recommendedActions'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      safetyTips: (json['safetyTips'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      extractedText: json['extractedText']?.toString(),
      analysisSource: json['analysisSource']?.toString(),
    );
  }
}

class CyberReportResult {
  final String id;
  final String firStyleReport;
  final String? pdfBase64;

  const CyberReportResult({
    required this.id,
    required this.firStyleReport,
    this.pdfBase64,
  });

  factory CyberReportResult.fromJson(Map<String, dynamic> json) {
    return CyberReportResult(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firStyleReport:
          json['firStyleReport']?.toString() ??
          json['complaintSummary']?.toString() ??
          'Report generated.',
      pdfBase64: json['pdfBase64']?.toString(),
    );
  }
}

class CyberReportListItem {
  final String id;
  final String category;
  final List<String> categories;
  final String description;
  final bool isDraft;
  final String status;
  final String? portalAcknowledgementNumber;
  final DateTime? filedOnPortalAt;
  final String? firStyleReport;
  final String? pdfBase64;
  final DateTime createdAt;

  const CyberReportListItem({
    required this.id,
    required this.category,
    this.categories = const [],
    required this.description,
    required this.isDraft,
    required this.status,
    this.portalAcknowledgementNumber,
    this.filedOnPortalAt,
    this.firStyleReport,
    this.pdfBase64,
    required this.createdAt,
  });

  List<String> get allCategories {
    if (categories.isNotEmpty) return categories;
    if (category.trim().isNotEmpty) return [category];
    return const ['Cyber Report'];
  }

  factory CyberReportListItem.fromJson(Map<String, dynamic> json) {
    final rawCategories = (json['categories'] as List? ?? const [])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
    final primaryCategory = json['category']?.toString() ?? 'Cyber Report';
    return CyberReportListItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      category: primaryCategory,
      categories: rawCategories.isNotEmpty ? rawCategories : [primaryCategory],
      description: json['description']?.toString() ?? '',
      isDraft: json['isDraft'] == true,
      status: json['status']?.toString() ?? 'Reported',
      portalAcknowledgementNumber:
          json['portalAcknowledgementNumber']?.toString(),
      filedOnPortalAt: DateTime.tryParse(
        json['filedOnPortalAt']?.toString() ?? '',
      ),
      firStyleReport: json['firStyleReport']?.toString(),
      pdfBase64: json['pdfBase64']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class CyberReportDetail {
  final CyberReportListItem report;
  final List<EvidenceItem> evidence;

  const CyberReportDetail({
    required this.report,
    required this.evidence,
  });

  factory CyberReportDetail.fromJson(Map<String, dynamic> json) {
    final reportJson = json['report'];
    final evidenceJson = json['evidence'];
    return CyberReportDetail(
      report: CyberReportListItem.fromJson(
        reportJson is Map
            ? Map<String, dynamic>.from(reportJson)
            : Map<String, dynamic>.from(json),
      ),
      evidence: evidenceJson is List
          ? evidenceJson
              .whereType<Map>()
              .map((item) => EvidenceItem.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class EvidenceItem {
  final String id;
  final String title;
  final String category;
  final bool encrypted;
  final bool privateMode;
  final DateTime uploadedAt;
  final List<String> tags;
  final String? fileType;
  final String? reportId;
  final String? reportCategory;

  const EvidenceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.encrypted,
    required this.privateMode,
    required this.uploadedAt,
    required this.tags,
    this.fileType,
    this.reportId,
    this.reportCategory,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    return EvidenceItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ?? 'Evidence',
      category: json['category']?.toString() ?? 'Other',
      encrypted: json['encrypted'] != false,
      privateMode: json['privateMode'] == true,
      uploadedAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      tags: (json['tags'] as List? ?? const []).map((item) => item.toString()).toList(),
      fileType: json['fileType']?.toString(),
      reportId: json['reportId']?.toString(),
      reportCategory: json['reportCategory']?.toString(),
    );
  }
}

class DownloadedEvidence {
  final List<int> bytes;
  final String fileName;
  final String mimeType;

  const DownloadedEvidence({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
}

class DeepfakeResources {
  final String title;
  final List<InfoSection> sections;
  final List<HelplineEntry> helplines;

  const DeepfakeResources({
    required this.title,
    required this.sections,
    this.helplines = const [],
  });

  factory DeepfakeResources.fromJson(Map<String, dynamic> json) {
    return DeepfakeResources(
      title: json['title']?.toString() ?? 'Deepfake Awareness',
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => InfoSection.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      helplines: (json['helplines'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => HelplineEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class HelplineEntry {
  final String label;
  final String value;

  const HelplineEntry({required this.label, required this.value});

  factory HelplineEntry.fromJson(Map<String, dynamic> json) {
    return HelplineEntry(
      label: json['label']?.toString() ?? 'Helpline',
      value: json['value']?.toString() ?? '',
    );
  }
}

class InfoSection {
  final String title;
  final String body;

  const InfoSection({required this.title, required this.body});

  factory InfoSection.fromJson(Map<String, dynamic> json) {
    return InfoSection(
      title: json['title']?.toString() ?? 'Information',
      body: json['body']?.toString() ?? '',
    );
  }
}
