import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Reading preferences for the detailed POSH Act guide.
class PoshGuideReadingPrefs {
  static const _fontScaleKey = 'posh_guide_font_scale_v1';
  static const _bookmarksKey = 'posh_guide_bookmarks_v1';

  static const minFontScale = 0.85;
  static const maxFontScale = 1.45;
  static const defaultFontScale = 1.0;

  Future<double> loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_fontScaleKey) ?? defaultFontScale;
    return value.clamp(minFontScale, maxFontScale).toDouble();
  }

  Future<void> saveFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      _fontScaleKey,
      scale.clamp(minFontScale, maxFontScale).toDouble(),
    );
  }

  Future<Set<int>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookmarksKey);
    if (raw == null || raw.isEmpty) return <int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <int>{};
      return decoded
          .map((item) => int.tryParse(item.toString()))
          .whereType<int>()
          .toSet();
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> saveBookmarks(Set<int> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = bookmarks.toList()..sort();
    await prefs.setString(_bookmarksKey, jsonEncode(sorted));
  }
}
