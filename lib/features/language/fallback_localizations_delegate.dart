import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ensures RTL languages not natively recognized by Flutter's GlobalWidgetsLocalizations
/// (sd, ks, bal, ug) resolve to TextDirection.rtl at runtime.
class RtlWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const RtlWidgetsLocalizationsDelegate();

  static const _rtlCodes = {
    'sd',
    'ks',
    'bal',
    'ug',
  };

  @override
  bool isSupported(Locale locale) => _rtlCodes.contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
      const _AppRtlWidgetsLocalizations(),
    );
  }

  @override
  bool shouldReload(RtlWidgetsLocalizationsDelegate old) => false;
}

class _AppRtlWidgetsLocalizations extends DefaultWidgetsLocalizations {
  const _AppRtlWidgetsLocalizations();

  @override
  TextDirection get textDirection => TextDirection.rtl;
}

/// Fallback Material delegate: provides default Material strings for locales
/// not natively bundled in Flutter's GlobalMaterialLocalizations.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(
      const DefaultMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback Cupertino delegate: provides default Cupertino strings for locales
/// not natively bundled in Flutter's GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(
      const DefaultCupertinoLocalizations(),
    );
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
