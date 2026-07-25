import 'package:suraksha_women_safety_app/features/sos/distress/distress_phrases.dart';

class DistressMatchResult {
  final bool matched;
  final String? phrase;
  final String normalizedText;

  const DistressMatchResult({
    required this.matched,
    this.phrase,
    this.normalizedText = '',
  });
}

class DistressPhraseMatcher {
  static final _normalizedPhrases = DistressPhrases.all
      .map(_normalize)
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);

  /// Single-word phrases that must match as whole words (not substrings).
  static const _boundaryOnlyPhrases = {
    'help',
    'stop',
    'police',
    'bachao',
    'madad',
    'vachva',
    'vachava',
    'madat',
    'बचाओ',
    'मदद',
    'वाचवा',
    'मदत',
  };

  static DistressMatchResult match(String rawText) {
    final normalized = _normalize(rawText);
    if (normalized.isEmpty) {
      return const DistressMatchResult(matched: false);
    }

    for (final phrase in _normalizedPhrases) {
      if (_matchesPhrase(normalized, phrase)) {
        return DistressMatchResult(
          matched: true,
          phrase: phrase,
          normalizedText: normalized,
        );
      }
    }

    // Multi-word: all words present regardless of order (vachva mala ↔ mala vachva).
    for (final phrase in _normalizedPhrases) {
      if (!phrase.contains(' ')) continue;
      if (_containsAllWords(normalized, phrase.split(' '))) {
        return DistressMatchResult(
          matched: true,
          phrase: phrase,
          normalizedText: normalized,
        );
      }
    }

    return DistressMatchResult(matched: false, normalizedText: normalized);
  }

  static bool _matchesPhrase(String normalized, String phrase) {
    if (normalized == phrase) return true;

    if (_boundaryOnlyPhrases.contains(phrase)) {
      return _hasWholeWord(normalized, phrase);
    }

    if (normalized.contains(phrase)) return true;

    if (phrase.contains(' ')) {
      return _containsWordsInOrder(normalized, phrase.split(' '));
    }

    return _hasWholeWord(normalized, phrase);
  }

  static bool _hasWholeWord(String haystack, String word) {
    final pattern = RegExp(
      '(?:^|\\s)${RegExp.escape(word)}(?:\\s|\$)',
      unicode: true,
    );
    return pattern.hasMatch(haystack);
  }

  static String _normalize(String input) {
    var text = input.toLowerCase().trim();
    text = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    const corrections = <String, String>{
      'help mi': 'help me',
      'halp me': 'help me',
      'halp': 'help',
      'bachao muje': 'bachao mujhe',
      'bachao mujeh': 'bachao mujhe',
      'muje bachao': 'mujhe bachao',
      'mujeh bachao': 'mujhe bachao',
      'mujhe bachao': 'mujhe bachao',
      'mala vachava': 'mala vachva',
      'vachava mala': 'vachva mala',
      'vachva mla': 'vachva mala',
      'mala vachva': 'mala vachva',
      'mala sodaa': 'mala soda',
      'madad kro': 'madad karo',
      'madat kra': 'madat kara',
      'bachaw': 'bachao',
      'bachao mujheh': 'bachao mujhe',
    };

    for (final entry in corrections.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }

    return text.trim();
  }

  static bool _containsWordsInOrder(String haystack, List<String> needles) {
    var index = 0;
    for (final word in needles) {
      final found = haystack.indexOf(word, index);
      if (found < 0) return false;
      index = found + word.length;
    }
    return true;
  }

  static bool _containsAllWords(String haystack, List<String> needles) {
    if (needles.length < 2) return false;
    final words = haystack.split(' ').where((w) => w.isNotEmpty).toSet();
    return needles.every(words.contains);
  }
}
