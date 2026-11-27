import 'package:fgtracker/app/Core/constant/const_res.dart';

class BannerPlanPricing {
  final String currency;
  final double baseAmount;
  final double gstPercent;
  final double gstAmount;
  final double totalAmount;
  final int amountInMinorUnits;

  BannerPlanPricing({
    required this.currency,
    required this.baseAmount,
    required this.gstPercent,
    required this.gstAmount,
    required this.totalAmount,
    required this.amountInMinorUnits,
  });

  factory BannerPlanPricing.fromJson(Map<String, dynamic> json) {
    return BannerPlanPricing(
      currency: (json['currency'] ?? 'INR').toString().toUpperCase(),
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0.0,
      gstPercent: (json['gstPercent'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountInMinorUnits: (json['amountInMinorUnits'] as num?)?.toInt() ?? 0,
    );
  }

  String formatAmount(double value) {
    switch (currency) {
      case 'USD':
        return '\$${value.toStringAsFixed(2)}';
      case 'INR':
        return '₹${value.toStringAsFixed(2)}';
      case 'EUR':
        return '€${value.toStringAsFixed(2)}';
      case 'GBP':
        return '£${value.toStringAsFixed(2)}';
      default:
        return '$currency ${value.toStringAsFixed(2)}';
    }
  }
}

class BannerPlanModel {
  final int id;
  final String name;
  final String? description;
  final int durationDays;
  final int? slotNumber;
  final BannerPlanPricing pricing;

  BannerPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationDays,
    this.slotNumber,
    required this.pricing,
  });

  factory BannerPlanModel.fromJson(Map<String, dynamic> json) {
    return BannerPlanModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 7,
      slotNumber: (json['slotNumber'] as num?)?.toInt(),
      pricing: BannerPlanPricing.fromJson(
        (json['pricing'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class SlotAvailabilityItem {
  final int slotNumber;
  final bool planAllowed;
  final bool available;
  final String? bookedUntil;
  final String nextAvailableDate;

  SlotAvailabilityItem({
    required this.slotNumber,
    required this.planAllowed,
    required this.available,
    this.bookedUntil,
    required this.nextAvailableDate,
  });

  factory SlotAvailabilityItem.fromJson(Map<String, dynamic> json) {
    return SlotAvailabilityItem(
      slotNumber: (json['slotNumber'] as num).toInt(),
      planAllowed: json['planAllowed'] == true,
      available: json['available'] == true,
      bookedUntil: json['bookedUntil']?.toString(),
      nextAvailableDate: (json['nextAvailableDate'] ?? '').toString(),
    );
  }
}

class SlotAvailabilityResponse {
  final String startDate;
  final String endDate;
  final List<SlotAvailabilityItem> slots;

  SlotAvailabilityResponse({
    required this.startDate,
    required this.endDate,
    required this.slots,
  });

  factory SlotAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final range =
        (json['requestedRange'] as Map<String, dynamic>?) ?? const {};
    final rawSlots = (json['slots'] as List?) ?? const [];
    return SlotAvailabilityResponse(
      startDate: (range['startDate'] ?? '').toString(),
      endDate: (range['endDate'] ?? '').toString(),
      slots: rawSlots
          .whereType<Map<String, dynamic>>()
          .map(SlotAvailabilityItem.fromJson)
          .toList(),
    );
  }
}

class BannerOrderResponse {
  final int paymentId;
  final String orderId;
  final int bannerId;
  final int slotNumber;
  final BannerPlanPricing pricing;
  final String? customerName;
  final String? customerEmail;
  final String? customerContact;
  final String keyId;
  final String razorpayOrderId;
  final int amountMinorUnits;
  final String currency;

  BannerOrderResponse({
    required this.paymentId,
    required this.orderId,
    required this.bannerId,
    required this.slotNumber,
    required this.pricing,
    this.customerName,
    this.customerEmail,
    this.customerContact,
    required this.keyId,
    required this.razorpayOrderId,
    required this.amountMinorUnits,
    required this.currency,
  });

  factory BannerOrderResponse.fromJson(Map<String, dynamic> json) {
    final rzp = (json['razorpay'] as Map<String, dynamic>?) ?? const {};
    final cust = (json['customer'] as Map<String, dynamic>?) ?? const {};
    return BannerOrderResponse(
      paymentId: (json['paymentId'] as num).toInt(),
      orderId: (json['orderId'] ?? '').toString(),
      bannerId: (json['bannerId'] as num).toInt(),
      slotNumber: (json['slotNumber'] as num?)?.toInt() ?? 1,
      pricing: BannerPlanPricing.fromJson(
        (json['pricing'] as Map<String, dynamic>?) ?? const {},
      ),
      customerName: cust['name']?.toString(),
      customerEmail: cust['email']?.toString(),
      customerContact: cust['contact']?.toString(),
      keyId: (rzp['keyId'] ?? '').toString(),
      razorpayOrderId: (rzp['orderId'] ?? '').toString(),
      amountMinorUnits: (rzp['amount'] as num?)?.toInt() ?? 0,
      currency: (rzp['currency'] ?? 'INR').toString().toUpperCase(),
    );
  }
}

class UserBannerAdModel {
  final int id;
  final int slotNumber;
  final int? planId;
  final String title;
  final String? description;
  final String? targetUrl;
  final String? ctaText;
  final String status;
  final String? rejectionReason;
  final String? startsAt;
  final String? expiresAt;
  final int impressionsCount;
  final int clicksCount;
  final String? imageUrl;
  final String? planName;
  final int? planDurationDays;
  final String? paymentStatus;
  final double? totalPaid;
  final String? currency;

  UserBannerAdModel({
    required this.id,
    required this.slotNumber,
    this.planId,
    required this.title,
    this.description,
    this.targetUrl,
    this.ctaText,
    required this.status,
    this.rejectionReason,
    this.startsAt,
    this.expiresAt,
    required this.impressionsCount,
    required this.clicksCount,
    this.imageUrl,
    this.planName,
    this.planDurationDays,
    this.paymentStatus,
    this.totalPaid,
    this.currency,
  });

  factory UserBannerAdModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    final payment = json['latestPayment'] as Map<String, dynamic>?;
    return UserBannerAdModel(
      id: (json['id'] as num).toInt(),
      slotNumber: (json['slotNumber'] as num?)?.toInt() ?? 1,
      planId: (json['planId'] as num?)?.toInt(),
      title: (json['title'] ?? 'Sponsored Banner').toString(),
      description: json['description']?.toString(),
      targetUrl: json['targetUrl']?.toString(),
      ctaText: json['ctaText']?.toString(),
      status: (json['status'] ?? 'pending_review').toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      startsAt: json['startsAt']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
      impressionsCount: (json['impressionsCount'] as num?)?.toInt() ?? 0,
      clicksCount: (json['clicksCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      planName: plan?['name']?.toString(),
      planDurationDays: (plan?['durationDays'] as num?)?.toInt(),
      paymentStatus: payment?['status']?.toString(),
      totalPaid: double.tryParse('${payment?['totalAmount'] ?? ''}'),
      currency: payment?['currency']?.toString(),
    );
  }

  String get resolvedImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return '';
    final clean = imageUrl!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    final base = ConstRes.aImageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final path = clean.replaceFirst(RegExp(r'^/+'), '');
    return '$base/$path';
  }
}
