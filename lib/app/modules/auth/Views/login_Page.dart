import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Curve/Login_Curve.dart';
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
      body: Stack(
        children: [
          ClipPath(
            clipper: CurvedDiagonalClipper(cutHeightFactor: 0.8),
            child: Container(
              height: 360.h,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B3FDD), Color(0xFF7E6FF3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    right: 10.w,
                    bottom: 160.h,
                    child: Icon(
                      Icons.location_on,
                      size: 70.sp,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    bottom: 20.h,
                    child: Icon(
                      Icons.location_on,
                      size: 50.sp,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  Positioned(
                    left: 40.w,
                    bottom: 50.h,
                    child: Icon(
                      Icons.location_on,
                      size: 130.sp,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.only(top: 80.h, left: 15.w, right: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 48.r,
                              backgroundColor: Colors.white,
                              backgroundImage:
                              AssetImage(Assets.icons.appIcon.path),
                            ),
                            SizedBox(width: 12.w),
                            reausabletext(
                              "Welcome Back",
                              color: Colors.white,
                              fontsize: 32,
                              fontfamily: FontFamily.interBold,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        reausabletext(
                          "We’re glad to see you again. Log in to access your account and explore our latest features.",
                          color: ToggleThemeData.white,
                          fontsize: 14,
                          align: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 370.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reausabletext(
                      "Log In Details",
                      color: Colors.black,
                      fontsize: 15,
                      fontfamily: FontFamily.interMedium,
                    ),
                    SizedBox(height: 16.h),

                    Form(
                      key: controller.loginKey,
                      child: Column(
                        children: [
                          Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                EdgeInsets.symmetric(vertical: 0.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F6FF),
                                  borderRadius: BorderRadius.circular(40.r),
                                  border: Border.all(
                                    color: controller.mobileErrorText.value
                                        .isEmpty
                                        ? ToggleThemeData.darkPurple
                                        : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (country) {
                                        controller.selectedDialCode =
                                            country.dialCode ?? '+91';
                                      },
                                      initialSelection: 'IN',
                                      favorite: ['+91', 'IN'],
                                      flagWidth: 20.sp,
                                      textStyle: TextStyle(
                                        fontSize: 14.sp,
                                        color: ToggleThemeData.darkPurple,
                                      ),
                                    ),
                                    Container(
                                      height: 30.h,
                                      width: 1.w,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: TextFormField(
                                        focusNode:
                                        controller.phoneFocusNode,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly
                                        ],
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily:
                                          FontFamily.interMedium,
                                        ),
                                        controller:
                                        controller.mobNoController,
                                        keyboardType:
                                        TextInputType.phone,
                                        textInputAction:
                                        TextInputAction.done,
                                        maxLength: 18,
                                        decoration: InputDecoration(
                                          counterText: '',
                                          border: InputBorder.none,
                                          hintText: 'Enter Mobile Number',
                                          hintStyle: TextStyle(
                                            fontSize: 14.sp,
                                            color: ToggleThemeData
                                                .darkPurple,
                                          ),
                                        ),
                                        onChanged: (_) {
                                          controller.mobileErrorText.value =
                                          '';
                                        },
                                        onFieldSubmitted: (_) {
                                          controller.phoneFocusNode
                                              .unfocus();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration:
                                const Duration(milliseconds: 250),
                                child: controller.mobileErrorText.value
                                    .isNotEmpty
                                    ? Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.w, top: 6.h),
                                  child: Text(
                                    controller.mobileErrorText.value,
                                    key: ValueKey(controller
                                        .mobileErrorText.value),
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                      fontFamily: FontFamily
                                          .interMedium,
                                    ),
                                  ),
                                )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          )),
                          SizedBox(height: 20.h),

                          reausablebutton(
                            title: AppText.login,
                            ontap: () {
                              controller.login();
                            },
                            borderradiues: 25.r,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
