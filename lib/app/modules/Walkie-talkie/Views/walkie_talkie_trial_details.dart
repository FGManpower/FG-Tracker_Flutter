import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_features_card.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_hero_section.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_individual_plan_card.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_purchase_bottom_bar.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_team_plan_card.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/walkie_trial_card.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  double _sp(double size) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return size;
    return size.sp.clamp(size * 0.85, size * 1.25);
  }

  // =====================================================
  // MAIN BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 550;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isWideScreen),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Obx(() {
          final bool isSkeletonLoading =
              controller.isLoading.value && controller.data == null;

          if (controller.errorMessage.value.isNotEmpty &&
              controller.data == null &&
              !controller.isLoading.value) {
            return _buildErrorState();
          }

          final Widget scrollContent = RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              await controller.fetchOverview(refresh: true);
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
                     WalkieHeroSection(),
                    SizedBox(height: 8.h),

                    // =====================================================
                    // 1. TRIAL CARD (Shows whenever trial exists)
                    // =====================================================
                    if (controller.shouldShowTrialCard || isSkeletonLoading) ...[
                      const WalkieTrialCard(),
                      SizedBox(height: 12.h),
                    ],

                    // =====================================================
                    // 2. ACTIVE SUBSCRIPTIONS SECTION
                    // =====================================================
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: _sp(15),
                            color: primaryColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Active Subscriptions",
                            style: TextStyle(
                              fontSize: _sp(14),
                              fontFamily: FontFamily.interBold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Individual Plan Card (Active or "No Active Plan")
                    WalkieIndividualPlanCard(
                      plan: controller.activeIndividualSubscription,
                      hasActiveSubscription:
                          controller.hasActiveIndividualSubscription,
                    ),
                    SizedBox(height: 10.h),

                    // Team Plan Card(s) (Active or "No Active Plan")
                    if (controller.hasActiveTeamSubscription &&
                        controller.activeTeamSubscriptions.isNotEmpty) ...[
                      for (int i = 0;
                          i < controller.activeTeamSubscriptions.length;
                          i++) ...[
                        WalkieTeamPlanCard(
                          plan: controller.activeTeamSubscriptions[i],
                          hasActiveSubscription: true,
                        ),
                        if (i < controller.activeTeamSubscriptions.length - 1)
                          SizedBox(height: 10.h),
                      ],
                    ] else ...[
                      WalkieTeamPlanCard(
                        plan: null,
                        hasActiveSubscription: false,
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // =====================================================
                    // 3. FEATURES CARD & PRIMARY ACTION BUTTON
                    // =====================================================
                    WalkieFeaturesCard(
                      onStartTrialPressed: () {
                        _showStartFreeTrialBottomSheet(context);
                      },
                    ),
                    SizedBox(height: 24.h),
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

        // Only show bottom purchase bar when user doesn't have an active subscription
        if (!controller.shouldShowPurchaseCTA) {
          return const SizedBox.shrink();
        }

        final bool isSkeletonLoading =
            controller.isLoading.value && controller.data == null;

        Widget bar = Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          child: Skeletonizer(
            enabled: isSkeletonLoading,
            child: const WalkiePurchaseBottomBar(),
          ),
        );

        if (isWideScreen) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
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

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
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
                  color: Colors.black.withValues(alpha: 0.05),
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
  // TOP ERROR BANNER
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
                isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
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
  // START FREE TRIAL BOTTOM SHEET
  // =====================================================

  void _showStartFreeTrialBottomSheet(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 14.h),
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4B7CC),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
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
                          Container(
                            width: 1,
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            color: const Color(0xFFECEBFA),
                          ),
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
                                        "7 Days Trial Period",
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
                            "No payment needed now. After your trial, you can choose to continue with a paid plan (${controller.priceLabel}/person) if you like.",
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
                  SizedBox(
                    width: double.infinity,
                    height: 50.h.clamp(46.0, 56.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
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
}
