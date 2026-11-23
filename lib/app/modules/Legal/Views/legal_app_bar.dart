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
  const Color purple = Color(0xFF5045B9);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    backgroundColor: isDark ? ToggleThemeData.darkThemeBackground : Colors.white,
    elevation: 1,
    scrolledUnderElevation: 1,
    surfaceTintColor: AppBarStyle.surfaceTintColor,
    shadowColor: purple.withValues(alpha: 0.1),
    centerTitle: false,
    iconTheme: const IconThemeData(color: purple),
    automaticallyImplyLeading: false,
    leadingWidth: AppBarStyle.leadingWidth,
    leading: AppBarStyle.leading(
      onTap: () => Navigator.of(context).maybePop(),
    ),
    title: Text(
      title,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
