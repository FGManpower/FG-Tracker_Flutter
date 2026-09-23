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
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final isVideo = controller.isVideo;
        final isVideoOn = controller.isVideoOn.value;
        final isAudioOn = controller.isAudioOn.value;
        final isSpeakerOn = controller.isSpeakerOn.value;
        final isScreenSharing = controller.isScreenSharing.value;

<<<<<<< HEAD
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlItem(
              icon: Icons.more_horiz_rounded,
              label: "More",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: () {
                controller.openMoreSheet();
              },
            ),
            if (isVideo)
              _ControlItem(
                icon: isVideoOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                label: isVideoOn ? "Camera on" : "Camera off",
=======
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 4.w),
              _ControlItem(
                icon: Icons.more_horiz_rounded,
                label: "More",
>>>>>>> 1c1f1c71a8d0d65b5af4d04e4bd6c55c3663dafe
                bgColor: Colors.white,
                iconColor: const Color(0xFF6E5CA4),
                borderColor: const Color(0xFFE9E5FE),
                onTap: controller.openMoreSheet,
              ),
<<<<<<< HEAD
            _ControlItem(
              icon: Icons.call_end_rounded,
              label: "End call",
              bgColor: const Color(0xFFFF3B30),
              iconColor: Colors.white,
              size: 56,
              iconSize: 28,
              onTap: controller.endCall,
            ),
            _ControlItem(
              icon: isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: isAudioOn ? "Mute" : "Unmute",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.toggleMic,
            ),
            _ControlItem(
              icon: isSpeakerOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              label: "Speaker",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.toggleSpeaker,
            ),
          ],
=======
              SizedBox(width: 8.w),
              if (isVideo) ...[
                _ControlItem(
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
              if (isVideo && isVideoOn && !isScreenSharing) ...[
                _ControlItem(
                  icon: Icons.cameraswitch_rounded,
                  label: "Flip",
                  bgColor: Colors.white,
                  iconColor: const Color(0xFF6E5CA4),
                  borderColor: const Color(0xFFE9E5FE),
                  onTap: controller.switchCamera,
                ),
                SizedBox(width: 8.w),
              ],
              _ControlItem(
                icon: Icons.call_end_rounded,
                label: "End call",
                bgColor: const Color(0xFFFF3B30),
                iconColor: Colors.white,
                size: 54,
                iconSize: 26,
                onTap: controller.endCall,
              ),
              SizedBox(width: 8.w),
              _ControlItem(
                icon: isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                label: isAudioOn ? "Mute" : "Unmute",
                bgColor: Colors.white,
                iconColor: const Color(0xFF6E5CA4),
                borderColor: const Color(0xFFE9E5FE),
                onTap: controller.toggleMic,
              ),
              SizedBox(width: 8.w),
              _ControlItem(
                icon: isSpeakerOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                label: "Speaker",
                bgColor: Colors.white,
                iconColor: const Color(0xFF6E5CA4),
                borderColor: const Color(0xFFE9E5FE),
                onTap: controller.toggleSpeaker,
              ),
              SizedBox(width: 4.w),
            ],
          ),
>>>>>>> 1c1f1c71a8d0d65b5af4d04e4bd6c55c3663dafe
        );
      }),
    );
  }
}

class _ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ControlItem({
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
<<<<<<< HEAD
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
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
=======
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
>>>>>>> 1c1f1c71a8d0d65b5af4d04e4bd6c55c3663dafe
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
