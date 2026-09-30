import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:fgtracker/app/Model/walkie_verify_payment_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Model/razorpay_payment_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_payment_failed_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_payment_pending_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentController extends GetxController {
  late final Razorpay _razorpay;

  final Rx<PaymentProcessStatus> status = PaymentProcessStatus.initial.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnString successPaymentId = RxnString();
  final RxnString successOrderId = RxnString();
  final RxnString successSignature = RxnString();
  int? createdPaymentId;
  String? createdRazorpayOrderId;

  // Plan & Receipt metadata
  final RxBool isTeam = true.obs;
  final RxString planTitle = "Team Plan (Monthly)".obs;
  final RxInt memberCount = 1.obs;
  final RxString validTill = "".obs;
  final RxDouble amountPaid = 0.0.obs;
  final RxString paymentMethod = "Razorpay (UPI / Card)".obs;
  final RxString transactionTime = "".obs;

  Function(PaymentSuccessResponse)? _customSuccessCallback;
  Function(PaymentFailureResponse)? _customFailureCallback;
  Function(ExternalWalletResponse)? _customWalletCallback;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
        "✅ [RazorpayPaymentController] Payment Success: ${response.paymentId}");
    HapticFeedback.heavyImpact();

    final String finalPayId = response.paymentId ?? '';
    final String finalOrdId =
        (response.orderId != null && response.orderId!.isNotEmpty)
            ? response.orderId!
            : (createdRazorpayOrderId ?? successOrderId.value ?? '');
    final String finalSig = response.signature ?? '';

    successPaymentId.value = finalPayId;
    successOrderId.value = finalOrdId;
    successSignature.value = finalSig;

    final String nowFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    transactionTime.value = nowFormatted;

    // 1. Verify Payment with Backend API
    bool isSuccess = true;
    bool isPending = false;
    String verifyMsg = '';

    if (createdPaymentId != null && createdPaymentId! > 0) {
      try {
        debugPrint(
            "🚀 [RazorpayPaymentController] Calling verify API: paymentId=$createdPaymentId, orderId=$finalOrdId, payId=$finalPayId");
        final verifyRes = await WalkiePlanRepo.verifyPayment(
          paymentId: createdPaymentId!,
          razorpayOrderId: finalOrdId,
          razorpayPaymentId: finalPayId,
          razorpaySignature: finalSig,
        );
        debugPrint(
            "✅ [RazorpayPaymentController] Verification response: ${verifyRes.toJson()}");

        if (verifyRes.status == false) {
          isSuccess = false;
          verifyMsg = verifyRes.message ?? "Payment verification failed.";
          final lower = verifyMsg.toLowerCase();
          if (lower.contains("pending") ||
              lower.contains("process") ||
              lower.contains("awaiting")) {
            isPending = true;
          }
        }
      } catch (e) {
        debugPrint("⚠️ [RazorpayPaymentController] Verification API Error: $e");
        // If network error occurred during verification, classify as pending check
        isSuccess = false;
        isPending = true;
        verifyMsg = "Payment was initiated. We are confirming with the bank.";
      }
    }

    isProcessing.value = false;

    // Flow 1: Verification Pending
    if (isPending) {
      status.value = PaymentProcessStatus.cancelled;
      errorMessage.value = verifyMsg;
      Get.off(() => WalkieTalkiePaymentPendingScreen(
            isTeam: isTeam.value,
            planTitle: planTitle.value,
            memberCount: memberCount.value,
            amountPaid: amountPaid.value,
            transactionTime: nowFormatted,
            orderId: finalOrdId,
          ));
      return;
    }

    // Flow 2: Verification Failed
    if (!isSuccess) {
      status.value = PaymentProcessStatus.failed;
      errorMessage.value =
          verifyMsg.isNotEmpty ? verifyMsg : "Payment verification failed.";
      Get.off(() => WalkieTalkiePaymentFailedScreen(
            isTeam: isTeam.value,
            planTitle: planTitle.value,
            memberCount: memberCount.value,
            amountPaid: amountPaid.value,
            transactionTime: nowFormatted,
            errorMessage: errorMessage.value,
            orderId: finalOrdId,
          ));
      return;
    }

    // Flow 3: Verification Success
    status.value = PaymentProcessStatus.success;
    errorMessage.value = '';

    if (_customSuccessCallback != null) {
      _customSuccessCallback!(response);
    }

    refreshWalkieOverviewSilently();

    final String currentRoute = Get.currentRoute;
    if (!currentRoute.contains("WalkieTalkiePurchaseSuccessScreen")) {
      Get.off(() => WalkieTalkiePurchaseSuccessScreen(
            isTeam: isTeam.value,
            planTitle: planTitle.value,
            memberCount: memberCount.value,
            validTill:
                validTill.value.isNotEmpty ? validTill.value : "1 Month Active",
            paymentId: finalPayId.isNotEmpty
                ? finalPayId
                : "pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}",
            orderId: finalOrdId,
            amountPaid: amountPaid.value,
            paymentMethod: paymentMethod.value,
            transactionTime: nowFormatted,
          ));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        "❌ [RazorpayPaymentController] Payment Error: Code ${response.code} | Message: ${response.message}");
    isProcessing.value = false;
    HapticFeedback.mediumImpact();

    final String nowFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    transactionTime.value = nowFormatted;

    final String msg = response.message ?? '';
    final String lowerMsg = msg.toLowerCase();
    final int? code = response.code;

    // Check if error is strictly an in-progress / pending state from gateway
    final bool isExplicitlyPending = (lowerMsg.contains("pending") ||
            lowerMsg.contains("awaiting") ||
            lowerMsg.contains("processing")) &&
        !lowerMsg.contains("fail") &&
        !lowerMsg.contains("decline") &&
        !lowerMsg.contains("error") &&
        !lowerMsg.contains("rejected");

    if (isExplicitlyPending) {
      debugPrint(
          "⏱️ [RazorpayPaymentController] Routing to Payment Pending Screen (Code: $code | Message: $msg)");
      status.value = PaymentProcessStatus.cancelled;
      errorMessage.value =
          msg.isNotEmpty ? msg : "Payment is pending confirmation.";

      if (_customFailureCallback != null) {
        _customFailureCallback!(response);
      }

      Get.off(() => WalkieTalkiePaymentPendingScreen(
            isTeam: isTeam.value,
            planTitle: planTitle.value,
            memberCount: memberCount.value,
            amountPaid: amountPaid.value,
            transactionTime: nowFormatted,
            orderId: createdRazorpayOrderId ?? successOrderId.value,
          ));
    } else {
      // Payment Failed (Bank decline, card error, invalid auth, payment failed, cancelled checkout, etc.)
      debugPrint(
          "❌ [RazorpayPaymentController] Routing to Payment Failed Screen (Code: $code | Message: $msg)");
      status.value = PaymentProcessStatus.failed;
      errorMessage.value =
          msg.isNotEmpty ? msg : "Payment failed. Please try again.";

      if (_customFailureCallback != null) {
        _customFailureCallback!(response);
      }

      Get.off(() => WalkieTalkiePaymentFailedScreen(
            isTeam: isTeam.value,
            planTitle: planTitle.value,
            memberCount: memberCount.value,
            amountPaid: amountPaid.value,
            transactionTime: nowFormatted,
            errorMessage: errorMessage.value,
            orderId: createdRazorpayOrderId ?? successOrderId.value,
          ));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint(
        "💳 [RazorpayPaymentController] External Wallet: ${response.walletName}");
    if (_customWalletCallback != null) {
      _customWalletCallback!(response);
    }
  }

  /// Open Razorpay Checkout modal with Model options
  Future<void> openCheckout({
    required RazorpayPaymentOptions options,
    int? paymentId,
    bool? isTeamPlan,
    String? planName,
    int? seats,
    String? validity,
    double? amount,
    String? method,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) async {
    return openCheckoutMap(
      optionsMap: options.toMap(),
      paymentId: paymentId,
      isTeamPlan: isTeamPlan,
      planName: planName,
      seats: seats,
      validity: validity,
      amount: amount,
      method: method,
      onSuccess: onSuccess,
      onError: onError,
      onWallet: onWallet,
    );
  }

  /// Open Razorpay Checkout modal with Map options
  Future<void> openCheckoutMap({
    required Map<String, dynamic> optionsMap,
    int? paymentId,
    bool? isTeamPlan,
    String? planName,
    int? seats,
    String? validity,
    double? amount,
    String? method,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) async {
    try {
      createdPaymentId = paymentId;
      createdRazorpayOrderId = optionsMap['order_id']?.toString() ??
          optionsMap['orderId']?.toString();
      if (createdRazorpayOrderId != null &&
          createdRazorpayOrderId!.isNotEmpty) {
        successOrderId.value = createdRazorpayOrderId;
      }
      if (isTeamPlan != null) isTeam.value = isTeamPlan;
      if (planName != null && planName.isNotEmpty) planTitle.value = planName;
      if (seats != null) memberCount.value = seats;
      if (validity != null) validTill.value = validity;
      if (amount != null) amountPaid.value = amount;
      if (method != null) paymentMethod.value = method;

      isProcessing.value = true;
      status.value = PaymentProcessStatus.processing;
      errorMessage.value = '';

      _customSuccessCallback = onSuccess;
      _customFailureCallback = onError;
      _customWalletCallback = onWallet;

      debugPrint(
          "🚀 [RazorpayPaymentController] Opening Checkout with options: $optionsMap");

      _razorpay.open(optionsMap);
    } catch (e) {
      debugPrint(
          "❌ [RazorpayPaymentController] Error opening Razorpay checkout: $e");
      isProcessing.value = false;
      status.value = PaymentProcessStatus.failed;
      errorMessage.value = "Unable to launch payment gateway: $e";
    }
  }

  /// Refresh overview API in background
  Future<void> refreshWalkieOverviewSilently() async {
    try {
      if (Get.isRegistered<WalkieTalkieTrialController>()) {
        Get.find<WalkieTalkieTrialController>().fetchOverview(refresh: true);
      } else {
        await WalkieTalkieTrialService().getOverview();
      }
    } catch (_) {}
  }

  /// Copy payment ID to clipboard
  void copyPaymentId() {
    HapticFeedback.selectionClick();
    final id = successPaymentId.value ?? '';
    if (id.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: id));
      showTopSnackbar("Payment ID copied to clipboard!");
    }
  }

  /// Copy / Share complete receipt text
  void shareReceipt() {
    HapticFeedback.lightImpact();
    final receiptText = "FG Tracker Payment Receipt\n"
        "Plan: ${planTitle.value}\n"
        "Amount: ₹${formatAmount(amountPaid.value > 0 ? amountPaid.value : 499)}\n"
        "Payment ID: ${successPaymentId.value ?? ''}\n"
        "${successOrderId.value != null && successOrderId.value!.isNotEmpty ? 'Order ID: ${successOrderId.value}\n' : ''}"
        "Date: ${transactionTime.value}\n"
        "Payment Mode: ${paymentMethod.value}\n"
        "Status: Completed";

    Clipboard.setData(ClipboardData(text: receiptText));
    showTopSnackbar("Receipt details copied to clipboard!");
  }

  /// Navigate to Assign Members screen
  void navigateToAssignMembers() {
    try {
      Get.toNamed(Routes.WalkieGroupSelect);
    } catch (_) {
      Get.to(() => const WalkieGroupSelectScreen());
    }
  }

  /// Return to Home Screen
  void navigateToHome() {
    try {
      Get.offAllNamed(Routes.Home_Screen);
    } catch (_) {
      Get.back();
      Get.back();
    }
  }

  /// Amount formatting helper
  String formatAmount(num amount) {
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

  void showTopSnackbar(String msg) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0F172A),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      messageText: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4ADE80),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );
  }

  /// Reset payment state
  void resetState() {
    isProcessing.value = false;
    status.value = PaymentProcessStatus.initial;
    errorMessage.value = '';
    successPaymentId.value = null;
    successOrderId.value = null;
    successSignature.value = null;
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
