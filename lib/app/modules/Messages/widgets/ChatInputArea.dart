import 'dart:io';

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../Core/values/bottomSheet.dart';
import '../../../Core/values/utility.dart';
import 'message_Widgets.dart';

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
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));

        final isMessageNotEmpty = messageText.value.trim().isNotEmpty;
        final isImageSelected = imagePath.value.isNotEmpty;
        final shouldShowSend = isMessageNotEmpty || isImageSelected;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
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
                  SizedBox(width: 5.w),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          color: ToggleThemeData.white,
                          fontFamily: FontFamily.interMedium,
                          fontSize: 16),
                      maxLines: null,
                      controller: textController,
                      onChanged: (val) => messageText.value = val,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: ToggleThemeData.Appcolor,
                        filled: true,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            backgroundColor: ToggleThemeData.white,
                            radius: 16.r,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: reausableIcon(
                                  icon: Icons.attachment_outlined,
                                  color: ToggleThemeData.darkPurple,
                                  size: 30),
                              onPressed: () {
                                ModalImage modal = ModalImage(
                                  isImageCroppable: true,
                                  onImageSelect: (path) {
                                    if (Utility.isNotNullEmptyOrFalse(path)) {
                                      onImageSelected(path);
                                    }
                                  },
                                );
                                modal.mainBottomSheet(context,
                                    groupType: "joinGroup");
                              },
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                            left: 10.w, right: 10.w, top: 15.h, bottom: 15.h),
                      ),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (shouldShowSend)
                    GestureDetector(
                      onTap: isSending.value ? null : onSend,
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundColor: isSending.value
                            ? Colors.grey
                            : ToggleThemeData.darkPurple,
                        child: reausableIcon(
                            icon: Icons.send, color: Colors.white, size: 25),
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
