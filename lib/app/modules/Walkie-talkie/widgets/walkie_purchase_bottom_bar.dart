import 'package:fgtracker/app/global_widget/crown_icon.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

class WalkiePurchaseBottomBar extends StatelessWidget {
  const WalkiePurchaseBottomBar({super.key});

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
      final bool isTrialActive = controller.isTrialActive;
      final bool hasAccess = controller.canUseWalkieTalkie;

      String topLabel = context.l10n.walkiePlan_bottomBarAfterTrial;
      if (!isTrialActive && !hasAccess) {
        topLabel = context.l10n.walkiePlan_bottomBarChoosePlan;
      }

      return GestureDetector(
        onTap: () {
          Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 0));
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFECEBFA),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              GoldenCrownBadge(size: 40.w.clamp(36.0, 46.0)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoFitText(
                      topLabel,
                      style: TextStyle(
                        fontFamily: "geographeditwebbold",
                        fontSize: _sp(context, 10.5).sp,
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AutoFitText(
                      context.l10n.walkiePlan_bottomBarPricePer(controller.priceLabel, controller.priceTypeLabel),
                      style: TextStyle(
                        fontFamily: FontFamily.interBold,
                        fontSize: _sp(context, 14.5).sp,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    AutoFitText(
                      context.l10n.walkiePlan_bottomBarContinue,
                      style: TextStyle(
                        fontFamily: "geographeditwebbold",
                        fontSize: _sp(context, 10).sp,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 9.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFFC7B8FF),
                    width: 1.2,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 140.w),
                  child: AutoFitText(
                    context.l10n.walkiePlan_bottomBarPurchaseFor(controller.priceLabel),
                    style: TextStyle(
                      fontFamily: FontFamily.interSemiBold,
                      fontSize: _sp(context, 11.5).sp,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
