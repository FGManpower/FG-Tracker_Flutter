import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';

import 'package:fgtracker/app/Model/walkie_order_summary_model.dart';

class WalkiePlanRepo {
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
}
