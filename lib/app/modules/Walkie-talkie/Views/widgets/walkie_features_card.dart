import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieFeaturesCard extends StatelessWidget {
  final VoidCallback onStartTrialPressed;

  const WalkieFeaturesCard({
    super.key,
    required this.onStartTrialPressed,
  });

  static const Color primaryColor = AppColors.primaryDarkblue;
  static const Color textColor = AppColors.authTextNavy;

  double _sp(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return size;
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalkieTalkieTrialController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        icon: Icons.mic_rounded,
                        title: "Push-to-talk\ncommunication",
                      ),
                      SizedBox(height: 10.h),
                      _buildFeatureItem(
                        context,
                        icon: Icons.groups_rounded,
                        title: "Quick group\ncommunication",
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFF0F1F6),
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        icon: Icons.touch_app_rounded,
                        title: "Hold to talk",
                      ),
                      SizedBox(height: 10.h),
                      _buildFeatureItem(
                        context,
                        icon: Icons.group_work_rounded,
                        title: "Easy group\ncoordination",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Dynamic Primary Action CTA
          Obx(() {
            final bool canUse = controller.canUseWalkieTalkie;
            final bool eligible = controller.isTrialEligible &&
                controller.trial?.status.toLowerCase() == 'not_started';

            if (!canUse && !eligible && controller.data != null) {
              return SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 0));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: _sp(context, 20),
                      ),
                      SizedBox(width: 8.w),
                      reausabletext(
                        "Purchase / Upgrade Plan",
                        fontsize: _sp(context, 15),
                        fontfamily: FontFamily.interBold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (canUse) {
                    Get.to(() => const WalkieGroupSelectScreen());
                    return;
                  }
                  onStartTrialPressed();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canUse ? Icons.mic_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: _sp(context, 20),
                    ),
                    SizedBox(width: 8.w),
                    reausabletext(
                      canUse
                          ? "Open Walkie Talkie"
                          : "Start ${controller.trialDurationHuman} Free Trial",
                      fontsize: _sp(context, 15),
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36.w.clamp(32.0, 42.0),
          height: 36.w.clamp(32.0, 42.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFF),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: _sp(context, 18),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: _sp(context, 11.5),
              fontFamily: FontFamily.interMedium,
              color: textColor,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
