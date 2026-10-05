import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../Controller/group_calling_controller.dart';

class GroupCallControls extends StatelessWidget {
  final GroupCallingController controller;

  const GroupCallControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final isVideo = controller.isVideo;
        final isVideoOn = controller.isVideoOn.value;
        final isAudioOn = controller.isAudioOn.value;
        final route = controller.audioRoute.value;

        late IconData routeIcon;
        late String routeLabel;
        late Color routeBg;
        late Color routeIconColor;
        late Color routeBorder;

        switch (route) {
          case AudioRoute.bluetooth:
            routeIcon = Icons.bluetooth_connected_rounded;
            routeLabel = "Bluetooth";
            routeBg = const Color(0xFFE8F0FF);
            routeIconColor = const Color(0xFF2F6BFF);
            routeBorder = const Color(0xFF2F6BFF);
            break;
          case AudioRoute.earpiece:
            routeIcon = Icons.phone_in_talk_rounded;
            routeLabel = "Earpiece";
            routeBg = Colors.white;
            routeIconColor = const Color(0xFF6E5CA4);
            routeBorder = const Color(0xFFE9E5FE);
            break;
          case AudioRoute.speaker:
            routeIcon = Icons.volume_up_rounded;
            routeLabel = "Speaker";
            routeBg = Colors.white;
            routeIconColor = const Color(0xFF6E5CA4);
            routeBorder = const Color(0xFFE9E5FE);
            break;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 4.w),
            ControlItem(
              icon: Icons.more_horiz_rounded,
              label: "More",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.openMoreSheet,
            ),
            SizedBox(width: 8.w),
            if (isVideo) ...[
              ControlItem(
                icon: isVideoOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                label: isVideoOn ? "Camera on" : "Camera off",
                bgColor: Colors.white,
                iconColor: const Color(0xFF6E5CA4),
                borderColor: const Color(0xFFE9E5FE),
                onTap: controller.toggleCamera,
              ),
              SizedBox(width: 8.w),
            ],
            ControlItem(
              icon: Icons.call_end_rounded,
              label: "End call",
              bgColor: const Color(0xFFFF3B30),
              iconColor: Colors.white,
              size: 54,
              iconSize: 26,
              onTap: controller.endCall,
            ),
            SizedBox(width: 8.w),
            ControlItem(
              icon: isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: isAudioOn ? "Mute" : "Unmute",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.toggleMic,
            ),
            SizedBox(width: 8.w),
            ControlItem(
              icon: routeIcon,
              label: routeLabel,
              bgColor: routeBg,
              iconColor: routeIconColor,
              borderColor: routeBorder,
              onTap: controller.toggleSpeaker,
            ),
            SizedBox(width: 4.w),
          ],
        );
      }),
    );
  }
}

class ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const ControlItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
    this.borderColor,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.r,
              height: size.r,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: borderColor != null
                    ? Border.all(color: borderColor!, width: 1.2)
                    : null,
                boxShadow: bgColor == const Color(0xFFFF3B30)
                    ? [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: iconSize.sp),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: FontFamily.interMedium,
                color: const Color(0xFF5B4B8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}