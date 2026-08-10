import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Core/constant/const_res.dart';

import 'package:get/get.dart';

import '../../../global_widget/common_widget.dart';
import '../Controller/GroupChatController.dart';
import '../widgets/message_Widgets.dart';
import 'ContactPickerPage.dart';
import 'LocationPickerPage.dart';

class GroupChatScreen extends GetView<GroupMessageController> {
  GroupChatScreen({super.key});

  final TextEditingController textController = TextEditingController();
  final groupController = Get.put(GroupController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          if (controller.isSearching.value) {
            return AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => controller.stopSearch(),
              ),
              title: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search messages...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: controller.onSearchChanged,
              ),
              actions: [
                Obx(() {
                  final total = controller.searchResultIds.length;
                  final current = controller.currentSearchIndex.value;
                  final display =
                      total == 0 ? "0/0" : "${total - current}/$total";
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Text(
                        display,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
                Obx(() => IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up,
                          color: Colors.black),
                      onPressed: controller.searchResultIds.isEmpty
                          ? null
                          : controller.previousSearchResult,
                    )),
                Obx(() => IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.black),
                      onPressed: controller.searchResultIds.isEmpty
                          ? null
                          : controller.nextSearchResult,
                    )),
              ],
            );
          }
          return AppBar(
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
                  border:
                      Border.all(color: ToggleThemeData.darkPurple, width: 2.w),
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
                  isDeleteMode: true
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
                        ? const Icon(Icons.group, color: Colors.deepPurple)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.groupName.isEmpty
                              ? "Unknown"
                              : controller.groupName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Obx(
                          () => Text(
                            "${controller.groupMembers.length} Members",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: ToggleThemeData.darkPurple,
                  size: 26.sp,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30.r),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              controller.isCreator.value
                                  ? "Group Actions"
                                  : "Chat Actions",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              controller.isCreator.value
                                  ? "Manage your group settings"
                                  : "Manage your chat",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            actionTile(
                              icon: Icons.search,
                              iconColor: Colors.blueAccent,
                              title: "Search Messages",
                              subtitle: "Find messages by keyword",
                              onTap: () {
                                Navigator.pop(context);
                                controller.startSearch();
                              },
                            ),
                            if (controller.isCreator.value) ...[
                              SizedBox(height: 12.h),
                              actionTile(
                                icon: Icons.edit_rounded,
                                iconColor: ToggleThemeData.darkPurple,
                                title: "Update Group",
                                subtitle: "Change the current group detail",
                                onTap: () {
                                  Navigator.pop(context);
                                  groupController.groupName.text =
                                      controller.groupName;
                                  DialogBox().showUpdateGroupBottomSheet(
                                    context: context,
                                    controller: groupController,
                                    groupId: controller.groupId.toString(),
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                              actionTile(
                                icon: Icons.person_remove_rounded,
                                iconColor: Colors.red,
                                title: "Delete Member",
                                subtitle: "Remove a member from this group",
                                onTap: () {
                                  Navigator.pop(context);

                                  BottomSheetUi().showMemberBottomSheet(
                                    context,
                                    controller.groupMembers.toList(),
                                    isGroupChat: true,
                                    groupId: controller.groupId,
                                    groupName: controller.groupName,
                                    isDeleteMode: true,
                                  );
                                },
                              ),
                            ],
                            SizedBox(height: 20.h),
                            SizedBox(
                              width: double.infinity,
                              child: reausablebutton(
                                title: "Cancel",
                                ontap: () => Navigator.pop(context),
                                height: 52,
                                borderradiues: 50,
                                backgroundColor: ToggleThemeData.darkPurple,
                                textcolor: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final pinned = controller.pinnedMessage.value;
              if (pinned == null || !controller.showPinnedBanner.value) {
                return const SizedBox.shrink();
              }
              return PinnedMessageBanner(
                pinnedMessage: pinned,
                onTap: () => controller.scrollToPinnedMessage(),
                onClose: () => controller.showPinnedBanner.value = false,
                onUnpin: () => controller.unpinMessage(),
              );
            }),
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
              onLocationSelected: () async {
                final location = await Get.to<LocationMessage>(
                  () => const LocationPickerPage(),
                );

                if (location != null) {
                  await controller.sendLocation(
                    location: location,
                  );
                }
              },
              onContactSelected: () async {
                final contact = await Get.to<ContactMessage>(
                  () => const ContactPickerPage(),
                );

                if (contact != null) {
                  await controller.sendContact(
                    contact: contact,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
