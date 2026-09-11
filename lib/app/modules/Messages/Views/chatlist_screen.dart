import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Controller/chat_list_controller.dart';
import '../widgets/custom_dropdown_menu.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatListController controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: _AllChatsBody(controller: controller),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NewChatScreen()),
        backgroundColor: const Color(0xFF6B4DFF),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
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
                  color: Colors.grey.shade700,
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
            SizedBox(height: 8.h),

            // ================= STATUS =================

            _sectionTitle(
              "Status",
              showViewAll: true,
            ),

            _statusSection(),

            SizedBox(height: 20.h),

            // ================= PINNED CHATS =================

            Obx(() {
              final pinnedChats = controller.privateChats
                  .where((chat) => chat.isPinned == true)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    "Pinned Chats 📌",
                    badgeCount: pinnedChats.length,
                  ),
                  if (pinnedChats.isEmpty)
                    _emptySection("No pinned chats")
                  else
                    ...pinnedChats.map(
                      (chat) => _chatTile(
                        context: context,
                        name: chat.name ?? "Unknown User",
                        role: chat.role ?? "",
                        msg: chat.message ?? "",
                        time: chat.time ?? "",
                        unreadCount: chat.unreadCount ?? 0,
                        statusColor: _statusColor(chat.status),
                        isGroup: chat.isGroup ?? false,
                        isPinned: true,
                        image: chat.image,
                      ),
                    ),
                ],
              );
            }),

            SizedBox(height: 10.h),

            // ================= ALL CHATS =================

            _sectionTitle(
              "All Chats",
              showDropdown: true,
            ),

            Obx(() {
              if (controller.isLoading.value &&
                  controller.privateChats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
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
                      name: chat.name ?? "Unknown User",
                      role: chat.role ?? "",
                      msg: chat.message ?? "",
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

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _emptyChats() {
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

  Widget _emptySection(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 18.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: reausabletext(
            text,
            fontsize: 11.sp,
            color: Colors.grey.shade600,
          ),
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

  Widget _statusSection() {
    return SizedBox(
      height: 100.h,
      child: Obx(() {
        if (controller.privateChats.isEmpty) {
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            children: [
              _emptyStatus(),
            ],
          );
        }

        final chatsWithStatus = controller.privateChats.where((chat) {
          return (chat.status ?? "").isNotEmpty;
        }).toList();

        if (chatsWithStatus.isEmpty) {
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            children: [
              _emptyStatus(),
            ],
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          itemCount: chatsWithStatus.length,
          itemBuilder: (context, index) {
            final chat = chatsWithStatus[index];

            return Padding(
              padding: EdgeInsets.only(
                right: 16.w,
              ),
              child: _statusItem(
                chat.name ?? "User",
                chat.status ?? "Offline",
                _statusColor(chat.status) ?? Colors.grey,
                chat.image ?? "",
              ),
            );
          },
        );
      }),
    );
  }

  Widget _emptyStatus() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: reausabletext(
          "No status available",
          fontsize: 11.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _statusItem(
    String name,
    String subStatus,
    Color ringColor,
    String imageUrl,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 26.sp,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: ringColor,
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
        SizedBox(height: 6.h),
        reausabletext(
          name.isEmpty ? "User" : name,
          fontsize: 12.sp,
          fontfamily: FontFamily.interSemiBold,
        ),
        reausabletext(
          subStatus.isEmpty ? "Offline" : subStatus,
          fontsize: 10.sp,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _chatTile({
    required BuildContext context,
    required String name,
    required String role,
    required String msg,
    required String time,
    int unreadCount = 0,
    Color? statusColor,
    bool isGroup = false,
    bool isPinned = false,
    String? image,
  }) {
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) {
        tapPos = d.globalPosition;
      },
      onLongPress: () => _showChatOptions(context, tapPos),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 6.h,
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.03,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _chatRowContent(
          name: name,
          role: role,
          msg: msg,
          time: time,
          unreadCount: unreadCount,
          statusColor: statusColor,
          isGroup: isGroup,
          isPinned: isPinned,
          image: image,
        ),
      ),
    );
  }

  Widget _chatRow({
    required BuildContext context,
    required String name,
    required String role,
    required String msg,
    required String time,
    int unreadCount = 0,
    Color? statusColor,
    bool isGroup = false,
    String? image,
  }) {
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) {
        tapPos = d.globalPosition;
      },
      onLongPress: () => _showChatOptions(context, tapPos),
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
    String? image,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor:
                  isGroup ? const Color(0xFF6B4DFF) : Colors.grey.shade300,
              backgroundImage: (!isGroup && image != null && image.isNotEmpty)
                  ? NetworkImage(image)
                  : null,
              child: isGroup
                  ? Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 26.sp,
                    )
                  : (image == null || image.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28.sp,
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
              reausabletext(
                name.isEmpty ? "Unknown User" : name,
                fontsize: 14.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
                maxline: 1,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                role,
                fontsize: 11.sp,
                fontweight: const FontWeight(500),
                color: Colors.grey.shade700,
                maxline: 1,
              ),
              SizedBox(height: 3.h),
              reausabletext(
                msg,
                fontsize: 11.sp,
                color: Colors.grey.shade600,
                maxline: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 85.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 48.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      time,
                      fontsize: 11.sp,
                      color: Colors.grey.shade700,
                      maxline: 1,
                    ),
                    SizedBox(height: 7.h),
                    if (unreadCount > 0)
                      Container(
                        width: 22.w,
                        height: 22.w,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B4DFF),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontFamily: FontFamily.interSemiBold,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 22.w,
                        height: 22.w,
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 20.w,
                child: Center(
                  child: Icon(
                    isPinned
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChatOptions(
    BuildContext context,
    Offset position,
  ) {
    CustomDropdownMenu.show(
      context: context,
      position: position,
      width: 210,
      items: [
        DropdownMenuItemData(
          icon: Icons.push_pin_outlined,
          title: "Pin Chat",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.notifications_off_outlined,
          title: "Mute Notifications",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.mark_email_unread_outlined,
          title: "Mark as Unread",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.person_outline,
          title: "View Contact",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.visibility_off_outlined,
          title: "Hide Chat",
          onTap: () {},
        ),
        DropdownMenuItemData(
          icon: Icons.delete_outline,
          title: "Delete Chat",
          isDestructive: true,
          onTap: () {},
        ),
      ],
    );
  }

  Color? _statusColor(String? status) {
    final value = (status ?? "").toLowerCase().trim();

    if (value == "online" || value == "active" || value == "available") {
      return Colors.green;
    }

    if (value == "away" || value == "busy") {
      return Colors.orange;
    }

    if (value == "offline" || value == "inactive") {
      return Colors.grey;
    }

    if (value == "dnd" ||
        value == "do_not_disturb" ||
        value == "do not disturb") {
      return Colors.red;
    }

    return null;
  }

  String _formatChatTime(String value) {
    if (value.isEmpty) {
      return "";
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    final local = parsed.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) {
      return "Just now";
    }

    if (difference.inHours < 1) {
      return "${difference.inMinutes} min";
    }

    if (difference.inDays == 0) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

      final minute = local.minute.toString().padLeft(2, '0');

      final period = local.hour >= 12 ? "PM" : "AM";

      return "$hour:$minute $period";
    }

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      return "${difference.inDays} days";
    }

    return "${local.day}/${local.month}/${local.year}";
  }
}
