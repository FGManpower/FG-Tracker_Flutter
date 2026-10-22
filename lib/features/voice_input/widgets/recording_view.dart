import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecordVoiceRecordingView extends StatefulWidget {
  final VoiceInputController controller;

  const RecordVoiceRecordingView({
    super.key,
    required this.controller,
  });

  @override
  State<RecordVoiceRecordingView> createState() =>
      _RecordVoiceRecordingViewState();
}

class _RecordVoiceRecordingViewState extends State<RecordVoiceRecordingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _canTapStop = false;

  @override
  void initState() {
    super.initState();
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
          // 1. Header: "Recording your voice…" + Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryElement, // #3D3DD8
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Recording your voice…",
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
          Obx(() => Text(
                widget.controller.hintMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primarySecondaryElementText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              )),

          SizedBox(height: 16.h),

          // 3. 22 Animated Waveform Bars (#3D3DD8 / #A4A3FF)
          Obx(() => VoiceInputWaveformBars(
                soundLevel: widget.controller.normalizedSoundLevel.value,
                isRecording: true,
                primaryColor: AppColors.primaryElement, // #3D3DD8
                secondaryColor: AppColors.blue, // #A4A3FF
              )),

          SizedBox(height: 20.h),

          // 4. Controls: Cancel | "Tap to stop" | Chip "AUDIO"
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

              // "Tap to stop" (72px #3D3DD8)
              GestureDetector(
                onTap: () {
                  if (_canTapStop) {
                    widget.controller.stopRecordVoice();
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
                            color: AppColors.primaryElement, // #3D3DD8
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryElement.withValues(
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
                        color: AppColors.primaryElement, // #3D3DD8
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Chip "AUDIO" (#EEF2FF / #3D3DD8)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryElementLight, // #EEF2FF
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      "AUDIO",
                      style: TextStyle(
                        color: AppColors.primaryElement, // #3D3DD8
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Type",
                    style: TextStyle(
                      color: AppColors.primarySecondaryElementText,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
