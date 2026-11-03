import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecordVoiceReviewView extends StatelessWidget {
  final VoiceInputController controller;
  final void Function(String)? onVoiceSend;

  const RecordVoiceReviewView({
    super.key,
    required this.controller,
    this.onVoiceSend,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: "Your voice message" + Chip "Ready to send"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your voice message",
                style: TextStyle(
                  color: AppColors.darkText, // #0F0B4C
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.greenLight, // #E8FDF2
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryElementStatus,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "Ready to send",
                      style: TextStyle(
                        color: AppColors.primaryElementStatus,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 2. Playback Card (#EEF2FF radius 18) with Play/Pause + 26 bars + duration
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primaryElementLight, // #EEF2FF
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Obx(() {
                  final isPlaying = controller.isAudioPlaying.value;
                  return GestureDetector(
                    onTap: () => controller.togglePlayPause(),
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryElement, // #3D3DD8
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 12.w),
                // 26 seekable waveform bars
                Expanded(
                  child: Obx(() => VoiceInputReviewWaveform(
                        progress: controller.audioProgress.value,
                        playedColor: AppColors.primaryElement, // #3D3DD8
                        unplayedColor: AppColors.blue, // #A4A3FF
                        onSeek: (frac) => controller.seekAudio(frac),
                      )),
                ),
                SizedBox(width: 10.w),
                Obx(() => Text(
                      controller.formattedAudioDuration,
                      style: TextStyle(
                        color: AppColors.primaryElement, // #3D3DD8
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // 3. Hint
          Text(
            "Listen before sending your voice message.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primarySecondaryElementText, // #666666
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 12.h),

          // 4. Buttons Row: Re-record | Delete (h 44, radius 14)
          Row(
            children: [
              // Re-record
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.reRecord(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryElement,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.primaryElement, // 1.5px #3D3DD8
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(Icons.refresh_rounded, size: 18.sp),
                    label: Text(
                      "Re-record",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              // Delete
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: TextButton.icon(
                    onPressed: () => controller.deleteSession(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      backgroundColor: const Color(0xFFFDECEF), // #FDECEF
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.darkRed,
                      size: 18.sp,
                    ),
                    label: Text(
                      "Delete",
                      style: TextStyle(
                        color: AppColors.darkRed, // #D2042D
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // 5. Send Voice Message Button (Full width)
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () {
                final callback = onVoiceSend ?? controller.onVoiceSendCallback;
                final path = controller.consumeRecordedAudio();
                if (path.isNotEmpty && callback != null) {
                  callback(path);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryElement, // #3D3DD8
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(Icons.send_rounded, size: 18.sp, color: Colors.white),
              label: Text(
                "Send voice message",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
