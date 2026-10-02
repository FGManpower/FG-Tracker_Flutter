import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalkieAssignedTeamSeatCard extends StatelessWidget {
  final WalkieTeamSeat seat;

  const WalkieAssignedTeamSeatCard({
    super.key,
    required this.seat,
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
    final controller = Get.find<WalkieTalkieTrialController>();

    final String planName =
        seat.planName.isNotEmpty ? seat.planName : "Team Access";

    String expiryDateFormatted = "Active";
    String daysLeftText = "";
    bool isExpiringSoon = false;

    if (seat.expiresAt != null) {
      expiryDateFormatted =
          DateFormat('dd MMM yyyy').format(seat.expiresAt!.toLocal());
      daysLeftText = controller.formatDaysRemaining(seat.expiresAt);
      final difference = seat.expiresAt!.difference(DateTime.now());
      if (difference.inDays <= 5) {
        isExpiringSoon = true;
      }
    }

    String startsDateFormatted = "";
    if (seat.startsAt != null) {
      startsDateFormatted =
          DateFormat('dd MMM yyyy').format(seat.startsAt!.toLocal());
    }

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
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
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
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.how_to_reg_rounded,
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
                              color: seat.isActive
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: seat.isActive
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
                                    color: seat.isActive
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  seat.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: _sp(context, 9.5),
                                    fontFamily: FontFamily.interBold,
                                    color: seat.isActive
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
                              "Team Access",
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
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: _sp(context, 10.5),
                                  color: const Color(0xFF64748B),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  "Assigned to You",
                                  style: TextStyle(
                                    fontSize: _sp(context, 9.5),
                                    fontFamily: FontFamily.interSemiBold,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ],
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

          // Details grid
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
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
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDetailTile(
                        context,
                        icon: Icons.assignment_ind_outlined,
                        label: "Seat Assignment",
                        value: "Assigned Seat",
                        badge: "Team Member",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: _sp(context, 14),
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          "Assigned by ${seat.assignedBy}",
                          style: TextStyle(
                            fontSize: _sp(context, 10.5),
                            color: const Color(0xFF64748B),
                            fontFamily: FontFamily.interMedium,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (startsDateFormatted.isNotEmpty) ...[
                        Text(
                          "• $startsDateFormatted",
                          style: TextStyle(
                            fontSize: _sp(context, 10.5),
                            color: const Color(0xFF94A3B8),
                            fontFamily: FontFamily.interRegular,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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
                color: const Color(0xFF16A34A),
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
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: _sp(context, 9.5),
                  fontFamily: FontFamily.interSemiBold,
                  color: isWarningBadge
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
