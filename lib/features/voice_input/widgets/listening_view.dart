import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VoiceToTextListeningView extends StatefulWidget {
  final VoiceInputController controller;

  const VoiceToTextListeningView({
    super.key,
    required this.controller,
  });

  @override
  State<VoiceToTextListeningView> createState() =>
      _VoiceToTextListeningViewState();
}

class _VoiceToTextListeningViewState extends State<VoiceToTextListeningView>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  bool _canTapStop = false;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _canTapStop = true);
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Blinking red dot (10px #D2042D) + "Listening…" + timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _blinkController,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: AppColors.darkRed, // 10px #D2042D
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Listening…",
                style: TextStyle(
                  color: AppColors.darkText, // #0F0B4C
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() => Text(
                    widget.controller.formattedTimer,
                    style: TextStyle(
                      color: AppColors.primarySecondaryElementText, // #666666
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
            ],
          ),

          SizedBox(height: 8.h),

          // 2. Hint
          Obx(() {
            final isWarning = widget.controller.isTooNoisy.value ||
                widget.controller.didntCatchThat.value;
            return Text(
              widget.controller.hintMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isWarning
                    ? AppColors.darkRed
                    : AppColors.primarySecondaryElementText,
                fontSize: 13.sp,
                fontWeight: isWarning ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }),

          SizedBox(height: 12.h),

          // 3. 22 Animated Waveform Bars (#704AFA / #B2ACFD)
          Obx(() => VoiceInputWaveformBars(
                soundLevel: widget.controller.normalizedSoundLevel.value,
                isRecording: true,
                primaryColor: AppColors.primaryDarkblue,
                secondaryColor: AppColors.authIconBar,
              )),

          SizedBox(height: 12.h),

          // 4. Live transcription preview — words appear here as user speaks
          Obx(() {
            final text = widget.controller.recognizedWords.value.trim();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 46.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                  bottomRight: Radius.circular(14.r),
                ),
                border: Border.all(
                  color: const Color(0xFFD6D2FA),
                  width: 1,
                ),
              ),
              child: text.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ),
                        // Blinking cursor indicator
                        FadeTransition(
                          opacity: _blinkController,
                          child: Container(
                            width: 2.w,
                            height: 18.h,
                            margin: EdgeInsets.only(left: 3.w, top: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDarkblue,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.mic_rounded,
                          color: AppColors.primaryDarkblue.withValues(alpha: 0.45),
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Boliye… text yahaan dikhega",
                          style: TextStyle(
                            color: AppColors.primarySecondaryElementText,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
            );
          }),

          SizedBox(height: 16.h),

          // 4. Controls: Cancel | "Tap to stop" | Language Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cancel
              GestureDetector(
                onTap: () => widget.controller.cancelSession(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: const BoxDecoration(
                        color: AppColors.SmookeyWhite, // #F1F1F1
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade700,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.primarySecondaryElementText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // "Tap to stop" (72px #704AFA, pulsing ring)
              GestureDetector(
                onTap: () {
                  if (_canTapStop) {
                    widget.controller.stopListening();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkblue, // 72px #704AFA
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDarkblue.withValues(
                                    alpha: 0.25 +
                                        (_pulseController.value * 0.25)),
                                blurRadius: 10 + (_pulseController.value * 8),
                                spreadRadius: 2 + (_pulseController.value * 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Tap to stop",
                      style: TextStyle(
                        color: AppColors.primaryDarkblue,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Language Chip (e.g. HI-IN / EN-IN)
              GestureDetector(
                onTap: () => widget.controller.openLanguagePicker(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.authIconBgCircle, // #EEEDFD
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Obx(() => Text(
                            widget.controller.selectedLanguage.value.shortCode,
                            style: TextStyle(
                              color: AppColors.primaryDarkblue,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Language",
                      style: TextStyle(
                        color: AppColors.primarySecondaryElementText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
