import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  double get blockWidth => screenSize.width / 100;
  double get blockHeight => screenSize.height / 100;
}

//  width: context.blockWidth * 80,   // 80% width
//     height: context.blockHeight * 30, // 30% height