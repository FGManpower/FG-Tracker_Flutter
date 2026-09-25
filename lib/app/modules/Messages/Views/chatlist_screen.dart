import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/util/chatutil.dart';
import '../../../routes/app_pages.dart';
import '../../Safe_Zone/views/safe_zone_view.dart';
import '../../Safe_Zone/views/safety_dashboard_view.dart';
import '../../Track/Views/Tracking_screen.dart';
import '../Controller/MessageController.dart';
import '../Controller/chat_list_controller.dart';
import '../widgets/custom_dropdown_menu.dart';
import 'ArchivedChatsScreen.dart';
import 'Chat_Screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatListController controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: _AllChatsBody(controller: controller),
          ),
          Positioned(
            right: 16.w,
            bottom: 170.h,
            child: FloatingActionButton(
              onPressed: () => Get.to(() => const NewChatScreen()),
              backgroundColor: const Color(0xFF6B4DFF),
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildQuickCommunication(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          _circleIcon(
            Icons.arrow_back,
            () => Get.back(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "Chat",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                reausabletext(
                  "Stay connected with your team",
                  fontsize: 11.sp,
                  fontweight: const FontWeight(500),
                  color: const Color(0xFF6B4DFF),
                ),
              ],
            ),
          ),
          _circleIcon(
            Icons.more_vert,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCommunication(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.h, bottom: 15.h, left: 8.w, right: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: reausabletext(
              "Quick Communication",
              fontsize: 12.sp,
              fontfamily: FontFamily.interBold,
              color: const Color(0xFF1B1B50),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: reausabletext(
              "Connect with your team instantly",
              fontsize: 10.sp,
              color: const Color(0xFF6B4DFF),
              fontweight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickCommCard(
                icon: Icons.speaker_phone_rounded,
                title: "Walkie",
                subtitle: "Push to Talk",
                onTap: () {
                  Get.toNamed(Routes.WalkieGroupSelect);
                },
              ),
              _quickCommCard(
                icon: Icons.location_on,
                title: "Tracking",
                subtitle: "Live Location",
                onTap: () {
                  Get.toNamed(Routes.TrackingScreen);
                },
              ),
              _quickCommCard(
                icon: Icons.people_alt_rounded,
                title: "Groups",
                subtitle: "Team Chats",
                onTap: () {
                  Get.toNamed(Routes.totalGroup);
                },
              ),
              _quickCommCard(
                icon: Icons.verified_user_rounded,
                title: "Safe Zone",
                subtitle: "Safety & Alerts",
                onTap: () {
                  Get.toNamed(Routes.SafetyDashboard);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickCommCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isNewChat = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(
            vertical: 6.h,
            horizontal: 2.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, isNewChat ? -3.h : 0),
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE9E7FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B4DFF).withValues(alpha: 0.12),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF5B50E8),
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: reausabletext(
                  title,
                  fontsize: 10.sp,
                  fontfamily: FontFamily.interBold,
                  color: const Color(0xFF1B1B50),
                  maxline: 1,
                ),
              ),
              SizedBox(height: 2.h),
              Center(
                child: reausabletext(
                  subtitle,
                  fontsize: 8.sp,
                  fontfamily: FontFamily.interMedium,
                  color: const Color(0xFF6B4DFF).withValues(alpha: 0.58),
                  maxline: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllChatsBody extends StatelessWidget {
  final ChatListController controller;

  const _AllChatsBody({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF6B4DFF),
      onRefresh: controller.refreshChats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _archivedChatsRow(),

            _sectionTitle(
              "All Chats",
            ),

            Obx(() {
              if (controller.isLoading.value &&
                  controller.privateChats.isEmpty) {
                return _buildSkeletonList();
              }

              if (controller.privateChats.isEmpty) {
                return _emptyChats();
              }

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.03,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: controller.privateChats.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.grey.withValues(
                      alpha: 0.12,
                    ),
                    height: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
                  itemBuilder: (context, index) {
                    final chat = controller.privateChats[index];

                    return _chatRow(
                      context: context,
                      chat: chat,
                      name: chat.name ?? "Unknown User",
                      role: chat.role ?? "",
                      msg: ChatUtil.formatLastMessage(chat.message),
                      time: _formatChatTime(
                        chat.time ?? "",
                      ),
                      unreadCount: chat.unreadCount ?? 0,
                      statusColor: _statusColor(chat.status),
                      isGroup: chat.isGroup ?? false,
                      image: chat.image,
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 150.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 6,
          separatorBuilder: (_, __) => Divider(
            color: Colors.grey.withValues(alpha: 0.12),
            height: 1,
            indent: 16.w,
            endIndent: 16.w,
          ),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 120.w, height: 14.h, color: Colors.grey),
                        SizedBox(height: 6.h),
                        Container(
                            width: 180.w, height: 12.h, color: Colors.grey),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40.w, height: 11.h, color: Colors.grey),
                      SizedBox(height: 6.h),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyChats() {
    // ... same as your previous code ...
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 35.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 40.sp,
              color: const Color(0xFF6B4DFF),
            ),
            SizedBox(height: 10.h),
            reausabletext(
              "No chats found",
              fontsize: 14.sp,
              fontfamily: FontFamily.interBold,
              color: Colors.black87,
            ),
            SizedBox(height: 5.h),
            reausabletext(
              "Your private chats will appear here.",
              fontsize: 11.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    bool showViewAll = false,
    int? badgeCount,
    bool showDropdown = false,
  }) {
    // ... same as your previous code ...
    final bool isPinned = title == "Pinned Chats 📌";

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          reausabletext(
            isPinned ? "Pinned Chats" : title,
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          if (isPinned) ...[
            SizedBox(width: 5.w),
            Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.push_pin_rounded,
                size: 16.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ],
          if (badgeCount != null) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Color(0xFFEBE7FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            ),
          ],
          const Spacer(),
          if (showViewAll)
            reausabletext(
              "View All >",
              fontsize: 12.sp,
              color: const Color(0xFF6B4DFF),
            ),
          if (showDropdown)
            Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: const Color(0xFF6B4DFF),
            ),
        ],
      ),
    );
  }

  Widget _chatRow({
    required BuildContext context,
    required String name,
    required String role,
    required PrivateChatModel chat,
    required String msg,
    required String time,
    int unreadCount = 0,
    Color? statusColor,
    bool isGroup = false,
    String? image,
  }) {
    // ... same as your previous code ...
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) {
        tapPos = d.globalPosition;
      },
      onTap: () async {
        final chat = controller.privateChats.firstWhere(
          (item) => item.name == name && item.image == image,
          orElse: () => controller.privateChats.first,
        );

        if (chat.userId == null) {
          return;
        }

        await Get.to(
          () => ChatScreen(),
          arguments: {
            "userData": MemberData(
              userId: chat.userId,
              name: chat.name,
              profileImage: chat.image,
              groupId: 0,
            ),
          },
          binding: BindingsBuilder(() {
            Get.put(MessageController());
          }),
        );
      },
      onLongPress: () => _showChatOptions(
        context,
        tapPos,
        chat,
      ),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        child: _chatRowContent(
          name: name,
          role: role,
          msg: msg,
          time: time,
          unreadCount: unreadCount,
          statusColor: statusColor,
          isGroup: isGroup,
          isPinned: chat.isPinned == true,
          isMuted: chat.isMuted == true,
          image: image,
        ),
      ),
    );
  }

  Widget _chatRowContent({
    required String name,
    required String role,
    required String msg,
    required String time,
    int unreadCount = 0,
    Color? statusColor,
    bool isGroup = false,
    bool isPinned = false,
    bool isMuted = false,
    String? image,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor:
                  isGroup ? const Color(0xFF6B4DFF) : Colors.grey.shade300,
              backgroundImage: (!isGroup && image != null && image.isNotEmpty)
                  ? NetworkImage(
                      image.startsWith("http://") ||
                              image.startsWith("https://")
                          ? image
                          : "${ConstRes.production}$image",
                    )
                  : null,
              child: isGroup
                  ? Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 24.sp,
                    )
                  : (image == null || image.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26.sp,
                        )
                      : null),
            ),
            if (statusColor != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: reausabletext(
                      name.isEmpty ? "Unknown User" : name,
                      fontsize: 12.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.black87,
                      maxline: 1,
                    ),
                  ),
                  if (isPinned) ...[
                    SizedBox(width: 5.w),
                    Transform.rotate(
                      angle: 0.5,
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 14.sp,
                        color: const Color(0xFF6B4DFF),
                      ),
                    ),
                  ],
                  if (isMuted) ...[
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.notifications_off_rounded,
                      size: 14.sp,
                      color: Colors.grey,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4.h),
              reausabletext(
                msg.isEmpty ? "" : msg,
                fontsize: 10.sp,
                fontfamily: FontFamily.interMedium,
                color: const Color(0xFF6B4DFF),
                maxline: 1,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            reausabletext(
              time,
              fontsize: 9.sp,
              color: const Color(0xFF6B4DFF),
              maxline: 1,
            ),
            SizedBox(height: 6.h),
            if (unreadCount > 0)
              Container(
                width: 18.w,
                height: 18.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4DFF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white,
                    fontFamily: FontFamily.interSemiBold,
                  ),
                ),
              )
            else
              SizedBox(height: 20.w),
          ],
        ),
        SizedBox(width: 16.w),
        Icon(
          Icons.chevron_right_rounded,
          size: 20.sp,
          color: const Color(0xFF6B4DFF),
        ),
      ],
    );
  }

  void _showChatOptions(
    BuildContext context,
    Offset position,
    PrivateChatModel chat,
  ) {
    final bool isPinned = chat.isPinned == true;
    final bool isMuted = chat.isMuted == true;
    CustomDropdownMenu.show(
      context: context,
      position: position,
      width: 210,
      items: [
        DropdownMenuItemData(
          icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          title: isPinned ? "Unpin Chat" : "Pin Chat",
          onTap: () {
            if (isPinned) {
              controller.unpinChat(chat);
            } else {
              controller.pinChat(chat);
            }
          },
        ),
        DropdownMenuItemData(
          icon: isMuted
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          title: isMuted ? "Unmute Notifications" : "Mute Notifications",
          onTap: () {
            if (isMuted) {
              controller.unmuteChat(chat);
            } else {
              _showMuteOptions(context, chat);
            }
          },
        ),
        DropdownMenuItemData(
          icon: Icons.mark_email_read_outlined,
          title: "Mark as Read",
          onTap: () {
            controller.markChatAsRead(chat);
          },
        ),
        DropdownMenuItemData(
          icon: Icons.person_outline,
          title: "View Contact",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.visibility_off_outlined,
          title: "Archive Chat",
          onTap: () {
            controller.archiveChat(chat);
          },
        ),
        DropdownMenuItemData(
          icon: Icons.delete_outline,
          title: "Delete Chat",
          isDestructive: true,
          onTap: () {
            controller.deleteChat(chat);
          },
        ),
      ],
    );
  }

  Color? _statusColor(String? status) {
    final value = (status ?? "").toLowerCase().trim();
    if (value == "online" || value == "active" || value == "available") {
      return Colors.green;
    }
    if (value == "away" || value == "busy") return Colors.orange;
    if (value == "offline" || value == "inactive") return Colors.grey;
    if (value == "dnd" ||
        value == "do_not_disturb" ||
        value == "do not disturb") {
      return Colors.red;
    }
    return null;
  }
  String _formatChatTime(String value) {
    if (value.isEmpty) return "";
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inHours < 1) return "${difference.inMinutes} min";
    if (difference.inDays == 0) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour >= 12 ? "PM" : "AM";
      return "$hour:$minute $period";
    }
    if (difference.inDays == 1) return "Yesterday";
    if (difference.inDays < 7) return "${difference.inDays} days";
    return "${local.day}/${local.month}/${local.year}";
  }

  void _showMuteOptions(
    BuildContext context,
    PrivateChatModel chat,
  ) {
    String selectedOption = "1_hour";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              titlePadding: EdgeInsets.fromLTRB(
                20.w,
                18.h,
                20.w,
                4.h,
              ),
              contentPadding: EdgeInsets.fromLTRB(
                20.w,
                0,
                20.w,
                2.h,
              ),
              actionsPadding: EdgeInsets.fromLTRB(
                12.w,
                0,
                12.w,
                6.h,
              ),
              title: reausabletext(
                "Mute notifications",
                fontsize: 20.sp,
                fontfamily: FontFamily.interSemiBold,
                color: Colors.black87,
                maxline: 1,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h),
                  reausabletext(
                    "Choose how long you want to pause notifications.",
                    fontsize: 13.sp,
                    fontfamily: FontFamily.interRegular,
                    color: Colors.black,
                    maxline: 2,
                  ),
                  SizedBox(height: 8.h),
                  _muteDialogOption(
                    title: "1 hour",
                    value: "1_hour",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  _muteDialogOption(
                    title: "8 hours",
                    value: "8_hours",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  _muteDialogOption(
                    title: "Until tomorrow",
                    value: "until_tomorrow",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                  _muteDialogOption(
                    title: "Until I turn it back on",
                    value: "always",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: reausabletext(
                    "Cancel",
                    fontsize: 14.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: const Color(0xFF8080EE),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    String? mutedUntil;

                    if (selectedOption == "1_hour") {
                      mutedUntil = DateTime.now()
                          .add(const Duration(hours: 1))
                          .toIso8601String();
                    } else if (selectedOption == "8_hours") {
                      mutedUntil = DateTime.now()
                          .add(const Duration(hours: 8))
                          .toIso8601String();
                    } else if (selectedOption == "until_tomorrow") {
                      final tomorrow = DateTime.now().add(
                        const Duration(days: 1),
                      );

                      mutedUntil = DateTime(
                        tomorrow.year,
                        tomorrow.month,
                        tomorrow.day,
                        8,
                        0,
                      ).toIso8601String();
                    } else {
                      mutedUntil = null;
                    }

                    Navigator.pop(dialogContext);

                    controller.muteChat(
                      chat,
                      mutedUntil: mutedUntil,
                    );
                  },
                  child: reausabletext(
                    "OK",
                    fontsize: 14.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: const Color(0xFF8080EE),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _muteDialogOption({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final bool selected = value == groupValue;

    return InkWell(
      onTap: () {
        onChanged(value);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFF8080EE) : Colors.black45,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8080EE),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: reausabletext(
                title,
                fontsize: 14.sp,
                fontfamily: FontFamily.interRegular,
                color: Colors.black87,
                maxline: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _archivedChatsRow() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 4.h,
      ),
      child: GestureDetector(
        onTap: () {
          Get.to(
                () => const ArchivedChatsScreen(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE9E7FF),
                ),
                child: Icon(
                  Icons.archive_outlined,
                  size: 21.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      "Archived",
                      fontsize: 13.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.black87,
                    ),

                    SizedBox(height: 2.h),

                    reausabletext(
                      "View archived conversations",
                      fontsize: 10.sp,
                      color: Colors.grey,
                      maxline: 1,
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 21.sp,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
