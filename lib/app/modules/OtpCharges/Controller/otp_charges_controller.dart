import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Razorpay/Controller/razorpay_payment_controller.dart';
import 'package:fgtracker/app/modules/home/Controller/home_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OtpChargesController extends GetxController {
  RxString phoneNumber = ''.obs;
  RxString countryCode = 'IN'.obs;
  RxString dialCode = '+91'.obs;
  RxString countryName = 'India'.obs;
  RxBool isVerified = true.obs;

  // When the backend sends charges, only these two need to change
  RxDouble otpCharge = 2.00.obs;
  RxDouble gstPercent = 18.0.obs;

  RxBool isLoading = false.obs;

  double get gstAmount => otpCharge.value * gstPercent.value / 100;

  double get totalPerOtp => otpCharge.value + gstAmount;

  /// "+91 98765 43210"
  String get formattedPhone {
    final digits = phoneNumber.value.replaceAll(RegExp(r'\D'), '');
    final dialDigits = dialCode.value.replaceAll('+', '');
    // Stored number may already include the country code
    final local = digits.length > 10 && digits.startsWith(dialDigits)
        ? digits.substring(dialDigits.length)
        : digits;
    if (local.length == 10) {
      return '${dialCode.value} ${local.substring(0, 5)} ${local.substring(5)}';
    }
    return local.isEmpty ? dialCode.value : '${dialCode.value} $local';
  }

  String money(double v) => '₹${v.toStringAsFixed(2)}';

  @override
  void onInit() {
    super.onInit();
    // Saved by getProfileData / register flow, no extra API call
    phoneNumber.value =
        Global.storageServices.get(PrefConst.userPhone)?.toString() ?? '';
  }

  /// Same key priority as Walkie: /api/initialize → ConstRes fallback
  String get _razorpayKey {
    final initPayment = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().initializeModel.value?.data?.payment
        : null;
    final key = initPayment?.razorpay?.keyId;
    return (key != null && key.isNotEmpty) ? key : ConstRes.activePaymentKey;
  }

  Future<void> onPay() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      // TODO: When the backend adds OTP-charge APIs, create the order first and pass
      // 'order_id' in options + paymentId to openCheckoutMap so Walkie's verify runs.
      // Without an order the payment is not verified by the server.
      final rawPhone = phoneNumber.value.replaceAll(RegExp(r'\D'), '');
      final contact = rawPhone.length >= 10
          ? rawPhone.substring(rawPhone.length - 10)
          : rawPhone;
      final email = Global.storageServices.get(PrefConst.userEmail)?.toString();
      final name = Global.storageServices.get(PrefConst.userName)?.toString();

      final options = <String, dynamic>{
        'key': _razorpayKey,
        'amount': (totalPerOtp * 100).round(),
        'currency': 'INR',
        'name': 'FG MANPOWER LLP',
        'description': 'OTP charges',
        'theme': {'color': '#704AFA'},
        'prefill': {
          if (contact.isNotEmpty) 'contact': contact,
          if (email != null && email.isNotEmpty && email != 'null')
            'email': email,
          if (name != null && name.isNotEmpty && name != 'null') 'name': name,
        },
        'notes': {'purpose': 'otp_charge'},
      };

      // Same Razorpay controller + result screens as the Walkie payment
      final razorpay = Get.isRegistered<RazorpayPaymentController>()
          ? Get.find<RazorpayPaymentController>()
          : Get.put(RazorpayPaymentController());

      await razorpay.openCheckoutMap(
        optionsMap: options,
        isTeamPlan: false,
        planName: 'OTP charges',
        seats: 1,
        validity: 'Per OTP',
        amount: totalPerOtp,
        method: 'Razorpay (UPI / Card)',
        onSuccess: (_) => isLoading.value = false,
        onError: (response) {
          isLoading.value = false;
          // Walkie's failed screen reads errorMessage after this callback
          razorpay.errorMessage.value = _errorMessageFor(response);
        },
        onWallet: (_) => isLoading.value = false,
        otpCharge: otpCharge.value,
        otpGstPercent: gstPercent.value,
      );
      // openCheckoutMap catches its own errors; nothing opened → stop loader
      if (!razorpay.isProcessing.value) isLoading.value = false;
    } catch (e) {
      if (kDebugMode) debugPrint('[OtpCharges] open failed: $e');
      isLoading.value = false;
    }
  }

  String _errorMessageFor(PaymentFailureResponse response) {
    if (kDebugMode) {
      debugPrint(
          '[OtpCharges] error code=${response.code} message=${response.message}');
    }
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment cancelled. You cancelled the payment. No money was deducted.';
      case Razorpay.NETWORK_ERROR:
        return 'No internet connection. Check your network and try again.';
      case Razorpay.TLS_ERROR:
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return "Payment couldn't start. Please update the app and try again.";
      case Razorpay.INVALID_OPTIONS:
        return 'Something went wrong. Please try again in a moment.';
      default:
        return 'Payment failed. If money was deducted it will be refunded in 5–7 working days.';
    }
  }

  void onBack() => Get.back();
}
