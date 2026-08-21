import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
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
import '../../../Model/GetMessage.dart';
import '../Controller/MessageController.dart';
import 'message_Widgets.dart';

class ChatInputArea extends StatefulWidget {
  final RxString messageText;
  final RxList<File> imagePath;
  final RxList<String> videoPaths;
  final RxString documentPath;
  final RxBool isSending;
  final TextEditingController textController;
  final VoidCallback onSend;
  void Function(String)? onVoiceSend;
  final VoidCallback onContactSelected;
  final Function(List<File> path) onImageSelected;
  final Function(List<String> paths) onVideosSelected;
  final Function(String path) onDocumentSelected;
  final RxList<Uint8List?> videoThumbnails;
  final RxList<String> videoDurations;
  final RxBool isUploadingVideo;
  final RxDouble uploadProgress;
  final VoidCallback onLocationSelected;
  final MessageController? messageController;
  final GroupMessageController? groupMessageController;
  RxList<LocationData>? groupMembers;
  final RxSet<int> uploadingVideoIndexes;
  final RxMap<int, double> videoUploadProgress;

  ChatInputArea({
    super.key,
    required this.messageText,
    required this.imagePath,
    required this.videoPaths,
    required this.uploadingVideoIndexes,
    required this.videoUploadProgress,
    required this.isSending,
    required this.textController,
    required this.onSend,
    required this.onImageSelected,
    required this.onVideosSelected,
    required this.onVoiceSend,
    required this.videoDurations,
    required this.videoThumbnails,
    required this.onDocumentSelected,
    required this.documentPath,
    required this.isUploadingVideo,
    required this.uploadProgress,
    this.groupMembers,
    required this.onContactSelected,
    required this.onLocationSelected,
    this.groupMessageController,
    this.messageController,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final voiceController = Get.put(VoiceRecordController());
  MessageData? _lastEditingMessage;
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
        final editingMessage =
            widget.messageController?.editingMessage.value ??
                widget.groupMessageController?.editingMessage.value;

        final isEditing = editingMessage != null;
        if (editingMessage != null &&
            _lastEditingMessage?.id != editingMessage.id) {
          _lastEditingMessage = editingMessage;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final text = editingMessage.content?.toString() ?? "";

            widget.textController.text = text;

            widget.textController.selection =
                TextSelection.fromPosition(
                  TextPosition(
                    offset: text.length,
                  ),
                );

            widget.messageText.value = text;

            focusNode.requestFocus();
          });
        }
        final isImageSelected = widget.imagePath.value.isNotEmpty;
        final isVideoSelected = widget.videoPaths.value.isNotEmpty;
        final isDocumentSelected = widget.documentPath.value.isNotEmpty;
        final shouldShowSend = isMessageNotEmpty ||
            isImageSelected ||
            isVideoSelected ||
            isDocumentSelected;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Container(
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
                      offset: const Offset(0, -1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isImageSelected)
                      SizedBox(
                        height: 110.h,
                        child: _buildLargeImagePreview(),
                      ),
                    if (isVideoSelected)
                      SizedBox(
                        height: 110.h,
                        child: _buildLargeVideoPreview(),
                      ),
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
                                  widget.groupMessageController!.showMentionList
                                      .value &&
                                  widget.groupMessageController!.filteredMembers
                                      .isNotEmpty)
                                MentionlistItem(
                                  filteredMembers: widget
                                      .groupMessageController!.filteredMembers,
                                  onTap: (member) {
                                    widget.groupMessageController!
                                        .insertMention(
                                      member: member,
                                      textController: widget.textController,
                                    );
                                  },
                                ),
                              Row(
                                children: [
                                  Flexible(

                                    child:

                                    TextField(
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
                                      maxLines: 3,
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
                                                  Navigator.pop(context);

                                                  final List<XFile> mediaFiles =
                                                      await FileServices()
                                                          .pickMultipleMediaFromGallery();

                                                  if (mediaFiles.isEmpty)
                                                    return;

                                                  final List<File> images = [];
                                                  final List<String> videos =
                                                      [];

                                                  const videoExtensions = [
                                                    'mp4',
                                                    'mov',
                                                    'avi',
                                                    'mkv',
                                                    '3gp',
                                                    'webm',
                                                    'm4v'
                                                  ];

                                                  for (final file
                                                      in mediaFiles) {
                                                    final ext = file.path
                                                        .split('.')
                                                        .last
                                                        .toLowerCase();
                                                    if (videoExtensions
                                                        .contains(ext)) {
                                                      videos.add(file.path);
                                                    } else {
                                                      images
                                                          .add(File(file.path));
                                                    }
                                                  }

                                                  if (images.isNotEmpty) {
                                                    widget.onImageSelected(
                                                        images);
                                                  }

                                                  if (videos.isNotEmpty) {
                                                    widget.onVideosSelected(
                                                        videos);
                                                  }
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
                                                        await Get.toNamed(Routes
                                                            .cameraScreen);

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
                                                        widget.onVideosSelected(
                                                            [result]);
                                                      } else {
                                                        widget.onImageSelected(
                                                            [File(result)]);
                                                      }
                                                    }
                                                  });
                                                },
                                                onLocation: () async {
                                                  Navigator.pop(context);
                                                  widget.onLocationSelected();
                                                },
                                                onContact: () async {
                                                  Navigator.pop(context);
                                                  widget.onContactSelected();
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
                                          : () {
                                        if (isEditing) {
                                          final newText =
                                          widget.textController.text.trim();

                                          if (newText.isEmpty) return;

                                          if (widget.messageController != null) {
                                            widget.messageController!
                                                .updateEditedMessage(
                                              newText: newText,
                                            );
                                          } else if (widget.groupMessageController !=
                                              null) {
                                            widget.groupMessageController!
                                                .updateEditedMessage(
                                              newText: newText,
                                            );
                                          }

                                          widget.textController.clear();
                                          widget.messageText.value = "";
                                        } else {
                                          widget.onSend();
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 24.r,
                                        backgroundColor:
                                        ToggleThemeData.darkPurple,
                                        child: Icon(
                                          isEditing
                                              ? Icons.check
                                              : Icons.send,
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
                            widget.messageText.value =
                                widget.textController.text;
                          },
                          config: Config(
                            height: 300.h,
                            checkPlatformCompatibility: true,
                            emojiViewConfig: EmojiViewConfig(
                              columns: 8,
                              emojiSizeMax: 10 *
                                  (ui.PlatformDispatcher.instance.views.first
                                      .devicePixelRatio),
                            ),
                            categoryViewConfig: const CategoryViewConfig(),
                            bottomActionBarConfig: const BottomActionBarConfig(
                                showSearchViewButton: false, enabled: false),
                            searchViewConfig: const SearchViewConfig(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLargeImagePreview() {
    return Obx(() {
      final totalImages = widget.imagePath.length;
      if (totalImages == 0) return const SizedBox();

      final displayCount = totalImages > 3 ? 3 : totalImages;
      final remainingCount = totalImages - 3;

      return Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          children: List.generate(displayCount, (index) {
            final isLast = index == 2 && remainingCount > 0;
            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: index < displayCount - 1 ? 8.w : 0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
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
                      if (widget.isSending.value)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                              child: Center(
                                child: SizedBox(
                                  width: 35.w,
                                  height: 35.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isLast)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                              alignment: Alignment.center,
                              child: Text(
                                "+$remainingCount",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!widget.isSending.value)
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: InkWell(
                            onTap: () {
                              if (isLast && remainingCount > 0) {
                                widget.imagePath
                                    .removeRange(2, widget.imagePath.length);
                              } else {
                                widget.imagePath.removeAt(index);
                              }
                            },
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
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildLargeVideoPreview() {
    return Obx(() {
      final totalVideos = widget.videoPaths.length;
      if (totalVideos == 0) return const SizedBox();

      final displayCount = totalVideos > 3 ? 3 : totalVideos;
      final remainingCount = totalVideos - 3;

      return Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          children: List.generate(displayCount, (index) {
            final isLast = index == 2 && remainingCount > 0;

            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: index < displayCount - 1 ? 8.w : 0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          color: Colors.black87,
                          child: Obx(() {
                            final thumb = index < widget.videoThumbnails.length
                                ? widget.videoThumbnails[index]
                                : null;
                            if (thumb != null) {
                              return Image.memory(
                                thumb,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            }
                            return const SizedBox();
                          }),
                        ),
                      ),

                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white.withOpacity(0.85),
                              size: 34.sp,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: Obx(() {
                          final duration = index < widget.videoDurations.length
                              ? widget.videoDurations[index]
                              : '';
                          if (duration.isEmpty) return const SizedBox();
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              duration,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                      ),

                      Obx(() {
                        final isUploading =
                            widget.uploadingVideoIndexes.contains(index);
                        if (!isUploading) return const SizedBox();

                        final progress =
                            widget.videoUploadProgress[index] ?? 0.0;

                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                              child: Center(
                                child: SizedBox(
                                  width: 45.w,
                                  height: 45.w,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: progress > 0 ? progress : null,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                      if (progress > 0)
                                        Text(
                                          "${(progress * 100).toInt()}%",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      if (isLast)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                              alignment: Alignment.center,
                              child: Text(
                                "+$remainingCount",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                      Obx(() {
                        final isUploading =
                            widget.uploadingVideoIndexes.contains(index);
                        if (isUploading) return const SizedBox();

                        return Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: InkWell(
                            onTap: () {
                              if (isLast && remainingCount > 0) {
                                widget.videoPaths
                                    .removeRange(2, widget.videoPaths.length);
                                if (widget.videoThumbnails.length > 2) {
                                  widget.videoThumbnails.removeRange(
                                      2, widget.videoThumbnails.length);
                                }
                                if (widget.videoDurations.length > 2) {
                                  widget.videoDurations.removeRange(
                                      2, widget.videoDurations.length);
                                }
                              } else {
                                widget.videoPaths.removeAt(index);
                                if (index < widget.videoThumbnails.length) {
                                  widget.videoThumbnails.removeAt(index);
                                }
                                if (index < widget.videoDurations.length) {
                                  widget.videoDurations.removeAt(index);
                                }
                              }
                            },
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
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
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
                if (widget.isSending.value)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.isSending.value)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          if (!widget.isSending.value)
            Positioned(
              right: 8.w,
              top: 8.h,
              child: GestureDetector(
                onTap: () => widget.documentPath.value = '',
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
}
