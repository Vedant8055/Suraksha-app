/// Detects language that suggests immediate personal danger in POSH notes.
class PoshDangerDetector {
  static const keywords = <String>[
    'immediate danger',
    'in danger',
    'unsafe now',
    'threat to life',
    'threatening me',
    'attack',
    'assault',
    'rape',
    'stalking',
    'following me',
    'weapon',
    'kill me',
    'going to hurt',
    'hurt me',
    'violence',
    'beating me',
    'locked in',
    'cannot leave',
    'trapped',
    'help me now',
    'call police',
    'emergency',
    // Hindi / Hinglish cues often typed in Latin script
    'jaan khatre',
    'khtra',
    'khatre mein',
    'abhi khatra',
    'maar dalega',
    'maarungi',
    'peecha',
  ];

  static bool mentionsImmediateDanger(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    for (final keyword in keywords) {
      if (normalized.contains(keyword)) return true;
    }
    return false;
  }
}
