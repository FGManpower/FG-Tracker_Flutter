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

  static const Color primaryColor = Color(0xFF5B4DFF);

  static const Color textColor = Color(0xFF1E1B4B);

  static const Color subtitleColor = Color(0xFF6B7280);

  static const Color backgroundColor = Color(0xFFF6F8FE);

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
        if (controller.errorMessage.value.isNotEmpty) {
          return const SizedBox.shrink();
        }

        final bool isSkeletonLoading =
            controller.isLoading.value && controller.data == null;

        Widget bar = Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          child: Skeletonizer(
            enabled: isSkeletonLoading,
            child: _buildPurchasePlanCard(isBottomBar: true),
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
  // TRIAL STATUS CARD
  // =====================================================

  Widget _buildFreeTrialStatusCard() {
    final trial = controller.trial;
    final bool hasSubscription = controller.hasActiveSubscription;
      final bool trialActive = controller.isTrialActive;
      final bool trialExpired = controller.showTrialExpired;
      final bool trialEligible = controller.isTrialEligible;

      String title = "FREE TRIAL";
      String? subtitle;
      String description =
          "Use your ${controller.trialDurationFormatted} trial anytime within 7 days.";

      if (hasSubscription) {
        title = "ACTIVE SUBSCRIPTION";
        subtitle = "Walkie Talkie Active";
        description = "Your subscription is currently active.";
      } else if (trialActive) {
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
        padding: EdgeInsets.all(13.w),
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
                                    : hasSubscription
                                        ? "Subscription Active"
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
                                : hasSubscription
                                    ? "Active"
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
  // FEATURES AND CTA CARD
  // =====================================================

  Widget _buildFeaturesAndCtaCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(13.w),
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
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
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
          SizedBox(height: 12.h),

          // -----------------------------------------
          // Dynamic CTA
          // -----------------------------------------
          Builder(
            builder: (context) {
              final bool canUse = controller.canUseWalkie;
              final bool eligible = controller.isTrialEligible;

              // Trial already used and user has no active subscription
              if (controller.data != null && !canUse && !eligible) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
                        fontsize: _sp(15.5),
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
          width: 34.w.clamp(30.0, 40.0),
          height: 34.w.clamp(30.0, 40.0),
          decoration: const BoxDecoration(
            color: Color(0xFFF0EFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: _sp(17),
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
              height: 1.2,
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
