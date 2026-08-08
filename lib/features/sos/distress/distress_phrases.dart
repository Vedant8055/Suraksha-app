/// Offline distress phrases — English, Hindi, Marathi (Latin + Devanagari variants).
class DistressPhrases {
  DistressPhrases._();

  static const List<String> all = [
    // English
    'help',
    'help me',
    'help me please',
    'save me',
    'save me please',
    'someone help',
    'somebody help',
    'leave me',
    'leave me alone',
    'let me go',
    'stop it',
    'stop',
    'dont touch me',
    "don't touch me",
    'police',
    'call police',
    // Hindi (romanized)
    'bachao',
    'bachao mujhe',
    'mujhe bachao',
    'mujhe bachao please',
    'madad',
    'madad karo',
    'madad kariye',
    'chhodo',
    'chhodo mujhe',
    'mujhe chhodo',
    'mujhe chhod do',
    'chhod do',
    'bachao please',
    'help kar',
    'bachao muje',
    'muje bachao',
    // Hindi (Devanagari)
    'बचाओ',
    'मुझे बचाओ',
    'बचाओ मुझे',
    'मदद',
    'मदद करो',
    'छोड़ो',
    'मुझे छोड़ो',
    'छोड़ दो',
    // Marathi (romanized)
    'mala vachva',
    'mala vachava',
    'vachva',
    'vachava',
    'vachva mala',
    'vachava mala',
    'mala sod',
    'mala soda',
    'mala sodun de',
    'mala sodun dya',
    'mala sodaycha',
    'madat',
    'madat kara',
    // Marathi (Devanagari)
    'मला वाचवा',
    'वाचवा',
    'वाचवा मला',
    'मला सोड',
    'मला सोडा',
    'मला सोडून दे',
    'मदत',
    'मदत करा',
  ];

  static const List<String> speechLocales = [
    'en_IN',
    'en_US',
    'hi_IN',
    'mr_IN',
  ];

  /// Prioritize STT locale order based on app language.
  static List<String> speechLocalesForLanguage(String languageCode) {
    final code = languageCode.toLowerCase().split(RegExp(r'[_-]')).first;
    return switch (code) {
      'hi' => const ['hi_IN', 'en_IN', 'en_US', 'mr_IN'],
      'mr' => const ['mr_IN', 'hi_IN', 'en_IN', 'en_US'],
      _ => const ['en_IN', 'en_US', 'hi_IN', 'mr_IN'],
    };
  }
}
