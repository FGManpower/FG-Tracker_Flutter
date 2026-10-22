class VoiceLanguage {
  final String code; // e.g. en_IN, hi_IN
  final String name; // e.g. English, हिन्दी
  final String englishName;
  final bool isRtl;

  const VoiceLanguage({
    required this.code,
    required this.name,
    required this.englishName,
    this.isRtl = false,
  });

  String get shortCode {
    final parts = code.split(RegExp(r'[-_]'));
    if (parts.length >= 2) {
      return '${parts[0]}-${parts[1]}'.toUpperCase();
    }
    return code.toUpperCase();
  }
}

class VoiceLanguages {
  static const List<VoiceLanguage> supported = [
    VoiceLanguage(code: 'en_IN', name: 'English', englishName: 'English'),
    VoiceLanguage(code: 'hi_IN', name: 'हिन्दी', englishName: 'Hindi'),
    VoiceLanguage(code: 'mr_IN', name: 'मराठी', englishName: 'Marathi'),
    VoiceLanguage(code: 'gu_IN', name: 'ગુજરાતી', englishName: 'Gujarati'),
    VoiceLanguage(code: 'bn_IN', name: 'বাংলা', englishName: 'Bengali'),
    VoiceLanguage(code: 'ta_IN', name: 'தமிழ்', englishName: 'Tamil'),
    VoiceLanguage(code: 'te_IN', name: 'తెలుగు', englishName: 'Telugu'),
    VoiceLanguage(code: 'kn_IN', name: 'ಕನ್ನಡ', englishName: 'Kannada'),
    VoiceLanguage(code: 'pa_IN', name: 'ਪੰਜਾਬੀ', englishName: 'Punjabi'),
    VoiceLanguage(code: 'ur_IN', name: 'اردو', englishName: 'Urdu', isRtl: true),
  ];

  static VoiceLanguage defaultLanguage({String? appLanguageCode}) {
    if (appLanguageCode != null && appLanguageCode.isNotEmpty) {
      final lang = appLanguageCode.toLowerCase();
      for (final item in supported) {
        if (item.code.toLowerCase().startsWith(lang) ||
            item.englishName.toLowerCase() == lang) {
          return item;
        }
      }
    }
    return supported.first; // English
  }
}
