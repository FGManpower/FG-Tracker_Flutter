import 'package:fgtracker/app/Model/walkie_coupon_model.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_payment_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalkieTalkiePaymentScreen extends StatefulWidget {
  final WalkiePaymentOrderModel? order;

  const WalkieTalkiePaymentScreen({
    super.key,
    this.order,
  });

  @override
  State<WalkieTalkiePaymentScreen> createState() =>
      _WalkieTalkiePaymentScreenState();
}

class _WalkieTalkiePaymentScreenState extends State<WalkieTalkiePaymentScreen> {
  late final WalkieTalkiePaymentController controller;

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
    if (Get.isRegistered<WalkieTalkiePaymentController>()) {
      controller = Get.find<WalkieTalkiePaymentController>();
      if (widget.order != null) {
        controller.order.value = widget.order!;
      }
    } else {
      controller = Get.put(WalkieTalkiePaymentController(widget.order));
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),

                        // Card 1: Selected Plan Details Card
                        _buildPlanOverviewCard(),

                        SizedBox(height: 14.h),

                        // Card 2: Promo / Coupon Code Section
                        _buildPromoCodeCard(),

                        SizedBox(height: 14.h),

                        // Card 3: Payment Details Summary Card
                        _buildPaymentDetailsCard(),

                        SizedBox(height: 24.h),
                      ],
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
                "Make Payment",
                style: TextStyle(
                  fontSize: 17.sp.clamp(15.0, 19.0),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Complete your payment to activate the plan",
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
  // CARD 1: PLAN OVERVIEW CARD
  // ==========================================
  Widget _buildPlanOverviewCard() {
    return Obx(() {
      final order = controller.order.value;
      final num planAmount = controller.planAmount;
      final num totalPayable = controller.totalPayable;
      final bool isDiscounted = controller.hasDiscount;

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
                    order.isTeam ? Icons.groups_rounded : Icons.person_rounded,
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
                        order.planTitle,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontFamily: FontFamily.interBold,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        order.isTeam
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
                            order.isTeam
                                ? Icons.group_outlined
                                : Icons.person_outline_rounded,
                            size: 15.sp,
                            color: _primaryPurple,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              order.isTeam
                                  ? "${order.memberCount} Members"
                                  : "1 Member",
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
                              order.durationName,
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
                              "₹${controller.formatCurrency(order.ratePerMember)}",
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
                      order.isTeam
                          ? "${order.memberCount} Members × ₹${controller.formatCurrency(order.ratePerMember)}"
                          : "1 Member × ₹${controller.formatCurrency(order.ratePerMember)}",
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
  // CARD 2: PROMO / COUPON CODE SECTION
  // ==========================================
  Widget _buildPromoCodeCard() {
    return Obx(() {
      final String? code = controller.currentPromoCode;
      final bool isApplied = code != null && code.isNotEmpty;
      final num discount = controller.discountAmount;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isApplied ? const Color(0xFF86EFAC) : _cardBorder,
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
              decoration: BoxDecoration(
                color: isApplied ? _greenBg : _lightPillBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApplied
                    ? Icons.check_circle_outline_rounded
                    : Icons.local_offer_outlined,
                size: 19.sp,
                color: isApplied ? _greenText : _primaryPurple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isApplied ? "Coupon Applied ($code)" : "Have a Promo Code?",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interBold,
                      color: isApplied ? _greenText : _textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isApplied
                        ? "You saved ₹${controller.formatCurrency(discount)} with this coupon"
                        : "Apply code to get additional discount",
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isApplied ? _greenBg : const Color(0xFFF1F3FE),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isApplied ? "Applied" : "Apply",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interBold,
                  color: isApplied ? _greenText : _primaryPurple,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==========================================
  // CARD 3: PAYMENT DETAILS SUMMARY CARD
  // ==========================================
  Widget _buildPaymentDetailsCard() {
    return Obx(() {
      final num planAmount = controller.planAmount;
      final num discount = controller.discountAmount;
      final num totalPayable = controller.totalPayable;
      final bool hasDiscount = controller.hasDiscount;

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

            // Row 1: Plan Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Plan Amount",
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
                    controller.currentPromoCode != null
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

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),

            // Row 3: Total Payable
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
          ],
        ),
      );
    });
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
                          Text(
                            "Pay ₹${controller.formatCurrency(totalPayable)}",
                            style: TextStyle(
                              fontSize: 15.sp.clamp(14.0, 16.5),
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
  // COUPON BOTTOM SHEET
  // ==========================================
  void _showCouponBottomSheet() {
    final TextEditingController promoTextController =
        TextEditingController(text: controller.currentPromoCode ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                ),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Sheet Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Apply Coupon",
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
                                color: Color(0xFFF1F5F9),
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

                      // Input Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 46.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border:
                                    Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_outlined,
                                    size: 18.sp,
                                    color: _primaryPurple,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: TextField(
                                      controller: promoTextController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontFamily: FontFamily.interBold,
                                        color: _textDark,
                                        letterSpacing: 0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter Coupon Code",
                                        hintStyle: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontFamily: FontFamily.interRegular,
                                          color: const Color(0xFF94A3B8),
                                          letterSpacing: 0,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) => setSheetState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Obx(() {
                            final bool isApplying =
                                controller.isApplyingCoupon.value;
                            return SizedBox(
                              height: 46.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryPurple,
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
                                        final code = promoTextController.text
                                            .trim()
                                            .toUpperCase();
                                        if (code.isEmpty) {
                                          controller.showTopWhiteMessage(
                                              "Please enter a coupon code");
                                          return;
                                        }
                                        final success = await controller
                                            .applyPromoCode(code);
                                        if (success && ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      },
                                child: isApplying
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Apply",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: FontFamily.interBold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),

                      SizedBox(height: 18.h),
                      Text(
                        "Available Coupons",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: FontFamily.interBold,
                          color: _textDark,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Coupons List
                      Obx(() {
                        if (controller.isLoadingCoupons.value) {
                          return _buildCouponsSkeleton();
                        }
                        final coupons = controller.eligibleCoupons;
                        if (coupons.isEmpty) {
                          return _buildStaticCouponsList(ctx);
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: coupons.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final coupon = coupons[index];
                            final bool isApplied =
                                controller.currentPromoCode == coupon.code;

                            return _buildCouponTile(
                              code: coupon.code ?? '',
                              description: coupon.discountDescription,
                              isApplied: isApplied,
                              onApply: () async {
                                final success =
                                    await controller.applyCoupon(coupon);
                                if (success && ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                              },
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

  Widget _buildStaticCouponsList(BuildContext ctx) {
    final staticCoupons = [
      {
        "code": "WELCOME20",
        "description": "Get flat 20% off on your Walkie Talkie subscription",
      },
      {
        "code": "SPECIAL10",
        "description": "Get 10% instant discount on all plans",
      },
      {
        "code": "FLAT150",
        "description": "Save flat ₹150 on team subscriptions",
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: staticCoupons.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = staticCoupons[index];
        final String code = item["code"]!;
        final String desc = item["description"]!;
        final bool isApplied = controller.currentPromoCode == code;

        return _buildCouponTile(
          code: code,
          description: desc,
          isApplied: isApplied,
          onApply: () async {
            final success = await controller.applyPromoCode(code);
            if (success && ctx.mounted) {
              Navigator.pop(ctx);
            }
          },
        );
      },
    );
  }

  Widget _buildCouponTile({
    required String code,
    required String description,
    required bool isApplied,
    required VoidCallback onApply,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isApplied ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isApplied ? _greenBg : _lightPillBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_rounded,
              size: 17.sp,
              color: isApplied ? _greenText : _primaryPurple,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
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
            onTap: onApply,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isApplied ? _greenText : _primaryPurple,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isApplied ? "APPLIED" : "APPLY",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: FontFamily.interBold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsSkeleton() {
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
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E7FF),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("COUPONCODE", style: TextStyle(fontSize: 13.sp)),
                      Text("Coupon description",
                          style: TextStyle(fontSize: 11.sp)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
