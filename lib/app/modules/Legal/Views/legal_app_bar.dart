import 'package:fgtracker/app/global_widget/app_back_button.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Same look as the app's `reusableAppbar`, but the title wraps to two lines
/// so long document names ("Data Protection & Information Security Policy")
/// are not cut, and it does not depend on the global navigator context.
AppBar legalAppBar(BuildContext context, String title) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    toolbarHeight: 56.h,
    backgroundColor:
        isDark ? ToggleThemeData.darkThemeBackground : AppColors.darkBlue,
    scrolledUnderElevation: 0,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    surfaceTintColor: AppBarStyle.surfaceTintColor,
    leadingWidth: AppBarStyle.leadingWidth,
    leading: AppBarStyle.leading(
      onTap: () => Navigator.of(context).maybePop(),
    ),
    centerTitle: true,
    title: Text(
      title,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 17.sp,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
