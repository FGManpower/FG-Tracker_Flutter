import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:get/get.dart';
import '../../Data/Services/walkie_native_service.dart';
import '../../config/themes_data.dart';
import '../../global_widget/common_widget.dart';

import 'Controller/walkieController.dart';

class WalkieTalkieScreen extends StatefulWidget {
  const WalkieTalkieScreen({
    super.key,
  });

  @override
  State<WalkieTalkieScreen> createState() => _WalkieTalkieScreenState();
}

class _WalkieTalkieScreenState extends State<WalkieTalkieScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(WalkieController());

  Map<String, dynamic>? arguments = Get.arguments;
  bool isTalking = false;
  bool isSpeakerOn = true;

  double micLevel = 0.2;
  Timer? _meterTimer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _meterTimer?.cancel();
    super.dispose();
  }

  Future<void> _startTalking() async {
    if (isTalking) return;

    setState(() => isTalking = true);
    HapticFeedback.heavyImpact();

    _pulseController.repeat(reverse: true);
    _startMicMeter();

    await WalkieNativeService.talk();
  }

  Future<void> _stopTalking() async {
    if (!isTalking) return;

    setState(() => isTalking = false);
    HapticFeedback.lightImpact();

    _pulseController.stop();
    _meterTimer?.cancel();
    micLevel = 0.2;

    await WalkieNativeService.stop();
  }

  void _startMicMeter() {
    final rnd = Random();
    _meterTimer?.cancel();

    _meterTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) {
        if (!mounted) return;
        setState(() {
          micLevel = isTalking ? (0.35 + rnd.nextDouble() * 0.65) : 0.2;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final micButtonSize = 170.r;
    final avatarSize = 96.r;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: BackpressIcon(context, color: ToggleThemeData.white),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() => isSpeakerOn = !isSpeakerOn);
                      HapticFeedback.selectionClick();
                    },
                    child: Icon(
                      isSpeakerOn ? Icons.volume_up : Icons.hearing,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Column(
              children: [
                CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: arguments?['profileUrl'] != null
                      ? NetworkImage(
                          ConstRes.aImageBaseUrl + arguments?['profileUrl']!,
                        )
                      : null,
                  child: arguments?['profileUrl'] == null
                      ? Icon(
                          Icons.person,
                          size: 36.sp,
                          color: Colors.white54,
                        )
                      : null,
                ),
                SizedBox(height: 14.h),
                reausabletext(
                  arguments?['callerName'],
                  fontsize: 18,
                  color: Colors.white,
                  fontweight: FontWeight.w600,
                  align: TextAlign.center,
                  maxline: 1,
                  textoverflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                reausabletext(
                  isTalking ? "You are talking…" : "Listening",
                  fontsize: 13,
                  color: isTalking ? Colors.greenAccent : Colors.white60,
                  letterSpacing: 0.6,
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final height = (micLevel * 34) + (i * 6);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 110),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 6.w,
                  height: height.h,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                );
              }),
            ),
            SizedBox(height: 34.h),
            GestureDetector(
              onTapDown: (_) => _startTalking(),
              onTapUp: (_) => _stopTalking(),
              onTapCancel: _stopTalking,
              child: ScaleTransition(
                scale: _pulseController,
                child: Container(
                  height: micButtonSize,
                  width: micButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isTalking
                          ? [Colors.greenAccent, Colors.green]
                          : [Colors.grey.shade700, Colors.grey.shade900],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent
                            .withOpacity(isTalking ? 0.55 : 0.25),
                        blurRadius: isTalking ? 42.r : 18.r,
                        spreadRadius: isTalking ? 10.r : 3.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 78.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            reausabletext(
              isTalking ? "Release to stop" : "Hold to talk",
              fontsize: 15,
              color: isTalking ? Colors.greenAccent : Colors.white70,
              letterSpacing: 1.0,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: reausabletext(
                "Walkie-Talkie",
                fontsize: 12,
                color: Colors.white38,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
