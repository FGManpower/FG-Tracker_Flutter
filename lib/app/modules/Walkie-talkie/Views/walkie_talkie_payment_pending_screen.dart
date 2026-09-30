import 'dart:math' as math;
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Model/razorpay_payment_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_plan_details.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalkieTalkiePaymentPendingScreen extends StatefulWidget {
  final bool isTeam;
  final String planTitle;
  final int memberCount;
  final num? amountPaid;
  final String? transactionTime;
  final String? orderId;

  const WalkieTalkiePaymentPendingScreen({
    super.key,
    this.isTeam = true,
    this.planTitle = "Safe Route Plan",
    this.memberCount = 1,
    this.amountPaid,
    this.transactionTime,
    this.orderId,
  });

  @override
  State<WalkieTalkiePaymentPendingScreen> createState() =>
      _WalkieTalkiePaymentPendingScreenState();
}

class _WalkieTalkiePaymentPendingScreenState
    extends State<WalkieTalkiePaymentPendingScreen>
    with TickerProviderStateMixin {
  late final RazorpayPaymentController controller;
  late final AnimationController _pulseController;
  late final AnimationController _orbitController;
  late final AnimationController _fadeController;

  final RxBool _isRefreshing = false.obs;

  static const Color _primaryPurple = AppColors.primaryDarkblue;
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _pendingAmber = Color(0xFFF59E0B);
  static const Color _successGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RazorpayPaymentController>()
        ? Get.find<RazorpayPaymentController>()
        : Get.put(RazorpayPaymentController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
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
    if (controller.planTitle.value.isNotEmpty &&
        controller.planTitle.value != "Team Plan (Monthly)") {
      return controller.planTitle.value;
    }
    return widget.planTitle;
  }

  Future<void> _handleRefreshStatus() async {
    if (_isRefreshing.value) return;
    _isRefreshing.value = true;
    HapticFeedback.mediumImpact();

    try {
      if (controller.createdPaymentId != null &&
          controller.createdPaymentId! > 0) {
        final verifyRes = await WalkiePlanRepo.verifyPayment(
          paymentId: controller.createdPaymentId!,
          razorpayOrderId: controller.createdRazorpayOrderId ?? '',
          razorpayPaymentId: controller.successPaymentId.value ?? '',
          razorpaySignature: controller.successSignature.value ?? '',
        );

        if (verifyRes.status == true) {
          controller.status.value = PaymentProcessStatus.success;
          controller.refreshWalkieOverviewSilently();
          Get.off(() => WalkieTalkiePurchaseSuccessScreen(
                isTeam: controller.isTeam.value,
                planTitle: _displayTitle,
                memberCount: controller.memberCount.value,
                amountPaid: _displayAmount,
                paymentId: controller.successPaymentId.value,
                orderId: controller.createdRazorpayOrderId,
                transactionTime: _displayTime,
              ));
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 1200));
      controller.showTopSnackbar("Payment status is still processing. Please wait.");
    } catch (e) {
      controller.showTopSnackbar("Payment still in progress. We'll update once confirmed.");
    } finally {
      _isRefreshing.value = false;
    }
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? (screenWidth - 540) / 2 : 20.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),

                // Top Animated Orbiting Clock Graphic
                _buildTopPendingIllustration(),

                SizedBox(height: 24.h),

                // Title & Subtitle
                Text(
                  "Payment Pending",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Your payment is being processed by the payment provider.\nThis may take a few minutes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 24.h),

                // Plan Details Card
                _buildPlanDetailsCard(),

                SizedBox(height: 20.h),

                // Payment Status Stepper Card
                _buildPaymentStatusCard(),

                SizedBox(height: 32.h),

                // Bottom Buttons
                _buildActionButtons(),

                SizedBox(height: 24.h),
              ],
            ),
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
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Center(
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _textDark,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Pending",
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          Text(
            "Your payment is being processed",
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: FontFamily.interRegular,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP PENDING ORBITING ILLUSTRATION (Clock + Card + Shield)
  // ============================================================
  Widget _buildTopPendingIllustration() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _orbitController]),
      builder: (context, child) {
        final double pulse = _pulseController.value;
        final double orbit = _orbitController.value * 2 * math.pi;

        return SizedBox(
          width: 260.w,
          height: 120.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient soft golden/orange background glow
              Container(
                width: 130.w + (pulse * 20.w),
                height: 90.h + (pulse * 15.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _pendingAmber.withValues(alpha: 0.28),
                      _pendingAmber.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // Orbiting curved dotted ring
              CustomPaint(
                size: Size(240.w, 100.h),
                painter: _OrbitRingPainter(pulse: pulse),
              ),

              // Left floating Card badge
              Positioned(
                left: 12.w + math.sin(orbit) * 3.w,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF2FE),
                    border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: const Color(0xFF4F46E5),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),

              // Right floating Shield badge
              Positioned(
                right: 12.w - math.sin(orbit) * 3.w,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF6FF),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shield_rounded,
                      color: const Color(0xFF2563EB),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),

              // Center Glowing Clock
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _pendingAmber.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.access_time_filled_rounded,
                    color: Colors.white,
                    size: 38.sp,
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
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plan Details",
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 14.h),

          // Plan Item Row 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.near_me_rounded,
                  color: _primaryPurple,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
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
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "Monthly Plan",
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontFamily: FontFamily.interMedium,
                              color: const Color(0xFF6D28D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Real-time monitoring • Instant alerts",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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

          SizedBox(height: 14.h),
          const Divider(color: _cardBorder, height: 1),
          SizedBox(height: 14.h),

          // Total Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Payment initiated on $_displayTime",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹${controller.formatAmount(_displayAmount)}",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: FontFamily.interBold,
                        color: _primaryPurple,
                      ),
                    ),
                    TextSpan(
                      text: " / month",
                      style: TextStyle(
                        fontSize: 11.5.sp,
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
  // PAYMENT STATUS STEPPER CARD
  // ============================================================
  Widget _buildPaymentStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Status",
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 16.h),

          // Step 1: Payment Initiated (Completed)
          _buildStepRow(
            icon: Icons.check_circle_rounded,
            iconColor: _pendingAmber,
            title: "Payment Initiated",
            subtitle: _displayTime,
            statusBadgeText: "Completed",
            statusBadgeBg: const Color(0xFFDCFCE7),
            statusBadgeTextColor: const Color(0xFF15803D),
            isLast: false,
            isCompleted: true,
          ),

          // Step 2: Processing Payment (In Progress)
          _buildStepRow(
            icon: Icons.radio_button_checked_rounded,
            iconColor: _pendingAmber,
            title: "Processing Payment",
            subtitle: "Your payment is being confirmed",
            statusBadgeText: "In Progress",
            statusBadgeBg: const Color(0xFFFEF3C7),
            statusBadgeTextColor: const Color(0xFFB45309),
            isLast: false,
            isCompleted: false,
            isActive: true,
          ),

          // Step 3: Activate Plan (Pending)
          _buildStepRow(
            icon: Icons.circle_outlined,
            iconColor: const Color(0xFFCBD5E1),
            title: "Activate Plan",
            subtitle: "Your plan will be activated automatically",
            statusBadgeText: "Pending",
            statusBadgeBg: const Color(0xFFF1F5F9),
            statusBadgeTextColor: const Color(0xFF64748B),
            isLast: true,
            isCompleted: false,
          ),

          SizedBox(height: 14.h),

          // Notice Info Container
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: _primaryPurple,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "Please do not close the app. We will notify you once the payment is confirmed and your plan is activated.",
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String statusBadgeText,
    required Color statusBadgeBg,
    required Color statusBadgeTextColor,
    required bool isLast,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon and Vertical Line
          Column(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? _pendingAmber.withValues(alpha: 0.15)
                      : (isCompleted
                          ? _pendingAmber.withValues(alpha: 0.15)
                          : Colors.transparent),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: isActive ? 18.sp : 18.sp,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isCompleted
                        ? _pendingAmber.withValues(alpha: 0.6)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // Texts and Status Badge
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interBold,
                            color: _textDark,
                          ),
                        ),
                        SizedBox(height: 3.h),
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
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusBadgeBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      statusBadgeText,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontFamily: FontFamily.interMedium,
                        color: statusBadgeTextColor,
                      ),
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

  // ============================================================
  // ACTION BUTTONS (Refresh Status & View Plan Details)
  // ============================================================
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Refresh Status Primary Button
        Obx(() {
          final bool loading = _isRefreshing.value;
          return SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: loading ? null : _handleRefreshStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Refresh Status",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontFamily: FontFamily.interBold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                      ],
                    ),
            ),
          );
        }),

        SizedBox(height: 12.h),

        // View Plan Details Secondary Button
        SizedBox(
          width: double.infinity,
          height: 52.h,
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
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              "View Plan Details",
              style: TextStyle(
                fontSize: 14.5.sp,
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

class _OrbitRingPainter extends CustomPainter {
  final double pulse;

  _OrbitRingPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
