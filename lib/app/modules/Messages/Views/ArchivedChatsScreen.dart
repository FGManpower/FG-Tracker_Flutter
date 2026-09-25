import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          _circleIcon(
            Icons.arrow_back,
                () => Get.back(),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "Archived Chats",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),

                SizedBox(height: 2.h),

                reausabletext(
                  "Your hidden conversations",
                  fontsize: 11.sp,
                  fontweight: const FontWeight(500),
                  color: const Color(0xFF6B4DFF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(),

          SizedBox(height: 4.h),

          _emptyArchivedChats(),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _sectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          reausabletext(
            "Archived",
            fontsize: 13.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),

          SizedBox(width: 6.w),

          Transform.rotate(
            angle: 0.5,
            child: Icon(
              Icons.archive_rounded,
              size: 16.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyArchivedChats() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 42.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9E7FF),
            ),
            child: Center(
              child: Icon(
                Icons.archive_outlined,
                size: 34.sp,
                color: const Color(0xFF6B4DFF),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          reausabletext(
            "No Archived Chats",
            fontsize: 15.sp,
            fontfamily: FontFamily.interBold,
            color: Colors.black87,
          ),

          SizedBox(height: 6.h),

          Center(
            child: reausabletext(
              "Archived conversations will appear here.",
              fontsize: 11.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}