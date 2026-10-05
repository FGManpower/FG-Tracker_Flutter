import 'dart:math' as math;
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Model/razorpay_payment_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_order_summary_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalkieTalkiePaymentFailedScreen extends StatefulWidget {
  final bool isTeam;
  final String planTitle;
  final String? durationName;
  final int? memberCount;
  final num? amountPaid;
  final String? transactionTime;
  final String? errorMessage;
  final String? orderId;

  const WalkieTalkiePaymentFailedScreen({
    super.key,
    this.isTeam = true,
    this.planTitle = "Safe Route Plan",
    this.durationName,
    this.memberCount = 1,
    this.amountPaid,
    this.transactionTime,
    this.errorMessage,
    this.orderId,
  });

  @override
  State<WalkieTalkiePaymentFailedScreen> createState() =>
      _WalkieTalkiePaymentFailedScreenState();
}

class _WalkieTalkiePaymentFailedScreenState
    extends State<WalkieTalkiePaymentFailedScreen>
    with TickerProviderStateMixin {
  late final RazorpayPaymentController controller;
  late final AnimationController _pulseController;
  late final AnimationController _shakeController;
  late final AnimationController _fadeController;

  static const Color _primaryPurple = AppColors.primaryDarkblue;
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RazorpayPaymentController>()
        ? Get.find<RazorpayPaymentController>()
        : Get.put(RazorpayPaymentController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String get _displayTime {
    if (widget.transactionTime != null && widget.transactionTime!.isNotEmpty) {
      return widget.transactionTime!;
    }
    if (controller.transactionTime.value.isNotEmpty) {
      return controller.transactionTime.value;
    }
    return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  }

  num get _displayAmount {
    if (widget.amountPaid != null && widget.amountPaid! > 0) {
      return widget.amountPaid!;
    }
    if (controller.amountPaid.value > 0) {
      return controller.amountPaid.value;
    }
    return 798;
  }

  String get _displayTitle {
    if (widget.planTitle.isNotEmpty && widget.planTitle != "Safe Route Plan") {
      return widget.planTitle;
    }
    if (controller.planTitle.value.isNotEmpty &&
        controller.planTitle.value != "Team Plan (Monthly)") {
      return controller.planTitle.value;
    }
    return widget.planTitle;
  }

  String get _displayBadge {
    if (widget.isTeam && widget.memberCount != null && widget.memberCount! > 1) {
      return "${widget.memberCount} Members";
    }
    if (widget.durationName != null && widget.durationName!.isNotEmpty) {
      return widget.durationName!;
    }
    final title = _displayTitle.toLowerCase();
    if (title.contains("year") || title.contains("annual")) {
      return "Annual Plan";
    }
    if (title.contains("quarter")) {
      return "Quarterly Plan";
    }
    if (widget.isTeam) {
      return "Team Plan";
    }
    return "Individual Plan";
  }

  String get _displayInterval {
    if (widget.durationName != null && widget.durationName!.isNotEmpty) {
      final d = widget.durationName!.toLowerCase();
      if (d.contains("month")) return "month";
      if (d.contains("year") || d.contains("annual")) return "year";
      if (d.contains("quarter")) return "quarter";
      return widget.durationName!;
    }
    final title = _displayTitle.toLowerCase();
    if (title.contains("year") || title.contains("annual")) return "year";
    if (title.contains("quarter")) return "quarter";
    if (title.contains("month")) return "month";
    return "plan";
  }

  String get _displayErrorMessage {
    final msg = widget.errorMessage;
    if (msg == null ||
        msg.trim().isEmpty ||
        msg.toLowerCase() == 'undefined' ||
        msg.toLowerCase() == 'null') {
      return "Your payment was not completed. No amount has been charged to your account.";
    }
    return msg;
  }

  void _handleRetryPayment() {
    HapticFeedback.lightImpact();
    Get.back();
  }

  void _showSupportDialog() {
    HapticFeedback.selectionClick();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEEF2FF),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: _primaryPurple,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Contact Support",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Need help with your payment? Our team is available 24/7 to assist you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 15, color: _primaryPurple),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "support@fgtracker.in",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontFamily: FontFamily.interMedium,
                              color: _textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        const Icon(Icons.call_outlined, size: 15, color: _primaryPurple),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "+91 98765 43210",
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontFamily: FontFamily.interMedium,
                              color: _textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 42.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text("Done", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: _buildAppBar(isWideScreen),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? (screenWidth - 520) / 2 : 18.w,
                  vertical: 14.h,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 28.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 6.h),

                          // Top Red Radiating Error Icon Illustration
                          _buildTopFailedIllustration(),

                          SizedBox(height: 18.h),

                          // Title & Subtitle
                          Text(
                            "Payment Failed",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontFamily: FontFamily.interBold,
                              color: _textDark,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              "We couldn't complete your payment.\nPlease try again or use a different payment method.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: FontFamily.interRegular,
                                color: _textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Plan Details Card
                          _buildPlanDetailsCard(),

                          SizedBox(height: 14.h),

                          // Red Error Banner
                          _buildErrorBanner(),

                          SizedBox(height: 16.h),

                          // What you can do next Card
                          _buildNextStepsCard(),
                        ],
                      ),

                      // Bottom Action Buttons
                      Padding(
                        padding: EdgeInsets.only(top: 24.h, bottom: 12.h),
                        child: _buildActionButtons(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    return AppBar(
      backgroundColor: _bgSoft,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Center(
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              height: 38.w,
              width: 38.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: _textDark,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Payment Failed",
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          Text(
            "We couldn't complete your payment",
            style: TextStyle(
              fontSize: 10.5.sp,
              fontFamily: FontFamily.interRegular,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP FAILED GLOWING CROSS ILLUSTRATION
  // ============================================================
  Widget _buildTopFailedIllustration() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulse = _pulseController.value;

        return SizedBox(
          width: 140.w,
          height: 105.h,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Soft outer red radial halo
              Container(
                width: 95.w + (pulse * 15.w),
                height: 95.w + (pulse * 15.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF43F5E).withValues(alpha: 0.18),
                      const Color(0xFFF43F5E).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // Radiating impact particle lines (Custom Painted)
              CustomPaint(
                size: Size(130.w, 90.h),
                painter: _RadiatingParticlesPainter(pulse: pulse),
              ),

              // Soft middle red glow circle
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF1F2),
                  border: Border.all(
                    color: const Color(0xFFFECDD3),
                    width: 1.8,
                  ),
                ),
              ),

              // Center Glowing Red Circle with Cross
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4D4D), Color(0xFFE11D48)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PLAN DETAILS CARD
  // ============================================================
  Widget _buildPlanDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plan Details",
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 12.h),

          // Plan Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  widget.isTeam ? Icons.groups_rounded : Icons.near_me_rounded,
                  color: _primaryPurple,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _displayTitle,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: _textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _displayBadge,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontFamily: FontFamily.interMedium,
                              color: const Color(0xFF6D28D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      widget.isTeam
                          ? "Multi-member access • Instant alerts"
                          : "Real-time monitoring • Instant alerts",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "₹${controller.formatAmount(_displayAmount)}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          const Divider(color: _cardBorder, height: 1),
          SizedBox(height: 12.h),

          // Total Amount Row (Responsive with flexible wrapping)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: FontFamily.interBold,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Payment failed on $_displayTime",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              RichText(
                textAlign: TextAlign.end,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹${controller.formatAmount(_displayAmount)}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: FontFamily.interBold,
                        color: _primaryPurple,
                      ),
                    ),
                    TextSpan(
                      text: " / $_displayInterval",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RED ERROR BANNER
  // ============================================================
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE11D48),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment could not be processed",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFFE11D48),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _displayErrorMessage,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WHAT YOU CAN DO NEXT CARD
  // ============================================================
  Widget _buildNextStepsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What you can do next?",
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 12.h),

          // Option 1: Try Again
          _buildActionOptionTile(
            icon: Icons.refresh_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: _primaryPurple,
            title: "Try Again",
            subtitle: "Retry the payment with the same method",
            onTap: _handleRetryPayment,
          ),

          SizedBox(height: 8.h),

          // Option 2: Use a Different Payment Method
          _buildActionOptionTile(
            icon: Icons.credit_card_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: _primaryPurple,
            title: "Use a Different Payment Method",
            subtitle: "Try UPI, Card, Net Banking or Wallet",
            onTap: _handleRetryPayment,
          ),

          SizedBox(height: 8.h),

          // Option 3: Contact Support
          _buildActionOptionTile(
            icon: Icons.help_outline_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF7C3AED),
            title: "Contact Support",
            subtitle: "Get help from our support team",
            onTap: _showSupportDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildActionOptionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS (Try Again & View Plan Details)
  // ============================================================
  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Try Again Primary Button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _handleRetryPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // View Plan Details Secondary Button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton(
            onPressed: () {
              Get.to(() => WalkieTalkiePlanScreen(
                    initialTabIndex: widget.isTeam ? 1 : 0,
                  ));
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "View Plan Details",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interMedium,
                color: _primaryPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RadiatingParticlesPainter extends CustomPainter {
  final double pulse;

  _RadiatingParticlesPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint dotPaint = Paint()
      ..color = const Color(0xFFE11D48).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double spread = 38.0 + (pulse * 5.0);

    // 6 Radiating lines
    final angles = [
      -math.pi / 4,
      math.pi / 4,
      -3 * math.pi / 4,
      3 * math.pi / 4,
      -math.pi,
      0.0,
    ];

    for (final angle in angles) {
      final double startR = spread;
      final double endR = spread + 12.0;
      final Offset start = Offset(
        center.dx + math.cos(angle) * startR,
        center.dy + math.sin(angle) * startR,
      );
      final Offset end = Offset(
        center.dx + math.cos(angle) * endR,
        center.dy + math.sin(angle) * endR,
      );
      canvas.drawLine(start, end, linePaint);
    }

    // 4 decorative dots
    final dotAngles = [
      -math.pi / 3,
      math.pi / 3,
      -2 * math.pi / 3,
      2 * math.pi / 3,
    ];
    for (final angle in dotAngles) {
      final Offset dotPos = Offset(
        center.dx + math.cos(angle) * (spread - 3),
        center.dy + math.sin(angle) * (spread - 3),
      );
      canvas.drawCircle(dotPos, 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadiatingParticlesPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
