import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fgtracker/app/Core/constant/BottomSheet/ChatBottomSheet.dart';
import 'package:fgtracker/app/Core/util/file_helper.dart';
import 'package:fgtracker/app/Data/Services/file_services.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/VoiceRecordController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/mentionList_item.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waveform_flutter/waveform_flutter.dart';
import '../Controller/MessageController.dart';
import 'message_Widgets.dart';

class ChatInputArea extends StatefulWidget {
  final RxString messageText;
  final RxList<File> imagePath;
  final RxString videoPath;
  final RxString documentPath;
  final RxBool isSending;
  final TextEditingController textController;
  final VoidCallback onSend;
  void Function(String)? onVoiceSend;

  final Function(List<File> path) onImageSelected;
  final Function(String path) onvideoSelected;
  final Function(String path) onDocumentSelected;
  final Rx<Uint8List?> videoThumbnail;
  final RxString videoDuration;
  final RxBool isUploadingVideo;
  final RxDouble uploadProgress;
  final VoidCallback onLocationSelected;
  final MessageController? messageController;
  final GroupMessageController? groupMessageController;
  RxList<LocationData>? groupMembers;

  ChatInputArea({
    super.key,
    required this.messageText,
    required this.imagePath,
    required this.videoPath,
    required this.isSending,
    required this.textController,
    required this.onSend,
    required this.onImageSelected,
    required this.onvideoSelected,
    required this.onVoiceSend,
    required this.videoDuration,
    required this.videoThumbnail,
    required this.onDocumentSelected,
    required this.documentPath,
    required this.isUploadingVideo,
    required this.uploadProgress,
    this.groupMembers,
    required this.onLocationSelected,
    this.groupMessageController,
    this.messageController,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final voiceController = Get.put(VoiceRecordController());

  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        widget.messageController?.showEmoji.value = false;
        widget.groupMessageController?.showEmoji.value = false;
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }


  void _toggleEmoji() {
    final isShowingEmoji = widget.messageController?.showEmoji.value ??
        widget.groupMessageController?.showEmoji.value ??
        false;

    if (isShowingEmoji) {
      widget.messageController?.showEmoji.value = false;
      widget.groupMessageController?.showEmoji.value = false;
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        widget.messageController?.showEmoji.value = true;
        widget.groupMessageController?.showEmoji.value = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final isMessageNotEmpty = widget.messageText.value.trim().isNotEmpty;
        final isImageSelected = widget.imagePath.value.isNotEmpty;
        final isVideoSelected = widget.videoPath.value.isNotEmpty;
        final isDocumentSelected = widget.documentPath.value.isNotEmpty;
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
                  if (voiceController.isRecording.value)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
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
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20.sp,
                              ),
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
                                widget.onVoiceSend!(path);
                              }
                            },
                            child: CircleAvatar(
                              radius: 20.r,
                              backgroundColor: ToggleThemeData.darkPurple,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.groupMessageController != null &&
                                widget.groupMessageController!
                                    .showMentionList.value &&
                                widget.groupMessageController!
                                    .filteredMembers.isNotEmpty)
                              MentionlistItem(
                                filteredMembers: widget
                                    .groupMessageController!.filteredMembers,
                                onTap: (member) {
                                  widget.groupMessageController!.insertMention(
                                    member: member,
                                    textController: widget.textController,
                                  );
                                },
                              ),
                            Row(
                              children: [
                                Flexible(
                                  child: TextField(
                                    controller: widget.textController,
                                    focusNode: focusNode,
                                    onChanged: (val) {
                                      widget.messageText.value = val;
                                      if (widget.groupMembers?.isNotEmpty ==
                                          true) {
                                        widget.groupMessageController
                                            ?.onTextChanged(
                                          textController:
                                          widget.textController,
                                        );
                                      }
                                    },
                                    style: TextStyle(
                                      color: ToggleThemeData.white,
                                      fontFamily: FontFamily.interMedium,
                                      fontSize: 16.sp,
                                    ),
                                    maxLines: 4,
                                    minLines: 1,
                                    expands: false,
                                    decoration: InputDecoration(
                                      hintText: "Type a message",
                                      prefixIcon: GestureDetector(

                                        onTap: _toggleEmoji,
                                        child: Icon(
                                          Icons.emoji_emotions_outlined,
                                          color: Colors.white,
                                          size: 26.sp,
                                        ),
                                      ),
                                      hintStyle:
                                      TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(30.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.all(3.r),
                                        child: GestureDetector(
                                          onTap: () {
                                            ChatBottomSheet.showFileOptions(
                                              context,
                                              onGallery: () async {
                                                final List<File> images =
                                                await FileServices()
                                                    .pickMultipleImagesFromGallery();

                                                if (images.isNotEmpty) {
                                                  widget.onImageSelected(
                                                      images);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              onVideo: () async {
                                                Navigator.pop(context);
                                                var path = await FileServices()
                                                    .pickVideoFromGallery();
                                                widget.onvideoSelected(
                                                    path?.path ?? "");
                                              },
                                              onDocument: () async {
                                                Navigator.pop(context);
                                                final file =
                                                await FileServices()
                                                    .pickDocument();
                                                if (file != null) {
                                                  widget.onDocumentSelected(
                                                      file.path ?? "");
                                                }
                                              },
                                              onCamera: () {
                                                Navigator.pop(context);

                                                WidgetsBinding.instance
                                                    .addPostFrameCallback(
                                                        (_) async {
                                                      final result =
                                                      await Get.toNamed(
                                                          Routes.cameraScreen);

                                                      if (result != null &&
                                                          result is String &&
                                                          result.isNotEmpty) {
                                                        final ext = result
                                                            .split('.')
                                                            .last
                                                            .toLowerCase();
                                                        const videoExtensions = [
                                                          'mp4',
                                                          'mov',
                                                          'avi',
                                                          'mkv',
                                                          '3gp',
                                                          'webm'
                                                        ];

                                                        if (videoExtensions
                                                            .contains(ext)) {
                                                          widget.onvideoSelected(
                                                              result);
                                                        } else {
                                                          if (result.isNotEmpty) {
                                                            widget.onImageSelected(
                                                                [File(result)]);
                                                          }
                                                        }
                                                      }
                                                    });
                                              },
                                              onLocation: () async {
                                                Navigator.pop(context);

                                                widget.onLocationSelected();
                                              },
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                            ToggleThemeData.white,
                                            radius: 16,
                                            child: reausableIcon(
                                              icon:
                                              Icons.file_present_outlined,
                                              color: ToggleThemeData.Appcolor,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                      fillColor: ToggleThemeData.Appcolor,
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 14.h,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                if (shouldShowSend &&
                                    !voiceController.isRecording.value)
                                  GestureDetector(
                                    onTap: widget.isSending.value
                                        ? null
                                        : widget.onSend,
                                    child: CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor:
                                      ToggleThemeData.darkPurple,
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else if (!voiceController.isRecording.value)
                                  GestureDetector(
                                    onTap: () async {
                                      await voiceController.startRecording();
                                    },
                                    child: CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor:
                                      ToggleThemeData.darkPurple,
                                      child: Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!voiceController.isRecording.value &&
                      (widget.messageController?.showEmoji.value ??
                          widget.groupMessageController?.showEmoji.value ??
                          false))
                    SizedBox(
                      height: 300.h,
                      child: EmojiPicker(
                        textEditingController: widget.textController,
                        onEmojiSelected: (category, emoji) {
                          widget.messageText.value = widget.textController.text;
                        },
                        config: Config(
                          height: 300.h,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 8,
                            emojiSizeMax: 10 *
                                (ui.PlatformDispatcher
                                    .instance.views.first.devicePixelRatio),
                          ),
                          categoryViewConfig: const CategoryViewConfig(),
                          bottomActionBarConfig:
                          const BottomActionBarConfig(
                            showSearchViewButton: false,
                              enabled: false
                          ),
                          searchViewConfig: const SearchViewConfig(),
                        ),
                      ),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      itemCount: widget.imagePath.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: ImageViewerWidget(
                imageProvider: FileImage(widget.imagePath[index]),
                width: double.infinity,
                height: double.infinity,
                borderRadius: 12,
              ),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: InkWell(
                onTap: () => widget.imagePath.removeAt(index),
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.close,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                        () => widget.videoThumbnail.value != null
                        ? Image.memory(
                      widget.videoThumbnail.value!,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.black87,
                    ),
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
                  Obx(() {
                    if (!widget.isUploadingVideo.value) {
                      return Center(
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
                      );
                    }

                    return Container(
                      color: Colors.black.withOpacity(.45),
                      child: Center(
                        child: SizedBox(
                          width: 70.w,
                          height: 70.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70.w,
                                height: 70.w,
                                child: CircularProgressIndicator(
                                  value: widget.uploadProgress.value,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                "${(widget.uploadProgress.value * 100).toInt()}%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    bottom: 10.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.videoPath.value.split('/').last,
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
                            widget.videoDuration.value,
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
                widget.videoPath.value = '';
                widget.videoThumbnail.value = null;
                widget.videoDuration.value = '';
                widget.isUploadingVideo.value = false;
                widget.uploadProgress.value = 0.0;
              },
              child: CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black54,
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: Colors.white,
                ),
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
                    color: getFileColor(widget.documentPath.value),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    getFileIcon(widget.documentPath.value),
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
                        widget.documentPath.value.split('/').last,
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
                        getFileExtension(widget.documentPath.value)
                            .toUpperCase(),
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
              onTap: () => widget.documentPath.value = '',
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