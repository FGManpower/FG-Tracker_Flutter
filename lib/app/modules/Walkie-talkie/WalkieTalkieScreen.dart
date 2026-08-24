import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Core/constant/const_res.dart';
import '../../config/themes_data.dart';
import '../../global_widget/common_widget.dart';
import 'Controller/walkieController.dart';
import '../../Data/Services/Walkie-Talkie-Service.dart';
import '../../Core/constant/notification_holder.dart';

class WalkieTalkieScreen extends StatefulWidget {
  const WalkieTalkieScreen({super.key});

  @override
  State<WalkieTalkieScreen> createState() => _WalkieTalkieScreenState();
}

class _WalkieTalkieScreenState extends State<WalkieTalkieScreen>
    with SingleTickerProviderStateMixin {
  final walkie = Get.put(WalkieController());
  final Map<String, dynamic>? args = Get.arguments;

  late final AnimationController _pulse;
  Timer? _meterTimer;
  double micLevel = 0.3;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    WalkieLaunchTracker.fromWalkieCall = true;

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);

    _startMeter();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _meterTimer?.cancel();
    walkie.reset();
    WalkieLaunchTracker.fromWalkieCall = false;
    WalkietalkieService.instance.dispose();
    super.dispose();
  }

  void _startMeter() {
    final rnd = Random();
    _meterTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() => micLevel = 0.4 + rnd.nextDouble() * 0.6);
    });
  }

  // ============================================================
  // PTT HANDLERS - Fixed with proper async
  // ============================================================
  Future<void> _startTalking() async {
    if (_isPressed) return; // Prevent double
    _isPressed = true;

    print("🎤 PTT pressed");

    walkie.startTalking();

    // ✅ Initialize recorder FIRST
    await WalkietalkieService.instance.initRecorder();

    // ✅ Then start talking (emits walkie_start)
    WalkietalkieService.instance.startTalking(args!['remoteUserId']?.toString() ?? "");
  }

  Future<void> _stopTalking() async {
    if (!_isPressed) return;
    _isPressed = false;

    print("🛑 PTT released");

    // ✅ Stop talking FIRST (emits walkie_stop)
    WalkietalkieService.instance.stopTalking(args!['remoteUserId']?.toString() ?? "");

    // ✅ Then stop recorder
    await WalkietalkieService.instance.stopRecorder();

    walkie.stopTalking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          final state = walkie.audioState.value;

          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    BackpressIcon(context, color: ToggleThemeData.white),
                    const Spacer(),
                    IconButton(
                      icon: Obx(() => Icon(
                        walkie.isSpeakerOn.value
                            ? Icons.volume_up
                            : Icons.hearing,
                        color: Colors.white,
                        size: 24.sp,
                      )),
                      onPressed: () async {
                        walkie.toggleSpeaker();
                        await WalkietalkieService.instance
                            .toggleSpeaker(walkie.isSpeakerOn.value);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // User Info
              Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: args?['profileUrl'] != null
                        ? NetworkImage(
                      ConstRes.aImageBaseUrl + args!['profileUrl'],
                    )
                        : null,
                    child: args?['profileUrl'] == null
                        ? Icon(Icons.person, size: 40.sp, color: Colors.white54)
                        : null,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    args?['callerName'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    state == WalkieAudioState.talking
                        ? "You are talking"
                        : "Listening…",
                    style: TextStyle(
                      color: state == WalkieAudioState.talking
                          ? Colors.greenAccent
                          : Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 36.h),

              // Audio Level Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 6.w,
                    height: ((micLevel * 36) + i * 6).h,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  );
                }),
              ),

              SizedBox(height: 44.h),

              // PTT Button - Fixed with proper press/release
              GestureDetector(
                onTapDown: (_) => _startTalking(),
                onTapUp: (_) => _stopTalking(),
                onTapCancel: _stopTalking,
                onLongPressEnd: (_) => _stopTalking(),
                child: ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    height: 160.r,
                    width: 160.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state == WalkieAudioState.talking
                          ? Colors.greenAccent
                          : Colors.grey,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 64.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}