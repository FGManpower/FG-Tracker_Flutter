import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChooseView extends StatelessWidget {
  final VoidCallback onSelectVoiceToText;
  final VoidCallback onSelectRecordVoice;

  const ChooseView({
    super.key,
    required this.onSelectVoiceToText,
    required this.onSelectRecordVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 18.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Option 1: Voice to Text
          InkWell(
            onTap: onSelectVoiceToText,
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              height: 72.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.primarySecondaryBackground, // #F7F7F9
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDarkblue, // 46px #704AFA
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_voice_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Voice to Text",
                          style: TextStyle(
                            color: AppColors.darkText, // #0F0B4C
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Speak and type into the message box",
                          style: TextStyle(
                            color: AppColors.primarySecondaryElementText, // #666666
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h), // Gap 10

          // Option 2: Record Voice
          InkWell(
            onTap: onSelectRecordVoice,
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              height: 72.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.primarySecondaryBackground, // #F7F7F9
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryElement, // 46px #3D3DD8
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Record Voice",
                          style: TextStyle(
                            color: AppColors.darkText, // #0F0B4C
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Record and send as an audio message",
                          style: TextStyle(
                            color: AppColors.primarySecondaryElementText, // #666666
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
