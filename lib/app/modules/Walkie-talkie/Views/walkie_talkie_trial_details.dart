
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';

import '../Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/generated/assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

  final WalkieTalkieTrialController controller =
  Get.isRegistered<WalkieTalkieTrialController>()
      ? Get.find<WalkieTalkieTrialController>()
      : Get.put(WalkieTalkieTrialController());

  static const Color primaryColor =
  Color(0xFF5B4DFF);

  static const Color textColor =
  Color(0xFF1E1B4B);

  static const Color subtitleColor =
  Color(0xFF6B7280);

  static const Color backgroundColor =
  Color(0xFFF6F8FE);

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,

      appBar: _buildAppBar(),

      body: SafeArea(

        top: false,

        bottom: false,

        child: Obx(() {

          // Initial loading

          if (
          controller.isLoading.value &&
              controller.data == null
          ) {

            return _buildLoadingState();
          }

          // Initial API error

          if (controller.data == null) {

            return _buildErrorState();
          }

          // Main screen

          return RefreshIndicator(

            color: primaryColor,

            onRefresh: () async {

              await controller.fetchOverview(
                refresh: true,
              );
            },

            child: SingleChildScrollView(

              physics:
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.center,

                children: [

                  if (controller.isRefreshing.value)
                    const LinearProgressIndicator(
                      color: primaryColor,
                      minHeight: 2,
                    ),

                  SizedBox(height: 4.h),

                  _buildHeroGraphic(),

                  SizedBox(height: 10.h),

                  _buildHeadingSection(),

                  SizedBox(height: 12.h),

                  _buildFreeTrialStatusCard(),

                  SizedBox(height: 10.h),

                  _buildFeaturesAndCtaCard(context),

                  SizedBox(height: 16.h),

                ],
              ),
            ),
          );

        }),
      ),

      bottomNavigationBar: Obx(() {
        if (!controller.showSubscribe ||
            controller.data == null ||
            controller.pricing == null ||
            controller.pricing?.available != true ||
            controller.pricing?.price == null) {
          return const SizedBox.shrink();
        }

        return Container(
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
              child: _buildPurchasePlanCard(isBottomBar: true),
            ),
          ),
        );
      }),
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 65.h,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(10.w),
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
                size: 20.sp,
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                reausabletext(
                  "Walkie Talkie",
                  fontsize: 18.sp,
                  fontfamily: FontFamily.interBold,
                  color: textColor,
                ),
                SizedBox(height: 2.h),
                reausabletext(
                  "Instantly communicate with your group",
                  fontsize: 12.sp,
                  color: subtitleColor,
                ),
              ],
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
    return Container(
      width: double.infinity,
      height: 220.h,
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      child: Center(
        child: BlendMask(
          blendMode: BlendMode.multiply,
          child: Assets.walkieTalkie.walkieTrialHero.image(
            fit: BoxFit.contain,
          ),
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
        horizontal: 24.w,
      ),
      child: Column(
        children: [
          reausabletext(
            "Stay Connected, Talk Instantly",
            fontsize: 18.sp,
            fontfamily: FontFamily.interBold,
            color: textColor,
            align: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          Text(
            "Use push-to-talk voice communication with your group\nwithout making a phone call.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: subtitleColor,
              fontFamily: FontFamily.interRegular,
              height: 1.35,
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
    return Obx(() {
      final trial = controller.trial;
      final bool hasSubscription = controller.hasActiveSubscription;
      final bool trialActive = controller.isTrialActive;
      final bool trialExpired = controller.showTrialExpired;
      final bool trialEligible = controller.isTrialEligible;

      String title = "FREE TRIAL";
      String subtitle = "1 Hour Free";
      String description = "Use your 1-hour trial anytime within 7 days.";

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
      } else if (trialEligible) {
        title = "FREE TRIAL";
        final sec = controller.totalSeconds;
        final hours = sec ~/ 3600;
        final mins = (sec % 3600) ~/ 60;
        if (hours > 0 && mins == 0) {
          subtitle = "$hours Hour Free";
        } else if (hours > 0) {
          subtitle = "$hours Hr $mins Mins Free";
        } else if (mins > 0) {
          subtitle = "$mins Mins Free";
        } else {
          subtitle = "1 Hour Free";
        }
        description = "Use your 1-hour trial anytime within 7 days.";
      }

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        padding: EdgeInsets.all(16.w),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            // -----------------------------------------
            // Trial header
            // -----------------------------------------
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFFF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: BlendMask(
                    blendMode: BlendMode.multiply,
                    child: Assets.walkieTalkie.walkieTrialGift.image(
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reausabletext(
                        title,
                        fontsize: 13.sp,
                        fontfamily: FontFamily.interBold,
                        color: textColor,
                      ),
                      SizedBox(height: 2.h),
                      reausabletext(
                        subtitle,
                        fontsize: 15.sp,
                        fontfamily: FontFamily.interBold,
                        color: primaryColor,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 11.5.sp,
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

            // -----------------------------------------
            // Trial usage
            // -----------------------------------------
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
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
                        fontsize: 12.sp,
                        fontfamily: FontFamily.interMedium,
                        color: textColor,
                      ),
                      reausabletext(
                        controller.usageLabel,
                        fontsize: 12.sp,
                        fontfamily: FontFamily.interSemiBold,
                        color: textColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Dynamic progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: LinearProgressIndicator(
                      value: controller.usageProgress,
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

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
                              size: 13.sp,
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
                            fontsize: 11.5.sp,
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
                        fontsize: 11.5.sp,
                        color: trialExpired
                            ? Colors.red
                            : subtitleColor,
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

  // =====================================================
  // FEATURES AND CTA CARD
  // =====================================================

  Widget _buildFeaturesAndCtaCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w,
      ),
      padding: EdgeInsets.all(16.w),
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
                      SizedBox(height: 14.h),
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
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.touch_app_rounded,
                        title: "Hold to talk",
                      ),
                      SizedBox(height: 14.h),
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
          SizedBox(height: 18.h),

          // -----------------------------------------
          // Dynamic CTA
          // -----------------------------------------
          Obx(() {
            final bool canUse = controller.canUseWalkie;
            final bool eligible = controller.isTrialEligible;

            // Trial already used, no active access.
            if (!canUse && !eligible) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              width: double.infinity,
              height: 48.h,
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
                      canUse
                          ? Icons.mic_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    reausabletext(
                      canUse
                          ? "Open Walkie Talkie"
                          : "Start Free Trial",
                      fontsize: 15.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }),
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
          width: 38.w,
          height: 38.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF0EFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 19.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
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
    return Obx(() {
      final pricing = controller.pricing;

      if (pricing == null ||
          pricing.available != true ||
          pricing.price == null) {
        return const SizedBox.shrink();
      }

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
            vertical: 12.h,
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
                width: 48.w,
                height: 48.w,
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Assets.walkieTalkie.walkieTrialCrown.image(
                  color: primaryColor,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    reausabletext(
                      "After your free trial",
                      fontsize: 10.5.sp,
                      color: subtitleColor,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "${controller.priceLabel} / ${controller.priceTypeLabel}",
                      fontsize: 16.sp,
                      fontfamily: FontFamily.interBold,
                      color: textColor,
                    ),
                    SizedBox(height: 2.h),
                    reausabletext(
                      "Continue with Walkie Talkie",
                      fontsize: 10.5.sp,
                      color: subtitleColor,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openPlanDetails,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
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
                    fontsize: 12.5.sp,
                    fontfamily: FontFamily.interSemiBold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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

      backgroundColor:
      Colors.transparent,

      builder: (ctx) {

        return Container(

          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.vertical(

              top: Radius.circular(28.r),
            ),
          ),

          child: SafeArea(

            top: false,

            child: SingleChildScrollView(

              child: Column(

                mainAxisSize:
                MainAxisSize.min,

                crossAxisAlignment:
                CrossAxisAlignment.start,

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

                        color:
                        const Color(0xFFB4B7CC),

                        borderRadius:
                        BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // -----------------------------------
                  // Heading
                  // -----------------------------------

                  Row(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            reausabletext(

                              "Start Your Free Trial",

                              fontsize: 19.sp,

                              fontfamily:
                              FontFamily.interBold,

                              color: textColor,
                            ),

                            SizedBox(height: 4.h),

                            Text(

                              "Enjoy Walkie Talkie features "
                                  "free for "
                                  "${controller.formatDuration(
                                controller.totalSeconds,
                              )}.\n"
                                  "No payment required.",

                              style: TextStyle(

                                fontSize: 12.5.sp,

                                color: subtitleColor,

                                fontFamily:
                                FontFamily.interRegular,

                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(

                        onTap: () =>
                            Navigator.of(ctx).pop(),

                        child: Container(

                          padding:
                          EdgeInsets.all(6.w),

                          decoration:
                          const BoxDecoration(

                            color:
                            Color(0xFFF3F4F6),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(

                            Icons.close_rounded,

                            size: 18.sp,

                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // -----------------------------------
                  // Trial highlights
                  // -----------------------------------

                  Row(

                    children: [

                      Expanded(

                        child:
                        _buildTrialHighlightCard(

                          icon:
                          Icons.card_giftcard_rounded,

                          title:
                          "${controller.formatDuration(
                            controller.totalSeconds,
                          )} Free",

                          subtitle:
                          "Try Walkie Talkie "
                              "without payment.",
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(

                        child:
                        _buildTrialHighlightCard(

                          icon:
                          Icons.hourglass_empty_rounded,

                          title: "Trial Access",

                          subtitle:
                          "Your remaining time "
                              "is managed by the server.",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  reausabletext(

                    "What you can do during the trial",

                    fontsize: 14.5.sp,

                    fontfamily:
                    FontFamily.interBold,

                    color: textColor,
                  ),

                  SizedBox(height: 10.h),

                  // -----------------------------------
                  // Features row 1
                  // -----------------------------------

                  Row(

                    children: [

                      Expanded(

                        child:
                        _buildTrialMiniFeature(

                          icon: Icons.mic_rounded,

                          title: "Push-to-talk",

                          desc:
                          "Instant voice\n"
                              "communication",
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(

                        child:
                        _buildTrialMiniFeature(

                          icon: Icons.groups_rounded,

                          title:
                          "Group Communication",

                          desc:
                          "Connect with your\n"
                              "team",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // -----------------------------------
                  // Features row 2
                  // -----------------------------------

                  Row(

                    children: [

                      Expanded(

                        child:
                        _buildTrialMiniFeature(

                          icon:
                          Icons.graphic_eq_rounded,

                          title: "Clear Audio",

                          desc:
                          "Voice\n"
                              "communication",
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(

                        child:
                        _buildTrialMiniFeature(

                          icon:
                          Icons.timer_outlined,

                          title: "Trial Duration",

                          desc:
                          controller.formatDuration(
                            controller.totalSeconds,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // -----------------------------------
                  // Subscription info
                  // -----------------------------------

                  Container(

                    padding: EdgeInsets.symmetric(

                      horizontal: 12.w,

                      vertical: 10.h,
                    ),

                    decoration: BoxDecoration(

                      color:
                      const Color(0xFFF0EFFF),

                      borderRadius:
                      BorderRadius.circular(12.r),
                    ),

                    child: Row(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Icon(

                          Icons.info_outline_rounded,

                          color: primaryColor,

                          size: 20.sp,
                        ),

                        SizedBox(width: 10.w),

                        Expanded(

                          child: Text(

                            "No payment needed now. "
                                "After your trial, you can "
                                "choose a paid plan starting "
                                "at ${controller.priceLabel}.",

                            style: TextStyle(

                              fontSize: 11.5.sp,

                              color:
                              const Color(0xFF4338CA),

                              fontFamily:
                              FontFamily.interMedium,

                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // -----------------------------------
                  // Trial activation
                  // -----------------------------------

                  SizedBox(

                    width: double.infinity,

                    height: 50.h,

                    child: ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        primaryColor,

                        disabledBackgroundColor:
                        primaryColor.withValues(
                          alpha: 0.45,
                        ),

                        shape:
                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                            14.r,
                          ),
                        ),

                        elevation: 0,
                      ),

                      // Connect the trial activation
                      // API here before enabling.
                      //
                      // On successful activation:
                      //
                      // 1. Refresh walkie/overview.
                      // 2. Confirm canUseWalkie == true.
                      // 3. Close the bottom sheet.
                      // 4. Navigate to group selection.

                      onPressed: null,

                      child: Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Icon(

                            Icons.play_arrow_rounded,

                            color: Colors.white,

                            size: 22.sp,
                          ),

                          SizedBox(width: 8.w),

                          reausabletext(

                            "Start Free Trial",

                            fontsize: 15.sp,

                            fontfamily:
                            FontFamily.interBold,

                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  reausabletext(

                    "No credit card required",

                    fontsize: 11.sp,

                    color: subtitleColor,

                    align: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
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

        borderRadius:
        BorderRadius.circular(14.r),

        border: Border.all(

          color: const Color(0xFFE9E5FF),
        ),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

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

              size: 18.sp,
            ),
          ),

          SizedBox(height: 10.h),

          reausabletext(

            title,

            fontsize: 13.sp,

            fontfamily:
            FontFamily.interBold,

            color: textColor,
          ),

          SizedBox(height: 4.h),

          Text(

            subtitle,

            style: TextStyle(

              fontSize: 10.5.sp,

              color: subtitleColor,

              fontFamily:
              FontFamily.interRegular,

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

      padding: EdgeInsets.all(10.w),

      decoration: BoxDecoration(

        color: const Color(0xFFFAFAFE),

        borderRadius:
        BorderRadius.circular(12.r),

        border: Border.all(

          color: const Color(0xFFEFF0F6),
        ),
      ),

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(

            width: 30.w,

            height: 30.w,

            decoration: BoxDecoration(

              color:
              const Color(0xFFF0EFFF),

              borderRadius:
              BorderRadius.circular(8.r),
            ),

            child: Icon(

              icon,

              color:
              const Color(0xFF6B4DFF),

              size: 16.sp,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    fontSize: 11.5.sp,

                    fontFamily:
                    FontFamily.interBold,

                    color: textColor,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(

                  desc,

                  style: TextStyle(

                    fontSize: 10.sp,

                    color: subtitleColor,

                    fontFamily:
                    FontFamily.interRegular,

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

    return const Center(

      child: CircularProgressIndicator(

        color: primaryColor,
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {

    return Center(

      child: Padding(

        padding: EdgeInsets.all(24.w),

        child: Column(

          mainAxisSize:
          MainAxisSize.min,

          children: [

            Icon(

              Icons.wifi_off_rounded,

              size: 55.sp,

              color: subtitleColor,
            ),

            SizedBox(height: 16.h),

            reausabletext(

              "Unable to Load Walkie Talkie",

              fontsize: 17.sp,

              fontfamily:
              FontFamily.interBold,

              color: textColor,

              align: TextAlign.center,
            ),

            SizedBox(height: 8.h),

            Text(

              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : "Something went wrong. "
                  "Please try again.",

              textAlign: TextAlign.center,

              style: TextStyle(

                fontSize: 12.sp,

                color: subtitleColor,
              ),
            ),

            SizedBox(height: 20.h),

            ElevatedButton(

              onPressed: () {

                controller.fetchOverview();
              },

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                primaryColor,

                foregroundColor:
                Colors.white,

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(12.r),
                ),
              ),

              child: const Text(
                "Try Again",
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

      borderRadius:
      BorderRadius.circular(16.r),

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