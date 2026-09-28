import 'package:fgtracker/app/Model/walkie_plan_model.dart';

class WalkiePaymentOrderModel {
  final WalkiePlanItem? plan;
  final bool isTeam;
  final String planTitle;
  final String durationName;
  final int durationMonths;
  final int memberCount;
  final int ratePerMember;
  final num planAmount;
  final num couponDiscount;
  final String? appliedCouponCode;
  final num totalPayable;
  final String validTill;

  WalkiePaymentOrderModel({
    this.plan,
    this.isTeam = true,
    this.planTitle = "Team Plan (Monthly)",
    this.durationName = "Monthly",
    this.durationMonths = 1,
    this.memberCount = 5,
    this.ratePerMember = 500,
    this.planAmount = 2500,
    this.couponDiscount = 500,
    this.appliedCouponCode,
    this.totalPayable = 2000,
    this.validTill = "15 Oct 2026",
  });

  WalkiePaymentOrderModel copyWith({
    WalkiePlanItem? plan,
    bool? isTeam,
    String? planTitle,
    String? durationName,
    int? durationMonths,
    int? memberCount,
    int? ratePerMember,
    num? planAmount,
    num? couponDiscount,
    String? appliedCouponCode,
    num? totalPayable,
    String? validTill,
  }) {
    return WalkiePaymentOrderModel(
      plan: plan ?? this.plan,
      isTeam: isTeam ?? this.isTeam,
      planTitle: planTitle ?? this.planTitle,
      durationName: durationName ?? this.durationName,
      durationMonths: durationMonths ?? this.durationMonths,
      memberCount: memberCount ?? this.memberCount,
      ratePerMember: ratePerMember ?? this.ratePerMember,
      planAmount: planAmount ?? this.planAmount,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      totalPayable: totalPayable ?? this.totalPayable,
      validTill: validTill ?? this.validTill,
    );
  }
}
