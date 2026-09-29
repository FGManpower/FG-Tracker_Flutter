import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_order_summary_screen.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkieTalkiePlanController extends GetxController {
  // 0 = Individual, 1 = Team Plan
  final RxInt selectedTab = 0.obs;

  // Loading states
  final RxBool isLoadingIndividual = false.obs;
  final RxBool isLoadingGroup = false.obs;
  final RxBool isLoadingCoupons = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Plans lists from API
  final RxList<WalkiePlanItem> individualPlans = <WalkiePlanItem>[].obs;
  final RxList<WalkiePlanItem> groupPlans = <WalkiePlanItem>[].obs;

  // Coupons from API
  final RxList<WalkieCouponItem> eligibleCoupons = <WalkieCouponItem>[].obs;
  final Rxn<WalkieCouponItem> selectedCoupon = Rxn<WalkieCouponItem>();
  final Rxn<WalkieAppliedCouponData> appliedCouponData =
      Rxn<WalkieAppliedCouponData>();
  final RxBool isApplyingCoupon = false.obs;
  final RxnString applyingCouponCode = RxnString();

  // Selected plan indices
  final RxInt selectedIndividualPlan = 0.obs;
  final RxInt selectedTeamDuration = 0.obs; // Index in groupPlans or fallback

  // Team Plan State
  final RxInt teamMemberCount = 1.obs;
  final RxnString appliedPromoCode = RxnString();
  final RxDouble promoDiscountPercent = 0.0.obs;
  final RxDouble fixedDiscountAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBothPlans();
  }

  // Quick Getters
  bool get isTeam => selectedTab.value == 1;

  bool get isLoading =>
      isTeam ? isLoadingGroup.value : isLoadingIndividual.value;

  List<WalkiePlanItem> get currentPlans =>
      isTeam ? groupPlans : individualPlans;

  bool get hasPlans => currentPlans.isNotEmpty;

  WalkiePlanItem? get activeIndividualPlan {
    if (individualPlans.isEmpty) return null;
    final idx =
        selectedIndividualPlan.value.clamp(0, individualPlans.length - 1);
    return individualPlans[idx];
  }

  WalkiePlanItem? get activeGroupPlan {
    if (groupPlans.isEmpty) return null;
    final idx = selectedTeamDuration.value.clamp(0, groupPlans.length - 1);
    return groupPlans[idx];
  }

  WalkiePlanItem? get activePlan =>
      isTeam ? activeGroupPlan : activeIndividualPlan;

  String get durationName {
    if (activeGroupPlan != null) {
      return activeGroupPlan!.durationLabel;
    }
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
    if (activeGroupPlan != null) {
      return activeGroupPlan!.safePrice;
    }
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

  num get currentSubtotal {
    if (appliedCouponData.value?.pricing?.subtotal != null) {
      return appliedCouponData.value!.pricing!.subtotal!;
    }
    return isTeam ? originalTotal : (activeIndividualPlan?.safePrice ?? 0);
  }

  // double get teamSavingsRate => 0.20; // commented out
  double get teamSavingsRate => 0.0;

  num get couponDiscountAmount {
    if (appliedCouponData.value?.pricing?.discountAmount != null) {
      return appliedCouponData.value!.pricing!.discountAmount!;
    }
    if (selectedCoupon.value != null) {
      final coupon = selectedCoupon.value!;
      if (coupon.isFixed) {
        return (coupon.discountValue ?? 0).clamp(0, currentSubtotal);
      } else if (coupon.isPercentage) {
        final pct = (coupon.discountValue ?? 0) / 100.0;
        num discount = (currentSubtotal * pct);
        if (coupon.maxDiscountAmount != null &&
            discount > coupon.maxDiscountAmount!) {
          discount = coupon.maxDiscountAmount!;
        }
        return discount.clamp(0, currentSubtotal);
      } else if (coupon.estimatedDiscount != null &&
          coupon.estimatedDiscount! > 0) {
        return coupon.estimatedDiscount!.clamp(0, currentSubtotal);
      }
    }
    if (promoDiscountPercent.value > 0) {
      return (currentSubtotal * promoDiscountPercent.value)
          .clamp(0, currentSubtotal);
    }
    if (fixedDiscountAmount.value > 0) {
      return fixedDiscountAmount.value.clamp(0, currentSubtotal);
    }
    return 0;
  }

  num get discountedTotal {
    if (appliedCouponData.value?.pricing?.finalAmount != null) {
      return appliedCouponData.value!.pricing!.finalAmount!;
    }
    final num base =
        isTeam ? (originalTotal * (1 - teamSavingsRate)) : currentSubtotal;
    final num total = base - couponDiscountAmount;
    return total < 0 ? 0 : total;
  }

  String get buttonText {
    if (isLoading) {
      return "Loading plans...";
    }
    if (!hasPlans) {
      return "No Plans Available";
    }
    if (isTeam) {
      return "Continue to Payment";
    }
    final plan = activeIndividualPlan;
    if (plan != null) {
      return "Continue with ${plan.displayTitle}";
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
      return activeGroupPlan?.displayTitle ?? "Team Plan ($durationName)";
    }
    return activeIndividualPlan?.displayTitle ?? "Individual Plan";
  }

  int get effectiveMemberCount => isTeam ? teamMemberCount.value : 1;

  // Actions
  void setTab(int tab) {
    selectedTab.value = tab;
    if (tab == 0) {
      fetchIndividualPlans();
    } else if (tab == 1) {
      fetchGroupPlans();
    }
  }

  void setIndividualPlan(int index) {
    selectedIndividualPlan.value = index;
  }

  void setTeamDuration(int index) {
    selectedTeamDuration.value = index;
  }

  void showTopWhiteMessage(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.09),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      messageText: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF5B4DF5),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 250),
    );
  }

  void incrementMembers() {
    final max = activeGroupPlan?.safeMaxMembers ?? 99;
    if (teamMemberCount.value < max) {
      teamMemberCount.value++;
      _reapplyCouponIfActive();
    } else {
      showTopWhiteMessage("Maximum limit of $max members reached");
    }
  }

  void decrementMembers() {
    final min = activeGroupPlan?.safeMinMembers ?? 1;
    if (teamMemberCount.value > min) {
      teamMemberCount.value--;
      _reapplyCouponIfActive();
    } else {
      showTopWhiteMessage("Minimum team size is $min member");
    }
  }

  void setMemberCount(int count) {
    final min = activeGroupPlan?.safeMinMembers ?? 1;
    final max = activeGroupPlan?.safeMaxMembers ?? 99;
    if (count >= min && count <= max) {
      teamMemberCount.value = count;
      _reapplyCouponIfActive();
    }
  }

  void _reapplyCouponIfActive() {
    if (appliedPromoCode.value != null && appliedPromoCode.value!.isNotEmpty) {
      applyCouponApi(appliedPromoCode.value!, isSilent: true);
    }
  }

  String _parseErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.error is SocketException) {
        return "No internet connection. Please check your network.";
      }
      if (error.response?.data is Map &&
          error.response?.data['message'] != null) {
        return error.response!.data['message'].toString();
      }
      return "Unable to connect to server. Please try again.";
    }
    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    }
    final str = error.toString().toLowerCase();
    if (str.contains("socket") ||
        str.contains("internet") ||
        str.contains("connection") ||
        str.contains("network") ||
        str.contains("failed host lookup")) {
      return "No internet connection. Please check your network.";
    }
    return "Unable to load plans. Please try again.";
  }

  Future<void> fetchBothPlans() async {
    errorMessage.value = '';
    await Future.wait([
      fetchIndividualPlans(),
      fetchGroupPlans(),
    ]);
  }

  Future<void> fetchIndividualPlans() async {
    try {
      isLoadingIndividual.value = true;
      final res = await WalkiePlanRepo.getPlans(planType: "individual");
      if (res.status == true && res.data?.plans != null) {
        individualPlans.assignAll(res.data!.plans!);
        if (selectedIndividualPlan.value >= individualPlans.length) {
          selectedIndividualPlan.value = 0;
        }
        if (errorMessage.value.isNotEmpty && individualPlans.isNotEmpty) {
          errorMessage.value = '';
        }
      } else {
        if (individualPlans.isEmpty) {
          errorMessage.value = res.message ?? "Unable to load plans. Please try again.";
        }
      }
    } catch (e) {
      debugPrint("Error fetching individual plans: $e");
      if (individualPlans.isEmpty && (selectedTab.value == 0 || groupPlans.isEmpty)) {
        errorMessage.value = _parseErrorMessage(e);
      }
    } finally {
      isLoadingIndividual.value = false;
    }
  }

  Future<void> fetchGroupPlans() async {
    try {
      isLoadingGroup.value = true;
      final res = await WalkiePlanRepo.getPlans(planType: "group");
      if (res.status == true && res.data?.plans != null) {
        groupPlans.assignAll(res.data!.plans!);
        if (selectedTeamDuration.value >= groupPlans.length) {
          selectedTeamDuration.value = 0;
        }
        if (groupPlans.isNotEmpty) {
          final first = groupPlans.first;
          final min = first.safeMinMembers;
          final max = first.safeMaxMembers;
          if (teamMemberCount.value < min) {
            teamMemberCount.value = min;
          } else if (teamMemberCount.value > max) {
            teamMemberCount.value = max;
          }
        }
        if (errorMessage.value.isNotEmpty && groupPlans.isNotEmpty) {
          errorMessage.value = '';
        }
      } else {
        if (groupPlans.isEmpty && selectedTab.value == 1) {
          errorMessage.value = res.message ?? "Unable to load plans. Please try again.";
        }
      }
    } catch (e) {
      debugPrint("Error fetching group plans: $e");
      if (groupPlans.isEmpty && (selectedTab.value == 1 || individualPlans.isEmpty)) {
        errorMessage.value = _parseErrorMessage(e);
      }
    } finally {
      isLoadingGroup.value = false;
    }
  }

  Future<void> fetchEligibleCoupons() async {
    if (isLoadingCoupons.value) return;
    try {
      isLoadingCoupons.value = true;
      final plan = activePlan;
      final planId = plan?.id ?? (isTeam ? 4 : 1);
      final seats = isTeam ? teamMemberCount.value : 1;

      final res = await WalkiePlanRepo.getEligibleCoupons(
        planId: planId,
        purchasedSeats: seats,
      );
      if (res.status == true && res.data != null) {
        eligibleCoupons.assignAll(res.data!.coupons);
      }
    } catch (e) {
      debugPrint("Error fetching eligible coupons: $e");
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  Future<bool> applyCouponApi(String code, {bool isSilent = false}) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      if (!isSilent) showTopWhiteMessage("Please enter a valid coupon code");
      return false;
    }

    final plan = activePlan;
    final planId = plan?.id ?? (isTeam ? 4 : 1);
    final seats = isTeam ? teamMemberCount.value : 1;

    try {
      isApplyingCoupon.value = true;
      applyingCouponCode.value = cleanCode;
      final res = await WalkiePlanRepo.applyCoupon(
        planId: planId,
        purchasedSeats: seats,
        couponCode: cleanCode,
      );

      if (res.status == true && res.data != null) {
        appliedCouponData.value = res.data;
        appliedPromoCode.value = res.data?.coupon?.code ?? cleanCode;
        promoDiscountPercent.value = 0.0;
        fixedDiscountAmount.value = 0.0;

        final match = eligibleCoupons.firstWhereOrNull(
          (c) => (c.code ?? '').trim().toUpperCase() == cleanCode,
        );
        if (match != null) {
          selectedCoupon.value = match;
        }

        if (!isSilent) {
          final saved = res.data?.pricing?.amountSaved ??
              res.data?.pricing?.discountAmount;
          if (saved != null && saved > 0) {
            showTopWhiteMessage(
                "Coupon applied! You save ₹${formatCurrency(saved)}");
          } else {
            showTopWhiteMessage(res.message ?? "Coupon applied successfully!");
          }
        }
        return true;
      } else {
        if (!isSilent) {
          showTopWhiteMessage(res.message ?? "Failed to apply coupon");
        }
        return false;
      }
    } catch (e) {
      debugPrint("Error applying coupon: $e");
      if (!isSilent) {
        showTopWhiteMessage(_parseErrorMessage(e));
      }
      return false;
    } finally {
      isApplyingCoupon.value = false;
      applyingCouponCode.value = null;
    }
  }

  Future<bool> applyCoupon(WalkieCouponItem coupon) async {
    if (coupon.eligible != true) {
      showTopWhiteMessage(coupon.formattedIneligibleReason);
      return false;
    }
    final String cleanCode = (coupon.code ?? '').trim().toUpperCase();
    final bool ok = await applyCouponApi(cleanCode, isSilent: true);
    if (ok) {
      final saved = appliedCouponData.value?.pricing?.amountSaved ??
          appliedCouponData.value?.pricing?.discountAmount;
      if (saved != null && saved > 0) {
        showTopWhiteMessage("Coupon applied! You save ₹${formatCurrency(saved)}");
      } else {
        showTopWhiteMessage("Coupon '$cleanCode' applied successfully!");
      }
      return true;
    }

    // Fallback if backend API is not responding/fails: Apply directly using coupon definition
    selectedCoupon.value = coupon;
    appliedPromoCode.value = cleanCode;
    if (coupon.isPercentage) {
      promoDiscountPercent.value = ((coupon.discountValue ?? 0) / 100.0);
      fixedDiscountAmount.value = 0.0;
    } else if (coupon.isFixed) {
      fixedDiscountAmount.value = (coupon.discountValue ?? 0).toDouble();
      promoDiscountPercent.value = 0.0;
    }
    final num saved = couponDiscountAmount;
    if (saved > 0) {
      showTopWhiteMessage("Coupon applied! You save ₹${formatCurrency(saved)}");
    } else {
      showTopWhiteMessage("Coupon '$cleanCode' applied successfully!");
    }
    appliedPromoCode.refresh();
    selectedCoupon.refresh();
    teamMemberCount.refresh();
    update();
    return true;
  }

  Future<bool> applyPromoCode(String code) async {
    final String cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      showTopWhiteMessage("Please enter a valid coupon code");
      return false;
    }
    final match = eligibleCoupons.firstWhereOrNull(
      (c) => (c.code ?? '').trim().toUpperCase() == cleanCode,
    );
    if (match != null) {
      return applyCoupon(match);
    }
    return applyCouponApi(cleanCode);
  }

  void removePromoCode() {
    appliedCouponData.value = null;
    selectedCoupon.value = null;
    appliedPromoCode.value = null;
    promoDiscountPercent.value = 0.0;
    fixedDiscountAmount.value = 0.0;
    appliedCouponData.refresh();
    appliedPromoCode.refresh();
    selectedCoupon.refresh();
    teamMemberCount.refresh();
    update();
    showTopWhiteMessage("Coupon removed");
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return "0";
    if (amount is num) {
      if (amount % 1 == 0) {
        return _formatInt(amount.toInt());
      } else {
        final parts = amount.toStringAsFixed(2).split('.');
        return "${_formatInt(int.parse(parts[0]))}.${parts[1]}";
      }
    }
    final parsed = num.tryParse(amount.toString());
    if (parsed != null) return formatCurrency(parsed);
    return amount.toString();
  }

  String _formatInt(int amount) {
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
    int months = 1;
    final plan = activePlan;
    if (plan?.durationMonths != null && plan!.durationMonths! > 0) {
      months = plan.durationMonths!;
    } else if (duration != null) {
      months = duration == 0 ? 1 : (duration == 1 ? 3 : 12);
    }

    final now = DateTime.now();
    final expiryDate = DateTime(now.year, now.month + months, now.day);
    const monthNames = [
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
    return "${expiryDate.day} ${monthNames[expiryDate.month - 1]} ${expiryDate.year}";
  }

  void openPaymentScreen() {
    if (!hasPlans || isLoading) return;

    final order = WalkiePaymentOrderModel(
      plan: activePlan,
      isTeam: isTeam,
      planTitle: planTitle,
      durationName: durationName,
      durationMonths: activePlan?.durationMonths ??
          (isTeam
              ? (selectedTeamDuration.value == 0
                  ? 1
                  : (selectedTeamDuration.value == 1 ? 3 : 12))
              : 1),
      memberCount: effectiveMemberCount,
      ratePerMember: ratePerMember,
      planAmount: originalTotal,
      couponDiscount: couponDiscountAmount,
      appliedCouponCode: appliedPromoCode.value,
      totalPayable: discountedTotal,
      validTill: getValidTillDate(),
    );

    Get.to(() => WalkieOrderSummaryScreen(order: order));
  }

  void openPurchaseSuccessScreen() {
    openPaymentScreen();
  }
}

// Aliases for flexible naming
typedef WalkiePlanController = WalkieTalkiePlanController;
typedef walkie_talkie_plan_controller = WalkieTalkiePlanController;
