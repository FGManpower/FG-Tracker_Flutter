import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: FontFamily.interRegular,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontFamily: FontFamily.interMedium, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 16, fontFamily: FontFamily.interRegular, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: 24, fontFamily: FontFamily.interBold, fontWeight: FontWeight.w700),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: FontFamily.interRegular,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontFamily: FontFamily.interMedium, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 16, fontFamily: FontFamily.interRegular, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: 24, fontFamily: FontFamily.interBold, fontWeight: FontWeight.w700),
    ),
  );
}
