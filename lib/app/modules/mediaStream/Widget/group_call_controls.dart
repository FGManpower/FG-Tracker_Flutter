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
        final wired = controller.isWiredHeadsetConnected.value;
        final deviceName = controller.audioDeviceLabel.value;

        late IconData routeIcon;
        late String routeLabel;
        late Color routeBg;
        late Color routeIconColor;
        late Color routeBorder;

        switch (route) {
          case AudioRoute.bluetooth:
            routeIcon = Icons.bluetooth_connected_rounded;
            routeLabel = deviceName.isNotEmpty ? deviceName : 'Bluetooth';
            routeBg = const Color(0xFFE8F0FF);
            routeIconColor = const Color(0xFF2F6BFF);
            routeBorder = const Color(0xFF2F6BFF);
            break;
          case AudioRoute.earpiece:
            if (wired) {
              routeIcon = Icons.headphones_rounded;
              routeLabel = 'Headphones';
            } else {
              routeIcon = Icons.phone_in_talk_rounded;
              routeLabel = 'Earpiece';
            }
            routeBg = Colors.white;
            routeIconColor = const Color(0xFF6E5CA4);
            routeBorder = const Color(0xFFE9E5FE);
            break;
          case AudioRoute.speaker:
            routeIcon = Icons.volume_up_rounded;
            routeLabel = 'Speaker';
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
              onTap: () => AudioRouteSheet.show(controller),
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

// ---------------------------------------------------------
// Bottom Sheet to manually choose the Audio Route
// ---------------------------------------------------------
class AudioRouteSheet {
  static void show(GroupCallingController controller) {
    controller.onSheetOpened();
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Select Audio Output",
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: FontFamily.interSemiBold,
                color: const Color(0xFF1E1147),
              ),
            ),
            SizedBox(height: 15.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Obx(() {
                final currentRoute = controller.audioRoute.value;
                final hasBluetooth = controller.isBluetoothConnected.value;
                final hasWired = controller.isWiredHeadsetConnected.value;
                final btName = controller.audioDeviceLabel.value;

                return Column(
                  children: [
                    _RouteTile(
                      icon: Icons.volume_up_rounded,
                      title: "Speaker",
                      subtitle: "Play sound on loudspeaker",
                      isSelected: currentRoute == AudioRoute.speaker,
                      onTap: () {
                        controller.setAudioRoute(AudioRoute.speaker);
                        Get.back();
                      },
                    ),
                    const Divider(height: 1, indent: 50),
                    _RouteTile(
                      icon: hasWired
                          ? Icons.headphones_rounded
                          : Icons.phone_in_talk_rounded,
                      title: hasWired ? "Headphones" : "Earpiece",
                      subtitle: hasWired
                          ? "Wired headset"
                          : "Phone earpiece",
                      isSelected: currentRoute == AudioRoute.earpiece,
                      onTap: () {
                        controller.setAudioRoute(AudioRoute.earpiece);
                        Get.back();
                      },
                    ),
                    if (hasBluetooth) ...[
                      const Divider(height: 1, indent: 50),
                      _RouteTile(
                        icon: Icons.bluetooth_connected_rounded,
                        title: btName.isNotEmpty ? btName : "Bluetooth",
                        subtitle: "Wireless headset",
                        isSelected: currentRoute == AudioRoute.bluetooth,
                        onTap: () {
                          controller.setAudioRoute(AudioRoute.bluetooth);
                          Get.back();
                        },
                      ),
                    ]
                  ],
                );
              }),
            ),
            SizedBox(height: 15.h),
            InkWell(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: const Color(0xFF1E1147),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    ).whenComplete(() => controller.onSheetClosed());
  }
}

class _RouteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF2F6BFF) : const Color(0xFF6E5CA4);
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: isSelected ? FontFamily.interSemiBold : FontFamily.interMedium,
          color: isSelected ? const Color(0xFF2F6BFF) : Colors.black,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
        subtitle!,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.grey.shade600,
          fontFamily: FontFamily.interMedium,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2F6BFF))
          : null,
      onTap: onTap,
    );
  }
}