import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<Login_Controller> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome\nBack! 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontFamily.interBold,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 45.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6754F4),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Great to see you again.\nLog in to access your account\nand explore our latest features.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interMedium,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 40.h),
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 50.h,
                          bottom: 35.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4B3FDD).withOpacity(0.12),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontFamily.interBold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "to Continue",
                              style: TextStyle(
                                color: const Color(0xFF6754F4),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: FontFamily.interMedium,
                              ),
                            ),
                            SizedBox(height: 35.h),
                            Form(
                              key: controller.loginKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPhoneInputField(),
                                  Obx(
                                        () => AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: controller.mobileErrorText.value.isNotEmpty
                                          ? Padding(
                                        padding: EdgeInsets.only(left: 10.w, top: 8.h),
                                        child: Text(
                                          controller.mobileErrorText.value,
                                          key: ValueKey(controller.mobileErrorText.value),
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.sp,
                                            fontFamily: FontFamily.interMedium,
                                          ),
                                        ),
                                      )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                  SizedBox(height: 35.h),
                                  _buildGradientLoginButton(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          height: 75.h,
                          width: 75.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6754F4).withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 45.sp,
                              color: const Color(0xFF6754F4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 20.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: const Color(0xFF5D47F1),
                              size: 34.sp,
                            ),
                            SizedBox(width: 12.w),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12.sp,
                                  fontFamily: FontFamily.interMedium,
                                ),
                                children: [
                                  const TextSpan(text: "Your data is "),
                                  TextSpan(
                                    text: "100% ",
                                    style: TextStyle(
                                      color: const Color(0xFF5D47F1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: "secure"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10.w,
                        top: -48.h,
                        child: Image.asset(
                          'assets/images/lock_3d.png',
                          height: 120.h,
                          width: 120.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFFC7C0FA),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CountryCodePicker(
            onChanged: (country) {
              controller.selectedDialCode = country.dialCode ?? '+91';
            },
            initialSelection: 'IN',
            favorite: const ['+91', 'IN'],
            showFlagDialog: true,
            showFlagMain: true,
            flagWidth: 19.sp,
            textStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
          ),
          Container(
            height: 25.h,
            width: 1.5.w,
            color: const Color(0xFFC7C0FA),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.phone_rounded,
            color: const Color(0xFF6754F4),
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextFormField(
              focusNode: controller.phoneFocusNode,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: FontFamily.interMedium,
                color: Colors.black,
              ),
              controller: controller.mobNoController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              maxLength: 15,
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Enter Mobile Number',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) {
                controller.mobileErrorText.value = '';
              },
              onFieldSubmitted: (_) {
                controller.phoneFocusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientLoginButton() {
    return InkWell(
      onTap: () async {
        controller.login();
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 17.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7B66F6),
              Color(0xFF533EF0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D47F1).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "Log In to Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.interBold,
              ),
            ),
            Positioned(
              right: 20.w,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}