import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieTalkiePlanController extends GetxController {
  // 0 = Individual, 1 = Team Plan
  final RxInt selectedTab = 0.obs;

  // Individual Plan (0 = Monthly, 1 = Quarterly, 2 = Yearly)
  final RxInt selectedIndividualPlan = 0.obs;

  // Team Plan State
  final RxInt teamMemberCount = 5.obs;
  final RxInt selectedTeamDuration =
      0.obs; // 0 = Monthly, 1 = Quarterly, 2 = Yearly
  final RxnString appliedPromoCode = RxnString();
  final RxDouble promoDiscountPercent = 0.0.obs;

  // Quick Getters
  bool get isTeam => selectedTab.value == 1;

  String get durationName {
    switch (selectedTeamDuration.value) {
      case 0:
        return "Monthly";
      case 1:
        return "Quarterly";
      case 2:
        return "Yearly";
      default:
        return "Monthly";
    }
  }

  int get ratePerMember {
    switch (selectedTeamDuration.value) {
      case 0:
        return 500;
      case 1:
        return 2400;
      case 2:
        return 4020;
      default:
        return 500;
    }
  }

  int get originalTotal => teamMemberCount.value * ratePerMember;

  double get teamSavingsRate => 0.20;

  int get discountedTotal {
    int total = (originalTotal * (1 - teamSavingsRate)).round();
    if (promoDiscountPercent.value > 0) {
      total = (total * (1 - promoDiscountPercent.value)).round();
    }
    return total;
  }

  String get buttonText {
    if (isTeam) {
      return "Continue to Payment";
    }
    switch (selectedIndividualPlan.value) {
      case 0:
        return "Continue with Monthly Plan";
      case 1:
        return "Continue with Quarterly Plan";
      case 2:
        return "Continue with Yearly Plan";
      default:
        return "Continue with Monthly Plan";
    }
  }

  String get planTitle {
    if (isTeam) {
      return "Team Plan ($durationName)";
    }
    switch (selectedIndividualPlan.value) {
      case 0:
        return "Individual Plan (Monthly)";
      case 1:
        return "Individual Plan (Quarterly)";
      case 2:
        return "Individual Plan (Yearly)";
      default:
        return "Individual Plan (Monthly)";
    }
  }

  int get effectiveMemberCount => isTeam ? teamMemberCount.value : 1;

  // Actions
  void setTab(int tab) {
    selectedTab.value = tab;
  }

  void setIndividualPlan(int index) {
    selectedIndividualPlan.value = index;
  }

  void setTeamDuration(int index) {
    selectedTeamDuration.value = index;
  }

  void incrementMembers() {
    teamMemberCount.value++;
  }

  void decrementMembers() {
    if (teamMemberCount.value > 1) {
      teamMemberCount.value--;
    }
  }

  void setMemberCount(int count) {
    if (count >= 1) {
      teamMemberCount.value = count;
    }
  }

  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      Utils().fluttertoast("Please enter a valid code");
      return false;
    }

    appliedPromoCode.value = cleanCode;
    promoDiscountPercent.value = 0.10;
    Utils().fluttertoast("Promo code $cleanCode applied!");
    return true;
  }

  void removePromoCode() {
    appliedPromoCode.value = null;
    promoDiscountPercent.value = 0.0;
  }

  String formatCurrency(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  String getValidTillDate([int? duration]) {
    final int dur = duration ??
        (isTeam ? selectedTeamDuration.value : selectedIndividualPlan.value);
    final now = DateTime.now();
    DateTime expiryDate;
    if (dur == 0) {
      expiryDate = DateTime(now.year, now.month + 1, now.day);
    } else if (dur == 1) {
      expiryDate = DateTime(now.year, now.month + 3, now.day);
    } else {
      expiryDate = DateTime(now.year + 1, now.month, now.day);
    }
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
    return "${expiryDate.day} ${months[expiryDate.month - 1]} ${expiryDate.year}";
  }

  void openPurchaseSuccessScreen() {
    Get.to(() => WalkieTalkiePurchaseSuccessScreen(
          isTeam: isTeam,
          planTitle: planTitle,
          memberCount: effectiveMemberCount,
          validTill: getValidTillDate(),
        ));
  }
}

// Aliases for flexible naming
typedef WalkiePlanController = WalkieTalkiePlanController;
typedef walkie_talkie_plan_controller = WalkieTalkiePlanController;
