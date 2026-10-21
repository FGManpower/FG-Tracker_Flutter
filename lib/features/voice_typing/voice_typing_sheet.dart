import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_typing/voice_typing_controller.dart';
import 'package:fgtracker/features/voice_typing/widgets/listening_view.dart';
import 'package:fgtracker/features/voice_typing/widgets/review_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VoiceTypingSheet extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;

  const VoiceTypingSheet({
    super.key,
    required this.textController,
    required this.focusNode,
  });

  @override
  State<VoiceTypingSheet> createState() => _VoiceTypingSheetState();
}

class _VoiceTypingSheetState extends State<VoiceTypingSheet> {
  late final VoiceTypingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      VoiceTypingController(
        textController: widget.textController,
        focusNode: widget.focusNode,
      ),
    );

    // Automatically begin listening when sheet appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startListening();
    });
  }

  @override
  void dispose() {
    Get.delete<VoiceTypingController>();
    super.dispose();
  }

  void _handleCancel() {
    controller.cancelListening();
    Navigator.of(context).pop();
    // Reopen keyboard as specified
    widget.focusNode.requestFocus();
  }

  void _handleDone() {
    controller.completeSession();
    Navigator.of(context).pop();
  }

  void _handleDelete() {
    controller.deleteSession();
    Navigator.of(context).pop();
  }

  void _handleReRecord() {
    controller.reRecord();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent accidental swipe-down during listening
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.sheetState.value == VoiceSheetState.listening) {
          _handleCancel();
        } else {
          _handleDone();
        }
      },
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          child: Obx(() {
            switch (controller.sheetState.value) {
              case VoiceSheetState.listening:
                return ListeningView(
                  controller: controller,
                  onCancel: _handleCancel,
                );

              case VoiceSheetState.review:
                return ReviewView(
                  controller: controller,
                  onDone: _handleDone,
                  onDelete: _handleDelete,
                  onReRecord: _handleReRecord,
                );

              case VoiceSheetState.noSpeech:
                return _buildMessageStateView(
                  icon: Icons.mic_off_rounded,
                  title: "Didn't catch that",
                  message: "Didn't catch that. Tap the mic and try again.",
                  actionLabel: "Try Again",
                  onAction: () => controller.startListening(),
                );

              case VoiceSheetState.error:
                return _buildMessageStateView(
                  icon: Icons.error_outline_rounded,
                  title: "Something went wrong",
                  message: controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : "Failed to recognize speech. Tap to retry.",
                  actionLabel: "Retry",
                  onAction: () => controller.startListening(),
                );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildMessageStateView({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _handleCancel,
              icon: const Icon(Icons.close_rounded, color: AppColors.primarySecondaryElementText),
            ),
          ],
        ),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            color: AppColors.authIconBgCircle,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDarkblue,
            size: 28,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primarySecondaryElementText,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton(
                  onPressed: _handleCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textbordercolor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primarySecondaryElementText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkblue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
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
