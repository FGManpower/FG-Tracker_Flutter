import 'package:flutter/cupertino.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

AppBar buildTrackAppBar(
  BuildContext context, {
  required String groupName,
  void Function()? onPressMembers,
  void Function()? onPressRefresh,
  void Function()? onPressTheme,
  void Function()? onSearch,
}) {
  return AppBar(
    backgroundColor: ToggleThemeData.darkPurple,
    elevation: 4,
    centerTitle: false,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      padding: EdgeInsets.zero,
      icon: Container(
        height: 33.w,
        width: 33.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ToggleThemeData.white,
            width: 2.w,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_outlined,
            color: ToggleThemeData.white,
            size: 24.sp,
          ),
        ),
      ),
    ),
    title: reausabletext(
      groupName,
      fontsize: 20,
      widths: 200,
      color: Colors.white,
      fontweight: FontWeight.bold,
    ),
    actions: [
      reausableIcon(
        icon: Icons.search,
        size: 28,
        color: ToggleThemeData.white,
        ontap: onSearch,
      ),
      SizedBox(width: 15.w),
      PopupMenuButton<String>(
        onSelected: (value) {},
        color: Colors.white,
        elevation: 5,
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        icon: Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 26.sp,
        ),
        itemBuilder: (context) => [
          popupItem(
            context: context,
            value: "members",
            icon: Icons.groups,
            text: "Members",
            onTap: onPressMembers,
          ),
          dividerMenuItem(),
          popupItem(
            context: context,
            value: "refresh_Maps",
            icon: Icons.refresh,
            text: "Refresh Map",
            onTap: onPressRefresh,
          ),
          dividerMenuItem(),
          popupItem(
            context: context,
            value: "theme",
            icon: Icons.layers,
            text: "Theme",
            onTap: onPressTheme,
          ),
        ],
      ),
      SizedBox(width: 10.w),
    ],
  );
}

PopupMenuItem<String> popupItem({
  required BuildContext context,
  required String value,
  required IconData icon,
  required String text,
  void Function()? onTap,
}) {
  return PopupMenuItem<String>(
    value: value,
    onTap: () {
      onTap?.call();
    },
    padding: EdgeInsets.symmetric(
      horizontal: 12.w,
      vertical: 8.h,
    ),
    child: Row(
      children: [
        Container(
          height: 32.h,
          width: 32.w,
          decoration: BoxDecoration(
            color: ToggleThemeData.darkPurple.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: ToggleThemeData.darkPurple,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

PopupMenuEntry<String> dividerMenuItem() {
  return PopupMenuItem(
    enabled: false,
    height: 1,
    padding: EdgeInsets.zero,
    child: Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 0),
      color: Colors.black.withValues(alpha: 0.15),
    ),
  );
}
