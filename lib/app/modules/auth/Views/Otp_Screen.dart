import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/Auth_widget.dart';
import 'package:fgtracker/app/modules/auth/Controller/OtpController.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends GetView<OtpController> {
  OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final String mobileNumber = args["mobNo"];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10.h, left: 10.w, right: 10.w),
        child: reausablebutton(
          title: "Verify  OTP",
          ontap: () {
            controller.veriefyOtp();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Curved purple background
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
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Row(
                    children: [
                      SizedBox(width: 8.w),
                      reausabletext(
                        "OTP Verification",
                        color: Colors.white,
                        fontsize: 20,
                        fontweight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 120.h, left: 20.w, right: 20.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.h),
                        child: Image.asset(
                          Assets.images.otpLock.path,
                          fit: BoxFit.contain,
                          width: 250.w, // Adjust width as needed
                        ),
                      ),
                    ),

                    reausabletext(
                      "Get Your Code",
                      fontsize: 32,
                      color: AppColors.darkBlue,
                      fontfamily: FontFamily.interBold,
                      fontweight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    reausabletext(
                        "Please enter the 4 digit code that\nsent to your Mobile number. $mobileNumber",
                        color: Colors.grey,
                        align: TextAlign.center,
                        fontsize: 14), reausabletext(
                        "",
                        color: Colors.grey,
                        align: TextAlign.center,
                        fontsize: 14),
                    // SizedBox(height: 30),
                    SizedBox(
                      height: 30.h,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 4,
                          controller: controller.otpController,
                          focusNode: controller.focusNode,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(16.0.r),
                            fieldHeight: 55.w,
                            fieldWidth: 55.w,
                            activeFillColor: Colors.white,
                            selectedColor: Colors.grey,
                            inactiveColor: Colors.grey,
                            activeColor: Colors.grey,
                            borderWidth: 0.8,
                          ),
                          textStyle: TextStyle(
                            fontSize: 27.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.number,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: false,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          onChanged: (value) {
                            // You can do realtime validation or checks here if needed
                          },
                          onCompleted: (otp) {
                            // controller.verifyOtp(otp);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                        // alignment: Alignment.centerRight,
                        child: Obx(() {
                      final controller = Get.find<OtpController>();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          controller.resendSeconds.value > 0
                              ? Column(
                                  children: [
                                    reausabletext(
                                      "Resend OTP in 00:${controller.resendSeconds.value.toString().padLeft(2, '0')}",
                                        fontsize: 14.sp,
                                        color: Colors.grey,
                                    ),
                                  ],
                                )
                              : TextButton(
                                  onPressed: controller.resendOtp,
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Didn't get the code? ",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Resend",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.darkBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              controller.resendOtp();
                                            },
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      );
                    })),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Custom clipper for top curve
class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
