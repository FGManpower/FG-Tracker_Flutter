import 'package:flutter/material.dart';
import '../deep_Link/Context_Utility.dart';

class MediaQueryHelper {
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;

  static BuildContext? get _context =>
      ContextUtility.navigatorkey.currentState?.context;

  static double width(double value, [BuildContext? context]) {
    final ctx = context ?? _context;
    if (ctx == null) return value;
    return MediaQuery.of(ctx).size.width * (value / _baseWidth);
  }

  static double height(double value, [BuildContext? context]) {
    final ctx = context ?? _context;
    if (ctx == null) return value;
    return MediaQuery.of(ctx).size.height * (value / _baseHeight);
  }

  static double font(double value, [BuildContext? context]) =>
      width(value, context);

  static double radius(double value, [BuildContext? context]) =>
      width(value, context);

  static EdgeInsets paddingAll(double value, [BuildContext? context]) =>
      EdgeInsets.all(width(value, context));

  static EdgeInsets paddingSymmetric({
    double vertical = 0,
    double horizontal = 0,
    BuildContext? context,
  }) =>
      EdgeInsets.symmetric(
        vertical: height(vertical, context),
        horizontal: width(horizontal, context),
      );

  static double icon(double value, [BuildContext? context]) =>
      width(value, context);

  static Size size(double w, double h, [BuildContext? context]) =>
      Size(width(w, context), height(h, context));

  static SizedBox gapH(double value, [BuildContext? context]) =>
      SizedBox(height: height(value, context));

  static SizedBox gapW(double value, [BuildContext? context]) =>
      SizedBox(width: width(value, context));
}
