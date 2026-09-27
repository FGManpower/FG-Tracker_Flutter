import 'package:get/get.dart';

class WalkieCouponResponseModel {
  final bool? status;
  final String? message;
  final WalkieCouponData? data;

  const WalkieCouponResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieCouponResponseModel.fromJson(dynamic json) {
    if (json is! Map) return const WalkieCouponResponseModel();
    final map = Map<String, dynamic>.from(json);
    return WalkieCouponResponseModel(
      status: map['status'] as bool?,
      message: map['message']?.toString(),
      data: map['data'] is Map
          ? WalkieCouponData.fromJson(Map<String, dynamic>.from(map['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class WalkieCouponData {
  final WalkieCouponPlanInfo? plan;
  final int? purchasedSeats;
  final num? subtotal;
  final String? currency;
  final List<WalkieCouponItem> coupons;

  const WalkieCouponData({
    this.plan,
    this.purchasedSeats,
    this.subtotal,
    this.currency,
    this.coupons = const [],
  });

  factory WalkieCouponData.fromJson(Map<String, dynamic> json) {
    final list = <WalkieCouponItem>[];
    if (json['coupons'] is List) {
      for (final item in json['coupons']) {
        if (item is Map) {
          list.add(WalkieCouponItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return WalkieCouponData(
      plan: json['plan'] is Map
          ? WalkieCouponPlanInfo.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      purchasedSeats: json['purchasedSeats'] is int
          ? json['purchasedSeats']
          : int.tryParse(json['purchasedSeats']?.toString() ?? ''),
      subtotal: json['subtotal'] is num
          ? json['subtotal']
          : num.tryParse(json['subtotal']?.toString() ?? ''),
      currency: json['currency']?.toString() ?? 'INR',
      coupons: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan?.toJson(),
        'purchasedSeats': purchasedSeats,
        'subtotal': subtotal,
        'currency': currency,
        'coupons': coupons.map((e) => e.toJson()).toList(),
      };
}

class WalkieCouponPlanInfo {
  final int? id;
  final String? name;
  final String? planType;

  const WalkieCouponPlanInfo({
    this.id,
    this.name,
    this.planType,
  });

  factory WalkieCouponPlanInfo.fromJson(Map<String, dynamic> json) {
    return WalkieCouponPlanInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      planType: json['planType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'planType': planType,
      };
}

class WalkieCouponItem {
  final int? id;
  final String? code;
  final String? discountType;
  final num? discountValue;
  final String? applicablePlanType;
  final num? minOrderAmount;
  final num? maxDiscountAmount;
  final DateTime? expiresAt;
  final bool? eligible;
  final List<String> ineligibleReasons;
  final num? estimatedDiscount;

  const WalkieCouponItem({
    this.id,
    this.code,
    this.discountType,
    this.discountValue,
    this.applicablePlanType,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.expiresAt,
    this.eligible,
    this.ineligibleReasons = const [],
    this.estimatedDiscount,
  });

  factory WalkieCouponItem.fromJson(Map<String, dynamic> json) {
    final reasons = <String>[];
    if (json['ineligibleReasons'] is List) {
      for (final r in json['ineligibleReasons']) {
        if (r != null) reasons.add(r.toString());
      }
    }

    return WalkieCouponItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      code: json['code']?.toString(),
      discountType: json['discountType']?.toString(),
      discountValue: json['discountValue'] is num
          ? json['discountValue']
          : num.tryParse(json['discountValue']?.toString() ?? ''),
      applicablePlanType: json['applicablePlanType']?.toString(),
      minOrderAmount: json['minOrderAmount'] is num
          ? json['minOrderAmount']
          : num.tryParse(json['minOrderAmount']?.toString() ?? ''),
      maxDiscountAmount: json['maxDiscountAmount'] is num
          ? json['maxDiscountAmount']
          : num.tryParse(json['maxDiscountAmount']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      eligible: json['eligible'] == true,
      ineligibleReasons: reasons,
      estimatedDiscount: json['estimatedDiscount'] is num
          ? json['estimatedDiscount']
          : num.tryParse(json['estimatedDiscount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        'applicablePlanType': applicablePlanType,
        'minOrderAmount': minOrderAmount,
        'maxDiscountAmount': maxDiscountAmount,
        'expiresAt': expiresAt?.toIso8601String(),
        'eligible': eligible,
        'ineligibleReasons': ineligibleReasons,
        'estimatedDiscount': estimatedDiscount,
      };

  bool get isFixed => (discountType ?? '').toLowerCase() == 'fixed';
  bool get isPercentage =>
      (discountType ?? '').toLowerCase() == 'percentage' ||
      (discountType ?? '').toLowerCase() == 'percent';

  String get discountDescription {
    if (isFixed) {
      return "Flat ₹${discountValue?.toInt() ?? 0} OFF";
    } else if (isPercentage) {
      return "${discountValue?.toInt() ?? 0}% OFF";
    }
    return "${discountValue ?? 0} Discount";
  }

  String get formattedExpiry {
    if (expiresAt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "Valid till ${expiresAt!.day} ${months[expiresAt!.month - 1]} ${expiresAt!.year}";
  }

  String get formattedIneligibleReason {
    if (ineligibleReasons.isEmpty) return 'Not eligible for current plan';
    final raw = ineligibleReasons.first;
    switch (raw) {
      case 'COUPON_NOT_STARTED':
        return 'Coupon offer is not active yet';
      case 'COUPON_EXPIRED':
        return 'Coupon has expired';
      case 'MIN_ORDER_NOT_MET':
        return 'Minimum order amount not met';
      case 'PLAN_NOT_APPLICABLE':
        return 'Not applicable on this plan';
      default:
        return raw.replaceAll('_', ' ').toLowerCase().capitalizeFirst ?? raw;
    }
  }
}

class WalkieApplyCouponResponseModel {
  final bool? status;
  final String? message;
  final WalkieAppliedCouponData? data;

  const WalkieApplyCouponResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory WalkieApplyCouponResponseModel.fromJson(dynamic json) {
    if (json is! Map) return const WalkieApplyCouponResponseModel();
    final map = Map<String, dynamic>.from(json);
    return WalkieApplyCouponResponseModel(
      status: map['status'] as bool?,
      message: map['message']?.toString(),
      data: map['data'] is Map
          ? WalkieAppliedCouponData.fromJson(Map<String, dynamic>.from(map['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data?.toJson(),
      };
}

class WalkieAppliedCouponData {
  final WalkieAppliedPlanInfo? plan;
  final int? purchasedSeats;
  final String? currency;
  final bool? couponApplied;
  final WalkieAppliedCouponInfo? coupon;
  final WalkieAppliedPricingInfo? pricing;

  const WalkieAppliedCouponData({
    this.plan,
    this.purchasedSeats,
    this.currency,
    this.couponApplied,
    this.coupon,
    this.pricing,
  });

  factory WalkieAppliedCouponData.fromJson(Map<String, dynamic> json) {
    return WalkieAppliedCouponData(
      plan: json['plan'] is Map
          ? WalkieAppliedPlanInfo.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      purchasedSeats: json['purchasedSeats'] is int
          ? json['purchasedSeats']
          : int.tryParse(json['purchasedSeats']?.toString() ?? ''),
      currency: json['currency']?.toString() ?? 'INR',
      couponApplied: json['couponApplied'] == true,
      coupon: json['coupon'] is Map
          ? WalkieAppliedCouponInfo.fromJson(Map<String, dynamic>.from(json['coupon']))
          : null,
      pricing: json['pricing'] is Map
          ? WalkieAppliedPricingInfo.fromJson(Map<String, dynamic>.from(json['pricing']))
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

class WalkieAppliedPlanInfo {
  final int? id;
  final String? name;
  final String? planType;
  final String? billingInterval;
  final int? durationMonths;
  final num? pricePerMember;

  const WalkieAppliedPlanInfo({
    this.id,
    this.name,
    this.planType,
    this.billingInterval,
    this.durationMonths,
    this.pricePerMember,
  });

  factory WalkieAppliedPlanInfo.fromJson(Map<String, dynamic> json) {
    return WalkieAppliedPlanInfo(
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'planType': planType,
        'billingInterval': billingInterval,
        'durationMonths': durationMonths,
        'pricePerMember': pricePerMember,
      };
}

class WalkieAppliedCouponInfo {
  final int? id;
  final String? code;
  final String? discountType;
  final num? discountValue;

  const WalkieAppliedCouponInfo({
    this.id,
    this.code,
    this.discountType,
    this.discountValue,
  });

  factory WalkieAppliedCouponInfo.fromJson(Map<String, dynamic> json) {
    return WalkieAppliedCouponInfo(
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

  bool get isFixed => (discountType ?? '').toLowerCase() == 'fixed';
  bool get isPercentage =>
      (discountType ?? '').toLowerCase() == 'percentage' ||
      (discountType ?? '').toLowerCase() == 'percent';
}

class WalkieAppliedPricingInfo {
  final num? subtotal;
  final num? discountAmount;
  final num? taxableAmount;
  final num? gstPercent;
  final num? gstAmount;
  final num? finalAmount;
  final num? amountSaved;

  const WalkieAppliedPricingInfo({
    this.subtotal,
    this.discountAmount,
    this.taxableAmount,
    this.gstPercent,
    this.gstAmount,
    this.finalAmount,
    this.amountSaved,
  });

  factory WalkieAppliedPricingInfo.fromJson(Map<String, dynamic> json) {
    return WalkieAppliedPricingInfo(
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
      amountSaved: json['amountSaved'] is num
          ? json['amountSaved']
          : num.tryParse(json['amountSaved']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'taxableAmount': taxableAmount,
        'gstPercent': gstPercent,
        'gstAmount': gstAmount,
        'finalAmount': finalAmount,
        'amountSaved': amountSaved,
      };
}

