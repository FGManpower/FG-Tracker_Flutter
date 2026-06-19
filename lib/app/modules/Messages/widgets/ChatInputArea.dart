import 'dart:io';
import 'dart:typed_data';

import 'package:fgtracker/app/Core/constant/BottomSheet/ChatBottomSheet.dart';
import 'package:fgtracker/app/Core/util/file_helper.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/file_services.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Messages/Controller/VoiceRecordController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import 'message_Widgets.dart';

class ChatInputArea extends StatelessWidget {
  final RxString messageText;
  final RxString imagePath;
  final RxString videoPath;
  final RxString documentPath;
  final RxBool isSending;
  final TextEditingController textController;
  final ScrollController scrollController;
  final VoidCallback onSend;
  void Function(String)? onVoiceSend;
  final Function(String path) onImageSelected;
  final Function(String path) onvideoSelected;
  final Function(String path) onDocumentSelected;
  final Rx<Uint8List?> videoThumbnail;
  final RxString videoDuration;

  ChatInputArea({
    Key? key,
    required this.messageText,
    required this.imagePath,
    required this.videoPath,
    required this.isSending,
    required this.textController,
    required this.scrollController,
    required this.onSend,
    required this.onImageSelected,
    required this.onvideoSelected,
    required this.onVoiceSend,
    required this.videoDuration,
    required this.videoThumbnail,
    required this.onDocumentSelected,
    required this.documentPath,
  }) : super(key: key);

  final voiceController = Get.put(VoiceRecordController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));

        final isMessageNotEmpty = messageText.value.trim().isNotEmpty;
        final isImageSelected = imagePath.value.isNotEmpty;
        final isVideoSelected = videoPath.value.isNotEmpty;
        final isDocumentSelected = documentPath.value.isNotEmpty;
        final shouldShowSend = isMessageNotEmpty ||
            isImageSelected ||
            isVideoSelected ||
            isDocumentSelected;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
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
                  if (isImageSelected) _buildLargeImagePreview(),
                  if (isVideoSelected) _buildLargeVideoPreview(),
                  if (isDocumentSelected) _buildLargeDocumentPreview(),

                  Obx(() {
                    if (!voiceController.isRecording.value) return const SizedBox();

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
                              final path = await voiceController.stopRecording();
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
                                    ChatBottomSheet.showFileOptions(
                                      context,
                                      onGallery: () {
                                        ModalImage bottomNavbar = ModalImage(
                                          isImageCroppable: false,
                                          onImageSelect: (path) async {
                                            if (Utility.isNotNullEmptyOrFalse(
                                                path)) {
                                              Navigator.pop(context);
                                              onImageSelected(path);
                                              Navigator.pop(context);
                                            }
                                          },
                                        );
                                        bottomNavbar.mainBottomSheet(context);
                                      },
                                      onVideo: () async {
                                        var path = await FileServices()
                                            .pickVideoFromGallery();
                                        onvideoSelected(path?.path ?? "");
                                      },
                                      onDocument: () async {
                                        final file = await FileServices()
                                            .pickDocument();
                                        if (file != null) {
                                          onDocumentSelected(file.path ?? "");
                                        }
                                      },
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: ToggleThemeData.white,
                                    radius: 16,
                                    child: reausableIcon(
                                      icon: Icons.file_present_outlined,
                                      color: ToggleThemeData.Appcolor,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                              fillColor: ToggleThemeData.Appcolor,
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 14.h),
                            ),
                          ),
                        ),
                      SizedBox(width: 8.w),
                      if (shouldShowSend && !voiceController.isRecording.value)
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
                            : const SizedBox()
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }


  Widget _buildLargeImagePreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
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
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeVideoPreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Stack(
        children: [
          Container(
            width: 250.w,
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Obx(
                        () => videoThumbnail.value != null
                        ? Image.memory(
                      videoThumbnail.value!,
                      fit: BoxFit.cover,
                    )
                        : Container(color: Colors.black87),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    bottom: 10.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            videoPath.value.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Obx(
                              () => Text(
                            videoDuration.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8.w,
            top: 8.h,
            child: GestureDetector(
              onTap: () {
                videoPath.value = '';
                videoThumbnail.value = null;
                videoDuration.value = '';
              },
              child: CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 16.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeDocumentPreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Stack(
        children: [
          Container(
            width: 280.w,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xff1F2937),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withOpacity(.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 55.w,
                  height: 55.w,
                  decoration: BoxDecoration(
                    color: getFileColor(documentPath.value),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    getFileIcon(documentPath.value),
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        documentPath.value.split('/').last,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        getFileExtension(documentPath.value).toUpperCase(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8.w,
            top: 8.h,
            child: GestureDetector(
              onTap: () => documentPath.value = '',
              child: CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 16.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}