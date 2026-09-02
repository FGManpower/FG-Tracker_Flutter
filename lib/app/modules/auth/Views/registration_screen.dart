import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
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
    bool isUpdate = controller.arguments?['type'] == "Update";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
      isUpdate ? const Color(0xFFEEE9FE) : const Color(0xFFEDE9FE),
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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.registerationBg.path),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: BackpressIcon(context, color: const Color(0xFF6B4DFF)),
              ),
              SizedBox(height: 30.h),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 60.h),
                    padding: EdgeInsets.only(
                        top: 80.h, left: 20.w, right: 20.w, bottom: 30.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 5),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRegLabel("User Name"),
                        _buildRegTextField(
                          controller: controller.nameController,
                          icon: Icons.person,
                          hint: "Enter User Name",
                          validator: (value) => Validator.validate(
                              value: value, title: "User Name"),
                        ),
                        SizedBox(height: 20.h),
                        _buildRegLabel("Contact Number"),
                        _buildRegTextField(
                          controller: controller.phoneController,
                          icon: Icons.call,
                          hint: "Enter Contact Number",
                          enabled: false,
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F8FF),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.all(15.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRegLabel("Select Gender"),
                              SizedBox(height: 10.h),
                              _buildRegGenderOption(
                                  title: AppText.male,
                                  value: "male",
                                  icon: Icons.person),
                              Divider(color: Colors.black12, height: 1.h),
                              _buildRegGenderOption(
                                  title: AppText.female,
                                  value: "female",
                                  icon: Icons.person_3),
                              Divider(color: Colors.black12, height: 1.h),
                              _buildRegGenderOption(
                                  title: AppText.other,
                                  value: "others",
                                  icon: Icons.group),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                        GestureDetector(
                          onTap: () => controller.register(controller),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF8B78FF),
                                Color(0xFF5A3FFF)
                              ]),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                reausabletext("Done",
                                    color: Colors.white,
                                    fontsize: 18.sp,
                                    fontfamily: FontFamily.interBold),
                                SizedBox(width: 10.w),
                                const Icon(Icons.arrow_forward,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.pickImage(context),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 8.w),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10)
                        ],
                      ),
                      child: Obx(
                              () => _getAvatarImage(70.r, const Color(0xFF6B4DFF))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileUI(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFEEE9FE),
      child: Column(
        children: [
          ClipPath(
            clipper: _EditProfileHeaderClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 30.h,
                left: 15.w,
                right: 15.w,
                bottom: 150.h,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B4DFF), Color(0xFF8B78FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Transform.translate(
                offset: Offset(0, 02.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: reausabletext(
                          "Edit Profile",
                          color: Colors.white,
                          fontsize: 20.sp,
                          fontfamily: FontFamily.interBold,
                        ),
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -116.h),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4DFF).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => controller.pickImage(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 66.r,
                              backgroundColor: const Color(0xFFE2E2E2),
                              child: CircleAvatar(
                                radius: 64.r,
                                backgroundColor: Colors.white,
                                child: Obx(
                                      () => _getAvatarImage(
                                    55.r,
                                    const Color(0xFFEDE9FE),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4.w,
                              bottom: 4.w,
                              child: CircleAvatar(
                                radius: 19.r,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 15.r,
                                  backgroundColor: const Color(0xFF6B4DFF),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      reausabletext("Tap on the photo to change",
                          color: Colors.grey,
                          fontsize: 13.sp,
                          // fontweight: FontWeight(700)
                      ),
                      SizedBox(height: 28.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: reausabletext(
                          "Personal Information",
                          color: const Color(0xFF6B4DFF),
                          fontsize: 15.sp,
                          fontfamily: FontFamily.interBold,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _buildEditProfileField(
                        label: "Full Name",
                        controller: controller.nameController,
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 15.h),
                      _buildEditProfileField(
                        label: "Phone Number",
                        controller: controller.phoneController,
                        icon: Icons.call_outlined,
                        enabled: false,
                      ),
                      SizedBox(height: 40.h),
                      reausablebutton(
                        ontap: () => controller.updateProfile(controller),
                        title: "Save Changes",
                        height: 56,
                        borderradiues: 20,
                        fontSize: 16,
                        backgroundColor: const Color(0xFF6B4DFF),
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

  Widget _getAvatarImage(double radius, Color defaultBgColor) {
    if (controller.selectedImage.value != "") {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(controller.selectedImage.value)),
        backgroundColor: Colors.grey,
      );
    } else if (Utility.isNotNullEmptyOrFalse(
        controller.userData.profileImage)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(
            "${ConstRes.aImageBaseUrl}${controller.userData.profileImage}"),
        backgroundColor: Colors.grey,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBgColor,
        child: Icon(Icons.mode_edit_rounded, size: 35.w, color: Colors.white),
      );
    }
  }

  Widget _buildRegLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 5.w),
      child: reausabletext(text,
          fontsize: 16.sp,
          fontfamily: FontFamily.interBold,
          color: const Color(0xFF1F1F39)),
    );
  }

  Widget _buildRegTextField(
      {required TextEditingController controller,
        required IconData icon,
        required String hint,
        bool enabled = true,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      style: TextStyle(
          color: const Color(0xFF6B4DFF),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFF6B4DFF)),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: Color(0xFFD6CFFF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: Color(0xFFD6CFFF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: Color(0xFF6B4DFF), width: 1.5)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: Color(0xFFD6CFFF))),
      ),
    );
  }

  Widget _buildRegGenderOption(
      {required String title, required String value, required IconData icon}) {
    return Obx(() {
      bool isSelected = controller.gender.value == value;
      return InkWell(
        onTap: () => controller.gender.value = value,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: const Color(0xFF6B4DFF),
                  size: 22.sp),
              SizedBox(width: 15.w),
              Icon(icon, color: const Color(0xFF6B4DFF), size: 22.sp),
              SizedBox(width: 15.w),
              reausabletext(title,
                  fontsize: 15.sp,
                  color: Colors.black87,
                  fontfamily: isSelected
                      ? FontFamily.interBold
                      : FontFamily.interRegular),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEditProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6FF),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B4DFF).withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B4DFF),
              size: 21.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 5.h),
                reausabletext(
                  label,
                  fontsize: 13.sp,
                  // fontweight: FontWeight(600),
                  color: Colors.grey,
                ),
                TextFormField(
                  controller: controller,
                  enabled: enabled,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                      bottom: 10,
                      top: 5,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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

class _EditProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 45,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}