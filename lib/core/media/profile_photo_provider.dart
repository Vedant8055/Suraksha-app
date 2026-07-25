import 'dart:io';

import 'package:flutter/material.dart';

/// Resolves profile photo URLs safely — never passes Windows paths to [NetworkImage].
ImageProvider<Object>? profilePhotoImageProvider(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;

  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    // Decode at a fixed size covering the ~58-120dp avatar usages at up to
    // 2x pixel ratio, instead of decoding the full-resolution source image.
    return ResizeImage(NetworkImage(value), width: 240, height: 240);
  }

  if (value.contains(':\\') || value.startsWith('/')) {
    try {
      final file = File(value);
      if (file.existsSync()) return FileImage(file);
    } catch (_) {
      return null;
    }
  }

  return null;
}

bool isValidRemotePhotoUrl(String? raw) {
  if (raw == null) return false;
  final value = raw.trim().toLowerCase();
  return value.startsWith('http://') || value.startsWith('https://');
}
