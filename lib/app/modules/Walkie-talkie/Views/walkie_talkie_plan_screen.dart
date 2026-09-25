import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieTalkiePlanScreen extends StatefulWidget {
  final int initialTabIndex; // 0 for Individual, 1 for Team Plan
  const WalkieTalkiePlanScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<WalkieTalkiePlanScreen> createState() => _WalkieTalkiePlanScreenState();
}

class _WalkieTalkiePlanScreenState extends State<WalkieTalkiePlanScreen> {
  // Tab: 0 = Individual, 1 = Team Plan
  late int _selectedTab;

  // Individual Plan Selection (0 = Monthly, 1 = Quarterly, 2 = Yearly)
  int _selectedIndividualPlan = 0;

  // Team Plan Configuration
  int _teamMemberCount = 5;
  int _selectedTeamDuration = 0; // 0 = Monthly, 1 = Quarterly, 2 = Yearly
  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Colors Palette
  final Color _primaryPurple = const Color(0xFF5A35FF);
  final Color _lightPurpleBg = const Color(0xFFF0EFFF);
  final Color _softPurpleBorder = const Color(0xFFDCD7FE);
  final Color _darkText = const Color(0xFF111827);
  final Color _secondaryText = const Color(0xFF6B7280);
  final Color _badgeGreenBg = const Color(0xFFDCFCE7);
  final Color _badgeGreenText = const Color(0xFF15803D);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isTeam = _selectedTab == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar + Hero Graphic
                    _buildTopHeroSection(isTeam),

                    SizedBox(height: 12.h),

                    // Feature Pill Highlights Row
                    _buildFeaturePills(isTeam),

                    SizedBox(height: 16.h),

                    // Individual vs Team Plan Segmented Control
                    _buildSegmentedTabToggle(),

                    SizedBox(height: 16.h),

                    // Content based on selected tab
                    AnimatedCrossFade(
                      firstChild: _buildIndividualTabContent(),
                      secondChild: _buildTeamTabContent(),
                      crossFadeState: isTeam
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar
            _buildBottomActionBar(isTeam),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP HERO SECTION (Back btn + Title + 3D Device)
  // ==========================================
  Widget _buildTopHeroSection(bool isTeam) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20.sp,
                color: _primaryPurple,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Title & Hero Walkie Talkie Illustration Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    reausabletext(
                      isTeam ? "Team Plan" : "Choose a Plan",
                      fontsize: 24.sp,
                      fontfamily: FontFamily.interBold,
                      color: _darkText,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isTeam
                          ? "Add team members and get everyone connected with Walkie Talkie"
                          : "Continue using Walkie Talkie with a plan that fits your team",
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: _secondaryText,
                        fontFamily: FontFamily.interRegular,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Right 3D Walkie Talkie Illustration with badge & annotations
              _buildWalkieTalkieHeroGraphic(isTeam),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalkieTalkieHeroGraphic(bool isTeam) {
    return SizedBox(
      width: 140.w,
      height: 125.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glowing radial circular halo background
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primaryPurple.withValues(alpha: 0.16),
                  _primaryPurple.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Walkie Talkie Device Graphic
          Positioned(
            right: 28.w,
            bottom: 4.h,
            child: _buildWalkieTalkieDevice(),
          ),

          // Stylized Annotation / Badge (Handwritten tone)
          Positioned(
            top: 6.h,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: _primaryPurple.withValues(alpha: 0.7),
                  size: 14.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  isTeam ? "Stronger\nTeams\nSafer Sites" : "Stay\nConnected\nAlways",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: FontFamily.interMedium,
                    fontStyle: FontStyle.italic,
                    fontSize: 8.5.sp,
                    color: _primaryPurple,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          // Small Team Avatars icon badge for Team Plan
          if (isTeam)
            Positioned(
              right: 2.w,
              bottom: 22.h,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: _primaryPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: _primaryPurple,
                  size: 22.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalkieTalkieDevice() {
    return Container(
      width: 62.w,
      height: 98.h,
      decoration: BoxDecoration(
        color: const Color(0xFF222433),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Antenna top left
          Positioned(
            top: -18.h,
            left: 10.w,
            child: Container(
              width: 7.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D29),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          // Knob top right
          Positioned(
            top: -8.h,
            right: 11.w,
            child: Container(
              width: 11.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: const Color(0xFF333647),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          // PTT side button
          Positioned(
            left: -3.w,
            top: 28.h,
            child: Container(
              width: 4.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // Device Face
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 4.h),
              // Grill slits
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Center illuminated speaker
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF151722),
                  border: Border.all(
                    color: _primaryPurple,
                    width: 2.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              // Status dot
              Container(
                width: 5.w,
                height: 5.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VALUE PROPOSITION PILLS
  // ==========================================
  Widget _buildFeaturePills(bool isTeam) {
    final List<Map<String, dynamic>> pills = isTeam
        ? [
            {
              "icon": Icons.bolt_rounded,
              "label": "Unlimited\nWalkie Talkie",
            },
            {
              "icon": Icons.groups_rounded,
              "label": "For Teams\nof All Sizes",
            },
            {
              "icon": Icons.shield_outlined,
              "label": "Reliable &\nSecure",
            },
            {
              "icon": Icons.headset_mic_rounded,
              "label": "Priority\nSupport",
            },
          ]
        : [
            {
              "icon": Icons.bolt_rounded,
              "label": "Instant\nCommunication",
            },
            {
              "icon": Icons.groups_rounded,
              "label": "For Teams\nof All Sizes",
            },
            {
              "icon": Icons.all_inclusive_rounded,
              "label": "Reliable &\nSecure",
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: _lightPurpleBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p["icon"] as IconData,
                    size: 16.sp,
                    color: _primaryPurple,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  p["label"] as String,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: _darkText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // SEGMENTED TAB TOGGLE (Individual | Team Plan)
  // ==========================================
  Widget _buildSegmentedTabToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              index: 0,
              icon: Icons.person_outline_rounded,
              title: "Individual",
              subtitle: "Per Person",
            ),
          ),
          SizedBox(width: 4.w),
          // Team Plan Tab
          Expanded(
            child: _buildToggleTabItem(
              index: 1,
              icon: Icons.groups_rounded,
              title: "Team Plan",
              subtitle: "For Multiple Members",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabItem({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? _primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.3),
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
              size: 20.sp,
              color: isSelected ? Colors.white : _secondaryText,
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: isSelected ? Colors.white : _darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: FontFamily.interRegular,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : _secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: INDIVIDUAL PLAN CONTENT (Image 2)
  // ==========================================
  Widget _buildIndividualTabContent() {
    return Column(
      children: [
        // Monthly Plan Card (Most Popular)
        _buildIndividualPlanCard(
          index: 0,
          title: "Monthly Plan",
          price: "₹500",
          priceSuffix: " / person",
          subtitle: "Perfect for short-term use",
          isMostPopular: true,
        ),

        SizedBox(height: 12.h),

        // Quarterly Plan Card
        _buildIndividualPlanCard(
          index: 1,
          title: "Quarterly Plan",
          price: "₹2,400",
          priceSuffix: " / person",
          originalPrice: "₹3,000",
          discountBadge: "Save 20%",
          subtitle: "Great value for growing teams",
        ),

        SizedBox(height: 12.h),

        // Yearly Plan Card
        _buildIndividualPlanCard(
          index: 2,
          title: "Yearly Plan",
          price: "₹4,020",
          priceSuffix: " / person",
          originalPrice: "₹6,000",
          discountBadge: "Save 33%",
          subtitle: "Best for long-term use",
        ),

        SizedBox(height: 16.h),

        // Free Trial Remaining Info Box
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3FF),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE0E5FF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _primaryPurple,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "You can still use your free trial for the remaining time. The plan will activate after your trial ends.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interMedium,
                    color: const Color(0xFF4B5563),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
  }) {
    final bool isSelected = _selectedIndividualPlan == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndividualPlan = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? _primaryPurple : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _primaryPurple.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
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
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Title, Price, and Radio Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: FontFamily.interBold,
                                  color: _darkText,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    price,
                                    style: TextStyle(
                                      fontSize: 26.sp,
                                      fontFamily: FontFamily.interBold,
                                      color: _darkText,
                                    ),
                                  ),
                                  Text(
                                    priceSuffix,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontFamily: FontFamily.interMedium,
                                      color: _secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                              if (discountBadge != null || originalPrice != null) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    if (discountBadge != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: _badgeGreenBg,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          discountBadge,
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontFamily: FontFamily.interBold,
                                            color: _badgeGreenText,
                                          ),
                                        ),
                                      ),
                                    if (originalPrice != null) ...[
                                      SizedBox(width: 8.w),
                                      Text(
                                        originalPrice,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: FontFamily.interMedium,
                                          color: const Color(0xFF9CA3AF),
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                              SizedBox(height: 4.h),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontFamily: FontFamily.interRegular,
                                  color: _secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Radio Button
                        Container(
                          margin: EdgeInsets.only(top: isMostPopular ? 14.h : 4.h),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? _primaryPurple
                                  : const Color(0xFFCBD5E1),
                              width: 2.w,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 12.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primaryPurple,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Feature Checklist
                    _buildPlanChecklistRow(
                      col1: "Unlimited Walkie Talkie",
                      col2: "High Quality Voice",
                    ),
                    SizedBox(height: 6.h),
                    _buildPlanChecklistRow(
                      col1: "Group Communication",
                      col2: "Priority Support",
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _primaryPurple,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Most Popular",
                      style: TextStyle(
                        fontSize: 10.5.sp,
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

  Widget _buildPlanChecklistRow({
    required String col1,
    required String col2,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.check_rounded,
                size: 16.sp,
                color: _primaryPurple,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  col1,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interMedium,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.check_rounded,
                size: 16.sp,
                color: _primaryPurple,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  col2,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interMedium,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: TEAM PLAN CONTENT (Image 1)
  // ==========================================
  Widget _buildTeamTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 1: Select Number of Members
        _buildSectionHeader(
          stepNumber: "1",
          title: "Select Number of Members",
          subtitle: "Choose how many team members you want to add",
        ),
        SizedBox(height: 12.h),
        _buildMemberStepperSection(),

        SizedBox(height: 20.h),

        // Step 2: Select Plan Duration
        _buildSectionHeader(
          stepNumber: "2",
          title: "Select Plan Duration",
          subtitle: "Choose the plan duration that works for you",
        ),
        SizedBox(height: 12.h),
        _buildDurationOptionsRow(),

        SizedBox(height: 20.h),

        // Step 3: Plan Summary
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStepCircle("3"),
                  SizedBox(width: 10.w),
                  Text(
                    "Plan Summary",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showPromoCodeBottomSheet,
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 14.sp,
                      color: _primaryPurple,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _appliedPromoCode != null
                          ? "Code: $_appliedPromoCode"
                          : "Have a Promo Code?",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: FontFamily.interSemiBold,
                        color: _primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        _buildPlanSummaryCard(),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCircle(stepNumber),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: FontFamily.interBold,
                    color: _darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String number) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: _primaryPurple,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: FontFamily.interBold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberStepperSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Minus Button
          GestureDetector(
            onTap: () {
              if (_teamMemberCount > 2) {
                setState(() {
                  _teamMemberCount--;
                });
              } else {
                Utils().fluttertoast("Minimum team size is 2 members");
              }
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _lightPurpleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_rounded,
                color: _primaryPurple,
                size: 22.sp,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // Member Count Display
          Container(
            width: 110.w,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$_teamMemberCount",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: FontFamily.interBold,
                    color: _darkText,
                  ),
                ),
                Text(
                  "Members",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interMedium,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Plus Button
          GestureDetector(
            onTap: () {
              setState(() {
                _teamMemberCount++;
              });
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _primaryPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // More Members Info Card
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _lightPurpleBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: _primaryPurple,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "More Members?",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontFamily: FontFamily.interBold,
                            color: const Color(0xFF1E1B4B),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "You can add or remove members anytime.",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: FontFamily.interRegular,
                            color: _secondaryText,
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
    );
  }

  Widget _buildDurationOptionsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Monthly
          Expanded(
            child: _buildDurationCard(
              index: 0,
              title: "Monthly",
              price: "₹500",
              priceSuffix: "per member",
            ),
          ),
          SizedBox(width: 8.w),
          // Quarterly
          Expanded(
            child: _buildDurationCard(
              index: 1,
              title: "Quarterly",
              price: "₹2,400",
              priceSuffix: "per member",
              discountBadge: "Save 20%",
            ),
          ),
          SizedBox(width: 8.w),
          // Yearly
          Expanded(
            child: _buildDurationCard(
              index: 2,
              title: "Yearly",
              price: "₹4,020",
              priceSuffix: "per member",
              discountBadge: "Save 33%",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard({
    required int index,
    required String title,
    required String price,
    required String priceSuffix,
    String? discountBadge,
  }) {
    final bool isSelected = _selectedTeamDuration == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTeamDuration = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? _primaryPurple : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _primaryPurple.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Radio icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: _darkText,
                  ),
                ),
                Container(
                  width: 16.w,
                  height: 16.w,
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
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _primaryPurple,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Price
            Text(
              price,
              style: TextStyle(
                fontSize: 17.sp,
                fontFamily: FontFamily.interBold,
                color: _darkText,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              priceSuffix,
              style: TextStyle(
                fontSize: 10.sp,
                fontFamily: FontFamily.interRegular,
                color: _secondaryText,
              ),
            ),

            SizedBox(height: 8.h),

            // Discount Badge (if any)
            if (discountBadge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _badgeGreenBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  discountBadge,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: _badgeGreenText,
                  ),
                ),
              )
            else
              SizedBox(height: 16.h), // Equalizer space
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummaryCard() {
    // Math calculation for Team Plan
    final String durationName = _selectedTeamDuration == 0
        ? "Monthly"
        : (_selectedTeamDuration == 1 ? "Quarterly" : "Yearly");

    final int ratePerMember = _selectedTeamDuration == 0
        ? 500
        : (_selectedTeamDuration == 1 ? 2400 : 4020);

    // Standard original base calculation
    final int originalTotal = _teamMemberCount * ratePerMember;

    // Built-in Team discount: 20% savings on Monthly base
    const double teamSavingsRate = 0.20;
    int discountedTotal = (originalTotal * (1 - teamSavingsRate)).round();

    // Additional Promo Code discount
    if (_promoDiscountPercent > 0) {
      discountedTotal =
          (discountedTotal * (1 - _promoDiscountPercent)).round();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Breakdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Team Plan ($durationName)",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontFamily: FontFamily.interBold,
                  color: _darkText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "$_teamMemberCount Members × ₹$ratePerMember",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _secondaryText,
                ),
              ),
            ],
          ),

          // Right: Pricing & Savings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _badgeGreenBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      _promoDiscountPercent > 0
                          ? "Save ${(teamSavingsRate * 100 + _promoDiscountPercent * 100).toInt()}%"
                          : "Save 20%",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontFamily: FontFamily.interBold,
                        color: _badgeGreenText,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "₹${_formatCurrency(discountedTotal)}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: FontFamily.interBold,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                "₹${_formatCurrency(originalTotal)} per month",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFF9CA3AF),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
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
  // BOTTOM ACTION BAR & PAYMENT TRIGGER
  // ==========================================
  Widget _buildBottomActionBar(bool isTeam) {
    String buttonText;
    if (isTeam) {
      buttonText = "Continue to Payment";
    } else {
      if (_selectedIndividualPlan == 0) {
        buttonText = "Continue with Monthly Plan";
      } else if (_selectedIndividualPlan == 1) {
        buttonText = "Continue with Quarterly Plan";
      } else {
        buttonText = "Continue with Yearly Plan";
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action Button
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
                _showPaymentMethodBottomSheet(buttonText);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Security Lock Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13.sp,
                color: _secondaryText,
              ),
              SizedBox(width: 6.w),
              Text(
                "Secure & Encrypted Payment",
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROMO CODE BOTTOM SHEET
  // ==========================================
  void _showPromoCodeBottomSheet() {
    final TextEditingController promoController =
        TextEditingController(text: _appliedPromoCode ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Apply Promo Code",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: FontFamily.interBold,
                      color: _darkText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: _secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46.h,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: promoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Enter coupon code (e.g. TEAM20)",
                          hintStyle: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF9CA3AF),
                            fontFamily: FontFamily.interRegular,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final code = promoController.text.trim().toUpperCase();
                        if (code.isEmpty) {
                          Utils().fluttertoast("Please enter a valid code");
                          return;
                        }
                        setState(() {
                          _appliedPromoCode = code;
                          _promoDiscountPercent = 0.10; // Extra 10%
                        });
                        Navigator.pop(ctx);
                        Utils().fluttertoast("Promo code $code applied!");
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontFamily: FontFamily.interBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Preset suggestions
              Text(
                "Available Coupons",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: _darkText,
                ),
              ),
              SizedBox(height: 8.h),
              _buildCouponPresetItem(
                code: "TEAM20",
                description: "Extra 10% off on all plans",
                onSelect: () {
                  setState(() {
                    _appliedPromoCode = "TEAM20";
                    _promoDiscountPercent = 0.10;
                  });
                  Navigator.pop(ctx);
                  Utils().fluttertoast("Coupon TEAM20 applied!");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponPresetItem({
    required String code,
    required String description,
    required VoidCallback onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _lightPurpleBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _softPurpleBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: FontFamily.interBold,
                    color: _primaryPurple,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
            Text(
              "TAP TO APPLY",
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: FontFamily.interBold,
                color: _primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAYMENT FLOW DIALOG / SHEET
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
                  color: _darkText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                planDescription,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interRegular,
                  color: _secondaryText,
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
                    _showSuccessDialog();
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: _lightPurpleBg,
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
                    color: _darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF9CA3AF),
            size: 20.sp,
          ),
        ],
      ),
    );
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
                  color: _darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Your Walkie Talkie plan is now active. Enjoy uninterrupted instant voice communication.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: _secondaryText,
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
                    Get.back(); // close dialog
                    Get.back(); // return to previous screen
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
