import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Widget _buildMessageContent(MessageData message, Color textColor) {
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
              imageProvider:
                  NetworkImage("${ConstRes.aImageBaseUrl}$imagePart"),
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
