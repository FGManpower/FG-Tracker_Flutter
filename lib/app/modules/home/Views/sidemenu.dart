import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/logout_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/modules/home/Home_Widget/Home_widget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Sidemenu extends StatelessWidget {
  final controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey;

  Sidemenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290.w,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          buildHeader(context),
          Expanded(child: _buildMenuItems(context)),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _HeaderClipper(),
          child: Container(
            height: 210.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A3FFF), Color(0xFF7F63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 55.h, left: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48.r,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: CircleAvatar(
                  radius: 45.r,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    Utility.isNotNullEmptyOrFalse(
                            controller.userData.value.profileImage)
                        ? "${ConstRes.aImageBaseUrl}${controller.userData.value.profileImage}"
                        : MyAppTheme.ProfilenotFoundImg,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      controller.userData.value.name ?? "User Name",
                      fontsize: 22.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                      maxline: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                    reausabletext(
                      controller.userData.value.mobileNo ?? "",
                      fontsize: 15.sp,
                      fontfamily: FontFamily.interRegular,
                      color: Colors.white70,
                      maxline: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusablelistItem(
            name: AppText.editProfile.tr,
            imagename: Assets.svg.profile,
            height: 25,
            width: 25,
            func: () {
              Navigator.pop(context);

              Get.toNamed(Routes.Register, arguments: {
                "type": "Update",
                'userData': controller.userData.value
              });
            }),
        ReusablelistItem(
            name: AppText.aboutUs.tr,
            imagename: Assets.svg.about,
            height: 25,
            width: 25,
            func: () {
              Navigator.pop(context);
              Get.toNamed(Routes.AboutUs);
            }),
        ReusablelistItem(
          name: AppText.logOut.tr,
          imagename: Assets.svg.logout,
          height: 20,
          width: 20,
          func: () {
            CommonDialog.ConfirmationDialog(
              title: AppText.logOut.tr,
              content: AppText.doYouReallyWantLogout.tr,
              confirm: AppText.confirm.tr,
              cancel: AppText.cancel.tr,
              icon: Icons.logout,
              onConfirm: () {
                Navigator.pop(ContextUtility.context!); // Close dialog
                Navigator.pop(context); // Close Drawer or current screen
                logOutController().logOutUser(); // Perform logout
              },
              onCancel: () {
                Navigator.pop(ContextUtility.context!); // Just close the dialog
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: AssetImage(Assets.icons.appIcon.path),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              Social_Icon(
                  imagename: Assets.svg.facebook, url: AppText.facebookUrl),
              Social_Icon(
                  imagename: Assets.svg.instagram, url: AppText.instagramUrl),
              Social_Icon(
                  imagename: Assets.svg.twitter, url: AppText.twitterUrl),
              Social_Icon(
                  imagename: Assets.svg.youtube, url: AppText.youtubeUrl),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===================== CUSTOM CLIPPER =====================
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
