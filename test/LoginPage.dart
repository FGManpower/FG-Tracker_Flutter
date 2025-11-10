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


    return Obx(() => Scaffold(
        backgroundColor: Colors.white,
        // appBar: reusableAppbar(controller.arguments?['type']  == "Update"?"Profile":"Register",
        //     ontap: () {
        //       final type = controller.arguments?['type'];
        //       if (type == "Update") {
        //
        //         Get.offAllNamed(Routes.Home_Screen);
        //       } else {
        //
        //         Get.toNamed(Routes.Login);
        //       }
        //     }),
        body:
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.registerationBg.path),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child:       Form(
            key: controller.registerKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),

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
                        radius: 60.r,
                        backgroundImage: NetworkImage(
                            MyAppTheme.ProfilenotFoundImg.toString()),
                        backgroundColor: Colors.black,
                      )
                          : CircleAvatar(
                        radius: 60.r,
                        backgroundImage: NetworkImage(
                          "${ConstRes.aImageBaseUrl}${controller.userData.profileImage}",
                        ),
                        backgroundColor: Colors.black,
                      )
                          : CircleAvatar(
                        radius: 60.r,
                        backgroundImage: Image.file(
                          File(controller.selectedImage.toString()),
                          fit: BoxFit.cover,
                        ).image,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),
                  Center(
                    child: reausabletext(
                        controller.arguments?['type'] == "Update"
                            ? AppText.updteYourAccnt
                            : AppText.createYourAccnt,
                        align: TextAlign.start,
                        fontsize: 20.sp,
                        fontweight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  controller.arguments?['type'] == "Update"
                      ? SizedBox()
                      : Center(
                    child: reausabletext(AppText.plsCreateYourAccnt,
                        color: Colors.grey.shade700,
                        fontsize: 14.sp,
                        align: TextAlign.center),
                  ),
                  SizedBox(height: 40.h),
                  CustomTextField(
                    hint: AppText.fullName,
                    controller: controller.nameController,

                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SvgPicture.asset(Assets.svg.person,
                          width: 20.w, height: 20.h),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    isEnable: false,
                    hint: AppText.phoneNumber,
                    controller: controller.phoneController,
                    maxLength: 10,
                    prefixIcon: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 12.0),
                      child: SvgPicture.asset(Assets.svg.call,
                          width: 20.w, height: 20.h),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  controller.arguments?['type'] == "Update"
                      ? SizedBox()
                      : SizedBox(height: 10.h),

                  SizedBox(height: 15.h),
                  reausabletext(AppText.selectGender,
                      fontfamily: FontFamily.interMedium, fontsize: 14),
                  SizedBox(height: 5.h),
                  Card(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildGender(title: AppText.male, value: "male"),
                        buildGender(title: AppText.female, value: "female"),
                        buildGender(
                            title: AppText.other, value: "others", divider: false),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  reausablebutton(
                      title:  controller.arguments?['type'] == "Update"
                          ?"Update":"Register",
                      ontap: (){
                        if(controller.arguments?['type'] == "Update"){
                          controller.updateProfile(controller);
                        }else{
                          controller.register(controller);
                        }


                      },
                      borderradiues: 4
                  ),
                  SizedBox(height: 20.h),
                  controller.arguments?['type'] == "Update"
                      ? SizedBox()
                      : Row(
                    children: [
                      Checkbox(
                        value: controller.isChecked.value,
                        onChanged: (value) {
                          controller.isChecked.value = value!;
                        },
                      ),
                      Expanded(
                        child: reausabletext(
                            AppText.byClickingRegisterBtn,
                            fontsize: 12.sp),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
        )

    ),);
  }
}
