import 'package:flutter/material.dart';

/// Locale-aware display for user names.
///
/// Profile storage stays in the original script (usually Latin). For Hindi /
/// Marathi UI we phonetically render Latin names in Devanagari so greetings
/// match the selected language (e.g. Vedant → वेदांत).
class LocalizedDisplayName {
  LocalizedDisplayName._();

  static final RegExp _devanagari = RegExp(r'[\u0900-\u097F]');
  static final RegExp _latinWord = RegExp(r"[A-Za-z']+");

  /// Prefer explicit overrides for well-known Indian spellings.
  static const Map<String, String> _nameOverrides = {
    'vedant': 'वेदांत',
    'vedanta': 'वेदांत',
    'kulkarni': 'कुलकर्णी',
    'priya': 'प्रिया',
    'anita': 'अनीता',
    'anitaa': 'अनीता',
    'neha': 'नेहा',
    'pooja': 'पूजा',
    'puja': 'पूजा',
    'anjali': 'अंजलि',
    'sneha': 'स्नेहा',
    'kavita': 'कविता',
    'sunita': 'सुनीता',
    'meera': 'मीरा',
    'mira': 'मीरा',
    'radha': 'राधा',
    'sita': 'सीता',
    'geeta': 'गीता',
    'gita': 'गीता',
    'rita': 'रीता',
    'deepa': 'दीपा',
    'divya': 'दिव्या',
    'isha': 'ईशा',
    'aisha': 'आइशा',
    'ayesha': 'आयुषा',
    'fatima': 'फातिमा',
    'zara': 'जारा',
    'sara': 'सारा',
    'sarah': 'सारा',
    'aditi': 'अदिति',
    'ananya': 'अनन्या',
    'aarohi': 'आरोही',
    'arohi': 'आरोही',
    'kiara': 'कियारा',
    'riya': 'रिया',
    'shreya': 'श्रेया',
    'shruti': 'श्रुति',
    'swati': 'स्वाति',
    'tanvi': 'तन्वी',
    'trisha': 'त्रिशा',
    'vidya': 'विद्या',
    'lakshmi': 'लक्ष्मी',
    'laxmi': 'लक्ष्मी',
    'parvati': 'पार्वती',
    'savita': 'सविता',
    'rekha': 'रेखा',
    'usha': 'उषा',
    'nisha': 'निशा',
    'ramesh': 'रमेश',
    'suresh': 'सुरेश',
    'mahesh': 'महेश',
    'rajesh': 'राजेश',
    'amit': 'अमित',
    'rahul': 'राहुल',
    'rohit': 'रोहित',
    'vikram': 'विक्रम',
    'vikas': 'विकास',
    'vivek': 'विवेक',
    'ajay': 'अजय',
    'vijay': 'विजय',
    'sanjay': 'संजय',
    'ankit': 'अंकित',
    'ankita': 'अंकिता',
    'arjun': 'अर्जुन',
    'krishna': 'कृष्णा',
    'ram': 'राम',
    'shyam': 'श्याम',
    'mohan': 'मोहन',
    'gopal': 'गोपाल',
    'nilesh': 'निलेश',
    'ganesh': 'गणेश',
    'sachin': 'सचिन',
    'nikhil': 'निखिल',
    'nishant': 'निशांत',
    'pranav': 'प्रणव',
    'aditya': 'आदित्य',
    'aarya': 'आर्या',
    'arya': 'आर्य',
    'omkar': 'ओंकार',
    'om': 'ओम',
    'suraj': 'सूरज',
    'sooraj': 'सूरज',
    'manoj': 'मनोज',
    'manisha': 'मनीषा',
    'deepak': 'दीपक',
    'dipak': 'दीपक',
    'kiran': 'किरण',
    'komal': 'कोमल',
    'pallavi': 'पल्लवी',
    'prachi': 'प्राची',
    'rashmi': 'रश्मि',
    'seema': 'सीमा',
    'sima': 'सीमा',
    'sonali': 'सोनाली',
    'sushma': 'सुषमा',
    'varsha': 'वर्षा',
    'vaishnavi': 'वैष्णवी',
    'yash': 'यश',
    'yogesh': 'योगेश',
  };

  static String forLocale(String rawName, Locale locale) {
    final name = rawName.trim();
    if (name.isEmpty) return name;
    final code = locale.languageCode.toLowerCase();
    if (code != 'hi' && code != 'mr') return name;
    if (_devanagari.hasMatch(name)) return name;
    return name.replaceAllMapped(_latinWord, (match) {
      return _wordToDevanagari(match.group(0)!);
    });
  }

  static String _wordToDevanagari(String word) {
    final key = word.toLowerCase();
    final override = _nameOverrides[key];
    if (override != null) return override;
    final phonetic = _phoneticToDevanagari(key);
    if (phonetic.isEmpty) return word;
    return phonetic;
  }

  /// Longest-match romanization → Devanagari for Indian English spellings.
  static String _phoneticToDevanagari(String input) {
    const independentVowels = <String, String>{
      'aa': 'आ',
      'ai': 'ऐ',
      'au': 'औ',
      'ee': 'ई',
      'ii': 'ई',
      'oo': 'ऊ',
      'uu': 'ऊ',
      'ri': 'ऋ',
      'a': 'अ',
      'e': 'ए',
      'i': 'इ',
      'o': 'ओ',
      'u': 'उ',
    };

    const matras = <String, String>{
      'aa': 'ा',
      'ai': 'ै',
      'au': 'ौ',
      'ee': 'ी',
      'ii': 'ी',
      'oo': 'ू',
      'uu': 'ू',
      'ri': 'ृ',
      'a': '',
      'e': 'े',
      'i': 'ि',
      'o': 'ो',
      'u': 'ु',
    };

    // Longer keys first.
    const consonants = <String, String>{
      'chh': 'छ',
      'shh': 'ष',
      'kh': 'ख',
      'gh': 'घ',
      'ch': 'च',
      'jh': 'झ',
      'th': 'थ',
      'dh': 'ध',
      'ph': 'फ',
      'bh': 'भ',
      'sh': 'श',
      'ng': 'ङ',
      'ny': 'ञ',
      'k': 'क',
      'g': 'ग',
      'c': 'क',
      'j': 'ज',
      't': 'त',
      'd': 'द',
      'n': 'न',
      'p': 'प',
      'b': 'ब',
      'm': 'म',
      'y': 'य',
      'r': 'र',
      'l': 'ल',
      'v': 'व',
      'w': 'व',
      's': 'स',
      'h': 'ह',
      'f': 'फ',
      'z': 'ज़',
      'q': 'क़',
      'x': 'क्स',
    };

    final buffer = StringBuffer();
    var i = 0;
    var pendingConsonant = false;

    String? matchLongest(Map<String, String> table) {
      for (final entry in table.entries) {
        if (input.startsWith(entry.key, i)) return entry.key;
      }
      return null;
    }

    while (i < input.length) {
      final vowelKey = matchLongest(independentVowels);
      final consonantKey = matchLongest(consonants);

      if (vowelKey != null &&
          (consonantKey == null || vowelKey.length >= consonantKey.length)) {
        if (pendingConsonant) {
          buffer.write(matras[vowelKey]);
          pendingConsonant = false;
        } else {
          buffer.write(independentVowels[vowelKey]);
        }
        i += vowelKey.length;
        continue;
      }

      if (consonantKey != null) {
        if (pendingConsonant) {
          buffer.write('्');
        }
        buffer.write(consonants[consonantKey]);
        pendingConsonant = true;
        i += consonantKey.length;

        // Anusvara for n/m before another consonant (e.g. ant → आंत-like).
        if ((consonantKey == 'n' || consonantKey == 'm') &&
            i < input.length &&
            matchLongest(consonants) != null &&
            matchLongest(independentVowels) == null) {
          // Replace last consonant with anusvara form: drop न/म, write ं
          // Simpler: append ं after previous vowel context — rewrite last char.
          final text = buffer.toString();
          if (text.isNotEmpty) {
            buffer.clear();
            buffer.write(text.substring(0, text.length - 1));
            buffer.write('ं');
            pendingConsonant = false;
          }
        }
        continue;
      }

      // Unknown character — keep as-is.
      if (pendingConsonant) {
        buffer.write('्');
        pendingConsonant = false;
      }
      buffer.write(input[i]);
      i += 1;
    }

    if (pendingConsonant) {
      // Word-final consonant: keep inherent अ for name readability (वेदांत not वेदान्त्).
      // Do nothing — inherent schwa.
    }

    return buffer.toString();
  }
}
