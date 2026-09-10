import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../widgets/ChatInputArea.dart';
import '../widgets/ChatList.dart';
import 'ContactPickerPage.dart';
import 'LocationPickerPage.dart';
import 'UserProfileScreen.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();
  final groupController = Get.put(GroupController());

  static const Color _purple = Color(0xFF5045B9);
  static const Color _scaffoldBg = Color(0xFFF5F3FB);

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
        backgroundColor: _scaffoldBg,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.h),
          child: Obx(() {
            if (controller.isSearching.value) return _buildSearchAppBar();
            return _buildNormalAppBar(
                context, userData, isOnline, lastSeenText);
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
                    ChatList(controller: controller),
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
                    await controller.sendLocation(location: location);
                  }
                },
                onContactSelected: () async {
                  final contact = await Get.to<ContactMessage>(
                    () => const ContactPickerPage(),
                  );
                  if (contact != null) {
                    await controller.sendContact(contact: contact);
                  }
                },
              ),
            ],
          ),
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

  Widget _buildNormalAppBar(BuildContext context, dynamic userData,
      bool isOnline, String lastSeenText) {
    return AppBar(
      elevation: 0,
      backgroundColor: _scaffoldBg,
      surfaceTintColor: _scaffoldBg,
      automaticallyImplyLeading: false,
      toolbarHeight: 64.h,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 8.w),
        child: Row(
          children: [
            _roundIconBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () {
                controller.handleBackPressed(context,
                    groupID: int.parse(userData.groupId.toString()));
              },
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const UserProfileScreen());
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
                      child: (userData.profileImage != null &&
                              userData.profileImage.toString().isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                "${ConstRes.aImageBaseUrl}${userData.profileImage}",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
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
                            userData.name?.toString().isEmpty ?? true
                                ? "Unknown"
                                : userData.name.toString(),
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
                          Row(
                            children: [
                              if (isOnline)
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  margin: EdgeInsets.only(right: 5.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  isOnline ? "Online" : lastSeenText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isOnline
                                        ? Colors.green
                                        : Colors.grey.shade600,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                controller.startCall(
                  context,
                  callerId:
                      Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: false,
                  callerName: controller.memberData.name,
                );
              },
            ),
            SizedBox(width: 6.w),
            _roundIconBtn(
              icon: Icons.videocam_rounded,
              onTap: () {
                controller.startCall(
                  context,
                  callerId:
                      Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: true,
                  callerName: controller.memberData.name,
                );
              },
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
                    color: _purple,
                    size: 24.sp,
                  ),
                ),
                onSelected: (value) {
                  if (value == 0) {
                    controller.startSearch();
                  } else if (value == 1) {
                    groupController.groupName.text =
                        controller.arguments?['groupName'] ?? "";
                    DialogBox().showUpdateGroupBottomSheet(
                      context: context,
                      controller: groupController,
                      groupId: userData.groupId.toString(),
                    );
                  } else if (value == 2) {
                    CommonDialog.ConfirmationDialog(
                      title: "Remove Member",
                      content:
                          "Are you sure you want to remove this member from the group?",
                      confirm: "Remove",
                      onConfirm: () {
                        groupController.deleteGroupMember(
                          context,
                          groupId: userData.groupId.toString(),
                          groupMemberId:
                              controller.memberData.userId.toString(),
                          onSuccess: (success) {
                            if (success) {
                              Get.offAllNamed(Routes.Home_Screen);
                            }
                          },
                        );
                      },
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    _buildPopupMenuItem(
                      value: 0,
                      icon: Icons.search,
                      iconColor: _purple,
                      title: "Search Messages",
                    ),
                    _buildPopupMenuItem(
                      value: 1,
                      icon: Icons.edit_rounded,
                      iconColor: _purple,
                      title: "Update Group",
                    ),
                    _buildPopupMenuItem(
                      value: 2,
                      icon: Icons.person_remove_rounded,
                      iconColor: Colors.redAccent,
                      title: "Delete Member",
                      isDestructive: true,
                    ),
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
          Icon(icon, color: iconColor, size: 20.sp),
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
        child: Icon(icon, color: _purple, size: 18.sp),
      ),
    );
  }
}
