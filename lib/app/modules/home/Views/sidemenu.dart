import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/logout_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/LiveStatus_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';

class Sidemenu extends StatelessWidget {
  final controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey;
  final RxString localPickedImage = ''.obs;

  Sidemenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    // Refresh backend profile data on opening drawer to get fresh status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.userData.value.userId == null) {
        controller.getProfileData();
      }
    });

    return Drawer(
      width: 280.w,
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
              physics: const BouncingScrollPhysics(),
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
    return Obx(() {
      final user = controller.userData.value;
      // Track liveLocations to reactively re-evaluate online status on socket updates
      final _ = controller.liveLocations.length;
      final bool isOnline = _isUserOnline(user);
      return Stack(
        children: [
          // Background Curved Header
          ClipPath(
            clipper: _WaveHeaderClipper(),
            child: Container(
              height: 225.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5D47F1),
                    Color(0xFF755EF7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Decorative Glow Circle
          Positioned(
            right: -25.w,
            top: 70.h,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Decorative Dot Matrix in top right
          Positioned(
            top: 36.h,
            right: 14.w,
            child: _buildDecorativeDots(),
          ),

          // User Profile Info
          Padding(
            padding: EdgeInsets.only(top: 54.h, left: 14.w, right: 12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Camera Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.Register, arguments: {
                          "type": "Update",
                          'userData': user,
                          'email': user.email ?? Global.storageServices.get(PrefConst.userEmail)?.toString() ?? "",
                          'mobNo': user.mobileNo ?? Global.storageServices.get(PrefConst.userPhone)?.toString() ?? "",
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2.5.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40.r,
                          backgroundColor: const Color(0xFFEDE9FE),
                          child: ClipOval(
                            child: Obx(
                              () => _buildAvatarImage(40.r, user.profileImage),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1.w,
                      bottom: 1.h,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _pickProfileImage(context),
                        child: Container(
                          padding: EdgeInsets.all(2.5.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 13.5.r,
                            backgroundColor: const Color(0xFF5D47F1),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 14.w),

                // Name, Phone, and Online Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Utility.isNotNullEmptyOrFalse(user.name)
                            ? user.name.toString()
                            : "divesh shinde",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontFamily.interBold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        Utility.isNotNullEmptyOrFalse(user.mobileNo)
                            ? user.mobileNo.toString()
                            : "",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13.5.sp,
                          fontFamily: FontFamily.interRegular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF00D26A)
                                  : const Color(0xFF9E9E9E),
                              shape: BoxShape.circle,
                              boxShadow: isOnline
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00D26A)
                                            .withValues(alpha: 0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isOnline ? "Online" : "Offline",
                            style: TextStyle(
                              color: isOnline
                                  ? Colors.white.withValues(alpha: 0.95)
                                  : Colors.white.withValues(alpha: 0.70),
                              fontSize: 12.5.sp,
                              fontFamily: FontFamily.interMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  bool _isUserOnline(UserData user) {
    // 1. Check UserData model from backend (/getProfile)
    if (user.isOnline != null) {
      if (user.isOnline is bool) return user.isOnline as bool;
      if (user.isOnline is num) return user.isOnline == 1;
      final s = user.isOnline.toString().toLowerCase().trim();
      if (s == '1' || s == 'true' || s == 'online') return true;
      if (s == '0' || s == 'false' || s == 'offline') return false;
    }

    // 2. Check lastSeen from backend UserData
    if (user.lastSeen != null && user.lastSeen!.isNotEmpty) {
      if (Tracking().isOnline(lastSeen: user.lastSeen, thresholdMinutes: 5)) {
        return true;
      }
    }

    // 3. Check if user is present in liveLocations from backend/socket
    final myId = user.userId ??
        int.tryParse(
            Global.storageServices.get(PrefConst.userId)?.toString() ?? '');
    if (myId != null) {
      final member = controller.liveLocations.firstWhereOrNull(
        (m) => m.userId == myId,
      );
      if (member != null) {
        return member.isOnline;
      }

      // 4. Check LivesStatusController if loaded
      if (Get.isRegistered<LivesStatusController>()) {
        final groupMember = LivesStatusController.instance.memberData
            .firstWhereOrNull((m) => m.userId == myId);
        if (groupMember != null) {
          return groupMember.isOnline == 1;
        }
      }
    }

    // 5. Fallback to socket connection status
    return SocketDashboardService.instance.isConnected;
  }

  void _pickProfileImage(BuildContext context) {
    ModalImage bottomNavbar = ModalImage(
      isImageCroppable: true,
      onImageSelect: (path) async {
        if (Utility.isNotNullEmptyOrFalse(path)) {
          Navigator.pop(context); // Close "Choose an Option" bottom sheet
          localPickedImage.value = path;
          await _uploadProfileImage(context, path);
        }
      },
    );
    bottomNavbar.mainBottomSheet(context);
  }

  Future<void> _uploadProfileImage(BuildContext context, String path) async {
    try {
      Loading().showloading();
      final user = controller.userData.value;
      final Map<String, dynamic> formMap = {
        'Name': Utility.isNotNullEmptyOrFalse(user.name) ? user.name : 'User',
        'Gender':
            Utility.isNotNullEmptyOrFalse(user.gender) ? user.gender : 'Male',
      };
      if (Utility.isNotNullEmptyOrFalse(user.email)) {
        formMap['Email'] = user.email;
        formMap['email'] = user.email;
      } else {
        final savedEmail = Global.storageServices.get(PrefConst.userEmail)?.toString();
        if (Utility.isNotNullEmptyOrFalse(savedEmail)) {
          formMap['Email'] = savedEmail;
          formMap['email'] = savedEmail;
        }
      }
      formMap['ProfileImage'] = await dio.MultipartFile.fromFile(
        path,
        filename: path.split(Platform.isWindows ? r'\' : '/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      final dio.FormData data = dio.FormData.fromMap(formMap);
      final response = await HttpUtil().Authpost(
        Urls.updateProfile,
        formdata: data,
        type: "formdata",
      );

      Loading().dismissloading();
      final commonResponse = CommonResponse.fromJson(response);
      if (commonResponse.status == true) {
        await controller.getProfileData();
        if (controller.userData.value.profileImage != null) {
          Global.storageServices.setString(
            PrefConst.profileImage,
            controller.userData.value.profileImage!,
          );
        }
        Utils().fluttertoast(
          commonResponse.message ?? "Profile image updated successfully",
        );
      } else {
        localPickedImage.value = '';
        CommonDialog.errorMessage(
          commonResponse.message ?? "Failed to update profile image",
        );
      }
    } catch (e) {
      Loading().dismissloading();
      localPickedImage.value = '';
      CommonDialog.errorMessage(e.toString());
    }
  }

  Widget _buildAvatarImage(double radius, String? profileImage) {
    if (localPickedImage.isNotEmpty &&
        File(localPickedImage.value).existsSync()) {
      return Image.file(
        File(localPickedImage.value),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
      );
    }
    if (Utility.isNotNullEmptyOrFalse(profileImage)) {
      return Image.network(
        "${ConstRes.aImageBaseUrl}$profileImage",
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(radius),
      );
    }
    return _defaultAvatar(radius);
  }

  Widget _defaultAvatar(double radius) {
    return Assets.images.userAvatar.image(
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(
        Icons.person,
        size: radius * 1.1,
        color: const Color(0xFF5D47F1),
      ),
    );
  }

  Widget _buildDecorativeDots() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(6, (col) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                width: 3.5.w,
                height: 3.5.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDrawerItem(
            icon: Icons.person_rounded,
            title: AppText.editProfile.tr,
            subtitle: "Update your information",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.Register, arguments: {
                "type": "Update",
                'userData': controller.userData.value,
                'email': controller.userData.value.email ?? Global.storageServices.get(PrefConst.userEmail)?.toString() ?? "",
                'mobNo': controller.userData.value.mobileNo ?? Global.storageServices.get(PrefConst.userPhone)?.toString() ?? "",
              });
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.info_rounded,
            title: AppText.aboutUs.tr,
            subtitle: "Know more about us",
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.AboutUs);
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.verified_user_rounded,
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
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.headset_mic_rounded,
            title: "Help & Support",
            subtitle: "Get help and support",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDivider(),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
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

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: const Divider(
        color: Color(0xFFF0ECFC),
        height: 1,
        thickness: 1,
      ),
    );
  }

  Widget _buildBottomAppCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FE),
        borderRadius: BorderRadius.circular(22.r),
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
                  color: const Color(0xFF5D47F1).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundColor: const Color(0xFF5D47F1),
              backgroundImage: AssetImage(Assets.icons.appIcon.path),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FG Tracker",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E202B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  "Stay connected,\nStay together.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF7A7F93),
                    height: 1.35,
                  ),
                  maxLines: 2,
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
      padding: EdgeInsets.only(bottom: 16.h, top: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Follow us on",
            style: TextStyle(
              fontSize: 11.5.sp,
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF8C8E9D),
            ),
          ),
          SizedBox(height: 10.h),
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
          SizedBox(height: 12.h),
          Text(
            "v 1.0.0",
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: FontFamily.interRegular,
              color: const Color(0xFF8C8E9D),
            ),
          ),
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
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: const Color(0xFF5D47F1), size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interRegular,
                      color: const Color(0xFF7A7F93),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF7E69F7),
              size: 24.sp,
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 40.w,
        height: 40.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 18.w,
          height: 18.w,
          colorFilter:
              const ColorFilter.mode(Color(0xFF5D47F1), BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 25);

    final firstControl = Offset(size.width * 0.40, size.height + 15);
    final midPoint = Offset(size.width * 0.65, size.height - 20);
    path.quadraticBezierTo(
        firstControl.dx, firstControl.dy, midPoint.dx, midPoint.dy);

    final secondControl = Offset(size.width * 0.85, size.height - 55);
    final endPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
        secondControl.dx, secondControl.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

