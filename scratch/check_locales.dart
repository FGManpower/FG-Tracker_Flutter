import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // Flutter provides `kMaterialSupportedLanguages` as the top-level Set<String>
  // of all language codes supported by GlobalMaterialLocalizations.
  final locales = kMaterialSupportedLanguages.toList()..sort();
  print('Supported language codes (${locales.length}):');
  print(locales);
  
  final indianCodes = [
    'hi', 'bn', 'te', 'mr', 'ta', 'ur', 'gu', 'kn', 'ml', 'or', 'pa', 'as',
    'ne', 'sd', 'sa', 'kok', 'mai', 'bho'
  ];
  for (final c in indianCodes) {
    final isSupported = GlobalMaterialLocalizations.delegate.isSupported(Locale(c));
    print('$c supported in Flutter: $isSupported');
  }
}

