import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_typing/voice_typing_controller.dart';
import 'package:fgtracker/features/voice_typing/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReviewView extends StatelessWidget {
  final VoiceTypingController controller;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback onReRecord;

  const ReviewView({
    super.key,
    required this.controller,
    required this.onDone,
    required this.onDelete,
    required this.onReRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header: "Your voice" + Success chip + "Done" Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Your voice",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryElementStatus,
                    size: 14,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    controller.reviewChipText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryElementStatus,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Semantics(
              label: "Done voice typing",
              button: true,
              child: TextButton(
                onPressed: onDone,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  minimumSize: Size(44.w, 44.h),
                ),
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkblue,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // 2. Player Card
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.authIconBgCircle,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Obx(() {
            if (!controller.hasAudioRecording.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryDarkblue,
                      size: 24,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Words converted into message box successfully.",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Play / Pause Circle
                Semantics(
                  label: controller.isPlayingAudio.value ? "Pause voice" : "Play voice",
                  button: true,
                  child: InkWell(
                    onTap: () => controller.togglePlayPause(),
                    borderRadius: BorderRadius.circular(24.r),
                    child: Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDarkblue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        controller.isPlayingAudio.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Static Waveform with fill progress
                Expanded(
                  child: StaticWaveformBars(
                    progress: controller.playbackProgressFraction,
                    onSeek: (fraction) => controller.seekPlaybackFraction(fraction),
                  ),
                ),
                SizedBox(width: 10.w),

                // Duration Text
                Text(
                  controller.formattedPlaybackTimer,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primarySecondaryElementText,
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 10.h),

        // 3. Hint Text
        Text(
          "Listen to your voice again. The text is in the message box – you can edit it before sending.",
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.primarySecondaryElementText,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.h),

        // 4. Two Buttons in a row: Re-record & Delete
        Row(
          children: [
            // Re-record Button
            Expanded(
              child: Semantics(
                label: "Re-record voice message",
                button: true,
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton.icon(
                    onPressed: onReRecord,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primaryDarkblue,
                      size: 20,
                    ),
                    label: Text(
                      "Re-record",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkblue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryDarkblue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Delete Button
            Expanded(
              child: Semantics(
                label: "Delete voice text",
                button: true,
                child: SizedBox(
                  height: 50.h,
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.darkRed,
                      size: 20,
                    ),
                    label: Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkRed,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.darkRed.withValues(alpha: 0.10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
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
