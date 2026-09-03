import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/util/validator.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateGroupScreen extends StatelessWidget {
  CreateGroupScreen({super.key});

  final GroupController controller = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: SafeArea(
        child: Form(
          key: controller.createGroupKey,
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 8.h),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.sp,
                        color: const Color(0xFF6B4DFF),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Center(
                        child: reausabletext(
                          AppText.createNewGroup,
                          fontsize: 24.sp,
                          fontfamily: FontFamily.interBold,
                          color: const Color(0xFF1F1F39),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Group Name label
                      _buildFieldLabel(
                        icon: Icons.groups_outlined,
                        title: AppText.groupName,
                      ),
                      SizedBox(height: 12.h),
                      _buildRoundedField(
                        controller: controller.groupName,
                        hint: AppText.enterGroupName,
                        icon: Icons.groups_outlined,
                        maxLength: 50,
                        maxLines: 1,
                        validator: (value) => Validator.validate(
                          value: value,
                          title: "Group Name",
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Group Description label
                      _buildFieldLabel(
                        icon: Icons.description_outlined,
                        title: "Group Description",
                      ),
                      SizedBox(height: 12.h),
                      _buildRoundedField(
                        controller: controller.groupDesc,
                        hint: "Enter Group Description",
                        icon: Icons.description_outlined,
                        maxLength: 200,
                        maxLines: 1,
                        // description optional rakhna ho to validator null
                        validator: null,
                      ),

                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ),

              // Done button
// Done button
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                child: GestureDetector(
                  onTap: () async {
                    if (controller.createGroupKey.currentState!.validate()) {
                      bool isCreated = await controller.createGroup(
                        context,
                        controller: controller,
                      );

                      if (isCreated) {
                        controller.groupName.clear();
                        controller.groupDesc.clear();
                        Get.back();
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B78FF), Color(0xFF6B4DFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4DFF).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: reausabletext(
                      "Done",
                      color: Colors.white,
                      fontsize: 18.sp,
                      fontfamily: FontFamily.interBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF6B4DFF)),
        ),
        SizedBox(width: 10.w),
        reausabletext(
          title,
          fontsize: 16.sp,
          fontfamily: FontFamily.interBold,
          color: const Color(0xFF1F1F39),
        ),
      ],
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int maxLength,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: const Color(0xFF6B4DFF),
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        fontFamily: FontFamily.interRegular,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF6B4DFF).withValues(alpha: 0.45),
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6B4DFF).withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Color(0xFF6B4DFF), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}