import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

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

      final l10n = context.l10n;
      // Was `title == "FREE TRIAL"`; kept as a flag so the badge logic
      // does not depend on the translated text.
      bool isFreeTrialTitle = true;
      String title = l10n.walkiePlan_trialFreeTrialLabel;
      String? subtitle;
      String description =
          l10n.walkiePlan_trialUseWithin7Days(controller.trialDurationFormatted);

      if (trialActive) {
        isFreeTrialTitle = false;
        title = l10n.walkiePlan_trialActiveLabel;
        subtitle = l10n.walkiePlan_trialFreeTrialRunning;
        description = l10n.walkiePlan_trialEnjoyDuringActive;
      } else if (trialConsumed) {
        isFreeTrialTitle = true;
        title = l10n.walkiePlan_trialFreeTrialLabel;
        subtitle = l10n.walkiePlan_trialUsed;
        description = l10n.walkiePlan_trialFullyConsumed;
      } else if (trialExpired) {
        isFreeTrialTitle = false;
        title = l10n.walkiePlan_trialExpiredLabel;
        subtitle = l10n.walkiePlan_trialHasEnded;
        description = l10n.walkiePlan_trialChooseSubscription;
      } else if (trialEligible || trial.status.toLowerCase() == 'not_started') {
        isFreeTrialTitle = true;
        title = l10n.walkiePlan_trialFreeTrialLabel;
        subtitle = null;
        description = l10n
            .walkiePlan_trialUseWithin7Days(controller.trialDurationFormatted);
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
                          Flexible(
                            child: AutoFitText(
                              title,
                              style: TextStyle(
                                fontFamily: FontFamily.interBold,
                                fontSize: _sp(context, 12.5).sp,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isFreeTrialTitle && !trialConsumed) ...[
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
                        l10n.walkiePlan_trialUsage,
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
                      Flexible(
                      child: Row(
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
                          Flexible(
                            child: AutoFitText(
                              trialActive
                                  ? l10n.walkiePlan_trialTimeRemaining
                                  : trialConsumed
                                      ? l10n.walkiePlan_trialCompleted
                                      : trialExpired
                                          ? l10n.walkiePlan_trialExpired
                                          : trial.expiresAt != null
                                              ? l10n.walkiePlan_trialValidityPeriod
                                              : l10n.walkiePlan_trialFreeAvailable,
                              style: TextStyle(
                                fontFamily: FontFamily.interMedium,
                                fontSize: _sp(context, 11).sp,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                      Flexible(
                        child: AutoFitText(
                          trialActive
                              ? controller.remainingLabel
                              : trialConsumed
                                  ? l10n.walkiePlan_trialStatusCompleted
                                  : trialExpired
                                      ? l10n.walkiePlan_trialStatusExpired
                                      : trial.expiresAt != null
                                          ? controller.formatDaysRemaining(trial.expiresAt)
                                          : l10n.walkiePlan_trialAvailableToStart,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontFamily: "geographeditwebbold",
                            fontSize: _sp(context, 11).sp,
                            color: trialExpired ? Colors.red : subtitleColor,
                          ),
                        ),
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
