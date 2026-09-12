import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/DocumentService.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/util/file_helper.dart';
import '../../../global_widget/common_widget.dart';
import 'AudioPlayerWidget.dart';
import 'ContactBubbleWidget.dart';
import 'LocationBubbleWidget.dart';
import 'message_Widgets.dart';

class ChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final MessageController controller;

  const ChatBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.context,
  });

  static const Color _purple = Color(0xFF5045B9);
  static const Color _myBubbleBg = Color(0xFFDCD6F5);
  static const Color _otherBubbleBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe ? _myBubbleBg : _otherBubbleBg;
    final textColor = Colors.black87;

    final borderRadius = isSentByMe
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(4.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(4.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Builder(
              builder: (bubbleContext) {
                return Obx(
                      () => GestureDetector(
                    onLongPress: () =>
                        _showMessageMenu(bubbleContext, isSentByMe),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                        maxWidth:
                        MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                        controller.highlightedMessageId.value ==
                            message.id
                            ? Colors.yellow.withValues(alpha: .35)
                            : bgColor,
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildReplyPreview(
                              message,
                              isSentByMe,
                            ),

                            if (_isPlainTextMessage(message))
                              _buildTextWithTime(
                                message: message,
                                textColor: textColor,
                                isSentByMe: isSentByMe,
                              )
                            else ...[
                              _buildMessageContent(
                                message,
                                textColor,
                                isSentByMe,
                              ),
                              SizedBox(height: 4.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildTimeRow(
                                  isSentByMe,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );  }

  bool _isPlainTextMessage(MessageData message) {
    final type = message.messageType ?? "text";
    return type == "text" || type == "text_message" || type.isEmpty;
  }

  Widget _buildTimeRow(bool isSentByMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited == true) ...[
          Text(
            "edited",
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          formatTime(message.timestamp ?? ""),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isSentByMe) ...[
          SizedBox(width: 3.w),
          Icon(
            (message.seenCount ?? 0) > 0 ? Icons.done_all : Icons.done,
            size: 14.sp,
            color:
                (message.seenCount ?? 0) > 0 ? _purple : Colors.grey.shade500,
          ),
        ],
      ],
    );
  }

  Widget _buildTextWithTime({
    required MessageData message,
    required Color textColor,
    required bool isSentByMe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextContent(message, textColor, isSentByMe),
        ),
        SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  Widget _buildTextContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final query = controller.searchQuery.value;
    final content = message.content?.toString() ?? "";

    if (query.isNotEmpty &&
        content.toLowerCase().contains(query.toLowerCase())) {
      return _buildHighlightedText(
        content,
        query,
        normalStyle: TextStyle(
          color: textColor,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
        highlightStyle: TextStyle(
          backgroundColor: const Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
      );
    }

    return Linkify(
      text: content,
      style: TextStyle(
        color: textColor,
        fontSize: 13.sp,
        fontFamily: FontFamily.interMedium,
        height: 1.35,
      ),
      linkStyle: TextStyle(
        color: _purple,
        decoration: TextDecoration.underline,
        fontSize: 13.sp,
      ),
      onOpen: (link) async {
        Uri uri = Uri.parse(link.url);
        if (!uri.hasScheme) {
          uri = Uri.parse("https://${link.url}");
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final imagePart = message.content ?? "";
      final caption = message.caption ?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: ImageViewerWidget(
              imageProvider: NetworkImage(
                "${ConstRes.aImageBaseUrl}$imagePart",
              ),
              width: 220,
              height: 200,
              borderRadius: 10,
            ),
          ),
          if (caption.isNotEmpty) SizedBox(height: 8.h),
          if (caption.isNotEmpty)
            reausabletext(
              caption,
              color: textColor,
              fontsize: 12.sp,
            ),
        ],
      );
    } else if (message.messageType == "audio") {
      return AudioBubble(
        audioUrl: "${ConstRes.aImageBaseUrl}${message.content}",
        isMe: false,
      );
    } else if (message.messageType == "video") {
      final parts = message.content?.split("||") ?? [];
      final videoPath = parts.isNotEmpty ? parts[0] : "";
      final thumbnailPath = parts.length > 1 ? parts[1] : "";
      final duration = parts.length > 2 ? parts[2] : "--:--";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoThumbnailWidget(
            videoUrl: "${ConstRes.aImageBaseUrl}$videoPath",
            thumbnail: thumbnailPath,
            duration: duration,
            onTap: () {
              Get.toNamed(
                Routes.videoPlayerScreen,
                arguments: {
                  "videoUrl": "${ConstRes.aImageBaseUrl}$videoPath",
                },
              );
            },
          ),
          if ((message.caption ?? "").isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                message.caption!,
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName);
      final extension = documentName.split('.').last.toLowerCase();
      final fileSize = parts.length > 2 ? parts[2] : "";

      IconData icon;
      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf_rounded;
          break;
        case "doc":
        case "docx":
          icon = Icons.description_rounded;
          break;
        case "xls":
        case "xlsx":
          icon = Icons.table_chart_rounded;
          break;
        case "ppt":
        case "pptx":
          icon = Icons.slideshow_rounded;
          break;
        default:
          icon = Icons.insert_drive_file_rounded;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await DocumentService()
                  .openDocument("${ConstRes.aImageBaseUrl}$documentUrl");
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 240.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFFF3F1FB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: _purple, size: 24.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          documentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          fileSize.isNotEmpty
                              ? "$fileSize • ${extension.toUpperCase()}"
                              : extension.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.download_rounded, color: _purple, size: 20.sp),
                ],
              ),
            ),
          ),
          if ((message.caption ?? "").isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                message.caption.toString(),
                color: textColor,
                fontsize: 12.sp,
                fontfamily: FontFamily.interMedium,
              ),
            ),
        ],
      );
    } else if (message.messageType == "location") {
      return LocationBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else if (message.messageType == "contact") {
      return ContactBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else {
      return _buildTextContent(message, textColor, isSentByMe);
    }
  }

  Widget _buildReplyPreview(MessageData message, bool isSentByMe) {
    if (message.replyId == null) return const SizedBox.shrink();

    String preview = message.replyMessage?.toString() ?? "";
    switch (message.replyType) {
      case "image":
        preview = "📷 Photo";
        break;
      case "video":
        preview = "🎥 Video";
        break;
      case "audio":
        preview = "🎤 Voice message";
        break;
      case "document":
        preview = "📄 Document";
        break;
      case "location":
        preview = "📍 Location";
        break;
    }

    return GestureDetector(
      onTap: () {
        if (message.replyId != null) {
          controller.scrollToMessage(message.replyId!);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.white.withValues(alpha: .5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            left: BorderSide(color: _purple, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.replySenderName?.toString() ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: _purple,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageMenu(BuildContext bubbleContext, bool isSentByMe) {
    final isPinned = controller.pinnedMessage.value?.id == message.id;

    final isText = message.messageType == "text" ||
        message.messageType == "text_message" ||
        (message.messageType ?? "").isEmpty;

    final renderBox =
    bubbleContext.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final screenSize = MediaQuery.of(bubbleContext).size;

    const menuWidth = 220.0;
    const menuMargin = 8.0;

    // Default: message ke right side
    double left = position.dx + size.width + menuMargin;

    // Right side space nahi hai -> message ke left side
    if (left + menuWidth > screenSize.width - menuMargin) {
      left = position.dx - menuWidth - menuMargin;
    }

    // Safety
    left = left.clamp(
      menuMargin,
      screenSize.width - menuWidth - menuMargin,
    );

    // Message ke top ke aas-paas
    double top = position.dy;

    // Menu ki approximate height
    const menuHeight = 500.0;

    // Neeche space nahi hai -> upar shift
    if (top + menuHeight > screenSize.height - menuMargin) {
      top = screenSize.height - menuHeight - menuMargin;
    }

    // Top boundary
    if (top < menuMargin) {
      top = menuMargin;
    }

    showDialog(
      context: bubbleContext,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuTile(
                          icon: Icons.reply_rounded,
                          iconColor: _purple,
                          title: "Reply",
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.setReply(message);
                          },
                        ),

                        if (isText)
                          _menuTile(
                            icon: Icons.copy_rounded,
                            iconColor: _purple,
                            title: "Copy",
                            onTap: () async {
                              Navigator.pop(ctx);

                              await Clipboard.setData(
                                ClipboardData(
                                  text: message.content ?? "",
                                ),
                              );

                              Utils().fluttertoast("Message copied");
                            },
                          ),

                        _menuTile(
                          icon: Icons.forward_rounded,
                          iconColor: _purple,
                          title: "Forward",
                          onTap: () {
                            Navigator.pop(ctx);

                            Get.toNamed(
                              Routes.forwardMessageScreen,
                              arguments: {
                                "message": message,
                              },
                            );
                          },
                        ),

                        if (isSentByMe && isText)
                          _menuTile(
                            icon: Icons.edit_rounded,
                            iconColor: _purple,
                            title: "Edit",
                            onTap: () {
                              Navigator.pop(ctx);
                              controller.startEditingMessage(message);
                            },
                          ),

                        _menuTile(
                          icon: Icons.push_pin_rounded,
                          iconColor:
                          isPinned ? Colors.redAccent : _purple,
                          title: isPinned
                              ? "Unpin Message"
                              : "Pin Message",
                          onTap: () {
                            Navigator.pop(ctx);

                            if (isPinned) {
                              controller.unpinMessage();
                            } else {
                              controller.pinMessage(message);
                            }
                          },
                        ),

                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                          indent: 12,
                          endIndent: 12,
                        ),

                        if (isSentByMe)
                          _menuTile(
                            icon: Icons.delete_outline_rounded,
                            iconColor: Colors.redAccent,
                            title: "Delete for Everyone",
                            isDestructive: true,
                            onTap: () {
                              Navigator.pop(ctx);

                              controller.deleteMessage(
                                messageId: message.id!,
                                deleteType: "for_everyone",
                              );
                            },
                          ),

                        _menuTile(
                          icon: Icons.delete_rounded,
                          iconColor: Colors.redAccent,
                          title: "Delete for Me",
                          isDestructive: true,
                          onTap: () {
                            Navigator.pop(ctx);

                            controller.deleteMessage(
                              messageId: message.id!,
                              deleteType: "for_me",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? Colors.redAccent
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<InlineSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }
      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: normalStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));
      start = index + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class GroupChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final bool isGroup;
  final int? groupId;
  final String? groupName;
  final GroupMessageController controller;

  const GroupChatBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.context,
    this.isGroup = false,
    this.groupId,
    this.groupName,
  });

  static const Color _purple = Color(0xFF5045B9);
  static const Color _myBubbleBg = Color(0xFFDCD6F5);
  static const Color _otherBubbleBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe ? _myBubbleBg : _otherBubbleBg;

    final textColor = Colors.black87;

    final borderRadius = isSentByMe
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(4.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(4.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isGroup && !isSentByMe)
            Padding(
              padding: EdgeInsets.only(
                right: 8.w,
                top: 4.h,
              ),
              child: GestureDetector(
                onTap: () {
                  DialogBox().showRouteDetailsBottomSheet(
                    destination: const LatLng(0, 0),
                    distance: 0,
                    userId:
                    int.tryParse(
                      message.senderId.toString(),
                    ) ??
                        0,
                    groupId: groupId,
                    groupName: groupName,
                    name: message.senderName,
                    imageUrl: message.senderImage,
                    status: true,
                    lastSeen: "",
                    isGroupChat: true,
                    isLocationSharing:
                    message.locationSharing ?? false,
                  );
                },
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                  message.senderImage != null &&
                      message.senderImage!.isNotEmpty
                      ? NetworkImage(
                    "${ConstRes.aImageBaseUrl}${message.senderImage}",
                  )
                      : null,
                  child:
                  (message.senderImage == null ||
                      message.senderImage!.isEmpty)
                      ? Icon(
                    Icons.person,
                    size: 18.sp,
                    color: Colors.grey.shade500,
                  )
                      : null,
                ),
              ),
            ),

          Flexible(
            child: Builder(
              builder: (bubbleContext) {
                return Obx(
                      () => GestureDetector(
                    onLongPress: () =>
                        _showMessageMenu(
                          bubbleContext,
                          isSentByMe,
                        ),
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                        maxWidth:
                        MediaQuery.of(context).size.width *
                            0.75,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                        controller.highlightedMessageId
                            .value ==
                            message.id
                            ? Colors.yellow.withValues(
                          alpha: .35,
                        )
                            : bgColor,
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGroup && !isSentByMe)
                              Padding(
                                padding:
                                EdgeInsets.only(
                                  bottom: 4.h,
                                ),
                                child: Text(
                                  message.senderName
                                      ?.toString() ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight:
                                    FontWeight.w700,
                                    color: _purple,
                                  ),
                                ),
                              ),

                            _buildReplyPreview(
                              message,
                              isSentByMe,
                            ),

                            if (_isPlainTextMessage(message))
                              _buildTextWithTime(
                                message: message,
                                textColor: textColor,
                                isSentByMe: isSentByMe,
                              )
                            else ...[
                              _buildMessageContent(
                                message,
                                textColor,
                                isSentByMe,
                              ),
                              SizedBox(height: 4.h),
                              Align(
                                alignment:
                                Alignment.centerRight,
                                child: _buildTimeRow(
                                  isSentByMe,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

  }

  bool _isPlainTextMessage(MessageData message) {
    final type = message.messageType ?? "text";
    return type == "text" || type == "text_message" || type.isEmpty;
  }

  Widget _buildTimeRow(bool isSentByMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited == true) ...[
          Text(
            "edited",
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        Text(
          formatTime(message.timestamp ?? ""),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isSentByMe) ...[
          SizedBox(width: 3.w),
          Icon(
            (message.seenCount ?? 0) > 0 ? Icons.done_all : Icons.done,
            size: 14.sp,
            color: _areAllMembersSeen(message) ? _purple : Colors.grey.shade500,
          ),
        ],
      ],
    );
  }

  Widget _buildTextWithTime({
    required MessageData message,
    required Color textColor,
    required bool isSentByMe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextContent(message, textColor, isSentByMe),
        ),
        SizedBox(width: 14.w),
        _buildTimeRow(isSentByMe),
      ],
    );
  }

  Widget _buildTextContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    final query = controller.searchQuery.value;
    final content = message.content?.toString() ?? "";

    if (query.isNotEmpty &&
        content.toLowerCase().contains(query.toLowerCase())) {
      return _buildHighlightedText(
        content,
        query,
        normalStyle: TextStyle(
          color: textColor,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
        highlightStyle: TextStyle(
          backgroundColor: const Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
          fontFamily: FontFamily.interMedium,
          height: 1.35,
        ),
      );
    }

    return Linkify(
      text: content,
      style: TextStyle(
        color: textColor,
        fontSize: 13.sp,
        fontFamily: FontFamily.interMedium,
        height: 1.35,
      ),
      linkStyle: TextStyle(
        color: _purple,
        decoration: TextDecoration.underline,
        fontSize: 13.sp,
      ),
      onOpen: (link) async {
        Uri uri = Uri.parse(link.url);
        if (!uri.hasScheme) {
          uri = Uri.parse("https://${link.url}");
        }
        debugPrint("OPEN URL => $uri");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<InlineSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }

      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: normalStyle));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildReplyPreview(MessageData message, bool isSentByMe) {
    if (message.replyId == null) return const SizedBox.shrink();

    String preview = message.replyMessage ?? "";
    switch (message.replyType) {
      case "image":
        preview = "📷 Photo";
        break;
      case "video":
        preview = "🎥 Video";
        break;
      case "audio":
        preview = "🎤 Voice message";
        break;
      case "document":
        preview = "📄 Document";
        break;
      case "location":
        preview = "📍 Location";
        break;
    }

    return GestureDetector(
      onTap: () {
        if (message.replyId != null) {
          controller.scrollToMessage(message.replyId!);
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSentByMe
              ? Colors.white.withValues(alpha: .5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            left: BorderSide(color: _purple, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.replySenderName ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: _purple,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
    bool isSentByMe,
  ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final imagePart = message.content ?? "";
      final caption = message.caption ?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: ImageViewerWidget(
              imageProvider: NetworkImage(
                "${ConstRes.aImageBaseUrl}$imagePart",
              ),
              width: 220,
              height: 200,
              borderRadius: 10,
            ),
          ),
          if (caption.isNotEmpty) SizedBox(height: 8.h),
          if (caption.isNotEmpty)
            reausabletext(
              caption,
              color: textColor,
              fontsize: 12.sp,
            ),
        ],
      );
    } else if (message.messageType == "audio") {
      return AudioBubble(
        audioUrl: "${ConstRes.aImageBaseUrl}${message.content}",
        isMe: false,
      );
    } else if (message.messageType == "video") {
      final parts = message.content?.split("||") ?? [];
      final videoPath = parts.isNotEmpty ? parts[0] : "";
      final thumbnailPath = parts.length > 1 ? parts[1] : "";
      final duration = parts.length > 2 ? parts[2] : "--:--";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoThumbnailWidget(
            videoUrl: "${ConstRes.aImageBaseUrl}$videoPath",
            thumbnail: thumbnailPath,
            duration: duration,
            onTap: () {
              Get.toNamed(
                Routes.videoPlayerScreen,
                arguments: {
                  "videoUrl": "${ConstRes.aImageBaseUrl}$videoPath",
                },
              );
            },
          ),
          if ((message.caption ?? "").isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                message.caption!,
                color: textColor,
                fontsize: 12.sp,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];
      final documentUrl = parts.isNotEmpty ? parts[0] : "";
      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;
      documentName = removeDuplicateExtension(documentName);
      final extension = documentName.split('.').last.toLowerCase();
      final fileSize = parts.length > 2 ? parts[2] : "";

      IconData icon;
      Color iconColor;
      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf_rounded;
          iconColor = Colors.red;
          break;
        case "doc":
        case "docx":
          icon = Icons.description_rounded;
          iconColor = Colors.blue;
          break;
        case "xls":
        case "xlsx":
          icon = Icons.table_chart_rounded;
          iconColor = Colors.green;
          break;
        case "ppt":
        case "pptx":
          icon = Icons.slideshow_rounded;
          iconColor = Colors.orange;
          break;
        default:
          icon = Icons.insert_drive_file_rounded;
          iconColor = _purple;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await DocumentService()
                  .openDocument("${ConstRes.aImageBaseUrl}$documentUrl");
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 240.w,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFFF3F1FB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: _purple, size: 24.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          documentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          fileSize.isNotEmpty
                              ? "$fileSize • ${extension.toUpperCase()}"
                              : extension.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.download_rounded,
                    color: _purple,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if ((message.caption ?? "").isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: reausabletext(
                message.caption.toString(),
                color: textColor,
                fontsize: 12.sp,
                fontfamily: FontFamily.interMedium,
              ),
            ),
        ],
      );
    } else if (message.messageType == "location") {
      return LocationBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else if (message.messageType == "contact") {
      return ContactBubbleWidget(
        content: message.content,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onLongPress: () {
            _showMessageMenu(context, isSentByMe);
          },
          onDoubleTap: () async {
            await Clipboard.setData(
              ClipboardData(text: message.content.toString()),
            );
            Utils().fluttertoast("Message copied...");
          },
          child: _buildTextContent(message, textColor, isSentByMe),
        ),
      );
    }
  }

  bool _areAllMembersSeen(MessageData message) {
    if (message.seenBy is! List) return false;

    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final recipientIds = controller.groupMembers
        .where((member) => member.userId.toString() != currentUserId)
        .map((member) => member.userId.toString())
        .toSet();

    if (recipientIds.isEmpty) return false;

    final seenIds = (message.seenBy as List).map((id) => id.toString()).toSet();

    return recipientIds.every((userId) => seenIds.contains(userId));
  }

  void _showMessageMenu(BuildContext bubbleContext, bool isSentByMe) {
    final isPinned = controller.pinnedMessage.value?.id == message.id;

    final isText = message.messageType == "text" ||
        message.messageType == "text_message" ||
        (message.messageType ?? "").isEmpty;

    final renderBox =
    bubbleContext.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final screenSize = MediaQuery.of(bubbleContext).size;

    const menuWidth = 220.0;
    const menuMargin = 8.0;

    double left = position.dx + size.width + menuMargin;

    if (left + menuWidth > screenSize.width - menuMargin) {
      left = position.dx - menuWidth - menuMargin;
    }

    left = left.clamp(
      menuMargin,
      screenSize.width - menuWidth - menuMargin,
    );

    double top = position.dy;

    const menuHeight = 500.0;

    if (top + menuHeight > screenSize.height - menuMargin) {
      top = screenSize.height - menuHeight - menuMargin;
    }

    if (top < menuMargin) {
      top = menuMargin;
    }

    showDialog(
      context: bubbleContext,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuTile(
                          icon: Icons.reply_rounded,
                          iconColor: _purple,
                          title: "Reply",
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.setReply(message);
                          },
                        ),

                        if (isText)
                          _menuTile(
                            icon: Icons.copy_rounded,
                            iconColor: _purple,
                            title: "Copy",
                            onTap: () async {
                              Navigator.pop(ctx);

                              await Clipboard.setData(
                                ClipboardData(
                                  text: message.content ?? "",
                                ),
                              );

                              Utils().fluttertoast("Message copied");
                            },
                          ),

                        _menuTile(
                          icon: Icons.forward_rounded,
                          iconColor: _purple,
                          title: "Forward",
                          onTap: () {
                            Navigator.pop(ctx);

                            Get.toNamed(
                              Routes.forwardMessageScreen,
                              arguments: {
                                "message": message,
                              },
                            );
                          },
                        ),

                        if (isSentByMe && isText)
                          _menuTile(
                            icon: Icons.edit_rounded,
                            iconColor: _purple,
                            title: "Edit",
                            onTap: () {
                              Navigator.pop(ctx);
                              controller.startEditingMessage(message);
                            },
                          ),

                        _menuTile(
                          icon: Icons.push_pin_rounded,
                          iconColor:
                          isPinned ? Colors.redAccent : _purple,
                          title: isPinned
                              ? "Unpin Message"
                              : "Pin Message",
                          onTap: () {
                            Navigator.pop(ctx);

                            if (isPinned) {
                              controller.unpinMessage();
                            } else {
                              controller.pinMessage(message);
                            }
                          },
                        ),

                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                          indent: 12,
                          endIndent: 12,
                        ),

                        if (isSentByMe)
                          _menuTile(
                            icon: Icons.delete_outline_rounded,
                            iconColor: Colors.redAccent,
                            title: "Delete for Everyone",
                            isDestructive: true,
                            onTap: () {
                              Navigator.pop(ctx);

                              controller.deleteMessage(
                                messageId: message.id!,
                                deleteType: "for_everyone",
                              );
                            },
                          ),

                        _menuTile(
                          icon: Icons.delete_rounded,
                          iconColor: Colors.redAccent,
                          title: "Delete for Me",
                          isDestructive: true,
                          onTap: () {
                            Navigator.pop(ctx);

                            controller.deleteMessage(
                              messageId: message.id!,
                              deleteType: "for_me",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? Colors.redAccent
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
