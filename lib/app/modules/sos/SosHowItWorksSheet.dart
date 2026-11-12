import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/l10n/l10n.dart';

class SosHowItWorksSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Flexible(
                  child: AutoFitText(
                    ctx.l10n.sos_howItWorksTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              ctx.l10n.sos_howItWorksIntro,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            _buildStep(
              Icons.notifications_active,
              Colors.red,
              ctx.l10n.sos_step1Title,
              ctx.l10n.sos_step1Body,
            ),
            SizedBox(height: 12.h),
            _buildStep(
              Icons.group,
              const Color(0xFF6B4DFF),
              ctx.l10n.sos_step2Title,
              ctx.l10n.sos_step2Body,
            ),
            SizedBox(height: 12.h),
            _buildStep(
              Icons.verified_user,
              Colors.green,
              ctx.l10n.sos_step3Title,
              ctx.l10n.sos_step3Body,
            ),
            SizedBox(height: 12.h),
            _buildStep(
              Icons.phone,
              const Color(0xFF2196F3),
              ctx.l10n.sos_step4Title,
              ctx.l10n.sos_step4Body,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined,
                      size: 18.sp, color: const Color(0xFF6B4DFF)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      ctx.l10n.sos_privacyNote,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  ctx.l10n.common_gotIt,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStep(
      IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.black54,
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