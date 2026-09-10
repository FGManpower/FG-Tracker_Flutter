import 'package:country_code_picker/country_code_picker.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
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
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
              Color(0xFF7E7DE8),
              Color(0xFF8E8DF0),
              Color(0xFFCFCBFA),
              Color(0xFFEEEDFD),
            ],
            stops: [0.0, 0.35, 0.68, 1.0],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: isKeyboardOpen
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: isKeyboardOpen ? 18.h : 85.h),
                            // Top Header: Welcome Back + compact Location Pin & Background Effect (all inside scroll view)
                            SizedBox(
                              width: double.infinity,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Top-right background effect & Location Pin (compact size)
                                  if (!isKeyboardOpen)
                                    Positioned(
                                      top: -15.h,
                                      right: -10.w,
                                      child: SizedBox(
                                        width: 155.w,
                                        height: 155.h,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Background effect (arcs + world map)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              width: 150.w,
                                              height: 150.h,
                                              child: Opacity(
                                                opacity: 0.85,
                                                child:
                                                _buildAuthWatermarkImage(),
                                              ),
                                            ),
                                            // 3D Location Icon on top of the effect
                                            Positioned(
                                              top: 20.h,
                                              right: 5.w,
                                              child: Image.asset(
                                                Assets.images.loctionIcon.path,
                                                width: 110.w,
                                                height: 110.h,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // Left-side Welcome Back text
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
                                            color: AppColors.white,
                                            fontSize:
                                            isKeyboardOpen ? 24.sp : 32.sp,
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
                                            color: AppColors.authIconBar,
                                            borderRadius:
                                            BorderRadius.circular(2.r),
                                          ),
                                        ),
                                        if (!isKeyboardOpen) ...[
                                          SizedBox(height: 12.h),
                                          SizedBox(
                                            width: 180.w,
                                            child: Text(
                                              "Great to see you again.\nLog in to access your account\nand explore our latest features.",
                                              style: TextStyle(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.9),
                                                fontSize: 13.sp,
                                                fontFamily:
                                                FontFamily.interRegular,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isKeyboardOpen ? 16.h : 36.h),
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
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.authGradientTop
                                            .withValues(alpha: 0.14),
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
                                          color: AppColors.authTextNavy,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontFamily.interBold,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        "to Continue",
                                        style: TextStyle(
                                          color: AppColors.authGradientTop,
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
                                                padding: EdgeInsets.only(
                                                    left: 10.w, top: 8.h),
                                                child: Text(
                                                  controller
                                                      .mobileErrorText
                                                      .value,
                                                  style: TextStyle(
                                                    color:
                                                    AppColors.darkRed,
                                                    fontSize: 12.sp,
                                                    fontFamily: FontFamily
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
                                      color: AppColors.authGradientTop,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            if (!isKeyboardOpen) _buildBottomSecurityBadge(),
                            SizedBox(height: 35.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppColors.authMainLavender,
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
                controller.selectedDialCode.value = country.dialCode ?? '+91';
              },
              initialSelection: 'IN',
              favorite: const ['+91', 'IN'],
              showFlagDialog: true,
              showFlagMain: true,
              flagWidth: 20.sp,
              textStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.authTextNavy,
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
            color: AppColors.authMainLavender,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Center(
              child: Obx(
                () => TextFormField(
                  focusNode: controller.phoneFocusNode,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      controller.selectedDialCode.value == '+91' ? 10 : 15,
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontFamily: FontFamily.interMedium,
                    color: AppColors.authTextNavy,
                  ),
                  controller: controller.mobNoController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength:
                      controller.selectedDialCode.value == '+91' ? 10 : 15,
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
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.authGradientTop.withValues(alpha: 0.10),
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
                color: AppColors.authGradientTop,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.authTextNavy,
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                  ),
                  children: [
                    const TextSpan(text: "Your data is "),
                    TextSpan(
                      text: "100% ",
                      style: TextStyle(
                        color: AppColors.authGradientTop,
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

  static Widget _buildAuthWatermarkImage() {
    return Assets.images.authArcBg.image(
      fit: BoxFit.contain,
      alignment: Alignment.topRight,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}