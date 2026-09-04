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
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
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
        final isSpeakerOn = controller.isSpeakerOn.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlItem(
              icon: Icons.more_horiz_rounded,
              label: "More",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.openMoreOptionsSheet,
            ),

            if (isVideo)
              _ControlItem(
                icon: isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                label: isVideoOn ? "Camera on" : "Camera off",
                bgColor: Colors.white,
                iconColor: const Color(0xFF6E5CA4),
                borderColor: const Color(0xFFE9E5FE),
                onTap: controller.toggleCamera,
              ),

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
              icon: isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              label: "Speaker",
              bgColor: Colors.white,
              iconColor: const Color(0xFF6E5CA4),
              borderColor: const Color(0xFFE9E5FE),
              onTap: controller.toggleSpeaker,
            ),
          ],
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
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.r),
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
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF5B4B8A),
            ),
          ),
        ],
      ),
    );
  }
}