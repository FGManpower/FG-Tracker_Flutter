import 'dart:math' as math;

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/auto_fit_text.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';

enum _ExpiredReason { timeUsedUp, dateEnded, unknown }

/// New trial card (Active / Expired). Old WalkieTrialCard is kept for "not started".
class WalkieTrialStatusCard extends StatelessWidget {
  const WalkieTrialStatusCard({super.key});

  static const Color _purple = AppColors.primaryDarkblue; // #704AFA
  static const Color _iconBg = AppColors.authIconBgCircle; // #EEEDFD
  static const Color _navy = Color(0xFF1A1446);
  static const Color _grey = Color(0xFF666666);
  static const Color _greyDark = Color(0xFF4A4A4A);
  static const Color _border = Color(0xFFECECF2);
  static const Color _green = Color(0xFF2F8A5B);
  static const Color _red = Color(0xFFD64545);

  double _sp(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return size;
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  /// 45 sec | 4 min 18 sec | 4 min | 1 hr 5 min
  static String formatDuration(int sec) {
    final s = math.max(0, sec);
    final t = appL10n;
    if (s < 60) return t.walkiePlan_trialSec(s);
    if (s < 3600) {
      final m = s ~/ 60, r = s % 60;
      return r == 0 ? t.walkiePlan_trialMin(m) : t.walkiePlan_trialMinSec(m, r);
    }
    final h = s ~/ 3600, m = (s % 3600) ~/ 60;
    return m == 0 ? t.walkiePlan_trialHr(h) : t.walkiePlan_trialHrMin(h, m);
  }

  /// < 7200 → "60 min", else "2 hr"
  static String formatTotal(int sec) => sec < 7200
      ? appL10n.walkiePlan_trialMin(sec ~/ 60)
      : appL10n.walkiePlan_trialHr(sec ~/ 3600);

  /// "28 Oct 2026"
  static String formatDate(DateTime d) =>
      appDateFormat('d MMM yyyy').format(d.toLocal());

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalkieTalkieTrialController>();

    return Obx(() {
      // Read remainingSeconds so the card updates when the controller does
      controller.remainingSeconds.value;
      final trial = controller.trial;
      if (trial == null) return const SizedBox.shrink();

      final bool isActive = controller.isTrialActive;
      final int total = controller.totalSeconds;
      final int used = controller.usedSeconds;
      final int remaining = math.max(0, total - used);
      final double progress =
          total <= 0 ? 0.0 : (used / total).clamp(0.0, 1.0).toDouble();
      final DateTime? endDate = trial.expiresAt;

      final _ExpiredReason reason = used >= total
          ? _ExpiredReason.timeUsedUp
          : endDate != null
              ? _ExpiredReason.dateEnded
              : _ExpiredReason.unknown;

      final l10n = context.l10n;
      final String label = isActive
          ? l10n.walkiePlan_trialFreeTrialLabel
          : l10n.walkiePlan_trialExpiredLabel;
      final String title =
          isActive ? l10n.walkiePlan_trialIsActive : l10n.walkiePlan_trialHasEnded;
      final String subtitle = isActive
          ? (endDate != null
              ? l10n.walkiePlan_trialTalkFreeTill(formatDate(endDate))
              : l10n.walkiePlan_trialTalkFree)
          : l10n.walkiePlan_trialChooseSubscription;
      final String bottomLeft = isActive
          ? l10n.walkiePlan_trialTimeLeft(formatDuration(remaining))
          : switch (reason) {
              _ExpiredReason.timeUsedUp => l10n.walkiePlan_trialTimeUsedUp,
              _ExpiredReason.dateEnded =>
                l10n.walkiePlan_trialEndedOn(formatDate(endDate!)),
              _ExpiredReason.unknown => l10n.walkiePlan_trialExpired,
            };

      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 14.h, left: 16.w, right: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D101040), // rgba(16,16,64,0.05)
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: icon + label / title / subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(CupertinoIcons.gift,
                      size: _sp(context, 22), color: _purple),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                            fontSize: _sp(context, 11),
                            fontFamily: FontFamily.interBold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.66,
                            color: _navy,
                          )),
                      SizedBox(height: 3.h),
                      Text(title,
                          style: TextStyle(
                            fontSize: _sp(context, 16),
                            fontFamily: FontFamily.interBold,
                            fontWeight: FontWeight.w700,
                            color: _purple,
                          )),
                      SizedBox(height: 3.h),
                      Text(subtitle,
                          style: TextStyle(
                            fontSize: _sp(context, 12),
                            fontFamily: FontFamily.interRegular,
                            color: _grey,
                            height: 1.4,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Inner usage box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: _border, width: 1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.walkiePlan_trialUsage,
                          style: TextStyle(
                            fontSize: _sp(context, 13),
                            fontFamily: FontFamily.interMedium,
                            fontWeight: FontWeight.w500,
                            color: _navy,
                          )),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: formatDuration(used),
                                style: TextStyle(
                                  fontSize: _sp(context, 13),
                                  fontFamily: FontFamily.interBold,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${formatTotal(total)}',
                                style: TextStyle(
                                  fontSize: _sp(context, 13),
                                  fontFamily: FontFamily.interRegular,
                                  color: _grey,
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Progress bar (min 4px fill when used > 0)
                  LayoutBuilder(builder: (context, c) {
                    double fill = c.maxWidth * progress;
                    if (used > 0 && fill < 4) fill = 4;
                    return Container(
                      height: 6,
                      width: c.maxWidth,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        height: 6,
                        width: fill,
                        decoration: BoxDecoration(
                          color: _purple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 10.h),

                  Row(
                    children: [
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: _iconBg,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Icon(Icons.access_time_rounded,
                            size: _sp(context, 13), color: _purple),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(bottomLeft,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _sp(context, 12),
                              fontFamily: FontFamily.interRegular,
                              color: _greyDark,
                            )),
                      ),
                      SizedBox(width: 8.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 110.w),
                        child: AutoFitText(
                            isActive
                                ? l10n.walkiePlan_cardActive
                                : l10n.walkiePlan_trialStatusExpired,
                            style: TextStyle(
                              fontSize: _sp(context, 12),
                              fontFamily: FontFamily.interSemiBold,
                              fontWeight: FontWeight.w600,
                              color: isActive ? _green : _red,
                            )),
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
