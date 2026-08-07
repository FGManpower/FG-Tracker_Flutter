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
import '../../../config/themes_data.dart';
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
    Key? key,
    required this.message,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe
        ? const LinearGradient(
            colors: [ToggleThemeData.darkPurple, ToggleThemeData.Appcolor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Colors.white, Colors.white],
          );

    final textColor = isSentByMe ? Colors.white : Colors.black87;

    final borderRadius = isSentByMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                _showDeleteBottomSheet(
                  context,
                  isSentByMe,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  gradient: controller.highlightedMessageId.value == message.id
                      ? LinearGradient(
                    colors: [
                      Colors.yellow.withOpacity(.35),
                      Colors.yellow.withOpacity(.20),
                    ],
                  )
                      : bgColor,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReplyPreview(
                      message,
                      isSentByMe,
                    ),
                    _buildMessageContent(
                      message,
                      textColor,
                      isSentByMe,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.only(
                left: isSentByMe ? 0 : 6.w,
                right: isSentByMe ? 6.w : 0,
              ),
              child: Align(
                alignment:
                    isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      formatTime(message.timestamp ?? ""),
                      fontsize: 10.sp,
                      color: Colors.grey[500],
                    ),
                    if (isSentByMe) SizedBox(width: 4.w),
                    if (isSentByMe)
                      Icon(
                        (message.seenCount ?? 0) > 0
                            ? Icons.done_all
                            : Icons.done,
                        size: 16.sp,
                        color: (message.seenCount ?? 0) > 0
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                  ],
                ),
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
      final parts = message.content?.split("||") ?? [];
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
              fontsize: 11.sp,
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
                message.caption.toString(),
                color: textColor,
                fontsize: 11.sp,
                fontfamily: FontFamily.interMedium,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];

      final documentUrl = parts.isNotEmpty ? parts[0] : "";

      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;

      documentName = removeDuplicateExtension(
        documentName,
      );

      final extension = documentName.split('.').last.toLowerCase();

      IconData icon;
      Color iconColor;

      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf;
          iconColor = Colors.red;
          break;

        case "doc":
        case "docx":
          icon = Icons.description;
          iconColor = Colors.blue;
          break;

        case "xls":
        case "xlsx":
          icon = Icons.table_chart;
          iconColor = Colors.green;
          break;

        case "ppt":
        case "pptx":
          icon = Icons.slideshow;
          iconColor = Colors.orange;
          break;

        default:
          icon = Icons.insert_drive_file;
          iconColor = Colors.grey;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await DocumentService().openDocument(
                "${ConstRes.aImageBaseUrl}$documentUrl",
              );
            },
            child: Container(
              width: 240.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          extension.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.download_rounded,
                    color: textColor,
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
                fontsize: 11.sp,
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
      // Search highlight check
      final query = controller.searchQuery.value;
      final content = message.content?.toString() ?? "";

      if (query.isNotEmpty &&
          content.toLowerCase().contains(query.toLowerCase())) {
        // Highlighted text with RichText
        return _buildHighlightedText(
          content,
          query,
          normalStyle: TextStyle(
            color: textColor,
            fontSize: 12.sp,
            fontFamily: FontFamily.interMedium,
          ),
          highlightStyle: TextStyle(
            backgroundColor: const Color(0xFFFFD700),
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            fontFamily: FontFamily.interMedium,
          ),
        );
      }

      return Linkify(
        text: content,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontFamily: FontFamily.interMedium,
        ),
        linkStyle: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        onOpen: (link) async {
          Uri uri = Uri.parse(link.url);
          if (!uri.hasScheme) {
            uri = Uri.parse("https://${link.url}");
          }
          print("URL => $uri");
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        },
      );
    }
  }

  Widget _buildReplyPreview(
    MessageData message,
    bool isSentByMe,
  ) {
    if (message.replyId == null) {
      return const SizedBox.shrink();
    }

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
          color:
              isSentByMe ? Colors.white.withOpacity(.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.r),
          border: Border(
            left: BorderSide(
              color: Colors.green,
              width: 4,
            ),
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
                color: isSentByMe ? Colors.white : Colors.green,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: isSentByMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showDeleteBottomSheet(
      BuildContext context,
      bool isSentByMe,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSentByMe)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text("Delete for Everyone"),
                  onTap: () {
                    print("DELETE FOR EVERYONE CLICKED");
                    Navigator.pop(context);

                    controller.deleteMessage(
                      messageId: message.id!,
                      deleteType: "for_everyone",
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete for Me"),
                onTap: () {
                  print("DELETE FOR ME CLICKED");
                  Navigator.pop(context);

                  controller.deleteMessage(
                    messageId: message.id!,
                    deleteType: "for_me",
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
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
          spans.add(TextSpan(
            text: text.substring(start),
            style: normalStyle,
          ));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
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
    Key? key,
    required this.message,
    required this.controller,
    required this.context,
    this.isGroup = false,
    this.groupId,
    this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe
        ? const LinearGradient(
            colors: [ToggleThemeData.darkPurple, ToggleThemeData.Appcolor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
            ],
          );

    final textColor = isSentByMe ? Colors.white : Colors.black87;

    final borderRadius = isSentByMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Obx(
      () => Container(
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
                  top: 18.h,
                ),
                child: GestureDetector(
                  onTap: () {
                    DialogBox().showRouteDetailsBottomSheet(
                      destination: const LatLng(0, 0),
                      distance: 0,
                      userId: int.tryParse(
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
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: message.senderImage != null &&
                            message.senderImage!.isNotEmpty
                        ? NetworkImage(
                            "${ConstRes.aImageBaseUrl}${message.senderImage}",
                          )
                        : null,
                    child: message.senderImage == null ||
                            message.senderImage!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 18.sp,
                          )
                        : null,
                  ),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (isGroup)
                    Padding(
                      padding: EdgeInsets.only(
                        left: isSentByMe ? 0 : 4.w,
                        right: isSentByMe ? 4.w : 0,
                        bottom: 4.h,
                        top: 20.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isSentByMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isSentByMe) ...[
                            Text(
                              message.senderName?.toString() ?? "",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              formatTime(message.timestamp ?? ""),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ] else ...[
                            Text(
                              formatTime(message.timestamp ?? ""),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              message.senderName?.toString() ?? "",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  GestureDetector(
                    onLongPress: () {
                      _showDeleteBottomSheet(
                        context,
                        isSentByMe,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: controller.highlightedMessageId.value == message.id
                            ? LinearGradient(
                          colors: [
                            Colors.yellow.withOpacity(.35),
                            Colors.yellow.withOpacity(.20),
                          ],
                        )
                            : bgColor,
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReplyPreview(
                            message,
                            isSentByMe,
                          ),
                          _buildMessageContent(
                            message,
                            textColor,
                            isSentByMe,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (isSentByMe)
                    Padding(
                      padding: EdgeInsets.only(
                        right: 4.w,
                      ),
                      child: Icon(
                        (message.seenCount ?? 0) > 0
                            ? Icons.done_all
                            : Icons.done,
                        size: 14.sp,
                        color: (message.seenCount ?? 0) > 0
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (isGroup && isSentByMe)
              Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  top: 20.h,
                ),
                child: GestureDetector(
                  onTap: () {
                    DialogBox().showRouteDetailsBottomSheet(
                      destination: const LatLng(0, 0),
                      distance: 0,
                      userId: int.tryParse(
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
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: message.senderImage != null &&
                            message.senderImage!.isNotEmpty
                        ? NetworkImage(
                            "${ConstRes.aImageBaseUrl}${message.senderImage}",
                          )
                        : null,
                    child: message.senderImage == null ||
                            message.senderImage!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 18.sp,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
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
          fontSize: 12.sp,
          fontFamily: FontFamily.interMedium,
        ),
        highlightStyle: TextStyle(
          backgroundColor: const Color(0xFFFFD700),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
          fontFamily: FontFamily.interMedium,
        ),
      );
    }

    return Linkify(
      text: content,
      style: TextStyle(
        color: textColor,
        fontSize: 12.sp,
        fontFamily: FontFamily.interMedium,
      ),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
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
          spans.add(TextSpan(
            text: text.substring(start),
            style: normalStyle,
          ));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
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
    if (message.replyId == null) {
      return const SizedBox.shrink();
    }

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
          color:
              isSentByMe ? Colors.white.withOpacity(.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10.r),
          border: Border(
            left: BorderSide(
              color: ToggleThemeData.darkPurple,
              width: 3,
            ),
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
                color: isSentByMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: isSentByMe ? Colors.white70 : Colors.grey.shade700,
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
      final parts = message.content?.split("||") ?? [];
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
              fontsize: 11.sp,
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
                fontsize: 11.sp,
              ),
            ),
        ],
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];

      final documentUrl = parts.isNotEmpty ? parts[0] : "";

      String documentName =
          parts.length > 1 ? parts[1] : documentUrl.split('/').last;

      documentName = removeDuplicateExtension(
        documentName,
      );

      final extension = documentName.split('.').last.toLowerCase();

      IconData icon;
      Color iconColor;

      switch (extension) {
        case "pdf":
          icon = Icons.picture_as_pdf;
          iconColor = Colors.red;
          break;

        case "doc":
        case "docx":
          icon = Icons.description;
          iconColor = Colors.blue;
          break;

        case "xls":
        case "xlsx":
          icon = Icons.table_chart;
          iconColor = Colors.green;
          break;

        case "ppt":
        case "pptx":
          icon = Icons.slideshow;
          iconColor = Colors.orange;
          break;

        default:
          icon = Icons.insert_drive_file;
          iconColor = Colors.grey;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await DocumentService().openDocument(
                "${ConstRes.aImageBaseUrl}$documentUrl",
              );
            },
            child: Container(
              width: 240.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          extension.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.download_rounded,
                    color: textColor,
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
                fontsize: 11.sp,
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
            _showDeleteBottomSheet(context, isSentByMe);
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


  void _showDeleteBottomSheet(
      BuildContext context,
      bool isSentByMe,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSentByMe)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text("Delete for Everyone"),
                  onTap: () {
                    Navigator.pop(context);

                    controller.deleteMessage(
                      messageId: message.id!,
                      deleteType: "for_everyone",
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete for Me"),
                onTap: () {
                  Navigator.pop(context);

                  controller.deleteMessage(
                    messageId: message.id!,
                    deleteType: "for_me",
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
