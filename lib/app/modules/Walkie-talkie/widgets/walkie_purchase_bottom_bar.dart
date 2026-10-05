import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

      String topLabel = "After your free trial";
      if (!isTrialActive && !hasAccess) {
        topLabel = "Choose a Plan";
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
              Container(
                width: 44.w.clamp(38.0, 48.0),
                height: 44.w.clamp(38.0, 48.0),
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFDDD6FE),
                    width: 1.0,
                  ),
                ),
                child: BlendMask(
                  blendMode: BlendMode.multiply,
                  child: Image.asset(
                    'assets/walkie_talkie/walkie_trial_crown.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.workspace_premium_rounded,
                      color: const Color(0xFFEAB308),
                      size: _sp(context, 24),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      topLabel,
                      fontsize: _sp(context, 10.5),
                      color: subtitleColor,
                      maxline: 1,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "${controller.priceLabel} / ${controller.priceTypeLabel}",
                      fontsize: _sp(context, 14.5),
                      fontfamily: FontFamily.interBold,
                      color: textColor,
                      maxline: 1,
                    ),
                    SizedBox(height: 1.h),
                    reausabletext(
                      "Continue with Walkie Talkie",
                      fontsize: _sp(context, 10),
                      color: subtitleColor,
                      maxline: 1,
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
                child: reausabletext(
                  "Purchase for ${controller.priceLabel}",
                  fontsize: _sp(context, 11.5),
                  fontfamily: FontFamily.interSemiBold,
                  color: primaryColor,
                  maxline: 1,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
