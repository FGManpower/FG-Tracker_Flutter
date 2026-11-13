import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final locales = GlobalMaterialLocalizations.delegate.supportedLocales
      .map((e) => e.languageCode)
      .toSet()
      .toList()
    ..sort();
  print('Supported language codes (${locales.length}):');
  print(locales);
  
  final indianCodes = ['hi', 'bn', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'ml', 'or', 'pa', 'as', 'ne', 'sd', 'sa', 'kok', 'mai', 'bho'];
  for (final c in indianCodes) {
    print('$c supported in Flutter: ${locales.contains(c)}');
  }
}

