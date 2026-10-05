import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NoVoiceSeatDialog extends StatelessWidget {
  final dynamic teamAssignedSeats;
  final dynamic teamPurchasedSeats;
  final VoidCallback? onUpgrade;
  final VoidCallback? onContinue;

  const NoVoiceSeatDialog({
    super.key,
    required this.teamAssignedSeats,
    required this.teamPurchasedSeats,
    this.onUpgrade,
    this.onContinue,
  });

  static void show({
    required BuildContext context,
    required dynamic teamAssignedSeats,
    required dynamic teamPurchasedSeats,
    VoidCallback? onUpgrade,
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => NoVoiceSeatDialog(
        teamAssignedSeats: teamAssignedSeats,
        teamPurchasedSeats: teamPurchasedSeats,
        onUpgrade: onUpgrade,
        onContinue: onContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onContinue?.call();
                },
                child: Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC7D2FE),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.headset_mic_rounded,
                color: const Color(0xFF4F46E5),
                size: 30.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "No Voice Seat Assigned",
              style: TextStyle(
                fontSize: 19.sp,
                fontFamily: FontFamily.interBold,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "You have an active Team Plan, but all active voice seats are currently assigned to other team members.\n\nYou can listen to group conversations in real-time, but to speak, you must assign a seat to yourself or upgrade your plan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF475569),
                fontFamily: FontFamily.interRegular,
                height: 1.4,
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Team Plan Status",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF059669),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Assigned Seats",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$teamAssignedSeats / $teamPurchasedSeats Seats Used",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your Voice Access",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Listen Only",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 46.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6356F6), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () {
                    Navigator.pop(context);
                    if (onUpgrade != null) {
                      onUpgrade!();
                    } else {
                      Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 1));
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: Colors.white, size: 17.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Upgrade & Add Seats",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5.sp,
                            fontFamily: FontFamily.interBold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onContinue?.call();
              },
              child: Text(
                "Continue in Listen-Only Mode",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}