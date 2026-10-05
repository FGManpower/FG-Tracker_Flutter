import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkie_talkie_trial_controller.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalkieTalkiePurchaseSuccessController extends GetxController {
  // Observables
  final RxBool isTeam = true.obs;
  final RxString planTitle = "Team Plan (Monthly)".obs;
  final RxInt memberCount = 5.obs;
  final RxString validTill = "15 Oct 2026".obs;
  final RxString paymentId = "".obs;
  final RxnString orderId = RxnString();
  final RxDouble amountPaid = 0.0.obs;
  final RxString paymentMethod = "Razorpay (UPI / Card)".obs;
  final RxString transactionTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    refreshWalkieOverviewSilently();
  }

  /// Initialize state from constructor arguments or Get.arguments
  void initData({
    bool? isTeamVal,
    String? planTitleVal,
    int? memberCountVal,
    String? validTillVal,
    String? paymentIdVal,
    String? orderIdVal,
    num? amountPaidVal,
    String? paymentMethodVal,
    String? transactionTimeVal,
  }) {
    if (isTeamVal != null) isTeam.value = isTeamVal;
    if (planTitleVal != null && planTitleVal.isNotEmpty) {
      planTitle.value = planTitleVal;
    }
    if (memberCountVal != null) memberCount.value = memberCountVal;
    if (validTillVal != null && validTillVal.isNotEmpty) {
      validTill.value = validTillVal;
    }
    if (paymentIdVal != null && paymentIdVal.isNotEmpty) {
      paymentId.value = paymentIdVal;
    } else if (paymentId.value.isEmpty) {
      paymentId.value =
          "pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}";
    }
    if (orderIdVal != null) orderId.value = orderIdVal;
    if (amountPaidVal != null) amountPaid.value = amountPaidVal.toDouble();
    if (paymentMethodVal != null && paymentMethodVal.isNotEmpty) {
      paymentMethod.value = paymentMethodVal;
    }
    if (transactionTimeVal != null && transactionTimeVal.isNotEmpty) {
      transactionTime.value = transactionTimeVal;
    } else if (transactionTime.value.isEmpty) {
      transactionTime.value =
          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    }
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      initData(
        isTeamVal: args['isTeam'] as bool?,
        planTitleVal: args['planTitle']?.toString(),
        memberCountVal: args['memberCount'] as int?,
        validTillVal: args['validTill']?.toString(),
        paymentIdVal: args['paymentId']?.toString(),
        orderIdVal: args['orderId']?.toString(),
        amountPaidVal: args['amountPaid'] as num?,
        paymentMethodVal: args['paymentMethod']?.toString(),
        transactionTimeVal: args['transactionTime']?.toString(),
      );
    }
  }

  /// Refresh overview API in background so user profile & status is up-to-date
  Future<void> refreshWalkieOverviewSilently() async {
    try {
      if (Get.isRegistered<WalkieTalkieTrialController>()) {
        Get.find<WalkieTalkieTrialController>().fetchOverview(refresh: true);
      } else {
        await WalkieTalkieTrialService().getOverview();
      }
    } catch (_) {}
  }

  /// Copy payment ID to clipboard
  void copyPaymentId() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: paymentId.value));
    showCopiedSnackbar("Payment ID copied to clipboard!");
  }

  /// Copy / Share complete receipt text
  void shareReceipt() {
    HapticFeedback.lightImpact();
    final receiptText =
        "FG Tracker Payment Receipt\n"
        "Plan: ${planTitle.value}\n"
        "Amount: ₹${formatAmount(amountPaid.value > 0 ? amountPaid.value : 499)}\n"
        "Payment ID: ${paymentId.value}\n"
        "${orderId.value != null && orderId.value!.isNotEmpty ? 'Order ID: ${orderId.value}\n' : ''}"
        "Date: ${transactionTime.value}\n"
        "Payment Mode: ${paymentMethod.value}\n"
        "Status: Completed";

    Clipboard.setData(ClipboardData(text: receiptText));
    showCopiedSnackbar("Receipt details copied to clipboard!");
  }

  /// Navigate to Assign Members screen
  void navigateToAssignMembers() {
    try {
      Get.toNamed(Routes.WalkieGroupSelect);
    } catch (_) {
      Get.to(() => const WalkieGroupSelectScreen());
    }
  }

  /// Return to Home Screen
  void navigateToHome() {
    try {
      Get.offAllNamed(Routes.Home_Screen);
    } catch (_) {
      Get.back();
      Get.back();
    }
  }

  /// Amount formatting helper
  String formatAmount(num amount) {
    final isDecimal = amount is double && amount != amount.roundToDouble();
    if (isDecimal) {
      final parts = amount.toStringAsFixed(2).split('.');
      final int intPart = int.tryParse(parts[0]) ?? 0;
      return '${_formatInt(intPart)}.${parts[1]}';
    }
    return _formatInt(amount.round());
  }

  String _formatInt(int intAmount) {
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

  /// Custom Snackbar
  void showCopiedSnackbar(String msg) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0F172A),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      messageText: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4ADE80),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );
  }
}
