import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Sidemenu extends StatelessWidget {
  final controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> scaffoldKey;

  Sidemenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Drawer(
          width: 280.w,
          backgroundColor: context.isDarkMode
              ? ToggleThemeData.darkThemeBackground
              : ToggleThemeData.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
            ),
          ),
          child: NavigationBarUi(context)),
    );
  }

  Widget NavigationBarUi(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              Header(),
              Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0.w, top: 15.h),
                    child: Column(
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
                          height: 25,
                          width: 25,
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
                                LogoutUser().logout(); // Perform logout
                              },
                              onCancel: () {
                                Navigator.pop(ContextUtility.context!); // Just close the dialog
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  )),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 10.w, top: 10.h, bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Padding(
                      padding: EdgeInsets.only(right: 15, top: 3.h),
                      child: CircleAvatar(
                        radius: 32.r,
                        backgroundImage: AssetImage(Assets.icons.appIcon.path),
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          reausabletext(AppText.appName,
                              fontfamily: FontFamily.interBold, fontsize: 20),
                          SizedBox(
                            width: 7.h,
                          ),
                          reausabletext(Constant.CurrentVersion,
                              fontfamily: FontFamily.interRegular,
                              fontsize: 11),
                        ],
                      ),
                      Row(
                        children: [
                          Social_Icon(
                              imagename: Assets.svg.facebook,
                              url: AppText.facebookUrl),
                          Social_Icon(
                              imagename: Assets.svg.instagram,
                              url: AppText.instagramUrl),
                          Social_Icon(
                              imagename: Assets.svg.twitter,
                              url: AppText.twitterUrl),
                          Social_Icon(
                              imagename: Assets.svg.youtube,
                              url: AppText.youtubeUrl),
                        ],
                      )
                    ],
                  )
                ])
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget Header() {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ToggleThemeData.Appcolor,
              ToggleThemeData.Appcolor,
              ToggleThemeData.Appcolor,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 25.w, top: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 43.r,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        Utility.isNotNullEmptyOrFalse(
                                controller.userData.value.profileImage)
                            ? "${Constant.ImagebaseUrl}${controller.userData.value.profileImage}"
                            : MyAppTheme.ProfilenotFoundImg,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reausabletext(controller.userData.value.name ?? "",
                              widths: 150,
                              height: 1.1,
                              textoverflow: TextOverflow.ellipsis,
                              fontsize: 25,
                              maxline: 2,
                              fontfamily: FontFamily.interBold,
                              color: Colors.white),
                          reausabletext(
                              widths: 150,
                              textoverflow: TextOverflow.ellipsis,
                              maxline: 1,
                              controller.userData.value.mobileNo ?? "",
                              fontsize: 16,
                              fontfamily: FontFamily.interRegular,
                              color: Colors.white),
                        ],
                      ))
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ));
  }

  Widget ReusablelistItem(
      {String? name,
      required String imagename,
      void Function()? func,
      int height = 25,
      int width = 25}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: InkWell(
          onTap: func,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      imagename,
                      height: height.h,
                      width: width.w,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    reausabletext(
                      name.toString(),
                      fontfamily: FontFamily.interRegular,
                      fontsize: 16,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Divider(
                color: Colors.black12,
                thickness: 1,
              ),
            ],
          )),
    );
  }

  Widget Social_Icon({required String imagename, required String url}) {
    return InkWell(
      onTap: () {
        launch(url);
      },
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: SvgPicture.asset(
          imagename,
          height: 25.h,
          width: 25.w,
          color: Colors.black,
        ),
      ),
    );
  }
}
