import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_order_summary_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  static const Color _primaryPurple = AppColors.primaryDarkblue;
  static const Color _bgSoft = AppColors.primarySecondaryBackground;
  static const Color _textDark = AppColors.authTextNavy;
  static const Color _textSecondary = AppColors.primarySecondaryElementText;
  static const Color _cardBorder = AppColors.textbordercolor;
  static const Color _lightPillBg = AppColors.authIconBgCircle;
  static const Color _greenText = AppColors.primaryElementStatus;
  static const Color _greenBg = AppColors.greenLight;

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

                            // Card 2: Razorpay Payment Initiation Card
                            _buildRazorpayInitiateCard(),

                            // Card 3: Payment Details Summary Card
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
                        "₹${controller.formatCurrency(rate * seats)}",
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontFamily: FontFamily.interMedium,
                          color: const Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    Text(
                      "₹${controller.formatCurrency(planAmount)}",
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
  // CARD 3: PAYMENT METHODS & RAZORPAY INITIATION CARD
  // ==========================================
  Widget _buildRazorpayInitiateCard() {
    return Obx(() {
      final bool isProcessing = controller.isProcessingPayment.value;

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
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FE),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
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
                        "Online Payment via Razorpay",
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

            // Supported Payment Options Pills Row
            Row(
              children: [
                _buildSupportedMethodBadge(
                  icon: Icons.bolt_rounded,
                  label: "UPI / QR",
                ),
                SizedBox(width: 6.w),
                _buildSupportedMethodBadge(
                  icon: Icons.credit_card_rounded,
                  label: "Cards",
                ),
                SizedBox(width: 6.w),
                _buildSupportedMethodBadge(
                  icon: Icons.account_balance_rounded,
                  label: "NetBanking",
                ),
                SizedBox(width: 6.w),
                _buildSupportedMethodBadge(
                  icon: Icons.account_balance_wallet_rounded,
                  label: "Wallets",
                ),
              ],
            ),

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
                        "Choose from GPay, PhonePe, Cards, NetBanking or Wallets on next step.",
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

  Widget _buildSupportedMethodBadge({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17.sp,
              color: _primaryPurple,
            ),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _textDark,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }



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
    final formattedAmt = "₹${controller.formatCurrency(totalPayable)}";
    return "Proceed to Pay • $formattedAmt";
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
