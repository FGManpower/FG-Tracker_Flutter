import 'dart:ui';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../gen/fonts.gen.dart';
import '../controller/calling_controller.dart';

class CallingScreen extends StatelessWidget {
  final controller = Get.put(CallingController());
  CallingScreen({super.key});
  static const Color primaryPurple = Color(0xFF7B58FF);
  static const Color darkText = Color(0xFF0F0B4C);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<CallingController>(
        builder: (c) {
          final bool isVideo = c.is_video;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  Positioned.fill(
                    child: RTCVideoView(
                      c.remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  )
                else
                  const Positioned.fill(child: _AudioBackground()),
                if (isVideo) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 220.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      children: [
                        if (isVideo) _buildTopInfo(c, isVideo: true),
                        if (!isVideo)
                          Expanded(
                            child: AudiocallScreen(controller: controller),
                          )
                        else
                          const Spacer(),
                        if (isVideo)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 20.w, bottom: 18.h),
                              child: _localPip(c),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 22.h),
                          child: _bottomControls(c, isVideo: isVideo),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopInfo(CallingController c, {required bool isVideo}) {
    final Color textColor = isVideo ? Colors.white : darkText;
    final Color subColor =
        isVideo ? Colors.white70 : primaryPurple.withOpacity(0.9);

    return Column(
      children: [
        Text(
          "Call From",
          style: TextStyle(
            color: subColor,
            fontSize: 14.sp,
            fontFamily: FontFamily.interMedium,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "${c.args["callerName"] ?? ""}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 26.sp,
            fontFamily: FontFamily.interSemiBold,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          final waiting = c.formattedDuration == "00:00";
          return Text(
            waiting ? "${c.callStatus.value}..." : c.formattedDuration,
            style: TextStyle(
              color: subColor,
              fontSize: 14.sp,
              fontFamily: FontFamily.interMedium,
            ),
          );
        }),
      ],
    );
  }

  Widget _localPip(CallingController c) {
    return Stack(
      children: [
        Container(
          width: 110.w,
          height: 150.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: c.isVideoOn
              ? RTCVideoView(
                  c.localRenderer,
                  mirror: c.isFrontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : Container(
                  color: const Color(0xFF1A1A2E),
                  child: Icon(Icons.videocam_off,
                      color: Colors.white54, size: 32.sp),
                ),
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: GestureDetector(
            onTap: c.switchCamera,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cameraswitch_rounded,
                  size: 16.sp, color: primaryPurple),
            ),
          ),
        ),
      ],
    );
  }

  void _openMoreSheet(BuildContext context, CallingController c) {
    final bool isVideo = c.is_video;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2FF),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Container(
                        margin: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          children: [
                            if (!isVideo) ...[
                              _sheetTile(
                                icon: Icons.cameraswitch_rounded,
                                title: "Switch camera",
                                onTap: () {
                                  Navigator.pop(ctx);
                                  c.switchCamera();
                                },
                              ),
                              _sheetDivider(),
                            ],

                            _sheetTile(
                              icon: Icons.present_to_all_rounded,
                              title: "Share screen",
                              onTap: () {
                                Navigator.pop(ctx);
                                // TODO: c.startScreenShare();
                                Get.snackbar(
                                  "Share screen",
                                  "Coming soon",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                            ),
                            _sheetDivider(),

                            _sheetTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: "Send message",
                              onTap: () {
                                Navigator.pop(ctx);
                                // TODO: open chat
                                Get.snackbar(
                                  "Send message",
                                  "Coming soon",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18.r),
                      onTap: () => Navigator.pop(ctx),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: primaryPurple,
                              fontSize: 16.sp,
                              fontFamily: FontFamily.interSemiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _sheetDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFF0EEF8),
      indent: 18.w,
      endIndent: 18.w,
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: primaryPurple, size: 24.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: primaryPurple,
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: primaryPurple.withOpacity(0.7),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomControls(CallingController c, {required bool isVideo}) {
    return Builder(
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isVideo
                    ? Colors.white.withOpacity(0.14)
                    : Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: Colors.white.withOpacity(isVideo ? 0.22 : 0.9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ★ 3 dots → bottom sheet
                  _ctrl(
                    icon: Icons.more_horiz_rounded,
                    label: "More",
                    isVideo: isVideo,
                    onTap: () => _openMoreSheet(context, c),
                  ),
                  _ctrl(
                    icon: c.isSpeakerOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    label: "Speaker",
                    active: c.isSpeakerOn,
                    isVideo: isVideo,
                    onTap: c.toggleSpeaker,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (controller.callStatus.value != "Connected") {
                            c.missedCall();
                          } else {
                            c.endCall();
                          }
                        },
                        child: Container(
                          width: 58.r,
                          height: 58.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66FF3B30),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.call_end_rounded,
                              color: Colors.white, size: 28.sp),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Decline",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isVideo ? Colors.white : darkText,
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ],
                  ),
                  _ctrl(
                    icon:
                        c.isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                    label: "Mute",
                    active: !c.isAudioOn,
                    isVideo: isVideo,
                    onTap: c.toggleMic,
                  ),
                  if (isVideo)
                    _ctrl(
                      icon: c.isVideoOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      label: c.isVideoOn ? "Camera" : "Camera Off",
                      active: !c.isVideoOn,
                      isVideo: isVideo,
                      onTap: c.toggleCamera,
                    )
                  else
                    _ctrl(
                      icon: Icons.videocam_rounded,
                      label: "Video",
                      isVideo: isVideo,
                      iconColor: primaryPurple,
                      onTap: () {
                        // optional upgrade to video
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ctrl({
    required IconData icon,
    required String label,
    required bool isVideo,
    required VoidCallback onTap,
    bool active = false,
    Color? iconColor,
  }) {
    final Color baseIcon =
        iconColor ?? (isVideo ? Colors.white : primaryPurple);
    final Color bg = isVideo
        ? Colors.white.withOpacity(active ? 0.28 : 0.14)
        : Colors.white.withOpacity(active ? 0.95 : 0.85);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: baseIcon, size: 22.sp),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isVideo ? Colors.white : darkText,
            fontFamily: FontFamily.interMedium,
          ),
        ),
      ],
    );
  }
}

class _AudioBackground extends StatelessWidget {
  const _AudioBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9E6FF),
            Color(0xFFF4F2FF),
            Color(0xFFEDE9FF),
          ],
        ),
      ),
    );
  }
}
