import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  final GlobalKey<ScaffoldState> scaffoldKey;
  final HomeController controller;
  final TrackingController trackingController;
  HomeAppBar({
    Key? key,
    required this.scaffoldKey,
    required this.controller,
    required this.trackingController,
  }) : super(key: key);
  final notificationController =
  Get.put(NotificationController());




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

          child: Row(
            children: [
              Obx(
                    () {
                  final bool isSharing = trackingController.isLocationSharing.value;

                  return Container(
                    height: 36.h,
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.only(
                      left: 8.w,
                      right: 4.w,
                    ),
                    decoration: BoxDecoration(
                      color: isSharing
                          ? Colors.green.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSharing
                              ? CupertinoIcons.location_fill
                              : CupertinoIcons.location_slash,
                          size: 15.sp,
                          color: isSharing
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),

                        SizedBox(width: 5.w),

                        Text(
                          isSharing ? 'Live' : 'Private',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isSharing
                                ? Colors.green.shade700
                                : Colors.grey.shade700,
                          ),
                        ),

                        SizedBox(width: 3.w),

                        Transform.scale(
                          scale: 0.72,
                          child: CupertinoSwitch(
                            value: isSharing,
                            activeTrackColor: Colors.green,
                            onChanged: (value) {
                              trackingController
                                  .toggleLocationSharing(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () {

                  Get.toNamed(
                    Routes.notificationScreen,
                  );
                },
                child: Obx(() {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Icon(
                        Icons.notifications_rounded,
                        size: 30.sp,
                        color: ToggleThemeData.Appcolor,
                      ),

                      if (notificationController.unreadCount.value > 0)
                        Positioned(
                          right: -2.w,
                          top: -2.h,

                          child: Container(

                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),

                            constraints: BoxConstraints(
                              minWidth: 18.w,
                              minHeight: 18.h,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.red,

                              borderRadius:
                              BorderRadius.circular(100.r),

                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.25),
                                  blurRadius: 6,
                                ),
                              ],
                            ),

                            child: Center(
                              child: Text(

                                notificationController
                                    .unreadCount.value > 99
                                    ? "99+"
                                    : notificationController
                                    .unreadCount.value
                                    .toString(),

                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),

            ],
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
  Size get preferredSize =>
      Size.fromHeight(55.h);
}