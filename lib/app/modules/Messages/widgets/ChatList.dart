import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../Controller/MessageController.dart';
import 'ChatItem.dart';

class ChatList extends StatelessWidget {
  final MessageController controller;

  const ChatList({
    super.key,
    required this.controller,
  });

  bool _isDeleted(MessageData msg) =>
      msg.isDeleted == true ||
      msg.content?.toString() == "This message was deleted";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingInitialMessages.value;

      return StreamBuilder<List<MessageData>>(
        stream: controller.messageStream,
        initialData: controller.messageData,
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          debugPrint(
            "CHAT LIST => chatId: ${controller.privateChatId.value}, "
            "messages: ${messages.length}, "
            "loading: ${controller.isLoadingInitialMessages.value}",
          );
          if (isLoading && messages.isEmpty) {
            return const ChatMessageSkeleton();
          }

          if (!isLoading && messages.isEmpty) {
            return _buildEmptyState();
          }

          return ScrollablePositionedList.builder(
            key: ValueKey("chat_list_${controller.privateChatId.value}"),
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            initialScrollIndex: messages.isNotEmpty ? messages.length - 1 : 0,
            initialAlignment: 0.0,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final prevMsg = index > 0 ? messages[index - 1] : null;
              final nextMsg =
                  index < messages.length - 1 ? messages[index + 1] : null;

              // WhatsApp Consecutive Clustering
              bool isSameSenderAsPrev = false;
              if (prevMsg != null &&
                  prevMsg.senderId != null &&
                  msg.senderId != null) {
                if (prevMsg.senderId.toString() == msg.senderId.toString()) {
                  final t1 =
                      DateTime.tryParse(prevMsg.timestamp?.toString() ?? '');
                  final t2 = DateTime.tryParse(msg.timestamp?.toString() ?? '');
                  if (t1 != null &&
                      t2 != null &&
                      t2.difference(t1).abs().inSeconds <= 60) {
                    isSameSenderAsPrev = true;
                  }
                }
              }

              bool isSameSenderAsNext = false;
              if (nextMsg != null &&
                  nextMsg.senderId != null &&
                  msg.senderId != null) {
                if (nextMsg.senderId.toString() == msg.senderId.toString()) {
                  final t1 = DateTime.tryParse(msg.timestamp?.toString() ?? '');
                  final t2 =
                      DateTime.tryParse(nextMsg.timestamp?.toString() ?? '');
                  if (t1 != null &&
                      t2 != null &&
                      t2.difference(t1).abs().inSeconds <= 60) {
                    isSameSenderAsNext = true;
                  }
                }
              }

              // WhatsApp Inline Date Header Separator
              bool showDateHeader = false;
              String? dateHeaderText;
              if (msg.timestamp != null &&
                  msg.timestamp.toString().trim().isNotEmpty) {
                try {
                  final currentDateStr =
                      formatDateHeader(msg.timestamp.toString());
                  if (index == 0) {
                    showDateHeader = true;
                    dateHeaderText = currentDateStr;
                  } else if (prevMsg?.timestamp != null &&
                      prevMsg!.timestamp.toString().trim().isNotEmpty) {
                    final prevDateStr =
                        formatDateHeader(prevMsg.timestamp.toString());
                    if (currentDateStr != prevDateStr) {
                      showDateHeader = true;
                      dateHeaderText = currentDateStr;
                    }
                  }
                } catch (_) {}
              }

              final bubble = RepaintBoundary(
                child: ChatBubble(
                  controller: controller,
                  message: msg,
                  context: context,
                  showAvatar: !isSameSenderAsNext,
                  isDense: isSameSenderAsPrev,
                ),
              );

              Widget itemWidget;
              if (_isDeleted(msg)) {
                itemWidget = bubble;
              } else {
                itemWidget = Dismissible(
                  key: ValueKey(msg.id ?? index),
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
                  child: bubble,
                );
              }

              if (showDateHeader && dateHeaderText != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          dateHeaderText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    itemWidget,
                  ],
                );
              }

              return itemWidget;
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
      duration: const Duration(milliseconds: 1300),
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
        final double value = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + 4.0 * value, -0.3),
              end: Alignment(-0.5 + 4.0 * value, 0.3),
              colors: const [
                Color(0xFFE6E3ED),
                Color(0xFFFBFBFE),
                Color(0xFFE6E3ED),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            children: [
              // Date Header Pill
              Center(
                child: Container(
                  width: 72.w,
                  height: 22.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E1EC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),

              // 1. Incoming Message with Avatar
              _incomingBubble(
                width: 220.w,
                lines: [190.w, 130.w],
              ),

              // 2. Outgoing Message
              _outgoingBubble(
                width: 170.w,
                lines: [140.w],
              ),

              // 3. Incoming Media Card (Photo/Video skeleton)
              _incomingMediaBubble(
                width: 210.w,
                height: 130.h,
              ),

              // 4. Outgoing Message (2 lines)
              _outgoingBubble(
                width: 230.w,
                lines: [200.w, 110.w],
              ),

              // 5. Incoming Audio / Voice Message
              _incomingAudioBubble(
                width: 200.w,
              ),

              // 6. Incoming Short Message
              _incomingBubble(
                width: 140.w,
                lines: [110.w],
              ),

              // 7. Outgoing Short Message
              _outgoingBubble(
                width: 130.w,
                lines: [95.w],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _incomingBubble({
    required double width,
    required List<double> lines,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            margin: EdgeInsets.only(right: 8.w, bottom: 2.h),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4E1EC),
            ),
          ),
          Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final line in lines) ...[
                  Container(
                    width: line,
                    height: 10.h,
                    margin: EdgeInsets.only(bottom: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E1EC),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 32.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E1EC),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _outgoingBubble({
    required double width,
    required List<double> lines,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEAE6F8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(4.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in lines) ...[
                Container(
                  width: line,
                  height: 10.h,
                  margin: EdgeInsets.only(bottom: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD7EB),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCD7EB),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 12.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCD7EB),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _incomingMediaBubble({
    required double width,
    required double height,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            margin: EdgeInsets.only(right: 8.w, bottom: 2.h),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4E1EC),
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(6.r),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E1EC),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomingAudioBubble({
    required double width,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            margin: EdgeInsets.only(right: 8.w, bottom: 2.h),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4E1EC),
            ),
          ),
          Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE4E1EC),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E1EC),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 40.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E1EC),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  bool _isDeleted(MessageData msg) =>
      msg.isDeleted == true ||
      msg.content?.toString() == "This message was deleted";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return StreamBuilder<List<MessageData>>(
        stream: controller.messageStream,
        initialData: controller.messageData,
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];

          if (isLoading && messages.isEmpty) {
            return const ChatMessageSkeleton();
          }

          if (!isLoading && messages.isEmpty) {
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
            key: ValueKey("group_chat_list_${controller.groupId}"),
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            initialScrollIndex: messages.isNotEmpty ? messages.length - 1 : 0,
            initialAlignment: 0.0,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final prevMsg = index > 0 ? messages[index - 1] : null;
              final nextMsg =
                  index < messages.length - 1 ? messages[index + 1] : null;

              // WhatsApp Consecutive Clustering for Group Chat
              bool isSameSenderAsPrev = false;
              if (prevMsg != null &&
                  prevMsg.senderId != null &&
                  msg.senderId != null) {
                if (prevMsg.senderId.toString() == msg.senderId.toString()) {
                  final t1 =
                      DateTime.tryParse(prevMsg.timestamp?.toString() ?? '');
                  final t2 = DateTime.tryParse(msg.timestamp?.toString() ?? '');
                  if (t1 != null &&
                      t2 != null &&
                      t2.difference(t1).abs().inSeconds <= 60) {
                    isSameSenderAsPrev = true;
                  }
                }
              }

              bool isSameSenderAsNext = false;
              if (nextMsg != null &&
                  nextMsg.senderId != null &&
                  msg.senderId != null) {
                if (nextMsg.senderId.toString() == msg.senderId.toString()) {
                  final t1 = DateTime.tryParse(msg.timestamp?.toString() ?? '');
                  final t2 =
                      DateTime.tryParse(nextMsg.timestamp?.toString() ?? '');
                  if (t1 != null &&
                      t2 != null &&
                      t2.difference(t1).abs().inSeconds <= 60) {
                    isSameSenderAsNext = true;
                  }
                }
              }

              // WhatsApp Inline Date Header Separator
              bool showDateHeader = false;
              String? dateHeaderText;
              if (msg.timestamp != null &&
                  msg.timestamp.toString().trim().isNotEmpty) {
                try {
                  final currentDateStr =
                      formatDateHeader(msg.timestamp.toString());
                  if (index == 0) {
                    showDateHeader = true;
                    dateHeaderText = currentDateStr;
                  } else if (prevMsg?.timestamp != null &&
                      prevMsg!.timestamp.toString().trim().isNotEmpty) {
                    final prevDateStr =
                        formatDateHeader(prevMsg.timestamp.toString());
                    if (currentDateStr != prevDateStr) {
                      showDateHeader = true;
                      dateHeaderText = currentDateStr;
                    }
                  }
                } catch (_) {}
              }

              final bubble = RepaintBoundary(
                child: GroupChatBubble(
                  controller: controller,
                  message: msg,
                  context: context,
                  isGroup: true,
                  groupId: controller.groupId,
                  groupName: controller.groupName.toString(),
                  showSenderName: !isSameSenderAsPrev,
                  showAvatar: !isSameSenderAsNext,
                  isDense: isSameSenderAsPrev,
                ),
              );

              Widget itemWidget;
              if (_isDeleted(msg)) {
                itemWidget = bubble;
              } else {
                itemWidget = Dismissible(
                  key: ValueKey(msg.id ?? index),
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
                  child: bubble,
                );
              }

              if (showDateHeader && dateHeaderText != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          dateHeaderText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    itemWidget,
                  ],
                );
              }

              return itemWidget;
            },
          );
        },
      );
    });
  }
}
