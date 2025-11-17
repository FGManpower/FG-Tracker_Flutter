import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class ChatBottomSheet {
  static Future<void> showCallOptions(
      BuildContext context, {
        VoidCallback? onAudioCall,
        VoidCallback? onWalkieTalkieCall,
      }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.33,
          maxChildSize: 0.45,
          minChildSize: 0.25,
          builder: (_, controller) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  reausabletext(
                    "Call Options",
                    fontsize: 18,
                    fontfamily: FontFamily.interBold,
                  ),
                  SizedBox(height: 12.h),

                  _callTile(
                    context,
                    title: "Normal Audio Call",
                    subtitle: "Standard clear voice quality",
                    icon: Icons.call_outlined,
                    color: ToggleThemeData.darkPurple,
                    onTap: () {
                      Navigator.pop(context);
                      onAudioCall?.call();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _callTile(
                    context,
                    title: "Walkie-Talkie Call",
                    subtitle: "Push-to-talk communication",
                    icon: Icons.record_voice_over_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      onWalkieTalkieCall?.call();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _callTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  reausabletext(
                    title,
                    fontsize: 15,
                    fontweight: FontWeight.w600,
                  ),
                  SizedBox(height: 2.h),
                  reausabletext(
                    subtitle,
                    fontsize: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}
