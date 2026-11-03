import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'colors.dart';

class Utils {
  void fluttertoast(
    String message, {
    ToastGravity gravitys = ToastGravity.BOTTOM,
    Toast toastlenght = Toast.LENGTH_SHORT,
    Color bgColor = AppColors.darkBlue,
    Color txtColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastlenght,
      gravity: gravitys,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor,
      textColor: txtColor,
      fontSize: 16.0,
    );
  }
}
