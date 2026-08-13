import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImageUrl;
  final String userName;
  final String groupName;
  final MessageController controller;
  final VoidCallback? onBackTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onUpdateGroupName;
  final VoidCallback? onDeleteMember;
  final VoidCallback? onVideoTap;
  final VoidCallback? onGroupExit;
  final VoidCallback? onDeleteGroup;
  final bool isOnline;
  final VoidCallback? onSearchTap;
  final bool isGroupChat;

  final String? lastSeen;

  CommonChatAppBar(
      {Key? key,
        required this.profileImageUrl,
        required this.userName,
        required this.controller,
        this.onBackTap,
        this.onCallTap,
        this.onVideoTap,
        this.onUpdateGroupName,
        this.onDeleteMember,
        required this.groupName,
        this.onGroupExit,
        required this.isOnline,
        this.lastSeen,
        this.onDeleteGroup,
        this.onSearchTap,
        this.isGroupChat = false})
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
                          color: isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5.w,
                          ),
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
        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
              // PopupMenuButton<String>(
              //         onSelected: (value) {},
              //         color: Colors.white,
              //         elevation: 5,
              //         offset: Offset(0, 48),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12.r),
              //         ),
              //         icon: Icon(
              //           FontAwesomeIcons.ellipsis,
              //           color: ToggleThemeData.darkPurple,
              //           size: 26.sp,
              //         ),
              //         itemBuilder: (context) => [
              //           popupItem(
              //             context: context,
              //             value: 'exit',
              //             icon: Icons.logout,
              //             text: 'Exit Group',
              //             onTap: () {
              //               onGroupExit!();
              //             },
              //           ),
              //         ],
              //       ),
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
              //   if (isCreator)



              Builder(
                builder: (context) {
                  if (isGroupChat && controller.isCreator == true) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30.r),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius:
                                      BorderRadius.circular(20.r),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    "Group Actions",
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Manage your group settings",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  actionTile(
                                    icon: Icons.search,
                                    iconColor: Colors.blueAccent,
                                    title: "Search Messages",
                                    subtitle: "Find messages by keyword",
                                    onTap: () {
                                      Navigator.pop(context);
                                      onSearchTap?.call();
                                    },
                                  ),
                                  SizedBox(height: 12.h),
                                  actionTile(
                                    icon: Icons.edit_rounded,
                                    iconColor: ToggleThemeData.darkPurple,
                                    title: "Update Group ",
                                    subtitle:
                                    "Change the current group detail",
                                    onTap: () {
                                      Navigator.pop(context);
                                      onUpdateGroupName?.call();
                                    },
                                  ),
                                  SizedBox(height: 12.h),
                                  actionTile(
                                    icon: Icons.person_remove_rounded,
                                    iconColor: Colors.red,
                                    title: "Delete Member",
                                    subtitle:
                                    "Remove a member from this group",
                                    onTap: () {
                                      Navigator.pop(context);
                                      onDeleteMember?.call();
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: reausablebutton(
                                      title: "Cancel",
                                      ontap: () => Navigator.pop(context),
                                      height: 52,
                                      borderradiues: 50,
                                      backgroundColor:
                                      ToggleThemeData.darkPurple,
                                      textcolor: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.more_vert,
                        color: ToggleThemeData.darkPurple,
                        size: 26.sp,
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30.r),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius:
                                    BorderRadius.circular(20.r),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  "Chat Actions",
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "Manage your chat",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                actionTile(
                                  icon: Icons.search,
                                  iconColor: Colors.blueAccent,
                                  title: "Search Messages",
                                  subtitle: "Find messages by keyword",
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSearchTap?.call();
                                  },
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: reausablebutton(
                                    title: "Cancel",
                                    ontap: () => Navigator.pop(context),
                                    height: 52,
                                    borderradiues: 50,
                                    backgroundColor:
                                    ToggleThemeData.darkPurple,
                                    textcolor: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: ToggleThemeData.darkPurple,
                      size: 26.sp,
                    ),
                  );
                },
              ),

              SizedBox(
                width: 15.w,
              ),
            ],
          ),
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

Widget actionTile({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: BoxBorder.all(color: Colors.grey.shade200)),
    child: InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                icon,
                color: iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    ),
  );
}