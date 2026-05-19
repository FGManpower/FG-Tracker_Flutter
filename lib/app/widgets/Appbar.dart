import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final HomeController controller;

  HomeAppBar({Key? key, required this.scaffoldKey, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      toolbarHeight: 50.h,
      backgroundColor: ToggleThemeData.white,
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [


        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.notificationScreen);
            },
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_sharp,
                  size: 30.sp,
                  color: ToggleThemeData.Appcolor,
                ),
                Visibility(
                  visible: true,
                  child: Positioned(
                      right: 0,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.r)),
                      )),
                )
              ],
            ),
          ),
        )
      ],
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 33.sp,
          color: ToggleThemeData.darkPurple,
        ),
        onPressed: () {
          if (scaffoldKey.currentState != null) {
            scaffoldKey.currentState!.openDrawer();
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(55.h);
}
