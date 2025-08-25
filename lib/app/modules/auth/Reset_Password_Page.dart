import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'Auth_Widget/Auth_widget.dart';
import 'Controller/Forgot_Password_Controller.dart';

class ResetPasswordPage extends StatelessWidget {
  final String token;

  ResetPasswordPage({super.key, required this.token});

  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: reausablebutton(
          title: "Confirm",
          ontap: () {
           if(controller.resetKey.currentState!.validate()){

           }
          },
          borderradiues: 7.r,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.resetKey,
          child: Column(
            children: [
              Stack(
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
                          "Forget Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16.0.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: reausabletext(
                        "Enter New Password",
                        fontsize: 22.sp,
                        align: TextAlign.center,
                        fontweight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    reausabletext(
                      "Your new password must be different from previously used password.",
                      fontsize: 13.sp,
                      align: TextAlign.center,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      Icons.lock,
                      "New Password",
                      controller: controller.newPasswordController,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline, size: 22.sp),
                    ),
                    SizedBox(height: 20.h),
                    _buildTextField(
                      Icons.lock,
                      "Confirm Password",
                      controller: controller.confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icon(Icons.lock_outline, size: 22.sp),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData? icon,
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirmPassword = false,
    bool obscureText = false,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: hint.toLowerCase().contains("password") ? 12 : 50,
      keyboardType: TextInputType.text,
      buildCounter: (_,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: (isPassword || isConfirmPassword)
            ? Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20.sp,
              )
            : null,
      ),
    );
  }
}
