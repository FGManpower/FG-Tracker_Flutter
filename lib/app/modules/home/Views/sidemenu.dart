import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/logout_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class Sidemenu extends StatelessWidget {
  final controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey;

  Sidemenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310.w,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItems(context),
                  _buildBottomAppCard(),
                ],
              ),
            ),
          ),
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: _WaveHeaderClipper(),
          child: Container(
            height: 230.h,
            width: double.infinity,
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
          padding: EdgeInsets.only(top: 60.h, left: 20.w, right: 15.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                    child: CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      backgroundImage: NetworkImage(
                        Utility.isNotNullEmptyOrFalse(
                                controller.userData.value.profileImage)
                            ? "${ConstRes.aImageBaseUrl}${controller.userData.value.profileImage}"
                            : MyAppTheme.ProfilenotFoundImg,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    reausabletext(
                      controller.userData.value.name ?? "User Name",
                      fontsize: 18.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                      maxline: 1,
                      textoverflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      controller.userData.value.mobileNo ?? "",
                      fontsize: 14.sp,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: AppText.editProfile.tr,
            subtitle: "Update your information",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.Register, arguments: {
                "type": "Update",
                'userData': controller.userData.value
              });
            },
          ),
          _divider(),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: AppText.aboutUs.tr,
            subtitle: "Know more about us",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.AboutUs);
            },
          ),
          _divider(),
          _buildDrawerItem(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            subtitle: "View our privacy policy",
            onTap: () async {
              Navigator.pop(context);
              try {
                final Uri url =
                    Uri.parse('https://www.fgmanpower.co.in/privacy-policy/');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  debugPrint('Could not launch $url');
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),
          _divider(),
          _buildDrawerItem(
            icon: Icons.headset_mic_outlined,
            title: "Help & Support",
            subtitle: "Get help and support",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _divider(),
          _buildDrawerItem(
            icon: Icons.logout_outlined,
            title: AppText.logOut.tr,
            subtitle: "Sign out from the app",
            onTap: () {
              CommonDialog.ConfirmationDialog(
                title: AppText.logOut.tr,
                content: AppText.doYouReallyWantLogout.tr,
                confirm: AppText.confirm.tr,
                cancel: AppText.cancel.tr,
                icon: Icons.logout,
                onConfirm: () {
                  Navigator.pop(ContextUtility.context!);
                  Navigator.pop(context);
                  logOutController().logOutUser();
                },
                onCancel: () {
                  Navigator.pop(ContextUtility.context!);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2FF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF6B4DFF).withValues(alpha: 0.2),
                    blurRadius: 10)
              ],
            ),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: const Color(0xFF6B4DFF),
              backgroundImage: AssetImage(Assets.icons.appIcon.path),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  "FG Tracker",
                  fontsize: 16.sp,
                  fontfamily: FontFamily.interBold,
                  color: const Color(0xFF1F1F39),
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "Stay connected,\nStay together.",
                  fontsize: 12.sp,
                  fontfamily: FontFamily.interRegular,
                  color: Colors.grey,
                  maxline: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, top: 4.h), // pehle 30.h tha
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          reausabletext(
            "Follow us on",
            fontsize: 11.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCustomSocialIcon(Assets.svg.facebook, AppText.facebookUrl),
              SizedBox(width: 12.w),
              _buildCustomSocialIcon(
                  Assets.svg.instagram, AppText.instagramUrl),
              SizedBox(width: 12.w),
              _buildCustomSocialIcon(Assets.svg.twitter, AppText.twitterUrl),
              SizedBox(width: 12.w),
              _buildCustomSocialIcon(Assets.svg.youtube, AppText.youtubeUrl),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2FF),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(icon, color: const Color(0xFF6B4DFF), size: 22.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    title,
                    fontsize: 15.sp,
                    fontfamily: FontFamily.interBold,
                    color: const Color(0xFF1F1F39),
                  ),
                  SizedBox(height: 3.h),
                  reausabletext(
                    subtitle,
                    fontsize: 12.sp,
                    fontfamily: FontFamily.interRegular,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: const Color(0xFF6B4DFF), size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.withValues(alpha: 0.15),
      thickness: 1,
      height: 10.h,
      indent: 15.w,
      endIndent: 15.w,
    );
  }

  Widget _buildCustomSocialIcon(String iconPath, String url) {
    return InkWell(
      onTap: () async {
        try {
          final Uri uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            debugPrint('Could not launch $url');
          }
        } catch (e) {
          log(e.toString());
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: const BoxDecoration(
          color: Color(0xFFF4F2FF),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 20.w,
          height: 20.w,
          colorFilter:
              const ColorFilter.mode(Color(0xFF6B4DFF), BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width * 0.35, size.height + 20);
    var firstEndPoint = Offset(size.width * 0.65, size.height - 40);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.85, size.height - 85);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
