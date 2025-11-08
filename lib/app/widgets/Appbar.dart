import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../global_widget/common_widget.dart';

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
      backgroundColor: ToggleThemeData.Appcolor,
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        Obx(() => Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: IconButton(
            icon: CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(
                Utility.isNotNullEmptyOrFalse(controller.userData.value.profileImage)
                    ? "${ConstRes.aImageBaseUrl}${controller.userData.value.profileImage}"
                    : MyAppTheme.ProfilenotFoundImg,
              ),
              child: controller.userData.value.profileImage == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            onPressed: () {},
          ),
        )),
      ],
      title: reausabletext(
        "Dashboard",
        fontsize: 21,
        color: Colors.white,
        fontweight: FontWeight.bold,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          size: 33,
          color: Colors.white,
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