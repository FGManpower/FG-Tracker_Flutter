import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide navigator;
import '../../../../gen/fonts.gen.dart';


class _RouteUi {
  final String label;
  final String subtitle;
  final IconData icon;
  const _RouteUi(this.label, this.subtitle, this.icon);
}

Future<CallAudioRoute?> showAudioRouteSheet(
  BuildContext context,
  CallAudioRouteController controller,
) {
  return showModalBottomSheet<CallAudioRoute>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AudioRouteSheet(controller: controller),
  );
}

class _AudioRouteSheet extends StatelessWidget {
  final CallAudioRouteController controller;

  const _AudioRouteSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2EA),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Audio output",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: const Color(0xFF9A9AA8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Obx(() {
            return Text(
              "Currently: ${controller.currentAudioRouteLabel}",
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF9A9AA8),
                fontFamily: FontFamily.interMedium,
              ),
            );
          }),
          SizedBox(height: 16.h),
          Obx(() {
            final CallAudioRoute active = controller.currentRoute.value;
            final bool isVideo = controller.isVideoCall.value;
            final bool btConnected = controller.isBluetoothConnected.value;
            final bool headsetConnected = controller.isHeadsetConnected.value;
            final String btName = controller.bluetoothDeviceName.value;
            final String headsetName = controller.headsetDeviceName.value;

            return Column(
              children: [
                // Earpiece is not available during video calls.
                if (!isVideo)
                  _RouteTile(
                    ui: const _RouteUi(
                      "Earpiece",
                      "Private listening at your ear",
                      Icons.phone_in_talk_rounded,
                    ),
                    selected: active == CallAudioRoute.earpiece,
                    onTap: () =>
                        Navigator.of(context).pop(CallAudioRoute.earpiece),
                  ),
                _RouteTile(
                  ui: const _RouteUi(
                    "Speaker",
                    "Loud, hands-free audio",
                    Icons.volume_up_rounded,
                  ),
                  selected: active == CallAudioRoute.speaker,
                  onTap: () =>
                      Navigator.of(context).pop(CallAudioRoute.speaker),
                ),
                if (btConnected)
                  _RouteTile(
                    ui: _RouteUi(
                      "Bluetooth",
                      (btName.isNotEmpty && btName != 'Bluetooth')
                          ? btName
                          : "Connected headset",
                      Icons.bluetooth_audio_rounded,
                    ),
                    selected: active == CallAudioRoute.bluetooth,
                    onTap: () =>
                        Navigator.of(context).pop(CallAudioRoute.bluetooth),
                  ),
                if (headsetConnected)
                  _RouteTile(
                    ui: _RouteUi(
                      "Headset",
                      (headsetName.isNotEmpty && headsetName != 'Headset')
                          ? headsetName
                          : "Wired headset",
                      Icons.headphones_rounded,
                    ),
                    selected: active == CallAudioRoute.headset,
                    onTap: () =>
                        Navigator.of(context).pop(CallAudioRoute.headset),
                  ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.isVideoCall.value) {
              return const SizedBox.shrink();
            }
            return Text(
              "Earpiece mode turns the screen off when the phone is near your ear.",
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.35,
                color: const Color(0xFFB4B4C0),
                fontFamily: FontFamily.interMedium,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  final _RouteUi ui;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _RouteTile({
    required this.ui,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool dim = !enabled;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: selected
            ? AppColors.primaryPurple.withOpacity(0.08)
            : const Color(0xFFF6F6FA),
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryPurple : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryPurple
                          : const Color(0xFFE8E8F0),
                    ),
                  ),
                  child: Icon(
                    ui.icon,
                    size: 20.sp,
                    color: dim
                        ? const Color(0xFFC9C9D4)
                        : (selected ? Colors.white : AppColors.primaryPurple),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ui.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: dim
                              ? const Color(0xFFB4B4C0)
                              : AppColors.darkText,
                          fontFamily: FontFamily.interSemiBold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        ui.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF9A9AA8),
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20.sp,
                    color: AppColors.primaryPurple,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
