import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Core/util/validator.dart';
import '../Controller/RegisterController.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isUpdate = controller.arguments?['type'] == "Update" ||
        (Get.arguments is Map && (Get.arguments as Map)['type'] == "Update");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
      isUpdate ? const Color(0xFFF7F6FD) : const Color(0xFFBBAEF9),
      body: Form(
        key: controller.registerKey,
        child: isUpdate
            ? _buildEditProfileUI(context)
            : _buildRegistrationUI(context),
      ),
    );
  }

  Widget _buildRegistrationUI(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB2A0F8),
            Color(0xFFBBAEF9),
            Color(0xFFC6B9FB),
            Color(0xFFC8BCFB),
          ],
          stops: [0.0, 0.4, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: -20.w,
            right: -65.w,
            height: 370.h,
            child: _buildAuthWatermarkImage(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 48.h),
                        padding: EdgeInsets.fromLTRB(20.w, 62.h, 20.w, 26.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B4DFF)
                                  .withValues(alpha: 0.15),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRegLabel("User Name"),
                            SizedBox(height: 8.h),
                            _buildRegTextField(
                              controller: controller.nameController,
                              icon: Icons.person,
                              hint: "Enter User Name",
                              validator: (value) => Validator.validate(
                                  value: value, title: "User Name"),
                            ),
                            SizedBox(height: 18.h),

                            _buildRegLabel("Contact Number"),
                            SizedBox(height: 8.h),
                            _buildRegTextField(
                              controller: controller.phoneController,
                              icon: Icons.call,
                              hint: "Enter Contact Number",
                              enabled: false,
                            ),
                            SizedBox(height: 28.h),

                            _buildRegLabel("Select Gender"),
                            SizedBox(height: 8.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBFBFE),
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: const Color(0xFFF0EDFF),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRegGenderOption(
                                    title: AppText.male,
                                    value: "male",
                                    icon: Icons.person,
                                  ),
                                  const Divider(
                                    color: Color(0xFFEFEBFD),
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  _buildRegGenderOption(
                                    title: AppText.female,
                                    value: "female",
                                    icon: Icons.person,
                                  ),
                                  const Divider(
                                    color: Color(0xFFEFEBFD),
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  _buildRegGenderOption(
                                    title: AppText.other,
                                    value: "others",
                                    icon: Icons.group,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 26.h),

                            // Submit Button with Loading State
                            Obx(() {
                              final isLoading = controller.isLoading.value;
                              return GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => controller.register(controller),
                                child: Container(
                                  width: double.infinity,
                                  height: 54.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF5E44F8),
                                        Color(0xFF674BFF),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5D47F1)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: isLoading
                                      ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    ),
                                  )
                                      : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        "Done",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: FontFamily.interBold,
                                        ),
                                      ),
                                      Positioned(
                                        right: 22.w,
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      Positioned(
                        top: 0,
                        child: _RegistrationHexagonBadge(
                          onTap: () => controller.pickImage(context),
                          child: _buildAvatarContent(),
                        ),
                      ),

                      Positioned(
                        top: 4.h,
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    return Obx(() {
      if (controller.selectedImage.value.isNotEmpty) {
        return ClipOval(
          child: Image.file(
            File(controller.selectedImage.value),
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
          ),
        );
      } else if (Utility.isNotNullEmptyOrFalse(
          controller.userData.profileImage)) {
        return ClipOval(
          child: Image.network(
            "${ConstRes.aImageBaseUrl}${controller.userData.profileImage}",
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: Color(0xFF5D47F1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 26.sp,
          ),
        );
      }
    });
  }

  Widget _buildRegLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF1F1F39),
        fontSize: 13.sp,
        fontFamily: FontFamily.interBold,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRegTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      initialValue: controller.text,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: state.hasError
                      ? Colors.redAccent
                      : const Color(0xFFD6CEFD),
                  width: state.hasError ? 1.4 : 1.2,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1EEFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF5D47F1),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      enabled: enabled,
                      keyboardType: keyboardType,
                      onChanged: (val) {
                        state.didChange(val);
                      },
                      style: TextStyle(
                        color: const Color(0xFF5D47F1),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: FontFamily.interBold,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: const Color(0xFFB0A8DE),
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interRegular,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 4.h),
                child: Text(
                  state.errorText ?? "",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRegGenderOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Obx(() {
      final bool isSelected =
          controller.gender.value.toLowerCase() == value.toLowerCase();
      return InkWell(
        onTap: () => controller.gender.value = value,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5D47F1)
                        : const Color(0xFFC7B9FE),
                    width: isSelected ? 2.0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5D47F1),
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 16.w),
              Icon(
                icon,
                color: const Color(0xFF5D47F1),
                size: 20.sp,
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1F1F39),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.interBold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget _buildAuthWatermarkImage() {
    return Assets.images.authArcBg.image(
      fit: BoxFit.fill,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildEditProfileUI(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF7F6FD),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 265.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5D47F1),
                    Color(0xFF705CF6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.sp,
                              fontFamily: FontFamily.interBold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 42.w),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFF5D47F1).withValues(alpha: 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => controller.pickImage(context),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 65.r,
                                    backgroundColor: const Color(0xFFEDE9FE),
                                    child: Obx(
                                          () => _getAvatarImage(
                                        65.r,
                                        const Color(0xFFEDE9FE),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 2.w,
                                    bottom: 2.h,
                                    child: Container(
                                      padding: EdgeInsets.all(3.5.w),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: 17.r,
                                        backgroundColor:
                                        const Color(0xFF5D47F1),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Tap on the photo to change",
                              style: TextStyle(
                                color: const Color(0xFF7A7F93),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.interRegular,
                              ),
                            ),
                            SizedBox(height: 26.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Personal Information",
                                style: TextStyle(
                                  color: const Color(0xFF5D47F1),
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.interBold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildEditProfileField(
                              label: "Full Name",
                              controller: controller.nameController,
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              validator: (value) => Validator.validate(
                                  value: value, title: "Full Name"),
                            ),
                            _buildEditProfileField(
                              label: "Phone Number",
                              controller: controller.phoneController,
                              icon: Icons.phone_outlined,
                              enabled: false,
                              keyboardType: TextInputType.phone,
                            ),
                            Obx(() {
                              if (!controller.hasExistingEmail.value) {
                                return const SizedBox.shrink();
                              }
                              return _buildEditProfileField(
                                label: "Email Address",
                                controller: controller.emailController,
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                    Validator.validateEmail(value),
                              );
                            }),
                            SizedBox(height: 26.h),

                            // Save Changes with Loading State
                            Obx(() {
                              final isLoading = controller.isLoading.value;
                              return GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => controller.updateProfile(controller),
                                child: Container(
                                  width: double.infinity,
                                  height: 54.h,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF5E44F8),
                                        Color(0xFF674BFF),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5D47F1)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                        : Text(
                                      "Save Changes",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: FontFamily.interBold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAvatarImage(double radius, Color defaultBgColor) {
    if (controller.selectedImage.value != "") {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(controller.selectedImage.value)),
        backgroundColor: defaultBgColor,
      );
    } else if (Utility.isNotNullEmptyOrFalse(
        controller.userData.profileImage)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBgColor,
        child: ClipOval(
          child: Image.network(
            "${ConstRes.aImageBaseUrl}${controller.userData.profileImage}",
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person_rounded,
              size: radius * 1.1,
              color: const Color(0xFF5D47F1),
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBgColor,
        child: Icon(
          Icons.person_rounded,
          size: radius * 1.1,
          color: const Color(0xFF5D47F1),
        ),
      );
    }
  }

  Widget _buildEditProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator != null ? (_) => validator(controller.text) : null,
      builder: (state) {
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.redAccent
                        : const Color(0xFFEDE8F5),
                    width: state.hasError ? 1.4 : 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: state.hasError
                          ? Colors.redAccent
                          : const Color(0xFF5D47F1),
                      size: 24.sp,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: state.hasError
                                  ? Colors.redAccent
                                  : const Color(0xFF8C8E9D),
                              fontFamily: FontFamily.interRegular,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextFormField(
                            controller: controller,
                            enabled: enabled,
                            keyboardType: keyboardType,
                            onChanged: (val) {
                              state.didChange(val);
                            },
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E202B),
                              fontFamily: FontFamily.interBold,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: EdgeInsets.only(left: 14.w, top: 4.h),
                  child: Text(
                    state.errorText ?? "",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interMedium,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RegistrationHexagonBadge extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _RegistrationHexagonBadge({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      height: 90.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(80.w, 90.h),
            painter: _RegHexHaloPainter(),
          ),
          CustomPaint(
            size: Size(68.w, 78.h),
            painter: _RegHexCardPainter(),
            child: SizedBox(
              width: 68.w,
              height: 78.h,
              child: Center(child: child),
            ),
          ),
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(5.w),
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 11.r,
                    backgroundColor: const Color(0xFF5D47F1),
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.white,
                      size: 11.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Path _buildRoundedHexagon(Size size, double cornerRadius) {
  final double w = size.width;
  final double h = size.height;
  final double cx = w / 2;
  final double cy = h / 2;

  final List<Offset> vertices = [
    Offset(cx, 0),
    Offset(w, cy * 0.5),
    Offset(w, h - cy * 0.5),
    Offset(cx, h),
    Offset(0, h - cy * 0.5),
    Offset(0, cy * 0.5),
  ];

  final Path path = Path();
  final int count = vertices.length;

  for (int i = 0; i < count; i++) {
    final Offset prev = vertices[(i - 1 + count) % count];
    final Offset curr = vertices[i];
    final Offset next = vertices[(i + 1) % count];

    final Offset dirPrev = (prev - curr);
    final double distPrev = dirPrev.distance;
    final Offset pPrev =
        curr + dirPrev * (cornerRadius.clamp(0.0, distPrev * 0.45) / distPrev);

    final Offset dirNext = (next - curr);
    final double distNext = dirNext.distance;
    final Offset pNext =
        curr + dirNext * (cornerRadius.clamp(0.0, distNext * 0.45) / distNext);

    if (i == 0) {
      path.moveTo(pPrev.dx, pPrev.dy);
    } else {
      path.lineTo(pPrev.dx, pPrev.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, pNext.dx, pNext.dy);
  }
  path.close();
  return path;
}

class _RegHexHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagon(size, 16);

    final shadowPaint = Paint()
      ..color = const Color(0xFF5D47F1).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    final auraPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, auraPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RegHexCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildRoundedHexagon(size, 13);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFECE7FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}