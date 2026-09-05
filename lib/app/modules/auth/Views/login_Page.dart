import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/modules/auth/Controller/login_controller.dart';
import 'package:fgtracker/app/modules/auth/Auth_Widget/hexagon_badge.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<Login_Controller> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7664F6),
              Color(0xFF8F7EF8),
              Color(0xFFD6CEFD),
              Color(0xFFF3F1FE),
            ],
            stops: [0.0, 0.35, 0.72, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
          children: [
            Positioned(
              // Moved the background icon down along with the increased top padding
              top: 120.h,
              right: -20.w,
              child: SizedBox(
                width: 190.w,
                height: 190.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      Assets.images.loctionIcon.path,
                      width: 170.w,
                      height: 170.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isKeyboardOpen =
                      MediaQuery.of(context).viewInsets.bottom > 0;
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Significantly increased top padding for a much cleaner layout shift
                              SizedBox(height: 140.h),
                              if (!isKeyboardOpen)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome\nBack! 👋",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontFamily.interBold,
                                          height: 1.15,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        width: 42.w,
                                        height: 3.5.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5D47F1),
                                          borderRadius:
                                              BorderRadius.circular(2.r),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      SizedBox(
                                        width: 220.w,
                                        child: Text(
                                          "Great to see you again.\nLog in to access your account\nand explore our latest features.",
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 13.sp,
                                            fontFamily: FontFamily.interRegular,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Spacer(),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 40.h),
                                    padding: EdgeInsets.only(
                                      left: 20.w,
                                      right: 20.w,
                                      top: 48.h,
                                      bottom: 28.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4B3FDD)
                                              .withValues(alpha: 0.12),
                                          blurRadius: 28,
                                          spreadRadius: 1,
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
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontFamily.interBold,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          "to Continue",
                                          style: TextStyle(
                                            color: const Color(0xFF5D47F1),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: FontFamily.interBold,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        Form(
                                          key: controller.loginKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildPhoneInputField(),
                                              Obx(
                                                () => controller.mobileErrorText
                                                        .value.isNotEmpty
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10.w,
                                                                top: 8.h),
                                                        child: Text(
                                                          controller
                                                              .mobileErrorText
                                                              .value,
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12.sp,
                                                            fontFamily:
                                                                FontFamily
                                                                    .interMedium,
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ),
                                              SizedBox(height: 24.h),
                                              AuthGradientButton(
                                                label: "Log In to Continue",
                                                onTap: () => controller.login(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    child: HexagonBadge(
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        size: 34.sp,
                                        color: const Color(0xFF5D47F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              if (!isKeyboardOpen) _buildBottomSecurityBadge(),
                              SizedBox(height: 30.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFFDCD6FD),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 105.w,
            child: CountryCodePicker(
              onChanged: (country) {
                controller.selectedDialCode = country.dialCode ?? '+91';
              },
              initialSelection: 'IN',
              favorite: const ['+91', 'IN'],
              showFlagDialog: true,
              showFlagMain: true,
              flagWidth: 20.sp,
              textStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.interMedium,
              ),
              padding: EdgeInsets.zero,
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
            ),
          ),
          Container(
            height: 24.h,
            width: 1.w,
            color: const Color(0xFFDCD6FD),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Center(
              child: TextFormField(
                focusNode: controller.phoneFocusNode,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: 14.5.sp,
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
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Enter Mobile Number',
                  hintStyle: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF9E9EAF),
                    fontFamily: FontFamily.interRegular,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  controller.checkAndDismissKeyboard(value);
                },
                onFieldSubmitted: (_) {
                  controller.phoneFocusNode.unfocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSecurityBadge() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 13.h,
            bottom: 13.h,
            left: 18.w,
            right: 70.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B3FDD).withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: const Color(0xFF5D47F1),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
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
                        fontFamily: FontFamily.interBold,
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
          right: 4.w,
          top: -22.h,
          child: Image.asset(
            Assets.images.lock3d.path,
            height: 64.h,
            width: 64.w,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
