import 'dart:ui';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/draggableVideoPip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

import '../../../../gen/fonts.gen.dart';
import '../Controller/calling_controller.dart';
import '../Services/call_pip.dart';

class CallingScreen extends StatelessWidget {
  CallingScreen({super.key});

  /// The controller is created by `StreamBinding` only. This getter must
  /// never create one: after a call ends the controller deletes itself
  /// while this screen may still be animating out, and a rebuild that
  /// created a new controller would start a NEW call (BUG-CALL-01).
  CallingController get controller => Get.find<CallingController>();

  static const Color _danger = CallColors.end;
  static const Color _warn = Color(0xFFFFB020);
  static const Color _cameraOffBg = CallColors.videoBg;
  static const Color _pipOffBg = Color(0xFF1A1A2E);
  static const Color _panelBg = Color(0xFF1E1F2B);
  static const Color _good = CallColors.accept;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CallingController>()) {
      // Call already ended; the route is closing.
      return const ColoredBox(color: Colors.black);
    }
    final c = controller;
    return GetBuilder<CallingController>(
      init: c,
      builder: (ctrl) => Obx(() => PopScope(
        canPop: ctrl.isMinimized.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          ctrl.minimizeCall();
        },
        child: _screen(context, ctrl),
      )),
    );
  }

  Widget _screen(BuildContext context, CallingController c) {
    final bool isVideo = c.is_video || c.isVideoCall.value;

    // Android picture-in-picture: only the video, no controls.
    if (CallPip.inPip.value && isVideo) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [_mainVideoLayer(c)]),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo) _mainVideoLayer(c) else _audioLayer(c),
          _remoteScreenLayer(context, c),
          if (isVideo) ...[
            _topGradient(),
            _bottomGradient(),
          ],
          _chrome(context, c, isVideo),
          _waitingOverlay(c),
          _pip(c, isVideo),
          _cameraPermissionChip(c),
          _statusPills(c, isVideo),
          _waitingCallBanner(c),
        ],
      ),
    );
  }

  /// Other side's state and link quality (doc 02 §7): "X muted",
  /// "Video paused", "Poor connection", "On hold".
  Widget _statusPills(CallingController c, bool isVideo) {
    return Obx(() {
      final String name = c.args["callerName"]?.toString() ?? '';
      final List<(String, IconData)> pills = <(String, IconData)>[
        if (c.isOnHold.value) (appL10n.call_onHold, Icons.pause_rounded),
        if (c.remoteMicMuted.value)
          (
            appL10n.call_remoteMuted(name.isEmpty ? appL10n.call_someone : name),
            Icons.mic_off_rounded,
          ),
        if (c.remoteVideoPaused.value)
          (appL10n.call_videoPaused, Icons.videocam_off_rounded),
        if (c.isPoorConnection.value)
          (appL10n.call_poorConnection, Icons.network_check_rounded),
      ];
      if (pills.isEmpty) return const SizedBox.shrink();
      final double topInset = MediaQuery.of(Get.context!).padding.top;
      // Under the top bar, so it never covers the name and timer.
      return Positioned(
        left: 16.w,
        right: 16.w,
        top: topInset + (isVideo ? 84.h : 72.h),
        child: Center(
          child: Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            alignment: WrapAlignment.center,
            children: [
              for (final (String text, IconData icon) in pills)
                Container(
                  key: ValueKey<String>('call_pill_$text'),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: text == appL10n.call_poorConnection
                        ? _warn.withValues(alpha: 0.92)
                        : Colors.black.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 14.r),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: FontFamily.interMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// Second incoming call while on this call (BUG-CALL-05):
  /// "X is calling…" with Decline / End & accept.
  Widget _waitingCallBanner(CallingController c) {
    return Obx(() {
      final w = c.waitingCall.value;
      if (w == null) return const SizedBox.shrink();
      final String name = w.callerName.isEmpty ? appL10n.call_unknown : w.callerName;
      return Positioned(
        left: 12.w,
        right: 12.w,
        top: MediaQuery.of(Get.context!).padding.top + 8.h,
        child: Material(
          key: const ValueKey<String>('call_waiting_banner'),
          color: _panelBg,
          elevation: 8,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      w.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: Colors.white70,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        appL10n.call_waitingCall(name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        key: const ValueKey<String>('call_waiting_decline'),
                        style: TextButton.styleFrom(
                          backgroundColor: _danger,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: c.declineWaitingCall,
                        child: Text(appL10n.call_decline),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextButton(
                        key: const ValueKey<String>('call_waiting_accept'),
                        style: TextButton.styleFrom(
                          backgroundColor: CallColors.accept,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: c.endAndAcceptWaitingCall,
                        child: Text(appL10n.call_endAndAccept),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// "Camera off · Allow" when the camera permission is missing (P-06).
  /// Tapping asks for the camera (or opens Settings) and turns it on; the
  /// call continues either way.
  Widget _cameraPermissionChip(CallingController c) {
    return Obx(() {
      if (!c.cameraBlockedByPermission.value) return const SizedBox.shrink();
      return Positioned(
        left: 0,
        right: 0,
        bottom: 150.h,
        child: Center(
          child: Material(
            color: Colors.black.withValues(alpha: 0.55),
            shape: const StadiumBorder(),
            child: InkWell(
              key: const ValueKey<String>('call_camera_permission_chip'),
              customBorder: const StadiumBorder(),
              onTap: c.allowCameraFromChip,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off_rounded,
                        color: Colors.white, size: 18.r),
                    SizedBox(width: 6.w),
                    Text(
                      appL10n.call_permCameraOffChip,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
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
              // Before the call connects the ringing avatar sits in the
              // middle; a "Camera off" tile under it would overlap it.
              : Obx(() => isCallConnected(c)
                  ? _cameraOffTile()
                  : const ColoredBox(
                      key: ValueKey<String>('main_video_waiting'),
                      color: _cameraOffBg,
                      child: SizedBox.expand(),
                    )),
        ),
      ),
    );
  }

  /// Consistent audio call background matching the deep purple/blue design in the screenshot.
  Widget _audioLayer(CallingController c) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: c.showControlsTemporarily,
        child: const DecoratedBox(
          key: ValueKey<String>('audio_call_bg'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: CallColors.audioConnected,
            ),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }

  /// In video calls, clean full-screen camera preview is shown (like WhatsApp)
  /// without a center avatar blocking the camera.
  Widget _videoRingingAvatar(CallingController c) {
    return const SizedBox.shrink();
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
          final bool currentIsVideo = c.is_video || c.isVideoCall.value;
          final bool remoteScreen = c.isRemoteScreenSharing.value;
          final bool connected = isCallConnected(c);
          final bool hideChrome =
              _chromeHidden(c, currentIsVideo, remoteScreen, connected);

          final bool sharing = c.isScreenSharing.value;

          return Column(
            children: [
              if (!hideChrome) _topBar(context, c, currentIsVideo, connected),
              // While I share my screen: a card in the middle with Stop
              // sharing (stays visible when the controls fade out).
              if (sharing)
                Expanded(child: Center(child: _sharingCard(c)))
              else if (!currentIsVideo && !remoteScreen)
                Expanded(child: AudiocallScreen(controller: c))
              else
                const Spacer(),
              if (!hideChrome) _controlsBar(context, c, currentIsVideo, connected),
            ],
          );
        }),
      ),
    );
  }

  /// Audio: ⌄ · "Audio Call" pill · signal dots.
  /// Video: ⌄ · name + status / timer · Share screen (once connected).
  Widget _topBar(
    BuildContext context,
    CallingController c,
    bool isVideo,
    bool connected,
  ) {
    const bool onDark = true;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _topBarButton(
            key: const ValueKey<String>('call_minimize'),
            icon: Icons.keyboard_arrow_down_rounded,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            onDark: onDark,
            onTap: () => c.minimizeCall(),
          ),
          Expanded(
            child: isVideo
                ? _videoTitle(c)
                : Center(child: _callKindPill(onDark: onDark)),
          ),
          if (isVideo && connected)
            _shareTopButton(context, c)
          else if (!isVideo)
            SizedBox(
              width: 44.r,
              child: Center(child: _signalDots(c)),
            )
          else
            SizedBox(width: 44.r),
        ],
      ),
    );
  }

  Widget _videoTitle(CallingController c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _peerName(c),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontFamily: FontFamily.interBold,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        SizedBox(height: 2.h),
        Obx(() {
          final bool reconnecting =
              c.callStatus.value.toLowerCase().startsWith('reconnecting');
          final bool running = isCallConnected(c);
          return Text(
            running && !reconnecting
                ? formatCallDuration(c.callDurationRx.value)
                : '${callStatusLabel(appL10n, c.callStatus.value)}…',
            key: const ValueKey<String>('call_status_text'),
            style: TextStyle(
              color: reconnecting ? _warn : Colors.white.withOpacity(0.85),
              fontSize: 12.sp,
              fontFamily: FontFamily.interMedium,
              fontFeatures: const [FontFeature.tabularFigures()],
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          );
        }),
      ],
    );
  }

  /// Small "📞 Audio Call" label in the middle of the audio top bar.
  Widget _callKindPill({required bool onDark}) {
    final Color fg = onDark ? Colors.white : AppColors.primaryPurple;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withOpacity(0.14)
            : Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call_rounded, color: fg, size: 13.r),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              appL10n.call_secureCallLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 12.sp,
                fontFamily: FontFamily.interMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Connection quality: signal bars, green while the link is good, amber
  /// with fewer bars when the quality monitor reports a poor connection.
  /// Tap shows what it means. (It used to be three dots, which looked like
  /// a "more options" menu that did nothing.)
  Widget _signalDots(CallingController c) {
    return Obx(() {
      final bool poor = c.isPoorConnection.value;
      final String label =
          poor ? appL10n.call_poorConnection : appL10n.call_goodConnection;
      return Tooltip(
        key: const ValueKey<String>('call_signal_quality'),
        message: poor ? appL10n.call_poorConnectionTip : label,
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 3),
        child: Semantics(
          label: label,
          child: SizedBox(
            width: 44.r,
            height: 44.r,
            child: Icon(
              poor
                  ? Icons.signal_cellular_alt_1_bar_rounded
                  : Icons.signal_cellular_alt_rounded,
              color: poor ? _warn : _good,
              size: 20.r,
            ),
          ),
        ),
      );
    });
  }

  /// Screen share in the video top bar (where the mock has its extra icon).
  Widget _shareTopButton(BuildContext context, CallingController c) {
    return Obx(() {
      final bool connected = isCallConnected(c);
      final bool busy = _busy(c) || !connected;
      final bool waiting = c.isScreenShareWaiting.value;
      final bool sharing = c.isScreenSharing.value;
      return Opacity(
        opacity: busy ? 0.4 : 1,
        child: _topBarButton(
          key: const ValueKey<String>('call_share_top'),
          icon: waiting
              ? Icons.close_rounded
              : sharing
                  ? Icons.stop_screen_share_rounded
                  : Icons.screen_share_rounded,
          label: waiting
              ? appL10n.common_cancel
              : (sharing ? appL10n.call_stop : appL10n.call_shareScreen),
          onDark: true,
          active: sharing || waiting,
          onTap: () {
            if (!connected) {
              Utils().fluttertoast(
                "You can share screen after the call is answered.",
              );
              return;
            }
            _onShareTap(context, c, isVideo: true);
          },
        ),
      );
    });
  }

  Widget _topBarButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool onDark,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final Color bg = active
        ? Colors.white
        : (onDark
            ? Colors.black.withOpacity(0.28)
            : Colors.white.withOpacity(0.85));
    final Color fg = active
        ? const Color(0xFF1B1530)
        : (onDark ? Colors.white : AppColors.primaryPurple);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: CircleBorder(
          side: BorderSide(color: onDark ? Colors.white24 : Colors.white),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: key,
          onTap: onTap,
          child: SizedBox(
            width: 44.r,
            height: 44.r,
            child: Icon(icon, color: fg, size: 24.r),
          ),
        ),
      ),
    );
  }

  /// Video controls fade out after a few seconds, but only once the call is
  /// connected: while it rings, End must always stay on screen.
  bool _chromeHidden(
    CallingController c,
    bool isVideo,
    bool remoteScreen,
    bool connected,
  ) {
    return connected &&
        !c.areControlsVisible.value &&
        (isVideo || c.isVideoCall.value || remoteScreen);
  }

  Widget _controlsBar(
    BuildContext context,
    CallingController c,
    bool isVideo,
    bool connected,
  ) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.showControlsTemporarily,
          child: _bottomControls(context, c, isVideo, connected),
        ),
      ),
    );
  }

  Widget _pip(CallingController c, bool isVideo) {
    return Obx(() {
      final bool waiting = c.isScreenShareWaiting.value;
      final bool remoteScreen = c.isRemoteScreenSharing.value;
      final bool chromeVisible = c.areControlsVisible.value;
      // Before the call connects only your own camera is shown (full
      // screen); the small window appears once the other side joins.
      final bool hidden = !isVideo ||
          !isCallConnected(c) ||
          waiting ||
          (remoteScreen && !chromeVisible);
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
                // "X is sharing their screen": always visible, below the
                // top bar while it shows, at the top edge when it fades.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: MediaQuery.of(context).padding.top +
                      (chromeVisible ? 76.h : 12.h),
                  left: 16.w,
                  right: 16.w,
                  child: IgnorePointer(
                    child: Center(
                      child: _glassPill(
                        icon: Icons.screen_share_rounded,
                        text: _remoteShareText(c),
                        live: true,
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
        ? appL10n.call_screenBeingShared
        : appL10n.call_personSharingScreen(name);
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
            appL10n.call_cameraOff,
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

  Widget _glassPill({
    required IconData icon,
    required String text,
    bool live = false,
  }) {
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
          if (live) ...[
            const _PulseDot(color: _danger),
            SizedBox(width: 8.w),
          ],
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: FontFamily.interMedium,
            ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown in the middle of the call screen while I share my screen
  /// (WhatsApp style): what is happening, who sees it, and a big red
  /// Stop sharing button. Built inside the chrome `Obx`, which already
  /// reads `isScreenSharing`; this one reads `isScreenShareLive`.
  Widget _sharingCard(CallingController c) {
    return Obx(() {
      final bool live = c.isScreenShareLive.value;
      final String name = _peerName(c);
      final String title = live
          ? appL10n.call_youAreSharingScreen
          : appL10n.call_startingScreenShare;
      final String subtitle = live
          ? (name.isEmpty
              ? appL10n.call_screenVisibleToOther
              : appL10n.call_screenVisibleToName(name))
          : appL10n.call_tapStartBroadcastHint;

      return Padding(
        key: const ValueKey<String>('call_sharing_card'),
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 22.h),
              decoration: BoxDecoration(
                color: CallColors.videoGlass,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.screen_share_rounded,
                          color: Colors.white,
                          size: 34.r,
                        ),
                      ),
                      Positioned(
                        right: 2.r,
                        top: 2.r,
                        child: _PulseDot(color: live ? _danger : _warn),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontFamily: FontFamily.interSemiBold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interMedium,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      key: const ValueKey<String>('call_stop_sharing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        c.stopScreenShare();
                        c.showControlsTemporarily();
                      },
                      icon: Icon(Icons.stop_screen_share_rounded, size: 20.r),
                      label: Text(
                        appL10n.call_stopSharing,
                        style: TextStyle(
                          fontSize: 14.sp,
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
                        appL10n.call_waitingForBroadcast,
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
                        appL10n.call_waitingForBroadcastMessage,
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
                            appL10n.common_cancel,
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

  /// Small draggable window: your camera (or theirs after a swap). Tap to
  /// swap the two views.
  Widget _videoPip(CallingController c) {
    final bool showingRemote =
        c.isLocalVideoMain && (c.isVideoOn || !c.isRemoteVideoOn);
    final bool hasVideo = showingRemote ? c.isRemoteVideoOn : c.isVideoOn;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        c.toggleVideoViews();
        c.showControlsTemporarily();
      },
      // Same size as DraggableVideoPip.pipWidth / pipHeight, so dragging
      // stops exactly at the screen edges.
      child: Container(
        width: 100.w,
        height: 150.h,
        decoration: BoxDecoration(
          color: _pipOffBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
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
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : Column(
                key: const ValueKey<String>('pip_video_off'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showingRemote)
                    CallAvatar(
                      name: _peerName(c),
                      image: c.args["profileImage"],
                      size: 48.r,
                    )
                  else
                    Icon(Icons.videocam_off_rounded,
                        color: Colors.white70, size: 26.r),
                  SizedBox(height: 8.h),
                  Text(
                    appL10n.call_cameraOff,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.sp,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Bottom controls, following the mock:
  /// * Audio calling (light): white card with Speaker, Video, Mute, End.
  /// * Audio connected (purple): Speaker, Mute, Video, Share, then a big
  ///   End call button.
  /// * Video ringing: dark bar with Switch, Camera, Mute, End.
  /// * Video connected: dark bar with Speaker, Camera, Mute, Switch, End
  ///   (screen share is in the top bar).
  Widget _bottomControls(
    BuildContext context,
    CallingController c,
    bool isVideo,
    bool connected,
  ) {
    if (!isVideo) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio call controls row: matching the design system
          _evenRow([
            _speakerControl(context, c, true,
                size: 54, activeIconColor: CallColors.primary),
            _micControl(c, true,
                size: 54, activeIconColor: CallColors.primary),
            _upgradeControl(c, true, size: 54),
            _shareControl(context, c, true,
                size: 54, activeIconColor: CallColors.primary),
          ]),
          SizedBox(height: 28.h),
          _endControl(c, true, size: 68, label: appL10n.call_endCall),
          SizedBox(height: 8.h),
        ],
      );
    }

    final List<Widget> buttons = connected
        ? <Widget>[
            _speakerControl(context, c, true),
            _cameraControl(c, true),
            _micControl(c, true),
            _flipControl(c),
            _endControl(c, true, size: 52, label: appL10n.call_end),
          ]
        : <Widget>[
            _flipControl(c),
            _cameraControl(c, true),
            _micControl(c, true),
            _endControl(c, true, size: 52, label: appL10n.call_end),
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: CallColors.videoGlass,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _evenRow(buttons),
        ),
      ),
    );
  }

  /// Equal share of the width for every button, so 5 buttons with long
  /// labels (Hindi, Tamil, German …) never overflow a narrow phone.
  Widget _evenRow(List<Widget> buttons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final Widget b in buttons)
          Expanded(child: Center(child: b)),
      ],
    );
  }

  bool _busy(CallingController c) {
    return c.isUpgradingToVideo.value || c.isRemoteUpgrading.value;
  }

  bool _blocked(CallingController c) {
    final s = c.callStatus.value.toLowerCase();
    return s == "busy" || (!isCallConnected(c) && !c.isCallLive);
  }

  /// Same behaviour for the bottom Share button (audio) and the top-bar
  /// share button (video).
  void _onShareTap(
    BuildContext context,
    CallingController c, {
    required bool isVideo,
  }) {
    if (!isCallConnected(c)) {
      Utils().fluttertoast(
        "You can share screen after the call is answered.",
      );
      return;
    }
    if (_blocked(c) || _busy(c)) return;
    if (c.isScreenShareWaiting.value) {
      c.cancelScreenShare();
      c.showControlsTemporarily();
      return;
    }
    if (c.isScreenSharing.value) {
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
  }

  Widget _shareControl(
    BuildContext context,
    CallingController c,
    bool onDark, {
    double size = 52,
    Color? activeIconColor,
  }) {
    return Obx(() {
      final bool waiting = c.isScreenShareWaiting.value;
      final bool sharing = c.isScreenSharing.value;
      final bool isVideo = c.is_video || c.isVideoCall.value;
      final bool connected = isCallConnected(c);
      final bool blocked = _blocked(c) || _busy(c) || !connected;

      return ctrl(
        icon: waiting
            ? Icons.close_rounded
            : sharing
                ? Icons.stop_screen_share_rounded
                : Icons.screen_share_rounded,
        label: waiting
            ? appL10n.common_cancel
            : (sharing ? appL10n.call_stop : appL10n.call_shareScreenShort),
        active: sharing || waiting,
        isVideo: onDark,
        size: size,
        activeIconColor: activeIconColor,
        videoInactive: blocked,
        onTap: () {
          if (!connected) {
            Utils().fluttertoast(
              "You can share screen after the call is answered.",
            );
            return;
          }
          _onShareTap(context, c, isVideo: isVideo);
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
        title: Text(dialogContext.l10n.call_switchToVideoToShare),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.common_cancel),
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
            child: Text(dialogContext.l10n.call_switch),
          ),
        ],
      ),
    );
  }

  Widget _speakerControl(
    BuildContext context,
    CallingController c,
    bool onDark, {
    double size = 52,
    Color? activeIconColor,
  }) {
    return Obx(() {
      final CallAudioRoute route = c.audioRouteController.currentRoute.value;

      return ctrl(
        icon: c.audioRouteController.currentAudioRouteIcon,
        label: c.audioRouteController.currentAudioRouteLabel,
        active: route != CallAudioRoute.earpiece,
        isVideo: onDark,
        size: size,
        activeIconColor: activeIconColor,
        onTap: () async {
          await c.toggleSpeaker(context);
          c.showControlsTemporarily();
        },
      );
    });
  }

  /// [label]: "End" inside a button bar, "End call" for the big button.
  Widget _endControl(
    CallingController c,
    bool onDark, {
    required double size,
    required String label,
  }) {
    return endCallButton(
      label: label,
      isVideo: onDark,
      size: size,
      onTap: () async {
        if (c.callDurationRx.value > 0 || c.args["callType"] != "outGoing") {
          await c.endCall();
        } else {
          await c.missedCall();
        }
      },
    );
  }

  Widget _micControl(
    CallingController c,
    bool onDark, {
    double size = 52,
    Color? activeIconColor,
  }) {
    return Obx(() {
      final bool micOn = c.isAudioOnRx.value;
      return ctrl(
        icon: micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
        label: micOn ? appL10n.call_mute : appL10n.call_unmute,
        active: !micOn,
        isVideo: onDark,
        size: size,
        activeIconColor: activeIconColor,
        onTap: () {
          c.toggleMic();
          c.showControlsTemporarily();
        },
      );
    });
  }

  /// Camera on / off. Filled white while the camera is ON, as in the mock.
  Widget _cameraControl(CallingController c, bool onDark) {
    return ctrl(
      icon: c.isVideoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
      label: c.isVideoOn ? appL10n.call_camera : appL10n.call_cameraOff,
      active: c.isVideoOn,
      isVideo: onDark,
      onTap: () {
        c.toggleCamera();
        c.showControlsTemporarily();
      },
    );
  }

  Widget _flipControl(CallingController c) {
    return ctrl(
      icon: Icons.cameraswitch_rounded,
      label: appL10n.call_switch,
      isVideo: true,
      videoInactive: !c.isVideoOn,
      onTap: () {
        if (!c.isVideoOn) return;
        c.switchCamera();
        c.showControlsTemporarily();
      },
    );
  }

  Widget _upgradeControl(
    CallingController c,
    bool onDark, {
    double size = 52,
  }) {
    return Obx(() {
      final bool busy = _busy(c);
      final bool connected = isCallConnected(c);
      final bool blocked = _blocked(c) || !connected;

      return ctrl(
        icon: busy ? Icons.hourglass_top_rounded : Icons.videocam_rounded,
        label: busy ? appL10n.call_statusConnecting : appL10n.call_video,
        isVideo: onDark,
        size: size,
        videoInactive: blocked || busy,
        onTap: () {
          if (!connected) {
            Utils().fluttertoast(
              "You can switch to video after the call is answered.",
            );
            return;
          }
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
