class ActivityLogRedactor {
  ActivityLogRedactor._();

  static final _secretKeys = {
    'password',
    'newpassword',
    'oldpassword',
    'confirmpassword',
    'otp',
    'code',
    'token',
    'accesstoken',
    'refreshtoken',
    'authorization',
    'pin',
    'secret',
    'apikey',
    'emailverificationtoken',
  };

  static String scrubText(String input) {
    var text = input;
    text = text.replaceAll(
      RegExp(r'(password|otp|token|pin)\s*[:=]\s*\S+', caseSensitive: false),
      r'$1=[redacted]',
    );
    text = text.replaceAll(RegExp(r'\b\d{6}\b'), '[redacted]');
    return text.length > 400 ? '${text.substring(0, 400)}…' : text;
  }

  static Map<String, String> scrubMap(Map<String, String> input) {
    final out = <String, String>{};
    for (final entry in input.entries) {
      final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (_secretKeys.contains(key) || key.contains('password') || key.contains('token')) {
        out[entry.key] = '[redacted]';
      } else {
        out[entry.key] = scrubText(entry.value);
      }
    }
    return out;
  }
}
