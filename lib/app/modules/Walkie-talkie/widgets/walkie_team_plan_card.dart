import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalkieTeamPlanCard extends StatelessWidget {
  final WalkieTeamSubscriptionDetails? plan;
  final bool hasActiveSubscription;

  const WalkieTeamPlanCard({
    super.key,
    required this.plan,
    required this.hasActiveSubscription,
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
    if (!hasActiveSubscription || plan == null) {
      return _buildNoActiveTeamPlanCard(context);
    }

    final controller = Get.find<WalkieTalkieTrialController>();
    final activePlan = plan!;

    final String planName =
        activePlan.planName.isNotEmpty ? activePlan.planName : "Team Plan";
    final String interval = activePlan.billingInterval.isNotEmpty
        ? (activePlan.billingInterval[0].toUpperCase() +
            activePlan.billingInterval.substring(1))
        : "Monthly";

    String expiryDateFormatted = "Active";
    String daysLeftText = "";
    bool isExpiringSoon = false;

    if (activePlan.expiresAt != null) {
      expiryDateFormatted =
          DateFormat('dd MMM yyyy').format(activePlan.expiresAt!.toLocal());
      daysLeftText = controller.formatDaysRemaining(activePlan.expiresAt);
      final difference = activePlan.expiresAt!.difference(DateTime.now());
      if (difference.inDays <= 5) {
        isExpiringSoon = true;
      }
    }

    String purchasedDateFormatted = "";
    if (activePlan.purchasedAt != null) {
      purchasedDateFormatted =
          DateFormat('dd MMM yyyy').format(activePlan.purchasedAt!.toLocal());
    }

    final bool isOwner = activePlan.isOwner;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4DFF).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
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
                          Expanded(
                            child: Text(
                              planName,
                              style: TextStyle(
                                fontSize: _sp(context, 15),
                                fontFamily: FontFamily.interBold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: activePlan.isActive
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: activePlan.isActive
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFECACA),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: activePlan.isActive
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  activePlan.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: _sp(context, 9.5),
                                    fontFamily: FontFamily.interBold,
                                    color: activePlan.isActive
                                        ? const Color(0xFF047857)
                                        : const Color(0xFFB91C1C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              "Team Plan",
                              style: TextStyle(
                                fontSize: _sp(context, 10.5),
                                fontFamily: FontFamily.interSemiBold,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isOwner
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: isOwner
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFE2E8F0),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOwner
                                      ? Icons.check_circle_rounded
                                      : Icons.how_to_reg_rounded,
                                  size: _sp(context, 10.5),
                                  color: isOwner
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  isOwner
                                      ? "Purchased by You"
                                      : "Assigned by ${activePlan.assignedBy}",
                                  style: TextStyle(
                                    fontSize: _sp(context, 9.5),
                                    fontFamily: FontFamily.interSemiBold,
                                    color: isOwner
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "•  $interval",
                            style: TextStyle(
                              fontSize: _sp(context, 11),
                              color: subtitleColor,
                              fontFamily: FontFamily.interRegular,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Seat pool statistics & details
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                // 3 Seat metric cards: Purchased, Assigned, Available
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatMetricBox(
                        context,
                        label: "Purchased",
                        value: "${activePlan.purchasedSeats}",
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSeatMetricBox(
                        context,
                        label: "Assigned",
                        value: "${activePlan.assignedSeats}",
                        icon: Icons.person_pin_circle_outlined,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSeatMetricBox(
                        context,
                        label: "Available",
                        value: "${activePlan.availableSeats}",
                        icon: Icons.event_seat_outlined,
                        color: activePlan.availableSeats > 0
                            ? const Color(0xFFD97706)
                            : const Color(0xFF9CA3AF),
                        bgColor: activePlan.availableSeats > 0
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFF3F4F6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Validity Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailTile(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: "Valid Until",
                        value: expiryDateFormatted,
                        badge: daysLeftText.isNotEmpty ? daysLeftText : null,
                        isWarningBadge: isExpiringSoon,
                      ),
                    ),
                    if (purchasedDateFormatted.isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildDetailTile(
                          context,
                          icon: Icons.shopping_bag_outlined,
                          label: "Purchased On",
                          value: purchasedDateFormatted,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),

                // Action buttons: Manage Members & Change Plan
                Row(
                  children: [
                    if (isOwner) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            side: const BorderSide(color: Color(0xFF5B4DFF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            Get.to(() => const WalkieGroupSelectScreen());
                          },
                          icon: Icon(
                            Icons.group_add_rounded,
                            size: _sp(context, 15),
                            color: const Color(0xFF5B4DFF),
                          ),
                          label: Text(
                            "Manage Members",
                            style: TextStyle(
                              fontSize: _sp(context, 11.5),
                              fontFamily: FontFamily.interSemiBold,
                              color: const Color(0xFF5B4DFF),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          Get.to(
                            () => const WalkieTalkiePlanDetails(
                              initialTabIndex: 1,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.sync_alt_rounded,
                          size: _sp(context, 15),
                          color: textColor,
                        ),
                        label: Text(
                          "Change Plan",
                          style: TextStyle(
                            fontSize: _sp(context, 11.5),
                            fontFamily: FontFamily.interSemiBold,
                            color: textColor,
                          ),
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
  }

  Widget _buildNoActiveTeamPlanCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFECEBFA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.groups_outlined,
              color: const Color(0xFF94A3B8),
              size: _sp(context, 22),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Team Plan",
                  style: TextStyle(
                    fontSize: _sp(context, 13.5),
                    fontFamily: FontFamily.interBold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "No active Team plan or assigned seat",
                  style: TextStyle(
                    fontSize: _sp(context, 11),
                    color: subtitleColor,
                    fontFamily: FontFamily.interRegular,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              side: const BorderSide(color: Color(0xFFC7B8FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.to(() => const WalkieTalkiePlanDetails(initialTabIndex: 1));
            },
            child: Text(
              "Browse",
              style: TextStyle(
                fontSize: _sp(context, 11),
                fontFamily: FontFamily.interSemiBold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMetricBox(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: _sp(context, 15),
            color: color,
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: _sp(context, 14),
              fontFamily: FontFamily.interBold,
              color: textColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: _sp(context, 9.5),
              fontFamily: FontFamily.interMedium,
              color: subtitleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? badge,
    bool isWarningBadge = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: _sp(context, 13),
                color: const Color(0xFF5B4DFF),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: _sp(context, 10.5),
                    fontFamily: FontFamily.interMedium,
                    color: subtitleColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: _sp(context, 12.5),
              fontFamily: FontFamily.interBold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (badge != null && badge.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: isWarningBadge
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: _sp(context, 9.5),
                  fontFamily: FontFamily.interSemiBold,
                  color: isWarningBadge
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF5B4DFF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
