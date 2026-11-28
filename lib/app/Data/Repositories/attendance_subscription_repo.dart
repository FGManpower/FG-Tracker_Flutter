import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/modules/Attendance/models/attendance_subscription_models.dart';

class AttendanceSubscriptionRepo {
  static Future<AttendanceSubscriptionStatusModel> getSubscriptionStatus(
      int groupId) async {
    final response =
        await HttpUtil().get('/attendance/subscription/status?groupId=$groupId');
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return AttendanceSubscriptionStatusModel.fromJson(data);
  }

  static Future<Map<String, dynamic>> startTrial(int groupId) async {
    final response = await HttpUtil().Authpost(
      '/attendance/trial/start',
      data: {'groupId': groupId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  static Future<({String currency, List<AttendancePlanModel> plans})> getPlans(
      {String? currency}) async {
    final qs = (currency != null && currency.trim().isNotEmpty)
        ? '?currency=${currency.trim().toUpperCase()}'
        : '';
    final response = await HttpUtil().get('/attendance/plans$qs');
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    final detectedCurrency =
        (data['currency'] ?? 'INR').toString().toUpperCase();
    final rawPlans = (data['plans'] as List?) ?? const [];
    final plans = rawPlans
        .whereType<Map<String, dynamic>>()
        .map(AttendancePlanModel.fromJson)
        .toList();
    return (currency: detectedCurrency, plans: plans);
  }

  static Future<AttendanceOrderSummaryModel> getOrderSummary({
    required int planId,
    required int purchasedSeats,
    String? couponCode,
    String orderPurpose = 'new_subscription',
  }) async {
    final response = await HttpUtil().Authpost(
      '/attendance/orders/summary',
      data: {
        'planId': planId,
        'purchasedSeats': purchasedSeats,
        'orderPurpose': orderPurpose,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim().toUpperCase(),
      },
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return AttendanceOrderSummaryModel.fromJson(data);
  }

  static Future<AttendancePaymentOrderModel> createOrder({
    required int groupId,
    required int planId,
    required int purchasedSeats,
    String? couponCode,
  }) async {
    final response = await HttpUtil().Authpost(
      '/attendance/payment/create-order',
      data: {
        'groupId': groupId,
        'planId': planId,
        'purchasedSeats': purchasedSeats,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim().toUpperCase(),
      },
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return AttendancePaymentOrderModel.fromJson(data);
  }

  static Future<AttendancePaymentOrderModel> topupSeats({
    required int groupId,
    required int additionalSeats,
    int? subscriptionId,
    String? couponCode,
  }) async {
    final response = await HttpUtil().Authpost(
      '/attendance/payment/topup-seats',
      data: {
        'groupId': groupId,
        'additionalSeats': additionalSeats,
        if (subscriptionId != null) 'subscriptionId': subscriptionId,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'couponCode': couponCode.trim().toUpperCase(),
      },
    );
    final data = (response['data'] as Map<String, dynamic>?) ?? const {};
    return AttendancePaymentOrderModel.fromJson(data);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required int paymentId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await HttpUtil().Authpost(
      '/attendance/payment/verify',
      data: {
        'paymentId': paymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  static Future<Map<String, dynamic>> updateMemberSeats({
    required int groupId,
    int? subscriptionId,
    List<int>? replaceUserIds,
    List<int>? targetUserIds,
    int? removeUserId,
  }) async {
    final response = await HttpUtil().Authpost(
      '/attendance/update-member-subscription',
      data: {
        'groupId': groupId,
        if (subscriptionId != null) 'subscriptionId': subscriptionId,
        if (replaceUserIds != null) 'replaceUserIds': replaceUserIds,
        if (targetUserIds != null) 'targetUserIds': targetUserIds,
        if (removeUserId != null) 'removeUserId': removeUserId,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }
}
