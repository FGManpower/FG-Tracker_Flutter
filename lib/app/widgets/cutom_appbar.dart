import 'package:flutter/material.dart';
import 'package:fgtracker/app/global_widget/app_back_button.dart';
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
    scrolledUnderElevation: AppBarStyle.scrolledUnderElevation,
    surfaceTintColor: AppBarStyle.surfaceTintColor,
    leadingWidth: showBackButton ? AppBarStyle.leadingWidth : null,
    leading: showBackButton
        ? AppBarStyle.leading(onTap: onBackPressed ?? () => Get.back())
        : null,
    title: title != null
        ? reausabletext(
      title,
     color: Colors.black)

        : null,
  );
}
