import 'package:flutter/widgets.dart';

/// One language the app supports.
///
/// The picker strings (title, subtitle, search hint, button, no-match) are
/// stored here for every language so the Language screen can preview itself
/// in the tapped language instantly, before the app-wide locale changes.
///
/// This is the ONE place that lists the supported languages. To add or remove
/// a language, edit [kAppLanguages] (and, from Part 2 on, the matching
/// lib/l10n/app_<code>.arb file).
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.continueLabel,
    required this.noResults,
    required this.languageLabel,
    this.aliases = const [],
  });

  /// ISO 639-1 code, e.g. 'hi'. This is what is saved in "app_language".
  final String code;
  final String englishName;
  final String nativeName;

  /// Letter shown in the tile, in the language's own script.
  final String glyph;

  // Picker strings, written in this language.
  final String title;
  final String subtitle;
  final String searchHint;
  final String continueLabel;
  final String noResults;

  /// The word "Language" in this language (Settings row label).
  final String languageLabel;

  /// Extra spellings people may type in search (e.g. 'bangla'). Lower case.
  final List<String> aliases;

  Locale get locale => Locale(code);

  /// Search: English name, native name, code, or a known alternate spelling.
  bool matches(String query) {
    final raw = query.trim();
    if (raw.isEmpty) return true;
    final q = raw.toLowerCase();
    return englishName.toLowerCase().contains(q) ||
        nativeName.contains(raw) ||
        code == q ||
        aliases.any((a) => a.contains(q));
  }
}

/// Display order. The first entry (English) is the fallback language.
const List<LanguageOption> kAppLanguages = [
  LanguageOption(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    glyph: 'Aa',
    title: 'Choose your language',
    subtitle: 'You can change it anytime from the menu',
    searchHint: 'Search language',
    continueLabel: 'Continue',
    noResults: 'No language found',
    languageLabel: 'Language',
  ),
  LanguageOption(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    glyph: 'हि',
    title: 'अपनी भाषा चुनें',
    subtitle: 'आप इसे कभी भी मेनू से बदल सकते हैं',
    searchHint: 'भाषा खोजें',
    continueLabel: 'आगे बढ़ें',
    noResults: 'कोई भाषा नहीं मिली',
    languageLabel: 'भाषा',
    aliases: ['hindi'],
  ),
  LanguageOption(
    code: 'mr',
    englishName: 'Marathi',
    nativeName: 'मराठी',
    glyph: 'म',
    title: 'तुमची भाषा निवडा',
    subtitle: 'तुम्ही ती कधीही मेनूमधून बदलू शकता',
    searchHint: 'भाषा शोधा',
    continueLabel: 'पुढे जा',
    noResults: 'कोणतीही भाषा सापडली नाही',
    languageLabel: 'भाषा',
  ),
  LanguageOption(
    code: 'gu',
    englishName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    glyph: 'ગુ',
    title: 'તમારી ભાષા પસંદ કરો',
    subtitle: 'તમે તેને ગમે ત્યારે મેનૂમાંથી બદલી શકો છો',
    searchHint: 'ભાષા શોધો',
    continueLabel: 'આગળ વધો',
    noResults: 'કોઈ ભાષા મળી નથી',
    languageLabel: 'ભાષા',
    aliases: ['gujrati'],
  ),
  LanguageOption(
    code: 'kn',
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    glyph: 'ಕ',
    title: 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    subtitle: 'ನೀವು ಇದನ್ನು ಯಾವಾಗ ಬೇಕಾದರೂ ಮೆನುವಿನಿಂದ ಬದಲಾಯಿಸಬಹುದು',
    searchHint: 'ಭಾಷೆ ಹುಡುಕಿ',
    continueLabel: 'ಮುಂದುವರಿಸಿ',
    noResults: 'ಯಾವುದೇ ಭಾಷೆ ಸಿಗಲಿಲ್ಲ',
    languageLabel: 'ಭಾಷೆ',
    aliases: ['kanada'],
  ),
  LanguageOption(
    code: 'bn',
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    glyph: 'বা',
    title: 'আপনার ভাষা বেছে নিন',
    subtitle: 'আপনি যেকোনো সময় মেনু থেকে এটি বদলাতে পারবেন',
    searchHint: 'ভাষা খুঁজুন',
    continueLabel: 'এগিয়ে যান',
    noResults: 'কোনো ভাষা পাওয়া যায়নি',
    languageLabel: 'ভাষা',
    aliases: ['bangla'],
  ),
  LanguageOption(
    code: 'ml',
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    glyph: 'മ',
    title: 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക',
    subtitle: 'ഇത് എപ്പോൾ വേണമെങ്കിലും മെനുവിൽ നിന്ന് മാറ്റാം',
    searchHint: 'ഭാഷ തിരയുക',
    continueLabel: 'തുടരുക',
    noResults: 'ഭാഷയൊന്നും കണ്ടെത്തിയില്ല',
    languageLabel: 'ഭാഷ',
  ),
  LanguageOption(
    code: 'ta',
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    glyph: 'த',
    title: 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    subtitle: 'இதை எப்போது வேண்டுமானாலும் மெனுவில் இருந்து மாற்றலாம்',
    searchHint: 'மொழியைத் தேடுக',
    continueLabel: 'தொடரவும்',
    noResults: 'எந்த மொழியும் கிடைக்கவில்லை',
    languageLabel: 'மொழி',
  ),
  LanguageOption(
    code: 'te',
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    glyph: 'తె',
    title: 'మీ భాషను ఎంచుకోండి',
    subtitle: 'మీరు దీన్ని ఎప్పుడైనా మెనూ నుండి మార్చవచ్చు',
    searchHint: 'భాష వెతకండి',
    continueLabel: 'కొనసాగించండి',
    noResults: 'ఏ భాషా దొరకలేదు',
    languageLabel: 'భాష',
  ),
  LanguageOption(
    code: 'pa',
    englishName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    glyph: 'ਪੰ',
    title: 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ',
    subtitle: 'ਤੁਸੀਂ ਇਸਨੂੰ ਕਦੇ ਵੀ ਮੀਨੂ ਤੋਂ ਬਦਲ ਸਕਦੇ ਹੋ',
    searchHint: 'ਭਾਸ਼ਾ ਖੋਜੋ',
    continueLabel: 'ਅੱਗੇ ਵਧੋ',
    noResults: 'ਕੋਈ ਭਾਸ਼ਾ ਨਹੀਂ ਮਿਲੀ',
    languageLabel: 'ਭਾਸ਼ਾ',
    aliases: ['panjabi'],
  ),
];

/// Supported language codes, in display order.
final List<String> kAppLanguageCodes =
    kAppLanguages.map((o) => o.code).toList(growable: false);

/// Returns the option for [code], or null if [code] is not supported.
LanguageOption? languageForCode(String? code) {
  for (final option in kAppLanguages) {
    if (option.code == code) return option;
  }
  return null;
}

/// Returns the supported language for [locale], or English if unsupported.
LanguageOption languageFor(Locale? locale) =>
    languageForCode(locale?.languageCode) ?? kAppLanguages.first;
