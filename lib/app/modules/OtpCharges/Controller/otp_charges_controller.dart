import 'dart:async';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/otp_charge_repo.dart';
import 'package:fgtracker/app/Model/otp_charge_model.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Opened from login when /v2/send-otp returns SHOW_OTP_CHARGE_SCREEN.
/// Pay → create-order → Razorpay → payment-success (backend sends the OTP)
/// → OTP screen. Opened without a charge token (side menu) it is info only.
class OtpChargesController extends GetxController {
  RxString phoneNumber = ''.obs;
  RxString countryCode = 'IN'.obs;
  RxString dialCode = '+91'.obs;
  RxString countryName = 'India'.obs;
  RxBool isVerified = true.obs;

  // Base charge + GST shown in the breakup; total comes from the backend
  RxDouble otpCharge = 2.00.obs;
  RxDouble gstPercent = 18.0.obs;
  final RxnDouble _backendTotal = RxnDouble();

  RxBool isLoading = false.obs;

  String? _otpChargeToken;
  String? _orderId;
  String? _email;
  OtpResendInfo? _otpResend; // handed on to the OTP screen
  late final Razorpay _razorpay;

  // OTP-charge gateway (own test/live mode, never the Walkie key)
  OtpChargeConfig? _gatewayConfig;
  Future<void>? _configLoad;
  final RxBool isPaymentEnabled = true.obs;

  // Backend token lives 30 min; expire it here a bit earlier
  static const Duration _tokenLifetime = Duration(minutes: 25);
  Timer? _expiryTimer;
  bool _tokenExpired = false;

  /// Only a login with a charge token can pay
  bool get canPay => _otpChargeToken != null && _otpChargeToken!.isNotEmpty;

  double get totalPerOtp =>
      _backendTotal.value ?? otpCharge.value + otpCharge.value * gstPercent.value / 100;

  double get gstAmount => totalPerOtp - otpCharge.value;

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
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) => isLoading.value = false);

    final args = Get.arguments;
    if (args is Map && args['otpCharge'] is OtpChargeInfo) {
      _loadFromLogin(args);
    } else {
      // Side menu: saved by getProfileData / register flow, no extra API call
      phoneNumber.value =
          Global.storageServices.get(PrefConst.userPhone)?.toString() ?? '';
    }
  }

  void _loadFromLogin(Map args) {
    final charge = args['otpCharge'] as OtpChargeInfo;
    final loginInfo = args['loginInfo'] as LoginInfo?;

    phoneNumber.value = args['mobNo']?.toString() ?? '';
    dialCode.value = args['countryCode']?.toString() ?? dialCode.value;
    final iso = args['countryIso']?.toString() ?? '';
    countryCode.value = iso.isNotEmpty ? iso : (charge.prefix ?? '');
    countryName.value = (charge.country?.isNotEmpty ?? false)
        ? charge.country!
        : args['countryName']?.toString() ?? '';

    _otpChargeToken = charge.otpChargeToken;
    _otpResend = args['otpResend'] as OtpResendInfo?;
    // Backend amount is the final GST-inclusive price
    final total = charge.amountMinor > 0
        ? charge.amountMinor / 100
        : charge.amount;
    _backendTotal.value = total;
    if (charge.gstPercent != null) gstPercent.value = charge.gstPercent!;
    // Use the backend split when sent, otherwise work it out from the total
    otpCharge.value = charge.baseAmount ??
        (total / (1 + gstPercent.value / 100) * 100).roundToDouble() / 100;
    _expiryTimer = Timer(_tokenLifetime, _onTokenExpired);

    final masked = loginInfo?.maskedEmail;
    _email = (masked == null || masked.contains('*')) ? null : masked;

    _configLoad = _loadGatewayConfig();
  }

  /// Fetched when the screen opens, before payment can start
  Future<void> _loadGatewayConfig() async {
    try {
      final config = await OtpChargeRepo.getConfig();
      if (config.status != true) return;
      _gatewayConfig = config;
      isPaymentEnabled.value = config.isPaymentEnabled;
      if (kDebugMode) {
        debugPrint('[OtpCharges] gateway mode=${config.mode} live=${config.isLive}');
      }
    } catch (e) {
      // create-order still returns the active key, so payment can go ahead
      if (kDebugMode) debugPrint('[OtpCharges] config failed: $e');
    }
  }

  void _onTokenExpired() {
    _tokenExpired = true;
    // Mid-payment: let it finish, payment-success reports a dead token itself
    if (!isLoading.value) _showSessionExpired();
  }

  /// Token is gone; only a fresh send-otp from the login screen gives a new one
  void _showSessionExpired([String? message]) {
    _expiryTimer?.cancel();
    _tokenExpired = true;
    CommonDialog.errorMessage(
      message ?? 'Session expired. Please start again.',
      onDismiss: () {
        Get.back(); // dialog
        onBack(); // to login
      },
    );
  }

  static bool _isTokenError(String? message) {
    final m = message?.toLowerCase() ?? '';
    return m.contains('expired') || m.contains('invalid or expired');
  }

  Future<void> onPay() async {
    if (isLoading.value || !canPay) return;
    if (_tokenExpired) {
      _showSessionExpired();
      return;
    }
    isLoading.value = true;
    try {
      await _configLoad;
      if (!isPaymentEnabled.value) {
        isLoading.value = false;
        CommonDialog.errorMessage(
            'OTP payments are temporarily unavailable. Please try again later.');
        return;
      }

      final order = await OtpChargeRepo.createOrder(_otpChargeToken!);
      if (order.status != true || order.orderId.isEmpty) {
        isLoading.value = false;
        if (_isTokenError(order.message)) {
          _showSessionExpired(order.message);
          return;
        }
        CommonDialog.errorMessage(
            order.message ?? 'Could not start the payment. Please try again.');
        return;
      }
      _orderId = order.orderId;

      // create-order key matches the config; config only fills a missing one
      final key =
          order.keyId.isNotEmpty ? order.keyId : _gatewayConfig?.keyId ?? '';
      if (key.isEmpty) {
        isLoading.value = false;
        CommonDialog.errorMessage(
            'Could not start the payment. Please try again.');
        return;
      }

      final rawPhone = phoneNumber.value.replaceAll(RegExp(r'\D'), '');
      final options = <String, dynamic>{
        'key': key,
        'amount': order.amount, // already in paise
        'currency': order.currency,
        'order_id': order.orderId,
        'name': 'FG MANPOWER LLP',
        'description': 'International OTP Verification Fee',
        'timeout': 180,
        'theme': {'color': '#704AFA'},
        'prefill': {
          if (rawPhone.isNotEmpty) 'contact': '${dialCode.value}$rawPhone',
          if (_email != null) 'email': _email,
        },
        'notes': {'purpose': 'otp_charge'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (kDebugMode) debugPrint('[OtpCharges] open failed: $e');
      isLoading.value = false;
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _expiryTimer?.cancel();
    // payment-success is idempotent, so retry network failures. If it never
    // gets through, the Razorpay webhook still sends the OTP.
    OtpChargePaymentResponse? result;
    for (var attempt = 1; attempt <= 3 && result == null; attempt++) {
      try {
        result = await OtpChargeRepo.paymentSuccess(
          razorpayOrderId: response.orderId ?? _orderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
          otpChargeToken: _otpChargeToken ?? '',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[OtpCharges] verify attempt $attempt: $e');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    isLoading.value = false;

    if (result == null) {
      Utils().fluttertoast(
          'Payment received. Your OTP may take a moment to arrive.');
      _goToOtpScreen();
      return;
    }
    if (result.status != true) {
      CommonDialog.errorMessage(result.message ??
          'Payment verification failed. If money was deducted it will be refunded in 5–7 working days.');
      return;
    }
    _goToOtpScreen();
  }

  /// OTP has been sent by the backend, same args as the free login path
  void _goToOtpScreen() {
    Get.offNamed(Routes.OTPScreen, arguments: {
      'mobNo': phoneNumber.value,
      'countryCode': dialCode.value,
      'otpResend': _otpResend,
    });
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    isLoading.value = false;
    final message = _errorMessageFor(response);
    if (_orderId != null) {
      try {
        await OtpChargeRepo.paymentFailed(
          razorpayOrderId: _orderId!,
          failureReason: response.message?.isNotEmpty == true
              ? response.message!
              : 'Payment cancelled',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[OtpCharges] payment-failed call: $e');
      }
    }
    // Token ran out while Razorpay was open: retrying would fail too
    if (_tokenExpired) {
      _showSessionExpired();
      return;
    }
    // Stay here; tapping Pay again creates a fresh order
    CommonDialog.errorMessage(message);
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

  /// Back to login = "Change Number"
  void onBack() => Get.back();

  @override
  void onClose() {
    _expiryTimer?.cancel();
    _razorpay.clear();
    super.onClose();
  }
}
