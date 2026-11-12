import 'package:flutter/material.dart';

/// Design tokens for the Language screen and Settings sheet. Light theme only.
///
/// [primary] is the app's existing brand purple (#5D47F1, as in the side
/// menu) and [letterTile] the app's existing tile tint (#EDE9FE). The other
/// tints are #5D47F1 mixed over white at the stated strength.
class LanguageColors {
  LanguageColors._();

  static const Color primary = Color(0xFF5D47F1);
  static const Color letterTile = Color(0xFFEDE9FE);
  static const Color page = Color(0xFFF7F6FE); // 5% primary
  static const Color pageGlow = Color(0xFFE8E5FD); // 14% primary
  static const Color selectedCard = Color(0xFFF2F0FE); // 8% primary
  static const Color cardBorder = Color(0xFFE5E2FD); // 16% primary
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1C1730);
  static const Color textSecondary = Color(0xFF6B6480);
}

/// Animation duration for selection changes and the live-preview fade.
const Duration kLanguageAnim = Duration(milliseconds: 180);
