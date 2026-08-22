/// Canonical ABO blood groups used across profile and medical vault.
class BloodGroupOptions {
  BloodGroupOptions._();

  static const List<String> all = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  /// Maps typed/legacy values like "O Positive" onto a canonical group.
  static String? match(String? raw) {
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return null;
    if (all.contains(trimmed)) return trimmed;

    var compact = trimmed.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    compact = compact
        .replaceAll('POSITIVE', '+')
        .replaceAll('NEGATIVE', '-')
        .replaceAll('POS', '+')
        .replaceAll('NEG', '-');
    if (all.contains(compact)) return compact;
    return null;
  }
}
