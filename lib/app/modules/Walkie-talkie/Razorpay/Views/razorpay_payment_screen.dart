import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Model/razorpay_payment_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  final WalkiePaymentOrderModel order;
  final num totalAmount;
  final String? promoCode;

  const RazorpayPaymentScreen({
    super.key,
    required this.order,
    required this.totalAmount,
    this.promoCode,
  });

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late final RazorpayPaymentController controller;

  static const Color _primaryPurple = Color(0xFF5B4DF5);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFEDF2F7);

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<RazorpayPaymentController>()) {
      controller = Get.find<RazorpayPaymentController>();
      controller.resetState();
    } else {
      controller = Get.put(RazorpayPaymentController());
    }

    // Automatically trigger Razorpay checkout after frame rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiateRazorpayPayment();
    });
  }

  void _initiateRazorpayPayment() {
    final String? userPhone =
        Global.storageServices.get(PrefConst.userPhone)?.toString();
    final String? userEmail =
        Global.storageServices.get(PrefConst.userEmail)?.toString();
    final String? userName =
        Global.storageServices.get(PrefConst.userName)?.toString();

    final options = RazorpayPaymentOptions(
      amount: widget.totalAmount,
      name: "FG Tracker",
      description: "${widget.order.planTitle} (${widget.order.durationName})",
      prefillContact: userPhone,
      prefillEmail: userEmail,
      prefillName: userName,
      themeColor: "#5B4DF5",
      notes: {
        'planTitle': widget.order.planTitle,
        'duration': widget.order.durationName,
        'memberCount': widget.order.memberCount.toString(),
        if (widget.promoCode != null) 'couponCode': widget.promoCode!,
      },
    );

    controller.openCheckout(
      options: options,
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentFailure,
    );
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    HapticFeedback.heavyImpact();

    // Navigate to Purchase Success Screen
    Get.off(() => WalkieTalkiePurchaseSuccessScreen(
          isTeam: widget.order.isTeam || widget.order.memberCount > 1,
          planTitle: widget.order.planTitle,
          memberCount: widget.order.memberCount,
          validTill: widget.order.validTill,
          paymentId: response.paymentId ??
              "pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}",
          orderId: response.orderId,
          amountPaid: widget.totalAmount,
          paymentMethod: "Razorpay Checkout",
        ));
  }

  void _onPaymentFailure(PaymentFailureResponse response) {
    HapticFeedback.mediumImpact();
  }

  String _formatCurrency(num amount) {
    final isDecimal = amount is double && amount != amount.roundToDouble();
    if (isDecimal) {
      final parts = amount.toStringAsFixed(2).split('.');
      final int intPart = int.tryParse(parts[0]) ?? 0;
      return '${_formatInt(intPart)}.${parts[1]}';
    }
    return _formatInt(amount.round());
  }

  String _formatInt(int intAmount) {
    final str = intAmount.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),

                        // Order Summary Card
                        _buildOrderDetailsCard(),

                        SizedBox(height: 14.h),

                        // Razorpay Status / Action Card
                        _buildPaymentStatusCard(),

                        SizedBox(height: 14.h),

                        // Payment Methods Supported Card
                        _buildSupportedMethodsCard(),

                        SizedBox(height: 14.h),

                        // 100% Secure Transaction Banner
                        _buildSecurityGuaranteeBanner(),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Action Bar
                _buildBottomActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWideScreen) {
    final Widget titleRow = Row(
      children: [
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Complete Payment",
                style: TextStyle(
                  fontSize: 17.sp.clamp(15.0, 19.0),
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Secure Checkout powered by Razorpay",
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
                Icons.verified_user_rounded,
                size: 16.sp,
                color: _primaryPurple,
              ),
              SizedBox(width: 4.w),
              Text(
                "Razorpay",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: FontFamily.interBold,
                  color: _primaryPurple,
                ),
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

  Widget _buildOrderDetailsCard() {
    final bool isTeam = widget.order.isTeam || widget.order.memberCount > 1;

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
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isTeam ? Icons.groups_rounded : Icons.person_rounded,
                  size: 22.sp,
                  color: _primaryPurple,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.planTitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: FontFamily.interBold,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${widget.order.durationName} • ${isTeam ? '${widget.order.memberCount} Members' : '1 Member'}",
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
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Payable Amount",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontFamily: FontFamily.interMedium,
                  color: _textDark,
                ),
              ),
              Text(
                "₹${_formatCurrency(widget.totalAmount)}",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontFamily: FontFamily.interBold,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    return Obx(() {
      final status = controller.status.value;
      final bool isProcessing = controller.isProcessing.value;
      final String error = controller.errorMessage.value;

      if (isProcessing || status == PaymentProcessStatus.processing) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 38.w,
                height: 38.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                "Connecting to Razorpay...",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontFamily: FontFamily.interBold,
                  color: _textDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Please complete the transaction in the Razorpay payment window.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      if (status == PaymentProcessStatus.failed ||
          status == PaymentProcessStatus.cancelled) {
        final bool isCancelled = status == PaymentProcessStatus.cancelled;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            children: [
              Icon(
                isCancelled ? Icons.info_outline_rounded : Icons.error_outline_rounded,
                size: 32.sp,
                color: const Color(0xFFDC2626),
              ),
              SizedBox(height: 8.h),
              Text(
                isCancelled ? "Payment Cancelled" : "Payment Failed",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontFamily: FontFamily.interBold,
                  color: const Color(0xFF991B1B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                error.isNotEmpty
                    ? error
                    : "The payment could not be processed. Please try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontFamily: FontFamily.interRegular,
                  color: const Color(0xFFB91C1C),
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                onPressed: _initiateRazorpayPayment,
                icon: Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
                label: Text(
                  "Retry Payment",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  Widget _buildSupportedMethodsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Supported Payment Modes",
            style: TextStyle(
              fontSize: 13.5.sp,
              fontFamily: FontFamily.interBold,
              color: _textDark,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildPaymentMethodPill(
                icon: Icons.qr_code_rounded,
                label: "UPI / QR",
              ),
              SizedBox(width: 8.w),
              _buildPaymentMethodPill(
                icon: Icons.credit_card_rounded,
                label: "Cards",
              ),
              SizedBox(width: 8.w),
              _buildPaymentMethodPill(
                icon: Icons.account_balance_rounded,
                label: "NetBanking",
              ),
              SizedBox(width: 8.w),
              _buildPaymentMethodPill(
                icon: Icons.account_balance_wallet_rounded,
                label: "Wallets",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodPill({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18.sp, color: _primaryPurple),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontFamily: FontFamily.interMedium,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityGuaranteeBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              size: 18.sp,
              color: const Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "100% Safe & PCI-DSS Compliant",
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontFamily: FontFamily.interBold,
                    color: const Color(0xFF15803D),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  "Transactions are encrypted with end-to-end 256-bit SSL security.",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Obx(() {
      final bool isProcessing = controller.isProcessing.value;

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
        child: SizedBox(
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
            onPressed: isProcessing ? null : _initiateRazorpayPayment,
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
                        "Processing with Razorpay...",
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
                        "Pay ₹${_formatCurrency(widget.totalAmount)} via Razorpay",
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
      );
    });
  }
}
