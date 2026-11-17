import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class InAppCallOverlayService {
  InAppCallOverlayService._();
  static final InAppCallOverlayService instance = InAppCallOverlayService._();

  OverlayEntry? _overlayEntry;
  Offset _position = Offset(16.w, 100.h);
  bool _isOverlayShowing = false;

  bool get isOverlayShowing => _isOverlayShowing;

  void showOverlay(CallingController controller) {
    if (_isOverlayShowing) return;

    final OverlayState? overlayState = Get.overlayContext != null
        ? Overlay.of(Get.overlayContext!)
        : (Get.key.currentState?.overlay);

    if (overlayState == null) {
      Get.log('[InAppCallOverlay] No OverlayState found to attach floating bubble');
      return;
    }

    _isOverlayShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => _FloatingCallBubble(
        controller: controller,
        initialPosition: _position,
        onPositionChanged: (newPos) => _position = newPos,
        onExpand: () => expandCall(controller),
        onEndCall: () {
          hideOverlay();
          controller.endCall(type: 'UserEndedFromOverlay');
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

  void expandCall(CallingController controller) {
    hideOverlay();
    controller.isMinimized.value = false;
    Get.toNamed(
      Routes.callScreen,
      arguments: controller.args,
    );
  }
}

class _FloatingCallBubble extends StatefulWidget {
  final CallingController controller;
  final Offset initialPosition;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onExpand;
  final VoidCallback onEndCall;

  const _FloatingCallBubble({
    required this.controller,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onExpand,
    required this.onEndCall,
  });

  @override
  State<_FloatingCallBubble> createState() => _FloatingCallBubbleState();
}

class _FloatingCallBubbleState extends State<_FloatingCallBubble> {
  late Offset _pos;

  @override
  void initState() {
    super.initState();
    _pos = widget.initialPosition;
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isVideo = widget.controller.isVideoCall.value &&
        (widget.controller.isRemoteVideoOn || widget.controller.isVideoOn);

    final double cardWidth = isVideo ? 120.w : 190.w;
    final double cardHeight = isVideo ? 165.h : 68.h;

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final double newX = (_pos.dx + details.delta.dx).clamp(
              8.0,
              screenSize.width - cardWidth - 8.0,
            );
            final double newY = (_pos.dy + details.delta.dy).clamp(
              40.0,
              screenSize.height - cardHeight - 40.0,
            );
            _pos = Offset(newX, newY);
            widget.onPositionChanged(_pos);
          });
        },
        onTap: widget.onExpand,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.transparent,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1F2B),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.8),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: isVideo
                ? _buildVideoBubble(context)
                : _buildAudioBubble(context),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBubble(BuildContext context) {
    final c = widget.controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (c.isRemoteVideoOn)
          RTCVideoView(
            c.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        else if (c.isVideoOn)
          RTCVideoView(
            c.localRenderer,
            mirror: c.isFrontCamera,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        else
          Container(
            color: const Color(0xFF14151F),
            child: const Center(
              child: Icon(Icons.videocam_off, color: Colors.white54, size: 28),
            ),
          ),
        // Overlay Controls
        Positioned(
          top: 6.h,
          right: 6.w,
          child: GestureDetector(
            onTap: widget.onEndCall,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call_end, color: Colors.white, size: 14.sp),
            ),
          ),
        ),
        Positioned(
          bottom: 6.h,
          left: 6.w,
          right: 6.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Obx(() => Text(
                  _formatDuration(c.callDurationRx.value),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioBubble(BuildContext context) {
    final c = widget.controller;
    final String callerName = c.args?["callerName"]?.toString() ?? "Active Call";
    final String? profileImage = c.args?["profileImage"]?.toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFF2C2D3E),
            backgroundImage: profileImage != null && profileImage.isNotEmpty
                ? CachedNetworkImageProvider(
                    profileImage.startsWith('http')
                        ? profileImage
                        : '${ConstRes.aImageBaseUrl}$profileImage',
                  )
                : const AssetImage(MyAppTheme.ProfilenotFoundImg) as ImageProvider,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(() => Text(
                      _formatDuration(c.callDurationRx.value),
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onEndCall,
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call_end, color: Colors.white, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}

