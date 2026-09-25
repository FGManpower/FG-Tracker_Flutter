import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieTalkiePlanScreen extends StatefulWidget {
  final int initialTabIndex; // 0 for Individual, 1 for Team Plan
  const WalkieTalkiePlanScreen({
    super.key,
    this.initialTabIndex = 1,
  });

  @override
  State<WalkieTalkiePlanScreen> createState() => _WalkieTalkiePlanScreenState();
}

class _WalkieTalkiePlanScreenState extends State<WalkieTalkiePlanScreen> {
  // 0 = Individual, 1 = Team Plan
  late int _selectedTab;

  // Individual Plan (0 = Monthly, 1 = Quarterly, 2 = Yearly)
  int _selectedIndividualPlan = 0;

  // Team Plan State
  int _teamMemberCount = 5;
  int _selectedTeamDuration = 0; // 0 = Monthly, 1 = Quarterly, 2 = Yearly
  String? _appliedPromoCode;
  double _promoDiscountPercent = 0.0;

  // Color Constants (Matching Screenshots Exactly)
  static const Color _primaryPurple = Color(0xFF5B4DF5);
  static const Color _bgSoft = Color(0xFFF6F8FE);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEDF2F7);
  static const Color _lightPillBg = Color(0xFFF1F3FE);
  static const Color _greenBadgeBg = Color(0xFFDCFCE7);
  static const Color _greenBadgeText = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bool isTeam = _selectedTab == 1;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final bool isSmallScreen = screenWidth < 360;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar + Hero Section
                        _buildTopHeroSection(isTeam, isSmallScreen),

                        SizedBox(height: 12.h),

                        // Feature Highlight Badges (Scrollable)
                        _buildFeaturePills(isTeam),

                        SizedBox(height: 14.h),

                        // Segmented Tab Switcher (Individual / Team Plan)
                        _buildSegmentedTabToggle(isTeam, isSmallScreen),

                        SizedBox(height: 14.h),

                        // Content based on selected tab
                        AnimatedCrossFade(
                          firstChild: _buildIndividualTabContent(isSmallScreen),
                          secondChild: _buildTeamTabContent(isSmallScreen),
                          crossFadeState: isTeam
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // Bottom Continue Action Bar
                _buildBottomActionBar(isTeam),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // TOP HERO SECTION (Back Btn, Title, 3D Hero)
  // ==========================================
  Widget _buildTopHeroSection(bool isTeam, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Squircle Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w.clamp(38.0, 46.0),
              height: 40.w.clamp(38.0, 46.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20.sp.clamp(18.0, 22.0),
                color: _primaryPurple,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isTeam ? "Team Plan" : "Choose a Plan",
                        style: TextStyle(
                          fontSize: 24.sp.clamp(20.0, 28.0),
                          fontFamily: FontFamily.interBold,
                          color: _textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isTeam
                          ? "Add team members and get everyone connected with Walkie Talkie"
                          : "Continue using Walkie Talkie with a plan that fits your team",
                      style: TextStyle(
                        fontSize: 12.sp.clamp(11.0, 13.5),
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // 3D Walkie Talkie Hero Graphic
              _buildWalkieTalkieHeroGraphic(isTeam, isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalkieTalkieHeroGraphic(bool isTeam, bool isSmallScreen) {
    final double graphicWidth =
        (isSmallScreen ? 120.w : 136.w).clamp(110.0, 150.0);
    final double graphicHeight = 124.h.clamp(110.0, 136.0);

    return SizedBox(
      width: graphicWidth,
      height: graphicHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer halo gradient disc
          Container(
            width: 108.w.clamp(90.0, 120.0),
            height: 108.w.clamp(90.0, 120.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primaryPurple.withValues(alpha: 0.15),
                  _primaryPurple.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Walkie Talkie Device
          Positioned(
            right: 26.w,
            bottom: 4.h,
            child: _buildWalkieTalkieDevice(),
          ),

          // Hand-annotated curved arrow and text
          Positioned(
            top: 4.h,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: _primaryPurple.withValues(alpha: 0.8),
                  size: 14.sp.clamp(12.0, 16.0),
                ),
                SizedBox(width: 2.w),
                Text(
                  isTeam
                      ? "Stronger\nTeams\nSafer Sites"
                      : "Stay\nConnected\nAlways",
                  style: TextStyle(
                    fontFamily: FontFamily.interMedium,
                    fontStyle: FontStyle.italic,
                    fontSize: 8.5.sp.clamp(7.5, 10.0),
                    color: _primaryPurple,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),

          // Team Badge in Team Plan
          if (isTeam)
            Positioned(
              right: 4.w,
              bottom: 22.h,
              child: Container(
                padding: EdgeInsets.all(5.5.w),
                decoration: BoxDecoration(
                  color: _primaryPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: _primaryPurple,
                  size: 19.sp.clamp(16.0, 22.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalkieTalkieDevice() {
    return Container(
      width: 58.w.clamp(52.0, 66.0),
      height: 94.h.clamp(86.0, 104.0),
      decoration: BoxDecoration(
        color: const Color(0xFF222433),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.28),
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
            top: -16.h,
            left: 9.w,
            child: Container(
              width: 6.5.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D29),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          // Knob top right
          Positioned(
            top: -7.h,
            right: 10.w,
            child: Container(
              width: 10.w,
              height: 9.h,
              decoration: BoxDecoration(
                color: const Color(0xFF333647),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          // PTT side button
          Positioned(
            left: -3.w,
            top: 26.h,
            child: Container(
              width: 4.w,
              height: 20.h,
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
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16.w,
                    height: 2.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7.h),
              // Illuminated center mic/speaker
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF151722),
                  border: Border.all(
                    color: _primaryPurple,
                    width: 2.2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              // Status dot
              Container(
                width: 4.5.w,
                height: 4.5.w,
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
              onTap: () => setState(() => _selectedTab = 0),
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
              onTap: () => setState(() => _selectedTab = 1),
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
          isSmallScreen: isSmallScreen,
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
          isSmallScreen: isSmallScreen,
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
          isSmallScreen: isSmallScreen,
        ),

        SizedBox(height: 14.h),

        // Info Banner
        Container(
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
    required bool isSmallScreen,
  }) {
    final bool isSelected = _selectedIndividualPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndividualPlan = index),
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
                                      borderRadius: BorderRadius.circular(5.r),
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

                    // Middle Column: Checklist Features (Exact 4 bullets in Screenshot 2)
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.5.h),
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
    return Column(
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
    );
  }

  Widget _buildTeamMembersCard(bool isSmallScreen) {
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
                  GestureDetector(
                    onTap: () {
                      if (_teamMemberCount > 2) {
                        setState(() => _teamMemberCount--);
                      } else {
                        Utils().fluttertoast("Minimum team size is 2 members");
                      }
                    },
                    child: Container(
                      width: 40.w.clamp(36.0, 44.0),
                      height: 40.w.clamp(36.0, 44.0),
                      decoration: const BoxDecoration(
                        color: _lightPillBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color: _primaryPurple,
                        size: 20.sp.clamp(18.0, 22.0),
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Count Display
                  Container(
                    width: (isSmallScreen ? 86.w : 100.w).clamp(80.0, 110.0),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$_teamMemberCount",
                          style: TextStyle(
                            fontSize: 22.sp.clamp(19.0, 26.0),
                            fontFamily: FontFamily.interBold,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          "Members",
                          style: TextStyle(
                            fontSize: 10.5.sp.clamp(9.5, 12.0),
                            fontFamily: FontFamily.interRegular,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Plus Button
                  GestureDetector(
                    onTap: () => setState(() => _teamMemberCount++),
                    child: Container(
                      width: 40.w.clamp(36.0, 44.0),
                      height: 40.w.clamp(36.0, 44.0),
                      decoration: const BoxDecoration(
                        color: _lightPillBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: _primaryPurple,
                        size: 20.sp.clamp(18.0, 22.0),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 10.w),

              // "More Members?" Info Box
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FE),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: _primaryPurple,
                        size: 20.sp.clamp(17.0, 22.0),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "More Members?",
                              style: TextStyle(
                                fontSize: 11.sp.clamp(9.5, 12.0),
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "You can add or remove members anytime.",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.sp.clamp(8.0, 10.5),
                                fontFamily: FontFamily.interRegular,
                                color: _textSecondary,
                                height: 1.2,
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
  }

  Widget _buildTeamDurationCard() {
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
          Row(
            children: [
              // Monthly
              Expanded(
                child: _buildTeamDurationOptionItem(
                  index: 0,
                  title: "Monthly",
                  price: "₹500",
                  priceSuffix: "per member",
                ),
              ),
              SizedBox(width: 8.w),
              // Quarterly
              Expanded(
                child: _buildTeamDurationOptionItem(
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
                child: _buildTeamDurationOptionItem(
                  index: 2,
                  title: "Yearly",
                  price: "₹4,020",
                  priceSuffix: "per member",
                  discountBadge: "Save 33%",
                ),
              ),
            ],
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
  }) {
    final bool isSelected = _selectedTeamDuration == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTeamDuration = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? _primaryPurple : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
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
                          isSelected ? _primaryPurple : const Color(0xFFCBD5E1),
                      width: 1.8.w,
                    ),
                  ),
                  child: isSelected
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
            SizedBox(height: 6.h),
            if (discountBadge != null)
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
              )
            else
              SizedBox(height: 15.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSummaryCard() {
    final String durationName = _selectedTeamDuration == 0
        ? "Monthly"
        : (_selectedTeamDuration == 1 ? "Quarterly" : "Yearly");

    final int ratePerMember = _selectedTeamDuration == 0
        ? 500
        : (_selectedTeamDuration == 1 ? 2400 : 4020);

    final int originalTotal = _teamMemberCount * ratePerMember;
    const double teamSavingsRate = 0.20;
    int discountedTotal = (originalTotal * (1 - teamSavingsRate)).round();

    if (_promoDiscountPercent > 0) {
      discountedTotal = (discountedTotal * (1 - _promoDiscountPercent)).round();
    }

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
                children: [
                  _buildStepNumberBadge("3"),
                  SizedBox(width: 8.w),
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
                        fontSize: 11.5.sp.clamp(10.5, 13.0),
                        fontFamily: FontFamily.interSemiBold,
                        color: _primaryPurple,
                      ),
                    ),
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
            child: Row(
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
                          "$_teamMemberCount Members × ₹$ratePerMember",
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _greenBadgeBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _promoDiscountPercent > 0
                                ? "Save ${(teamSavingsRate * 100 + _promoDiscountPercent * 100).toInt()}%"
                                : "Save 20%",
                            style: TextStyle(
                              fontSize: 9.5.sp.clamp(8.5, 11.0),
                              fontFamily: FontFamily.interBold,
                              color: _greenBadgeText,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "₹${_formatCurrency(discountedTotal)}",
                          style: TextStyle(
                            fontSize: 20.sp.clamp(17.0, 23.0),
                            fontFamily: FontFamily.interBold,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "₹${_formatCurrency(originalTotal)} per month",
                      style: TextStyle(
                        fontSize: 10.5.sp.clamp(9.5, 12.0),
                        fontFamily: FontFamily.interRegular,
                        color: const Color(0xFF94A3B8),
                        decoration: TextDecoration.lineThrough,
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
  // BOTTOM BAR
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
                backgroundColor: _primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              onPressed: () => _showPaymentMethodBottomSheet(buttonText),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 15.sp.clamp(13.5, 16.5),
                        fontFamily: FontFamily.interBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18.sp.clamp(16.0, 20.0),
                  ),
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
  }

  // ==========================================
  // PROMO CODE SHEET
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
                      color: _textDark,
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
                        color: _textSecondary,
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
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: promoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Enter code (e.g. TEAM20)",
                          hintStyle: TextStyle(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF94A3B8),
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
                          _promoDiscountPercent = 0.10;
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
              Text(
                "Available Coupons",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _appliedPromoCode = "TEAM20";
                    _promoDiscountPercent = 0.10;
                  });
                  Navigator.pop(ctx);
                  Utils().fluttertoast("Coupon TEAM20 applied!");
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: _lightPillBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFDCD7FE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TEAM20",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: FontFamily.interBold,
                              color: _primaryPurple,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Extra 10% off on all plans",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: FontFamily.interRegular,
                              color: _textSecondary,
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
              ),
            ],
          ),
        );
      },
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
