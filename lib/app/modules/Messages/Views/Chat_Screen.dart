import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Walkie-talkie/Controller/walkieController.dart';
import '../widgets/ChatInputArea.dart';
import '../widgets/ChatList.dart';
import 'ContactPickerPage.dart';
import 'LocationPickerPage.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  final wc = Get.put(WalkieController());
  final groupController = Get.put(GroupController());

  Future<void> _sendMessage() async {
    await controller.sendMessage(textController: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final userData = controller.memberData;
    String lastSeenText = "Offline";
    bool isOnline = false;

    if (userData.lastSeen != null && userData.lastSeen!.trim().isNotEmpty) {
      final rawLastSeen = userData.lastSeen!.trim();

      try {
        lastSeenText = Tracking().getTimeAgo(DateTime.parse(rawLastSeen));
      } catch (_) {
        // Already formatted string ("2 hours ago", "Just now", etc.)
        lastSeenText = rawLastSeen;
      }

      isOnline = lastSeenText.toLowerCase() == "just now";
    }

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackPressed(context,
            groupID: int.parse(userData.groupId.toString()));
        return false;
      },
      child: Scaffold(
        backgroundColor: ToggleThemeData.chatBackground,
        resizeToAvoidBottomInset: true,
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

            return CommonChatAppBar(
              profileImageUrl:
                  "${ConstRes.aImageBaseUrl}${userData.profileImage ?? ""}",
              userName: userData.name ?? "",
              controller: controller,
              groupName: controller.arguments?['groupName'],
              isOnline: isOnline,
              lastSeen: lastSeenText,
              isGroupChat: false,
              onBackTap: () {
                controller.handleBackPressed(context,
                    groupID: int.parse(userData.groupId.toString()));
              },
              onCallTap: () {
                controller.startCall(
                  context,
                  callerId:
                      Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: false,
                  callerName: controller.memberData.name,
                );
              },
              onVideoTap: () {
                controller.startCall(
                  context,
                  callerId:
                      Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: true,
                  callerName: controller.memberData.name,
                );
              },
              onUpdateGroupName: () {
                groupController.groupName.text =
                    controller.arguments?['groupName'] ?? "";
                DialogBox().showUpdateGroupBottomSheet(
                    context: context,
                    controller: groupController,
                    groupId: userData.groupId.toString());
              },
              onDeleteMember: () {
                CommonDialog.ConfirmationDialog(
                  title: "Remove Member",
                  content:
                      "Are you sure you want to remove this member from the group?",
                  confirm: "Remove",
                  onConfirm: () {
                    groupController.deleteGroupMember(
                      context,
                      groupId: userData.groupId.toString(),
                      groupMemberId: controller.memberData.userId.toString(),
                      onSuccess: (success) {
                        if (success) {
                          Get.offAllNamed(Routes.Home_Screen);
                        }
                      },
                    );
                  },
                );
              },
              onSearchTap: () => controller.startSearch(),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ChatList(
                      controller: controller,
                    ),
                    Obx(() {
                      final isVisible = controller.showFloatingDate.value;
                      final date = controller.floatingDate.value;

                      if (date.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IgnorePointer(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedSlide(
                            offset:
                                isVisible ? Offset.zero : const Offset(0, -0.8),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: AnimatedOpacity(
                              opacity: isVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() {
                final reply = controller.replyMessage.value;

                if (reply == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 42,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reply.senderName?.toString() ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reply.content?.toString() ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.clearReply,
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                );
              }),
              ChatInputArea(
                messageText: controller.messageText,
                imagePath: controller.imagePaths,
                videoPaths: controller.videoPaths,
                videoThumbnails: controller.videoThumbnails,
                videoDurations: controller.videoDurations,
                documentPath: controller.documentPath,
                isSending: controller.isSending,
                textController: _controller,
                messageController: controller,
                onSend: _sendMessage,
                uploadingVideoIndexes: controller.uploadingVideoIndexes,
                videoUploadProgress: controller.videoUploadProgress,
                onImageSelected: (paths) {
                  controller.imagePaths.addAll(paths);
                },
                onVoiceSend: (voicePath) {
                  if (Utility.isNotNullEmptyOrFalse(voicePath)) {
                    controller.uploadAudio(voicePath);
                  }
                },
                onVideosSelected: (paths) async {
                  if (paths.isNotEmpty) {
                    await controller.addVideos(paths);
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
      ),
    );
  }
}
