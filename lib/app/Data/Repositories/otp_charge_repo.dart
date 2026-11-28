import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/OtpVeriefy.dart';
import 'package:fgtracker/app/Model/otp_charge_model.dart';

/// /v2 OTP-charge endpoints. All are called before login, so no auth header.
class OtpChargeRepo {
  static Future<SendOtpResponse> sendOtp(dynamic param) async {
    var response = await HttpUtil().post(Urls.v2SendOtp, data: param);
    return SendOtpResponse.fromJson(response);
  }

  /// Carries otpResend (attempts left / 6-hour block)
  static Future<SendOtpResponse> resendOtp(dynamic param) async {
    var response = await HttpUtil().post(Urls.v2ResendOtp, data: param);
    return SendOtpResponse.fromJson(response);
  }

  /// Same data keys as the legacy verify-otp, so the existing model is reused
  static Future<VeriefyOtpResponse> verifyOtp(dynamic param) async {
    var response = await HttpUtil().post(Urls.v2VerifyOtp, data: param);
    return VeriefyOtpResponse.fromJson(response);
  }

  /// Active gateway for the OTP-charge module (test/live key, enabled flag)
  static Future<OtpChargeConfig> getConfig() async {
    // HttpUtil().get needs a saved token, and there is none before login
    var response = await HttpUtil().api.sendRequest.get(Urls.otpChargeConfig);
    return OtpChargeConfig.fromJson(response.data);
  }

  static Future<OtpChargeOrderResponse> createOrder(
      String otpChargeToken) async {
    var response = await HttpUtil().post(Urls.otpChargeCreateOrder,
        data: {'otpChargeToken': otpChargeToken});
    return OtpChargeOrderResponse.fromJson(response);
  }

  static Future<OtpChargePaymentResponse> paymentSuccess({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String otpChargeToken,
  }) async {
    var response = await HttpUtil().post(Urls.otpChargePaymentSuccess, data: {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'otpChargeToken': otpChargeToken,
    });
    return OtpChargePaymentResponse.fromJson(response);
  }

  static Future<OtpChargePaymentResponse> paymentFailed({
    required String razorpayOrderId,
    required String failureReason,
  }) async {
    var response = await HttpUtil().post(Urls.otpChargePaymentFailed, data: {
      'razorpayOrderId': razorpayOrderId,
      'failureReason': failureReason,
    });
    return OtpChargePaymentResponse.fromJson(response);
  }
}
