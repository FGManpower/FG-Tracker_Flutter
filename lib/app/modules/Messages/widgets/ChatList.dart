import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../Controller/MessageController.dart';
import 'ChatItem.dart';

class ChatList extends StatelessWidget {
  final MessageController controller;

  const ChatList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingInitialMessages.value;

      return StreamBuilder<List<MessageData>>(
        stream: controller.messageStream,
        initialData: controller.messageData,
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];

          // -----------------------------------------
          // 1. API LOADING
          // -----------------------------------------
          if (isLoading && messages.isEmpty) {
            return const ChatMessageSkeleton();
          }

          // -----------------------------------------
          // 2. API LOADED + NO MESSAGES
          // -----------------------------------------
          if (!isLoading && messages.isEmpty) {
            return _buildEmptyState();
          }

          // -----------------------------------------
          // 3. ACTUAL MESSAGES
          // -----------------------------------------
          return ScrollablePositionedList.builder(
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];

              return Dismissible(
                key: ValueKey(msg.id),
                direction: DismissDirection.startToEnd,
                dismissThresholds: const {
                  DismissDirection.startToEnd: 0.25,
                },
                confirmDismiss: (_) async {
                  HapticFeedback.lightImpact();
                  controller.setReply(msg);
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.w),
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.reply,
                    color: Colors.green,
                  ),
                ),
                child: ChatBubble(
                  controller: controller,
                  message: msg,
                  context: context,
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "💬",
            style: TextStyle(fontSize: 48.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            "No messages here yet",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Say hi 👋 to start the conversation",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageSkeleton extends StatefulWidget {
  const ChatMessageSkeleton({super.key});

  @override
  State<ChatMessageSkeleton> createState() => _ChatMessageSkeletonState();
}

class _ChatMessageSkeletonState extends State<ChatMessageSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        // Subtle brightness change.
        // Not too shiny, but clearly visible.
        final shimmerColor = Color.lerp(
          const Color(0xFFD8D5E0),
          const Color(0xFFE8E5ED),
          value,
        )!;

        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          children: [
            _bubble(
              alignment: Alignment.centerLeft,
              width: 185.w,
              height: 48.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerRight,
              width: 145.w,
              height: 38.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerLeft,
              width: 225.w,
              height: 58.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerRight,
              width: 180.w,
              height: 46.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerLeft,
              width: 155.w,
              height: 38.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerRight,
              width: 210.w,
              height: 55.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerLeft,
              width: 195.w,
              height: 46.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerRight,
              width: 160.w,
              height: 40.h,
              color: shimmerColor,
            ),
            _bubble(
              alignment: Alignment.centerLeft,
              width: 235.w,
              height: 62.h,
              color: shimmerColor,
            ),
          ],
        );
      },
    );
  }

  Widget _bubble({
    required Alignment alignment,
    required double width,
    required double height,
    required Color color,
  }) {
    final isRight = alignment == Alignment.centerRight;

    return Align(
      alignment: alignment,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(
          vertical: 5.h,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(
              isRight ? 16.r : 4.r,
            ),
            bottomRight: Radius.circular(
              isRight ? 4.r : 16.r,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupChatList extends StatelessWidget {
  final GroupMessageController controller;

  const GroupChatList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageData>>(
      stream: controller.messageStream,
      initialData: controller.messageData,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "💬",
                  style: TextStyle(fontSize: 48.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  "No messages here yet",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Say hi 👋 to start the conversation",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return ScrollablePositionedList.builder(
          itemScrollController: controller.itemScrollController,
          itemPositionsListener: controller.itemPositionsListener,
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 8.h,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];

            return Dismissible(
              key: ValueKey(msg.id),
              direction: DismissDirection.startToEnd,
              confirmDismiss: (_) async {
                HapticFeedback.lightImpact();
                controller.setReply(msg);
                return false;
              },
              background: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20.w),
                color: Colors.transparent,
                child: Icon(
                  Icons.reply,
                  color: Colors.deepPurple,
                  size: 24.sp,
                ),
              ),
              child: GroupChatBubble(
                controller: controller,
                message: msg,
                context: context,
                isGroup: true,
                groupId: controller.groupId,
                groupName: controller.groupName,
              ),
            );
          },
        );
      },
    );
  }
}
