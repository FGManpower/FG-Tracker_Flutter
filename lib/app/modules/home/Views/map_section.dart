import 'dart:ui';

import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B4DFF),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                reausabletext(
                  "Live Tracking",
                  fontsize: 16.sp,
                  fontfamily: FontFamily.interBold,
                ),
              ],
            ),
            Row(
              children: [
                _MapFilterBadge("All Groups", Icons.keyboard_arrow_down),
                SizedBox(width: 8.w),
                _MapFilterBadge("Radius: 2 km", Icons.my_location),
              ],
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MapGridPainter()),
                ),
                Positioned(top: 25.h, left: 35.w, child: _MapAvatarPin()),
                Positioned(top: 35.h, right: 85.w, child: _MapAvatarPin()),
                Positioned(bottom: 50.h, left: 55.w, child: _MapAvatarPin()),
                Positioned(bottom: 40.h, right: 95.w, child: _MapAvatarPin()),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6B4DFF).withOpacity(0.15),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4DFF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: reausabletext(
                        "You",
                        color: Colors.white,
                        fontsize: 10.sp,
                        fontfamily: FontFamily.interBold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12.w,
                  top: 30.h,
                  child: Column(
                    children: [
                      _MapControlBtn(Icons.add),
                      SizedBox(height: 4.h),
                      _MapControlBtn(Icons.remove),
                      SizedBox(height: 8.h),
                      _MapControlBtn(Icons.my_location),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.SOSScreen);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
                            ],
                          ),
                          child: Icon(Icons.warning, size: 16.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 14.sp,
                          color: const Color(0xFF6B4DFF),
                        ),
                        SizedBox(width: 6.w),
                        reausabletext(
                          "8 Members Live",
                          fontsize: 11.sp,
                          fontfamily: FontFamily.interSemiBold,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.12),
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B4DFF),
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFF6B4DFF).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            reausabletext(
                              "Coming Soon",
                              color: Colors.white,
                              fontsize: 16.sp,
                              fontfamily: FontFamily.interBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final bluePathPaint = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, bluePathPaint);

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.4, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.8, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapAvatarPin extends StatelessWidget {
  const _MapAvatarPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: CircleAvatar(
            radius: 14.r,
            backgroundColor: const Color(0xFFE8F0FE),
            child: Icon(
              Icons.person,
              size: 16.sp,
              color: const Color(0xFF6B4DFF),
            ),
          ),
        ),
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5.w),
          ),
        ),
      ],
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  const _MapControlBtn(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 16.sp, color: Colors.black87),
    );
  }
}

class _MapFilterBadge extends StatelessWidget {
  const _MapFilterBadge(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          if (icon != Icons.keyboard_arrow_down) ...[
            Icon(icon, size: 14.sp, color: const Color(0xFF6B4DFF)),
            SizedBox(width: 4.w),
          ],
          reausabletext(text, fontsize: 11.sp, color: Colors.black87),
          if (icon == Icons.keyboard_arrow_down) ...[
            SizedBox(width: 4.w),
            Icon(icon, size: 16.sp, color: Colors.black87),
          ],
        ],
      ),
    );
  }
}