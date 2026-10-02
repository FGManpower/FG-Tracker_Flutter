import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';

import '../Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/gen/assets.gen.dart';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalkieTalkieTrialDetailsScreen extends StatefulWidget {
  const WalkieTalkieTrialDetailsScreen({
    super.key,
  });

  @override
  State<WalkieTalkieTrialDetailsScreen> createState() =>
      _WalkieTalkieTrialDetailsScreenState();
}

class _WalkieTalkieTrialDetailsScreenState
    extends State<WalkieTalkieTrialDetailsScreen> {
  late final WalkieTalkieTrialController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WalkieTalkieTrialController>()
        ? Get.find<WalkieTalkieTrialController>()
        : Get.put(WalkieTalkieTrialController());
  }

  static const Color primaryColor = AppColors.primaryDarkblue;

  static const Color textColor = AppColors.authTextNavy;

  static const Color subtitleColor = AppColors.primarySecondaryElementText;

  static const Color backgroundColor = AppColors.primarySecondaryBackground;

  // =====================================================
  // RESPONSIVE FONT SCALING HELPER (Mobile / Tab / PC)
  // =====================================================

  double _sp(double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return size;
    }
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 550;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Obx(() {
          final bool isSkeletonLoading =
              controller.isLoading.value && controller.data == null;

          final Widget scrollContent = RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              await controller.fetchOverview(
                refresh: true,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Skeletonizer(
                enabled: isSkeletonLoading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (controller.isRefreshing.value)
                      const LinearProgressIndicator(
                        color: primaryColor,
                        minHeight: 2,
                      ),
                    _buildTopErrorBanner(),
                    _buildHeroGraphic(),
                    SizedBox(height: 6.h),
                    _buildHeadingSection(),
                    SizedBox(height: 8.h),
                    _buildFreeTrialStatusCard(),
                    SizedBox(height: 8.h),
                    _buildFeaturesAndCtaCard(context),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          );

          if (isWideScreen) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: scrollContent,
              ),
            );
          }

          return scrollContent;
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.errorMessage.value.isNotEmpty &&
            controller.data == null) {
          return const SizedBox.shrink();
        }

        // ===============================================
        // SUBSCRIBED USER
        // ===============================================

        if (controller.hasActiveSubscription) {
          return const SizedBox.shrink();
        }

        // ===============================================
        // BACKEND DOES NOT WANT SUBSCRIBE CTA
        // ===============================================

        if (controller.data != null &&
            !controller.showSubscribe) {
          return const SizedBox.shrink();
        }

        final bool isSkeletonLoading =
            controller.isLoading.value &&
                controller.data == null;

        Widget bar = Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            10.h,
          ),
          child: Skeletonizer(
            enabled: isSkeletonLoading,
            child: _buildPurchasePlanCard(
              isBottomBar: true,
            ),
          ),
        );

        if (isWideScreen) {
          return Center(
            child: Container(
              constraints:
              const BoxConstraints(
                maxWidth: 520,
              ),
              color: backgroundColor,
              child: SafeArea(
                top: false,
                child: bar,
              ),
            ),
          );
        }

        return Container(
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: bar,
          ),
        );
      }),
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar() {
    final bool isWideScreen = MediaQuery.of(context).size.width > 550;

    Widget titleRow = Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 38.w.clamp(34.0, 44.0),
            height: 38.w.clamp(34.0, 44.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back,
              size: _sp(19),
              color: primaryColor,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              reausabletext(
                "Walkie Talkie",
                fontsize: _sp(17),
                fontfamily: FontFamily.interBold,
                color: textColor,
              ),
              SizedBox(height: 1.h),
              reausabletext(
                "Instantly communicate with your group",
                fontsize: _sp(11.5),
                color: subtitleColor,
              ),
            ],
          ),
        ),
      ],
    );

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 54.h.clamp(50.0, 65.0),
      automaticallyImplyLeading: false,
      title: isWideScreen
          ? Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                child: titleRow,
              ),
            )
          : titleRow,
    );
  }

  // =====================================================
  // TOP ERROR / NO INTERNET BANNER
  // =====================================================

  Widget _buildTopErrorBanner() {
    final msg = controller.errorMessage.value;
    if (msg.isEmpty) return const SizedBox.shrink();

    final bool isOffline = msg.toLowerCase().contains('internet') ||
        msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('connection');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.info_outline_rounded,
            size: _sp(18),
            color: const Color(0xFFDC2626),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              isOffline
                  ? "No internet connection. Please check your network."
                  : msg,
              style: TextStyle(
                fontSize: _sp(11.5),
                color: const Color(0xFF991B1B),
                fontFamily: FontFamily.interMedium,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => controller.fetchOverview(refresh: true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: _sp(11.5),
                  fontFamily: FontFamily.interSemiBold,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HERO GRAPHIC
  // =====================================================

  Widget _buildHeroGraphic() {
    return SizedBox(
      width: double.infinity,
      child: BlendMask(
        blendMode: BlendMode.multiply,
        child: Assets.walkieTalkie.walkieTrialHero.image(
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  // =====================================================
  // HEADING
  // =====================================================

  Widget _buildHeadingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: Column(
        children: [
          reausabletext(
            "Stay Connected, Talk Instantly",
            fontsize: _sp(17.5),
            fontfamily: FontFamily.interBold,
            color: textColor,
            align: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Text(
            "Use push-to-talk voice communication with your group\nwithout making a phone call.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(11.5),
              color: subtitleColor,
              fontFamily: FontFamily.interRegular,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TRIAL OR SUBSCRIPTION STATUS CARD
  // =====================================================

  Widget _buildFreeTrialStatusCard() {
    if (controller.hasActiveSubscription) {
      return _buildActiveSubscriptionCard();
    }

    final bool trialActive = controller.isTrialActive;
    final bool trialExpired = controller.showTrialExpired;
    final bool trialEligible = controller.isTrialEligible;

    String title = "FREE TRIAL";
    String? subtitle;
    String description =
        "Use your ${controller.trialDurationFormatted} trial anytime within 7 days.";

    if (trialActive) {
      title = "TRIAL ACTIVE";
      subtitle = "Free Trial Running";
      description = "Enjoy Walkie Talkie during your trial.";
    } else if (trialExpired) {
      title = "TRIAL EXPIRED";
      subtitle = "Your Trial Has Ended";
      description = "Choose a subscription to continue.";
    } else if (trialEligible || controller.data == null) {
      title = "FREE TRIAL";
      subtitle = null;
      description =
          "Use your ${controller.trialDurationFormatted} trial anytime within 7 days.";
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // -----------------------------------------
          // Trial header
          // -----------------------------------------
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
                  size: _sp(24),
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
                          fontsize: _sp(12.5),
                          fontfamily: FontFamily.interBold,
                          color: textColor,
                        ),
                        if (title == "FREE TRIAL") ...[
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
                                  size: _sp(11),
                                  color: primaryColor,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  controller.trialDurationFormatted,
                                  style: TextStyle(
                                    fontSize: _sp(10.5),
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
                        fontsize: _sp(14.5),
                        fontfamily: FontFamily.interBold,
                        color: primaryColor,
                      ),
                    ],
                    SizedBox(height: 3.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: _sp(11),
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

          // -----------------------------------------
          // Trial usage
          // -----------------------------------------
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
                      fontsize: _sp(11.5),
                      fontfamily: FontFamily.interMedium,
                      color: textColor,
                    ),
                    reausabletext(
                      controller.usageLabel,
                      fontsize: _sp(11.5),
                      fontfamily: FontFamily.interSemiBold,
                      color: textColor,
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Dynamic progress bar
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

                // -----------------------------------
                // Countdown / trial status
                // -----------------------------------
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
                            trialExpired
                                ? Icons.timer_off_outlined
                                : Icons.hourglass_empty_rounded,
                            size: _sp(13),
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        reausabletext(
                          trialActive
                              ? "Trial Time Remaining"
                              : trialExpired
                                  ? "Trial Expired"
                                  : "7 Days Trial Period",
                          fontsize: _sp(11),
                          fontfamily: FontFamily.interMedium,
                          color: textColor,
                        ),
                      ],
                    ),
                    reausabletext(
                      trialActive
                          ? controller.remainingLabel
                          : trialExpired
                              ? "Expired"
                              : "Expires in 7 days",
                      fontsize: _sp(11),
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
  }

  // =====================================================
  // ACTIVE SUBSCRIPTION CARD (REDESIGNED)
  // =====================================================

  Widget _buildActiveSubscriptionCard() {
    final allSubs = controller.allActiveSubscriptions;
    final bool isOwned = controller.isCurrentSubscriptionOwnedByMe;

    final String planName = controller.subscriptionPlanName.isNotEmpty
        ? controller.subscriptionPlanName
        : "Walkie Talkie Plan";
    final bool isTeam =
        controller.isGroupSubscription || (controller.purchasedSeats > 1);
    final int seats =
        controller.purchasedSeats > 0 ? controller.purchasedSeats : 1;
    final String interval = controller.subscriptionBillingInterval.isNotEmpty
        ? (controller.subscriptionBillingInterval[0].toUpperCase() +
            controller.subscriptionBillingInterval.substring(1))
        : "Subscription";

    final DateTime? expiresAt = controller.subscriptionExpiresAt;
    final DateTime? startsAt = controller.subscriptionStartsAt;

    String expiryDateFormatted = "Active";
    String daysLeftText = "";
    bool isExpiringSoon = false;

    if (expiresAt != null) {
      expiryDateFormatted =
          DateFormat('dd MMM yyyy').format(expiresAt.toLocal());
      final difference = expiresAt.difference(DateTime.now());
      final days = difference.inDays;
      if (days > 0) {
        daysLeftText = "$days days left";
        if (days <= 5) isExpiringSoon = true;
      } else if (difference.inHours > 0) {
        daysLeftText = "${difference.inHours} hours left";
        isExpiringSoon = true;
      } else {
        daysLeftText = "Expiring today";
        isExpiringSoon = true;
      }
    }

    String startsDateFormatted = "";
    if (startsAt != null) {
      startsDateFormatted =
          DateFormat('dd MMM yyyy').format(startsAt.toLocal());
    }

    final bool hasMultipleSubs = allSubs.length > 1;

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
          // If user has multiple active subscriptions, display horizontal selector
          if (hasMultipleSubs) _buildSubscriptionSwitcher(allSubs),

          // Top header with plan name, active pill, and ownership badge
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: hasMultipleSubs ? Radius.zero : Radius.circular(20.r),
                topRight: hasMultipleSubs ? Radius.zero : Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: _sp(24),
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
                                fontSize: _sp(15),
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
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "ACTIVE",
                                  style: TextStyle(
                                    fontSize: _sp(9.5),
                                    fontFamily: FontFamily.interBold,
                                    color: const Color(0xFF047857),
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
                              color: isTeam
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              isTeam ? "Team Plan" : "Individual Plan",
                              style: TextStyle(
                                fontSize: _sp(10.5),
                                fontFamily: FontFamily.interSemiBold,
                                color: isTeam
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFFC2410C),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isOwned
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: isOwned
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFE2E8F0),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOwned
                                      ? Icons.check_circle_rounded
                                      : Icons.info_outline_rounded,
                                  size: _sp(10.5),
                                  color: isOwned
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  isOwned ? "Subscribed by You" : "Assigned to You",
                                  style: TextStyle(
                                    fontSize: _sp(9.5),
                                    fontFamily: FontFamily.interSemiBold,
                                    color: isOwned
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
                              fontSize: _sp(11),
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

          // Plan details summary grid
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSubDetailTile(
                        icon: Icons.calendar_today_rounded,
                        label: "Valid Until",
                        value: expiryDateFormatted,
                        badge: daysLeftText.isNotEmpty ? daysLeftText : null,
                        isWarningBadge: isExpiringSoon,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildSubDetailTile(
                        icon: isTeam
                            ? Icons.groups_rounded
                            : Icons.person_rounded,
                        label: "Seats / Members",
                        value: isTeam ? "$seats Seats" : "1 Seat (Self)",
                        badge: isTeam ? "Team Access" : "Personal",
                      ),
                    ),
                  ],
                ),
                if (startsDateFormatted.isNotEmpty) ...[
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
                          Icons.verified_user_outlined,
                          size: _sp(14),
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Active since $startsDateFormatted",
                          style: TextStyle(
                            fontSize: _sp(10.5),
                            color: const Color(0xFF64748B),
                            fontFamily: FontFamily.interMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 12.h),

                // Quick actions row
                Row(
                  children: [
                    if (isTeam && isOwned) ...[
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
                            size: _sp(15),
                            color: const Color(0xFF5B4DFF),
                          ),
                          label: Text(
                            "Assign Members",
                            style: TextStyle(
                              fontSize: _sp(11.5),
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
                        onPressed: _openPlanDetails,
                        icon: Icon(
                          Icons.sync_alt_rounded,
                          size: _sp(15),
                          color: textColor,
                        ),
                        label: Text(
                          "Change Plan",
                          style: TextStyle(
                            fontSize: _sp(11.5),
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

  Widget _buildSubscriptionSwitcher(
    List<WalkieCurrentSubscription> allSubs,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FD),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers_outlined,
                size: _sp(14),
                color: const Color(0xFF4338CA),
              ),
              SizedBox(width: 5.w),
              reausabletext(
                "Subscribed Plans (${allSubs.length})",
                fontsize: _sp(11.5),
                fontfamily: FontFamily.interBold,
                color: const Color(0xFF312E81),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: allSubs.map((sub) {
                final isSelected =
                    controller.currentSubscription?.id == sub.id;
                final isOwned = controller.isOwnedByCurrentUser(sub);
                final String planTitle = sub.plan?.name.isNotEmpty == true
                    ? sub.plan!.name
                    : (sub.isGroup ? "Team Plan" : "Individual Plan");

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () {
                        controller.selectSubscription(sub);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : const Color(0xFFD1D5DB),
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        primaryColor.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              sub.isGroup || sub.purchasedSeats > 1
                                  ? Icons.groups_rounded
                                  : Icons.person_rounded,
                              size: _sp(13),
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF4B5563),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              planTitle,
                              style: TextStyle(
                                fontSize: _sp(11),
                                fontFamily: isSelected
                                    ? FontFamily.interBold
                                    : FontFamily.interMedium,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.22)
                                    : isOwned
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                isOwned ? "Subscribed by You" : "Assigned",
                                style: TextStyle(
                                  fontSize: _sp(9),
                                  fontFamily: FontFamily.interSemiBold,
                                  color: isSelected
                                      ? Colors.white
                                      : isOwned
                                          ? const Color(0xFF047857)
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubDetailTile({
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
                size: _sp(13),
                color: const Color(0xFF5B4DFF),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: _sp(10.5),
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
              fontSize: _sp(12.5),
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
                  fontSize: _sp(9.5),
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

  // =====================================================
  // FEATURES AND CTA CARD
  // =====================================================

  Widget _buildFeaturesAndCtaCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.mic_rounded,
                        title: "Push-to-talk\ncommunication",
                      ),
                      SizedBox(height: 10.h),
                      _buildFeatureItem(
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
                        icon: Icons.touch_app_rounded,
                        title: "Hold to talk",
                      ),
                      SizedBox(height: 10.h),
                      _buildFeatureItem(
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

          // -----------------------------------------
          // Dynamic CTA
          // -----------------------------------------
          Builder(
            builder: (context) {
              final bool canUse = controller.canUseWalkie;
              final bool eligible = controller.isTrialEligible;

              // Trial already used and user has no active subscription -> Show Purchase CTA
              if (controller.data != null && !canUse && !eligible) {
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
                    onPressed: _openPlanDetails,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: _sp(20),
                        ),
                        SizedBox(width: 8.w),
                        reausabletext(
                          "Purchase / Upgrade Plan",
                          fontsize: _sp(15),
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
                      Get.to(
                        () => const WalkieGroupSelectScreen(),
                      );
                      return;
                    }
                    _showStartFreeTrialBottomSheet(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canUse ? Icons.mic_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: _sp(20),
                      ),
                      SizedBox(width: 8.w),
                      reausabletext(
                        canUse
                            ? "Open Walkie Talkie"
                            : "Start ${controller.trialDurationHuman} Free Trial",
                        fontsize: _sp(15),
                        fontfamily: FontFamily.interBold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FEATURE ITEM
  // =====================================================

  Widget _buildFeatureItem({
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
            size: _sp(18),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: _sp(11.5),
              fontFamily: FontFamily.interMedium,
              color: textColor,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PURCHASE PLAN CARD
  // =====================================================

  Widget _buildPurchasePlanCard({bool isBottomBar = false}) {
    return GestureDetector(
        onTap: _openPlanDetails,
        child: Container(
          margin: isBottomBar
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
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
                      size: _sp(24),
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
                      "After your free trial",
                      fontsize: _sp(10.5),
                      color: subtitleColor,
                      maxline: 1,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "${controller.priceLabel} / ${controller.priceTypeLabel}",
                      fontsize: _sp(14.5),
                      fontfamily: FontFamily.interBold,
                      color: textColor,
                      maxline: 1,
                    ),
                    SizedBox(height: 1.h),
                    reausabletext(
                      "Continue with Walkie Talkie",
                      fontsize: _sp(10),
                      color: subtitleColor,
                      maxline: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: _openPlanDetails,
                child: Container(
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
                    fontsize: _sp(11.5),
                    fontfamily: FontFamily.interSemiBold,
                    color: primaryColor,
                    maxline: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _openPlanDetails() {
    Get.to(
      () => const WalkieTalkiePlanDetails(
        initialTabIndex: 0,
      ),
    );
  }

  // =====================================================
  // START FREE TRIAL BOTTOM SHEET
  // =====================================================

  void _showStartFreeTrialBottomSheet(
    BuildContext context,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final double maxHeight = MediaQuery.of(ctx).size.height * 0.88;
        final bool isWideScreen = MediaQuery.of(ctx).size.width > 550;

        Widget sheet = Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28.r),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 12.h,
                        bottom: 14.h,
                      ),
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4B7CC),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // -----------------------------------
                  // Heading
                  // -----------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reausabletext(
                              "Start Your Free Trial",
                              fontsize: _sp(20),
                              fontfamily: FontFamily.interBold,
                              color: textColor,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Enjoy all Walkie Talkie features free for ${controller.trialDurationHuman}.\nNo payment required.",
                              style: TextStyle(
                                fontSize: _sp(12),
                                color: subtitleColor,
                                fontFamily: FontFamily.interRegular,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: _sp(18),
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // -----------------------------------
                  // Trial highlights box (Dynamic Duration Free | Valid for 7 Days)
                  // -----------------------------------
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFECEBFA),
                        width: 1.2,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Dynamic Duration Free
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 42.w.clamp(36.0, 46.0),
                                  height: 42.w.clamp(36.0, 46.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EFFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.gift_fill,
                                    color: primaryColor,
                                    size: _sp(20),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      reausabletext(
                                        controller.trialDurationFreeLabel,
                                        fontsize: _sp(13),
                                        fontfamily: FontFamily.interBold,
                                        color: textColor,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "Full access to all features",
                                        style: TextStyle(
                                          fontSize: _sp(10),
                                          color: subtitleColor,
                                          fontFamily: FontFamily.interRegular,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vertical divider
                          Container(
                            width: 1,
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            color: const Color(0xFFECEBFA),
                          ),

                          // Valid for 7 Days
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 42.w.clamp(36.0, 46.0),
                                  height: 42.w.clamp(36.0, 46.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EFFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.hourglass,
                                    color: primaryColor,
                                    size: _sp(20),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      reausabletext(
                                        "Valid for 7 Days",
                                        fontsize: _sp(13),
                                        fontfamily: FontFamily.interBold,
                                        color: textColor,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "Use trial anytime in 7 days",
                                        style: TextStyle(
                                          fontSize: _sp(10),
                                          color: subtitleColor,
                                          fontFamily: FontFamily.interRegular,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  reausabletext(
                    "What you can do during the trial",
                    fontsize: _sp(15),
                    fontfamily: FontFamily.interBold,
                    color: textColor,
                  ),

                  SizedBox(height: 10.h),

                  // -----------------------------------
                  // Features row 1 (Group Communication & Unlimited Usage)
                  // -----------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrialMiniFeature(
                          icon: Icons.groups_rounded,
                          title: "Group Communication",
                          desc: "Connect with your team",
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildTrialMiniFeature(
                          icon: Icons.all_inclusive_rounded,
                          title: "Unlimited Usage",
                          desc: "Use without any limits",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // -----------------------------------
                  // Features row 2 (Push-to-talk & Clear Audio)
                  // -----------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrialMiniFeature(
                          icon: Icons.mic_rounded,
                          title: "Push-to-talk",
                          desc: "Instant voice communication",
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildTrialMiniFeature(
                          icon: Icons.sensors_rounded,
                          title: "Clear Audio",
                          desc: "High quality voice",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // -----------------------------------
                  // Subscription info banner
                  // -----------------------------------
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3FF),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: primaryColor,
                          size: _sp(19),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            "No payment needed now. After your trial, you can choose to continue with a paid plan (${controller.priceLabel.isNotEmpty && controller.priceLabel != 'Price unavailable' ? controller.priceLabel : '₹500'}/person) if you like.",
                            style: TextStyle(
                              fontSize: _sp(11),
                              color: const Color(0xFF5B5299),
                              fontFamily: FontFamily.interMedium,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // -----------------------------------
                  // Trial activation button
                  // -----------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 50.h.clamp(46.0, 56.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            14.r,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Get.to(() => const WalkieGroupSelectScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: _sp(22),
                          ),
                          SizedBox(width: 8.w),
                          reausabletext(
                            "Start ${controller.trialDurationHuman} Free Trial",
                            fontsize: _sp(15.5),
                            fontfamily: FontFamily.interBold,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Center(
                    child: reausabletext(
                      "Use anytime within 7 days  •  No credit card required",
                      fontsize: _sp(11),
                      color: subtitleColor,
                      align: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ),
        );

        if (isWideScreen) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              child: sheet,
            ),
          );
        }

        return sheet;
      },
    );
  }

  // =====================================================
  // TRIAL HIGHLIGHT CARD
  // =====================================================

  Widget _buildTrialHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFE9E5FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: const BoxDecoration(
              color: Color(0xFFECEBFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B4DFF),
              size: _sp(18),
            ),
          ),
          SizedBox(height: 10.h),
          reausabletext(
            title,
            fontsize: _sp(13),
            fontfamily: FontFamily.interBold,
            color: textColor,
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: _sp(10.5),
              color: subtitleColor,
              fontFamily: FontFamily.interRegular,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TRIAL MINI FEATURE
  // =====================================================

  Widget _buildTrialMiniFeature({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFECEBFA),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: _sp(19),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  title,
                  fontsize: _sp(12.5),
                  fontfamily: FontFamily.interBold,
                  color: textColor,
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: _sp(10.5),
                    color: subtitleColor,
                    fontFamily: FontFamily.interRegular,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LOADING STATE
  // =====================================================

  Widget _buildLoadingState() {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Skeleton Hero Graphic
            Container(
              height: 180.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),

            SizedBox(height: 6.h),

            // Skeleton Heading Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Container(
                    height: 22.h,
                    width: 220.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 14.h,
                    width: 260.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Skeleton Status Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(14.w),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EFFF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              height: 18.h,
                              width: 140.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    height: 8.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Skeleton Features and CTA Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(14.w),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 48.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    final msg = controller.errorMessage.value;
    final bool isOffline = msg.toLowerCase().contains('internet') ||
        msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('connection');

      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 84.w.clamp(74.0, 96.0),
                height: 84.w.clamp(74.0, 96.0),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOffline
                      ? Icons.wifi_off_rounded
                      : Icons.cloud_off_rounded,
                  size: _sp(40),
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 18.h),
              reausabletext(
                isOffline ? "No Internet Connection" : "Unable to Load Walkie Talkie",
                fontsize: _sp(17),
                fontfamily: FontFamily.interBold,
                color: textColor,
                align: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  msg.isNotEmpty
                      ? msg
                      : "Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _sp(12.5),
                    color: subtitleColor,
                    fontFamily: FontFamily.interRegular,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                height: 44.h.clamp(40.0, 48.0),
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.fetchOverview();
                        },
                  icon: controller.isLoading.value
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: _sp(17),
                        ),
                  label: Text(
                    controller.isLoading.value ? "Retrying..." : "Try Again",
                    style: TextStyle(
                      fontSize: _sp(13.5),
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1.5,
                    shadowColor: primaryColor.withValues(alpha: 0.3),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // =====================================================
  // COMMON CARD DECORATION
  // =====================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: 0.03,
          ),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
