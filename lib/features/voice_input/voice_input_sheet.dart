import 'dart:io';
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
    bool hasPermission = false;

    if (Platform.isIOS) {
      var micStatus = await Permission.microphone.status;
      if (kDebugMode) {
        final speechStatus = await Permission.speech.status;
        final recorderHasPerm = await AudioRecorder().hasPermission();
        debugPrint('[VT-iOS] Permission.microphone.status: $micStatus');
        debugPrint('[VT-iOS] Permission.speech.status: $speechStatus');
        debugPrint('[VT-iOS] AudioRecorder().hasPermission(): $recorderHasPerm');
      }

      // If already allowed (granted or limited in iOS 17+), proceed immediately
      if (micStatus.isGranted || micStatus.isLimited) {
        hasPermission = true;
      } else if (micStatus.isDenied) {
        // First-time or unprompted: request() shows the native iOS system popup
        micStatus = await Permission.microphone.request();
        if (kDebugMode) {
          debugPrint('[VT-iOS] Permission.microphone.request() result: $micStatus');
        }
        if (micStatus.isGranted || micStatus.isLimited) {
          hasPermission = true;
        } else if (micStatus.isPermanentlyDenied || micStatus.isRestricted) {
          if (!context.mounted) return;
          _showPermissionDialog(context);
          return;
        } else {
          return;
        }
      } else if (micStatus.isPermanentlyDenied || micStatus.isRestricted) {
        if (kDebugMode) {
          debugPrint(
              '[VT-iOS] Showing permission dialog because: permanentlyDenied/restricted ($micStatus)');
        }
        if (!context.mounted) return;
        _showPermissionDialog(context);
        return;
      }
    } else {
      // Android behaviour stays exactly the same as before
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (!context.mounted) return;
        _showPermissionDialog(context);
        return;
      }
      hasPermission = true;
    }

    if (!hasPermission) return;

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

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _PermissionDialog(),
    );
  }
}

class _PermissionDialog extends StatefulWidget {
  const _PermissionDialog();

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
    // Re-check mic permission when returning from iOS Settings
    if (state == AppLifecycleState.resumed) {
      Permission.microphone.status.then((status) {
        if (kDebugMode) {
          debugPrint('[VT-iOS] App resumed, re-checked mic status: $status');
        }
        if (status.isGranted || status.isLimited) {
          if (mounted) Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Text(
        "Permission Required",
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        "Microphone permission is needed to use voice.",
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey.shade700,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            openAppSettings();
          },
          child: const Text("Open settings"),
        ),
      ],
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
