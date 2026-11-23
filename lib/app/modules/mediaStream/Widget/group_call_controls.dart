import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import '../../../../gen/fonts.gen.dart';
import '../Controller/group_calling_controller.dart';

class GroupCallControls extends StatelessWidget {
  final GroupCallingController controller;

  const GroupCallControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xEB1C272E),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Obx(() {
        final isVideo = controller.isVideo;
        final isVideoOn = controller.isVideoOn.value;
        final isAudioOn = controller.isAudioOn.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // More options
            ControlItem(
              icon: Icons.more_horiz_rounded,
              label: context.l10n.call_more,
              bgColor: const Color(0xFF2A3942),
              iconColor: Colors.white,
              onTap: controller.openMoreSheet,
            ),

            // Video camera toggle (if video call)
            if (isVideo)
              ControlItem(
                icon: isVideoOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                label: isVideoOn
                    ? context.l10n.call_cameraOn
                    : context.l10n.call_cameraOff,
                bgColor: isVideoOn
                    ? const Color(0xFF2A3942)
                    : Colors.white.withOpacity(0.12),
                iconColor: isVideoOn ? Colors.white : Colors.white60,
                onTap: controller.toggleCamera,
              ),

            // Microphone mute toggle
            ControlItem(
              icon: isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              label: isAudioOn ? context.l10n.call_mute : context.l10n.call_unmute,
              bgColor: isAudioOn
                  ? const Color(0xFF2A3942)
                  : const Color(0xFFEA4335).withOpacity(0.25),
              iconColor: isAudioOn ? Colors.white : const Color(0xFFFF5252),
              borderColor: isAudioOn
                  ? null
                  : const Color(0xFFFF5252).withOpacity(0.40),
              onTap: controller.toggleMic,
            ),

            // Speaker / audio route
            Obx(() {
              final CallAudioRoute route =
                  controller.audioRouteController.currentRoute.value;
              final bool isSpeaker = route != CallAudioRoute.earpiece;

              return ControlItem(
                icon: controller.audioRouteController.currentAudioRouteIcon,
                label: controller.audioRouteController.currentAudioRouteLabel,
                bgColor: isSpeaker
                    ? Colors.white.withOpacity(0.20)
                    : const Color(0xFF2A3942),
                iconColor: Colors.white,
                onTap: () async {
                  await controller.toggleSpeaker(context);
                },
              );
            }),

            // End call button (Prominent WhatsApp red)
            ControlItem(
              icon: Icons.call_end_rounded,
              label: context.l10n.call_endCall,
              bgColor: const Color(0xFFEA4335),
              iconColor: Colors.white,
              size: 50,
              iconSize: 26,
              onTap: controller.endCall,
            ),
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
    super.key,
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
                boxShadow: bgColor == const Color(0xFFEA4335)
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEA4335).withOpacity(0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(icon, color: iconColor, size: iconSize.sp),
            ),
            SizedBox(height: 5.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 58.w),
              child: AutoFitText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: FontFamily.interMedium,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
