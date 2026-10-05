import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieTrialCard extends StatelessWidget {
  const WalkieTrialCard({super.key});

  static const Color primaryColor = AppColors.primaryDarkblue;
  static const Color textColor = AppColors.authTextNavy;
  static const Color subtitleColor = AppColors.primarySecondaryElementText;

  double _sp(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return size;
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalkieTalkieTrialController>();

    return Obx(() {
      final trial = controller.trial;
      if (trial == null) return const SizedBox.shrink();

      final bool trialActive = controller.isTrialActive;
      final bool trialExpired = controller.isTrialExpired;
      final bool trialConsumed = controller.isTrialConsumed;
      final bool trialEligible = controller.isTrialEligible;

      String title = "FREE TRIAL";
      String? subtitle;
      String description =
          "Use your ${controller.trialDurationFormatted} trial anytime within 7 days.";

      if (trialActive) {
        title = "TRIAL ACTIVE";
        subtitle = "Free Trial Running";
        description = "Enjoy Walkie Talkie during your active trial period.";
      } else if (trialConsumed) {
        title = "FREE TRIAL";
        subtitle = "Trial Used";
        description = "Your free trial has been completely consumed.";
      } else if (trialExpired) {
        title = "TRIAL EXPIRED";
        subtitle = "Your Trial Has Ended";
        description = "Choose a subscription to continue using Walkie Talkie.";
      } else if (trialEligible || trial.status.toLowerCase() == 'not_started') {
        title = "FREE TRIAL";
        subtitle = null;
        description =
            "Use your ${controller.trialDurationFormatted} trial anytime within 7 days.";
      }

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
            // Trial header
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFFF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    CupertinoIcons.gift_fill,
                    color: primaryColor,
                    size: _sp(context, 24),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          reausabletext(
                            title,
                            fontsize: _sp(context, 12.5),
                            fontfamily: FontFamily.interBold,
                            color: textColor,
                          ),
                          if (title == "FREE TRIAL" && !trialConsumed) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFFF),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFFDDD6FE),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: _sp(context, 11),
                                    color: primaryColor,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    controller.trialDurationFormatted,
                                    style: TextStyle(
                                      fontSize: _sp(context, 10.5),
                                      fontFamily: FontFamily.interBold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        reausabletext(
                          subtitle,
                          fontsize: _sp(context, 14.5),
                          fontfamily: FontFamily.interBold,
                          color: primaryColor,
                        ),
                      ],
                      SizedBox(height: 3.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: _sp(context, 11),
                          color: subtitleColor,
                          fontFamily: FontFamily.interRegular,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // Trial usage progress block
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFE),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFEFF0F6),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      reausabletext(
                        "Trial Usage",
                        fontsize: _sp(context, 11.5),
                        fontfamily: FontFamily.interMedium,
                        color: textColor,
                      ),
                      reausabletext(
                        controller.usageLabel,
                        fontsize: _sp(context, 11.5),
                        fontfamily: FontFamily.interSemiBold,
                        color: textColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: LinearProgressIndicator(
                      value: controller.usageProgress,
                      minHeight: 5.h,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EFFF),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(
                              trialExpired || trialConsumed
                                  ? Icons.timer_off_outlined
                                  : Icons.hourglass_empty_rounded,
                              size: _sp(context, 13),
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          reausabletext(
                            trialActive
                                ? "Trial Time Remaining"
                                : trialConsumed
                                    ? "Trial Completed"
                                    : trialExpired
                                        ? "Trial Expired"
                                        : trial.expiresAt != null
                                            ? "Trial Validity Period"
                                            : "Free Trial Available",
                            fontsize: _sp(context, 11),
                            fontfamily: FontFamily.interMedium,
                            color: textColor,
                          ),
                        ],
                      ),
                      reausabletext(
                        trialActive
                            ? controller.remainingLabel
                            : trialConsumed
                                ? "Completed"
                                : trialExpired
                                    ? "Expired"
                                    : trial.expiresAt != null
                                        ? controller.formatDaysRemaining(trial.expiresAt)
                                        : "Available to start",
                        fontsize: _sp(context, 11),
                        color: trialExpired ? Colors.red : subtitleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
