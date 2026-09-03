import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

        // 🟢 Check if messages list is empty
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