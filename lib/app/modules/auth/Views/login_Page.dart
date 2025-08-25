import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/Auth_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

class LoginPage extends GetView<Login_Controller> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
        child: reausablebutton(
          title: AppText.login,
          ontap: () {
            controller.login();
          },
          borderradiues: 4.r,
        ),
      ),
      body: Stack(
        children: [
          ClipPath(
            clipper: CustomHeaderWaveClipper(),
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50.h,
            left: 16.w,
            right: 10.w,
            child: Row(
              children: [
                SizedBox(width: 8.w),
                Text(
                  AppText.login,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 200.h, left: 20.w, right: 20.w),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(Assets.images.appicon.path,
                  // child: Image.asset('assets/images/app_icon.png',
                      fit: BoxFit.cover),
                ),
                SizedBox(height: 20.h),
                reausabletext(
                  AppText.welcomeBack,color: Colors.black,
                  fontsize: 31,
                  fontfamily: FontFamily.interBold,
                ),
                SizedBox(height: 5.h),
                reausabletext(
                  AppText.wereGladToseeYouAgain,
                  align: TextAlign.center,
                  fontsize: 13,
                  color: Colors.grey,
                ),
                SizedBox(height: 30.h),
                Form(
                  key: controller.loginKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 0.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            CountryCodePicker(
                              onChanged: (country) {
                                controller.selectedDialCode = country.dialCode ?? '+91';
                              },
                              initialSelection: 'IN',
                              favorite: ['+91', 'IN'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              flagWidth: 20.sp,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                color: ToggleThemeData.black,
                              ),
                            ),
                            Container(
                              height: 30.h,
                              width: 1.w,
                              color: Colors.black,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child:
                              TextFormField(
                                focusNode: controller.phoneFocusNode,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                                  style: TextStyle(

                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.interMedium,
                                ),
                                controller: controller.mobNoController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,

                                maxLength: 18,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: 'Enter Mobile Number',
                                ),
                                  onFieldSubmitted: (_) {
                                    controller.phoneFocusNode.unfocus();
                                  }
                              ),
                            ),
                          ],
                        ),

                      ),
                      Obx(() => controller.mobileErrorText.value.isNotEmpty
                          ? Padding(
                        padding: EdgeInsets.only(top: 4.h, left: 8.w),
                        child: reausabletext(
                          controller.mobileErrorText.value,

                            color: Colors.red,
                            fontsize: 12.sp,

                        ),
                      )
                          : SizedBox.shrink()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
