import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Core/constant/const_res.dart';

import 'package:get/get.dart';

import '../Controller/GroupChatController.dart';

class GroupChatScreen extends GetView<GroupMessageController> {
  GroupChatScreen({super.key});

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          icon: Container(
            height: 28.w,
            width: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ToggleThemeData.darkPurple, width: 2.w),
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_outlined,
                color: ToggleThemeData.darkPurple,
                size: 22.sp,
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            BottomSheetUi().showMemberBottomSheet(
              context,
              controller.groupMembers.toList(),
              isGroupChat: true,
              groupId: int.parse(controller.groupId.toString()),
              groupName: controller.groupName,
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: controller.groupImage.isNotEmpty
                    ? NetworkImage(
                        "${ConstRes.aImageBaseUrl}${controller.groupImage}",
                      )
                    : null,
                backgroundColor: Colors.deepPurple.shade100,
                child: controller.groupImage.isEmpty
                    ? Icon(
                        Icons.group,
                        color: Colors.deepPurple,
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.groupName == ""
                        ? "Unknown"
                        : controller.groupName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Obx(
                    () => Text(
                      "${controller.groupMembers.length} Members",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                    () => Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: GroupChatList(
                    controller: controller,
                  ),
                ),
              ),
            ),
            Obx(() {
              final reply = controller.replyMessage.value;

              if (reply == null) return const SizedBox.shrink();

              String previewText;

              switch (reply.messageType) {
                case "image":
                  previewText = "📷 Photo";
                  break;
                case "video":
                  previewText = "🎥 Video";
                  break;
                case "audio":
                  previewText = "🎤 Voice message";
                  break;
                case "document":
                  previewText = "📄 Document";
                  break;
                default:
                  previewText = reply.content?.toString() ?? "";
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: ToggleThemeData.darkPurple,
                      width: 4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.senderName ?? "Unknown",
                            style: TextStyle(
                              color: ToggleThemeData.darkPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: controller.clearReply,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            }),
            ChatInputArea(
              messageText: controller.messageText,
              imagePath: controller.imagePaths,
              videoPath: controller.videoPath,
              documentPath: controller.documentPath,
              isSending: controller.isSending,
              textController: textController,
              videoDuration: controller.videoDuration,
              videoThumbnail: controller.videoThumbnail,
              groupMembers: controller.groupMembers,
              groupMessageController: controller,
              onSend: () {
                controller.sendMessage(
                  textController: textController,
                );
              },
              onImageSelected: (path) {
                controller.imagePaths.value = path;
              },
              onVoiceSend: (voicePath) {
                controller.uploadAudio(voicePath);
              },
              onvideoSelected: (path) async {
                if (Utility.isNotNullEmptyOrFalse(path)) {
                  controller.videoPath.value = path;
                  await controller.generateVideoPreview(
                    path,
                  );
                  controller.update();
                }
              },
              isUploadingVideo: controller.isUploadingVideo,
              uploadProgress: controller.uploadProgress,
              onDocumentSelected: (path) async {
                if (Utility.isNotNullEmptyOrFalse(path)) {
                  controller.documentPath.value = path;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
