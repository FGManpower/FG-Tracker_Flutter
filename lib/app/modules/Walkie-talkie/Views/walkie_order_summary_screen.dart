import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalkieOrderSummaryScreen extends StatefulWidget {
  final WalkiePaymentOrderModel? order;

  const WalkieOrderSummaryScreen({
    super.key,
    this.order,
  });

  @override
  State<WalkieOrderSummaryScreen> createState() =>
      _WalkieOrderSummaryScreenState();
}

class _WalkieOrderSummaryScreenState extends State<WalkieOrderSummaryScreen> {
  late final WalkieOrderSummaryController controller;

  static const Color _primaryPurple = Color(0xFF5B4DF5);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEDF2F7);
  static const Color _lightPillBg = Color(0xFFEEF0FE);
  static const Color _greenText = Color(0xFF16A34A);
  static const Color _greenBg = Color(0xFFDCFCE7);

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<WalkieOrderSummaryController>()) {
      controller = Get.find<WalkieOrderSummaryController>();
      if (widget.order != null) {
        controller.order.value = widget.order!;
      }
    } else {
      controller = Get.put(WalkieOrderSummaryController(widget.order));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 550;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: _buildAppBar(isWideScreen),
      body: SafeArea(
        top: false,
        child: Center(
          child: Container(
            constraints:
                isWideScreen ? const BoxConstraints(maxWidth: 520) : null,
            child: Column(
              children: [
                // Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Obx(
                      () => Skeletonizer(
                        enabled: controller.isLoadingSummary.value &&
                            controller.summaryData.value == null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),

                            // Top Error / Offline Banner
                            _buildTopErrorBanner(),

                            // Card 1: Selected Plan Details Card
                            _buildPlanOverviewCard(),

                            SizedBox(height: 14.h),

                            // Card 2: Applied Promo / Coupon Code Section (Only shown when applied)
                            _buildPromoCodeCard(),

                            // Card 3: Razorpay Payment Initiation Card (Between Box 1 & Box 2)
                            _buildRazorpayInitiateCard(),

                            // Card 4: Payment Details Summary Card
                            _buildPaymentDetailsCard(),

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Fixed Bottom Action Bar (Pay Button & Terms)
                _buildBottomPaymentBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // APP BAR (Standard App Style)
  // ==========================================
  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    final Widget titleRow = Row(
      children: [
        // Squircle Back Button
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
              size: 19.sp.clamp(17.0, 22.0),
              color: _primaryPurple,
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 17.sp.clamp(15.0, 19.0),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Review your plan details & proceed to pay",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp.clamp(10.0, 12.5),
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 8.w),

        // 100% Secure Encrypted Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3FE),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_rounded,
                size: 16.sp,
                color: _primaryPurple,
              ),
              SizedBox(width: 5.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "100% Secure",
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      fontFamily: FontFamily.interBold,
                      color: _primaryPurple,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "Encrypted Payment",
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return AppBar(
      backgroundColor: _bgSoft,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60.h.clamp(54.0, 68.0),
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
        margin: EdgeInsets.only(bottom: 12.h),
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
              onTap: () {
                controller.fetchOrderSummary();
                controller.fetchCoupons();
              },
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
  // CARD 1: PLAN OVERVIEW CARD
  // ==========================================
  Widget _buildPlanOverviewCard() {
    return Obx(() {
      final order = controller.order.value;
      final String planTitle = controller.planName;
      final String duration = controller.durationName;
      final int seats = controller.purchasedSeats;
      final num rate = controller.pricePerMember;
      final num planAmount = controller.planAmount;
      final num totalPayable = controller.totalPayable;
      final bool isDiscounted = controller.hasDiscount;
      final bool isMultiMember = order.isTeam || seats > 1;

      return Container(
        width: double.infinity,
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
            // Top Row: Icon + Title & Subtitle + Optional Badge
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _lightPillBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isMultiMember ? Icons.groups_rounded : Icons.person_rounded,
                    size: 24.sp,
                    color: _primaryPurple,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planTitle,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontFamily: FontFamily.interBold,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isMultiMember
                            ? "For Multiple Members"
                            : "For Single Member",
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

            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // 3-Column Info Row (Members, Duration, Price per member)
            Row(
              children: [
                // Col 1: Members
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Members",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: _textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMultiMember
                                ? Icons.group_outlined
                                : Icons.person_outline_rounded,
                            size: 15.sp,
                            color: _primaryPurple,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              isMultiMember ? "$seats Members" : "1 Member",
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 32.h,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                ),

                // Col 2: Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: _textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 15.sp,
                            color: _primaryPurple,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              duration,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 32.h,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                ),

                // Col 3: Price per member
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price per member",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: _textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 15.sp,
                            color: _primaryPurple,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              "₹${controller.formatCurrency(rate)}",
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Bottom Row: Total Amount
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
                    SizedBox(height: 2.h),
                    Text(
                      isMultiMember
                          ? "$seats Members × ₹${controller.formatCurrency(rate)}"
                          : "1 Member × ₹${controller.formatCurrency(rate)}",
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontFamily: FontFamily.interRegular,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isDiscounted) ...[
                      Text(
                        "₹${controller.formatCurrency(planAmount)}",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontFamily: FontFamily.interMedium,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    Text(
                      "₹${controller.formatCurrency(totalPayable)}",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: FontFamily.interBold,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ==========================================
  // CARD 2: APPLIED PROMO / COUPON CODE SECTION (Only shown when applied)
  // ==========================================
  Widget _buildPromoCodeCard() {
    return Obx(() {
      final bool isApplied = controller.isCouponApplied;
      if (!isApplied) {
        return const SizedBox.shrink();
      }

      final String? code = controller.currentPromoCode;
      final num discount = controller.discountAmount;

      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF86EFAC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: _greenBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 19.sp,
                color: _greenText,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code != null && code.isNotEmpty
                        ? "Coupon Applied ($code)"
                        : "Coupon Applied",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interBold,
                      color: _greenText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "You saved ₹${controller.formatCurrency(discount)} with this coupon",
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
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.removeCoupon();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "Remove",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interBold,
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
  // CARD 3: PAYMENT METHODS & RAZORPAY INITIATION CARD
  // ==========================================
  Widget _buildRazorpayInitiateCard() {
    return Obx(() {
      final bool isProcessing = controller.isProcessingPayment.value;
      final String activeMethod = controller.selectedPaymentMethod.value;

      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isProcessing
                ? _primaryPurple.withValues(alpha: 0.5)
                : _cardBorder,
          ),
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
            // Top Header: Title & 100% Secure Badge
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3FE),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          size: 20.sp,
                          color: _primaryPurple,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Method",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: FontFamily.interBold,
                                color: _textDark,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Choose preferred payment mode",
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
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _greenBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: 11.sp,
                        color: _greenText,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "SECURE",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontFamily: FontFamily.interBold,
                          color: _greenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Main Payment Method Selection Tabs
            Row(
              children: [
                _buildMethodPill(
                  id: 'upi',
                  icon: Icons.bolt_rounded,
                  label: "UPI / QR",
                  isSelected: activeMethod == 'upi',
                ),
                SizedBox(width: 6.w),
                _buildMethodPill(
                  id: 'card',
                  icon: Icons.credit_card_rounded,
                  label: "Cards",
                  isSelected: activeMethod == 'card',
                ),
                SizedBox(width: 6.w),
                _buildMethodPill(
                  id: 'netbanking',
                  icon: Icons.account_balance_rounded,
                  label: "NetBanking",
                  isSelected: activeMethod == 'netbanking',
                ),
                SizedBox(width: 6.w),
                _buildMethodPill(
                  id: 'wallet',
                  icon: Icons.account_balance_wallet_rounded,
                  label: "Wallets",
                  isSelected: activeMethod == 'wallet',
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // Dynamic Sub-options based on active selection
            if (activeMethod == 'upi') ...[
              _buildUpiSubOptions(),
            ] else if (activeMethod == 'card') ...[
              _buildCardSubOptions(),
            ] else if (activeMethod == 'netbanking') ...[
              _buildNetBankingSubOptions(),
            ] else if (activeMethod == 'wallet') ...[
              _buildWalletSubOptions(),
            ],

            SizedBox(height: 12.h),

            // Info / Checkout trigger banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isProcessing
                    ? const Color(0xFFF1F3FE)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isProcessing
                      ? const Color(0xFFC7D2FE)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  if (isProcessing) ...[
                    SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _primaryPurple,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Opening Razorpay Payment Checkout...",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _primaryPurple,
                        ),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.verified_user_rounded,
                      size: 15.sp,
                      color: _primaryPurple,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Secure 256-bit payment processed via Razorpay Gateway.",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interRegular,
                          color: _textDark,
                        ),
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

  Widget _buildMethodPill({
    required String id,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.selectedPaymentMethod.value = id;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFF1F3FE) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? _primaryPurple : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17.sp,
                color: isSelected ? _primaryPurple : _textSecondary,
              ),
              SizedBox(height: 3.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: isSelected
                        ? FontFamily.interBold
                        : FontFamily.interMedium,
                    color: isSelected ? _primaryPurple : _textDark,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiSubOptions() {
    return Obx(() {
      final selectedApp = controller.selectedUpiApp.value;
      final currentTab = controller.selectedUpiTab.value;
      final customVpa = controller.customUpiVpa.value;

      final upiTabs = [
        {'id': 'apps', 'label': 'UPI Apps', 'icon': Icons.apps_rounded},
        {'id': 'vpa', 'label': 'Enter UPI ID', 'icon': Icons.alternate_email_rounded},
        {'id': 'qr', 'label': 'Scan QR', 'icon': Icons.qr_code_rounded},
      ];

      final apps = [
        {'id': 'gpay', 'name': 'Google Pay', 'type': 'gpay'},
        {'id': 'phonepe', 'name': 'PhonePe', 'type': 'phonepe'},
        {'id': 'paytm', 'name': 'Paytm UPI', 'type': 'paytm'},
        {'id': 'bhim', 'name': 'BHIM UPI', 'type': 'bhim'},
        {'id': 'cred', 'name': 'CRED UPI', 'type': 'cred'},
        {'id': 'amazonpay', 'name': 'Amazon Pay', 'type': 'amazonpay'},
      ];

      final upiSuffixes = [
        '@okhdfcbank',
        '@okaxis',
        '@oksbi',
        '@okicici',
        '@paytm',
        '@ybl',
        '@ibl',
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented UPI Mode Toggle Bar
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: upiTabs.map((tab) {
                final bool isSelected = currentTab == tab['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectedUpiTab.value = tab['id'] as String;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(vertical: 6.5.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tab['icon'] as IconData,
                            size: 13.sp,
                            color: isSelected ? _primaryPurple : _textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            tab['label'] as String,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: isSelected
                                  ? FontFamily.interBold
                                  : FontFamily.interMedium,
                              color: isSelected ? _primaryPurple : _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 12.h),

          // TAB 1: UPI APPS
          if (currentTab == 'apps') ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 2.3,
              ),
              itemCount: apps.length,
              itemBuilder: (context, idx) {
                final app = apps[idx];
                final bool isAppSelected = selectedApp == app['id'];

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectedUpiApp.value = app['id'] as String;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color:
                          isAppSelected ? const Color(0xFFF5F3FF) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isAppSelected
                            ? _primaryPurple
                            : const Color(0xFFE2E8F0),
                        width: isAppSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isAppSelected
                              ? _primaryPurple.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildBrandLogoBadge(app['type'] as String),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            app['name'] as String,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontFamily: isAppSelected
                                  ? FontFamily.interBold
                                  : FontFamily.interMedium,
                              color: isAppSelected ? _primaryPurple : _textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAppSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15.sp,
                            color: _primaryPurple,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ]

          // TAB 2: ENTER UPI ID / VPA
          else if (currentTab == 'vpa') ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: customVpa.contains('@') && customVpa.length > 3
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email_rounded,
                        size: 18.sp,
                        color: _primaryPurple,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "Enter Virtual Payment Address (VPA)",
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontFamily: FontFamily.interBold,
                            color: _textDark,
                          ),
                        ),
                      ),
                      if (customVpa.contains('@') && customVpa.length > 3) ...[
                        Icon(
                          Icons.verified_rounded,
                          size: 15.sp,
                          color: const Color(0xFF16A34A),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "Valid VPA",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: FontFamily.interBold,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: controller.vpaTextController,
                    onChanged: (val) {
                      controller.customUpiVpa.value = val.trim();
                    },
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: "mobile_number@upi or name@okhdfcbank",
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: FontFamily.interRegular,
                        color: const Color(0xFF94A3B8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      suffixIcon: customVpa.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: _textSecondary,
                              onPressed: () {
                                controller.vpaTextController.clear();
                                controller.customUpiVpa.value = '';
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            const BorderSide(color: _primaryPurple, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "Quick Handles:",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interMedium,
                      color: _textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: upiSuffixes.map((suffix) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final currentText =
                              controller.vpaTextController.text.trim();
                          final username = currentText.contains('@')
                              ? currentText.split('@')[0]
                              : currentText;
                          final newVpa =
                              username.isEmpty ? "username$suffix" : "$username$suffix";
                          controller.vpaTextController.text = newVpa;
                          controller.vpaTextController.selection =
                              TextSelection.fromPosition(
                                  TextPosition(offset: newVpa.length));
                          controller.customUpiVpa.value = newVpa;
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            suffix,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: _primaryPurple,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ]

          // TAB 3: SCAN QR
          else ...[
            _buildLiveUpiQrCodeCard(),
          ],
        ],
      );
    });
  }

  Widget _buildLiveUpiQrCodeCard() {
    final num totalPayable = controller.totalPayable;
    final String upiString =
        "upi://pay?pa=fgtracker.razorpay@icici&pn=FGTracker&am=$totalPayable&cu=INR&tn=WalkieTalkiePlan";

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: _primaryPurple,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scan & Pay via UPI QR",
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontFamily: FontFamily.interBold,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Scan with GPay, PhonePe, Paytm or BHIM",
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _greenBg,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 10.sp,
                        color: _greenText,
                      ),
                      Text(
                        "INSTANT",
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontFamily: FontFamily.interBold,
                          color: _greenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Central QR Box with authentic styling
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: PrettyQrView.data(
                      data: upiString,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                      decoration: const PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "₹${controller.formatCurrency(totalPayable)}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "UPI ID: fgtracker.razorpay@icici",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: FontFamily.interMedium,
                          color: _textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(const ClipboardData(
                              text: "fgtracker.razorpay@icici"));
                          controller.showTopWhiteMessage(
                              "UPI ID copied to clipboard!");
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 12.sp,
                          color: _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildBrandLogoBadge(String type) {
    switch (type) {
      case 'gpay':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "G",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF4285F4), // Google Blue
                    height: 1.0,
                  ),
                ),
                Text(
                  "P",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFFEA4335), // Google Red
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'phonepe':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: const BoxDecoration(
            color: Color(0xFF5F259F), // PhonePe Purple
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "Pe",
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: FontFamily.interBold,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        );

      case 'paytm':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFF002E6E), // Paytm Navy
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              "tm",
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFF00BAF2), // Paytm Cyan
                height: 1.0,
              ),
            ),
          ),
        );

      case 'bhim':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "UPI",
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF0C992B), // UPI Green
                    letterSpacing: -0.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'amazonpay':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFF232F3E), // Amazon Navy
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 14.sp,
              color: const Color(0xFFFF9900), // Amazon Orange
            ),
          ),
        );

      case 'cred':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFF18181B), // CRED Dark
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              "C",
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: FontFamily.interBold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        );

      case 'mobikwik':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFF005DAA),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              "M",
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFFE5007D),
                height: 1.0,
              ),
            ),
          ),
        );

      case 'freecharge':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFF532E63),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              "fc",
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: FontFamily.interBold,
                color: const Color(0xFFF05A22),
                height: 1.0,
              ),
            ),
          ),
        );

      case 'airtel':
        return Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE40000),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Text(
              "a",
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: FontFamily.interBold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        );

      default:
        return Icon(Icons.payment_rounded, size: 20.sp, color: _primaryPurple);
    }
  }

  Widget _buildCardSubOptions() {
    return Obx(() {
      final String currentNetwork = controller.selectedCardNetwork.value;
      final String currentType = controller.selectedCardType.value;

      final cardTypes = [
        {'id': 'debit', 'label': 'Debit Card', 'icon': Icons.payment_rounded},
        {
          'id': 'credit',
          'label': 'Credit Card',
          'icon': Icons.credit_card_rounded
        },
        {
          'id': 'corporate',
          'label': 'Corporate Card',
          'icon': Icons.business_rounded
        },
      ];

      final cardNetworks = [
        {
          'id': 'visa',
          'name': 'VISA',
          'bgColor': const Color(0xFF1A1F71),
          'textColor': Colors.white,
          'accentColor': const Color(0xFFF7B600),
        },
        {
          'id': 'mastercard',
          'name': 'Mastercard',
          'isCustom': true,
        },
        {
          'id': 'rupay',
          'name': 'RuPay',
          'bgColor': const Color(0xFF0B2A6B),
          'textColor': Colors.white,
          'accentColor': const Color(0xFFF26522),
        },
        {
          'id': 'maestro',
          'name': 'Maestro',
          'bgColor': const Color(0xFF00A2E8),
          'textColor': Colors.white,
        },
        {
          'id': 'amex',
          'name': 'AMEX',
          'bgColor': const Color(0xFF006FCF),
          'textColor': Colors.white,
        },
        {
          'id': 'diners',
          'name': 'Diners',
          'bgColor': const Color(0xFF004A80),
          'textColor': Colors.white,
        },
      ];

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Type Selector (Debit / Credit / Corporate)
            Text(
              "Select Card Type",
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interBold,
                color: _textDark,
              ),
            ),
            SizedBox(height: 7.h),
            Row(
              children: cardTypes.map((type) {
                final bool isSelected = currentType == type['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectedCardType.value = type['id'] as String;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                          right: type['id'] == 'corporate' ? 0 : 6.w),
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryPurple : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? _primaryPurple
                              : const Color(0xFFCBD5E1),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _primaryPurple.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 13.sp,
                            color: isSelected ? Colors.white : _textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              type['label'] as String,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontFamily: isSelected
                                    ? FontFamily.interBold
                                    : FontFamily.interMedium,
                                color: isSelected ? Colors.white : _textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 12.h),

            // Card Network Selector (VISA, Mastercard, RuPay, Maestro, AMEX, Diners)
            Text(
              "Select Card Network",
              style: TextStyle(
                fontSize: 11.5.sp,
                fontFamily: FontFamily.interBold,
                color: _textDark,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: cardNetworks.map((net) {
                final bool isSelected = currentNetwork == net['id'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectedCardNetwork.value = net['id'] as String;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFF1F3FE) : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? _primaryPurple
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isSelected ? 0.05 : 0.02),
                          blurRadius: isSelected ? 6 : 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (net['isCustom'] == true)
                          _buildMastercardBadge()
                        else
                          _buildAuthenticCardBadge(
                            network: net['name'] as String,
                            bgColor: net['bgColor'] as Color,
                            textColor: net['textColor'] as Color,
                            accentColor: net['accentColor'] as Color?,
                          ),
                        SizedBox(width: 6.w),
                        Text(
                          net['name'] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: isSelected
                                ? FontFamily.interBold
                                : FontFamily.interMedium,
                            color: isSelected ? _primaryPurple : _textDark,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14.sp,
                            color: _primaryPurple,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 10.h),

            // Selection summary indicator
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 14.sp,
                    color: _primaryPurple,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      "Selected: ${currentNetwork.toUpperCase()} ${currentType.capitalizeFirst} Card (256-bit 3D Secure)",
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontFamily: FontFamily.interSemiBold,
                        color: _primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAuthenticCardBadge({
    required String network,
    required Color bgColor,
    required Color textColor,
    Color? accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            network,
            style: TextStyle(
              fontSize: 9.sp,
              fontFamily: FontFamily.interBold,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.3,
              fontStyle:
                  network == "VISA" ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (accentColor != null) ...[
            SizedBox(width: 2.w),
            Container(
              width: 2.5.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMastercardBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.w,
            height: 8.h,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: 7.5.w,
                    height: 7.5.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB001B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: 7.5.w,
                    height: 7.5.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
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

  Widget _buildNetBankingSubOptions() {
    return Obx(() {
      final selected = controller.selectedBank.value;
      final banks = [
        {'id': 'hdfc', 'name': 'HDFC Bank', 'color': const Color(0xFF004C8F)},
        {'id': 'sbi', 'name': 'SBI', 'color': const Color(0xFF0072BB)},
        {'id': 'icici', 'name': 'ICICI Bank', 'color': const Color(0xFFA21921)},
        {'id': 'axis', 'name': 'Axis Bank', 'color': const Color(0xFF97144D)},
        {
          'id': 'kotak',
          'name': 'Kotak Mahindra',
          'color': const Color(0xFFED1C24)
        },
        {'id': 'pnb', 'name': 'PNB', 'color': const Color(0xFFA20A2A)},
        {
          'id': 'bob',
          'name': 'Bank of Baroda',
          'color': const Color(0xFFF26522)
        },
        {
          'id': 'canara',
          'name': 'Canara Bank',
          'color': const Color(0xFF005DAA)
        },
        {
          'id': 'indusind',
          'name': 'IndusInd Bank',
          'color': const Color(0xFF861F41)
        },
        {'id': 'yes', 'name': 'YES Bank', 'color': const Color(0xFF004A80)},
        {'id': 'idfc', 'name': 'IDFC FIRST', 'color': const Color(0xFF990000)},
        {
          'id': 'other',
          'name': 'Other Banks',
          'color': const Color(0xFF475569)
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Indian Banks",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              Text(
                "Instant NetBanking",
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: banks.map((bank) {
              final bool isBankSelected = selected == bank['id'];
              final bankColor = bank['color'] as Color;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectedBank.value = bank['id'] as String;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:
                        isBankSelected ? const Color(0xFFF1F3FE) : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isBankSelected
                          ? _primaryPurple
                          : const Color(0xFFE2E8F0),
                      width: isBankSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isBankSelected ? 0.04 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: bankColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (bank['name'] as String).substring(0, 1),
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        bank['name'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: isBankSelected
                              ? FontFamily.interBold
                              : FontFamily.interMedium,
                          color: isBankSelected ? _primaryPurple : _textDark,
                        ),
                      ),
                      if (isBankSelected) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: _primaryPurple,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildWalletSubOptions() {
    return Obx(() {
      final selected = controller.selectedWallet.value;
      final wallets = [
        {
          'id': 'paytm',
          'name': 'Paytm Wallet',
          'type': 'paytm',
        },
        {
          'id': 'amazonpay',
          'name': 'Amazon Pay',
          'type': 'amazonpay',
        },
        {
          'id': 'phonepe',
          'name': 'PhonePe Wallet',
          'type': 'phonepe',
        },
        {
          'id': 'mobikwik',
          'name': 'MobiKwik',
          'type': 'mobikwik',
        },
        {
          'id': 'freecharge',
          'name': 'Freecharge',
          'type': 'freecharge',
        },
        {
          'id': 'airtel',
          'name': 'Airtel Money',
          'type': 'airtel',
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Digital Wallet",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              Text(
                "Instant 1-Click Pay",
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.3,
            ),
            itemCount: wallets.length,
            itemBuilder: (context, idx) {
              final wallet = wallets[idx];
              final bool isWalletSelected = selected == wallet['id'];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectedWallet.value = wallet['id'] as String;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isWalletSelected
                        ? const Color(0xFFF1F3FE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isWalletSelected
                          ? _primaryPurple
                          : const Color(0xFFE2E8F0),
                      width: isWalletSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isWalletSelected ? 0.04 : 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildBrandLogoBadge(wallet['type'] as String),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          wallet['name'] as String,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontFamily: isWalletSelected
                                ? FontFamily.interBold
                                : FontFamily.interMedium,
                            color:
                                isWalletSelected ? _primaryPurple : _textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isWalletSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15.sp,
                          color: _primaryPurple,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // ==========================================
  // CARD 4: PAYMENT DETAILS SUMMARY CARD
  // ==========================================
  Widget _buildPaymentDetailsCard() {
    return Obx(() {
      final num planAmount = controller.planAmount;
      final num discount = controller.discountAmount;
      final num amountAfterDiscount = controller.amountAfterDiscount;
      final num gstPercent = controller.gstPercent;
      final num gstAmount = controller.gstAmount;
      final num totalPayable = controller.totalPayable;
      final num totalSaving = controller.totalSaving;
      final bool hasDiscount = controller.hasDiscount;
      final bool hasGst = controller.hasGst;

      return Container(
        width: double.infinity,
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
            Text(
              "Payment Details",
              style: TextStyle(
                fontSize: 14.5.sp,
                fontFamily: FontFamily.interBold,
                color: _textDark,
              ),
            ),
            SizedBox(height: 14.h),

            // Row 1: Subtotal / Plan Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _textSecondary,
                  ),
                ),
                Text(
                  "₹${controller.formatCurrency(planAmount)}",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interMedium,
                    color: _textDark,
                  ),
                ),
              ],
            ),

            // Row 2: Discount (if any)
            if (hasDiscount) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.currentPromoCode != null &&
                            controller.currentPromoCode!.isNotEmpty
                        ? "Discount (${controller.currentPromoCode})"
                        : "Discount",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _greenText,
                    ),
                  ),
                  Text(
                    "- ₹${controller.formatCurrency(discount)}",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: FontFamily.interBold,
                      color: _greenText,
                    ),
                  ),
                ],
              ),
            ],

            // Row 3: Amount After Discount (if GST applies and there was discount)
            if (hasDiscount && hasGst) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount After Discount",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    "₹${controller.formatCurrency(amountAfterDiscount)}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontFamily.interMedium,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ],

            // Row 4: GST (if any)
            if (hasGst) ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GST ($gstPercent%)",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: _textSecondary,
                    ),
                  ),
                  Text(
                    "+ ₹${controller.formatCurrency(gstAmount)}",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontFamily: FontFamily.interMedium,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ],

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Row 5: Total Payable
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Payable",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                  ),
                ),
                Text(
                  "₹${controller.formatCurrency(totalPayable)}",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),

            // Optional Total Savings banner
            if (totalSaving > 0) ...[
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: _greenBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 15.sp,
                      color: _greenText,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        "You saved ₹${controller.formatCurrency(totalSaving)} on this order!",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: FontFamily.interBold,
                          color: _greenText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _getDynamicPayButtonLabel(num totalPayable) {
    final method = controller.selectedPaymentMethod.value;
    final formattedAmt = "₹${controller.formatCurrency(totalPayable)}";
    if (method == 'upi') {
      final tab = controller.selectedUpiTab.value;
      if (tab == 'vpa') {
        final vpa = controller.customUpiVpa.value.trim();
        if (vpa.isNotEmpty) {
          return "Pay via $vpa • $formattedAmt";
        }
        return "Verify & Pay via UPI • $formattedAmt";
      } else if (tab == 'qr') {
        return "Pay via QR Code • $formattedAmt";
      }
      final app = controller.selectedUpiApp.value;
      if (app == 'gpay') return "Pay via Google Pay • $formattedAmt";
      if (app == 'phonepe') return "Pay via PhonePe • $formattedAmt";
      if (app == 'paytm') return "Pay via Paytm UPI • $formattedAmt";
      if (app == 'bhim') return "Pay via BHIM UPI • $formattedAmt";
      if (app == 'cred') return "Pay via CRED UPI • $formattedAmt";
      if (app == 'amazonpay') return "Pay via Amazon Pay UPI • $formattedAmt";
      return "Pay via UPI • $formattedAmt";
    } else if (method == 'card') {
      final network = controller.selectedCardNetwork.value.toUpperCase();
      final type =
          controller.selectedCardType.value == 'credit' ? 'Credit' : 'Debit';
      return "Pay via $network $type • $formattedAmt";
    } else if (method == 'netbanking') {
      final bankId = controller.selectedBank.value;
      final String bankName;
      switch (bankId) {
        case 'hdfc':
          bankName = 'HDFC';
          break;
        case 'sbi':
          bankName = 'SBI';
          break;
        case 'icici':
          bankName = 'ICICI';
          break;
        case 'axis':
          bankName = 'Axis';
          break;
        case 'kotak':
          bankName = 'Kotak';
          break;
        case 'pnb':
          bankName = 'PNB';
          break;
        case 'bob':
          bankName = 'Bank of Baroda';
          break;
        case 'canara':
          bankName = 'Canara Bank';
          break;
        case 'indusind':
          bankName = 'IndusInd';
          break;
        case 'yes':
          bankName = 'YES Bank';
          break;
        case 'idfc':
          bankName = 'IDFC FIRST';
          break;
        default:
          bankName = 'NetBanking';
          break;
      }
      return "Pay via $bankName • $formattedAmt";
    } else if (method == 'wallet') {
      final walletId = controller.selectedWallet.value;
      final String walletName;
      switch (walletId) {
        case 'paytm':
          walletName = 'Paytm';
          break;
        case 'amazonpay':
          walletName = 'Amazon Pay';
          break;
        case 'phonepe':
          walletName = 'PhonePe';
          break;
        case 'mobikwik':
          walletName = 'MobiKwik';
          break;
        case 'freecharge':
          walletName = 'Freecharge';
          break;
        case 'airtel':
          walletName = 'Airtel';
          break;
        default:
          walletName = 'Wallet';
          break;
      }
      return "Pay via $walletName Wallet • $formattedAmt";
    }
    return "Pay $formattedAmt";
  }

  // ==========================================
  // BOTTOM FIXED ACTION BAR
  // ==========================================
  Widget _buildBottomPaymentBar() {
    return Obx(() {
      final num totalPayable = controller.totalPayable;
      final bool isProcessing = controller.isProcessingPayment.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
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
            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 48.h.clamp(46.0, 52.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed:
                    isProcessing ? null : () => controller.processPayment(),
                child: isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          Text(
                            "Processing Payment...",
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontFamily: FontFamily.interBold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 17.sp,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getDynamicPayButtonLabel(totalPayable),
                                style: TextStyle(
                                  fontSize: 15.sp.clamp(13.5, 16.5),
                                  fontFamily: FontFamily.interBold,
                                  color: Colors.white,
                                ),
                              ),
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

            // Terms Subtext
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "By proceeding, you agree to our ",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: _textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: _showTermsDialog,
                  child: Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interMedium,
                      color: _primaryPurple,
                      decoration: TextDecoration.underline,
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

  // ==========================================
  // PROMO CODE BOTTOM SHEET
  // ==========================================
  void _showPromoCodeBottomSheet(BuildContext context) {
    controller.fetchCoupons();
    final TextEditingController promoController =
        TextEditingController(text: controller.currentPromoCode ?? "");

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
                            final String? appliedCode =
                                controller.currentPromoCode?.toUpperCase();
                            final bool isThisCodeApplied =
                                controller.isCouponApplied &&
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
                                          controller.removeCoupon();
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
                            if (controller.isLoadingCoupons.value) {
                              return SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
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

                      // Coupons List
                      Obx(() {
                        final coupons = controller.eligibleCoupons;
                        final bool isLoading =
                            controller.isLoadingCoupons.value;

                        if (isLoading && coupons.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _primaryPurple,
                                strokeWidth: 2.5.w,
                              ),
                            ),
                          );
                        }

                        if (coupons.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 24.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14.r),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 32.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "No coupons available at the moment",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontFamily: FontFamily.interMedium,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: List.generate(coupons.length, (index) {
                            final coupon = coupons[index];
                            final String couponCode =
                                (coupon.code ?? '').toUpperCase();
                            final String? appliedCode =
                                controller.currentPromoCode?.toUpperCase();
                            final bool isThisApplied =
                                controller.isCouponApplied &&
                                    appliedCode != null &&
                                    appliedCode == couponCode;

                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: isThisApplied
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isThisApplied
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFE2E8F0),
                                  width: isThisApplied ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: isThisApplied
                                          ? _greenBg
                                          : const Color(0xFFEEF0FE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.discount_rounded,
                                      size: 18.sp,
                                      color: isThisApplied
                                          ? _greenText
                                          : _primaryPurple,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              couponCode,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontFamily:
                                                    FontFamily.interBold,
                                                color: _textDark,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            if (coupon.discountDescription
                                                .isNotEmpty) ...[
                                              SizedBox(width: 8.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: _greenBg,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.r),
                                                ),
                                                child: Text(
                                                  coupon.discountDescription,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontFamily:
                                                        FontFamily.interBold,
                                                    color: _greenText,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (coupon
                                            .formattedExpiry.isNotEmpty) ...[
                                          SizedBox(height: 3.h),
                                          Text(
                                            coupon.formattedExpiry,
                                            style: TextStyle(
                                              fontSize: 11.5.sp,
                                              fontFamily:
                                                  FontFamily.interRegular,
                                              color: _textSecondary,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () async {
                                      if (isThisApplied) {
                                        HapticFeedback.lightImpact();
                                        controller.removeCoupon();
                                        promoController.clear();
                                        setSheetState(() {});
                                      } else {
                                        final success = await controller
                                            .applyCoupon(coupon);
                                        if (success && ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: isThisApplied
                                            ? _greenBg
                                            : const Color(0xFFF1F3FE),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        isThisApplied ? "Remove" : "Apply",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: FontFamily.interBold,
                                          color: isThisApplied
                                              ? const Color(0xFFDC2626)
                                              : _primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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

  // ==========================================
  // TERMS & CONDITIONS DIALOG
  // ==========================================
  void _showTermsDialog() {
    Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: FontFamily.interBold,
                      color: _textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child:
                        const Icon(Icons.close_rounded, color: _textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                "• Walkie Talkie plan subscriptions are activated immediately upon payment.\n"
                "• Subscriptions renew automatically based on chosen billing cycle unless cancelled.\n"
                "• All payments are processed securely through 256-bit encryption.\n"
                "• Plans and member allocations can be managed at any time from your settings.",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                height: 42.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "I Understand",
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
        ),
      ),
    );
  }
}


// Backwards compatibility alias
typedef WalkieTalkiePaymentScreen = WalkieOrderSummaryScreen;
