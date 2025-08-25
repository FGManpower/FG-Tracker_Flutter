import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global_widget/common_widget.dart';

AppBar customAppBar({
  String? title,
  bool showBackButton = true,
  VoidCallback? onBackPressed,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,

    elevation: 0,
    leading: showBackButton
        ? IconButton(
      icon: Icon(Icons.arrow_back_ios, color: Colors.black),
      onPressed: onBackPressed ?? () => Get.back(),
    )
        : null,
    title: title != null
        ? reausabletext(
      title,
     color: Colors.black)

        : null,
  );
}
