import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../Controller/MessageController.dart';
import '../Controller/chat_screen_logic.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Services/chat_translation_service.dart';
import 'ChatItem.dart';
import 'chat_history_widgets.dart';

/// Text a left swipe translates: a received text message, or a received
/// media message's caption. Empty = no translate swipe for this message.
String _swipeTranslatableText(MessageData msg) {
  final me = Global.storageServices.get(PrefConst.userId)?.toString();
  if (msg.senderId?.toString() == me) return '';
  if (msg.isDeleted == true) return '';
  if (ChatScreenRules.isText(msg.messageType)) {
    return (msg.content?.toString() ?? '').trim();
  }
  return (msg.caption?.toString() ?? '').trim();
}

/// Same id the bubble uses for its translation card.
String _translationId(MessageData msg, String text) {
  final id = msg.id?.toString() ?? '';
  if (id.isNotEmpty && id != '0' && id != 'null') return id;
  return "msg_${text.hashCode}";
}

/// Swipe right = reply (unchanged). Swipe left on a received message =
/// translate / show original, on Android and iOS.
Future<bool> _onMessageSwipe(
  DismissDirection direction,
  MessageData msg,
  void Function(MessageData) setReply,
) async {
  HapticFeedback.lightImpact();
  if (direction == DismissDirection.startToEnd) {
    setReply(msg);
  } else {
    final text = _swipeTranslatableText(msg);
    if (text.isNotEmpty) {
      ChatTranslationService.instance
          .toggleForSwipe(_translationId(msg, text), text);
    }
  }
  return false;
}

Widget _translateSwipeBackground() => Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      color: Colors.transparent,
      child: Icon(Icons.translate_rounded,
          color: const Color(0xFF5045B9), size: 22.sp),
    );

Widget _buildUnreadDivider(int? unreadCount) {
  final label = (unreadCount != null && unreadCount > 0)
      ? "$unreadCount UNREAD MESSAGES"
      : "UNREAD MESSAGES";
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF5045B9).withValues(alpha: 0.35), thickness: 0.8)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFECEAFD),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF5045B9).withValues(alpha: 0.3), width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5045B9),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFF5045B9).withValues(alpha: 0.35), thickness: 0.8)),
      ],
    ),
  );
}

Widget _buildSecurityEncryptionBanner({bool isGroup = false}) {
  return Center(
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFF9E79F).withValues(alpha: 0.8),
          width: 0.8,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 14.sp, color: const Color(0xFF7D6608)),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              "Messages and calls are encrypted with AES-256 and TLS. Your communications are private and protected.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7D6608),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

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
      final loadFailed = controller.historyLoadFailed.value;
      final loadingOlder = controller.isLoadingOlderMessages.value;

      return StreamBuilder<List<MessageData>>(
        stream: controller.messageStream,
        initialData: controller.messageData,
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          if (isLoading && messages.isEmpty) {
            return const ChatMessageSkeleton();
          }

          if (messages.isEmpty && loadFailed) {
            return ChatHistoryErrorState(onRetry: controller.retryLoadHistory);
          }

          if (!isLoading && messages.isEmpty) {
            return _buildEmptyState();
          }

          return Stack(
            children: [
              _buildList(messages),
              ChatHistoryTopLoader(visible: loadingOlder),
            ],
          );
        },
      );
    });
  }

  Widget _buildList(List<MessageData> messages) {
    return Builder(
      builder: (context) {
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
                      appDayLabel(DateTime.parse(msg.timestamp.toString()).toLocal());
                  if (index == 0) {
                    showDateHeader = true;
                    dateHeaderText = currentDateStr;
                  } else if (prevMsg?.timestamp != null &&
                      prevMsg!.timestamp.toString().trim().isNotEmpty) {
                    final prevDateStr =
                        appDayLabel(
                            DateTime.parse(prevMsg.timestamp.toString()).toLocal());
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
              if (msg.isSystemMessage || _isDeleted(msg)) {
                itemWidget = bubble;
              } else {
                final canTranslate = _swipeTranslatableText(msg).isNotEmpty;
                itemWidget = Dismissible(
                  key: ValueKey(msg.id ?? index),
                  direction: canTranslate
                      ? DismissDirection.horizontal
                      : DismissDirection.startToEnd,
                  dismissThresholds: const {
                    DismissDirection.startToEnd: 0.25,
                    DismissDirection.endToStart: 0.25,
                  },
                  confirmDismiss: (direction) =>
                      _onMessageSwipe(direction, msg, controller.setReply),
                  secondaryBackground:
                      canTranslate ? _translateSwipeBackground() : null,
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

              final isFirstUnread = msg.id != null &&
                  (controller.unreadCount.value > 0) &&
                  msg.id == controller.firstUnreadMessageId.value;
              if (isFirstUnread) {
                itemWidget = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUnreadDivider(controller.unreadCount.value),
                    itemWidget,
                  ],
                );
              }

              if (showDateHeader && dateHeaderText != null) {
                itemWidget = Column(
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

              if (index == 0) {
                itemWidget = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSecurityEncryptionBanner(),
                    itemWidget,
                  ],
                );
              }

              return itemWidget;
            },
          );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSecurityEncryptionBanner(),
          SizedBox(height: 16.h),
          Text(
            "💬",
            style: TextStyle(fontSize: 48.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            appL10n.chat_emptyTitle,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            appL10n.chat_emptySubtitle,
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
      final loadFailed = controller.historyLoadFailed.value;
      final loadingOlder = controller.isLoadingOlderMessages.value;

      return StreamBuilder<List<MessageData>>(
        stream: controller.messageStream,
        initialData: controller.messageData,
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];

          if (isLoading && messages.isEmpty) {
            return const ChatMessageSkeleton();
          }

          if (messages.isEmpty && loadFailed) {
            return ChatHistoryErrorState(onRetry: controller.retryLoadHistory);
          }

          if (!isLoading && messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSecurityEncryptionBanner(isGroup: true),
                  SizedBox(height: 16.h),
                  Text(
                    "💬",
                    style: TextStyle(fontSize: 48.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    appL10n.chat_emptyTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    appL10n.chat_emptySubtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(children: [ScrollablePositionedList.builder(
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
                      appDayLabel(DateTime.parse(msg.timestamp.toString()).toLocal());
                  if (index == 0) {
                    showDateHeader = true;
                    dateHeaderText = currentDateStr;
                  } else if (prevMsg?.timestamp != null &&
                      prevMsg!.timestamp.toString().trim().isNotEmpty) {
                    final prevDateStr =
                        appDayLabel(
                            DateTime.parse(prevMsg.timestamp.toString()).toLocal());
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
              if (msg.isSystemMessage || _isDeleted(msg)) {
                itemWidget = bubble;
              } else {
                final canTranslate = _swipeTranslatableText(msg).isNotEmpty;
                itemWidget = Dismissible(
                  key: ValueKey(msg.id ?? index),
                  direction: canTranslate
                      ? DismissDirection.horizontal
                      : DismissDirection.startToEnd,
                  dismissThresholds: const {
                    DismissDirection.startToEnd: 0.25,
                    DismissDirection.endToStart: 0.25,
                  },
                  confirmDismiss: (direction) =>
                      _onMessageSwipe(direction, msg, controller.setReply),
                  secondaryBackground:
                      canTranslate ? _translateSwipeBackground() : null,
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

              final isFirstUnread = msg.id != null &&
                  (controller.unreadCount.value > 0) &&
                  msg.id == controller.firstUnreadMessageId.value;
              if (isFirstUnread) {
                itemWidget = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUnreadDivider(controller.unreadCount.value),
                    itemWidget,
                  ],
                );
              }

              if (showDateHeader && dateHeaderText != null) {
                itemWidget = Column(
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

              if (index == 0) {
                itemWidget = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSecurityEncryptionBanner(isGroup: true),
                    itemWidget,
                  ],
                );
              }

              return itemWidget;
            },
          ), ChatHistoryTopLoader(visible: loadingOlder)]);
        },
      );
    });
  }
}
