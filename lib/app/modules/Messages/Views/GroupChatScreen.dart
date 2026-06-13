import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              child: GroupChatList(
                controller: controller,
                scrollController: controller.scrollController,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ChatInputArea(
                messageText: controller.messageText,
                imagePath: controller.imagePath,
                videoPath: controller.videoPath,
                isSending: controller.isSending,
                textController: textController,
                scrollController: controller.scrollController,
                videoDuration: controller.videoDuration,
                videoThumbnail: controller.videoThumbnail,
                onSend: () {
                  controller.sendMessage(
                    textController: textController,
                  );
                },
                onImageSelected: (path) {
                  controller.imagePath.value = path;
                },
                onVoiceSend: (voicePath) {
                  controller.uploadAudio(voicePath);
                },
                onvideoSelected: (path) async {
                  Navigator.pop(context);
                  if (Utility.isNotNullEmptyOrFalse(path)) {
                    controller.videoPath.value = path;


                      await controller.generateVideoPreview(
                        path,
                      );

                      controller.update();

                  }
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}
