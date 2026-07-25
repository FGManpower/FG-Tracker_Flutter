import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../global_widget/common_widget.dart';
import '../Controller/MessageController.dart';
import 'ChatItem.dart';

class ChatList extends StatelessWidget {
  final MessageController controller;
  final ScrollController scrollController;

  const ChatList({
    Key? key,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? lastDateHeader;

    return Obx(() => ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: controller.messageData.length,
      itemBuilder: (context, index) {
        final msg = controller.messageData[index];
        final messageDate = formatDateHeader(msg.timestamp ?? "");

        bool showHeader = false;
        if (lastDateHeader != messageDate) {
          lastDateHeader = messageDate;
          showHeader = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showHeader) _buildDateHeader(messageDate),
            Dismissible(
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
              child: KeyedSubtree(
                key: controller.messageKeys.putIfAbsent(
                  msg.id!,
                      () => GlobalKey(),
                ),
                child: ChatBubble(
                  controller: controller,
                  message: msg,
                  context: context,
                ),
              ),
            ),
          ],
        );
      },
    ));
  }


  Widget _buildDateHeader(String messageDate) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: reausabletext(
            messageDate,
            fontsize: 10.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}


class GroupChatList extends StatelessWidget {
  final GroupMessageController controller;
  final ScrollController scrollController;

  const GroupChatList({
    Key? key,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? lastDateHeader;

    return Obx(() => ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: controller.messageData.length,
      itemBuilder: (context, index) {
        final msg = controller.messageData[index];
        final messageDate = formatDateHeader(msg.timestamp ?? "");

        bool showHeader = false;
        if (lastDateHeader != messageDate) {
          lastDateHeader = messageDate;
          showHeader = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showHeader) _buildDateHeader(messageDate),
            Dismissible(
              key: ValueKey(msg.id),
              direction: DismissDirection.startToEnd,
              confirmDismiss: (_) async {
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
              child: KeyedSubtree(
                key: controller.messageKeys.putIfAbsent(
                  msg.id ?? -(index + 1),
                  () => GlobalKey(),
                ),
                child: GroupChatBubble(
                  controller: controller,
                  message: msg,
                  context: context,
                  isGroup: true,
                  groupId: int.parse(controller.groupId.toString()),
                  groupName: controller.groupName,
                ),
              ),
            ),
          ],
        );
      },
    ));
  }


  Widget _buildDateHeader(String messageDate) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: reausabletext(
            messageDate,
            fontsize: 10.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}