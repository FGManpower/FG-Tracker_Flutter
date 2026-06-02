import 'dart:io';

import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Messages/Controller/VoiceRecordController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import 'message_Widgets.dart';

class ChatInputArea extends StatelessWidget {
  final RxString messageText;
  final RxString imagePath;
  final RxBool isSending;
  final TextEditingController textController;
  final ScrollController scrollController;
  final VoidCallback onSend;
  void Function(String)? onVoiceSend;
  final Function(String path) onImageSelected;

  ChatInputArea(
      {Key? key,
      required this.messageText,
      required this.imagePath,
      required this.isSending,
      required this.textController,
      required this.scrollController,
      required this.onSend,
      required this.onImageSelected,
      required this.onVoiceSend})
      : super(key: key);

  final voiceController = Get.put(VoiceRecordController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));

        final isMessageNotEmpty = messageText.value.trim().isNotEmpty;
        final isImageSelected = imagePath.value.isNotEmpty;
        final shouldShowSend = isMessageNotEmpty || isImageSelected;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImageSelected)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Stack(
                  children: [
                    ImageViewerWidget(
                      imageProvider: FileImage(File(imagePath.value)),
                      width: 250,
                      height: 180,
                      borderRadius: 12,
                    ),
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: GestureDetector(
                        onTap: () => imagePath.value = '',
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: Offset(0, -1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(() {
                      if (!voiceController.isRecording.value) return SizedBox();

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                voiceController.deleteRecording();
                              },
                              child: CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.delete,
                                    color: Colors.white, size: 20.sp),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${voiceController.duration.value}s",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    height: 35.h,
                                    child: AnimatedWaveList(
                                      stream: voiceController.amplitudeStream,
                                      barBuilder: (animation, amplitude) =>
                                          WaveFormBar(
                                        animation: animation,
                                        amplitude: amplitude,
                                        color: ToggleThemeData.darkPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () {
                                if (voiceController.isPaused.value) {
                                  voiceController.resumeRecording();
                                } else {
                                  voiceController.pauseRecording();
                                }
                              },
                              child: CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  voiceController.isPaused.value
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () async {
                                final path =
                                    await voiceController.stopRecording();
                                if (path != null) {
                                  onVoiceSend!(path);
                                }
                              },
                              child: CircleAvatar(
                                radius: 20.r,
                                backgroundColor: ToggleThemeData.darkPurple,
                                child: Icon(Icons.send,
                                    color: Colors.white, size: 20.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Row(
                      children: [
                        SizedBox(width: 5.w),
                        if (!voiceController.isRecording.value)
                          Expanded(
                            child: TextField(
                              controller: textController,
                              onChanged: (val) => messageText.value = val,
                              style: TextStyle(
                                  color: ToggleThemeData.white,
                                  fontFamily: FontFamily.interMedium,
                                  fontSize: 16.sp),
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.all(3.r),
                                  child: GestureDetector(
                                    onTap: () {

                                      ModalImage bottomNavbar = ModalImage(
                                        isImageCroppable: false,
                                        onImageSelect: (path) async {
                                          if (Utility.isNotNullEmptyOrFalse(path)) {
                                            onImageSelected(path);
                                            Navigator.pop(context);
                                          }
                                        },
                                      );
                                      bottomNavbar.mainBottomSheet(context);
                                    },
                                    child: CircleAvatar(
                                    backgroundColor: ToggleThemeData.white,
                                    radius: 16,
                                    child: reausableIcon(
                                        icon: Icons.image_outlined,
                                        color: ToggleThemeData.Appcolor,
                                        size: 25),
                                  ),)

                                ),
                                fillColor: ToggleThemeData.Appcolor,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 14.h),
                              ),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        if (shouldShowSend &&
                            !voiceController.isRecording.value)
                          GestureDetector(
                            onTap: isSending.value ? null : onSend,
                            child: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: ToggleThemeData.darkPurple,
                              child: Icon(Icons.send, color: Colors.white),
                            ),
                          )
                        else
                          !voiceController.isRecording.value
                              ? GestureDetector(
                                  onTap: () async {
                                    await voiceController.startRecording();
                                  },
                                  child: CircleAvatar(
                                    radius: 24.r,
                                    backgroundColor: ToggleThemeData.darkPurple,
                                    child: Icon(Icons.mic, color: Colors.white),
                                  ),
                                )
                              : SizedBox()
                      ],
                    )
                  ],
                )),
          ],
        );
      }),
    );
  }
}
