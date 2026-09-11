import 'dart:ui';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/incoming_call_controller.dart';

class IncomingCallScreen extends GetView<IncomingCallController> {
  const IncomingCallScreen({super.key});

  static const Color primaryPurple = Color(0xFF7B58FF);
  static const Color audioText = Color(0xFF0F0B4C);

  String _imageUrl() {
    final raw = controller.call.callerProfileImage;
    if (Utility.isNullEmptyOrFalse(raw)) {
      return MyAppTheme.ProfilenotFoundImg;
    }
    final path = raw.toString().trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return ConstRes.aImageBaseUrl + path;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IncomingCallController>(
      builder: (_) {
        final bool isVideo = controller.call.isVideo;
        final String name = controller.call.callerName;
        final String imageUrl = _imageUrl();

        final Color textColor = isVideo ? Colors.white : audioText;
        final Color sideBtnBg = isVideo
            ? Colors.white.withOpacity(0.18)
            : const Color(0xFF9E92BA).withOpacity(0.85);

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (isVideo)
                  _videoBg(imageUrl)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
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
                  ),
                if (isVideo)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.30),
                          Colors.black.withOpacity(0.70),
                        ],
                      ),
                    ),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isVideo
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: isVideo ? Colors.white24 : Colors.white,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVideo
                                  ? Icons.videocam_rounded
                                  : Icons.call_rounded,
                              color: primaryPurple,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              isVideo
                                  ? "Incoming video call"
                                  : "Incoming audio call",
                              style: TextStyle(
                                color: isVideo ? Colors.white70 : primaryPurple,
                                fontSize: 13.sp,
                                fontFamily: FontFamily.interMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isVideo ? 50.h : 55.h),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!isVideo) ...[
                            _ring(250.r, 0.18),
                            _ring(195.r, 0.28),
                            _ring(145.r, 0.40),
                          ],
                          Container(
                            width: 130.r,
                            height: 130.r,
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.white.withOpacity(isVideo ? 0.9 : 1),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryPurple.withOpacity(0.22),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 61.r,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28.sp,
                          fontFamily: FontFamily.interSemiBold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isVideo) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.white38),
                            color: Colors.white.withOpacity(0.06),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded,
                                  color: Colors.white, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                "Turn on your video",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontFamily: FontFamily.interMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.keyboard_double_arrow_up_rounded,
                        color: isVideo
                            ? Colors.white38
                            : primaryPurple.withOpacity(0.45),
                        size: 34.sp,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Swipe up to answer",
                        style: TextStyle(
                          color: isVideo
                              ? Colors.white54
                              : primaryPurple.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 18.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _sideBtn(
                              icon: Icons.close_rounded,
                              label: "Decline",
                              bg: sideBtnBg,
                              textColor: textColor,
                              onTap: controller.rejectCall,
                            ),
                            _SlideUpAnswerButton(
                              isVideo: isVideo,
                              onAnswer: controller.acceptCall,
                            ),
                            _sideBtn(
                              icon: Icons.mic_off_rounded,
                              label: "Mute",
                              bg: sideBtnBg,
                              textColor: textColor,
                              onTap: () {
                                // optional
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _videoBg(String imageUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF0D0B1C)),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
      ],
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryPurple.withOpacity(opacity),
          width: 1.6,
        ),
      ),
    );
  }

  Widget _sideBtn({
    required IconData icon,
    required String label,
    required Color bg,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30.r,
            backgroundColor: bg,
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13.sp,
            fontFamily: FontFamily.interMedium,
          ),
        ),
      ],
    );
  }
}

class _SlideUpAnswerButton extends StatefulWidget {
  final bool isVideo;
  final VoidCallback onAnswer;

  const _SlideUpAnswerButton({
    required this.isVideo,
    required this.onAnswer,
  });

  @override
  State<_SlideUpAnswerButton> createState() => _SlideUpAnswerButtonState();
}

class _SlideUpAnswerButtonState extends State<_SlideUpAnswerButton>
    with SingleTickerProviderStateMixin {
  final RxDouble dragOffset = 0.0.obs;
  final RxBool isAnswered = false.obs;
  final RxBool isDragging = false.obs;

  static const double _answerThreshold = 70.0;
  static const double _maxDrag = 90.0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const Color _purple = Color(0xFF7B58FF);
  static const Color _purpleSoft = Color(0xFF9880FA);

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
    if (!_pulseController.isAnimating && !isAnswered.value) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 110.r,
          width: 90.r,
          child: Obx(() {
            final offset = dragOffset.value;
            final answered = isAnswered.value;
            final dragging = isDragging.value;

            return Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (!answered)
                  Positioned(
                    bottom: 8.r,
                    child: Container(
                      width: 2,
                      height: 70.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            _purpleSoft.withOpacity(0.0),
                            _purpleSoft.withOpacity(0.35),
                            _purpleSoft.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, offset),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (!answered && !dragging)
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
                                    color: _purpleSoft
                                        .withOpacity((1.12 - v) * 0.35),
                                  ),
                                ),
                                Container(
                                  height: 80.r * (0.85 + (v - 1.0) * 2.5),
                                  width: 80.r * (0.85 + (v - 1.0) * 2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _purpleSoft
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
                          if (answered) return;
                          isDragging.value = true;
                          _stopPulse();
                        },
                        onVerticalDragUpdate: (details) {
                          if (answered) return;
                          dragOffset.value =
                              (dragOffset.value + details.delta.dy)
                                  .clamp(-_maxDrag, 0.0);
                        },
                        onVerticalDragEnd: (_) {
                          if (answered) return;
                          isDragging.value = false;

                          if (dragOffset.value.abs() >= _answerThreshold) {
                            isAnswered.value = true;
                            _stopPulse();
                            widget.onAnswer();
                          } else {
                            dragOffset.value = 0.0;
                            _startPulse();
                          }
                        },
                        onVerticalDragCancel: () {
                          if (answered) return;
                          isDragging.value = false;
                          dragOffset.value = 0.0;
                          _startPulse();
                        },
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale = (answered || dragging)
                                ? 1.0
                                : _pulseAnimation.value;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Container(
                            height: 74.r,
                            width: 74.r,
                            decoration: BoxDecoration(
                              color: _purple,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _purpleSoft.withOpacity(0.45),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isVideo
                                  ? Icons.videocam_rounded
                                  : Icons.call_rounded,
                              color: Colors.white,
                              size: 34.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 8.h),
        Text(
          "Answer",
          style: TextStyle(
            color: widget.isVideo ? Colors.white : const Color(0xFF0F0B4C),
            fontSize: 14.sp,
            fontFamily: FontFamily.interMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
