import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/util/file_helper.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/DocumentService.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Views/videoPlayerScreen.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';

import 'AudioPlayerWidget.dart';
import 'message_Widgets.dart';

class ChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;

  const ChatBubble({
    Key? key,
    required this.message,
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

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: bgColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                )
              ],
            ),
            child: _buildMessageContent(message, textColor),
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
    );
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
  ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final parts = message.content?.split("||") ?? [];
      final imagePart = parts.isNotEmpty ? parts[0] : "";
      final textPart = parts.length > 1 ? parts[1] : "";

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
          if (textPart.isNotEmpty) SizedBox(height: 8.h),
          if (textPart.isNotEmpty)
            reausabletext(
              textPart,
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
      final videoUrl = "${ConstRes.aImageBaseUrl}${message.content}";

      return VideoThumbnailWidget(
        videoUrl: videoUrl,
        onTap: () {
          Get.toNamed(
            Routes.videoPlayerScreen,
            arguments: {
              "videoUrl": message.content,
            },
          );
        },
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

      return InkWell(
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
      );
    } else {
      return reausabletext(
        message.content.toString(),
        color: textColor,
        fontsize: 12.sp,
        fontfamily: FontFamily.interMedium,
      );
    }
  }
}

class GroupChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final bool isGroup;
  final int? groupId;
  final String? groupName;

  const GroupChatBubble({
    Key? key,
    required this.message,
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
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: bgColor,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      )
                    ],
                  ),
                  child: _buildMessageContent(
                    message,
                    textColor,
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
    );
  }

  Widget _buildMessageContent(
    MessageData message,
    Color textColor,
  ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final parts = message.content?.split("||") ?? [];
      final imagePart = parts.isNotEmpty ? parts[0] : "";
      final textPart = parts.length > 1 ? parts[1] : "";

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
          if (textPart.isNotEmpty) SizedBox(height: 8.h),
          if (textPart.isNotEmpty)
            reausabletext(
              textPart,
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
      final videoUrl = "${ConstRes.aImageBaseUrl}${message.content}";

      return VideoThumbnailWidget(
        videoUrl: videoUrl,
        onTap: () {
          Get.toNamed(
            Routes.videoPlayerScreen,
            arguments: {
              "videoUrl": message.content,
            },
          );
        },
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

      return InkWell(
        onTap: () async {
          await DocumentService().openDocument(
            "${ConstRes.aImageBaseUrl}${documentUrl}",
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
      );
    } else {
      return reausabletext(
        message.content.toString(),
        color: textColor,
        fontsize: 12.sp,
        fontfamily: FontFamily.interMedium,
      );
    }
  }
}
