import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Core/theme/AppText.dart';
import '../../../Core/values/Dialog/Common_dialog.dart';
import '../Controller/MessageController.dart';

class CommonChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImageUrl;
  final String userName;
  final String groupName;
  final VoidCallback? onBackTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onThemeTap;
  bool isCreator;

  CommonChatAppBar(
      {Key? key,
      required this.profileImageUrl,
      required this.userName,
      this.onBackTap,
      this.onCallTap,
      this.onMicTap,
      this.onVideoTap,
      this.onThemeTap,
      required this.groupName,
      required this.isCreator})
      : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 10.w,
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundImage: NetworkImage(
                      profileImageUrl,
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  if (true)
                    Positioned(
                      right: 4.w,
                      child: Container(
                        height: 12.w,
                        width: 12.w,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5.w),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(userName,
                      textoverflow: TextOverflow.ellipsis,
                      align: TextAlign.start,
                      color: Colors.black,
                      fontsize: 18.sp,
                      fontfamily: FontFamily.interSemiBold),
                  reausabletext(groupName,
                      fontfamily: FontFamily.interMedium,
                      fontsize: 13.sp,
                      color: Colors.grey[500]),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 10.w,
            ),
            reausableIcon(
                icon: Icons.call_rounded,
                color: ToggleThemeData.darkPurple,
                size: 26,
                ontap: onCallTap),
            SizedBox(
              width: 15.w,
            ),
            reausableIcon(
                icon: Icons.videocam,
                color: ToggleThemeData.darkPurple,
                size: 26,
                ontap: onVideoTap),
            SizedBox(
              width: 5.w,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  CommonDialog.ConfirmationDialog(
                    title: AppText.areYouSure,
                    content: AppText.doYouWantToDeleteGroup,
                    onConfirm: () {
                      // controller.deleteGroup(context, groupId: widget.groupId.toString());
                    },
                  );
                } else if (value == 'exit') {
                  CommonDialog.ConfirmationDialog(
                    title: AppText.areYouSure,
                    content: AppText.doYouWantToExitGroup,
                    onConfirm: () {
                      // controller.exitGroup(context, groupId: widget.groupId);
                    },
                  );
                }
              },
              icon: reausableIcon(
                icon: FontAwesomeIcons.ellipsis,
                color: ToggleThemeData.darkPurple,
                size: 26,
              ),
              offset: Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  height: 20.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  value: isCreator ? 'delete' : 'exit',
                  child: Row(
                    children: [
                      Icon(
                        isCreator ? Icons.delete_outline : Icons.logout,
                        size: 18,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 8),
                      reausabletext(isCreator ? 'Delete Group' : 'Exit Group',
                          fontsize: 14.sp),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 15.w,
            ),
          ],
        )
      ],
    );
  }
}



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

class ThemePicker {
  static void show(
      BuildContext context, MessageController controller, String userId) {
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
