class WalkieCreateOrderResponseModel {
  final bool? status;
  final String? message;
  final WalkieCreateOrderData? data;

  const WalkieCreateOrderResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieCreateOrderResponseModel.fromJson(dynamic json) {
    if (json is! Map) return const WalkieCreateOrderResponseModel();
    final map = Map<String, dynamic>.from(json);
    return WalkieCreateOrderResponseModel(
      status: map['status'] as bool?,
      message: map['message']?.toString(),
      data: map['data'] is Map
          ? WalkieCreateOrderData.fromJson(
              Map<String, dynamic>.from(map['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class WalkieCreateOrderData {
  final WalkieOrderPaymentInfo? payment;
  final WalkieOrderRazorpayInfo? razorpay;
  final WalkieOrderPlanInfo? plan;
  final WalkieOrderSubscriptionInfo? subscription;
  final WalkieOrderCouponInfo? coupon;
  final WalkieOrderPricingInfo? pricing;

  const WalkieCreateOrderData({
    this.payment,
    this.razorpay,
    this.plan,
    this.subscription,
    this.coupon,
    this.pricing,
  });

  factory WalkieCreateOrderData.fromJson(Map<String, dynamic> json) {
    return WalkieCreateOrderData(
      payment: json['payment'] is Map
          ? WalkieOrderPaymentInfo.fromJson(
              Map<String, dynamic>.from(json['payment']))
          : null,
      razorpay: json['razorpay'] is Map
          ? WalkieOrderRazorpayInfo.fromJson(
              Map<String, dynamic>.from(json['razorpay']))
          : null,
      plan: json['plan'] is Map
          ? WalkieOrderPlanInfo.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      subscription: json['subscription'] is Map
          ? WalkieOrderSubscriptionInfo.fromJson(
              Map<String, dynamic>.from(json['subscription']))
          : null,
      coupon: json['coupon'] is Map
          ? WalkieOrderCouponInfo.fromJson(
              Map<String, dynamic>.from(json['coupon']))
          : null,
      pricing: json['pricing'] is Map
          ? WalkieOrderPricingInfo.fromJson(
              Map<String, dynamic>.from(json['pricing']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'payment': payment?.toJson(),
        'razorpay': razorpay?.toJson(),
        'plan': plan?.toJson(),
        'subscription': subscription?.toJson(),
        'coupon': coupon?.toJson(),
        'pricing': pricing?.toJson(),
      };
}

class WalkieOrderPaymentInfo {
  final int? id;
  final String? orderId;
  final String? status;

  const WalkieOrderPaymentInfo({
    this.id,
    this.orderId,
    this.status,
  });

  factory WalkieOrderPaymentInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderPaymentInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      orderId: json['orderId']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'status': status,
      };
}

class WalkieOrderRazorpayInfo {
  final String? keyId;
  final String? orderId;
  final num? amount;
  final String? currency;

  const WalkieOrderRazorpayInfo({
    this.keyId,
    this.orderId,
    this.amount,
    this.currency,
  });

  factory WalkieOrderRazorpayInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderRazorpayInfo(
      keyId: json['keyId']?.toString(),
      orderId: json['orderId']?.toString(),
      amount: json['amount'] is num
          ? json['amount']
          : num.tryParse(json['amount']?.toString() ?? ''),
      currency: json['currency']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'keyId': keyId,
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
      };
}

class WalkieOrderPlanInfo {
  final int? id;
  final String? name;
  final String? planType;
  final String? billingInterval;
  final int? durationMonths;

  const WalkieOrderPlanInfo({
    this.id,
    this.name,
    this.planType,
    this.billingInterval,
    this.durationMonths,
  });

  factory WalkieOrderPlanInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderPlanInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      planType: json['planType']?.toString(),
      billingInterval: json['billingInterval']?.toString(),
      durationMonths: json['durationMonths'] is int
          ? json['durationMonths']
          : int.tryParse(json['durationMonths']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'planType': planType,
        'billingInterval': billingInterval,
        'durationMonths': durationMonths,
      };
}

class WalkieOrderSubscriptionInfo {
  final int? purchasedSeats;

  const WalkieOrderSubscriptionInfo({
    this.purchasedSeats,
  });

  factory WalkieOrderSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderSubscriptionInfo(
      purchasedSeats: json['purchasedSeats'] is int
          ? json['purchasedSeats']
          : int.tryParse(json['purchasedSeats']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'purchasedSeats': purchasedSeats,
      };
}

class WalkieOrderCouponInfo {
  final bool? applied;
  final dynamic details;

  const WalkieOrderCouponInfo({
    this.applied,
    this.details,
  });

  factory WalkieOrderCouponInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderCouponInfo(
      applied: json['applied'] is bool
          ? json['applied']
          : (json['applied']?.toString() == 'true'),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
        'applied': applied,
        'details': details,
      };
}

class WalkieOrderPricingInfo {
  final num? subtotal;
  final num? discountAmount;
  final num? taxableAmount;
  final num? gstPercent;
  final num? gstAmount;
  final num? finalAmount;

  const WalkieOrderPricingInfo({
    this.subtotal,
    this.discountAmount,
    this.taxableAmount,
    this.gstPercent,
    this.gstAmount,
    this.finalAmount,
  });

  factory WalkieOrderPricingInfo.fromJson(Map<String, dynamic> json) {
    return WalkieOrderPricingInfo(
      subtotal: json['subtotal'] is num
          ? json['subtotal']
          : num.tryParse(json['subtotal']?.toString() ?? ''),
      discountAmount: json['discountAmount'] is num
          ? json['discountAmount']
          : num.tryParse(json['discountAmount']?.toString() ?? ''),
      taxableAmount: json['taxableAmount'] is num
          ? json['taxableAmount']
          : num.tryParse(json['taxableAmount']?.toString() ?? ''),
      gstPercent: json['gstPercent'] is num
          ? json['gstPercent']
          : num.tryParse(json['gstPercent']?.toString() ?? ''),
      gstAmount: json['gstAmount'] is num
          ? json['gstAmount']
          : num.tryParse(json['gstAmount']?.toString() ?? ''),
      finalAmount: json['finalAmount'] is num
          ? json['finalAmount']
          : num.tryParse(json['finalAmount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'taxableAmount': taxableAmount,
        'gstPercent': gstPercent,
        'gstAmount': gstAmount,
        'finalAmount': finalAmount,
      };
}
