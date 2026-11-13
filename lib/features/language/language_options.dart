import 'package:flutter/widgets.dart';

/// One language the app supports.
///
/// The picker strings (title, subtitle, search hint, button, no-match) are
/// stored here for every language so the Language screen can preview itself
/// in the tapped language instantly, before the app-wide locale changes.
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

  /// ISO 639 code, e.g. 'hi'. This is what is saved in "app_language".
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

  static const Set<String> _compiledL10nCodes = {
    'en', 'hi', 'mr', 'gu', 'kn', 'bn', 'ml', 'ta', 'te', 'pa', 'or',
    'es', 'fr', 'de', 'ar', 'pt', 'ja', 'zh'
  };

  /// True if this language has full compiled ARB strings and Flutter localizations.
  bool get hasCompiledL10n => _compiledL10nCodes.contains(code);

  /// Framework Locale for this language. If the language has fully compiled
  /// ARB/MaterialLocalizations, it uses its code; otherwise it safely maps
  /// to English so Flutter's Material widgets never throw missing delegate errors.
  Locale get locale =>
      _compiledL10nCodes.contains(code) ? Locale(code) : const Locale('en');

  /// Search: English name, native name, code, or a known alternate spelling.
  bool matches(String query) {
    final raw = query.trim();
    if (raw.isEmpty) return true;
    final q = raw.toLowerCase();
    return englishName.toLowerCase().contains(q) ||
        nativeName.toLowerCase().contains(q) ||
        nativeName.contains(raw) ||
        code == q ||
        aliases.any((a) => a.contains(q));
  }
}

/// Complete catalog of all world languages supported in Choose Your Language.
const List<LanguageOption> kAppLanguages = [
  LanguageOption(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    glyph: 'Aa',
    title: "Choose your language",
    subtitle: "You can change it anytime from the menu",
    searchHint: "Search language",
    continueLabel: "Continue",
    noResults: "No language found",
    languageLabel: "Language",
    aliases: ['english'],
  ),
  LanguageOption(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    glyph: 'हि',
    title: "अपनी भाषा चुनें",
    subtitle: "आप इसे कभी भी मेनू से बदल सकते हैं",
    searchHint: "भाषा खोजें",
    continueLabel: "आगे बढ़ें",
    noResults: "कोई भाषा नहीं मिली",
    languageLabel: "भाषा",
    aliases: ['hindi'],
  ),
  LanguageOption(
    code: 'mr',
    englishName: 'Marathi',
    nativeName: 'मराठी',
    glyph: 'म',
    title: "तुमची भाषा निवडा",
    subtitle: "तुम्ही ती कधीही मेनूमधून बदलू शकता",
    searchHint: "भाषा शोधा",
    continueLabel: "पुढे जा",
    noResults: "कोणतीही भाषा आढळली नाही",
    languageLabel: "भाषा",
    aliases: ['marathi'],
  ),
  LanguageOption(
    code: 'gu',
    englishName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    glyph: 'ગુ',
    title: "તમારી ભાષા પસંદ કરો",
    subtitle: "તમે મેનુમાંથી ગમે ત્યારે બદલી શકો છો",
    searchHint: "ભાષા શોધો",
    continueLabel: "આગળ વધો",
    noResults: "કોઈ ભાષા મળી નથી",
    languageLabel: "ભાષા",
    aliases: ['gujarati', 'gujrati'],
  ),
  LanguageOption(
    code: 'kn',
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    glyph: 'ಕ',
    title: "ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ",
    subtitle: "ಮೆನುವಿನಿಂದ ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಬದಲಾಯಿಸಬಹುದು",
    searchHint: "ಭಾಷೆ ಹುಡುಕಿ",
    continueLabel: "ಮುಂದುವರಿಯಿರಿ",
    noResults: "ಯಾವುದೇ ಭಾಷೆ ಕಂಡುಬಂದಿಲ್ಲ",
    languageLabel: "ಭಾಷೆ",
    aliases: ['kannada', 'kanada'],
  ),
  LanguageOption(
    code: 'bn',
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    glyph: 'বা',
    title: "আপনার ভাষা বেছে নিন",
    subtitle: "মেনু থেকে এটি যেকোনো সময় পরিবর্তন করতে পারেন",
    searchHint: "ভাষা খুঁজুন",
    continueLabel: "এগিয়ে যান",
    noResults: "কোনো ভাষা পাওয়া যায়নি",
    languageLabel: "ভাষা",
    aliases: ['bengali', 'bangla'],
  ),
  LanguageOption(
    code: 'ml',
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    glyph: 'മ',
    title: "നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക",
    subtitle: "ഇത് എപ്പോൾ വേണമെങ്കിലും മെനുവിൽ നിന്ന് മാറ്റാം",
    searchHint: "ഭാഷ തിരയുക",
    continueLabel: "തുടരുക",
    noResults: "ഭാഷയൊന്നും കണ്ടെത്തിയില്ല",
    languageLabel: "ഭാഷ",
    aliases: ['malayalam'],
  ),
  LanguageOption(
    code: 'ta',
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    glyph: 'த',
    title: "உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்",
    subtitle: "இதை எப்போது வேண்டுமானாலும் மெனுவில் இருந்து மாற்றலாம்",
    searchHint: "மொழியைத் தேடுக",
    continueLabel: "தொடரவும்",
    noResults: "எந்த மொழியும் கிடைக்கவில்லை",
    languageLabel: "மொழி",
    aliases: ['tamil'],
  ),
  LanguageOption(
    code: 'te',
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    glyph: 'తె',
    title: "మీ భాషను ఎంచుకోండి",
    subtitle: "మీరు దీన్ని ఎప్పుడైనా మెనూ నుండి మార్చవచ్చు",
    searchHint: "భాష వెతకండి",
    continueLabel: "కొనసాగించండి",
    noResults: "ఏ భాషా దొరకలేదు",
    languageLabel: "భాష",
    aliases: ['telugu'],
  ),
  LanguageOption(
    code: 'pa',
    englishName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    glyph: 'ਪੰ',
    title: "ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ",
    subtitle: "ਤੁਸੀਂ ਇਸਨੂੰ ਕਦੇ ਵੀ ਮੀਨੂ ਤੋਂ ਬਦਲ ਸਕਦੇ ਹੋ",
    searchHint: "ਭਾਸ਼ਾ ਖੋਜੋ",
    continueLabel: "ਅੱਗੇ ਵਧੋ",
    noResults: "ਕੋਈ ਭਾਸ਼ਾ ਨਹੀਂ ਮਿਲੀ",
    languageLabel: "ਭਾਸ਼ਾ",
    aliases: ['punjabi', 'panjabi'],
  ),
  LanguageOption(
    code: 'or',
    englishName: 'Odia',
    nativeName: 'ଓଡ଼ିଆ',
    glyph: 'ଓ',
    title: "ଆପଣଙ୍କର ଭାଷା ବାଛନ୍ତୁ",
    subtitle: "ଆପଣ ଏହାକୁ ମେନୁରୁ ଯେକୌଣସି ସମୟରେ ବଦଳାଇ ପାରିବେ",
    searchHint: "ଭାଷା ଖୋଜନ୍ତୁ",
    continueLabel: "ଆଗକୁ ବଢ଼ନ୍ତୁ",
    noResults: "କୌଣସି ଭାଷା ମିଳିଲା ନାହିଁ",
    languageLabel: "ଭାଷା",
    aliases: ['odia', 'oriya', 'odisa', 'odisha'],
  ),
  LanguageOption(
    code: 'es',
    englishName: 'Spanish',
    nativeName: 'Español',
    glyph: 'Es',
    title: "Elige tu idioma",
    subtitle: "Puedes cambiarlo en cualquier momento desde el menú",
    searchHint: "Buscar idioma",
    continueLabel: "Continuar",
    noResults: "No se encontró ningún idioma",
    languageLabel: "Idioma",
    aliases: ['spanish', 'espanol'],
  ),
  LanguageOption(
    code: 'fr',
    englishName: 'French',
    nativeName: 'Français',
    glyph: 'Fr',
    title: "Choisissez votre langue",
    subtitle: "Vous pouvez la modifier à tout moment dans le menu",
    searchHint: "Rechercher une langue",
    continueLabel: "Continuer",
    noResults: "Aucune langue trouvée",
    languageLabel: "Langue",
    aliases: ['french', 'francais'],
  ),
  LanguageOption(
    code: 'de',
    englishName: 'German',
    nativeName: 'Deutsch',
    glyph: 'De',
    title: "Wählen Sie Ihre Sprache",
    subtitle: "Sie können sie jederzeit im Menü ändern",
    searchHint: "Sprache suchen",
    continueLabel: "Weiter",
    noResults: "Keine Sprache gefunden",
    languageLabel: "Sprache",
    aliases: ['german', 'deutsch'],
  ),
  LanguageOption(
    code: 'ar',
    englishName: 'Arabic',
    nativeName: 'العربية',
    glyph: 'عر',
    title: "اختر لغتك",
    subtitle: "يمكنك تغييرها في أي وقت من القائمة",
    searchHint: "بحث عن لغة",
    continueLabel: "متابعة",
    noResults: "لم يتم العثور على أي لغة",
    languageLabel: "اللغة",
    aliases: ['arabic', 'arab', 'uae', 'dubai'],
  ),
  LanguageOption(
    code: 'pt',
    englishName: 'Portuguese',
    nativeName: 'Português',
    glyph: 'Pt',
    title: "Escolha seu idioma",
    subtitle: "Você pode alterá-lo a qualquer momento no menu",
    searchHint: "Pesquisar idioma",
    continueLabel: "Continuar",
    noResults: "Nenhum idioma encontrado",
    languageLabel: "Idioma",
    aliases: ['portuguese', 'portugues'],
  ),
  LanguageOption(
    code: 'ja',
    englishName: 'Japanese',
    nativeName: '日本語',
    glyph: '日',
    title: "言語を選択してください",
    subtitle: "メニューからいつでも変更できます",
    searchHint: "言語を検索",
    continueLabel: "次へ",
    noResults: "言語が見つかりません",
    languageLabel: "言語",
    aliases: ['japanese', 'nihongo'],
  ),
  LanguageOption(
    code: 'zh',
    englishName: 'Chinese (Simplified)',
    nativeName: '中文 (简体)',
    glyph: '中',
    title: "选择您的语言",
    subtitle: "您可以随时从菜单中更改它",
    searchHint: "搜索语言",
    continueLabel: "继续",
    noResults: "未找到语言",
    languageLabel: "语言",
    aliases: ['chinese', 'simplified', 'mandarin', 'zhongwen'],
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