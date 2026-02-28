import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Track/Widget/TrackLAppBar.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImageUrl;
  final String userName;
  final String groupName;
  final bool isCreator;
  final VoidCallback? onBackTap;
  final VoidCallback? onCallTap;

  final VoidCallback? onVideoTap;
  final VoidCallback? onGroupExit;
  final VoidCallback? onDeleteGroup;

  CommonChatAppBar(
      {Key? key,
      required this.profileImageUrl,
      required this.userName,
      required this.isCreator,
      this.onBackTap,
      this.onCallTap,
      this.onVideoTap,
      required this.groupName,
      this.onGroupExit,this.onDeleteGroup})
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
              reausableIcon(
                icon: Icons.arrow_back_ios,
                size: 25,
                ontap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 5.w,
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
                      widths: 130,
                      fontfamily: FontFamily.interSemiBold),
                  reausabletext(groupName,
                      fontfamily: FontFamily.interMedium,
                      fontsize: 13.sp,
                      widths: 125,
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
            // isCreator == true
            //     ?
            PopupMenuButton<String>(
                    onSelected: (value) {},
                    color: Colors.white,
                    elevation: 5,
                    offset: Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    icon: Icon(
                      FontAwesomeIcons.ellipsis,
                      color: ToggleThemeData.darkPurple,
                      size: 26.sp,
                    ),
                    itemBuilder: (context) => [
                      popupItem(
                        context: context,
                        value: 'exit',
                        icon: Icons.logout,
                        text: 'Exit Group',
                        onTap: () {
                          onGroupExit!();
                        },
                      ),
                    ],
                  ),
                // : PopupMenuButton<String>(
                //     onSelected: (value) {},
                //     color: Colors.white,
                //     elevation: 5,
                //     offset: Offset(0, 48),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12.r),
                //     ),
                //     icon: Icon(
                //       Icons.more_vert,
                //       color: ToggleThemeData.darkPurple,
                //       size: 26.sp,
                //     ),
                //     itemBuilder: (context) => [
                //       popupItem(
                //         context: context,
                //         value: 'delete',
                //         icon: Icons.delete_outline,
                //         text: 'Group Delete',
                //         onTap: onDeleteGroup
                //       ),
                //     ],
                //   ),
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
