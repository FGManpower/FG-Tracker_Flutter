import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Model/razorpay_payment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentController extends GetxController {
  late final Razorpay _razorpay;

  final Rx<PaymentProcessStatus> status = PaymentProcessStatus.initial.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxnString successPaymentId = RxnString();
  final RxnString successOrderId = RxnString();
  final RxnString successSignature = RxnString();

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("✅ Razorpay Payment Success: ${response.paymentId}");
    isProcessing.value = false;
    status.value = PaymentProcessStatus.success;
    errorMessage.value = '';
    successPaymentId.value = response.paymentId;
    successOrderId.value = response.orderId;
    successSignature.value = response.signature;

    if (_customSuccessCallback != null) {
      _customSuccessCallback!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        "❌ Razorpay Payment Error: Code ${response.code} | Message: ${response.message}");
    isProcessing.value = false;

    // Razorpay code 2 = User cancelled transaction
    if (response.code == 2) {
      status.value = PaymentProcessStatus.cancelled;
      errorMessage.value = "Payment was cancelled.";
    } else {
      status.value = PaymentProcessStatus.failed;
      errorMessage.value =
          response.message ?? "Payment failed. Please try again.";
    }

    if (_customFailureCallback != null) {
      _customFailureCallback!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("💳 Razorpay External Wallet: ${response.walletName}");
    if (_customWalletCallback != null) {
      _customWalletCallback!(response);
    }
  }

  /// Open Razorpay Checkout modal
  Future<void> openCheckout({
    required RazorpayPaymentOptions options,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) async {
    try {
      isProcessing.value = true;
      status.value = PaymentProcessStatus.processing;
      errorMessage.value = '';

      _customSuccessCallback = onSuccess;
      _customFailureCallback = onError;
      _customWalletCallback = onWallet;

      final map = options.toMap();
      debugPrint("🚀 Opening Razorpay Checkout with options: $map");

      _razorpay.open(map);
    } catch (e) {
      debugPrint("❌ Error opening Razorpay checkout: $e");
      isProcessing.value = false;
      status.value = PaymentProcessStatus.failed;
      errorMessage.value = "Unable to launch payment gateway: $e";
    }
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
