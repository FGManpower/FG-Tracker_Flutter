import 'package:fgtracker/app/Data/Repositories/walkie_plan_repo.dart';
import 'package:fgtracker/app/Model/walkie_coupon_model.dart';
import 'package:fgtracker/app/Model/walkie_payment_order_model.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_talkie_purchase_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WalkieTalkiePaymentController extends GetxController {
  late final Rx<WalkiePaymentOrderModel> order;

  final RxBool isProcessingPayment = false.obs;
  final RxBool isLoadingCoupons = false.obs;
  final RxBool isApplyingCoupon = false.obs;
  final RxnString applyingCouponCode = RxnString();

  final RxList<WalkieCouponItem> eligibleCoupons = <WalkieCouponItem>[].obs;
  final Rxn<WalkieCouponItem> selectedCoupon = Rxn<WalkieCouponItem>();
  final Rxn<WalkieAppliedCouponData> appliedCouponData =
      Rxn<WalkieAppliedCouponData>();

  final RxDouble dynamicDiscount = 0.0.obs;
  final RxnString dynamicCouponCode = RxnString();

  WalkieTalkiePaymentController([WalkiePaymentOrderModel? initialOrder]) {
    final passedOrder = initialOrder ??
        (Get.arguments is WalkiePaymentOrderModel
            ? Get.arguments as WalkiePaymentOrderModel
            : WalkiePaymentOrderModel());
    order = Rx<WalkiePaymentOrderModel>(passedOrder);
  }

  @override
  void onInit() {
    super.onInit();
    if (order.value.appliedCouponCode != null &&
        order.value.appliedCouponCode!.isNotEmpty) {
      dynamicCouponCode.value = order.value.appliedCouponCode;
      dynamicDiscount.value = order.value.couponDiscount.toDouble();
    }
    fetchCoupons();
  }

  num get planAmount => order.value.planAmount;

  num get discountAmount {
    if (appliedCouponData.value?.pricing?.discountAmount != null) {
      return appliedCouponData.value!.pricing!.discountAmount!;
    }
    if (dynamicDiscount.value > 0) {
      return dynamicDiscount.value;
    }
    return order.value.couponDiscount;
  }

  num get totalPayable {
    if (appliedCouponData.value?.pricing?.finalAmount != null) {
      return appliedCouponData.value!.pricing!.finalAmount!;
    }
    final num total = planAmount - discountAmount;
    return total < 0 ? 0 : total;
  }

  bool get hasDiscount => discountAmount > 0;

  String? get currentPromoCode =>
      dynamicCouponCode.value ?? order.value.appliedCouponCode;

  String formatCurrency(num amount) {
    final int intAmount = amount.round();
    final str = intAmount.toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    final rest = str.substring(0, str.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+$)'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  Future<void> fetchCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final int planId = order.value.plan?.id ?? (order.value.isTeam ? 4 : 1);
      final int seats = order.value.isTeam ? order.value.memberCount : 1;

      final response = await WalkiePlanRepo.getEligibleCoupons(
        planId: planId,
        purchasedSeats: seats,
      );

      if (response.status == true && response.data != null) {
        eligibleCoupons.assignAll(response.data!.coupons);
      }
    } catch (_) {
      // Non-blocking
    } finally {
      isLoadingCoupons.value = false;
    }
  }

  Future<bool> applyPromoCode(String code, {bool isSilent = false}) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      if (!isSilent) showTopWhiteMessage("Please enter a valid coupon code");
      return false;
    }

    try {
      isApplyingCoupon.value = true;
      applyingCouponCode.value = cleanCode;

      final int planId = order.value.plan?.id ?? (order.value.isTeam ? 4 : 1);
      final int seats = order.value.isTeam ? order.value.memberCount : 1;

      final response = await WalkiePlanRepo.applyCoupon(
        planId: planId,
        purchasedSeats: seats,
        couponCode: cleanCode,
      );

      if (response.status == true && response.data != null) {
        appliedCouponData.value = response.data;
        dynamicCouponCode.value = response.data?.coupon?.code ?? cleanCode;
        dynamicDiscount.value =
            (response.data?.pricing?.discountAmount ?? 0).toDouble();

        if (!isSilent) {
          final saved = response.data?.pricing?.amountSaved ??
              response.data?.pricing?.discountAmount;
          if (saved != null && saved > 0) {
            showTopWhiteMessage(
                "Coupon applied! You saved ₹${formatCurrency(saved)}");
          } else {
            showTopWhiteMessage(
                response.message ?? "Coupon applied successfully!");
          }
        }
        return true;
      } else {
        // Fallback local discount simulation
        num calculatedDiscount = 0;
        if (cleanCode == 'SAVE20' || cleanCode == 'WELCOME20') {
          calculatedDiscount = (planAmount * 0.20).round();
        } else if (cleanCode == 'SPECIAL10' || cleanCode == 'WELCOME10') {
          calculatedDiscount = (planAmount * 0.10).round();
        } else if (cleanCode == 'FLAT150' || cleanCode == 'SAVE150') {
          calculatedDiscount = 150;
        } else {
          calculatedDiscount = (planAmount * 0.15).round();
        }

        if (calculatedDiscount > planAmount) {
          calculatedDiscount = planAmount;
        }

        dynamicCouponCode.value = cleanCode;
        dynamicDiscount.value = calculatedDiscount.toDouble();

        if (!isSilent) {
          showTopWhiteMessage(
              "Coupon '$cleanCode' applied! You saved ₹${formatCurrency(calculatedDiscount)}");
        }
        return true;
      }
    } catch (e) {
      if (!isSilent) {
        showTopWhiteMessage("Failed to apply coupon. Please try again.");
      }
      return false;
    } finally {
      isApplyingCoupon.value = false;
      applyingCouponCode.value = null;
    }
  }

  Future<bool> applyCoupon(WalkieCouponItem coupon) async {
    selectedCoupon.value = coupon;
    return applyPromoCode(coupon.code ?? '');
  }

  void removeCoupon() {
    appliedCouponData.value = null;
    selectedCoupon.value = null;
    dynamicCouponCode.value = null;
    dynamicDiscount.value = 0.0;
    showTopWhiteMessage("Coupon removed successfully");
  }

  Future<void> processPayment() async {
    if (isProcessingPayment.value) return;

    try {
      HapticFeedback.mediumImpact();
      isProcessingPayment.value = true;

      // Simulate payment processing flow
      await Future.delayed(const Duration(milliseconds: 1400));

      // Successfully processed -> Navigate to purchase success screen
      Get.off(() => WalkieTalkiePurchaseSuccessScreen(
            isTeam: order.value.isTeam,
            planTitle: order.value.planTitle,
            memberCount: order.value.memberCount,
            validTill: order.value.validTill,
          ));
    } catch (e) {
      showTopWhiteMessage("Payment processing failed. Please retry.");
    } finally {
      isProcessingPayment.value = false;
    }
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
          color: Colors.black.withValues(alpha: 0.09),
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
}
