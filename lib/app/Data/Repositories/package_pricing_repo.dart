import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_mock.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:flutter/foundation.dart';

/// Package Pricing endpoints. Contract: docs/package_pricing_api.md
class PackagePricingRepo {
  PackagePricingRepo._();

  /// Set to false once the backend /packages endpoints are live.
  /// Only affects debug builds — release builds always call the API.
  static const bool _useMockInDebug = true;
  static const bool useMock = kDebugMode && _useMockInDebug;

  static Future<PackageListResponse> getPackages() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return PackageListResponse.fromJson(PackagePricingMock.packages());
    }
    final response = await HttpUtil().get(Urls.packages);
    return PackageListResponse.fromJson(response);
  }

  static Future<PackagePlansResponse> getPlans(String moduleKey) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return PackagePlansResponse.fromJson(
          PackagePricingMock.plansFor(moduleKey));
    }
    final response = await HttpUtil().get(Urls.packagePlans(moduleKey));
    return PackagePlansResponse.fromJson(response);
  }

  /// Backend recalculates the amount from planId × members; the app's own
  /// total is only for display.
  static Future<PackageCreateOrderResponse> createOrder({
    required int planId,
    required int members,
  }) async {
    final body = {'planId': planId, 'members': members};
    debugPrint('🚀 [PackagePricingRepo.createOrder] $body');
    final response =
        await HttpUtil().Authpost(Urls.packageCreateOrder, data: body);
    return PackageCreateOrderResponse.fromJson(response);
  }

  static Future<PackageVerifyPaymentResponse> verifyPayment({
    required int paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await HttpUtil().Authpost(
      Urls.packageVerifyPayment,
      data: {
        'paymentId': paymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    return PackageVerifyPaymentResponse.fromJson(response);
  }

  static Future<void> paymentFailed({
    required int paymentId,
    required String razorpayOrderId,
    required String failureReason,
  }) async {
    await HttpUtil().Authpost(
      Urls.packagePaymentFailed,
      data: {
        'paymentId': paymentId,
        'razorpayOrderId': razorpayOrderId,
        'failureReason': failureReason,
      },
    );
  }
}
