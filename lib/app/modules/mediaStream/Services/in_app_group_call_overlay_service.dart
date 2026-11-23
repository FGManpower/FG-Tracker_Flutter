import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class InAppGroupCallOverlayService {
  InAppGroupCallOverlayService._();
  static final InAppGroupCallOverlayService instance =
      InAppGroupCallOverlayService._();

  OverlayEntry? _overlayEntry;
  Offset _position = Offset(16.w, 100.h);
  bool _isOverlayShowing = false;

  bool get isOverlayShowing => _isOverlayShowing;

  void showOverlay(GroupCallingController controller) {
    if (_isOverlayShowing) return;

    final OverlayState? overlayState = Get.key.currentState?.overlay ??
        (Get.overlayContext != null ? Overlay.maybeOf(Get.overlayContext!) : null);

    if (overlayState == null) {
      Get.log('[InAppGroupCallOverlay] No OverlayState found to attach floating bubble');
      return;
    }

    _isOverlayShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => _FloatingGroupCallBubble(
        controller: controller,
        initialPosition: _position,
        onPositionChanged: (newPos) => _position = newPos,
        onExpand: () => expandCall(controller),
        onEndCall: () {
          hideOverlay();
          controller.endCall();
        },
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void hideOverlay() {
    if (!_isOverlayShowing) return;
    _isOverlayShowing = false;
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  void expandCall(GroupCallingController controller) {
    hideOverlay();
    controller.isMinimized.value = false;
    if (Get.currentRoute != Routes.groupCallingScreen) {
      Get.toNamed(
        Routes.groupCallingScreen,
        arguments: {
          'groupId': controller.groupId,
          'groupName': controller.groupName,
          'groupProfile': controller.groupProfile,
          'isVideo': controller.isVideo,
          'callType': 'ongoing',
          'callId': controller.callId,
          'memberCount': controller.totalMemberCount,
        },
      );
    }
  }
}

class _FloatingGroupCallBubble extends StatefulWidget {
  final GroupCallingController controller;
  final Offset initialPosition;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onExpand;
  final VoidCallback onEndCall;

  const _FloatingGroupCallBubble({
    required this.controller,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onExpand,
    required this.onEndCall,
  });

  @override
  State<_FloatingGroupCallBubble> createState() =>
      _FloatingGroupCallBubbleState();
}

class _FloatingGroupCallBubbleState extends State<_FloatingGroupCallBubble> {
  late Offset _pos;

  @override
  void initState() {
    super.initState();
    _pos = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double bubbleWidth = 145.w;
    final double bubbleHeight = 200.h;

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final double newX = (_pos.dx + details.delta.dx)
                .clamp(8.0, screenSize.width - bubbleWidth - 8.0);
            final double newY = (_pos.dy + details.delta.dy)
                .clamp(40.0, screenSize.height - bubbleHeight - 40.0);
            _pos = Offset(newX, newY);
          });
          widget.onPositionChanged(_pos);
        },
        onTap: widget.onExpand,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: bubbleWidth,
            height: bubbleHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1E262C),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white24, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.50),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background media / avatar
                _buildMediaContent(),

                // Top Header Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.controller.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Obx(
                            () => Text(
                              '${widget.controller.activeParticipants.length}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Control & Duration Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            widget.controller.formattedDuration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onEndCall,
                          child: Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEA4335),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    return Obx(() {
      final c = widget.controller;
      final bool isVideoActive = c.isVideo && c.isVideoOn.value;

      if (isVideoActive && c.localRenderer.srcObject != null) {
        return RTCVideoView(
          c.localRenderer,
          mirror: c.isFrontCamera.value,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        );
      }

      // Audio mode or camera off: show group avatar
      final imgUrl = Utility.isNullEmptyOrFalse(c.groupProfile)
          ? MyAppTheme.ProfilenotFoundImg
          : (c.groupProfile!.startsWith('http')
              ? c.groupProfile!
              : ConstRes.aImageBaseUrl + c.groupProfile!);

      return Container(
        color: const Color(0xFF1B2730),
        child: Center(
          child: CircleAvatar(
            radius: 32.r,
            backgroundColor: Colors.white12,
            backgroundImage: CachedNetworkImageProvider(imgUrl),
          ),
        ),
      );
    });
  }
}
