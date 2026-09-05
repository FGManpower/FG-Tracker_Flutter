import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../widgets/custom_dropdown_menu.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: const _AllChatsBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NewChatScreen()),
        backgroundColor: const Color(0xFF6B4DFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
          _circleIcon(Icons.arrow_back, () => Get.back()),
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
                  fontweight: FontWeight(400),
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
          _circleIcon(Icons.more_vert, () {}),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
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
          child: Icon(icon, size: 20.sp, color: Colors.black87),
        ),
      ),
    );
  }
}

class _AllChatsBody extends StatelessWidget {
  const _AllChatsBody();

  static final List<Map<String, dynamic>> _allChats = [
    {
      "name": "Priya Sharma",
      "role": "Event Management Team",
      "msg": "Checklist updated, please review.",
      "time": "10:10 AM",
      "unreadCount": 1,
      "statusColor": Colors.green,
      "isGroup": false,
    },
    {
      "name": "Construction Team",
      "role": "12 Members",
      "msg": "Arjun: Safety meeting at 4 PM today.",
      "time": "Yesterday",
      "unreadCount": 0,
      "statusColor": null,
      "isGroup": true,
    },
    {
      "name": "Rohit Verma",
      "role": "FG Manpower HR",
      "msg": "Please share the documents.",
      "time": "24 May",
      "unreadCount": 0,
      "statusColor": Colors.grey,
      "isGroup": false,
    },
    {
      "name": "Neha Verma",
      "role": "Construction Site Team",
      "msg": "Site visit completed.",
      "time": "23 May",
      "unreadCount": 2,
      "statusColor": Colors.orange,
      "isGroup": false,
    },
    {
      "name": "Pooja Mehta",
      "role": "Accounts Team",
      "msg": "Thanks for the update!",
      "time": "22 May",
      "unreadCount": 3,
      "statusColor": Colors.green,
      "isGroup": false,
    },
    {
      "name": "Event Crew",
      "role": "15 Members",
      "msg": "Riya: Final rehearsal at 6 PM.",
      "time": "22 May",
      "unreadCount": 3,
      "statusColor": null,
      "isGroup": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _sectionTitle("Status", showViewAll: true),
          _statusSection(context),
          SizedBox(height: 20.h),
          _sectionTitle("Pinned Chats 📌", badgeCount: 1),
          _chatTile(
            context: context,
            name: "Samad",
            role: "FG Manpower Development",
            msg: "Okay, I will be there at 10 AM.",
            time: "10:24 AM",
            unreadCount: 2,
            statusColor: Colors.green,
            isPinned: true,
          ),
          SizedBox(height: 10.h),
          _sectionTitle("All Chats", showDropdown: true),
          Container(
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
              itemCount: _allChats.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey.withValues(alpha: 0.12),
                height: 1,
                indent: 16.w,
                endIndent: 16.w,
              ),
              itemBuilder: (context, index) {
                final chat = _allChats[index];
                return _chatRow(
                  context: context,
                  name: chat['name'],
                  role: chat['role'],
                  msg: chat['msg'],
                  time: chat['time'],
                  unreadCount: chat['unreadCount'],
                  statusColor: chat['statusColor'],
                  isGroup: chat['isGroup'],
                );
              },
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    bool showViewAll = false,
    int? badgeCount,
    bool showDropdown = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          reausabletext(
            title,
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
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

  Widget _statusSection(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _myStatus(context),
          SizedBox(width: 16.w),
          _statusItem("Priya", "Online", Colors.green),
          _statusItem("Rohit", "Away", Colors.orange),
          _statusItem("Imran", "Offline", Colors.grey),
        ],
      ),
    );
  }

  Widget _myStatus(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        CustomDropdownMenu.show(
          context: context,
          position: Offset(
            details.globalPosition.dx,
            details.globalPosition.dy + 10,
          ),
          width: 200,
          items: [
            DropdownMenuItemData(
              icon: Icons.add_photo_alternate_outlined,
              title: "Add to My Status",
              onTap: () {},
            ),
            DropdownMenuItemData(
              icon: Icons.lock_outline,
              title: "Status Privacy",
              onTap: () {},
            ),
          ],
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6B4DFF), width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.white, size: 30.sp),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4DFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          reausabletext(
            "My Status",
            fontsize: 12.sp,
            fontfamily: FontFamily.interSemiBold,
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String name, String subStatus, Color ringColor) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.white, size: 30.sp),
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
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          reausabletext(
            name,
            fontsize: 12.sp,
            fontfamily: FontFamily.interSemiBold,
          ),
          reausabletext(subStatus, fontsize: 10.sp, color: Colors.grey),
        ],
      ),
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
  }) {
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) => tapPos = d.globalPosition,
      onLongPress: () => _showChatOptions(context, tapPos),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
  }) {
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) => tapPos = d.globalPosition,
      onLongPress: () => _showChatOptions(context, tapPos),
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: _chatRowContent(
          name: name,
          role: role,
          msg: msg,
          time: time,
          unreadCount: unreadCount,
          statusColor: statusColor,
          isGroup: isGroup,
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: isGroup
                  ? (name == "Event Crew"
                      ? const Color(0xFFFF6B8A)
                      : const Color(0xFF6B4DFF))
                  : Colors.grey.shade300,
              child: Icon(
                isGroup ? Icons.groups : Icons.person,
                color: Colors.white,
                size: isGroup ? 26.sp : 28.sp,
              ),
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
                name,
                fontsize: 14.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
                maxline: 1,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                role,
                fontsize: 11.sp,
                color: const Color(0xFF6B4DFF),
                maxline: 1,
              ),
              SizedBox(height: 3.h),
              reausabletext(
                msg,
                fontsize: 12.sp,
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
                      color: Colors.grey.shade500,
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

  void _showChatOptions(BuildContext context, Offset position) {
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
}
