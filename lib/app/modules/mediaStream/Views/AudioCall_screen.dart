import 'dart:math' as math;

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';

class AudiocallScreen extends StatefulWidget {
  const AudiocallScreen({
    super.key,
    required this.controller,
  });

  final CallingController controller;

  @override
  State<AudiocallScreen> createState() => _AudiocallScreenState();
}

class _AudiocallScreenState extends State<AudiocallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  static const Color primaryPurple = Color(0xFF7B58FF);
  static const Color darkText = Color(0xFF0F0B4C);

  CallingController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String profilePath =
        controller.args['callerProfile']?.toString() ?? '';


    final String imageUrl = Utility.isNullEmptyOrFalse(profilePath)
        ? MyAppTheme.ProfilenotFoundImg
        : profilePath.startsWith('http')
        ? profilePath
        : ConstRes.aImageBaseUrl + "Uploads/Auth/$profilePath";

    final bool isOutgoing =
        controller.args["callType"] == "outGoing";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final double progress =
              _animationController.value;

          return Column(
            children: [
              SizedBox(height: 10.h),

              Text(
                isOutgoing ? "Calling" : "Call From",
                style: TextStyle(
                  color: primaryPurple.withOpacity(0.85),
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interMedium,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "${controller.args["callerName"] ?? ""}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 28.sp,
                  fontFamily: FontFamily.interSemiBold,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                controller.formattedDuration == "00:00"
                    ? "${controller.callStatus.value}..."
                    : controller.formattedDuration,
                style: TextStyle(
                  color: AppColors.primaryPurple.withOpacity(0.9),
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 30.h),

              _AnimatedAvatar(
                imageUrl: imageUrl,
                progress: progress,
              ),

              SizedBox(height: 35.h),

              _AnimatedAudioWave(
                progress: progress,
              ),

              SizedBox(height: 28.h),

              const Spacer(),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedAvatar extends StatelessWidget {
  final String imageUrl;
  final double progress;

  const _AnimatedAvatar({
    required this.imageUrl,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double outerProgress = progress;
    final double middleProgress =
        (progress + 0.25) % 1.0;
    final double innerProgress =
        (progress + 0.5) % 1.0;

    return SizedBox(
      width: 270.r,
      height: 270.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulseRing(
            baseSize: 250.r,
            progress: outerProgress,
            opacity: 0.14,
            color: const Color(0xFF7B58FF),
          ),

          _PulseRing(
            baseSize: 205.r,
            progress: middleProgress,
            opacity: 0.20,
            color: const Color(0xFF8F72FF),
          ),

          _PulseRing(
            baseSize: 160.r,
            progress: innerProgress,
            opacity: 0.28,
            color: const Color(0xFFB1A0FF),
          ),

          Container(
            width: 128.r,
            height: 128.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B58FF)
                      .withOpacity(0.30),
                  blurRadius: 24,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: EdgeInsets.all(4.r),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 120.r,
                height: 120.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: const Color(0xFFF0EDFF),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: 58.sp,
                      color: const Color(0xFF7B58FF),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            bottom: 4.r,
            right: 36.r,
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: const Color(0xFF7B58FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7B58FF)
                        .withOpacity(0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double baseSize;
  final double progress;
  final double opacity;
  final Color color;

  const _PulseRing({
    required this.baseSize,
    required this.progress,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double scale =
        0.88 + (progress * 0.16);

    final double ringOpacity =
        opacity * (1.0 - (progress * 0.45));

    return Transform.scale(
      scale: scale,
      child: Container(
        width: baseSize,
        height: baseSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(
            ringOpacity.clamp(0.0, 1.0),
          ),
          border: Border.all(
            color: color.withOpacity(
              (ringOpacity + 0.10).clamp(0.0, 1.0),
            ),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _AnimatedAudioWave extends StatelessWidget {
  final double progress;

  const _AnimatedAudioWave({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const List<double> baseHeights = [
      10,
      20,
      32,
      45,
      60,
      45,
      32,
      20,
      10,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        baseHeights.length,
            (index) {
          final double phase =
              progress * math.pi * 2 +
                  index * 0.55;

          final double wave =
              (math.sin(phase) + 1) / 2;

          final double height = baseHeights[index] *
              (0.65 + wave * 0.55);

          final double opacity =
              0.55 + wave * 0.45;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: EdgeInsets.symmetric(
              horizontal: 3.5.w,
            ),
            width: 4.5.w,
            height: height.h,
            decoration: BoxDecoration(
              color: const Color(0xFF7B58FF)
                  .withOpacity(opacity),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B58FF)
                      .withOpacity(0.25),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}