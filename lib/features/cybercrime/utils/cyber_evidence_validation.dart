import 'dart:io';

class CyberEvidenceValidation {
  static const maxBytes = 10 * 1024 * 1024;
  static const maxSearchLength = 80;
  static const allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'pdf',
    'mp3',
    'wav',
    'm4a',
  };

  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
  static bool isAllowedType(String fileName) {
    final ext = extensionOf(fileName);
    return allowedExtensions.contains(ext);
  }

  static Future<int?> fileSizeBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.length();
    } catch (_) {
      return null;
    }
  }

  static String sanitizeSearch(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length <= maxSearchLength) return trimmed;
    return trimmed.substring(0, maxSearchLength);
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Returns a localization key when invalid, otherwise null.
  static Future<String?> validateFile({
    required String path,
    required String fileName,
  }) async {
    if (!isAllowedType(fileName)) return 'cyberEvidenceInvalidType';
    final size = await fileSizeBytes(path);
    if (size == null) return 'cyberEvidenceFileMissing';
    if (size > maxBytes) return 'fileTooLarge10Mb';
    if (size <= 0) return 'cyberEvidenceFileMissing';
    return null;
  }
}
