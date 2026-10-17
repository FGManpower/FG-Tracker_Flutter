import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/crown_icon.dart';
import 'package:fgtracker/app/modules/Notification/Controller/Notification_Controller.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../modules/home/Views/LiveStatus/components/ghost_member.dart';

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
  final GroupTrackingController trackingController;
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
      backgroundColor: const Color(0xFFF4F6FC),
      automaticallyImplyLeading: false,
      titleSpacing: 16.w,
      title: Row(
        children: [
          Obx(() {
            final String? profileImage =
                controller.userData.value.profileImage;
            final bool hasImage =
            Utility.isNotNullEmptyOrFalse(profileImage);

            return GestureDetector(
              onTap: () {
                if (scaffoldKey.currentState != null) {
                  scaffoldKey.currentState!.openDrawer();
                }
              },
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Stack(
                  children: [
                    ClipOval(
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: '${ConstRes.aImageBaseUrl}$profileImage',
                              width: 44.w,
                              height: 44.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 44.w,
                                height: 44.w,
                                color: const Color(0xFFEDE9FE),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 24.sp,
                                  color: const Color(0xFF5D47F1),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 44.w,
                                height: 44.w,
                                color: const Color(0xFFEDE9FE),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 24.sp,
                                  color: const Color(0xFF5D47F1),
                                ),
                              ),
                            )
                          : Container(
                              width: 44.w,
                              height: 44.w,
                              color: const Color(0xFFEDE9FE),
                              child: Icon(
                                Icons.person_rounded,
                                size: 24.sp,
                                color: const Color(0xFF5D47F1),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 1.w,
                      bottom: 1.h,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(width: 10.w),
          Expanded(
            child: _WelcomeTitle(controller: controller),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.toNamed(Routes.walkieTalkieTrialDetails);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CrownIcon(
                width: 21.w,
                height: 15.5.h,
                color: const Color(0xFF5338EE),
              ),
              SizedBox(height: 2.h),
              Text(
                'Premium',
                style: TextStyle(
                  fontFamily: FontFamily.interBold,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5338EE),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _LocationStatus(trackingController: trackingController),
        SizedBox(width: 8.w),
        _NotificationBell(
          notificationController: notificationController,
        ),
        SizedBox(width: 16.w),
      ],
    );
  }
}

class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle({required this.controller});

  final HomeController controller;

  String _formatName(String raw) {
    if (raw.trim().isEmpty) return 'User';
    final words = raw.trim().split(RegExp(r'\s+'));
    final firstName =
        words.firstWhere((w) => w.isNotEmpty, orElse: () => 'User');
    return firstName[0].toUpperCase() +
        (firstName.length > 1 ? firstName.substring(1) : '');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String rawName = controller.userData.value.name?.trim() ?? '';
      final String name = _formatName(rawName);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: FontFamily.interBold,
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10153D),
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                '👋',
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Manage your groups easily',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: FontFamily.interRegular,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.2,
            ),
          ),
        ],
      );
    });
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({
    required this.trackingController,
  });

  final GroupTrackingController trackingController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSharing =
          trackingController.isLocationSharing.value;

      final Color dotColor = isSharing
          ? _Palette.green
          : const Color(0xFFE53935);

      final Color backgroundColor = isSharing
          ? _Palette.pillLive
          : const Color(0xFFFFEEEE);

      final Color borderColor = isSharing
          ? _Palette.pillBorderLive
          : const Color(0xFFF5D0D0);

      final Color textColor = isSharing
          ? _Palette.textLive
          : const Color(0xFFD32F2F);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.to(() => const GhostMember());
        },
        child: Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                isSharing ? 'Live' : 'Private',
                style: TextStyle(
                  fontFamily: FontFamily.interSemiBold,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({
    required this.notificationController,
  });

  final NotificationController notificationController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Get.toNamed(Routes.notificationScreen);
      },
      child: Obx(() {
        final int unread =
            notificationController.unreadCount.value;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _Palette.bellBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 22.sp,
                color: _Palette.bellInk,
              ),
            ),

            if (unread > 0)
              Positioned(
                right: -4.w,
                top: -4.h,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 19.w,
                    minHeight: 19.w,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.h,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _Palette.purple,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.purple.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: FontFamily.interSemiBold,
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
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