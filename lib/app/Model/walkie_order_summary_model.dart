class WalkieOrderSummaryResponseModel {
  final bool? status;
  final String? message;
  final WalkieOrderSummaryData? data;

  const WalkieOrderSummaryResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieOrderSummaryResponseModel.fromJson(dynamic json) {
    if (json is! Map) return const WalkieOrderSummaryResponseModel();
    final map = Map<String, dynamic>.from(json);
    return WalkieOrderSummaryResponseModel(
      status: map['status'] as bool?,
      message: map['message']?.toString(),
      data: map['data'] is Map
          ? WalkieOrderSummaryData.fromJson(Map<String, dynamic>.from(map['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class WalkieOrderSummaryData {
  final WalkieSummaryPlan? plan;
  final int? purchasedSeats;
  final String? currency;
  final bool? couponApplied;
  final WalkieSummaryCoupon? coupon;
  final WalkieSummaryPricing? pricing;

  const WalkieOrderSummaryData({
    this.plan,
    this.purchasedSeats,
    this.currency,
    this.couponApplied,
    this.coupon,
    this.pricing,
  });

  factory WalkieOrderSummaryData.fromJson(Map<String, dynamic> json) {
    return WalkieOrderSummaryData(
      plan: json['plan'] is Map
          ? WalkieSummaryPlan.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      purchasedSeats: json['purchasedSeats'] is int
          ? json['purchasedSeats']
          : int.tryParse(json['purchasedSeats']?.toString() ?? ''),
      currency: json['currency']?.toString() ?? 'INR',
      couponApplied: json['couponApplied'] is bool
          ? json['couponApplied']
          : (json['couponApplied']?.toString() == 'true'),
      coupon: json['coupon'] is Map
          ? WalkieSummaryCoupon.fromJson(Map<String, dynamic>.from(json['coupon']))
          : null,
      pricing: json['pricing'] is Map
          ? WalkieSummaryPricing.fromJson(Map<String, dynamic>.from(json['pricing']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan?.toJson(),
        'purchasedSeats': purchasedSeats,
        'currency': currency,
        'couponApplied': couponApplied,
        'coupon': coupon?.toJson(),
        'pricing': pricing?.toJson(),
      };
}

class WalkieSummaryPlan {
  final int? id;
  final String? name;
  final String? planType;
  final String? billingInterval;
  final int? durationMonths;
  final num? pricePerMember;
  final String? currency;
  final int? minMembers;
  final int? maxMembers;

  const WalkieSummaryPlan({
    this.id,
    this.name,
    this.planType,
    this.billingInterval,
    this.durationMonths,
    this.pricePerMember,
    this.currency,
    this.minMembers,
    this.maxMembers,
  });

  factory WalkieSummaryPlan.fromJson(Map<String, dynamic> json) {
    return WalkieSummaryPlan(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      planType: json['planType']?.toString(),
      billingInterval: json['billingInterval']?.toString(),
      durationMonths: json['durationMonths'] is int
          ? json['durationMonths']
          : int.tryParse(json['durationMonths']?.toString() ?? ''),
      pricePerMember: json['pricePerMember'] is num
          ? json['pricePerMember']
          : num.tryParse(json['pricePerMember']?.toString() ?? ''),
      currency: json['currency']?.toString(),
      minMembers: json['minMembers'] is int
          ? json['minMembers']
          : int.tryParse(json['minMembers']?.toString() ?? ''),
      maxMembers: json['maxMembers'] is int
          ? json['maxMembers']
          : int.tryParse(json['maxMembers']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'planType': planType,
        'billingInterval': billingInterval,
        'durationMonths': durationMonths,
        'pricePerMember': pricePerMember,
        'currency': currency,
        'minMembers': minMembers,
        'maxMembers': maxMembers,
      };
}

class WalkieSummaryCoupon {
  final int? id;
  final String? code;
  final String? discountType;
  final num? discountValue;

  const WalkieSummaryCoupon({
    this.id,
    this.code,
    this.discountType,
    this.discountValue,
  });

  factory WalkieSummaryCoupon.fromJson(Map<String, dynamic> json) {
    return WalkieSummaryCoupon(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      code: json['code']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: json['discountValue'] is num
          ? json['discountValue']
          : num.tryParse(json['discountValue']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
      };
}

class WalkieSummaryPricing {
  final num? pricePerMember;
  final int? purchasedSeats;
  final num? subtotal;
  final num? discountAmount;
  final num? amountAfterDiscount;
  final num? gstPercent;
  final num? gstAmount;
  final num? finalAmount;
  final num? totalSaving;

  const WalkieSummaryPricing({
    this.pricePerMember,
    this.purchasedSeats,
    this.subtotal,
    this.discountAmount,
    this.amountAfterDiscount,
    this.gstPercent,
    this.gstAmount,
    this.finalAmount,
    this.totalSaving,
  });

  factory WalkieSummaryPricing.fromJson(Map<String, dynamic> json) {
    return WalkieSummaryPricing(
      pricePerMember: json['pricePerMember'] is num
          ? json['pricePerMember']
          : num.tryParse(json['pricePerMember']?.toString() ?? ''),
      purchasedSeats: json['purchasedSeats'] is int
          ? json['purchasedSeats']
          : int.tryParse(json['purchasedSeats']?.toString() ?? ''),
      subtotal: json['subtotal'] is num
          ? json['subtotal']
          : num.tryParse(json['subtotal']?.toString() ?? ''),
      discountAmount: json['discountAmount'] is num
          ? json['discountAmount']
          : num.tryParse(json['discountAmount']?.toString() ?? ''),
      amountAfterDiscount: json['amountAfterDiscount'] is num
          ? json['amountAfterDiscount']
          : num.tryParse(json['amountAfterDiscount']?.toString() ?? ''),
      gstPercent: json['gstPercent'] is num
          ? json['gstPercent']
          : num.tryParse(json['gstPercent']?.toString() ?? ''),
      gstAmount: json['gstAmount'] is num
          ? json['gstAmount']
          : num.tryParse(json['gstAmount']?.toString() ?? ''),
      finalAmount: json['finalAmount'] is num
          ? json['finalAmount']
          : num.tryParse(json['finalAmount']?.toString() ?? ''),
      totalSaving: json['totalSaving'] is num
          ? json['totalSaving']
          : num.tryParse(json['totalSaving']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'pricePerMember': pricePerMember,
        'purchasedSeats': purchasedSeats,
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'amountAfterDiscount': amountAfterDiscount,
        'gstPercent': gstPercent,
        'gstAmount': gstAmount,
        'finalAmount': finalAmount,
        'totalSaving': totalSaving,
      };
}
