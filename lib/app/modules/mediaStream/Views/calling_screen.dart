import 'dart:ui';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/draggableVideoPip.dart';
import 'package:flutter/cupertino.dart';
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
          final bool showLocalInMain = !c.isRemoteScreenSharing.value &&
              (c.isLocalVideoMain || c.isScreenSharing.value) &&
              (c.isVideoOn || !c.isRemoteVideoOn || c.isScreenSharing.value);
          final bool mainHasActiveVideo = showLocalInMain
              ? (c.isVideoOn || c.isScreenSharing.value)
              : (c.isRemoteVideoOn || c.isRemoteScreenSharing.value);
          final bool remoteWaiting = !showLocalInMain &&
              c.isRemoteVideoOn &&
              c.isRemoteVideoLoading.value;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: c.toggleControls,
                        child: remoteWaiting
                            ? _ConnectingVideoView(
                                name: (c.args["callerName"] ?? "").toString(),
                                status: c.callStatus.value,
                              )
                            : mainHasActiveVideo
                                ? RTCVideoView(
                                    showLocalInMain
                                        ? c.localRenderer
                                        : c.remoteRenderer,
                                    key: ValueKey<String>(
                                      showLocalInMain
                                          ? 'main_local_${c.localRenderer.textureId}'
                                          : 'main_remote_${c.remoteRenderer.textureId}',
                                    ),
                                    mirror: showLocalInMain && c.isFrontCamera,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                  )
                                : Container(
                                    key: const ValueKey<String>(
                                        'main_video_off'),
                                    color: const Color(0xFF12131F),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 84.r,
                                          height: 84.r,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.videocam_off_rounded,
                                            color: Colors.white60,
                                            size: 38.sp,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          "Camera Off",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15.sp,
                                            fontFamily: FontFamily.interMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      children: [
                        if (isVideo)
                          IgnorePointer(child: _buildTopInfo(c, isVideo: true)),
                        if (!isVideo)
                          Expanded(child: AudiocallScreen(controller: c))
                        else
                          const Spacer(),
                        Obx(() {
                          if (!c.areControlsVisible.value &&
                              (c.is_video || c.isVideoCall.value)) {
                            return const SizedBox.shrink();
                          }

                          return RepaintBoundary(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                18.w,
                                8.h,
                                18.w,
                                22.h,
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: c.showControlsTemporarily,
                                child: _bottomControls(
                                  context,
                                  c,
                                  isVideo: isVideo,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                if (isVideo)
                  Positioned.fill(
                    child: DraggableVideoPip(
                      controller: c,
                      child: RepaintBoundary(child: _videoPip(c)),
                    ),
                  ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 96.h,
                  left: 0,
                  right: 0,
                  child: Obx(() {
                    if (!c.isScreenSharing.value &&
                        !c.isRemoteScreenSharing.value) {
                      return const SizedBox.shrink();
                    }

                    final String name = c.screenShareName.value.trim();
                    final String text = c.isScreenSharing.value
                        ? "You are sharing your screen"
                        : "${name.isEmpty ? 'The other person' : name} is sharing the screen";

                    return IgnorePointer(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.screen_share_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6.w),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 240.w),
                                child: Text(
                                  text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontFamily: FontFamily.interMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopInfo(CallingController c, {required bool isVideo}) {
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
        Obx(() {
          final String dur = c.formattedDuration;
          final String status = c.callStatus.value;
          final String statusText = status == "Reconnecting..."
              ? status
              : (dur == "00:00" ? "$status..." : dur);
          return Text(
            statusText,
            style: TextStyle(
              color: subColor,
              fontSize: 14.sp,
              fontFamily: FontFamily.interMedium,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ],
    );
  }

  Widget _videoPip(CallingController c) {
    final bool showingRemote =
        c.isLocalVideoMain && (c.isVideoOn || !c.isRemoteVideoOn);
    final bool pipHasActiveVideo =
        showingRemote ? c.isRemoteVideoOn : c.isVideoOn;

    return SizedBox(
      width: 110.w,
      height: 150.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                c.toggleVideoViews();
                c.showControlsTemporarily();
              },
              child: Container(
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
                child: (showingRemote &&
                        c.isRemoteVideoOn &&
                        c.isRemoteVideoLoading.value)
                    ? Container(
                        key: const ValueKey<String>('pip_video_wait'),
                        color: const Color(0xFF1A1A2E),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 22.r,
                          height: 22.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white54,
                            ),
                          ),
                        ),
                      )
                    : pipHasActiveVideo
                        ? RTCVideoView(
                            showingRemote ? c.remoteRenderer : c.localRenderer,
                            key: ValueKey<String>(
                              showingRemote
                                  ? 'pip_remote_${c.remoteRenderer.textureId}'
                                  : 'pip_local_${c.localRenderer.textureId}',
                            ),
                            mirror: !showingRemote && c.isFrontCamera,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : Container(
                            key: const ValueKey<String>('pip_video_off'),
                            color: const Color(0xFF1A1A2E),
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white54,
                              size: 32.sp,
                            ),
                          ),
              ),
            ),
          ),
          if (c.isVideoOn)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: c.switchCamera,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 6.h, right: 6.w),
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cameraswitch_rounded,
                      size: 17.sp,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget ctrl({
    required IconData icon,
    required String label,
    required bool isVideo,
    required VoidCallback onTap,
    bool active = false,
    Color? iconColor,
    bool videoInactive = false,
    double size = 52,
  }) {
    final Color base = isVideo ? Colors.white : AppColors.darkText;
    final Color fg = videoInactive ? base.withOpacity(0.35) : base;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: videoInactive ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size.r,
            height: size.r,
            decoration: BoxDecoration(
              color: active
                  ? (isVideo
                      ? Colors.white
                      : AppColors.primaryPurple.withOpacity(0.14))
                  : (isVideo
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.9)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isVideo
                    ? Colors.white.withOpacity(0.18)
                    : Colors.white.withOpacity(0.9),
              ),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: active
                  ? (isVideo ? Colors.black : AppColors.primaryPurple)
                  : (videoInactive ? fg : (iconColor ?? base)),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: videoInactive
                  ? fg.withOpacity(0.7)
                  : (isVideo ? Colors.white : AppColors.darkText),
              fontFamily: FontFamily.interMedium,
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
              Obx(() {
                return ctrl(
                  icon: Icons.screen_share_rounded,
                  label: c.isScreenSharing.value ? "Stop" : "Share",
                  active: c.isScreenSharing.value,
                  isVideo: isVideo,
                  size: 44,
                  onTap: () {
                    if (c.is_video) {
                      c.toggleScreenShare();
                      c.showControlsTemporarily();
                    } else {
                      showCupertinoDialog(
                        context: Get.context!,
                        builder: (dialogContext) {
                          return CupertinoAlertDialog(
                            title: const Text(
                              'Switch to video call to share your screen',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Cancel'),
                              ),
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  c.toggleScreenShare();
                                  c.showControlsTemporarily();
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Switch'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                );
              }),
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
                      if (c.callDurationRx.value > 0 ||
                          c.args["callType"] != "outGoing") {
                        await c.endCall();
                      } else {
                        await c.missedCall();
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
                Obx(() {
                  final bool busy =
                      c.isUpgradingToVideo.value || c.isRemoteUpgrading.value;
                  final bool blocked = c.callStatus.toString() == "busy" ||
                      c.callDurationRx.value == 0;

                  return ctrl(
                    icon: busy
                        ? Icons.hourglass_top_rounded
                        : Icons.videocam_rounded,
                    label: busy ? "Connecting" : "Video",
                    isVideo: isVideo,
                    iconColor: blocked ? Colors.white : AppColors.primaryPurple,
                    videoInactive: blocked || busy,
                    onTap: () {
                      if (blocked || busy) return;
                      c.upgradeToVideoCall();
                      c.showControlsTemporarily();
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectingVideoView extends StatefulWidget {
  const _ConnectingVideoView({required this.name, required this.status});

  final String name;
  final String status;

  @override
  State<_ConnectingVideoView> createState() => _ConnectingVideoViewState();
}

class _ConnectingVideoViewState extends State<_ConnectingVideoView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String get _initials {
    final String raw = widget.name.trim();
    if (raw.isEmpty) return "?";
    final List<String> parts =
        raw.split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String get _label {
    final String status = widget.status.trim();
    if (status.isEmpty || status.toLowerCase() == 'connected') {
      return "Connecting video";
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('main_video_wait'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0E1220),
            Color(0xFF171B2E),
            Color(0xFF0A0D16),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOut.transform(_pulse.value);
          final int dots = 1 + (t * 2.9).floor();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 176.r,
                height: 176.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.86 + (0.22 * t),
                      child: Container(
                        width: 176.r,
                        height: 176.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              AppColors.primaryPurple.withOpacity(
                                0.22 * (1 - t),
                              ),
                              AppColors.primaryPurple.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.74 + (0.10 * t),
                      child: Container(
                        width: 176.r,
                        height: 176.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.10 + (0.12 * (1 - t)),
                            ),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 96.r,
                      height: 96.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            AppColors.primaryPurple.withOpacity(0.95),
                            const Color(0xFF2A2350),
                          ],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Text(
                        _initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.sp,
                          fontFamily: FontFamily.interSemiBold,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 11.r,
                      height: 11.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$_label${"." * dots}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        fontFamily: FontFamily.interMedium,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
