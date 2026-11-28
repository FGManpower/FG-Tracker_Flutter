import 'dart:ui';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
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
  CallingScreen({super.key});

  final controller = Get.put(CallingController());

  static const Color _danger = Color(0xFFFF3B30);
  static const Color _warn = Color(0xFFFFB020);
  static const Color _cameraOffBg = Color(0xFF12131F);
  static const Color _pipOffBg = Color(0xFF1A1A2E);
  static const Color _panelBg = Color(0xFF1E1F2B);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<CallingController>(builder: (c) => _screen(context, c)),
    );
  }

  Widget _screen(BuildContext context, CallingController c) {
    final bool isVideo = c.is_video || c.isVideoCall.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo) _mainVideoLayer(c) else _audioLayer(c),
          _remoteScreenLayer(context, c),
          if (isVideo) ...[_topGradient(), _bottomGradient()],
          _chrome(context, c, isVideo),
          _waitingOverlay(c),
          _pip(c, isVideo),
        ],
      ),
    );
  }

  Widget _mainVideoLayer(CallingController c) {
    final bool showLocalInMain =
        c.isLocalVideoMain && (c.isVideoOn || !c.isRemoteVideoOn);
    final bool hasVideo = showLocalInMain ? c.isVideoOn : c.isRemoteVideoOn;

    return Positioned.fill(
      child: RepaintBoundary(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.toggleControls,
          child: hasVideo
              ? RTCVideoView(
                  showLocalInMain ? c.localRenderer : c.remoteRenderer,
                  key: ValueKey<String>(
                    showLocalInMain
                        ? 'main_local_${c.localRenderer.textureId}'
                        : 'main_remote_${c.remoteRenderer.textureId}',
                  ),
                  mirror: showLocalInMain && c.isFrontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : _cameraOffTile(),
        ),
      ),
    );
  }

  Widget _audioLayer(CallingController c) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: c.showControlsTemporarily,
        child: const AudioBackground(),
      ),
    );
  }

  Widget _topGradient() {
    return Positioned(
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
              colors: [Colors.black.withOpacity(0.55), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomGradient() {
    return Positioned(
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
              colors: [Colors.black.withOpacity(0.55), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chrome(
    BuildContext context,
    CallingController c,
    bool isVideo,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Obx(() {
          final bool remoteScreen = c.isRemoteScreenSharing.value;
          final bool hideChrome = _chromeHidden(c, isVideo, remoteScreen);

          return Column(
            children: [
              if (isVideo && !hideChrome) IgnorePointer(child: _topInfo(c)),
              _shareBanner(c),
              if (!isVideo && !remoteScreen)
                Expanded(child: AudiocallScreen(controller: c))
              else
                const Spacer(),
              if (!hideChrome) _controlsBar(context, c, isVideo),
            ],
          );
        }),
      ),
    );
  }

  bool _chromeHidden(
    CallingController c,
    bool isVideo,
    bool remoteScreen,
  ) {
    return !c.areControlsVisible.value &&
        (isVideo || c.isVideoCall.value || remoteScreen);
  }

  Widget _controlsBar(
    BuildContext context,
    CallingController c,
    bool isVideo,
  ) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 22.h),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.showControlsTemporarily,
          child: _bottomControls(context, c, isVideo),
        ),
      ),
    );
  }

  Widget _pip(CallingController c, bool isVideo) {
    return Obx(() {
      final bool waiting = c.isScreenShareWaiting.value;
      final bool remoteScreen = c.isRemoteScreenSharing.value;
      final bool chromeVisible = c.areControlsVisible.value;
      final bool hidden =
          !isVideo || waiting || (remoteScreen && !chromeVisible);
      if (hidden) return const SizedBox.shrink();
      return Positioned.fill(
        child: DraggableVideoPip(
          controller: c,
          child: RepaintBoundary(child: _videoPip(c)),
        ),
      );
    });
  }

  Widget _remoteScreenLayer(BuildContext context, CallingController c) {
    return Obx(() {
      final bool active = c.isRemoteScreenSharing.value;
      final bool chromeVisible = c.areControlsVisible.value;
      if (!active) return const SizedBox.shrink();

      return Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (chromeVisible) {
              c.toggleControls();
            } else {
              c.showControlsTemporarily();
            }
          },
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (c.screenRenderer.textureId == null)
                  const Center(child: _LoadingDot())
                else
                  RTCVideoView(
                    c.screenRenderer,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  ),
                if (chromeVisible)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10.h,
                    left: 16.w,
                    right: 16.w,
                    child: IgnorePointer(
                      child: Center(
                        child: _glassPill(
                          icon: Icons.screen_share_rounded,
                          text: _remoteShareText(c),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _remoteShareText(CallingController c) {
    final String name = _peerName(c);
    return name.isEmpty
        ? "Screen is being shared"
        : "$name is sharing the screen";
  }

  Widget _cameraOffTile() {
    return Container(
      key: const ValueKey<String>('main_video_off'),
      color: _cameraOffBg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84.r,
            height: 84.r,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
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
    );
  }

  Widget _glassPill({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: FontFamily.interMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareBanner(CallingController c) {
    return Obx(() {
      final bool sharing = c.isScreenSharing.value;
      final bool live = c.isScreenShareLive.value;
      if (!sharing) return const SizedBox.shrink();

      final String name = _peerName(c);
      final String title =
          live ? "You're sharing your screen" : "Starting screen share…";
      final String subtitle = live
          ? (name.isEmpty
              ? "Your screen is visible to the other person"
              : "Your screen is visible to $name")
          : "Tap Start Broadcast if the system prompt appears";

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 11.h, 10.w, 11.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _PulseDot(color: live ? _danger : _warn),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interSemiBold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 11.sp,
                            fontFamily: FontFamily.interMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      c.stopScreenShare();
                      c.showControlsTemporarily();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: _danger,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: _danger.withOpacity(0.40),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Stop sharing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interSemiBold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _waitingOverlay(CallingController c) {
    return Obx(() {
      final bool waiting = c.isScreenShareWaiting.value;
      if (!waiting) return const SizedBox.shrink();

      return Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Container(
            color: Colors.black.withOpacity(0.74),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 16.h),
                  decoration: BoxDecoration(
                    color: _panelBg.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 34.r,
                        height: 34.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "Waiting for Start Broadcast",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontFamily: FontFamily.interSemiBold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Tap \u201CStart Broadcast\u201D in the system dialog "
                        "to share your screen. Sharing begins only after that.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          c.cancelScreenShare();
                          c.showControlsTemporarily();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.14),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontFamily: FontFamily.interSemiBold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  String _peerName(CallingController c) {
    return (c.args["callerName"] ?? "").toString().trim();
  }

  Widget _topInfo(CallingController c) {
    final bool isOutgoing = c.args["callType"] == "outGoing";

    return Column(
      children: [
        Text(
          isOutgoing ? "" : "Call From",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            fontFamily: FontFamily.interMedium,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "${c.args["callerName"] ?? ""}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            fontFamily: FontFamily.interSemiBold,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          final String dur = c.formattedDuration;
          return Text(
            dur == "00:00" ? "${c.callStatus.value}..." : dur,
            style: TextStyle(
              color: Colors.white70,
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
    final bool hasVideo = showingRemote ? c.isRemoteVideoOn : c.isVideoOn;

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
                child: hasVideo
                    ? RTCVideoView(
                        showingRemote ? c.remoteRenderer : c.localRenderer,
                        key: ValueKey<String>(
                          showingRemote
                              ? 'pip_remote_${c.remoteRenderer.textureId}'
                              : 'pip_local_${c.localRenderer.textureId}',
                        ),
                        mirror: !showingRemote && c.isFrontCamera,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        key: const ValueKey<String>('pip_video_off'),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF252B38),
                              Color(0xFF11151E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 25.sp,
                                backgroundColor: const Color(0xFF343B49),
                                backgroundImage: NetworkImage(
                                  Utility.isNotNullEmptyOrFalse(
                                          c.args["profileImage"])
                                      ? ConstRes.aImageBaseUrl +
                                          c.args["profileImage"]
                                      : MyAppTheme.notFoundImg,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videocam_off_rounded,
                                    color: Colors.white70,
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Camera off',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          if (c.isVideoOn) _switchCameraButton(c),
        ],
      ),
    );
  }

  Widget _switchCameraButton(CallingController c) {
    return Positioned(
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
    );
  }

  Widget _bottomControls(
    BuildContext context,
    CallingController c,
    bool isVideo,
  ) {
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
              _shareControl(context, c, isVideo),
              _speakerControl(context, c, isVideo),
              _endControl(c, isVideo),
              _micControl(c, isVideo),
              if (isVideo)
                _cameraControl(c, isVideo)
              else
                _upgradeControl(c, isVideo),
            ],
          ),
        ),
      ),
    );
  }

  bool _busy(CallingController c) {
    return c.isUpgradingToVideo.value || c.isRemoteUpgrading.value;
  }

  bool _blocked(CallingController c) {
    return c.callStatus.toString() == "busy" || c.callDurationRx.value == 0;
  }

  Widget _shareControl(
    BuildContext context,
    CallingController c,
    bool isVideo,
  ) {
    return Obx(() {
      final bool busy = _busy(c);
      final bool blocked = _blocked(c);
      final bool waiting = c.isScreenShareWaiting.value;
      final bool sharing = c.isScreenSharing.value;

      return ctrl(
        icon: waiting
            ? Icons.close_rounded
            : sharing
                ? Icons.stop_screen_share_rounded
                : Icons.screen_share_rounded,
        label: waiting ? "Cancel" : (sharing ? "Stop" : "Share"),
        active: sharing || waiting,
        isVideo: isVideo,
        iconColor: blocked ? Colors.white : null,
        videoInactive: blocked || busy,
        onTap: () {
          if (blocked || busy) return;

          if (waiting) {
            c.cancelScreenShare();
            c.showControlsTemporarily();
            return;
          }

          if (sharing) {
            c.stopScreenShare();
            c.showControlsTemporarily();
            return;
          }

          if (isVideo) {
            c.startScreenShare();
            c.showControlsTemporarily();
            return;
          }

          _askSwitchToVideoThenShare(context, c);
        },
      );
    });
  }

  void _askSwitchToVideoThenShare(
    BuildContext context,
    CallingController c,
  ) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Switch to video call to share your screen"),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.pop(dialogContext);
              await c.upgradeToVideoCall();
              if (c.isClosed) return;
              await c.startScreenShare();
              c.showControlsTemporarily();
            },
            child: const Text("Switch"),
          ),
        ],
      ),
    );
  }

  Widget _speakerControl(
    BuildContext context,
    CallingController c,
    bool isVideo,
  ) {
    return Obx(() {
      final CallAudioRoute route = c.audioRouteController.currentRoute.value;

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
    });
  }

  Widget _endControl(CallingController c, bool isVideo) {
    return Column(
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
            decoration: BoxDecoration(
              color: _danger,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _danger.withOpacity(0.40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
    );
  }

  Widget _micControl(CallingController c, bool isVideo) {
    return ctrl(
      icon: c.isAudioOn ? Icons.mic_rounded : Icons.mic_off_rounded,
      label: "Mute",
      active: !c.isAudioOn,
      isVideo: isVideo,
      onTap: () {
        c.toggleMic();
        c.showControlsTemporarily();
      },
    );
  }

  Widget _cameraControl(CallingController c, bool isVideo) {
    return ctrl(
      icon: c.isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
      label: c.isVideoOn ? "Camera" : "Camera Off",
      active: !c.isVideoOn,
      isVideo: isVideo,
      onTap: () {
        c.toggleCamera();
        c.showControlsTemporarily();
      },
    );
  }

  Widget _upgradeControl(CallingController c, bool isVideo) {
    return Obx(() {
      final bool busy = _busy(c);
      final bool blocked = _blocked(c);

      return ctrl(
        icon: busy ? Icons.hourglass_top_rounded : Icons.videocam_rounded,
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
    });
  }
}

class _LoadingDot extends StatelessWidget {
  const _LoadingDot();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});

  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        return Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.25 + 0.45 * t),
                blurRadius: 4 + 8 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}
