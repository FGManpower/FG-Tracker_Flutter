import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../global_widget/common_widget.dart';
import '../../Controller/group_incoming_call_controller.dart';

class GroupIncomingCallScreen extends GetView<GroupIncomingCallController> {
  const GroupIncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0B29),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              _buildIncomingBadge(),
              SizedBox(height: 60.h),
              _buildStackedAvatars(),
              SizedBox(height: 30.h),
              reausabletext(
                controller.groupName,
                fontsize: 28,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              reausabletext(
                "${controller.callerName} and ${controller.totalMemberCount - 1} others",
                fontsize: 16,
                fontfamily: FontFamily.interRegular,
                color: const Color(0xFFB1A9D1),
              ),
              SizedBox(height: 40.h),
              _buildInfoCard(),
              const Spacer(),
              const Icon(
                Icons.keyboard_double_arrow_up,
                color: Color(0xFF6E5CA4),
                size: 30,
              ),
              SizedBox(height: 20.h),
              _buildActionButtons(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.isVideo ? Icons.videocam : Icons.call,
            color: const Color(0xFF9880FA),
            size: 20,
          ),
          SizedBox(width: 8.w),
          reausabletext(
            "Incoming group ${controller.isVideo ? "video" : "audio"} call",
            fontsize: 14,
            fontfamily: FontFamily.interMedium,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars() {
    return SizedBox(
      height: 90.h,
      width: 250.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0, child: _circleAvatar(radius: 35.r)),
          Positioned(left: 45.w, child: _circleAvatar(radius: 40.r)),
          Positioned(right: 45.w, child: _circleAvatar(radius: 40.r)),
          Positioned(right: 0, child: _circleAvatar(radius: 35.r)),
          Positioned(
            child: Container(
              height: 90.r,
              width: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6E5CA4),
                border: Border.all(color: const Color(0xFF0F0B29), width: 4),
              ),
              alignment: Alignment.center,
              child: reausabletext(
                "+${controller.activeMemberCount}",
                fontsize: 20,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAvatar({required double radius}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey,
      backgroundImage: const NetworkImage("https://via.placeholder.com/150"),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1147),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Color(0xFF6E5CA4), size: 30),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "${controller.activeMemberCount} members in this call",
                  fontsize: 16,
                  fontfamily: FontFamily.interMedium,
                  color: Colors.white,
                ),
                SizedBox(height: 4.h),
                reausabletext(
                  "You will join as soon as you answer",
                  fontsize: 13,
                  fontfamily: FontFamily.interRegular,
                  color: const Color(0xFFB1A9D1),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          icon: Icons.close,
          label: "Decline",
          color: const Color(0xFF2A2146),
          iconColor: Colors.white,
          onTap: controller.declineCall,
        ),
        _SlideUpJoinButton(
          isVideo: controller.isVideo,
          onJoin: controller.joinCall,
        ),
        Obx(() => _actionButton(
              icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
              label: controller.isMuted.value ? "Muted" : "Mute",
              color: const Color(0xFF2A2146),
              iconColor: Colors.white,
              onTap: controller.toggleMute,
            )),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            height: 65.r,
            width: 65.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30.sp),
          ),
        ),
        SizedBox(height: 10.h),
        reausabletext(
          label,
          fontsize: 14,
          fontfamily: FontFamily.interMedium,
          color: Colors.white,
        ),
      ],
    );
  }
}

class _SlideUpJoinButton extends StatefulWidget {
  final bool isVideo;
  final VoidCallback onJoin;

  const _SlideUpJoinButton({
    required this.isVideo,
    required this.onJoin,
  });

  @override
  State<_SlideUpJoinButton> createState() => _SlideUpJoinButtonState();
}

class _SlideUpJoinButtonState extends State<_SlideUpJoinButton>
    with SingleTickerProviderStateMixin {
  final RxDouble dragOffset = 0.0.obs;
  final RxBool isJoined = false.obs;
  final RxBool isDragging = false.obs;

  static const double _joinThreshold = 70.0;
  static const double _maxDrag = 90.0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _stopPulse() {
    if (_pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  void _startPulse() {
    if (!_pulseController.isAnimating && !isJoined.value) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80.r,
          width: 80.r,
          child: Obx(() {
            final offset = dragOffset.value;
            final joined = isJoined.value;
            final dragging = isDragging.value;

            return Transform.translate(
              offset: Offset(0, offset),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (!joined && !dragging)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) {
                        final v = _pulseAnimation.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 80.r * v,
                              width: 80.r * v,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF9880FA)
                                    .withOpacity((1.12 - v) * 0.35),
                              ),
                            ),
                            Container(
                              height: 80.r * (0.85 + (v - 1.0) * 2.5),
                              width: 80.r * (0.85 + (v - 1.0) * 2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF9880FA)
                                      .withOpacity((1.12 - v) * 0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  GestureDetector(
                    onVerticalDragStart: (_) {
                      if (joined) return;
                      isDragging.value = true;
                      _stopPulse();
                    },
                    onVerticalDragUpdate: (details) {
                      if (joined) return;
                      dragOffset.value = (dragOffset.value + details.delta.dy)
                          .clamp(-_maxDrag, 0.0);
                    },
                    onVerticalDragEnd: (_) {
                      if (joined) return;
                      isDragging.value = false;

                      if (dragOffset.value.abs() >= _joinThreshold) {
                        isJoined.value = true;
                        _stopPulse();
                        widget.onJoin();
                      } else {
                        dragOffset.value = 0.0;
                        _startPulse();
                      }
                    },
                    onVerticalDragCancel: () {
                      if (joined) return;
                      isDragging.value = false;
                      dragOffset.value = 0.0;
                      _startPulse();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale =
                            (joined || dragging) ? 1.0 : _pulseAnimation.value;
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        height: 70.r,
                        width: 70.r,
                        decoration: BoxDecoration(
                          color: Color(0xFF6E5CA4),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9880FA).withOpacity(0.45),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isVideo ? Icons.videocam : Icons.call,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: 10.h),
        reausabletext(
          "Join",
          fontsize: 14,
          fontfamily: FontFamily.interMedium,
          color: Colors.white,
        ),
      ],
    );
  }
}
