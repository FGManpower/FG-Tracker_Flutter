import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'SosController.dart';
import 'SosHowItWorksSheet.dart';

class SosScreen extends GetView<SosController> {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        scrolledUnderElevation: 0, // Scroll hone par color change ya elevation rokne ke liye
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Container(
            margin: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87, size: 20.sp),
              padding: EdgeInsets.zero,
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SOS Alert",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Send alert to nearby people",
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: GestureDetector(
                onTap: () => SosHowItWorksSheet.show(context),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                    Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14.sp, color: Colors.black87),
                      SizedBox(width: 4.w),
                      Text(
                        "How it works",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 65.w,
                    height: 65.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF12E43),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Need Help?",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                "Send an SOS alert to nearby people.\nThey will be notified and can assist you.",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF6B4DFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.camera_alt,
                              size: 15.sp, color: const Color(0xFF6B4DFF)),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Photo (Optional)",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "Attach a photo to help others understand better.",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => controller.pickImageFromCamera(),
                      child: Container(
                        height: 75.h,
                        width: 75.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Obx(() => controller.imagePath.value.isEmpty
                            ? Icon(Icons.camera_alt_outlined,
                            size: 22.sp, color: const Color(0xFF6B4DFF))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
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
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF6B4DFF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.group,
                              size: 15.sp, color: const Color(0xFF6B4DFF)),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notify Your Family (1 to 5 required)",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Obx(() => Text(
                                controller.selectedFamilyMembers.isEmpty
                                    ? "Add at least 1 family member to send SOS alert"
                                    : "${controller.selectedFamilyMembers.length} member(s) selected",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: controller
                                      .selectedFamilyMembers.isEmpty
                                      ? Colors.black54
                                      : const Color(0xFF6B4DFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedFamilyMembers.isNotEmpty
                        ? Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: SizedBox(
                        height: 45.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                          controller.selectedFamilyMembers.length,
                          itemBuilder: (context, index) {
                            final user =
                            controller.selectedFamilyMembers[index];
                            final profileUrl = (user
                                .profileImage?.isNotEmpty ??
                                false)
                                ? "${ConstRes.aImageBaseUrl}${user.profileImage}"
                                : null;

                            return Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F4FF),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: const Color(0xFF6B4DFF)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 12.r,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: profileUrl != null
                                        ? NetworkImage(profileUrl)
                                        : null,
                                    child: profileUrl == null
                                        ? Text(
                                      (user.name?.isNotEmpty ??
                                          false)
                                          ? user.name![0]
                                          .toUpperCase()
                                          : "U",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight:
                                          FontWeight.bold),
                                    )
                                        : null,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    user.name?.split(' ')[0] ?? "",
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  SizedBox(width: 4.w),
                                  InkWell(
                                    onTap: () => controller
                                        .removeFamilyMember(index),
                                    child: Icon(Icons.close,
                                        size: 14.sp, color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                        : const SizedBox.shrink()),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => controller.openFamilyBottomSheet(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4FF),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                              color: const Color(0xFF6B4DFF)
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                size: 15.sp, color: const Color(0xFF6B4DFF)),
                            SizedBox(width: 6.w),
                            Text(
                              "Add Family Member",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B4DFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Reason",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: controller.reasonList
                          .map((reason) => _buildReasonItem(reason))
                          .toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.selectedReason.value == 'Other'
                          ? "Add Details (Mandatory)"
                          : "Add Details (Optional)",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.detailsController,
                      maxLines: 2,
                      maxLength: 200,
                      style: TextStyle(fontSize: 12.sp),
                      decoration: InputDecoration(
                        hintText: "Type any additional details...",
                        hintStyle: TextStyle(
                            fontSize: 11.sp, color: Colors.grey.shade400),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide:
                          const BorderSide(color: Color(0xFF6B4DFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => controller.sendSosAlert(context),
                child: Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                    ),
                    borderRadius: BorderRadius.circular(35.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                            color: Colors.white24, shape: BoxShape.circle),
                        child: Icon(Icons.near_me,
                            color: Colors.white, size: 14.sp),
                      ),
                      Column(
                        children: [
                          Text(
                            "Send SOS Alert",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Alert will be sent to nearby people",
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward,
                          color: Colors.white, size: 16.sp),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 11.sp, color: Colors.black54),
                  SizedBox(width: 5.w),
                  Text(
                    "Your alert will be sent to nearby people and your family.",
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.black54,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            spreadRadius: 1),
      ],
    );
  }

  Widget _buildReasonItem(SosReasonItem reason) {
    return Obx(() {
      bool isSelected = controller.selectedReason.value == reason.key;
      return GestureDetector(
        onTap: () => controller.selectReason(reason.key),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52.w,
              height: 52.w,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected
                      ? reason.activeColor
                      : Colors.grey.withValues(alpha: 0.25),
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: reason.activeColor.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  reason.asset.path,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              reason.label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? reason.activeColor : Colors.black87,
              ),
            ),
          ],
        ),
      );
    });
  }
}