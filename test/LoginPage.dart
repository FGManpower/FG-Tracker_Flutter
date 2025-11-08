import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

class LoginPage extends GetView<Login_Controller> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: Stack(
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
                    // Location icons now safely clipped
                    Positioned(
                      right: 10.w, // fine-tune these values
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

                    // Logo + text
                    Padding(
                      padding: EdgeInsets.only(top: 80.h, left: 24.w, right: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32.r,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                AssetImage(Assets.images.appIcon.path),
                              ),
                              SizedBox(width: 12.w),
                              reausabletext(
                                "Welcome Back",
                                color: Colors.white,
                                fontsize: 28,
                                fontfamily: FontFamily.interBold,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          reausabletext(
                            "We’re glad to see you again. Log in to access your account and explore our latest features.",
                            color: Colors.white70,
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



            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                child: Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
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
                        fontsize: 18,
                        fontfamily: FontFamily.interSemiBold,
                      ),
                      SizedBox(height: 16.h),


                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F6FF),
                          borderRadius: BorderRadius.circular(40.r),
                          border: Border.all(
                            color: AppColors.darkBlue,
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
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              flagWidth: 22.sp,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              height: 24.h,
                              width: 1.w,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.phone,
                              color: AppColors.darkBlue,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextFormField(
                                focusNode: controller.phoneFocusNode,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: controller.mobNoController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.darkBlue,
                                  fontFamily: FontFamily.interMedium,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: 'Enter Mobile Number',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF8B7AE8),
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  controller.phoneFocusNode.unfocus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                            () => controller.mobileErrorText.value.isNotEmpty
                            ? Padding(
                          padding:
                          EdgeInsets.only(top: 4.h, left: 8.w),
                          child: reausabletext(
                            controller.mobileErrorText.value,
                            color: Colors.red,
                            fontsize: 12.sp,
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 25.h),


                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            elevation: 4,
                          ),
                          onPressed: controller.login,
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontFamily: FontFamily.interSemiBold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CurvedDiagonalClipper extends CustomClipper<Path> {
  // You can adjust this factor to control the 'cut' position and curve height.
  final double cutHeightFactor;

  CurvedDiagonalClipper({this.cutHeightFactor = 0.5});

  @override
  Path getClip(Size size) {
    // 1. Start the path from the top-left corner
    Path path = Path();
    path.lineTo(0.0, size.height);

    // 2. Define the starting point of the curve (bottom-left)
    double curveStartPointX = 0;
    double curveStartPointY = size.height * cutHeightFactor; // Adjust 0.5 for different curve height

    // 3. Define the control point for the curve (this controls the arc's depth)
    // Here we make the control point just slightly below the curveStartPointY
    double controlPointX = size.width / 4;
    double controlPointY = size.height * cutHeightFactor + 40; // Makes the curve dip down

    // 4. Define the end point of the curve (top-right diagonal part)
    double curveEndPointX = size.width;
    double curveEndPointY = size.height * cutHeightFactor - 80;

    // 5. Draw the quadratic Bezier curve
    path.quadraticBezierTo(
      controlPointX,
      controlPointY,
      curveEndPointX,
      curveEndPointY,
    );

    // 6. Complete the path to the top-right and then top-left corner
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


