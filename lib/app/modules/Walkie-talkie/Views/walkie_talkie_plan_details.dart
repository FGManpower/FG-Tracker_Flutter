import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_plan_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_order_summary_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:fgtracker/app/global_widget/blend_mask.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalkieTalkiePlanDetails extends StatefulWidget {
  final int initialTabIndex;
  const WalkieTalkiePlanDetails({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<WalkieTalkiePlanDetails> createState() =>
      _WalkieTalkiePlanDetailsState();
}

// Aliases so all casing variants work interchangeably
typedef walkie_talkie_plan_details = WalkieTalkiePlanDetails;
typedef WalkieTalkiePlanScreen = WalkieTalkiePlanDetails;
typedef walkieTalkiePlanScreen = WalkieTalkiePlanDetails;

class _WalkieTalkiePlanDetailsState extends State<WalkieTalkiePlanDetails> {
  // Color Constants (Matching Screenshots Exactly)
  static const Color _primaryPurple = Color(0xFF5B4DF5);
  static const Color _bgSoft = Color(0xFFF6F8FE);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEDF2F7);
  static const Color _lightPillBg = Color(0xFFF1F3FE);
  static const Color _greenBadgeBg = Color(0xFFDCFCE7);
  static const Color _greenBadgeText = Color(0xFF16A34A);

  late final WalkieTalkiePlanController controller;

  // Reactive state bridges connected to controller
  int get _selectedIndividualPlan => controller.selectedIndividualPlan.value;
  set _selectedIndividualPlan(int val) =>
      controller.selectedIndividualPlan.value = val;

  int get _selectedTeamDuration => controller.selectedTeamDuration.value;
  set _selectedTeamDuration(int val) =>
      controller.selectedTeamDuration.value = val;

  int get _teamMemberCount => controller.teamMemberCount.value;
  set _teamMemberCount(int val) => controller.teamMemberCount.value = val;

  String? get _appliedPromoCode => controller.appliedPromoCode.value;
  set _appliedPromoCode(String? val) => controller.appliedPromoCode.value = val;

  double get _promoDiscountPercent => controller.promoDiscountPercent.value;
  set _promoDiscountPercent(double val) =>
      controller.promoDiscountPercent.value = val;

  bool get isTeam => controller.isTeam;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WalkieTalkiePlanController>()
        ? Get.find<WalkieTalkiePlanController>()
        : Get.put(WalkieTalkiePlanController());
    controller.setTab(widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isTeam = controller.isTeam;

      return Scaffold(
        backgroundColor: _bgSoft,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final bool isSmallScreen = screenWidth < 360;
              final bool isWideScreen = screenWidth > 600;

              Widget content = Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Bar + Hero Section
                          _buildTopHeroSection(isTeam, isSmallScreen),

                          // Top Error / Offline Banner
                          _buildTopErrorBanner(),

                          SizedBox(height: 12.h),

                          // Feature Highlight Badges (Scrollable)
                          _buildFeaturePills(isTeam),

                          SizedBox(height: 14.h),

                          // Segmented Tab Switcher (Individual / Team Plan)
                          _buildSegmentedTabToggle(isTeam, isSmallScreen),

                          SizedBox(height: 14.h),

                          // Content based on selected tab
                          AnimatedCrossFade(
                            firstChild:
                                _buildIndividualTabContent(isSmallScreen),
                            secondChild: _buildTeamTabContent(isSmallScreen),
                            crossFadeState: isTeam
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Continue Action Bar
                  _buildBottomActionBar(isTeam),
                ],
              );

              if (isWideScreen) {
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: _bgSoft,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: content,
                  ),
                );
              }

              return content;
            },
          ),
        ),
      );
    });
  }

  // ==========================================
  // TOP HERO SECTION (Back Btn, Title, 3D Hero)
  // ==========================================
  Widget _buildTopHeroSection(bool isTeam, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.none,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side Column: Back Button, Title, Subtitle
          Expanded(
            flex: isSmallScreen ? 11 : 10,
            child: Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Squircle Back Button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 38.w.clamp(34.0, 42.0),
                      height: 38.w.clamp(34.0, 42.0),
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
                        size: 19.sp.clamp(16.0, 21.0),
                        color: _primaryPurple,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 6.h : 10.h),

                  Text(
                    isTeam ? "Team Plan" : "Choose a Plan",
                    style: TextStyle(
                      fontSize:
                          (isSmallScreen ? 19.sp : 22.sp).clamp(17.0, 25.0),
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    isTeam
                        ? "Add team members and get everyone connected with Walkie Talkie"
                        : "Continue using Walkie Talkie with a plan that fits your team",
                    style: TextStyle(
                      fontSize:
                          (isSmallScreen ? 10.5.sp : 11.5.sp).clamp(9.5, 12.5),
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: Hero Graphic (Responsive Dynamic Sizing)
          Expanded(
            flex: isSmallScreen ? 10 : 12,
            child: _buildWalkieTalkieHeroGraphic(isTeam, isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkieTalkieHeroGraphic(bool isTeam, bool isSmallScreen) {
    final double targetHeight =
        isSmallScreen ? 118.h.clamp(105.0, 130.0) : 142.h.clamp(120.0, 165.0);
    final double scaleFactor = isSmallScreen ? 1.05 : 1.15;

    return SizedBox(
      height: targetHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerRight,
        child: Transform.scale(
          scale: scaleFactor,
          alignment: Alignment.centerRight,
          child: isTeam
              ? Image.asset(
                  'assets/walkie_talkie/walkie_team_header.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                )
              : Image.asset(
                  'assets/walkie_talkie/walkie_individual_header.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP ERROR / NO INTERNET BANNER
  // ==========================================
  Widget _buildTopErrorBanner() {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      final bool isOffline = msg.toLowerCase().contains('internet') ||
          msg.toLowerCase().contains('network') ||
          msg.toLowerCase().contains('connection');

      return Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 2.h),
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
              size: 18.sp.clamp(16.0, 20.0),
              color: const Color(0xFFDC2626),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                isOffline
                    ? "No internet connection. Please check your network."
                    : msg,
                style: TextStyle(
                  fontSize: 11.5.sp.clamp(10.5, 12.5),
                  color: const Color(0xFF991B1B),
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => controller.fetchBothPlans(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 11.5.sp.clamp(10.5, 12.5),
                    fontFamily: FontFamily.interSemiBold,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==========================================
  // VALUE PROPOSITION PILLS
  // ==========================================
  Widget _buildFeaturePills(bool isTeam) {
    final List<Map<String, dynamic>> pills = isTeam
        ? [
            {
              "icon": Icons.bolt_rounded,
              "title": "Unlimited",
              "subtitle": "Walkie Talkie",
            },
            {
              "icon": Icons.groups_rounded,
              "title": "For Teams",
              "subtitle": "of All Sizes",
            },
            {
              "icon": Icons.shield_outlined,
              "title": "Reliable &",
              "subtitle": "Secure",
            },
            {
              "icon": Icons.headset_mic_rounded,
              "title": "Priority",
              "subtitle": "Support",
            },
          ]
        : [
            {
              "icon": Icons.bolt_rounded,
              "title": "Instant",
              "subtitle": "Communication",
            },
            {
              "icon": Icons.groups_rounded,
              "title": "For Teams",
              "subtitle": "of All Sizes",
            },
            {
              "icon": Icons.all_inclusive_rounded,
              "title": "Reliable &",
              "subtitle": "Secure",
            },
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: pills.map((p) {
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28.w.clamp(26.0, 32.0),
                  height: 28.w.clamp(26.0, 32.0),
                  decoration: const BoxDecoration(
                    color: _lightPillBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p["icon"] as IconData,
                    size: 15.sp.clamp(14.0, 18.0),
                    color: _primaryPurple,
                  ),
                ),
                SizedBox(width: 7.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p["title"] as String,
                      style: TextStyle(
                        fontSize: 10.5.sp.clamp(9.5, 12.0),
                        fontFamily: FontFamily.interSemiBold,
                        color: _textDark,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      p["subtitle"] as String,
                      style: TextStyle(
                        fontSize: 9.5.sp.clamp(8.5, 11.0),
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // SEGMENTED TAB TOGGLE
  // ==========================================
  Widget _buildSegmentedTabToggle(bool isTeam, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Individual Tab
          Expanded(
            child: _buildToggleTabItem(
              isSelected: !isTeam,
              onTap: () => controller.setTab(0),
              icon: Icons.person_outline_rounded,
              title: "Individual",
              subtitle: "Per Person",
              isSmallScreen: isSmallScreen,
            ),
          ),
          SizedBox(width: 4.w),
          // Team Plan Tab
          Expanded(
            child: _buildToggleTabItem(
              isSelected: isTeam,
              onTap: () => controller.setTab(1),
              icon: Icons.groups_rounded,
              title: "Team Plan",
              subtitle: "For Multiple Members",
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabItem({
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: (isSmallScreen ? 18.sp : 21.sp).clamp(17.0, 23.0),
              color: isSelected ? Colors.white : _primaryPurple,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp.clamp(11.5, 14.5),
                        fontFamily: FontFamily.interBold,
                        color: isSelected ? Colors.white : _textDark,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5.sp.clamp(8.5, 11.0),
                        fontFamily: FontFamily.interRegular,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: INDIVIDUAL PLAN CONTENT (Screenshot 2)
  // ==========================================
  Widget _buildIndividualTabContent(bool isSmallScreen) {
    return Obx(() {
      final bool isLoading = controller.isLoadingIndividual.value;
      final List<WalkiePlanItem> plans = controller.individualPlans;

      if (!isLoading && plans.isEmpty) {
        return _buildNoPlansAvailable(isTeam: false);
      }

      if (isLoading && plans.isEmpty) {
        return Skeletonizer(
          enabled: true,
          child: Column(
            children: [
              _buildIndividualPlanCard(
                index: 0,
                title: "Monthly Plan",
                price: "₹500",
                priceSuffix: " / person",
                subtitle: "Perfect for short-term use",
                isMostPopular: true,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: 12.h),
              _buildIndividualPlanCard(
                index: 1,
                title: "Quarterly Plan",
                price: "₹2,400",
                priceSuffix: " / person",
                originalPrice: "₹3,000",
                // discountBadge: "Save 20%",
                subtitle: "Great value for growing teams",
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: 12.h),
              _buildIndividualPlanCard(
                index: 2,
                title: "Yearly Plan",
                price: "₹4,020",
                priceSuffix: " / person",
                originalPrice: "₹6,000",
                // discountBadge: "Save 33%",
                subtitle: "Best for long-term use",
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        );
      }

      return Skeletonizer(
        enabled: isLoading,
        child: Column(
          children: [
            ...List.generate(plans.length, (index) {
              final plan = plans[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildIndividualPlanCard(
                  index: index,
                  title: plan.displayTitle,
                  price: "₹${controller.formatCurrency(plan.safePrice)}",
                  priceSuffix: " / person",
                  subtitle: _getSubtitleForPlan(plan),
                  discountBadge: _getDiscountBadgeForPlan(plan),
                  originalPrice: _getOriginalPriceForPlan(plan),
                  isMostPopular: index == 0,
                  isSmallScreen: isSmallScreen,
                ),
              );
            }),
            SizedBox(height: 2.h),
            _buildTrialRemainingBanner(),
          ],
        ),
      );
    });
  }

  Widget _buildTrialRemainingBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FE),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E7FC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _primaryPurple,
            size: 20.sp.clamp(18.0, 22.0),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "You can still use your free trial for the remaining time.\nThe plan will activate after your trial ends.",
              style: TextStyle(
                fontSize: 11.5.sp.clamp(10.5, 13.0),
                fontFamily: FontFamily.interMedium,
                color: const Color(0xFF475569),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitleForPlan(WalkiePlanItem plan) {
    final interval = (plan.billingInterval ?? '').toLowerCase();
    if (interval == 'monthly' || plan.durationMonths == 1) {
      return "Perfect for short-term use";
    } else if (interval == 'quarterly' || plan.durationMonths == 3) {
      return "Great value for growing teams";
    } else if (interval == 'yearly' || plan.durationMonths == 12) {
      return "Best for long-term use";
    }
    return "Instant walkie talkie voice access";
  }

  String? _getDiscountBadgeForPlan(WalkiePlanItem plan) {
    return null;
  }

  String? _getOriginalPriceForPlan(WalkiePlanItem plan) {
    final interval = (plan.billingInterval ?? '').toLowerCase();
    if (interval == 'quarterly' || plan.durationMonths == 3) {
      final orig = (plan.safePrice / 0.8).round();
      return "₹${controller.formatCurrency(orig)}";
    } else if (interval == 'yearly' || plan.durationMonths == 12) {
      final orig = (plan.safePrice / 0.67).round();
      return "₹${controller.formatCurrency(orig)}";
    }
    return null;
  }

  Widget _buildIndividualPlanCard({
    required int index,
    required String title,
    required String price,
    required String priceSuffix,
    required String subtitle,
    String? originalPrice,
    String? discountBadge,
    bool isMostPopular = false,
    required bool isSmallScreen,
  }) {
    return Obx(() {
      final bool isSelected = controller.selectedIndividualPlan.value == index;

      return GestureDetector(
        onTap: () => controller.setIndividualPlan(index),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? _primaryPurple : const Color(0xFFE2E8F0),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primaryPurple.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 15.h, 12.w, 15.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Title, Price, Subtitle, Discount
                      Expanded(
                        flex: 11,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp.clamp(14.0, 17.0),
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    price,
                                    style: TextStyle(
                                      fontSize: 25.sp.clamp(21.0, 28.0),
                                      fontFamily: FontFamily.interBold,
                                      color: _textDark,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    priceSuffix,
                                    style: TextStyle(
                                      fontSize: 12.sp.clamp(10.5, 13.5),
                                      fontFamily: FontFamily.interRegular,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (discountBadge != null ||
                                originalPrice != null) ...[
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  if (discountBadge != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: _greenBadgeBg,
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                      ),
                                      child: Text(
                                        discountBadge,
                                        style: TextStyle(
                                          fontSize: 9.5.sp.clamp(8.5, 11.0),
                                          fontFamily: FontFamily.interBold,
                                          color: _greenBadgeText,
                                        ),
                                      ),
                                    ),
                                  if (originalPrice != null) ...[
                                    SizedBox(width: 6.w),
                                    Text(
                                      originalPrice,
                                      style: TextStyle(
                                        fontSize: 11.5.sp.clamp(10.0, 13.0),
                                        fontFamily: FontFamily.interMedium,
                                        color: const Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            SizedBox(height: 3.h),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5.sp.clamp(9.5, 12.0),
                                fontFamily: FontFamily.interRegular,
                                color: _textSecondary,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Middle Column: Checklist Features
                      Expanded(
                        flex: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckItem("Unlimited Walkie Talkie"),
                            SizedBox(height: 4.h),
                            _buildCheckItem("High Quality Voice"),
                            SizedBox(height: 4.h),
                            _buildCheckItem("Group Communication"),
                            SizedBox(height: 4.h),
                            _buildCheckItem("Priority Support"),
                          ],
                        ),
                      ),

                      SizedBox(width: 6.w),

                      // Right Column: Radio Button
                      Container(
                        width: 21.w.clamp(19.0, 24.0),
                        height: 21.w.clamp(19.0, 24.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? _primaryPurple
                                : const Color(0xFFCBD5E1),
                            width: 1.8.w,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 11.w,
                                  height: 11.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _primaryPurple,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),

                // "Most Popular" Ribbon Badge
                if (isMostPopular)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 3.5.h),
                      decoration: BoxDecoration(
                        color: _primaryPurple,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Most Popular",
                        style: TextStyle(
                          fontSize: 9.5.sp.clamp(8.5, 11.0),
                          fontFamily: FontFamily.interBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        Icon(
          Icons.check_rounded,
          size: 14.sp.clamp(12.0, 16.0),
          color: _primaryPurple,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp.clamp(9.0, 11.5),
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TEAM PLAN CONTENT (Screenshot 1)
  // ==========================================
  Widget _buildTeamTabContent(bool isSmallScreen) {
    return Obx(() {
      final bool isLoading = controller.isLoadingGroup.value;
      final plans = controller.groupPlans;

      if (!isLoading && plans.isEmpty) {
        return _buildNoPlansAvailable(isTeam: true);
      }

      return Skeletonizer(
        enabled: isLoading,
        child: Column(
          children: [
            // Card 1: Select Number of Members
            _buildTeamMembersCard(isSmallScreen),

            SizedBox(height: 14.h),

            // Card 2: Select Plan Duration
            _buildTeamDurationCard(),

            SizedBox(height: 14.h),

            // Card 3: Plan Summary
            _buildTeamSummaryCard(),
          ],
        ),
      );
    });
  }

  Widget _buildTeamMembersCard(bool isSmallScreen) {
    return Obx(() {
      final int memberCount = controller.teamMemberCount.value;
      final int minMembers = controller.activeGroupPlan?.safeMinMembers ?? 1;
      final int maxMembers = controller.activeGroupPlan?.safeMaxMembers ?? 99;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardStepHeader(
              stepNumber: "1",
              title: "Select Number of Members",
              subtitle: "Choose how many team members you want to add",
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                // Stepper Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus Button
                    _buildStepperButton(
                      isPlus: false,
                      isEnabled: memberCount > minMembers,
                      onTap: () {
                        if (memberCount > minMembers) {
                          HapticFeedback.lightImpact();
                          controller.decrementMembers();
                        } else {
                          controller.showTopWhiteMessage(
                              "Minimum team size is $minMembers member${minMembers > 1 ? 's' : ''}");
                        }
                      },
                    ),

                    SizedBox(width: 6.w),

                    // Count Display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: (isSmallScreen ? 70.w : 78.w).clamp(66.0, 84.0),
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FF),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: _primaryPurple,
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryPurple.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              "$memberCount",
                              key: ValueKey<int>(memberCount),
                              style: TextStyle(
                                fontSize: 22.sp.clamp(20.0, 25.0),
                                fontFamily: FontFamily.interBold,
                                color: _primaryPurple,
                              ),
                            ),
                          ),
                          Text(
                            memberCount == 1 ? "Member" : "Members",
                            style: TextStyle(
                              fontSize: 10.sp.clamp(9.0, 11.5),
                              fontFamily: FontFamily.interSemiBold,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // Plus Button
                    _buildStepperButton(
                      isPlus: true,
                      isEnabled: memberCount < maxMembers,
                      onTap: () {
                        if (memberCount < maxMembers) {
                          HapticFeedback.lightImpact();
                          controller.incrementMembers();
                        } else {
                          controller.showTopWhiteMessage(
                              "Maximum limit of $maxMembers members reached");
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(width: 10.w),

                // "More Members?" Info Box
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3FE),
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          color: _primaryPurple,
                          size: 19.sp.clamp(17.0, 21.0),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "More Members?",
                                style: TextStyle(
                                  fontSize: 11.sp.clamp(10.0, 12.0),
                                  fontFamily: FontFamily.interBold,
                                  color: _textDark,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "Add or remove members anytime.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.sp.clamp(8.0, 10.0),
                                  fontFamily: FontFamily.interRegular,
                                  color: _textSecondary,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStepperButton({
    required bool isPlus,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: isEnabled ? onTap : null,
        child: Container(
          width: 38.w.clamp(35.0, 42.0),
          height: 38.w.clamp(35.0, 42.0),
          decoration: BoxDecoration(
            color:
                isEnabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEnabled
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              isPlus ? Icons.add_rounded : Icons.remove_rounded,
              color:
                  isEnabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              size: 20.sp.clamp(18.0, 22.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDurationCard() {
    final plans = controller.groupPlans;
    final int selectedIdx = controller.selectedTeamDuration.value;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardStepHeader(
            stepNumber: "2",
            title: "Select Plan Duration",
            subtitle: "Choose the plan duration that works for you",
          ),
          SizedBox(height: 14.h),
          if (plans.isEmpty)
            Row(
              children: [
                Expanded(
                  child: _buildTeamDurationOptionItem(
                    index: 0,
                    title: "Quarterly",
                    price: "₹399",
                    priceSuffix: "per member",
                    isSelected: true,
                  ),
                ),
              ],
            )
          else
            Row(
              children: List.generate(plans.length, (index) {
                final plan = plans[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index > 0 ? 8.w : 0,
                    ),
                    child: _buildTeamDurationOptionItem(
                      index: index,
                      title: plan.displayTitle,
                      price: "₹${controller.formatCurrency(plan.safePrice)}",
                      priceSuffix: "per member",
                      isSelected: selectedIdx == index,
                      onTap: () {
                        setState(() {
                          _selectedTeamDuration = index;
                        });
                        controller.setTeamDuration(index);
                      },
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamDurationOptionItem({
    required int index,
    required String title,
    required String price,
    required String priceSuffix,
    String? discountBadge,
    bool? isSelected,
    VoidCallback? onTap,
  }) {
    final bool selected = isSelected ?? (_selectedTeamDuration == index);

    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() => _selectedTeamDuration = index);
            controller.setTeamDuration(index);
          },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? _primaryPurple : const Color(0xFFE2E8F0),
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp.clamp(11.0, 13.5),
                        fontFamily: FontFamily.interBold,
                        color: _textDark,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 16.w.clamp(14.0, 18.0),
                  height: 16.w.clamp(14.0, 18.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          selected ? _primaryPurple : const Color(0xFFCBD5E1),
                      width: 1.8.w,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryPurple,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 7.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 17.sp.clamp(15.0, 19.0),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                priceSuffix,
                style: TextStyle(
                  fontSize: 9.5.sp.clamp(8.5, 11.0),
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                ),
              ),
            ),
            if (discountBadge != null) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _greenBadgeBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    discountBadge,
                    style: TextStyle(
                      fontSize: 9.sp.clamp(8.0, 10.5),
                      fontFamily: FontFamily.interBold,
                      color: _greenBadgeText,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSummaryCard() {
    return Obx(() {
      final String durationName = controller.durationName;
      final int ratePerMember = controller.ratePerMember;
      final int memberCount = controller.teamMemberCount.value;
      final int originalTotal = controller.originalTotal;
      final num discountedTotal = controller.discountedTotal;
      final num couponDiscount = controller.couponDiscountAmount;
      final String? promoCode = controller.appliedPromoCode.value;
      final appliedData = controller.appliedCouponData.value;
      final pricing = appliedData?.pricing;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 3 Header with Promo Code link on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepNumberBadge("3"),
                    SizedBox(width: 10.w),
                    Text(
                      "Plan Summary",
                      style: TextStyle(
                        fontSize: 14.5.sp.clamp(13.5, 16.0),
                        fontFamily: FontFamily.interBold,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: _showPromoCodeBottomSheet,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 14.sp,
                                color: promoCode != null
                                    ? const Color(0xFF16A34A)
                                    : _primaryPurple,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  promoCode != null
                                      ? "Code: $promoCode"
                                      : "Have a Promo Code?",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5.sp.clamp(10.5, 13.0),
                                    fontFamily: FontFamily.interSemiBold,
                                    color: promoCode != null
                                        ? const Color(0xFF16A34A)
                                        : _primaryPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (promoCode != null) ...[
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            controller.removePromoCode();
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 15.sp,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Inner Summary Box
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE8EEF5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Team Plan ($durationName)",
                                style: TextStyle(
                                  fontSize: 14.sp.clamp(12.5, 15.5),
                                  fontFamily: FontFamily.interBold,
                                  color: _textDark,
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "$memberCount Members × ₹${controller.formatCurrency(ratePerMember)}",
                                style: TextStyle(
                                  fontSize: 11.5.sp.clamp(10.0, 13.0),
                                  fontFamily: FontFamily.interMedium,
                                  color: _textSecondary,
                                ),
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
                            "₹${controller.formatCurrency(discountedTotal)}",
                            style: TextStyle(
                              fontSize: 20.sp.clamp(17.0, 23.0),
                              fontFamily: FontFamily.interBold,
                              color: _textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (originalTotal != discountedTotal) ...[
                            SizedBox(height: 2.h),
                            Text(
                              "₹${controller.formatCurrency(originalTotal)} total",
                              style: TextStyle(
                                fontSize: 10.5.sp.clamp(9.5, 12.0),
                                fontFamily: FontFamily.interRegular,
                                color: const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (promoCode != null && couponDiscount > 0) ...[
                    SizedBox(height: 8.h),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 13.sp,
                                color: const Color(0xFF16A34A),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  "Promo ($promoCode) applied",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontFamily: FontFamily.interMedium,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "-₹${controller.formatCurrency(couponDiscount)}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: FontFamily.interBold,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (pricing?.amountSaved != null &&
                      pricing!.amountSaved! > 0) ...[
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            size: 13.sp,
                            color: const Color(0xFF16A34A),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "You save ₹${controller.formatCurrency(pricing!.amountSaved)} with this coupon!",
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCardStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepNumberBadge(stepNumber),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp.clamp(13.0, 16.0),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5.sp.clamp(10.0, 13.0),
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepNumberBadge(String number) {
    return Container(
      width: 23.w.clamp(20.0, 26.0),
      height: 23.w.clamp(20.0, 26.0),
      decoration: const BoxDecoration(
        color: _primaryPurple,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 11.5.sp.clamp(10.0, 13.0),
            fontFamily: FontFamily.interBold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildNoPlansAvailable({required bool isTeam}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68.w,
            height: 68.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.layers_clear_rounded,
                color: _primaryPurple,
                size: 34.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "No Plans Available",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp.clamp(15.0, 19.0),
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isTeam
                ? "No team walkie-talkie plans are currently available. Please check back later or retry."
                : "No individual walkie-talkie plans are currently available. Please check back later or retry.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.sp.clamp(11.0, 14.0),
              fontFamily: FontFamily.interRegular,
              color: _textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            onPressed: () {
              if (isTeam) {
                controller.fetchGroupPlans();
              } else {
                controller.fetchIndividualPlans();
              }
            },
            icon: Icon(
              Icons.refresh_rounded,
              size: 16.sp,
              color: _primaryPurple,
            ),
            label: Text(
              "Retry",
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interBold,
                color: _primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM BAR
  // ==========================================
  Widget _buildBottomActionBar(bool isTeam) {
    return Obx(() {
      final bool isLoading = controller.isLoading;
      final bool hasPlans = controller.hasPlans;
      final String buttonText = controller.buttonText;
      final bool isButtonEnabled = hasPlans && !isLoading;

      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 48.h.clamp(44.0, 52.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? _primaryPurple
                      : const Color(0xFFCBD5E1),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                onPressed: isButtonEnabled
                    ? () => controller.openPurchaseSuccessScreen()
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 15.sp.clamp(13.5, 16.5),
                          fontFamily: FontFamily.interBold,
                          color: isButtonEnabled
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    if (isButtonEnabled) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18.sp.clamp(16.0, 20.0),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 7.h),

            // Security Lock Note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13.sp.clamp(11.0, 14.0),
                  color: _textSecondary,
                ),
                SizedBox(width: 6.w),
                Text(
                  "Secure & Encrypted Payment",
                  style: TextStyle(
                    fontSize: 11.5.sp.clamp(10.0, 13.0),
                    fontFamily: FontFamily.interMedium,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ==========================================
  // PROMO CODE SHEET (FLIPKART STYLE)
  // ==========================================
  void _showPromoCodeBottomSheet() {
    controller.fetchEligibleCoupons();
    final TextEditingController promoController =
        TextEditingController(text: controller.appliedPromoCode.value ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final double maxHeight = MediaQuery.of(ctx).size.height * 0.85;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: maxHeight),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Title Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                color: _primaryPurple,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Coupons & Offers",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontFamily: FontFamily.interBold,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18.sp,
                                color: _textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Promo Code Input Box + Apply/Remove Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 46.h,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: promoController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      onChanged: (_) => setSheetState(() {}),
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontFamily: FontFamily.interBold,
                                        color: _textDark,
                                        letterSpacing: 0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter coupon code",
                                        hintStyle: TextStyle(
                                          fontSize: 12.5.sp,
                                          color: const Color(0xFF94A3B8),
                                          fontFamily: FontFamily.interRegular,
                                          letterSpacing: 0,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (promoController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        promoController.clear();
                                        setSheetState(() {});
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(4.w),
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          size: 16.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Obx(() {
                            final bool isApplying =
                                controller.isApplyingCoupon.value;
                            final String typedCode =
                                promoController.text.trim().toUpperCase();
                            final String? appliedCode = controller
                                .appliedPromoCode.value
                                ?.toUpperCase();
                            final bool isThisCodeApplied =
                                appliedCode != null &&
                                    appliedCode.isNotEmpty &&
                                    typedCode == appliedCode;

                            return SizedBox(
                              height: 46.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isThisCodeApplied
                                      ? const Color(0xFF16A34A)
                                      : _primaryPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                ),
                                onPressed: isApplying
                                    ? null
                                    : () async {
                                        if (isThisCodeApplied) {
                                          HapticFeedback.lightImpact();
                                          controller.removePromoCode();
                                          promoController.clear();
                                          setSheetState(() {});
                                          return;
                                        }
                                        if (typedCode.isEmpty) {
                                          controller.showTopWhiteMessage(
                                              "Please enter a valid coupon code");
                                          return;
                                        }
                                        final success = await controller
                                            .applyPromoCode(typedCode);
                                        if (success && ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      },
                                child: isApplying &&
                                        ((controller.applyingCouponCode.value ??
                                                    '') ==
                                                typedCode ||
                                            controller
                                                    .applyingCouponCode.value ==
                                                null)
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isThisCodeApplied) ...[
                                            Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                          ],
                                          Text(
                                            isThisCodeApplied
                                                ? "Applied"
                                                : "Apply",
                                            style: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontFamily: FontFamily.interBold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 18.h),

                      // Available Coupons Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Available Coupons",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: FontFamily.interBold,
                              color: _textDark,
                            ),
                          ),
                          Obx(() {
                            if (controller.isLoadingCoupons.value &&
                                controller.eligibleCoupons.isNotEmpty) {
                              return const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _primaryPurple,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Available Coupons List
                      Obx(() {
                        if (controller.isLoadingCoupons.value) {
                          return _buildCouponsSkeletonList();
                        }

                        if (controller.eligibleCoupons.isEmpty) {
                          return _buildNoCouponsEmptyState();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.eligibleCoupons.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final coupon = controller.eligibleCoupons[index];
                            final String couponCode =
                                (coupon.code ?? '').trim().toUpperCase();
                            final bool isApplied =
                                controller.appliedPromoCode.value != null &&
                                    controller.appliedPromoCode.value!
                                            .toUpperCase() ==
                                        couponCode;
                            final bool isEligible = coupon.eligible == true;
                            final bool isThisItemApplying =
                                controller.isApplyingCoupon.value &&
                                    (controller.applyingCouponCode.value ?? '')
                                            .trim()
                                            .toUpperCase() ==
                                        couponCode;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: isApplied
                                    ? const Color(0xFFF0FDF4)
                                    : (isEligible
                                        ? _lightPillBg
                                        : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isApplied
                                      ? const Color(0xFF86EFAC)
                                      : (isEligible
                                          ? const Color(0xFFDCD7FE)
                                          : const Color(0xFFE2E8F0)),
                                  width: isApplied ? 1.4 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38.w,
                                    height: 38.w,
                                    decoration: BoxDecoration(
                                      color: isApplied
                                          ? const Color(0xFFDCFCE7)
                                          : (isEligible
                                              ? const Color(0xFFE0E7FF)
                                              : const Color(0xFFF1F5F9)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isApplied
                                          ? Icons.check_circle_rounded
                                          : Icons.local_offer_rounded,
                                      size: 18.sp,
                                      color: isApplied
                                          ? const Color(0xFF16A34A)
                                          : (isEligible
                                              ? _primaryPurple
                                              : const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Wrap(
                                          spacing: 6.w,
                                          runSpacing: 4.h,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              coupon.code ?? '',
                                              style: TextStyle(
                                                fontSize: 13.5.sp,
                                                fontFamily:
                                                    FontFamily.interBold,
                                                color: isEligible || isApplied
                                                    ? _textDark
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 1.5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isApplied
                                                    ? const Color(0xFFDCFCE7)
                                                    : (isEligible
                                                        ? const Color(
                                                            0xFFE0E7FF)
                                                        : const Color(
                                                            0xFFF1F5F9)),
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                              ),
                                              child: Text(
                                                coupon.discountDescription,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontFamily:
                                                      FontFamily.interBold,
                                                  color: isApplied
                                                      ? const Color(0xFF16A34A)
                                                      : (isEligible
                                                          ? _primaryPurple
                                                          : const Color(
                                                              0xFF94A3B8)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3.h),
                                        if (!isEligible)
                                          Text(
                                            coupon.formattedIneligibleReason,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  FontFamily.interMedium,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          )
                                        else if (coupon
                                            .formattedExpiry.isNotEmpty)
                                          Text(
                                            coupon.formattedExpiry,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontFamily:
                                                  FontFamily.interRegular,
                                              color: _textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  if (isApplied)
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        controller.removePromoCode();
                                        promoController.clear();
                                        setSheetState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: const Color(0xFFEF4444),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.close_rounded,
                                              size: 13.sp,
                                              color: const Color(0xFFEF4444),
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              "REMOVE",
                                              style: TextStyle(
                                                fontSize: 10.5.sp,
                                                fontFamily:
                                                    FontFamily.interBold,
                                                color: const Color(0xFFEF4444),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: (controller
                                                  .isApplyingCoupon.value ||
                                              !isEligible)
                                          ? (!isEligible
                                              ? () => controller
                                                  .showTopWhiteMessage(coupon
                                                      .formattedIneligibleReason)
                                              : null)
                                          : () async {
                                              HapticFeedback.lightImpact();
                                              final ok = await controller
                                                  .applyCoupon(coupon);
                                              if (ok && ctx.mounted) {
                                                Navigator.pop(ctx);
                                              }
                                            },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isThisItemApplying
                                              ? _primaryPurple.withValues(
                                                  alpha: 0.8)
                                              : (isEligible
                                                  ? _primaryPurple
                                                  : const Color(0xFFE2E8F0)),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: isThisItemApplying
                                            ? SizedBox(
                                                width: 14.w,
                                                height: 14.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                isEligible ? "APPLY" : "LOCKED",
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontFamily:
                                                      FontFamily.interBold,
                                                  color: isEligible
                                                      ? Colors.white
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCouponsSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E7FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    size: 18.sp,
                    color: _primaryPurple,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            index == 0
                                ? "WELCOME10"
                                : (index == 1 ? "SPECIAL20" : "FLAT150"),
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              index == 0
                                  ? "10% OFF"
                                  : (index == 1 ? "20% OFF" : "FLAT ₹150 OFF"),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: FontFamily.interBold,
                                color: _primaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "Valid on all plans • Expires soon",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryPurple,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "APPLY",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoCouponsEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF2F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.confirmation_number_outlined,
                size: 24.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "No Coupons Available",
              style: TextStyle(
                fontSize: 13.5.sp,
                fontFamily: FontFamily.interBold,
                color: _textDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "There are no active coupons for this plan right now.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interRegular,
                color: _textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAYMENT BOTTOM SHEET & SUCCESS
  // ==========================================
  void _showPaymentMethodBottomSheet(String planDescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Select Payment Method",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                planDescription,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPaymentOptionTile(
                icon: Icons.qr_code_scanner_rounded,
                title: "UPI / QR Code",
                subtitle: "Google Pay, PhonePe, Paytm",
              ),
              SizedBox(height: 10.h),
              _buildPaymentOptionTile(
                icon: Icons.credit_card_rounded,
                title: "Credit / Debit Card",
                subtitle: "Visa, MasterCard, RuPay",
              ),
              SizedBox(height: 10.h),
              _buildPaymentOptionTile(
                icon: Icons.account_balance_rounded,
                title: "Net Banking",
                subtitle: "All Indian Banks supported",
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openPurchaseSuccessScreen(isTeam);
                  },
                  child: Text(
                    "Pay & Activate Plan",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: _lightPillBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _primaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  String _getValidTillDate(int durationIndex) {
    final now = DateTime.now();
    DateTime expiryDate;
    if (durationIndex == 0) {
      expiryDate = DateTime(now.year, now.month + 1, now.day);
    } else if (durationIndex == 1) {
      expiryDate = DateTime(now.year, now.month + 3, now.day);
    } else {
      expiryDate = DateTime(now.year + 1, now.month, now.day);
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${expiryDate.day} ${months[expiryDate.month - 1]} ${expiryDate.year}";
  }

  void _openPurchaseSuccessScreen([bool? isTeamParam]) {
    controller.openPaymentScreen();
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 38.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Plan Activated Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Your Walkie Talkie plan is now active. Enjoy uninterrupted instant voice communication.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: _textSecondary,
                  fontFamily: FontFamily.interRegular,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
