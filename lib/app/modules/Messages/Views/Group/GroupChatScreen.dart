import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Views/Group/ChatGroupProfile_Screen.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/constant/const_res.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../Controller/GroupChatController.dart';
import '../ContactPickerPage.dart';
import '../LocationPickerPage.dart';

class GroupChatScreen extends GetView<GroupMessageController> {
  GroupChatScreen({super.key});

  final groupController = Get.put(GroupController());

  static const Color _purple = Color(0xFF5045B9);
  static const Color _scaffoldBg = Color(0xFFF5F3FB);

  void _dismissKeyboard(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      FocusScope.of(context).unfocus();
    }
    if (controller.showEmoji.value) {
      controller.showEmoji.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Obx(() {
          if (controller.isSearching.value) return _buildSearchAppBar();
          return _buildNormalAppBar(context);
        }),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
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
                onClose: () => controller.unpinMessage(),
                onUnpin: () => controller.unpinMessage(),
              );
            }),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification &&
                      notification.direction != ScrollDirection.idle) {
                    _dismissKeyboard(context);
                  }
                  return false;
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _dismissKeyboard(context),
                      child: GroupChatList(controller: controller),
                    ),
                    Obx(() {
                      final isVisible = controller.showFloatingDate.value;
                      final date = controller.floatingDate.value;

                      if (date.isEmpty) return const SizedBox.shrink();

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
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.10),
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
                    _buildScrollToBottomButton(),
                  ],
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

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _dismissKeyboard(context),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: _purple, width: 4),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
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
                              style: const TextStyle(
                                color: _purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(previewText,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.clearReply,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              final typingText = controller.groupTypingText.value;
              if (typingText.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                color: _scaffoldBg,
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 14.sp,
                      color: Colors.green.shade600,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        typingText,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
              textController: controller.textEditingController,
              groupMembers: controller.groupMembers,
              groupMessageController: controller,
              uploadingVideoIndexes: controller.uploadingVideoIndexes,
              videoUploadProgress: controller.videoUploadProgress,
              onSend: () {
                controller.sendMessage(
                    textController: controller.textEditingController);
              },
              onImageSelected: (paths) => controller.imagePaths.addAll(paths),
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
                    () => const LocationPickerPage());
                if (location != null) {
                  await controller.sendLocation(location: location);
                }
              },
              onContactSelected: () async {
                final contact = await Get.to<ContactMessage>(
                    () => const ContactPickerPage());
                if (contact != null) {
                  await controller.sendContact(contact: contact);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Obx(() {
      final isVisible = controller.showScrollToBottom.value;
      final unreadCount = controller.unreadBelowCount.value;

      return Positioned(
        bottom: 12.h,
        right: 14.w,
        child: AnimatedScale(
          scale: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.scrollToBottom();
                    controller.unreadBelowCount.value = 0;
                    controller.showScrollToBottom.value = false;
                  },
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _purple,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.h,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? "99+" : "$unreadCount",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
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
          final display = total == 0 ? "0/0" : "${total - current}/$total";
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(display,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          );
        }),
        Obx(() => IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black),
              onPressed: controller.searchResultIds.isEmpty
                  ? null
                  : controller.previousSearchResult,
            )),
        Obx(() => IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              onPressed: controller.searchResultIds.isEmpty
                  ? null
                  : controller.nextSearchResult,
            )),
      ],
    );
  }

  Future<void> _initiateGroupCall({
    required bool isVideo,
  }) async {
    try {
      Get.toNamed(
        Routes.groupCallingScreen,
        arguments: {
          "groupId": controller.groupId.toString(),
          "groupName": controller.groupName.isEmpty
              ? "Unknown Group"
              : controller.groupName,
          "groupProfile": controller.groupImage,
          "isVideo": isVideo,
          "memberCount": controller.groupMembers.length,
          "callType": "outgoing",
        },
      );
    } catch (e) {
      debugPrint("Error initiating group call: $e");
      Get.snackbar(
        "Error",
        "Could not start group call. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildNormalAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF5F3FB),
      surfaceTintColor: const Color(0xFFF5F3FB),
      automaticallyImplyLeading: false,
      toolbarHeight: 64.h,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 8.w),
        child: Row(
          children: [
            _roundIconBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.to(
                    () => const GroupProfileScreen(),
                    arguments: {
                      "groupCode": Get.arguments?["groupCode"],
                    },
                  );
                },
                child: Row(
                  children: [
                    Container(
                      height: 40.w,
                      width: 40.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B78FF), Color(0xFF6A5AE0)],
                        ),
                      ),
                      child: controller.groupImage.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                controller.groupImage.startsWith('http://') ||
                                        controller.groupImage
                                            .startsWith('https://')
                                    ? controller.groupImage
                                    : "${ConstRes.aImageBaseUrl}${controller.groupImage}",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.groups_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.groups_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.groupName.value.isEmpty
                                  ? "Unknown"
                                  : controller.groupName.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(() {
                            final typingText =
                                controller.groupTypingText.value;
                            if (typingText.isNotEmpty) {
                              return Text(
                                typingText,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }

                            final total = controller.groupMembers.length;
                            return Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "$total Members",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4.w),
            _roundIconBtn(
              icon: Icons.call_rounded,
              onTap: () => _initiateGroupCall(
                isVideo: false,
              ),
            ),
            SizedBox(width: 6.w),
            _roundIconBtn(
              icon: Icons.videocam_rounded,
              onTap: () => _initiateGroupCall(
                isVideo: true,
              ),
            ),
            SizedBox(width: 2.w),
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton<int>(
                offset: const Offset(0, 50),
                color: const Color(0xFFF9F8FF),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                icon: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: const Color(0xFF5045B9),
                    size: 24.sp,
                  ),
                ),
                onSelected: (value) {
                  if (value == 0) {
                    controller.startSearch();
                  } else if (value == 1) {
                    groupController.groupName.text = controller.groupName.value;
                    groupController.groupDesc.text = controller.groupDesc.value;
                    groupController.selectedGroupImage.value = null;

                    DialogBox().showUpdateGroupBottomSheet(
                      context: context,
                      controller: groupController,
                      groupId: controller.groupId.toString(),
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    _buildPopupMenuItem(
                      value: 0,
                      icon: Icons.search,
                      iconColor: const Color(0xFF5045B9),
                      title: "Search Messages",
                    ),
                    if (controller.isCreator.value) ...[
                      _buildPopupMenuItem(
                        value: 1,
                        icon: Icons.edit_rounded,
                        iconColor: const Color(0xFF5045B9),
                        title: "Update Group",
                      ),
                    ]
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem({
    required int value,
    required IconData icon,
    required Color iconColor,
    required String title,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<int>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 46.h,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20.sp,
          ),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.redAccent : const Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.w,
        width: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5045B9),
          size: 18.sp,
        ),
      ),
    );
  }
}
