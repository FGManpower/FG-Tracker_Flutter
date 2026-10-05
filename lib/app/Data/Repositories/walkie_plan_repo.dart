import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';

import 'package:fgtracker/app/Model/walkie_create_order_model.dart';
import 'package:fgtracker/app/Model/walkie_order_summary_model.dart';

import 'package:fgtracker/app/Model/walkie_verify_payment_model.dart';
import 'package:flutter/cupertino.dart';

import 'package:fgtracker/app/Model/CommonRes.dart';

class WalkiePlanRepo {
  static Future<CommonResponse> updateMemberSubscription({
    required int subscriptionId,
    List<int>? targetUserIds,
    int? targetUserId,
    List<int>? replaceUserIds,
    int? replaceUserId,
    int? removeUserId,
    int? oldUserId,
    int? newUserId,
    String? action,
  }) async {
    final Map<String, dynamic> body = {
      'subscriptionId': subscriptionId,
    };

    if (action != null && action.isNotEmpty) {
      body['action'] = action;
    }

    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      body['targetUserIds'] = targetUserIds;
    } else if (targetUserId != null) {
      body['targetUserId'] = targetUserId;
    }

    if (replaceUserIds != null && replaceUserIds.isNotEmpty) {
      body['replaceUserIds'] = replaceUserIds;
    } else if (replaceUserId != null) {
      body['replaceUserId'] = replaceUserId;
    }

    if (removeUserId != null) {
      body['removeUserId'] = removeUserId;
    }

    if (oldUserId != null) {
      body['oldUserId'] = oldUserId;
    }

    if (newUserId != null) {
      body['newUserId'] = newUserId;
    }

    debugPrint(
        "🚀 [WalkiePlanRepo.updateMemberSubscription] URL: ${Urls.walkieUpdateMemberSubscription} | Body: $body");
    var response = await HttpUtil().Authpost(
      Urls.walkieUpdateMemberSubscription,
      data: body,
    );
    debugPrint(
        "✅ [WalkiePlanRepo.updateMemberSubscription] Raw Response: $response");
    return CommonResponse.fromJson(response);
  }

  static Future<WalkiePlansResponseModel> getPlans({required String planType}) async {
    var response = await HttpUtil().get(
      Urls.walkiePlans,
      data: {'planType': planType},
    );
    return WalkiePlansResponseModel.fromJson(response);
  }

  static Future<WalkieCouponResponseModel> getEligibleCoupons({
    required int planId,
    required int purchasedSeats,
  }) async {
    var response = await HttpUtil().get(
      Urls.walkieEligibleCoupons,
      data: {
        'planId': planId,
        'purchasedSeats': purchasedSeats,
      },
    );
    return WalkieCouponResponseModel.fromJson(response);
  }

  static Future<WalkieApplyCouponResponseModel> applyCoupon({
    required int planId,
    required int purchasedSeats,
    required String couponCode,
  }) async {
    var response = await HttpUtil().Authpost(
      Urls.walkieApplyCoupon,
      data: {
        'planId': planId,
        'purchasedSeats': purchasedSeats,
        'couponCode': couponCode,
      },
    );
    return WalkieApplyCouponResponseModel.fromJson(response);
  }

  static Future<WalkieOrderSummaryResponseModel> getOrderSummary({
    required int planId,
    required int purchasedSeats,
    String? couponCode,
  }) async {
    final Map<String, dynamic> body = {
      'planId': planId,
      'purchasedSeats': purchasedSeats,
    };
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      body['couponCode'] = couponCode.trim().toUpperCase();
    }
    var response = await HttpUtil().Authpost(
      Urls.walkieOrderSummary,
      data: body,
    );
    return WalkieOrderSummaryResponseModel.fromJson(response);
  }

  static Future<WalkieCreateOrderResponseModel> createOrder({
    required int planId,
    required int purchasedSeats,
    String couponCode = "",
  }) async {
    final Map<String, dynamic> body = {
      'planId': planId,
      'purchasedSeats': purchasedSeats,
      'couponCode': couponCode.trim().isNotEmpty ? couponCode.trim().toUpperCase() : "",
    };
    var response = await HttpUtil().Authpost(
      Urls.walkieCreateOrder,
      data: body,
    );
    return WalkieCreateOrderResponseModel.fromJson(response);
  }

  static Future<WalkieVerifyPaymentResponseModel> verifyPayment({
    required int paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final Map<String, dynamic> body = {
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    };
    debugPrint("🚀 [WalkiePlanRepo.verifyPayment] URL: ${Urls.walkieVerifyPayment} | Body: $body");
    var response = await HttpUtil().Authpost(
      Urls.walkieVerifyPayment,
      data: body,
    );
    debugPrint("✅ [WalkiePlanRepo.verifyPayment] Raw Response: $response");
    return WalkieVerifyPaymentResponseModel.fromJson(response);
  }
}
