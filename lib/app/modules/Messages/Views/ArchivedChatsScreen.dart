import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import '../Controller/chat_list_controller.dart';
import '../Controller/MessageController.dart';
import '../widgets/custom_dropdown_menu.dart';
import 'Chat_Screen.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  static const String _imageBaseUrl = 'http://fgtracker.in:3000';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatListController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: Obx(
            () => _buildBody(controller),
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
                  "Archived Chats",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "Your hidden conversations",
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

  Widget _buildBody(ChatListController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(),
          SizedBox(height: 4.h),
          if (controller.archivedChats.isEmpty)
            _emptyArchivedChats()
          else
            _archivedChatsList(controller),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          reausabletext(
            "Archived",
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          SizedBox(width: 6.w),
          Transform.rotate(
            angle: 0.5,
            child: Icon(
              Icons.archive_rounded,
              size: 16.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _archivedChatsList(ChatListController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.archivedChats.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final chat = controller.archivedChats[index];
        final imageUrl = _getImageUrl(chat.image);

        Offset tapPosition = Offset.zero;

        return GestureDetector(
          onTapDown: (details) {
            tapPosition = details.globalPosition;
          },
          onTap: () {
            _openChat(chat);
          },
          onLongPress: () {
            _showArchivedChatOptions(
              context,
              tapPosition,
              chat,
              controller,
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE9E7FF),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? Center(
                    child: Icon(
                      Icons.person,
                      size: 24.sp,
                      color: const Color(0xFF6B4DFF),
                    ),
                  )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reausabletext(
                        chat.name ?? "Unknown User",
                        fontsize: 14.sp,
                        fontfamily: FontFamily.interBold,
                        color: Colors.black87,
                        maxline: 1,
                      ),
                      SizedBox(height: 4.h),
                      reausabletext(
                        _getMessagePreview(chat),
                        fontsize: 11.sp,
                        color: Colors.grey,
                        maxline: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.time?.isNotEmpty == true)
                      reausabletext(
                        _formatChatTime(chat.time!),
                        fontsize: 9.sp,
                        color: Colors.grey,
                        fontfamily: FontFamily.interMedium,
                      ),
                    SizedBox(height: 5.h),
                    Icon(
                      Icons.archive_rounded,
                      size: 18.sp,
                      color: const Color(0xFF6B4DFF),
                    ),
                    SizedBox(height: 5.h),
                    if (chat.unreadCount != null &&
                        chat.unreadCount! > 0)
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.w,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4DFF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: reausabletext(
                            "${chat.unreadCount}",
                            fontsize: 9.sp,
                            color: Colors.white,
                            fontfamily: FontFamily.interBold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMessagePreview(dynamic chat) {
    final message = chat.message?.toString().trim() ?? '';

    if (message.isNotEmpty) {
      switch (chat.messageType?.toString().toLowerCase()) {
        case 'image':
          return "📷 Photo";
        case 'video':
          return "🎥 Video";
        case 'audio':
          return "🎵 Audio";
        case 'document':
        case 'file':
          return "📄 Document";
        case 'location':
          return "📍 Location";
        default:
          return message;
      }
    }

    return "No messages yet";
  }

  String _formatChatTime(String value) {
    try {
      final dateTime = DateTime.parse(value).toLocal();
      final now = DateTime.now();

      final isToday =
          dateTime.year == now.year &&
              dateTime.month == now.month &&
              dateTime.day == now.day;

      if (isToday) {
        final hour = dateTime.hour % 12 == 0
            ? 12
            : dateTime.hour % 12;

        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = dateTime.hour >= 12 ? 'PM' : 'AM';

        return "$hour:$minute $period";
      }

      final yesterday = now.subtract(const Duration(days: 1));

      final isYesterday =
          dateTime.year == yesterday.year &&
              dateTime.month == yesterday.month &&
              dateTime.day == yesterday.day;

      if (isYesterday) {
        return "Yesterday";
      }

      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";
    } catch (_) {
      return '';
    }
  }

  void _openChat(dynamic chat) {
    if (chat.userId == null) {
      return;
    }

    Get.to(
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
  }

  void _showArchivedChatOptions(
      BuildContext context,
      Offset position,
      dynamic chat,
      ChatListController controller,
      ) {
    CustomDropdownMenu.show(
      context: context,
      position: position,
      width: 190,
      items: [
        DropdownMenuItemData(
          icon: Icons.unarchive_outlined,
          title: "Unarchive Chat",
          onTap: () {
            controller.unarchiveChat(chat);
            Get.back();
          },
        ),
      ],
    );
  }

  String _getImageUrl(String? image) {
    if (image == null || image.trim().isEmpty) {
      return '';
    }

    final value = image.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return '$_imageBaseUrl/${value.startsWith('/') ? value.substring(1) : value}';
  }

  Widget _emptyArchivedChats() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 42.h,
      ),
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
      child: Column(
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9E7FF),
            ),
            child: Center(
              child: Icon(
                Icons.archive_outlined,
                size: 34.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          reausabletext(
            "No Archived Chats",
            fontsize: 15.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),
          SizedBox(height: 6.h),
          Center(
            child: reausabletext(
              "Archived conversations will appear here.",
              fontsize: 11.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}