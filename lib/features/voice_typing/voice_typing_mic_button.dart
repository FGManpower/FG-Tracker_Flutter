import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_typing/voice_typing_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceTypingMicButton extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;

  const VoiceTypingMicButton({
    super.key,
    required this.textController,
    required this.focusNode,
  });

  Future<void> _handleTap(BuildContext context) async {
    // 1. Hide keyboard
    focusNode.unfocus();
    FocusScope.of(context).unfocus();

    // 2. Check & Request Permissions
    final micStatus = await Permission.microphone.request();
    final speechStatus = await Permission.speech.request();

    final isMicGranted = micStatus.isGranted;
    final isSpeechGranted = speechStatus.isGranted || speechStatus.isLimited;

    if (!context.mounted) return;

    if (isMicGranted && isSpeechGranted) {
      // 3. Open VoiceTypingSheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => VoiceTypingSheet(
          textController: textController,
          focusNode: focusNode,
        ),
      );
    } else {
      _showPermissionDeniedDialog(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppColors.authIconBgCircle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off_rounded,
                color: AppColors.primaryDarkblue,
                size: 22,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "Microphone Access",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Microphone permission is needed to type with your voice.",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primarySecondaryElementText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primarySecondaryElementText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkblue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "Open settings",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Speak to type",
      button: true,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: Container(
          width: 40.w,
          height: 40.w,
          margin: EdgeInsets.only(right: 4.w),
          decoration: const BoxDecoration(
            color: AppColors.authIconBgCircle,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.mic_rounded,
            color: AppColors.primaryDarkblue,
            size: 20,
          ),
        ),
      ),
    );
  }
}
