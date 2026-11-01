// Models for the /v2 OTP-charge flow (non-India numbers, 2nd login onwards).

class OtpNextStep {
  static const String verifyOtp = 'VERIFY_OTP';
  static const String showOtpChargeScreen = 'SHOW_OTP_CHARGE_SCREEN';
  static const String completePayment = 'COMPLETE_PAYMENT';
  static const String completeProfile = 'COMPLETE_PROFILE';
  static const String mainApp = 'MAIN_APP';
}

int _toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class SendOtpResponse {
  bool? status;
  String? message;
  OtpChargeInfo? otpCharge;
  OtpResendInfo? otpResend;
  LoginInfo? loginInfo;
  String nextStep = OtpNextStep.verifyOtp;

  SendOtpResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    otpCharge = json['otpCharge'] is Map
        ? OtpChargeInfo.fromJson(Map<String, dynamic>.from(json['otpCharge']))
        : null;
    otpResend = json['otpResend'] is Map
        ? OtpResendInfo.fromJson(Map<String, dynamic>.from(json['otpResend']))
        : null;
    loginInfo = json['loginInfo'] is Map
        ? LoginInfo.fromJson(Map<String, dynamic>.from(json['loginInfo']))
        : null;
    nextStep = json['nextStep']?.toString() ?? OtpNextStep.verifyOtp;
  }
}

class OtpChargeInfo {
  bool required = false;

  /// Total charged, in rupees (e.g. 10.50)
  double amount = 0;

  /// Same amount in paise (e.g. 1050)
  int amountMinor = 0;
  String currency = 'INR';
  String? country;
  String? prefix;
  String? otpChargeToken;
  String? requestId;
  String? reason;

  // GST split, sent by the backend once added (null until then)
  double? baseAmount;
  double? gstPercent;
  double? gstAmount;

  OtpChargeInfo.fromJson(Map<String, dynamic> json) {
    baseAmount = (json['baseAmount'] as num?)?.toDouble();
    gstPercent = (json['gstPercent'] as num?)?.toDouble();
    gstAmount = (json['gstAmount'] as num?)?.toDouble();
    required = json['required'] == true;
    amount = (json['amount'] as num?)?.toDouble() ?? 0;
    amountMinor = _toInt(json['amountMinor']);
    currency = json['currency']?.toString() ?? 'INR';
    country = json['country']?.toString();
    prefix = json['prefix']?.toString();
    otpChargeToken = json['otpChargeToken']?.toString();
    requestId = json['requestId']?.toString();
    reason = json['reason']?.toString();
  }
}

class OtpResendInfo {
  bool isBlocked = false;
  int attemptsUsed = 0;
  int attemptsRemaining = 3;
  int maxAttempts = 3;
  DateTime? blockedUntil;
  int retryAfterSeconds = 0;

  OtpResendInfo.fromJson(Map<String, dynamic> json) {
    isBlocked = json['isBlocked'] == true;
    attemptsUsed = _toInt(json['attemptsUsed']);
    attemptsRemaining =
        json['attemptsRemaining'] == null ? 3 : _toInt(json['attemptsRemaining']);
    maxAttempts = json['maxAttempts'] == null ? 3 : _toInt(json['maxAttempts']);
    blockedUntil = json['blockedUntil'] != null
        ? DateTime.tryParse(json['blockedUntil'].toString())
        : null;
    retryAfterSeconds = _toInt(json['retryAfterSeconds']);
  }
}

class LoginInfo {
  bool isExistingUser = false;
  int loginCount = 0;
  bool hasEmail = false;
  String? maskedEmail;
  String? maskedMobile;
  bool canAddEmail = false;

  LoginInfo.fromJson(Map<String, dynamic> json) {
    isExistingUser = json['isExistingUser'] == true;
    loginCount = _toInt(json['loginCount']);
    hasEmail = json['hasEmail'] == true;
    maskedEmail = json['maskedEmail']?.toString();
    maskedMobile = json['maskedMobile']?.toString();
    canAddEmail = json['canAddEmail'] == true;
  }
}

/// GET /v2/otp-charge/config. Separate from the Walkie gateway, which may be
/// in a different mode (test/live).
class OtpChargeConfig {
  bool? status;
  String? message;
  String mode = 'test';
  bool isLive = false;
  String keyId = '';
  String currency = 'INR';
  bool isPaymentEnabled = true;

  OtpChargeConfig.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : <String, dynamic>{};
    mode = data['mode']?.toString() ?? 'test';
    isLive = data['isLive'] == true;
    keyId = data['keyId']?.toString() ?? '';
    currency = data['currency']?.toString() ?? 'INR';
    isPaymentEnabled = data['isPaymentEnabled'] != false;
  }
}

class OtpChargeOrderResponse {
  bool? status;
  String? message;
  String orderId = '';

  /// In paise
  int amount = 0;
  String currency = 'INR';
  String keyId = '';
  String? requestId;

  OtpChargeOrderResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : <String, dynamic>{};
    orderId = data['orderId']?.toString() ?? '';
    amount = _toInt(data['amount']);
    currency = data['currency']?.toString() ?? 'INR';
    keyId = data['keyId']?.toString() ?? '';
    requestId = data['requestId']?.toString();
  }
}

/// Response of payment-success / payment-failed
class OtpChargePaymentResponse {
  bool? status;
  String? message;
  String? paymentStatus;
  String? nextStep;

  OtpChargePaymentResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    paymentStatus =
        json['data'] is Map ? json['data']['paymentStatus']?.toString() : null;
    nextStep = json['nextStep']?.toString();
  }
}
