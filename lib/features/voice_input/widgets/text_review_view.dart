import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/widgets/waveform_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VoiceToTextReviewView extends StatelessWidget {
  final VoiceInputController controller;
  final VoidCallback? onSend;

  const VoiceToTextReviewView({
    super.key,
    required this.controller,
    this.onSend,
  });

  String get _statusChipLabel {
    switch (controller.contextType.value) {
      case VoiceContextType.reply:
        return "Reply ready";
      case VoiceContextType.caption:
        return "Caption ready";
      case VoiceContextType.normal:
        return "Text ready";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Voice to Text",
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryElementStatus,
                      size: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _statusChipLabel,
                      style: TextStyle(
                        color: AppColors.primaryElementStatus,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ── SECTION 1: Voice Playback (if audio available) ────────────────────
          Obx(() {
            if (controller.voiceToTextAudioPath.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  icon: Icons.graphic_eq_rounded,
                  label: "Listen back",
                  color: AppColors.primaryDarkblue,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.authIconBgCircle, // #EEEDFD
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      // Play / Pause Button
                      Obx(() {
                        final isPlaying = controller.isAudioPlaying.value;
                        return GestureDetector(
                          onTap: () => controller.togglePlayPause(),
                          child: Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDarkblue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26.sp,
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: 12.w),
                      // Seekable waveform
                      Expanded(
                        child: Obx(() => VoiceInputReviewWaveform(
                              progress: controller.audioProgress.value,
                              playedColor: AppColors.primaryDarkblue,
                              unplayedColor: AppColors.authIconBar,
                              onSeek: (frac) => controller.seekAudio(frac),
                            )),
                      ),
                      SizedBox(width: 10.w),
                      Obx(() => Text(
                            controller.audioDurationSeconds.value > 0
                                ? controller.formattedAudioDuration
                                : controller.formattedTimer,
                            style: TextStyle(
                              color: AppColors.primaryDarkblue,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            );
          }),

          // ── SECTION 2: Transcribed Text ──────────────────────────────────────
          _SectionLabel(
            icon: Icons.chat_bubble_outline_rounded,
            label: "Your message",
            color: AppColors.primaryDarkblue,
          ),
          SizedBox(height: 6.h),
          Obx(() {
            final text = controller.recognizedWords.value.trim();
            return Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 60.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(
                  color: const Color(0xFFD6D2FA),
                  width: 1,
                ),
              ),
              child: Text(
                text.isNotEmpty ? text : "No text captured — try re-recording.",
                style: TextStyle(
                  color: text.isNotEmpty
                      ? AppColors.darkText
                      : AppColors.primarySecondaryElementText,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            );
          }),

          SizedBox(height: 6.h),

          // Hint
          Text(
            "Listen to your voice above, or edit the text in the message box before sending.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primarySecondaryElementText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 12.h),

          // ── Action Buttons Row: Re-record | Delete ───────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.reRecord(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkblue,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.primaryDarkblue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(Icons.refresh_rounded, size: 17.sp),
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
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: TextButton.icon(
                    onPressed: () => controller.deleteSession(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      backgroundColor: const Color(0xFFFDECEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.darkRed,
                      size: 17.sp,
                    ),
                    label: Text(
                      "Delete",
                      style: TextStyle(
                        color: AppColors.darkRed,
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

          // ── Send Button (full width) ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () {
                final sendAction = onSend ?? controller.onSendCallback;
                // 1. Commit spoken text to messageTextRx + close panel
                controller.closeInlinePanel();
                // 2. Fire send after one frame so the Obx rebuild completes
                Future.microtask(() {
                  if (sendAction != null) sendAction();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkblue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(Icons.send_rounded, size: 18.sp, color: Colors.white),
              label: Text(
                "Send message",
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

// ── Small reusable section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 13.sp),
        SizedBox(width: 4.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
