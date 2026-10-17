import 'dart:ui';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/draggableVideoPip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../../../gen/fonts.gen.dart';
import '../Controller/calling_controller.dart';

class CallingScreen extends StatelessWidget {
  final controller = Get.put(CallingController());

  CallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<CallingController>(
        builder: (c) {
          final bool isVideo = c.is_video || c.isVideoCall.value;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.toggleControls,
                      child: RTCVideoView(
                        c.isLocalVideoMain ? c.localRenderer : c.remoteRenderer,
                        mirror: c.isLocalVideoMain && c.isFrontCamera,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.showControlsTemporarily,
                      child: const AudioBackground(),
                    ),
                  ),
                if (isVideo) ...[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180.h,
                    child: IgnorePointer(
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
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 220.h,
                    child: IgnorePointer(
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
                  ),
                ],
                if (isVideo)
                  Positioned.fill(
                    child: DraggableVideoPip(
                      controller: c,
                      child: _videoPip(c),
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      children: [
                        if (isVideo)
                          _buildTopInfo(
                            c,
                            isVideo: true,
                          ),
                        if (!isVideo)
                          Expanded(
                            child: AudiocallScreen(controller: c),
                          )
                        else
                          const Spacer(),
                        Obx(() {
                          if (!c.areControlsVisible.value &&
                              c.is_video == true) {
                            return const SizedBox.shrink();
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.showControlsTemporarily,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                18.w,
                                8.h,
                                18.w,
                                22.h,
                              ),
                              child: _bottomControls(
                                context,
                                c,
                                isVideo: isVideo,
                              ),
                            ),
                          );
                        }),
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

  Widget _buildTopInfo(
    CallingController c, {
    required bool isVideo,
  }) {
    final Color textColor = isVideo ? Colors.white : AppColors.darkText;

    final Color subColor =
        isVideo ? Colors.white70 : AppColors.primaryPurple.withOpacity(0.9);

    final bool isOutgoing = c.args["callType"] == "outGoing";

    return Column(
      children: [
        Text(
          isOutgoing ? "" : "Call From",
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
        Text(
          c.formattedDuration == "00:00"
              ? "${c.callStatus.value}..."
              : c.formattedDuration,
          style: TextStyle(
            color: subColor,
            fontSize: 14.sp,
            fontFamily: FontFamily.interMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _videoPip(CallingController c) {
    final bool showingRemote = c.isLocalVideoMain;

    return GestureDetector(
      onTap: () {
        c.toggleVideoViews();
        c.showControlsTemporarily();
      },
      child: Stack(
        children: [
          Container(
            width: 110.w,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.85),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: showingRemote
                ? RTCVideoView(
                    c.remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : c.isVideoOn
                    ? RTCVideoView(
                        c.localRenderer,
                        mirror: c.isFrontCamera,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        color: const Color(0xFF1A1A2E),
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 32.sp,
                        ),
                      ),
          ),
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: () {
                c.switchCamera();
              },
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cameraswitch_rounded,
                  size: 16.sp,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomControls(
    BuildContext context,
    CallingController c, {
    required bool isVideo,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 14.h,
          ),
          decoration: BoxDecoration(
            color: isVideo
                ? Colors.white.withOpacity(0.14)
                : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: Colors.white.withOpacity(
                isVideo ? 0.22 : 0.9,
              ),
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
              Obx(() {
                final CallAudioRoute route =
                    c.audioRouteController.currentRoute.value;

                return ctrl(
                  icon: c.audioRouteController.currentAudioRouteIcon,
                  label: c.audioRouteController.currentAudioRouteLabel,
                  active: route != CallAudioRoute.earpiece,
                  isVideo: isVideo,
                  onTap: () async {
                    await c.toggleSpeaker(context);
                    c.showControlsTemporarily();
                  },
                );
              }),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (c.callStatus.value != "Connected") {
                        await c.missedCall();
                      } else {
                        await c.endCall();
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
                      child: Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Decline",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isVideo ? Colors.white : AppColors.darkText,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ],
              ),
              ctrl(
                icon: c.isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                label: "Mute",
                active: !c.isAudioOn,
                isVideo: isVideo,
                onTap: () {
                  c.toggleMic();
                  c.showControlsTemporarily();
                },
              ),
              if (isVideo)
                ctrl(
                  icon: c.isVideoOn
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: c.isVideoOn ? "Camera" : "Camera Off",
                  active: !c.isVideoOn,
                  isVideo: isVideo,
                  onTap: () {
                    c.toggleCamera();
                    c.showControlsTemporarily();
                  },
                )
              else
                ctrl(
                  icon: Icons.videocam_rounded,
                  label: "Video",
                  isVideo: isVideo,
                  iconColor: AppColors.primaryPurple,
                  onTap: () {
                    c.upgradeToVideoCall();
                    c.showControlsTemporarily();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
