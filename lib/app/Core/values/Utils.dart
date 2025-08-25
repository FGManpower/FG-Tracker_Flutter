

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'colors.dart';


class Utils {
  void fluttertoast(String message,{ToastGravity gravitys=ToastGravity.BOTTOM,Toast toastlenght=Toast.LENGTH_SHORT}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravitys,
        timeInSecForIosWeb: 1,

        backgroundColor: AppColors.darkBlue,
        textColor: Colors.white,
        fontSize: 16.0);
  }


}
