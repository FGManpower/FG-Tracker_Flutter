import 'dart:math' as math;
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WalkieTalkiePurchaseSuccessScreen extends StatefulWidget {
  final bool isTeam;
  final String planTitle;
  final int memberCount;
  final String validTill;

  const WalkieTalkiePurchaseSuccessScreen({
    super.key,
    this.isTeam = true,
    this.planTitle = "Team Plan (Monthly)",
    this.memberCount = 5,
    this.validTill = "15 Oct 2026",
  });

  @override
  State<WalkieTalkiePurchaseSuccessScreen> createState() =>
      _WalkieTalkiePurchaseSuccessScreenState();
}

class _WalkieTalkiePurchaseSuccessScreenState
    extends State<WalkieTalkiePurchaseSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rippleAnimation;
  late final Animation<double> _rippleOpacity;
  late final Animation<double> _checkAnimation;
  late final Animation<double> _confettiScale;
  late final Animation<double> _confettiOpacity;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool get isTeam => widget.isTeam;
  String get planTitle => widget.planTitle;
  int get memberCount => widget.memberCount;
  String get validTill => widget.validTill;

  static const Color _primaryPurple = Color(0xFF5B4DF5);
  static const Color _bgSoft = Color(0xFFF7F8FE);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEDF2F7);
  static const Color _lightPillBg = Color(0xFFEEF0FE);
  static const Color _greenBadgeBg = Color(0xFFDCFCE7);
  static const Color _greenBadgeText = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.85, end: 1.55).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.22, 0.72, curve: Curves.easeOut),
      ),
    );

    _rippleOpacity = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.22, 0.72, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.38, 0.82, curve: Curves.easeInOutCubic),
      ),
    );

    _confettiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.18, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _confettiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.12, 0.40, curve: Curves.easeIn),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.48, 0.95, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.48, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final bool isWideScreen = screenWidth > 600;

            Widget content = Column(
              children: [
                // Top close action bar
                _buildTopBar(context),

                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: (isWideScreen ? 24.w : 16.w).clamp(16.0, 32.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 2.h),

                        // Confetti Celebration + Animated Checkmark Badge
                        _buildCelebrationHeader(),

                        SizedBox(height: 10.h),

                        // Animated Content below checkmark
                        FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Title & Subtitle
                                Text(
                                  "Purchase Successful!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21.sp.clamp(18.0, 24.0),
                                    fontFamily: FontFamily.interBold,
                                    color: _textDark,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  isTeam
                                      ? "Your Team Plan is now active"
                                      : "Your Plan is now active",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5.sp.clamp(11.0, 14.0),
                                    fontFamily: FontFamily.interMedium,
                                    color: const Color(0xFF525F7F),
                                  ),
                                ),

                                SizedBox(height: 14.h),

                                // Card 1: Active Plan Details Card
                                _buildPlanDetailsCard(),

                                SizedBox(height: 10.h),

                                // Card 2: What's Next Action Card
                                _buildWhatsNextCard(context),

                                SizedBox(height: 14.h),

                                // Stepper / Timeline
                                _buildTimelineStepper(),

                                SizedBox(height: 12.h),

                                // Info Note Box
                                _buildInfoNoteBox(),

                                SizedBox(height: 12.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                _buildBottomBar(context, isWideScreen),
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
  }

  // ==========================================
  // TOP BAR (Close Button)
  // ==========================================
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => _showNotNowBottomSheet(context),
            icon: Icon(
              Icons.close_rounded,
              color: _textSecondary,
              size: 24.sp.clamp(20.0, 26.0),
            ),
            splashRadius: 20.r,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CELEBRATION HEADER (Confetti + Animated Purple Check)
  // ==========================================
  Widget _buildCelebrationHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        final double checkProgress = _checkAnimation.value;
        final double scale = _scaleAnimation.value;
        final double rippleScale = _rippleAnimation.value;
        final double rippleAlpha = _rippleOpacity.value;
        final double confettiScale = _confettiScale.value;
        final double confettiAlpha = _confettiOpacity.value;
        final double pulseScale =
            _mainController.isCompleted ? (1.0 + (_pulseController.value * 0.05)) : 1.0;

        return SizedBox(
          width: 220.w.clamp(190.0, 240.0),
          height: 114.h.clamp(102.0, 126.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Confetti particles popping out
              Positioned.fill(
                child: Opacity(
                  opacity: confettiAlpha.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: confettiScale,
                    child: CustomPaint(
                      painter: _ConfettiParticlesPainter(),
                    ),
                  ),
                ),
              ),

              // Expanding ripple wave on entrance
              if (rippleAlpha > 0.01)
                Transform.scale(
                  scale: rippleScale,
                  child: Container(
                    width: 70.w.clamp(62.0, 78.0),
                    height: 70.w.clamp(62.0, 78.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryPurple.withValues(alpha: rippleAlpha),
                        width: 2.8.w,
                      ),
                    ),
                  ),
                ),

              // Outer halo glow (with subtle breathing pulse)
              Transform.scale(
                scale: (scale * pulseScale).clamp(0.0, 1.5),
                child: Container(
                  width: 84.w.clamp(76.0, 94.0),
                  height: 84.w.clamp(76.0, 94.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryPurple.withValues(alpha: 0.14),
                  ),
                ),
              ),

              // Inner Purple Checkmark Circle (bouncing in with spring curve)
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 66.w.clamp(60.0, 72.0),
                  height: 66.w.clamp(60.0, 72.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5DF6), Color(0xFF4C3DEE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryPurple.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: Size(
                        38.w.clamp(34.0, 44.0),
                        38.w.clamp(34.0, 44.0),
                      ),
                      painter: _AnimatedCheckmarkPainter(
                        progress: checkProgress,
                        color: Colors.white,
                        strokeWidth: 4.8.w.clamp(4.0, 5.4),
                      ),
                    ),
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
  // CARD 1: PLAN SUMMARY PILL CARD
  // ==========================================
  Widget _buildPlanDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Avatar
          Container(
            width: 42.w.clamp(38.0, 46.0),
            height: 42.w.clamp(38.0, 46.0),
            decoration: const BoxDecoration(
              color: _lightPillBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTeam ? Icons.groups_rounded : Icons.person_rounded,
              color: _primaryPurple,
              size: 22.sp.clamp(19.0, 25.0),
            ),
          ),

          SizedBox(width: 14.w),

          // Plan Name & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  planTitle,
                  style: TextStyle(
                    fontSize: 15.sp.clamp(13.5, 16.5),
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  isTeam
                      ? "$memberCount Members"
                      : "1 Member",
                  style: TextStyle(
                    fontSize: 12.5.sp.clamp(11.0, 13.5),
                    fontFamily: FontFamily.interMedium,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Valid till $validTill",
                  style: TextStyle(
                    fontSize: 11.5.sp.clamp(10.5, 12.5),
                    fontFamily: FontFamily.interRegular,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Active Pill Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _greenBadgeBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              "Active",
              style: TextStyle(
                fontSize: 11.sp.clamp(10.0, 12.5),
                fontFamily: FontFamily.interBold,
                color: _greenBadgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 2: WHAT'S NEXT ACTION CARD
  // ==========================================
  Widget _buildWhatsNextCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAssignMembers(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4FD),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFDFE6FB)),
          boxShadow: [
            BoxShadow(
              color: _primaryPurple.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Walkie Talkie Device Graphic
            _buildMiniWalkieGraphic(),

            SizedBox(width: 12.w),

            // Card Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "What's Next?",
                    style: TextStyle(
                      fontSize: 11.5.sp.clamp(10.5, 12.5),
                      fontFamily: FontFamily.interBold,
                      color: _primaryPurple,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Assign Walkie Access",
                    style: TextStyle(
                      fontSize: 14.5.sp.clamp(13.5, 16.0),
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Select team members who will use Walkie Talkie.",
                    style: TextStyle(
                      fontSize: 11.5.sp.clamp(10.5, 12.5),
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Arrow Action Circle
            Container(
              width: 38.w.clamp(34.0, 42.0),
              height: 38.w.clamp(34.0, 42.0),
              decoration: BoxDecoration(
                color: _primaryPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 19.sp.clamp(17.0, 22.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini Walkie Device Graphic with glowing halo
  Widget _buildMiniWalkieGraphic() {
    return SizedBox(
      width: 58.w.clamp(52.0, 66.0),
      height: 68.h.clamp(60.0, 76.0),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Halo glow behind
          Container(
            width: 54.w.clamp(48.0, 62.0),
            height: 54.w.clamp(48.0, 62.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryPurple.withValues(alpha: 0.12),
            ),
          ),

          // Walkie Talkie 3D asset image
          Assets.walkieTalkie.walkieDevice.image(
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TIMELINE / STEPPER (1, 2, 3)
  // ==========================================
  Widget _buildTimelineStepper() {
    return Column(
      children: [
        // Step 1
        _buildTimelineStepItem(
          stepNumber: "1",
          title: "Assign Walkie Access",
          subtitle: "Choose which members can use Walkie Talkie.",
          isCompletedOrActive: true,
          showConnector: true,
        ),

        // Step 2
        _buildTimelineStepItem(
          stepNumber: "2",
          title: "Set Up Team",
          subtitle: "Invite members, manage roles and permissions.",
          isCompletedOrActive: false,
          showConnector: true,
        ),

        // Step 3
        _buildTimelineStepItem(
          stepNumber: "3",
          title: "Start Communicating",
          subtitle: "Your team is ready to go!",
          isCompletedOrActive: false,
          showConnector: false,
        ),
      ],
    );
  }

  Widget _buildTimelineStepItem({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompletedOrActive,
    required bool showConnector,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Number Badge + Vertical Connector Line
        Column(
          children: [
            Container(
              width: 25.w.clamp(22.0, 28.0),
              height: 25.w.clamp(22.0, 28.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedOrActive
                    ? _primaryPurple
                    : const Color(0xFFEEF2F6),
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    fontSize: 11.sp.clamp(10.0, 12.5),
                    fontFamily: FontFamily.interBold,
                    color: isCompletedOrActive
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            if (showConnector)
              Container(
                width: 1.8.w,
                height: 15.h.clamp(12.0, 18.0),
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),

        SizedBox(width: 10.w),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5.sp.clamp(12.5, 14.5),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp.clamp(10.0, 12.0),
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                  height: 1.25,
                ),
              ),
              if (showConnector) SizedBox(height: 6.h),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // INFO NOTE BOX
  // ==========================================
  Widget _buildInfoNoteBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E7FC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _primaryPurple,
            size: 19.sp.clamp(17.0, 21.0),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "You can manage or change Walkie access anytime from Team Settings.",
              style: TextStyle(
                fontSize: 11.sp.clamp(10.0, 12.0),
                fontFamily: FontFamily.interMedium,
                color: const Color(0xFF475569),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM BAR (Assign Members + Maybe Later)
  // ==========================================
  Widget _buildBottomBar(BuildContext context, bool isWideScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
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
          // Primary "Assign Members" Button
          SizedBox(
            width: double.infinity,
            height: 44.h.clamp(40.0, 48.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: () => _showNotNowBottomSheet(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Assign Members",
                    style: TextStyle(
                      fontSize: 14.5.sp.clamp(13.0, 16.0),
                      fontFamily: FontFamily.interBold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 17.sp.clamp(15.0, 19.0),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Secondary "Maybe Later" Text Action
          GestureDetector(
            onTap: () => _showNotNowBottomSheet(context),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
              child: Text(
                "Maybe Later",
                style: TextStyle(
                  fontSize: 13.5.sp.clamp(12.0, 14.5),
                  fontFamily: FontFamily.interBold,
                  color: _primaryPurple,
                  decoration: TextDecoration.underline,
                  decorationColor: _primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to Assign Members
  void _navigateToAssignMembers() {
    try {
      Get.toNamed(Routes.WalkieGroupSelect);
    } catch (_) {
      Get.to(() => const WalkieGroupSelectScreen());
    }
  }

  // ==========================================
  // "NOT NOW?" BOTTOM SHEET (Image 2)
  // ==========================================
  void _showNotNowBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return LayoutBuilder(
          builder: (ctx, sheetConstraints) {
            final double sheetWidth = sheetConstraints.maxWidth;
            final bool isSheetWide = sheetWidth > 600;

            Widget sheetBody = Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Drag Handle
                  Container(
                    width: 40.w.clamp(36.0, 46.0),
                    height: 4.h.clamp(3.5, 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Clock / Timer Icon with Radiating Ticks
                  _buildRadiantClockGraphic(),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    "Not Now?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp.clamp(18.0, 23.0),
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "You can assign Walkie access later from Team Settings anytime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp.clamp(11.5, 14.0),
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Info Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3FE),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E7FC)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _primaryPurple,
                          size: 20.sp.clamp(18.0, 22.0),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            "Your plan is active. Team members will not have Walkie access until you assign them.",
                            style: TextStyle(
                              fontSize: 11.5.sp.clamp(10.5, 12.5),
                              fontFamily: FontFamily.interRegular,
                              color: const Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Two Action Buttons: "Back" & "Continue to Home ->"
                  Row(
                    children: [
                      // Back Button
                      Expanded(
                        child: SizedBox(
                          height: 46.h.clamp(42.0, 50.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F3FE),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                fontSize: 14.sp.clamp(13.0, 15.5),
                                fontFamily: FontFamily.interBold,
                                color: _primaryPurple,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Continue to Home Button
                      Expanded(
                        child: SizedBox(
                          height: 46.h.clamp(42.0, 50.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              try {
                                Get.offAllNamed(Routes.Home_Screen);
                              } catch (_) {
                                Get.back();
                                Get.back();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Continue to Home",
                                      style: TextStyle(
                                        fontSize: 13.5.sp.clamp(12.0, 15.0),
                                        fontFamily: FontFamily.interBold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16.sp.clamp(14.0, 18.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isSheetWide) {
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: sheetBody,
                ),
              );
            }

            return sheetBody;
          },
        );
      },
    );
  }

  // Radiant Clock Graphic with 4 tick marks around it
  Widget _buildRadiantClockGraphic() {
    return SizedBox(
      width: 110.w.clamp(96.0, 120.0),
      height: 60.h.clamp(52.0, 68.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Top Tick
          Positioned(
            left: 12.w,
            top: 10.h,
            child: Transform.rotate(
              angle: -math.pi / 5,
              child: Container(
                width: 9.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Left Bottom Tick
          Positioned(
            left: 8.w,
            bottom: 15.h,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: 10.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Right Top Tick
          Positioned(
            right: 12.w,
            top: 10.h,
            child: Transform.rotate(
              angle: math.pi / 5,
              child: Container(
                width: 9.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Right Bottom Tick
          Positioned(
            right: 8.w,
            bottom: 15.h,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 10.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),

          // Central Clock Circle
          Container(
            width: 54.w.clamp(48.0, 60.0),
            height: 54.w.clamp(48.0, 60.0),
            decoration: const BoxDecoration(
              color: _lightPillBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.access_time_rounded,
                color: _primaryPurple,
                size: 26.sp.clamp(22.0, 28.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CONFETTI PARTICLES CUSTOM PAINTER
// ==========================================
class _ConfettiParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final Paint purplePaint = Paint()
      ..color = const Color(0xFF6B5AF6)
      ..style = PaintingStyle.fill;

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..style = PaintingStyle.fill;

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final Paint pinkPaint = Paint()
      ..color = const Color(0xFFF472B6)
      ..style = PaintingStyle.fill;

    // Curved Ribbon Helper
    void drawCurvedRibbon(
      Canvas c,
      Offset start,
      Offset control,
      Offset end,
      double strokeWidth,
      Color color,
    ) {
      final Paint strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final Path p = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      c.drawPath(p, strokePaint);
    }

    // Diamond spark helper
    void drawDiamond(Canvas c, Offset center, double size, Paint p) {
      final Path path = Path()
        ..moveTo(center.dx, center.dy - size)
        ..lineTo(center.dx + size * 0.7, center.dy)
        ..lineTo(center.dx, center.dy + size)
        ..lineTo(center.dx - size * 0.7, center.dy)
        ..close();
      c.drawPath(path, p);
    }

    // TOP-LEFT PARTICLES
    // Purple squiggle top-left
    drawCurvedRibbon(
      canvas,
      Offset(cx - 35, cy - 42),
      Offset(cx - 30, cy - 54),
      Offset(cx - 24, cy - 48),
      3.2,
      const Color(0xFF6366F1),
    );

    // Green ribbon far-left
    drawCurvedRibbon(
      canvas,
      Offset(cx - 68, cy - 28),
      Offset(cx - 56, cy - 36),
      Offset(cx - 62, cy - 18),
      3.0,
      const Color(0xFF34D399),
    );

    // Coral / Pink dot top-left
    canvas.drawCircle(Offset(cx - 40, cy - 24), 3.0, pinkPaint);

    // Yellow diamond mid-left
    drawDiamond(canvas, Offset(cx - 50, cy - 10), 3.2, yellowPaint);

    // Yellow diamond lower-left
    drawDiamond(canvas, Offset(cx - 72, cy + 18), 3.2, yellowPaint);

    // Blue dot lower-left
    canvas.drawCircle(Offset(cx - 48, cy + 24), 2.8, bluePaint);

    // Green dot top-center
    canvas.drawCircle(Offset(cx + 32, cy - 44), 3.0, greenPaint);

    // Pink dot top-right
    canvas.drawCircle(Offset(cx + 48, cy - 34), 3.0, pinkPaint);

    // Purple dot far-right
    canvas.drawCircle(Offset(cx + 46, cy - 18), 2.8, purplePaint);

    // TOP-RIGHT PARTICLES
    // Purple curved squiggle top-right
    drawCurvedRibbon(
      canvas,
      Offset(cx + 66, cy - 30),
      Offset(cx + 72, cy - 20),
      Offset(cx + 64, cy - 14),
      3.2,
      const Color(0xFF818CF8),
    );

    // Yellow diamond top-right
    drawDiamond(canvas, Offset(cx + 36, cy - 14), 3.0, yellowPaint);

    // Green ribbon bottom-right
    drawCurvedRibbon(
      canvas,
      Offset(cx + 64, cy + 12),
      Offset(cx + 56, cy + 20),
      Offset(cx + 60, cy + 26),
      3.0,
      const Color(0xFF34D399),
    );

    // Yellow diamond bottom-right
    drawDiamond(canvas, Offset(cx + 40, cy + 22), 3.2, yellowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedCheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _AnimatedCheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Normalized checkmark vertices matching the screenshot checkmark proportions
    final p1 = Offset(size.width * 0.27, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.70);
    final p3 = Offset(size.width * 0.75, size.height * 0.35);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalLength = metric.length;
    final currentLength = totalLength * progress.clamp(0.0, 1.0);

    final extracted = metric.extractPath(0.0, currentLength);
    canvas.drawPath(extracted, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedCheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

