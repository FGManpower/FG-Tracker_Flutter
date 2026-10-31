import 'dart:io';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/features/voice_input/voice_input_controller.dart';
import 'package:fgtracker/features/voice_input/widgets/choose_view.dart';
import 'package:fgtracker/features/voice_input/widgets/language_list.dart';
import 'package:fgtracker/features/voice_input/widgets/listening_view.dart';
import 'package:fgtracker/features/voice_input/widgets/recording_view.dart';
import 'package:fgtracker/features/voice_input/widgets/text_review_view.dart';
import 'package:fgtracker/features/voice_input/widgets/voice_review_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceInputSheet {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController textController,
    required FocusNode focusNode,
    RxString? messageText,
    VoidCallback? onSend,
    void Function(String)? onVoiceSend,
    VoiceContextType type = VoiceContextType.normal,
  }) async {
    // 1. Unfocus keyboard
    focusNode.unfocus();
    FocusScope.of(context).unfocus();

    // 2. Microphone Permission Check (iOS & Android)
    if (!await _ensurePermission(context, Permission.microphone)) return;

    final controller = Get.find<VoiceInputController>();

    if (!context.mounted) return;

    // 3. Show small modal sheet with ONLY the two options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChooseView(
        onSelectVoiceToText: () async {
          Navigator.pop(context);
          // iOS: Voice-to-Text starts only if Speech Recognition is allowed
          if (Platform.isIOS &&
              !await _ensurePermission(
                context,
                Permission.speech,
                message:
                    "Speech recognition permission is needed to convert voice to text.",
              )) {
            return;
          }
          await controller.startVoiceToText(
            textController: textController,
            focusNode: focusNode,
            messageText: messageText,
            type: type,
            onSend: onSend,
          );
        },
        onSelectRecordVoice: () async {
          Navigator.pop(context);
          await controller.startRecordVoice(
            textController: textController,
            focusNode: focusNode,
            type: type,
            onVoiceSend: onVoiceSend,
          );
        },
      ),
    );
  }

  /// Returns true if [permission] is granted. Otherwise shows the custom dialog:
  /// "Allow" (then the real system popup) when the system can still ask,
  /// or "Open settings" when it was denied and can't be asked again.
  static Future<bool> _ensurePermission(
    BuildContext context,
    Permission permission, {
    String message = "Microphone permission is needed to use voice.",
  }) async {
    var status = await permission.status;
    if (kDebugMode) {
      debugPrint('[VoiceInput] $permission status: $status');
    }
    if (status.isGranted || status.isLimited) return true;

    final canRequest = !status.isPermanentlyDenied && !status.isRestricted;
    if (!context.mounted) return false;
    final result = await _showPermissionDialog(
      context,
      permission: permission,
      canRequest: canRequest,
      message: message,
    );
    if (result != true) return false;
    // Granted from Settings (dialog closed itself on resume)
    if (!canRequest) return true;

    // User tapped Allow: now show the real system popup
    if (Platform.isIOS && permission == Permission.microphone) {
      // Native iOS request (AVCaptureDevice)
      final recorder = AudioRecorder();
      final granted = await recorder.hasPermission();
      recorder.dispose();
      return granted;
    }
    status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  static Future<bool?> _showPermissionDialog(
    BuildContext context, {
    required Permission permission,
    required bool canRequest,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _PermissionDialog(
        permission: permission,
        canRequest: canRequest,
        message: message,
      ),
    );
  }
}

class _PermissionDialog extends StatefulWidget {
  final Permission permission;
  final bool canRequest;
  final String message;

  const _PermissionDialog({
    required this.permission,
    required this.canRequest,
    required this.message,
  });

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when returning from Settings
    if (state == AppLifecycleState.resumed && !widget.canRequest) {
      widget.permission.status.then((status) {
        if (kDebugMode) {
          debugPrint('[VoiceInput] App resumed, re-checked status: $status');
        }
        if (status.isGranted || status.isLimited) {
          if (mounted) Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mic icon in soft purple circle
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                color: AppColors.authIconBgCircle,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDarkblue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.mic_rounded,
                  color: AppColors.white,
                  size: 26.sp,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              "Permission Required",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.4,
                color: AppColors.primarySecondaryElementText,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkblue,
                      side: const BorderSide(color: AppColors.authIconBar),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.canRequest) {
                        Navigator.pop(context, true);
                      } else {
                        openAppSettings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkblue,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      widget.canRequest ? "Allow" : "Open settings",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceInputInlinePanel extends StatelessWidget {
  final VoiceInputController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback? onSend;
  final void Function(String)? onVoiceSend;

  const VoiceInputInlinePanel({
    super.key,
    required this.controller,
    required this.textController,
    required this.focusNode,
    this.onSend,
    this.onVoiceSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 280.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            offset: const Offset(0, -3),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Obx(() {
        switch (controller.mode.value) {
          case VoiceInputMode.voiceToTextListening:
            return VoiceToTextListeningView(controller: controller);
          case VoiceInputMode.voiceToTextReview:
            return VoiceToTextReviewView(
              controller: controller,
              onSend: onSend ?? controller.onSendCallback,
            );
          case VoiceInputMode.voiceToTextLanguageList:
            return LanguageList(controller: controller);
          case VoiceInputMode.recordVoiceRecording:
            return RecordVoiceRecordingView(controller: controller);
          case VoiceInputMode.recordVoiceReview:
            return RecordVoiceReviewView(
              controller: controller,
              onVoiceSend: onVoiceSend ?? controller.onVoiceSendCallback,
            );
          case VoiceInputMode.idle:
            return const SizedBox();
        }
      }),
    );
  }
}
