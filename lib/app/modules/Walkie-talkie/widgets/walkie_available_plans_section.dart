import 'package:fgtracker/app/Core/util/currency_format.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Utils/walkie_plan_l10n.dart';
import 'package:fgtracker/l10n/l10n.dart';

class WalkieAvailablePlansSection extends StatelessWidget {
  final List<WalkieSubscriptionPlan> individualPlans;
  final List<WalkieSubscriptionPlan> teamPlans;

  const WalkieAvailablePlansSection({
    super.key,
    required this.individualPlans,
    required this.teamPlans,
  });

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
    if (individualPlans.isEmpty && teamPlans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4DFF).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: primaryColor,
                  size: _sp(context, 18),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.walkiePlan_availableTitle,
                      style: TextStyle(
                        fontSize: _sp(context, 15),
                        fontFamily: FontFamily.interBold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      context.l10n.walkiePlan_availableSubtitle,
                      style: TextStyle(
                        fontSize: _sp(context, 10.5),
                        color: subtitleColor,
                        fontFamily: FontFamily.interRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 1. INDIVIDUAL PLANS
          if (individualPlans.isNotEmpty) ...[
            _buildCategoryHeader(context, context.l10n.walkiePlan_availableIndividualPlans, Icons.person_rounded),
            SizedBox(height: 8.h),
            for (final plan in individualPlans) ...[
              _buildPlanItem(
                context,
                plan: plan,
                isTeam: false,
                onTap: () {
                  Get.to(
                    () => const WalkieTalkiePlanDetails(
                      initialTabIndex: 0,
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
            ],
            SizedBox(height: 8.h),
          ],

          // 2. TEAM PLANS
          if (teamPlans.isNotEmpty) ...[
            _buildCategoryHeader(context, context.l10n.walkiePlan_availableTeamPlans, Icons.groups_rounded),
            SizedBox(height: 8.h),
            for (final plan in teamPlans) ...[
              _buildPlanItem(
                context,
                plan: plan,
                isTeam: true,
                onTap: () {
                  Get.to(
                    () => const WalkieTalkiePlanDetails(
                      initialTabIndex: 1,
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: _sp(context, 14),
          color: primaryColor,
        ),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: _sp(context, 12),
            fontFamily: FontFamily.interBold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanItem(
    BuildContext context, {
    required WalkieSubscriptionPlan plan,
    required bool isTeam,
    required VoidCallback onTap,
  }) {
    final formattedPrice = plan.pricePerMember == plan.pricePerMember.roundToDouble()
        ? plan.pricePerMember.toStringAsFixed(0)
        : plan.pricePerMember.toStringAsFixed(2);
    final currencySymbol = CurrencyFormat.symbol(plan.currency);
    final interval = plan.billingInterval.isNotEmpty
        ? walkieDurationText(
            plan.billingInterval[0].toUpperCase() +
                plan.billingInterval.substring(1),
            context.l10n)
        : context.l10n.walkiePlan_durationMonthly;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFE),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFEFF0F6),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: _sp(context, 13),
                          fontFamily: FontFamily.interBold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: isTeam ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          interval,
                          style: TextStyle(
                            fontSize: _sp(context, 9.5),
                            fontFamily: FontFamily.interSemiBold,
                            color: isTeam ? const Color(0xFF1D4ED8) : const Color(0xFFC2410C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    isTeam
                        ? context.l10n.walkiePlan_availableTeamSeats(plan.minMembers, plan.maxMembers)
                        : context.l10n.walkiePlan_availableSingleMember,
                    style: TextStyle(
                      fontSize: _sp(context, 10.5),
                      color: subtitleColor,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$currencySymbol$formattedPrice",
                  style: TextStyle(
                    fontSize: _sp(context, 14),
                    fontFamily: FontFamily.interBold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  isTeam ? context.l10n.walkiePlan_availablePerSeat : context.l10n.walkiePlan_availablePerMonth,
                  style: TextStyle(
                    fontSize: _sp(context, 9.5),
                    color: subtitleColor,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: _sp(context, 12),
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
