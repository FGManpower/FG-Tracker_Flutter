import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import '../../../global_widget/input_widget.dart';
import '../Controller/SosController.dart';

class SosScreen extends GetView<SosController> {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            reausabletext(
              "SOS Alert",
              fontsize: 18.sp,
              fontfamily: FontFamily.interBold,
              color: Colors.black87,
            ),
            reausabletext(
              "Send alert to nearby people",
              fontsize: 11.sp,
              color: Colors.black54,
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14.sp, color: Colors.black87),
                    SizedBox(width: 4.w),
                    reausabletext("How it works", fontsize: 11.sp, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: reausabletext(
                    "SOS",
                    fontsize: 20.sp,
                    fontfamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            reausabletext(
              "Need Help?",
              fontsize: 18.sp,
              fontfamily: FontFamily.interBold,
              color: Colors.black87,
              align: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            reausabletext(
              "Send an SOS alert to nearby people.\nThey will be notified and can assist you.",
              fontsize: 12.sp,
              color: Colors.black54,
              align: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4DFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.camera_alt, size: 16.sp, color: const Color(0xFF6B4DFF)),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reausabletext("Add Photo (Optional)", fontsize: 13.sp, fontfamily: FontFamily.interSemiBold),
                          reausabletext("Attach a photo to help others understand the situation better.", fontsize: 10.sp, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: () => controller.pickImageFromCamera(),
                    child: Container(
                      height: 90.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Obx(() => controller.imagePath.value.isEmpty
                          ? Icon(Icons.add, size: 24.sp, color: const Color(0xFF6B4DFF))
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(controller.imagePath.value),
                          fit: BoxFit.cover,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4DFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.group, size: 16.sp, color: const Color(0xFF6B4DFF)),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reausabletext("Notify Your Family (Minimum 1 required)", fontsize: 13.sp, fontfamily: FontFamily.interSemiBold),
                          reausabletext("Add at least 1 family member to send SOS alert", fontsize: 10.sp, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4FF),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16.sp, color: const Color(0xFF6B4DFF)),
                        SizedBox(width: 6.w),
                        reausabletext("Add Family Member", fontsize: 12.sp, fontfamily: FontFamily.interSemiBold, color: const Color(0xFF6B4DFF)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext("Select Reason", fontsize: 13.sp, fontfamily: FontFamily.interSemiBold),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildReasonItem("Medical", Icons.favorite, Colors.pink),
                      _buildReasonItem("Accident", Icons.car_crash, Colors.orange),
                      _buildReasonItem("Safety", Icons.security, Colors.red),
                      _buildReasonItem("Threat", Icons.coronavirus, Colors.purple),
                      _buildReasonItem("Other", Icons.more_horiz, Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => InputField(
              title: controller.selectedReason.value == 'Other' ? "Add Details (Mandatory)" : "Add Details (Optional)",
              controller: controller.detailsController,
              hintText: "Type any additional details...",
              maxLines: 3,
              maxLength: 200,
            )),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () => controller.sendSosAlert(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(40.r),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.near_me, color: Colors.white, size: 16.sp),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reausabletext("Send SOS Alert", fontsize: 15.sp, fontfamily: FontFamily.interBold, color: Colors.white),
                            reausabletext("Alert will be sent to nearby people", fontsize: 10.sp, color: Colors.white70),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 12.sp, color: Colors.black54),
                SizedBox(width: 6.w),
                reausabletext("Your alert will be sent to nearby people and your family members.", fontsize: 10.sp, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(String label, IconData icon, Color color) {
    return Obx(() {
      bool isSelected = controller.selectedReason.value == label;
      return GestureDetector(
        onTap: () => controller.selectReason(label),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 20.sp, color: isSelected ? color : Colors.black54),
            ),
            SizedBox(height: 6.h),
            reausabletext(
              label,
              fontsize: 10.sp,
              fontfamily: isSelected ? FontFamily.interSemiBold : FontFamily.interRegular,
              color: isSelected ? color : Colors.black87,
            ),
          ],
        ),
      );
    });
  }
}