import 'dart:io';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide navigator;

import '../../../../gen/fonts.gen.dart';

Future<CallAudioRoute?> showAudioRouteSheet(
    BuildContext context,
    CallAudioRouteController controller,
    ) {
  return showModalBottomSheet<CallAudioRoute>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (sheetContext) =>
        _AudioRouteSheet(controller: controller, sheetContext: sheetContext),
  );
}

class _AudioRouteSheet extends StatelessWidget {
  final CallAudioRouteController controller;
  final BuildContext sheetContext;

  const _AudioRouteSheet({
    required this.controller,
    required this.sheetContext,
  });

  void _close([CallAudioRoute? route]) {
    Navigator.of(sheetContext).pop(route);
  }

  void _warn(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Platform.isIOS;
    final String phoneLabel = isIOS ? 'iPhone' : 'Phone';
    final IconData phoneIcon = isIOS
        ? Icons.phone_iphone_rounded
        : Icons.phone_android_rounded;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 14.w.clamp(10.0, 20.0),
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Obx(() {
              final CallAudioRoute active = controller.currentRoute.value;
              final bool isVideo = controller.isVideoCall.value;
              final bool hasBT = controller.isBluetoothConnected.value;
              final String btName = controller.bluetoothDeviceName.value;
              final bool hasHeadset = controller.isHeadsetConnected.value;
              final String headsetName = controller.headsetDeviceName.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
                      width: 38.w.clamp(32.0, 44.0),
                      height: 4.h.clamp(3.0, 5.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Audio Output',
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 16.sp.clamp(15.0, 18.0),
                            fontWeight: FontWeight.w700,
                            fontFamily: FontFamily.interSemiBold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _close(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  const Divider(
                    color: Color(0xFFF1F5F9),
                    height: 1,
                    thickness: 1,
                  ),
                  if (!isVideo)
                    _RouteItem(
                      title: phoneLabel,
                      trailingIcon: phoneIcon,
                      isSelected: active == CallAudioRoute.earpiece,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _close(CallAudioRoute.earpiece);
                      },
                    ),
                  if (!isVideo) const _RouteDivider(),
                  _RouteItem(
                    title: 'Speaker',
                    trailingIcon: Icons.volume_up_rounded,
                    isSelected: active == CallAudioRoute.speaker,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _close(CallAudioRoute.speaker);
                    },
                  ),
                  const _RouteDivider(),
                  _RouteItem(
                    title: hasBT ? btName : 'Bluetooth',
                    subtitle: hasBT ? 'Connected' : 'Not connected',
                    trailingIcon: Icons.bluetooth_audio_rounded,
                    isSelected: active == CallAudioRoute.bluetooth,
                    isEnabled: hasBT,
                    onTap: () {
                      if (!hasBT) {
                        _warn(
                          'Bluetooth',
                          'No Bluetooth audio device connected. Please pair '
                              'your Bluetooth headset in settings.',
                        );
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      _close(CallAudioRoute.bluetooth);
                    },
                  ),
                  const _RouteDivider(),
                  _RouteItem(
                    title: hasHeadset ? headsetName : 'Wired Headphones',
                    subtitle: hasHeadset ? 'Connected' : 'Not connected',
                    trailingIcon: Icons.headphones_rounded,
                    isSelected: active == CallAudioRoute.headset,
                    isEnabled: hasHeadset,
                    onTap: () {
                      if (!hasHeadset) {
                        _warn(
                          'Wired Headphones',
                          'No wired earphones or headset connected. Please '
                              'plug them into your device.',
                        );
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      _close(CallAudioRoute.headset);
                    },
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: TextButton(
                      onPressed: () => _close(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontSize: 14.5.sp.clamp(13.0, 16.0),
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.interSemiBold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _RouteDivider extends StatelessWidget {
  const _RouteDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1);
  }
}

class _RouteItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _RouteItem({
    required this.title,
    required this.trailingIcon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool dim = !isEnabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dim
                            ? const Color(0xFFB4B4C0)
                            : (isSelected
                            ? AppColors.primaryPurple
                            : AppColors.darkText),
                        fontSize: 15.sp.clamp(14.0, 17.0),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: dim
                              ? const Color(0xFFC9C9D4)
                              : const Color(0xFF94A3B8),
                          fontSize: 11.5.sp.clamp(10.5, 13.5),
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20.sp,
                    color: AppColors.primaryPurple,
                  ),
                ),
              Icon(
                trailingIcon,
                size: 22.sp,
                color: dim
                    ? const Color(0xFFC9C9D4)
                    : (isSelected
                    ? AppColors.primaryPurple
                    : const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
