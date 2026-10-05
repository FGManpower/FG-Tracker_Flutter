import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/status/widget/add_status_widgets.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/AddStatusController.dart';

class StatusTopBar extends StatelessWidget {
  final AddStatusController controller;

  const StatusTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16.w,
          MediaQuery.of(context).padding.top + 8.h,
          16.w,
          16.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.65),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundActionBtn(
              icon: Icons.close_rounded,
              onTap: () {
                if (controller.capturedFile.value != null) {
                  controller.retake();
                } else {
                  Get.back();
                }
              },
            ),
            Expanded(
              child: Obx(() {
                final hasMedia = controller.capturedFile.value != null;
                return Column(
                  children: [
                    SizedBox(height: 4.h),
                    reausabletext(
                      hasMedia ? 'Preview Status' : 'Add to My Status',
                      fontsize: 16.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      hasMedia
                          ? (controller.isVideoFile.value
                              ? 'Tap video to play / pause'
                              : 'Pinch to zoom photo')
                          : 'Share updates with your team',
                      fontsize: 11.sp,
                      color: Colors.white70,
                    ),
                  ],
                );
              }),
            ),
            Obx(() {
              if (controller.mode.value == 'text') {
                return RoundActionBtn(
                  icon: Icons.palette_rounded,
                  onTap: () {
                    controller.selectedBgIndex.value =
                        (controller.selectedBgIndex.value + 1) %
                            controller.bgColors.length;
                  },
                );
              }

              if (controller.capturedFile.value != null) {
                return Column(
                  children: [
                    if (controller.isVideoFile.value) ...[
                      RoundActionBtn(
                        icon: controller.isVideoMuted.value
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        active: !controller.isVideoMuted.value,
                        onTap: controller.toggleVideoMute,
                      ),
                      SizedBox(height: 10.h),
                    ],
                    RoundActionBtn(
                      icon: Icons.delete_outline_rounded,
                      onTap: controller.retake,
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  RoundActionBtn(
                    icon: controller.isFlashOn.value
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: controller.toggleFlash,
                    active: controller.isFlashOn.value,
                  ),
                  SizedBox(height: 10.h),
                  RoundActionBtn(
                    icon: Icons.cameraswitch_rounded,
                    onTap: controller.flipCamera,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
