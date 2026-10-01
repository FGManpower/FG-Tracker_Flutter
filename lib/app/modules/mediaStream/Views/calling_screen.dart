import 'dart:ui';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/call_widget.dart';
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
                      onTap: c.showControlsTemporarily,
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
                          if (!c.areControlsVisible.value) {
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
          isOutgoing ? "Calling" : "Call From",
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

          // Camera switch button
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: showingRemote
                  ? null
                  : () {
                      c.switchCamera();
                      c.showControlsTemporarily();
                    },
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  showingRemote
                      ? Icons.swap_horiz_rounded
                      : Icons.cameraswitch_rounded,
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

  void _openMoreSheet(
    BuildContext context,
    CallingController c,
  ) {
    final bool isVideo = c.is_video || c.isVideoCall.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              14.w,
              0,
              14.w,
              14.h,
            ),
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
                        margin: EdgeInsets.fromLTRB(
                          12.w,
                          6.h,
                          12.w,
                          12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          children: [
                            if (isVideo) ...[
                              sheetTile(
                                icon: Icons.cameraswitch_rounded,
                                title: "Switch camera",
                                onTap: () {
                                  Navigator.pop(ctx);
                                  c.switchCamera();
                                  c.showControlsTemporarily();
                                },
                              ),
                              sheetDivider(),
                            ],
                            sheetTile(
                              icon: Icons.present_to_all_rounded,
                              title: "Share screen",
                              onTap: () {
                                Navigator.pop(ctx);
                                Get.snackbar(
                                  "Share screen",
                                  "Coming soon",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                            ),
                            sheetDivider(),
                            sheetTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: "Send message",
                              onTap: () {
                                Navigator.pop(ctx);
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
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: AppColors.primaryPurple,
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
              ctrl(
                icon: Icons.more_horiz_rounded,
                label: "More",
                isVideo: isVideo,
                onTap: () {
                  c.showControlsTemporarily();
                  _openMoreSheet(context, c);
                },
              ),
              Obx(() {
                final String activeRoute = c.currentAudioRoute.value;

                IconData speakerIcon;
                String speakerLabel;
                Color? activeIconColor;
                bool isButtonActive = false;

                if (activeRoute == "bluetooth") {
                  speakerIcon = Icons.bluetooth_audio_rounded;
                  speakerLabel = "Bluetooth";
                  activeIconColor = const Color(0xFF2196F3);
                  isButtonActive = true;
                } else if (activeRoute == "speaker") {
                  speakerIcon = Icons.volume_up_rounded;
                  speakerLabel = "Speaker";
                  activeIconColor =
                      isVideo ? Colors.white : AppColors.primaryPurple;
                  isButtonActive = true;
                } else {
                  speakerIcon = Icons.volume_down_rounded;
                  speakerLabel = "Earpiece";
                  activeIconColor = isVideo
                      ? Colors.white60
                      : AppColors.darkText.withOpacity(0.6);
                  isButtonActive = false;
                }

                return ctrl(
                  icon: speakerIcon,
                  label: speakerLabel,
                  active: isButtonActive,
                  isVideo: isVideo,
                  onTap: () {
                    c.toggleSpeaker();
                    c.showControlsTemporarily();
                  },
                  iconColor: activeIconColor,
                );
              }),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (c.callStatus.value != "Connected") {
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

class DraggableVideoPip extends StatefulWidget {
  final Widget child;

  const DraggableVideoPip({
    super.key,
    required this.child,
  });

  @override
  State<DraggableVideoPip> createState() => _DraggableVideoPipState();
}

class _DraggableVideoPipState extends State<DraggableVideoPip> {
  Offset? _position;

  double get _pipWidth => 110.w;
  double get _pipHeight => 150.h;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final double safeTop = MediaQuery.of(context).padding.top;

        final double minLeft = 8.w;
        final double maxLeft = screenWidth - _pipWidth - 8.w;

        final double minTop = safeTop + 12.h;

        // Keep the PIP above the bottom controls.
        final double maxTop = screenHeight - _pipHeight - 145.h;

        final double defaultTop = maxTop > minTop ? maxTop : minTop;

        final Offset currentPosition = _position ??
            Offset(
              20.w,
              defaultTop,
            );

        final double boundedMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;

        final double boundedMaxTop = maxTop < minTop ? minTop : maxTop;

        final Offset safePosition = Offset(
          currentPosition.dx.clamp(
            minLeft,
            boundedMaxLeft,
          ),
          currentPosition.dy.clamp(
            minTop,
            boundedMaxTop,
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: safePosition.dx,
              top: safePosition.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  setState(() {});
                },
                onPanUpdate: (details) {
                  final double newLeft = safePosition.dx + details.delta.dx;

                  final double newTop = safePosition.dy + details.delta.dy;

                  setState(() {
                    _position = Offset(
                      newLeft.clamp(
                        minLeft,
                        boundedMaxLeft,
                      ),
                      newTop.clamp(
                        minTop,
                        boundedMaxTop,
                      ),
                    );
                  });
                },
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}
