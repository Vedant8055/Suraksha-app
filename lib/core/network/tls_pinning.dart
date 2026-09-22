import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Release-only TLS pinning for the Suraksha production API host.
///
/// Pins are SHA-256 fingerprints of the *leaf* certificate DER (colon-hex).
/// Extra pins can be injected at build time:
/// `--dart-define=TLS_PIN_SHA256=AA:BB:...,CC:DD:...`
///
/// Emergency disable (hotfix only): `--dart-define=TLS_PINNING=false`
///
/// Rotate leaf pins BEFORE [activeLeafExpiresAt] (next CDN cert issue).
/// Android [network_security_config.xml] already pins the longer-lived GTS WE1
/// intermediate SPKI; Dio still validates the leaf until we can move fully to SPKI.
class TlsPinning {
  TlsPinning._();

  static const productionHost = 'suraksha-backend-gtdi.onrender.com';

  /// Known expiry of the active production leaf (UTC). Used for operator alerts.
  static final DateTime activeLeafExpiresAt =
      DateTime.utc(2026, 10, 22, 21, 54, 17);

  /// Production leaf certificates (onrender.com via GTS WE1). Keep the
  /// previous leaf during a rotation so either CDN edge certificate is valid.
  /// New release APKs must include each newly observed Render leaf before the
  /// old one expires.
  static const _builtinLeafFingerprints = <String>{
    // Active leaf, verified 2026-09-21 (expires 2026-10-22).
    '04:1E:C4:C6:9F:66:77:19:7B:4E:F1:C0:67:42:11:64:F4:B2:69:DA:27:F2:F5:30:29:2C:AB:BB:05:1F:C1:B1',
    // Previous leaf retained for a safe certificate transition.
    'B2:F6:50:F8:65:95:06:1C:84:DF:28:DB:E5:EF:8F:9E:97:43:B0:7E:27:F6:67:E3:8F:1E:00:96:4D:E0:1F:9A',
  };

  /// Google Trust Services WE1 intermediate SPKI (sha256/base64) for Android NSC.
  static const we1SpkiSha256Base64 = 'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=';

  static Set<String> get allowedLeafFingerprints {
    final pins = <String>{..._builtinLeafFingerprints};
    const extra = String.fromEnvironment('TLS_PIN_SHA256', defaultValue: '');
    if (extra.isNotEmpty) {
      for (final part in extra.split(',')) {
        final normalized = _normalizeFingerprint(part);
        if (normalized.isNotEmpty) pins.add(normalized);
      }
    }
    return pins;
  }

  static bool get isEnabled =>
      !kDebugMode &&
      const bool.fromEnvironment('TLS_PINNING', defaultValue: true);

  /// True when the active leaf is within [within] of expiry (or already past).
  static bool isLeafNearingExpiry({
    Duration within = const Duration(days: 21),
  }) {
    final now = DateTime.now().toUtc();
    return !activeLeafExpiresAt.isAfter(now.add(within));
  }

  static String fingerprintSha256(List<int> der) {
    final digest = sha256.convert(der);
    return digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }

  static String _normalizeFingerprint(String value) {
    final cleaned = value.trim().replaceAll(' ', '').toUpperCase();
    if (cleaned.isEmpty) return '';
    if (cleaned.contains(':')) return cleaned;
    final buf = StringBuffer();
    for (var i = 0; i < cleaned.length; i += 2) {
      if (i + 2 > cleaned.length) break;
      if (buf.isNotEmpty) buf.write(':');
      buf.write(cleaned.substring(i, i + 2));
    }
    return buf.toString();
  }

  /// Returns true when the certificate is acceptable for [host].
  static bool validateCertificate(
    X509Certificate? cert,
    String host,
    int port,
  ) {
    if (!isEnabled) return true;
    final normalizedHost = host.toLowerCase();
    if (normalizedHost != productionHost &&
        !normalizedHost.endsWith('.$productionHost')) {
      return true;
    }
    if (cert == null) return false;
    final fp = fingerprintSha256(cert.der);
    return allowedLeafFingerprints.contains(fp);
  }

  /// Applies the same release-only leaf pin check used by [NetworkManager].
  static void attachToDio(Dio dio) {
    if (kIsWeb) return;
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(),
      validateCertificate: (cert, host, port) {
        return validateCertificate(cert, host, port);
      },
    );
  }
}
