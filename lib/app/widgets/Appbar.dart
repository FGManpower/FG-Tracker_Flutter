import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class _Palette {
  static const Color ink = Color(0xFF10153D);
  static const Color muted = Color(0xFF59639A);
  static const Color purple = Color(0xFF6757E8);
  static const Color green = Color(0xFF16A765);
  static const Color pillLive = Color(0xFFEAF8EF);
  static const Color pillBorderLive = Color(0xFFD5EFDE);
  static const Color pillPrivate = Color(0xFFF4F4F7);
  static const Color pillBorderPrivate = Color(0xFFE8E8ED);
  static const Color textLive = Color(0xFF16804F);
  static const Color textPrivate = Color(0xFF686B78);
  static const Color dotPrivate = Color(0xFF9699A8);
  static const Color bellInk = Color(0xFF10132F);
  static const Color bellBorder = Color(0xFFE8EAF1);
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeAppBar({
    super.key,
    required this.scaffoldKey,
    required this.controller,
    required this.trackingController,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final HomeController controller;
  final TrackingController trackingController;
  final NotificationController notificationController =
  Get.put(NotificationController());

  @override
  Size get preferredSize => Size.fromHeight(65.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 65.h,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 70.w,
      leading:Obx(() {
        final String? profileImage = controller.userData.value.profileImage;
        final bool hasImage = Utility.isNotNullEmptyOrFalse(profileImage);
        return Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: GestureDetector(
            onTap: () {
              if (scaffoldKey.currentState != null) {

                scaffoldKey.currentState!.openDrawer();

              }
            },
            // onTap: () => Get.toNamed(Routes.Register, arguments: {
            //   "type": "Update",
            //   "userData": controller.userData.value,
            // }),
            child: SizedBox(
              width: 52.w,
              height: 52.w,
              child: Stack(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: hasImage
                          ? '${ConstRes.aImageBaseUrl}$profileImage'
                          : MyAppTheme.ProfilenotFoundImg,
                      width: 52.w,
                      height: 52.w,
                      fit: BoxFit.cover,

                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 12,
                    child: Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      titleSpacing: 0,
      title: _WelcomeTitle(controller: controller),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 14.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LocationStatus(trackingController: trackingController),
              SizedBox(width: 10.w),
              _NotificationBell(notificationController: notificationController),
            ],
          ),
        ),
      ],
    );
  }
}


class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String name = controller.userData.value.name ?? '';
      return Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back, $name! 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.interSemiBold,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _Palette.ink,
                height: 1.25,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Manage your groups easily',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.interRegular,
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
                color: _Palette.muted,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({required this.trackingController});

  final TrackingController trackingController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSharing = trackingController.isLocationSharing.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 34.h,
        padding: EdgeInsets.only(left: 9.w, right: 4.w),
        decoration: BoxDecoration(
          color: isSharing ? _Palette.pillLive : _Palette.pillPrivate,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSharing
                ? _Palette.pillBorderLive
                : _Palette.pillBorderPrivate,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSharing ? _Palette.green : _Palette.dotPrivate,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              isSharing ? 'Live' : 'Private',
              style: TextStyle(
                fontFamily: FontFamily.interSemiBold,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: isSharing ? _Palette.textLive : _Palette.textPrivate,
                height: 1,
              ),
            ),
            SizedBox(width: 2.w),
            SizedBox(
              width: 40.w,
              height: 24.h,
              child: FittedBox(
                alignment: Alignment.centerRight,
                child: Transform.scale(
                  scale: 0.58,
                  child: CupertinoSwitch(
                    value: isSharing,
                    activeTrackColor: const Color(0xFF21B866),
                    thumbColor: Colors.white,
                    onChanged: trackingController.toggleLocationSharing,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.notificationController});

  final NotificationController notificationController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(Routes.notificationScreen),
      child: Obx(() {
        final int unread = notificationController.unreadCount.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _Palette.bellBorder, width: 1),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 22.sp,
                color: _Palette.bellInk,
              ),
            ),
            if (unread > 0)
              Positioned(
                right: -3.w,
                top: -4.h,
                child: Container(
                  constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.w),
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: _Palette.purple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.purple.withOpacity(0.22),
                        blurRadius: 7,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: TextStyle(
                        fontFamily: FontFamily.interSemiBold,
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
