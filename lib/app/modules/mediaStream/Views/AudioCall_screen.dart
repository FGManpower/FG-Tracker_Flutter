import 'package:fgtracker/app/modules/mediaStream/controller/calling_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';

class AudiocallScreen extends StatelessWidget {
  const AudiocallScreen({super.key, required this.controller});

  final CallingController controller;

  static const Color primaryPurple = Color(0xFF7B58FF);
  static const Color darkText = Color(0xFF0F0B4C);

  @override
  Widget build(BuildContext context) {
    final String profilePath = controller.args['callerProfile'] ?? '';
    final String imageUrl = Utility.isNullEmptyOrFalse(profilePath)
        ? MyAppTheme.ProfilenotFoundImg
        : (profilePath.startsWith('http')
        ? profilePath
        : ConstRes.aImageBaseUrl + profilePath);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Text(
            "Call From",
            style: TextStyle(
              color: primaryPurple.withOpacity(0.85),
              fontSize: 14.sp,
              fontFamily: FontFamily.interMedium,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "${controller.args["callerName"] ?? ""}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 28.sp,
              fontFamily: FontFamily.interSemiBold,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final waiting = controller.formattedDuration == "00:00";
            return Text(
              waiting
                  ? "${controller.callStatus.value}..."
                  : controller.formattedDuration,
              style: TextStyle(
                color: primaryPurple,
                fontSize: 15.sp,
                fontFamily: FontFamily.interMedium,
              ),
            );
          }),
          SizedBox(height: 30.h),

          Stack(
            alignment: Alignment.center,
            children: [
              _ring(240.r, 0.15),
              _ring(190.r, 0.25),
              _ring(145.r, 0.40),

              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(4.r),
                child: CircleAvatar(
                  radius: 56.r,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
            ],
          ),

          SizedBox(height: 35.h),

          _AudioWave(),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _ring(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryPurple.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }
}

class _AudioWave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heights = [10, 20, 32, 45, 60, 45, 32, 20, 10];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: heights
          .map(
            (h) => Container(
          margin: EdgeInsets.symmetric(horizontal: 3.5.w),
          width: 4.5.w,
          height: h.h,
          decoration: BoxDecoration(
            color: const Color(0xFF7B58FF).withOpacity(0.85),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      )
          .toList(),
    );
  }
}