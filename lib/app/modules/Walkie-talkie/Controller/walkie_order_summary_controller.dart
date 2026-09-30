import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';
import 'package:fgtracker/app/Model/walkie_create_order_model.dart';
import 'package:fgtracker/app/Model/walkie_order_summary_model.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalkieOrderSummaryController extends GetxController {
  late final Razorpay _razorpay;
  late final Rx<WalkiePaymentOrderModel> order;

  final RxBool isProcessingPayment = false.obs;
  final RxBool isLoadingCoupons = false.obs;
  final RxBool isLoadingSummary = false.obs;
  final RxBool isApplyingCoupon = false.obs;
  final RxnString applyingCouponCode = RxnString();
  final RxString errorMessage = ''.obs;

  final RxList<WalkieCouponItem> eligibleCoupons = <WalkieCouponItem>[].obs;
  final Rxn<WalkieCouponItem> selectedCoupon = Rxn<WalkieCouponItem>();
  final Rxn<WalkieAppliedCouponData> appliedCouponData =
      Rxn<WalkieAppliedCouponData>();
  final Rxn<WalkieOrderSummaryData> summaryData = Rxn<WalkieOrderSummaryData>();
  final Rxn<WalkieCreateOrderData> createOrderData =
      Rxn<WalkieCreateOrderData>();

  final RxDouble dynamicDiscount = 0.0.obs;
  final RxnString dynamicCouponCode = RxnString();
  final RxBool userExplicitlyAppliedCoupon = false.obs;

  // Selected Payment Method & Sub-options
  final RxString selectedPaymentMethod = 'upi'.obs; // 'upi', 'card', 'netbanking', 'wallet'
  final RxString selectedUpiApp = 'gpay'.obs; // 'gpay', 'phonepe', 'paytm', 'bhim', 'cred', 'amazonpay'
  final RxString selectedUpiTab = 'apps'.obs; // 'apps', 'vpa', 'qr'
  final RxString customUpiVpa = ''.obs;
  final TextEditingController vpaTextController = TextEditingController();
  final RxString selectedCardNetwork = 'visa'.obs; // 'visa', 'mastercard', 'rupay', 'maestro', 'amex'
  final RxString selectedCardType = 'debit'.obs; // 'debit', 'credit', 'corporate'
  final RxString selectedBank = 'hdfc'.obs; // 'hdfc', 'sbi', 'icici', 'axis', 'kotak', etc.
  final RxString selectedWallet = 'paytm'.obs; // 'paytm', 'amazonpay', 'phonepe', 'mobikwik', etc.

  WalkieOrderSummaryController([WalkiePaymentOrderModel? initialOrder]) {
    final passedOrder = initialOrder ??
        (Get.arguments is WalkiePaymentOrderModel
            ? Get.arguments as WalkiePaymentOrderModel
            : WalkiePaymentOrderModel());
    order = Rx<WalkiePaymentOrderModel>(passedOrder);
  }

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    final bool hasInitialCoupon = (order.value.appliedCouponCode != null &&
        order.value.appliedCouponCode!.trim().isNotEmpty &&
        order.value.couponDiscount > 0);

    userExplicitlyAppliedCoupon.value = hasInitialCoupon;

    if (hasInitialCoupon) {
      dynamicCouponCode.value = order.value.appliedCouponCode!.trim();
      dynamicDiscount.value = order.value.couponDiscount.toDouble();
    } else {
      dynamicCouponCode.value = null;
      dynamicDiscount.value = 0.0;
    }
    fetchOrderSummary();
    fetchCoupons();
  }

  String get planName => summaryData.value?.plan?.name ?? order.value.planTitle;

  String get durationName {
    final interval = summaryData.value?.plan?.billingInterval;
    if (interval != null && interval.isNotEmpty) {
      return interval.capitalizeFirst ?? interval;
    }
    return order.value.durationName;
  }

  int get purchasedSeats =>
      summaryData.value?.purchasedSeats ??
      (order.value.isTeam ? order.value.memberCount : 1);

  num get pricePerMember =>
      summaryData.value?.pricing?.pricePerMember ??
      summaryData.value?.plan?.pricePerMember ??
      order.value.ratePerMember;

  num get planAmount =>
      summaryData.value?.pricing?.subtotal ?? order.value.planAmount;

  num get discountAmount {
    if (!userExplicitlyAppliedCoupon.value) return 0;
    if (summaryData.value != null) {
      if (summaryData.value?.couponApplied == true) {
        return summaryData.value?.pricing?.discountAmount ?? 0;
      }
      return 0;
    }
    if (appliedCouponData.value != null) {
      return appliedCouponData.value?.pricing?.discountAmount ?? 0;
    }
    if (dynamicCouponCode.value != null &&
        dynamicCouponCode.value!.isNotEmpty &&
        dynamicDiscount.value > 0) {
      return dynamicDiscount.value;
    }
    if (order.value.appliedCouponCode != null &&
        order.value.appliedCouponCode!.isNotEmpty &&
        order.value.couponDiscount > 0) {
      return order.value.couponDiscount;
    }
    return 0;
  }

  num get amountAfterDiscount =>
      summaryData.value?.pricing?.amountAfterDiscount ??
      (planAmount - (isCouponApplied ? discountAmount : 0) > 0
          ? planAmount - (isCouponApplied ? discountAmount : 0)
          : 0);

  num get gstPercent => summaryData.value?.pricing?.gstPercent ?? 0;

  num get gstAmount => summaryData.value?.pricing?.gstAmount ?? 0;

  num get totalSaving =>
      summaryData.value?.pricing?.totalSaving ?? (isCouponApplied ? discountAmount : 0);

  num get totalPayable {
    if (summaryData.value?.pricing?.finalAmount != null) {
      return summaryData.value!.pricing!.finalAmount!;
    }
    if (appliedCouponData.value?.pricing?.finalAmount != null) {
      return appliedCouponData.value!.pricing!.finalAmount!;
    }
    final num total = planAmount - (isCouponApplied ? discountAmount : 0);
    return total < 0 ? 0 : total;
  }

  bool get isCouponApplied {
    if (!userExplicitlyAppliedCoupon.value) return false;
    if (summaryData.value != null) {
      return summaryData.value?.couponApplied == true &&
          (summaryData.value?.pricing?.discountAmount ?? 0) > 0;
    }
    if (appliedCouponData.value != null) {
      return (appliedCouponData.value?.pricing?.discountAmount ?? 0) > 0;
    }
    final code = dynamicCouponCode.value ?? order.value.appliedCouponCode;
    return (code != null && code.isNotEmpty) &&
        (dynamicDiscount.value > 0 || order.value.couponDiscount > 0);
  }

  bool get hasDiscount => isCouponApplied && discountAmount > 0;

  bool get hasGst => gstAmount > 0;

  String? get currentPromoCode {
    if (!isCouponApplied) return null;
    return summaryData.value?.coupon?.code ??
        appliedCouponData.value?.coupon?.code ??
        dynamicCouponCode.value ??
        order.value.appliedCouponCode;
  }

  String formatCurrency(num amount) {
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

  String _parseErrorMessage(dynamic error) {
    if (error == null) return "Something went wrong. Please try again.";

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.error is SocketException) {
        return "No internet connection. Please check your network.";
      }
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map) {
          if (data['message'] != null &&
              data['message'].toString().trim().isNotEmpty) {
            return data['message'].toString().trim();
          }
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map) {
              final msgs = errors.values
                  .map((v) => v is List ? v.join("\n") : v.toString())
                  .join("\n");
              if (msgs.trim().isNotEmpty) return msgs.trim();
            } else if (errors is List) {
              return errors.join("\n");
            }
            return errors.toString();
          }
          if (data['error'] != null &&
              data['error'].toString().trim().isNotEmpty) {
            return data['error'].toString().trim();
          }
        } else if (data is String && data.trim().isNotEmpty) {
          return data.trim();
        }
      }
      return error.message?.isNotEmpty == true
          ? error.message!
          : "Unable to connect to server. Please try again.";
    }

    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    }

    final str = error.toString().trim();
    if (str.isEmpty) return "Something went wrong. Please try again.";

    final lower = str.toLowerCase();
    if (lower.contains("socket") ||
        lower.contains("internet") ||
        lower.contains("connection") ||
        lower.contains("network") ||
        lower.contains("failed host lookup") ||
        lower.contains("connection refused")) {
      return "No internet connection. Please check your network.";
    }

    if (str.startsWith("Exception: ")) {
      return str.substring(11).trim();
    }

    return str;
  }

  Future<void> fetchOrderSummary({String? couponCodeOverride}) async {
    try {
      isLoadingSummary.value = true;
      final int planId = order.value.plan?.id ?? (order.value.isTeam ? 4 : 1);
      final int seats = order.value.isTeam ? order.value.memberCount : 1;
      final String? couponCode = couponCodeOverride != null
          ? (couponCodeOverride.trim().isEmpty ? null : couponCodeOverride.trim())
          : (userExplicitlyAppliedCoupon.value ? currentPromoCode : null);

      final response = await WalkiePlanRepo.getOrderSummary(
        planId: planId,
        purchasedSeats: seats,
        couponCode: couponCode,
      );

      if (response.status == true && response.data != null) {
        summaryData.value = response.data;
        errorMessage.value = '';
        if (userExplicitlyAppliedCoupon.value &&
            response.data?.couponApplied == true &&
            response.data?.coupon?.code != null &&
            (response.data?.pricing?.discountAmount ?? 0) > 0) {
          dynamicCouponCode.value = response.data!.coupon!.code;
          dynamicDiscount.value =
              response.data!.pricing!.discountAmount!.toDouble();
        } else if (!userExplicitlyAppliedCoupon.value) {
          dynamicCouponCode.value = null;
          dynamicDiscount.value = 0.0;
        }
      } else {
        if (summaryData.value == null) {
          errorMessage.value = response.message ?? "Unable to load order summary.";
        }
      }
    } catch (e) {
      debugPrint("Error fetching order summary: $e");
      if (summaryData.value == null) {
        errorMessage.value = _parseErrorMessage(e);
      }
    } finally {
      isLoadingSummary.value = false;
    }
  }

  Future<void> fetchCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final int planId = order.value.plan?.id ?? (order.value.isTeam ? 4 : 1);
      final int seats = order.value.isTeam ? order.value.memberCount : 1;

      final response = await WalkiePlanRepo.getEligibleCoupons(
        planId: planId,
        purchasedSeats: seats,
      );

      if (response.status == true && response.data != null) {
        eligibleCoupons.assignAll(response.data!.coupons);
      }
    } catch (e) {
      debugPrint("Error fetching eligible coupons: $e");
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  Future<bool> applyPromoCode(String code, {bool isSilent = false}) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      if (!isSilent) showTopWhiteMessage("Please enter a valid coupon code");
      return false;
    }

    try {
      isApplyingCoupon.value = true;
      applyingCouponCode.value = cleanCode;
      userExplicitlyAppliedCoupon.value = true;

      final int planId = order.value.plan?.id ?? (order.value.isTeam ? 4 : 1);
      final int seats = order.value.isTeam ? order.value.memberCount : 1;

      // 1. Query order summary API with coupon code
      final summaryRes = await WalkiePlanRepo.getOrderSummary(
        planId: planId,
        purchasedSeats: seats,
        couponCode: cleanCode,
      );

      if (summaryRes.status == true && summaryRes.data != null) {
        summaryData.value = summaryRes.data;
        dynamicCouponCode.value = summaryRes.data?.coupon?.code ?? cleanCode;
        dynamicDiscount.value =
            (summaryRes.data?.pricing?.discountAmount ?? 0).toDouble();

        if (!isSilent) {
          final saved = summaryRes.data?.pricing?.totalSaving ??
              summaryRes.data?.pricing?.discountAmount;
          if (saved != null && saved > 0) {
            showTopWhiteMessage(
                "Coupon applied! You saved ₹${formatCurrency(saved)}");
          } else {
            showTopWhiteMessage(
                summaryRes.message ?? "Coupon applied successfully!");
          }
        }
        return true;
      }

      // 2. Fallback to applyCoupon API if needed
      final response = await WalkiePlanRepo.applyCoupon(
        planId: planId,
        purchasedSeats: seats,
        couponCode: cleanCode,
      );

      if (response.status == true && response.data != null) {
        appliedCouponData.value = response.data;
        dynamicCouponCode.value = response.data?.coupon?.code ?? cleanCode;
        dynamicDiscount.value =
            (response.data?.pricing?.discountAmount ?? 0).toDouble();

        // Refresh order summary with applied coupon
        await fetchOrderSummary(couponCodeOverride: dynamicCouponCode.value);

        if (!isSilent) {
          final saved = response.data?.pricing?.amountSaved ??
              response.data?.pricing?.discountAmount;
          if (saved != null && saved > 0) {
            showTopWhiteMessage(
                "Coupon applied! You saved ₹${formatCurrency(saved)}");
          } else {
            showTopWhiteMessage(
                response.message ?? "Coupon applied successfully!");
          }
        }
        return true;
      } else {
        if (!isSilent) {
          showTopWhiteMessage(
              response.message ?? "Invalid or expired coupon code");
        }
        return false;
      }
    } catch (e) {
      if (!isSilent) {
        showTopWhiteMessage(_parseErrorMessage(e));
      }
      return false;
    } finally {
      isApplyingCoupon.value = false;
      applyingCouponCode.value = null;
    }
  }

  Future<bool> applyCoupon(WalkieCouponItem coupon) async {
    selectedCoupon.value = coupon;
    return applyPromoCode(coupon.code ?? '');
  }

  void removeCoupon() {
    userExplicitlyAppliedCoupon.value = false;
    appliedCouponData.value = null;
    selectedCoupon.value = null;
    dynamicCouponCode.value = null;
    dynamicDiscount.value = 0.0;
    fetchOrderSummary(couponCodeOverride: "");
    showTopWhiteMessage("Coupon removed successfully");
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("✅ [WalkieOrderSummaryController] Payment Success callback received: ${response.paymentId}");
    isProcessingPayment.value = false;
    HapticFeedback.heavyImpact();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        "❌ Razorpay Payment Error: Code ${response.code} | Message: ${response.message}");
    isProcessingPayment.value = false;
    HapticFeedback.mediumImpact();

    final bool isCancelled = response.code == 2 ||
        (response.message?.toLowerCase().contains("cancel") ?? false);
    final String errorTitle =
        isCancelled ? "Payment Cancelled" : "Payment Unsuccessful";
    final String errorReason = isCancelled
        ? "Payment was cancelled before completion. No amount was deducted from your bank account."
        : (response.message != null && response.message!.isNotEmpty
            ? response.message!
            : "Your transaction could not be processed right now. Please verify your payment details or try a different payment method.");

    showPaymentStatusModal(
      title: errorTitle,
      message: errorReason,
      isCancelled: isCancelled,
      errorCode: response.code,
    );
  }

  void showPaymentStatusModal({
    required String title,
    required String message,
    bool isCancelled = false,
    int? errorCode,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isCancelled
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCancelled
                    ? Icons.info_outline_rounded
                    : Icons.error_outline_rounded,
                size: 32,
                color: isCancelled
                    ? const Color(0xFFD97706)
                    : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Change Method",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4DF5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Get.back();
                      processPayment();
                    },
                    child: const Text(
                      "Retry Pay",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("💳 Razorpay External Wallet: ${response.walletName}");
    isProcessingPayment.value = false;
  }

  Future<void> processPayment() async {
    if (isProcessingPayment.value) return;

    try {
      HapticFeedback.mediumImpact();
      isProcessingPayment.value = true;

      // 1. Prepare parameters for create-order API
      final int planId = summaryData.value?.plan?.id ??
          order.value.plan?.id ??
          (order.value.isTeam ? 4 : 1);
      final int seats = purchasedSeats;
      final String couponCode =
          isCouponApplied ? (currentPromoCode ?? "") : "";

      debugPrint(
          "🚀 [CreateOrder API] Request: planId=$planId, purchasedSeats=$seats, couponCode='$couponCode'");

      // 2. Hit WalkiePlanRepo.createOrder API
      final createOrderRes = await WalkiePlanRepo.createOrder(
        planId: planId,
        purchasedSeats: seats,
        couponCode: couponCode,
      );

      if (createOrderRes.status != true || createOrderRes.data == null) {
        isProcessingPayment.value = false;
        final errorMsg = createOrderRes.message ??
            "Failed to create payment order. Please try again.";
        showTopWhiteMessage(errorMsg);
        return;
      }

      createOrderData.value = createOrderRes.data;

      final rzp = createOrderRes.data?.razorpay;
      final payment = createOrderRes.data?.payment;

      final String? rawPhone =
          Global.storageServices.get(PrefConst.userPhone)?.toString();
      final String? userEmail =
          Global.storageServices.get(PrefConst.userEmail)?.toString();
      final String? userName =
          Global.storageServices.get(PrefConst.userName)?.toString();

      // Sanitize phone to valid 10-digit format for Razorpay
      String? cleanPhone;
      if (rawPhone != null && rawPhone.isNotEmpty) {
        final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 10) {
          cleanPhone = digits.substring(digits.length - 10);
        } else if (digits.isNotEmpty) {
          cleanPhone = digits;
        }
      }

      // Determine amount in paise from backend API or fallback
      final int amountInPaise = rzp?.amount != null && (rzp!.amount! > 0)
          ? rzp.amount!.round()
          : (totalPayable > 0 ? (totalPayable * 100).round() : 100);

      final String razorpayKey = (rzp?.keyId != null && rzp!.keyId!.isNotEmpty)
          ? rzp.keyId!
          : ConstRes.activePaymentKey;

      final Map<String, dynamic> razorpayOptions = {
        'key': razorpayKey,
        'amount': amountInPaise,
        'name': 'FG MANPOWER LLP',
        'description': 'Walkie-Talkie Subscription',
        'currency': rzp?.currency ?? 'INR',
        if (rzp?.orderId != null && rzp!.orderId!.isNotEmpty)
          'order_id': rzp!.orderId!,
        'theme': {
          'color': '#5B4DF5',
        },
        'config': _buildRazorpayConfig(),
        'prefill': {
          if (cleanPhone != null && cleanPhone.isNotEmpty) 'contact': cleanPhone,
          if (userEmail != null && userEmail.isNotEmpty) 'email': userEmail,
          if (userName != null && userName.isNotEmpty) 'name': userName,
          if (selectedPaymentMethod.value == 'upi') ...{
            'method': 'upi',
            if (customUpiVpa.value.trim().isNotEmpty)
              'vpa': customUpiVpa.value.trim(),
          },
          if (selectedPaymentMethod.value == 'card') 'method': 'card',
          if (selectedPaymentMethod.value == 'netbanking') ...{
            'method': 'netbanking',
            if (selectedBank.value.isNotEmpty)
              'bank': _getRazorpayBankCode(selectedBank.value),
          },
          if (selectedPaymentMethod.value == 'wallet') ...{
            'method': 'wallet',
            if (selectedWallet.value.isNotEmpty)
              'wallet': _getRazorpayWalletCode(selectedWallet.value),
          },
        },
        'retry': {
          'enabled': true,
          'max_count': 3,
        },
        'send_sms_hash': true,
        'notes': {
          'planTitle': planName,
          'plan_id': planId.toString(),
          'duration': durationName,
          'memberCount': seats.toString(),
          'selectedPaymentMode': selectedPaymentMethod.value,
          if (payment?.orderId != null) 'backendOrderId': payment!.orderId!,
          if (selectedPaymentMethod.value == 'upi') ...{
            'upiApp': selectedUpiApp.value,
            if (customUpiVpa.value.trim().isNotEmpty)
              'upiVpa': customUpiVpa.value.trim(),
          },
          if (selectedPaymentMethod.value == 'netbanking')
            'bank': selectedBank.value,
          if (selectedPaymentMethod.value == 'wallet')
            'wallet': selectedWallet.value,
          if (couponCode.isNotEmpty) 'couponCode': couponCode,
        },
      };

      final razorpayController = Get.isRegistered<RazorpayPaymentController>()
          ? Get.find<RazorpayPaymentController>()
          : Get.put(RazorpayPaymentController());

      // Prepare user friendly payment method string
      String methodDesc = "Razorpay Payment";
      if (selectedPaymentMethod.value == 'upi') {
        if (selectedUpiApp.value == 'gpay') {
          methodDesc = "Google Pay (UPI)";
        } else if (selectedUpiApp.value == 'phonepe') {
          methodDesc = "PhonePe (UPI)";
        } else if (selectedUpiApp.value == 'paytm') {
          methodDesc = "Paytm (UPI)";
        } else if (selectedUpiApp.value == 'bhim') {
          methodDesc = "BHIM UPI";
        } else if (selectedUpiApp.value == 'cred') {
          methodDesc = "Cred (UPI)";
        } else if (selectedUpiApp.value == 'amazonpay') {
          methodDesc = "Amazon Pay (UPI)";
        } else {
          methodDesc = "UPI Payment";
        }
      } else if (selectedPaymentMethod.value == 'card') {
        final cardTypeLabel =
            selectedCardType.value == 'credit' ? 'Credit Card' : 'Debit Card';
        methodDesc =
            "$cardTypeLabel (${selectedCardNetwork.value.toUpperCase()})";
      } else if (selectedPaymentMethod.value == 'netbanking') {
        methodDesc = "NetBanking (${selectedBank.value.toUpperCase()})";
      } else if (selectedPaymentMethod.value == 'wallet') {
        methodDesc = "Wallet (${selectedWallet.value.capitalizeFirst})";
      }

      await razorpayController.openCheckoutMap(
        optionsMap: razorpayOptions,
        paymentId: payment?.id,
        isTeamPlan: order.value.isTeam || purchasedSeats > 1,
        planName: planName,
        seats: purchasedSeats,
        validity: order.value.validTill,
        amount: (createOrderData.value?.pricing?.finalAmount ?? totalPayable).toDouble(),
        method: methodDesc,
        onSuccess: _handlePaymentSuccess,
        onError: _handlePaymentError,
        onWallet: _handleExternalWallet,
      );
    } catch (e) {
      isProcessingPayment.value = false;
      debugPrint("❌ [Razorpay] Exception opening checkout: $e");
      showTopWhiteMessage(_parseErrorMessage(e));
    }
  }

  String _getRazorpayBankCode(String bankId) {
    const bankCodeMap = {
      'hdfc': 'HDFC',
      'sbi': 'SBIN',
      'icici': 'ICIC',
      'axis': 'UTIB',
      'kotak': 'KKBK',
      'pnb': 'PUNB_R',
      'bob': 'BARB_R',
      'canara': 'CNRB',
      'indusind': 'INDB',
      'yes': 'YESB',
      'idfc': 'IDFB',
    };
    return bankCodeMap[bankId.toLowerCase()] ?? bankId.toUpperCase();
  }

  String _getRazorpayWalletCode(String walletId) {
    const walletMap = {
      'paytm': 'paytm',
      'amazonpay': 'amazonpay',
      'phonepe': 'phonepe',
      'mobikwik': 'mobikwik',
      'freecharge': 'freecharge',
      'airtel': 'airtelmoney',
    };
    return walletMap[walletId.toLowerCase()] ?? walletId.toLowerCase();
  }

  Map<String, dynamic> _buildRazorpayConfig() {
    final method = selectedPaymentMethod.value;
    if (method == 'upi') {
      return {
        'display': {
          'blocks': {
            'preferred': {
              'name': 'Pay via UPI / QR',
              'instruments': [
                {'method': 'upi'},
              ],
            },
            'other': {
              'name': 'Other Payment Methods',
              'instruments': [
                {'method': 'card'},
                {'method': 'netbanking'},
                {'method': 'wallet'},
              ],
            },
          },
          'sequence': ['block.preferred', 'block.other'],
          'preferences': {
            'show_default_blocks': true,
          },
        },
      };
    } else if (method == 'card') {
      return {
        'display': {
          'blocks': {
            'preferred': {
              'name': 'Debit / Credit Card',
              'instruments': [
                {'method': 'card'},
              ],
            },
            'other': {
              'name': 'Other Payment Methods',
              'instruments': [
                {'method': 'upi'},
                {'method': 'netbanking'},
                {'method': 'wallet'},
              ],
            },
          },
          'sequence': ['block.preferred', 'block.other'],
          'preferences': {
            'show_default_blocks': true,
          },
        },
      };
    } else if (method == 'netbanking') {
      final bankCode = _getRazorpayBankCode(selectedBank.value);
      return {
        'display': {
          'blocks': {
            'preferred': {
              'name': 'Pay via NetBanking (${selectedBank.value.toUpperCase()})',
              'instruments': [
                {
                  'method': 'netbanking',
                  'banks': [bankCode],
                },
              ],
            },
            'other': {
              'name': 'Other Payment Methods',
              'instruments': [
                {'method': 'upi'},
                {'method': 'card'},
                {'method': 'wallet'},
              ],
            },
          },
          'sequence': ['block.preferred', 'block.other'],
          'preferences': {
            'show_default_blocks': true,
          },
        },
      };
    } else if (method == 'wallet') {
      final walletCode = _getRazorpayWalletCode(selectedWallet.value);
      return {
        'display': {
          'blocks': {
            'preferred': {
              'name': 'Pay via Digital Wallet',
              'instruments': [
                {
                  'method': 'wallet',
                  'wallets': [walletCode],
                },
              ],
            },
            'other': {
              'name': 'Other Payment Methods',
              'instruments': [
                {'method': 'upi'},
                {'method': 'card'},
                {'method': 'netbanking'},
              ],
            },
          },
          'sequence': ['block.preferred', 'block.other'],
          'preferences': {
            'show_default_blocks': true,
          },
        },
      };
    }
    return {};
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void showTopWhiteMessage(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.09),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      messageText: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF5B4DF5),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}

// Backwards compatibility alias
typedef WalkieTalkiePaymentController = WalkieOrderSummaryController;
