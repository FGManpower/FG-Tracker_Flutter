import 'package:fgtracker/app/Core/values/Curve/Login_Curve.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/OtpController.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends GetView<OtpController> {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final String mobileNumber = args["mobNo"];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            clipper: CurvedDiagonalClipper(cutHeightFactor: 0.8),
            child: Container(
              height: 360.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B3FDD), Color(0xFF7E6FF3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 40.w,
                    bottom: 50.h,
                    child: Icon(
                      Icons.lock_outline,
                      size: 130.sp,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 80.h, left: 20.w, right: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          "OTP Verification",
                          color: Colors.white,
                          fontsize: 33,
                          fontfamily: FontFamily.interBold,
                        ),
                        SizedBox(height: 12.h),
                        reausabletext(
                          "Please verify your identity by entering the One-Time Password (OTP) sent to your registered mobile number.",
                          color: ToggleThemeData.white,
                          fontsize: 14,
                          align: TextAlign.start,
                          fontfamily: FontFamily.interRegular,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 360.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
              child: Column(
                children: [
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text:
                            "Please enter the 4-digit code sent to your mobile number ",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                              fontFamily: FontFamily.interRegular,
                            ),
                            children: [
                              TextSpan(
                                text: "+$mobileNumber",
                                style: TextStyle(
                                  color: ToggleThemeData.Appcolor,
                                  fontSize: 12.sp,
                                  fontFamily: FontFamily.interBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Obx(
                              () => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: PinCodeTextField(
                                  appContext: context,
                                  length: 4,
                                  controller: controller.otpController,
                                  focusNode: controller.focusNode,
                                  animationType: AnimationType.fade,
                                  keyboardType: TextInputType.number,
                                  animationDuration:
                                  const Duration(milliseconds: 300),
                                  enableActiveFill: false,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(16.r),
                                    fieldHeight: 60.w,
                                    fieldWidth: 60.w,
                                    borderWidth: 1,
                                    activeColor: ToggleThemeData.darkPurple,
                                    inactiveColor:
                                    ToggleThemeData.darkPurple.withOpacity(0.5),
                                    selectedColor: ToggleThemeData.darkPurple,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.black,
                                    fontFamily: FontFamily.interMedium,
                                  ),
                                  onChanged: (value) =>
                                  controller.otpErrorText.value = '',
                                  onCompleted: (otp) {},
                                ),
                              ),
                              if (controller.otpErrorText.value.isNotEmpty)
                                Padding(
                                  padding:
                                  EdgeInsets.only(top: 6.h, left: 20.w),
                                  child: Text(
                                    controller.otpErrorText.value,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                      fontFamily: FontFamily.interMedium,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 25.h),
                              reausablebutton(
                                title: "Verify Code",
                                ontap: controller.veriefyOtp,
                                borderradiues: 25.r,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      final controller = Get.find<OtpController>();
                      return controller.resendSeconds.value > 0
                          ? reausabletext(
                        "Resend OTP in 00:${controller.resendSeconds.value.toString().padLeft(2, '0')}",
                        fontsize: 13.sp,
                        color: Colors.grey,
                        fontfamily: FontFamily.interMedium,
                      )
                          : Text.rich(
                        TextSpan(
                          text: "Didn't get the code? ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            fontFamily: FontFamily.interRegular,
                          ),
                          children: [
                            TextSpan(
                              text: "Resend It",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: ToggleThemeData.Appcolor,
                                fontFamily: FontFamily.interBold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = controller.resendOtp,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
