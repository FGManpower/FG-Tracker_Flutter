import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_typing/voice_typing_controller.dart';
import 'package:fgtracker/features/voice_typing/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ListeningView extends StatefulWidget {
  final VoiceTypingController controller;
  final VoidCallback onCancel;

  const ListeningView({
    super.key,
    required this.controller,
    required this.onCancel,
  });

  @override
  State<ListeningView> createState() => _ListeningViewState();
}

class _ListeningViewState extends State<ListeningView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _blinkController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _blinkAnimation;
  bool _canTapStop = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Prevent accidental tap-to-stop while sheet is animating in
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _canTapStop = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header: Blinking red dot + Listening... + Timer
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _blinkAnimation,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: AppColors.darkRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              "Listening…",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const Spacer(),
            Obx(
              () => Text(
                widget.controller.formattedListeningTimer,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primarySecondaryElementText,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // 2. Context-based Hint
        Text(
          widget.controller.listeningHintText,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.primarySecondaryElementText,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.h),

        // 3. Live Animated Waveform
        Obx(
          () => AnimatedWaveformBars(
            soundLevel: widget.controller.soundLevel.value,
          ),
        ),
        SizedBox(height: 24.h),

        // 4. Bottom Controls: Cancel | Tap to Stop | Language
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cancel Button
            Semantics(
              label: "Cancel voice typing",
              button: true,
              child: InkWell(
                onTap: widget.onCancel,
                borderRadius: BorderRadius.circular(32.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: const BoxDecoration(
                          color: AppColors.SmookeyWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.primarySecondaryElementText,
                          size: 22,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primarySecondaryElementText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center: Tap to Stop with Pulsing Ring
            Semantics(
              label: "Tap to stop recording",
              button: true,
              child: InkWell(
                onTap: () {
                  if (_canTapStop) {
                    widget.controller.stopListening();
                  }
                },
                borderRadius: BorderRadius.circular(44.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 84.w,
                        height: 84.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 72.w * _pulseAnimation.value,
                                  height: 72.w * _pulseAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryDarkblue.withValues(
                                        alpha: (1.25 - _pulseAnimation.value).clamp(0.0, 0.4),
                                      ),
                                      width: 2.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 72.w,
                              height: 72.w,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDarkblue,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Tap to stop",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDarkblue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right: Language Chip
            Semantics(
              label: "Toggle speech language",
              button: true,
              child: InkWell(
                onTap: () => widget.controller.toggleLanguage(),
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.authIconBgCircle,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Obx(
                          () => Text(
                            widget.controller.languageLabel,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkblue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "Language",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primarySecondaryElementText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
