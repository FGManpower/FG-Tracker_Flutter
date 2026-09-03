import 'package:fgtracker/app/Core/values/BottomSheets/BottomSheetUi.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Views/Group/ChatGroupProfile_Screen.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Core/constant/const_res.dart';

import 'package:get/get.dart';

import '../../../../global_widget/common_widget.dart';
import '../../Controller/GroupChatController.dart';
import '../../widgets/message_Widgets.dart';
import '../ContactPickerPage.dart';
import '../LocationPickerPage.dart';

class GroupChatScreen extends GetView<GroupMessageController> {
  GroupChatScreen({super.key});

  final TextEditingController textController = TextEditingController();
  final groupController = Get.put(GroupController());

  static const Color _purple = Color(0xFF5045B9);
  static const Color _scaffoldBg = Color(0xFFF5F3FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Obx(() {
          if (controller.isSearching.value) return _buildSearchAppBar();
          return _buildNormalAppBar(context);
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
                onClose: () => controller.unpinMessage(),
                onUnpin: () => controller.unpinMessage(),
              );
            }),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GroupChatList(controller: controller),
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
                                      color: Colors.black.withValues(alpha: 0.10),
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
              textController: textController,
              groupMembers: controller.groupMembers,
              groupMessageController: controller,
              uploadingVideoIndexes: controller.uploadingVideoIndexes,
              videoUploadProgress: controller.videoUploadProgress,
              onSend: () {
                controller.sendMessage(textController: textController);
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
                          "${ConstRes.aImageBaseUrl}${controller.groupImage}",
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
                          Text(
                            controller.groupName.isEmpty
                                ? "Unknown"
                                : controller.groupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(() {
                            final total = controller.groupMembers.length;
                            final online =
                            total > 0 ? (total ~/ 2).clamp(1, total) : 0;
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
              onTap: () {
                // TODO: call
              },
            ),
            SizedBox(width: 6.w),
            _roundIconBtn(
              icon: Icons.videocam_rounded,
              onTap: () {
                // TODO: video
              },
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () => _showMoreMenu(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: const Color(0xFF5045B9),
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
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

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
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
                controller.isCreator.value ? "Group Actions" : "Chat Actions",
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
                  iconColor: _purple,
                  title: "Update Group",
                  subtitle: "Change the current group detail",
                  onTap: () {
                    Navigator.pop(context);
                    groupController.groupName.text = controller.groupName;
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
                  backgroundColor: _purple,
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
  }
}