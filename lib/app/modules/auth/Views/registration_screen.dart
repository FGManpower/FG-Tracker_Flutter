import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/Auth_widget.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../Core/util/validator.dart';
import '../../../config/themes_data.dart';
import '../../../routes/app_pages.dart';
import '../Controller/RegisterController.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  Widget buildGender(
      {required String title, required String value, bool divider = true}) {
    return Column(
      children: [
        Obx(() => RadioListTile<String>(
              title: reausabletext(title, fontsize: 14.sp),
              value: value,
              groupValue: controller.gender.value,
              onChanged: (String? newValue) {
                controller.gender.value = newValue!;
              },
            )),
        divider
            ? Divider(color: Colors.black12.withOpacity(0.1), height: 1.h)
            : SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.registerationBg.path),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
            child: Form(
              key: controller.registerKey,
              child: SingleChildScrollView(
                  child: Stack(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 15.w, right: 15.w, top: 140.h),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 50.h, bottom: 30.h, left: 15.w, right: 15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 40.h),
                              inputField(
                                context,
                                title: "User Name",
                                maxLength: 50,
                                maxLines: 1,
                                hintname: "Enter User Name",
                                textctr: controller.nameController,
                                prefixicon: Icons.person,
                                validators: (value) => Validator.validate(
                                    value: value, title: "User Name"),
                              ),
                              SizedBox(height: 15.h),
                              inputField(
                                context,
                                enable: false,
                                title: "Contact Number",
                                maxLength: 50,
                                maxLines: 1,
                                hintname: "Enter Contact Number",
                                textctr: controller.phoneController,
                                prefixicon: Icons.call,
                                validators: (value) =>
                                    Validator.validatePhone(value),
                              ),
                              SizedBox(height: 15.h),
                              Card(
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controller.arguments?['type'] == "Update"
                                        ? SizedBox()
                                        : SizedBox(height: 10.h),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.w),
                                      child: reausabletext(AppText.selectGender,
                                          fontfamily: FontFamily.interSemiBold,
                                          fontsize: 15),
                                    ),
                                    buildGender(
                                        title: AppText.male, value: "male"),
                                    buildGender(
                                        title: AppText.female, value: "female"),
                                    buildGender(
                                        title: AppText.other,
                                        value: "others",
                                        divider: false),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              reausablebutton(
                                  title:
                                      controller.arguments?['type'] == "Update"
                                          ? "Update"
                                          : "Register",
                                  ontap: () {
                                    if (controller.arguments?['type'] ==
                                        "Update") {
                                      controller.updateProfile(controller);
                                    } else {
                                      controller.register(controller);
                                    }
                                  },
                                  borderradiues: 25),
                            ],
                          ),
                        )),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.h),
                        child: Column(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  ModalImage bottomNavbar = ModalImage(
                                    isImageCroppable: true,
                                    onImageSelect: (path) async {
                                      if (Utility.isNotNullEmptyOrFalse(path)) {
                                        controller.selectedImage.value = path;
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                  bottomNavbar.mainBottomSheet(context);
                                },
                                child: controller.selectedImage == ""
                                    ? controller.userData?.profileImage == null
                                        ? CircleAvatar(
                                            radius: 75.r,
                                            backgroundColor:
                                                ToggleThemeData.darkPurple,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  ToggleThemeData.white,
                                              radius: 25.r,
                                              child: reausableIcon(
                                                  icon: Icons.mode_edit_rounded,
                                                  size: 30),
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 75.r,
                                            backgroundImage: NetworkImage(
                                              "${ConstRes.aImageBaseUrl}${controller.userData.profileImage}",
                                            ),
                                            backgroundColor: Colors.grey,
                                          )
                                    : CircleAvatar(
                                        radius: 75.r,
                                        backgroundImage: Image.file(
                                          File(controller.selectedImage
                                              .toString()),
                                          fit: BoxFit.cover,
                                        ).image,
                                        backgroundColor: Colors.grey,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              )),
            ),
          )),
    );
  }
}
