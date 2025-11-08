import 'dart:convert';
import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../../Core/values/global.dart';
import '../../../Model/GetMessage.dart';
import '../Controller/MessageController.dart';

class ImageViewerWidget extends StatelessWidget {
  final ImageProvider imageProvider;
  final double width;
  final double height;
  final double borderRadius;

  const ImageViewerWidget({
    super.key,
    required this.imageProvider,
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });

  void _showImageViewer(BuildContext context) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image(image: imageProvider),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageViewer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Image(
          image: imageProvider,
          width: width.w,
          height: height.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width.w,
              height: height.h,
              color: Colors.grey[300],
              child: const Center(child: Text("Image failed")),
            );
          },
        ),
      ),
    );
  }
}
class CommonChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImageUrl;
  final String userName;
  final String groupName;
  final VoidCallback? onBackTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onThemeTap;

  const CommonChatAppBar({
    Key? key,
    required this.profileImageUrl,
    required this.userName,
    this.onBackTap,
    this.onCallTap,
    this.onMicTap,
    this.onVideoTap,
    this.onThemeTap,
    required this.groupName,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: onBackTap,
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing Row
          Row(

            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    userName,
                    textoverflow: TextOverflow.ellipsis,
                    align: TextAlign.start,
                    color: Colors.black,
                    fontsize: 15.sp,
                    fontweight: FontWeight.w600,
                  ),
                  reausabletext(
                    widths: 110,
                    groupName,
                   fontsize: 13.sp, color: Colors.grey[500]),

                ],
              ),
            ],
          ),

        ],
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.call, color: Colors.black),
          onPressed: onCallTap,iconSize: 20.sp,
        ),
        // IconButton(
        //   icon: Icon(Icons.mic, color: Colors.black),
        //   onPressed: onMicTap,
        // ),
        IconButton(
          icon: Icon(Icons.videocam, color: Colors.black),
          onPressed: onVideoTap,
        ),
        IconButton(
          icon: Icon(Icons.color_lens, color: Colors.black),
          onPressed: onThemeTap,
        ),
      ],

    );
  }
}

Future<String?> uploadImage(String filePath) async {
  try {
    // Example using MultipartRequest (adjust according to your backend)
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-server.com/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['url']; // Assuming server returns uploaded image URL
    }
  } catch (e) {
    print("Image Upload Error: $e");
  }
  return null;
}

class ChatInputArea extends StatelessWidget {
  final RxString messageText;
  final RxString imagePath;
  final RxBool isSending;
  final TextEditingController textController;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final Function(String path) onImageSelected;

  const ChatInputArea({
    Key? key,
    required this.messageText,
    required this.imagePath,
    required this.isSending,
    required this.textController,
    required this.scrollController,
    required this.onSend,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        WidgetsBinding.instance.addPostFrameCallback(
                (_) => scrollController.jumpTo(scrollController.position.maxScrollExtent));

        final isMessageNotEmpty = messageText.value.trim().isNotEmpty;
        final isImageSelected = imagePath.value.isNotEmpty;
        final shouldShowSend = isMessageNotEmpty || isImageSelected;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Preview
            if (isImageSelected)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Stack(
                  children: [
                    ImageViewerWidget(
                      imageProvider: FileImage(File(imagePath.value)),
                      width: 250,
                      height: 180,
                      borderRadius: 12,
                    ),
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: GestureDetector(
                        onTap: () => imagePath.value = '',
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image picker button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.image, color: Colors.blueAccent),
                      onPressed: () {
                        ModalImage modal = ModalImage(
                          isImageCroppable: true,
                          onImageSelect: (path) {
                            if (Utility.isNotNullEmptyOrFalse(path)) {
                              onImageSelected(path);
                            }
                          },
                        );
                        modal.mainBottomSheet(context, groupType: "joinGroup");
                      },
                    ),
                  ),
                  SizedBox(width: 5.w),

                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (val) => messageText.value = val,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      textInputAction: TextInputAction.send,
                    ),
                  ),

                  SizedBox(width: 8.w),


                  if (shouldShowSend)
                    GestureDetector(
                      onTap: isSending.value ? null : onSend,
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: isSending.value ? Colors.grey : Colors.blue,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

Widget _lastSeenWidget() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
    alignment: Alignment.centerLeft,
    child: reausabletext(
        align: TextAlign.center,
        "Last seen today at 9:55 AM",
        color: Colors.grey[600],
        fontsize: 13),
  );
}

class ChatController {
  final ScrollController scrollController = ScrollController();

  // Example message data list, replace with your actual data model
  List<MessageModel> messageData = [];

  /// This returns the ListView widget to show chat messages.
  Widget buildChatListWidget(Widget Function(MessageModel msg) chatBubbleBuilder) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: messageData.length,
      itemBuilder: (context, index) {
        final msg = messageData[index];
        return chatBubbleBuilder(msg);
      },
    );
  }
}

// Example message model - replace with your actual message model class
class MessageModel {
  final String text;
  // add other fields if needed

  MessageModel(this.text);
}




class ThemePicker {
  /// Shows the Theme Picker Bottom Sheet
  static void show(BuildContext context, MessageController controller, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(16),
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Chat Theme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                Colors.blue.shade100,
                Colors.green.shade100,
                Colors.pink.shade100,
                Colors.yellow.shade100,
                Colors.grey.shade100,
                Colors.white,
              ].map((color) {
                return GestureDetector(
                  onTap: () {
                    controller.chatBackgroundColor.value = color;
                    controller.chatBackgroundImagePath.value = null;
                    controller.saveThemePreferences(userId);
                    Get.back();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                controller.pickBackgroundImageFromGallery(userId).then((_) {
                  controller.saveThemePreferences(userId);
                });
                Get.back();
              },
              icon: Icon(Icons.photo),
              label: Text("Choose from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
// adjust import for your custom text widget

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
    final currentUserId = Global.storageServices.get(PrefConst.userId).toString();
    final isSentByMe = message.senderId.toString() == currentUserId;

    final align = isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isSentByMe ? Colors.blue[400] : Colors.grey.shade300;
    final textColor = isSentByMe ? Colors.white : Colors.black87;

    final radius = isSentByMe
        ? BorderRadius.only(
      topLeft: Radius.circular(15.r),
      topRight: Radius.circular(0.r),
      bottomLeft: Radius.circular(15.r),
      bottomRight: Radius.circular(15.r),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(0.r),
      topRight: Radius.circular(15.r),
      bottomLeft: Radius.circular(15.r),
      bottomRight: Radius.circular(15.r),
    );

    final imageUrl = "${ConstRes.aImageBaseUrl}${message.content ?? ''}";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
            ),
            child: _buildMessageContent(message, textColor),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: isSentByMe ? EdgeInsets.only(right: 8.w) : EdgeInsets.only(left: 8.w),
            child: Align(
              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: reausabletext(
                formatTime(message.timestamp ?? ""),
                fontsize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Extracted message content builder
  Widget _buildMessageContent(MessageData message, Color textColor) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final parts = message.content?.split("||") ?? [];
      final imagePart = parts.isNotEmpty ? parts[0] : "";
      final textPart = parts.length > 1 ? parts[1] : "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: ImageViewerWidget(
              imageProvider: NetworkImage("${ConstRes.aImageBaseUrl}$imagePart"),
              width: 200,
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
    } else {
      return reausabletext(
        message.content.toString(),
        color: textColor,
        fontsize: 11.sp,
      );
    }
  }
}


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
            ChatBubble(message: msg, context: context),
          ],
        );
      },
    ));
  }

  /// ✅ Extracted date header widget for better readability
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


