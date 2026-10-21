import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/status/views/status_section.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/util/chatutil.dart';
import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../routes/app_pages.dart';
import '../../home/Controller/total_group_controller.dart';
import '../Controller/MessageController.dart';
import '../Controller/chat_list_controller.dart';
import '../widgets/custom_dropdown_menu.dart';
import '../widgets/custom_dropdown_menu.dart' as CustomDropdownMenu;
import 'ArchivedChatsScreen.dart';
import 'Chat_Screen.dart';
import 'new_chat_screen.dart';

import 'package:fgtracker/app/Core/values/colorPool.dart';
import 'package:fgtracker/app/Model/GroupChatListModel.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatListController controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    // Single Unified WhatsApp Chat List Screen:
    // TabBar and legacy separate Groups Tab are commented out as requested.
    // Both 1-to-1 chats and group chats are now presented in a single unified list.
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NewChatScreen()),
        backgroundColor: const Color(0xFF6B4DFF),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: const QuickCommunicationBar(),
      body: _AllChatsBody(controller: controller),
      /*
      // LEGACY TAB BAR UI (Commented out):
      // body: Column(
      //   children: [
      //     _buildCustomTabBar(),
      //     Expanded(
      //       child: TabBarView(
      //         children: [
      //           _AllChatsBody(controller: controller),
      //           const _GroupsTabBody(),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      */
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
        ],
      ),
    );
  }

  /*
  // LEGACY TAB BAR UI (Commented out):
  Widget _buildCustomTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: const Color(0xFF6B4DFF),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black87,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontFamily: FontFamily.interSemiBold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, size: 18.sp),
                SizedBox(width: 8.w),
                const Text("All Chats"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_alt_rounded, size: 18.sp),
                SizedBox(width: 8.w),
                const Text("Groups"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _circleIcon(IconData icon, VoidCallback onTap) {
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
              color: Colors.black.withOpacity(0.04),
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

class QuickCommunicationBar extends StatefulWidget {
  const QuickCommunicationBar({Key? key}) : super(key: key);

  @override
  State<QuickCommunicationBar> createState() => _QuickCommunicationBarState();
}

class _QuickCommunicationBarState extends State<QuickCommunicationBar> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          "Quick Communication",
                          fontsize: 13.sp,
                          fontfamily: FontFamily.interBold,
                          color: const Color(0xFF1B1B50),
                        ),
                        SizedBox(height: 2.h),
                        reausabletext(
                          "Connect with your team instantly",
                          fontsize: 10.sp,
                          color: const Color(0xFF6B4DFF),
                          fontweight: FontWeight.w500,
                        ),
                      ],
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      color: const Color(0xFF6B4DFF),
                      size: 28.sp,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding:
                          EdgeInsets.only(left: 8.w, right: 8.w, bottom: 15.h),
                      child: Row(
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
                    )
                  : SizedBox(width: double.infinity, height: 0.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickCommCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
            horizontal: 2.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE9E7FF),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4DFF).withOpacity(0.12),
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
                  color: const Color(0xFF6B4DFF).withOpacity(0.58),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusSection(),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF6B4DFF),
            onRefresh: controller.refreshChats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => controller.archivedChats.isNotEmpty
                        ? _archivedChatsRow()
                        : const SizedBox.shrink(),
                  ),
                  // Search Bar for Unified WhatsApp Chats
                  Container(
                    height: 44.h,
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.12),
                      ),
                    ),
                    child: Obx(
                      () => TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search chats or messages...",
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                            fontFamily: FontFamily.interRegular,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: controller.clearSearch,
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => _sectionTitle(
                      "All Chats",
                      badgeCount: controller.unreadTotalCount.value > 0
                          ? controller.unreadTotalCount.value
                          : null,
                    ),
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
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
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
                          color: Colors.grey.withOpacity(0.12),
                          height: 1,
                          indent: 16.w,
                          endIndent: 16.w,
                        ),
                        itemBuilder: (context, index) {
                          final chat = controller.privateChats[index];

                          return _chatRow(
                            context: context,
                            chat: chat,
                            name: chat.name ?? chat.groupName ?? "Unknown User",
                            role: chat.role ?? "",
                            msg: chat.preview ??
                                ChatUtil.formatLastMessage(chat.message),
                            time: _formatChatTime(
                              chat.timestamp ?? chat.time ?? "",
                            ),
                            unreadCount: chat.unreadCount ?? 0,
                            statusColor: chat.isGroup == true
                                ? null
                                : (chat.isOnline == true
                                    ? const Color(0xFF16A765)
                                    : Colors.grey),
                            isGroup: chat.isGroup ?? false,
                            image: chat.image,
                          );
                        },
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
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
              color: Colors.black.withOpacity(0.03),
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
            color: Colors.grey.withOpacity(0.12),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 35.h),
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
    final bool isPinned = title == "Pinned Chats 📌";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    Offset tapPos = Offset.zero;

    return GestureDetector(
      onTapDown: (d) {
        tapPos = d.globalPosition;
      },
      onTap: () async {
        if (chat.isGroup == true) {
          final effectiveGroupId =
              chat.groupId?.toString() ?? chat.id?.toString() ?? '';
          if (effectiveGroupId.isEmpty) return;

          if (Get.isRegistered<ChatListController>()) {
            Get.find<ChatListController>().markChatAsRead(chat);
          }

          String groupCode = '';
          String isCreator = 'false';
          String isActive = 'true';
          String profileImg = chat.image ?? '';

          if (Get.isRegistered<GroupController>()) {
            final gc = Get.find<GroupController>();
            final matched = gc.groupData.firstWhereOrNull(
              (g) => g.id == (chat.groupId ?? chat.id),
            );
            if (matched != null) {
              groupCode = matched.groupCode ?? '';
              isCreator = (matched.isCreator ?? false).toString();
              isActive = (matched.isActive ?? true).toString();
              if (profileImg.isEmpty && matched.groupProfile != null) {
                profileImg = matched.groupProfile!;
              }
            }
          }

          await Get.toNamed(
            Routes.groupChatScreen,
            arguments: {
              "groupId": effectiveGroupId,
              "groupName": chat.name ?? chat.groupName ?? "Group Chat",
              "groupProfile": profileImg,
              "groupImage": profileImg,
              "groupCode": groupCode,
              "isCreator": isCreator,
              "isActive": isActive,
            },
          )?.then((_) {
            controller.getChatList(isRefresh: false);
          });
          return;
        }

        if (chat.userId == null && chat.id == null) {
          return;
        }

        if (Get.isRegistered<ChatListController>()) {
          Get.find<ChatListController>().markChatAsRead(chat);
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
            "chatId":
                (chat.chatId ?? chat.conversationId ?? chat.id)?.toString(),
          },
          binding: BindingsBuilder(() {
            Get.put(MessageController());
          }),
        )?.then((_) {
          controller.getChatList(isRefresh: false);
        });
      },
      onLongPress: () => _showChatOptions(context, tapPos, chat),
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
          isPinned: chat.isPinned == true,
          isMuted: chat.isMuted == true,
          isDeletedForEveryone: chat.isDeletedForEveryone == true,
          isBlocked: chat.isBlocked == true,
          isForwarded: chat.isForwarded == true,
          forwardedLabel: chat.forwardedLabel ?? "Forwarded",
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
    bool isDeletedForEveryone = false,
    bool isBlocked = false,
    bool isForwarded = false,
    String forwardedLabel = "Forwarded",
    String? image,
  }) {
    final bool isDeleted = isDeletedForEveryone ||
        msg == "This message was deleted" ||
        msg == "Message deleted";

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
              backgroundImage: (image != null && image.isNotEmpty)
                  ? NetworkImage(
                      image.startsWith("http://") ||
                              image.startsWith("https://")
                          ? image
                          : "${ConstRes.aImageBaseUrl}$image",
                    )
                  : null,
              child: (image != null && image.isNotEmpty)
                  ? null
                  : (isGroup
                      ? Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 24.sp,
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26.sp,
                        )),
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
                      name.isEmpty ? "Unknown" : name,
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
              if (isDeleted)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block_flipped,
                      size: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        "This message was deleted",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    if (isBlocked) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        margin: EdgeInsets.only(right: 5.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Blocked",
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (isForwarded) ...[
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159),
                        child: Icon(
                          Icons.reply_rounded,
                          size: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "${forwardedLabel.isNotEmpty ? forwardedLabel : 'Forwarded'}: ",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interMedium,
                        ),
                      ),
                    ],
                    Flexible(
                      child: reausabletext(
                        msg.isEmpty ? "" : msg,
                        fontsize: 10.sp,
                        fontfamily: FontFamily.interMedium,
                        color: const Color(0xFF6B4DFF),
                        maxline: 1,
                      ),
                    ),
                  ],
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
            CommonDialog.ConfirmationDialog(
              title: "Delete Chat",
              content: "Delete this conversation from your chat list?",
              cancel: "No",
              confirm: "Delete",
              icon: Icons.delete_outline_rounded,
              onConfirm: () {
                Get.back();
                controller.deleteChat(chat);
              },
            );
          },
        ),
      ],
    );
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
              titlePadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 4.h),
              contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 2.h),
              actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 6.h),
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
                    onChanged: (value) =>
                        setState(() => selectedOption = value),
                  ),
                  _muteDialogOption(
                    title: "8 hours",
                    value: "8_hours",
                    groupValue: selectedOption,
                    onChanged: (value) =>
                        setState(() => selectedOption = value),
                  ),
                  _muteDialogOption(
                    title: "Until tomorrow",
                    value: "until_tomorrow",
                    groupValue: selectedOption,
                    onChanged: (value) =>
                        setState(() => selectedOption = value),
                  ),
                  _muteDialogOption(
                    title: "Until I turn it back on",
                    value: "always",
                    groupValue: selectedOption,
                    onChanged: (value) =>
                        setState(() => selectedOption = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
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
                      final tomorrow =
                          DateTime.now().add(const Duration(days: 1));
                      mutedUntil = DateTime(
                              tomorrow.year, tomorrow.month, tomorrow.day, 8, 0)
                          .toIso8601String();
                    } else {
                      mutedUntil = null;
                    }
                    Navigator.pop(dialogContext);
                    controller.muteChat(chat, mutedUntil: mutedUntil);
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
      onTap: () => onChanged(value),
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
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 4.h),
      child: GestureDetector(
        onTap: () => Get.to(() => const ArchivedChatsScreen()),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
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

/*
// LEGACY GROUPS TAB BODY (Commented out - Groups are merged into the unified WhatsApp chat list):
// Previously called TotalGroupController().getGroupChatList()
class _GroupsTabBody extends StatelessWidget {
  const _GroupsTabBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TotalGroupController());

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 10.h,
      ),
      child: Column(
        children: [
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.12),
              ),
            ),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: "Search groups...",
                  hintStyle: TextStyle(
                    fontSize: 13.5.sp,
                    color: Colors.grey.shade400,
                    fontFamily: FontFamily.interRegular,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20.sp,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixIcon: controller.searchText.value.isNotEmpty
                      ? GestureDetector(
                          onTap: controller.clearSearch,
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: Colors.grey.shade400,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.groupList.isEmpty) {
                return _buildGroupList(
                  controller: controller,
                  isLoading: true,
                );
              }

              if (controller.hasError.value && controller.groupList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 45.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        controller.errorMessage.value.isNotEmpty
                            ? controller.errorMessage.value
                            : "Something went wrong",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: controller.refreshGroups,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final groups = controller.filteredGroupList;

              if (groups.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refreshGroups,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 250.h,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.searchText.value.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.groups_outlined,
                                size: 45.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                controller.searchText.value.isNotEmpty
                                    ? "No groups found"
                                    : "No groups available",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: FontFamily.interRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshGroups,
                child: _buildGroupList(
                  controller: controller,
                  data: groups,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList({
    required TotalGroupController controller,
    List<GroupChatData>? data,
    bool isLoading = false,
  }) {
    final List<GroupChatData>? items = isLoading ? null : data;

    final int itemCount = items?.length ?? 6;

    return Skeletonizer(
      enabled: items == null,
      child: ListView.separated(
        controller: controller.scrollController,
        padding: EdgeInsets.only(bottom: 20.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemBuilder: (context, index) {
          if (items == null) {
            return const _GroupCardSkeleton();
          }

          return apiGroupCard(
            items[index],
            index,
            controller,
          );
        },
      ),
    );
  }

  Widget apiGroupCard(
    GroupChatData group,
    int index,
    TotalGroupController controller,
  ) {
    final colors = colorPool[index % colorPool.length];

    final String groupName = controller.getGroupName(group);
    final String description = controller.getGroupDescription(group);
    final int memberCount = controller.getMemberCount(group);
    final int unreadCount = controller.getUnreadCount(group);
    final String groupDate = controller.getGroupDate(group);

    return Padding(
      padding: EdgeInsets.only(bottom: 0.h),
      child: InkWell(
        onTap: () {
          final gId = group.groupId?.toString() ?? '';
          if (gId.isEmpty) return;

          String groupCode = '';
          String isCreator = 'false';
          String isActive = 'true';
          String profileImg = group.groupProfile ?? '';

          if (Get.isRegistered<GroupController>()) {
            final gc = Get.find<GroupController>();
            final matched = gc.groupData.firstWhereOrNull(
              (g) => g.id == group.groupId,
            );
            if (matched != null) {
              groupCode = matched.groupCode ?? '';
              isCreator = (matched.isCreator ?? false).toString();
              isActive = (matched.isActive ?? true).toString();
              if (profileImg.isEmpty && matched.groupProfile != null) {
                profileImg = matched.groupProfile!;
              }
            }
          }

          Get.toNamed(
            Routes.groupChatScreen,
            arguments: {
              "groupId": gId,
              "groupName": groupName,
              "groupProfile": profileImg,
              "groupImage": profileImg,
              "groupCode": groupCode,
              "isCreator": isCreator,
              "isActive": isActive,
            },
          )?.then((_) {
            controller.getGroupChatList(refresh: true);
          });
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colors['bg'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: colors['icon'],
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      "$memberCount Members",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B4DFF),
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (groupDate.isNotEmpty)
                    Text(
                      groupDate,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: Colors.grey.shade500,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (unreadCount > 0)
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 20.w,
                            minHeight: 20.w,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B4DFF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? "99+" : unreadCount.toString(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (unreadCount > 0) SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCardSkeleton extends StatelessWidget {
  const _GroupCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Group Name Placeholder",
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "12 Members",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Last message placeholder",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Yesterday",
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
