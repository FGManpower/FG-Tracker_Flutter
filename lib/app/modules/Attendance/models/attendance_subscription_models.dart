class AttendancePlanModel {
  final int id;
  final String name;
  final String? description;
  final String billingInterval;
  final int durationMonths;
  final double pricePerMember;
  final String currency;
  final int minMembers;
  final int? maxMembers;

  AttendancePlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.billingInterval,
    required this.durationMonths,
    required this.pricePerMember,
    required this.currency,
    required this.minMembers,
    this.maxMembers,
  });

  factory AttendancePlanModel.fromJson(Map<String, dynamic> json) {
    return AttendancePlanModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      billingInterval: (json['billingInterval'] ?? 'monthly').toString(),
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 1,
      pricePerMember: double.tryParse('${json['pricePerMember'] ?? 0}') ?? 0.0,
      currency: (json['currency'] ?? 'INR').toString().toUpperCase(),
      minMembers: (json['minMembers'] as num?)?.toInt() ?? 1,
      maxMembers: (json['maxMembers'] as num?)?.toInt(),
    );
  }
}

class AttendancePricingModel {
  final double pricePerMember;
  final int purchasedSeats;
  final double subtotal;
  final double discountAmount;
  final double amountAfterDiscount;
  final String taxName;
  final bool isExport;
  final double gstPercent;
  final double gstAmount;
  final double finalAmount;

  AttendancePricingModel({
    required this.pricePerMember,
    required this.purchasedSeats,
    required this.subtotal,
    required this.discountAmount,
    required this.amountAfterDiscount,
    required this.taxName,
    required this.isExport,
    required this.gstPercent,
    required this.gstAmount,
    required this.finalAmount,
  });

  factory AttendancePricingModel.fromJson(Map<String, dynamic> json) {
    return AttendancePricingModel(
      pricePerMember: double.tryParse('${json['pricePerMember'] ?? 0}') ?? 0.0,
      purchasedSeats: (json['purchasedSeats'] as num?)?.toInt() ?? 1,
      subtotal: double.tryParse('${json['subtotal'] ?? 0}') ?? 0.0,
      discountAmount: double.tryParse('${json['discountAmount'] ?? 0}') ?? 0.0,
      amountAfterDiscount:
          double.tryParse('${json['amountAfterDiscount'] ?? 0}') ?? 0.0,
      taxName: (json['taxName'] ?? 'GST').toString(),
      isExport: json['isExport'] == true,
      gstPercent: double.tryParse('${json['gstPercent'] ?? 0}') ?? 0.0,
      gstAmount: double.tryParse('${json['gstAmount'] ?? 0}') ?? 0.0,
      finalAmount: double.tryParse('${json['finalAmount'] ?? 0}') ?? 0.0,
    );
  }
}

class AttendanceOrderSummaryModel {
  final AttendancePlanModel plan;
  final int purchasedSeats;
  final String currency;
  final bool couponApplied;
  final String? couponCode;
  final AttendancePricingModel pricing;

  AttendanceOrderSummaryModel({
    required this.plan,
    required this.purchasedSeats,
    required this.currency,
    required this.couponApplied,
    this.couponCode,
    required this.pricing,
  });

  factory AttendanceOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] as Map<String, dynamic>?;
    return AttendanceOrderSummaryModel(
      plan: AttendancePlanModel.fromJson(
        (json['plan'] as Map<String, dynamic>?) ?? const {},
      ),
      purchasedSeats: (json['purchasedSeats'] as num?)?.toInt() ?? 1,
      currency: (json['currency'] ?? 'INR').toString().toUpperCase(),
      couponApplied: json['couponApplied'] == true,
      couponCode: coupon?['code']?.toString(),
      pricing: AttendancePricingModel.fromJson(
        (json['pricing'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class AttendanceSubscriptionStatusModel {
  final bool allowed;
  final String accessType;
  final bool hasActiveSubscription;
  final bool canStartTrial;
  final bool canCreateAttendance;
  final int groupMemberCount;
  final int seatsUsed;
  final int seatsRemaining;
  final List<int> assignedMemberIds;
  final int? subscriptionId;
  final String? planName;
  final int purchasedSeats;
  final String? expiresAt;

  AttendanceSubscriptionStatusModel({
    required this.allowed,
    required this.accessType,
    required this.hasActiveSubscription,
    required this.canStartTrial,
    required this.canCreateAttendance,
    required this.groupMemberCount,
    required this.seatsUsed,
    required this.seatsRemaining,
    required this.assignedMemberIds,
    this.subscriptionId,
    this.planName,
    this.purchasedSeats = 0,
    this.expiresAt,
  });

  factory AttendanceSubscriptionStatusModel.fromJson(
      Map<String, dynamic> json) {
    final sub = json['subscription'] as Map<String, dynamic>?;
    final trial = json['trial'] as Map<String, dynamic>?;
    final rawIds = (json['assignedMemberIds'] as List?) ?? const [];
    return AttendanceSubscriptionStatusModel(
      allowed: json['allowed'] == true,
      accessType: (json['accessType'] ?? 'none').toString(),
      hasActiveSubscription: json['hasActiveSubscription'] == true,
      canStartTrial: json['canStartTrial'] == true,
      canCreateAttendance: json['canCreateAttendance'] == true,
      groupMemberCount: (json['groupMemberCount'] as num?)?.toInt() ?? 1,
      seatsUsed: (json['seatsUsed'] as num?)?.toInt() ?? 0,
      seatsRemaining: (json['seatsRemaining'] as num?)?.toInt() ?? 0,
      assignedMemberIds: rawIds.map((e) => (e as num).toInt()).toList(),
      subscriptionId: (sub?['id'] as num?)?.toInt(),
      planName: sub?['planName']?.toString(),
      purchasedSeats: (sub?['purchasedSeats'] as num?)?.toInt() ?? 0,
      expiresAt: (sub?['expiresAt'] ?? trial?['expiresAt'])?.toString(),
    );
  }
}

class AttendancePaymentOrderModel {
  final int paymentId;
  final String orderId;
  final String razorpayKeyId;
  final String razorpayOrderId;
  final int amountMinor;
  final String currency;
  final String customerName;
  final String customerEmail;
  final String customerContact;
  final AttendancePricingModel pricing;

  AttendancePaymentOrderModel({
    required this.paymentId,
    required this.orderId,
    required this.razorpayKeyId,
    required this.razorpayOrderId,
    required this.amountMinor,
    required this.currency,
    required this.customerName,
    required this.customerEmail,
    required this.customerContact,
    required this.pricing,
  });

  factory AttendancePaymentOrderModel.fromJson(Map<String, dynamic> json) {
    final payment = (json['payment'] as Map<String, dynamic>?) ?? const {};
    final rzp = (json['razorpay'] as Map<String, dynamic>?) ?? const {};
    final cust = (json['customer'] as Map<String, dynamic>?) ?? const {};
    final pricing = (json['pricing'] as Map<String, dynamic>?) ?? const {};
    return AttendancePaymentOrderModel(
      paymentId: (payment['id'] as num).toInt(),
      orderId: (payment['orderId'] ?? '').toString(),
      razorpayKeyId: (rzp['keyId'] ?? '').toString(),
      razorpayOrderId: (rzp['orderId'] ?? '').toString(),
      amountMinor: (rzp['amount'] as num).toInt(),
      currency: (rzp['currency'] ?? 'INR').toString().toUpperCase(),
      customerName: (cust['name'] ?? '').toString(),
      customerEmail: (cust['email'] ?? '').toString(),
      customerContact: (cust['contact'] ?? '').toString(),
      pricing: AttendancePricingModel.fromJson(pricing),
    );
  }
}

String formatAttendanceCurrency(num amount, String currency) {
  final cur = currency.trim().toUpperCase();
  switch (cur) {
    case 'INR':
      return '₹${amount.toStringAsFixed(2)}';
    case 'USD':
      return '\$${amount.toStringAsFixed(2)}';
    case 'EUR':
      return '€${amount.toStringAsFixed(2)}';
    case 'GBP':
      return '£${amount.toStringAsFixed(2)}';
    default:
      return '$cur ${amount.toStringAsFixed(2)}';
  }
}
