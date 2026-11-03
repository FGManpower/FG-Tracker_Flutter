import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/package_pricing_repo.dart';
import 'package:fgtracker/app/Model/package_pricing_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Pricing details for one module (Attendance, Safe Zone + Route,
/// Live Tracking, …). Opened with arguments:
/// `{'moduleKey': String, 'package': PackageItem?}`
///
/// Flow: pick tier → pick duration → set members → Buy
/// → create-order → Razorpay → verify → back to the list with `true`.
class PackagePlanDetailsController extends GetxController {
  String moduleKey = '';

  /// Card data from the list screen, so the header shows while plans load
  final Rxn<PackageItem> package = Rxn<PackageItem>();
  final Rxn<PackagePlanDetails> details = Rxn<PackagePlanDetails>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedTier = 0.obs;
  final RxInt selectedDuration = 0.obs;
  final RxInt members = 1.obs;

  final RxBool isPaying = false.obs;

  late final Razorpay _razorpay;
  int? _paymentId;
  String? _razorpayOrderId;

  // ---------------------------------------------------------------------------
  // Getters used by the view
  // ---------------------------------------------------------------------------

  String get title =>
      details.value?.title ?? package.value?.title ?? 'Package';

  String? get description =>
      details.value?.description ?? package.value?.tagline;

  String get currency =>
      details.value?.currency ?? package.value?.currency ?? 'INR';

  List<PackageTier> get tiers => details.value?.tiers ?? const [];

  PackageTier? get tier {
    if (tiers.isEmpty) return null;
    return tiers[selectedTier.value.clamp(0, tiers.length - 1)];
  }

  List<PackageDuration> get durations => tier?.durations ?? const [];

  PackageDuration? get duration {
    final list = durations;
    if (list.isEmpty) return null;
    return list[selectedDuration.value.clamp(0, list.length - 1)];
  }

  bool get showMemberPicker => tier?.allowsMultipleMembers ?? false;

  /// Module-level features first, then the selected tier's
  List<PackageFeature> get features => [
        ...?details.value?.features,
        ...?tier?.features,
      ];

  num get gstPercent => details.value?.gstPercent ?? 0;

  bool get priceIncludesGst => details.value?.priceIncludesGst ?? true;

  num get subtotal => (duration?.pricePerMember ?? 0) * members.value;

  num get gstAmount =>
      priceIncludesGst || gstPercent <= 0 ? 0 : subtotal * gstPercent / 100;

  num get total => subtotal + gstAmount;

  bool get isSubscribed => package.value?.isSubscribed ?? false;

  bool get canBuy =>
      !isLoading.value &&
      !isPaying.value &&
      duration?.planId != null &&
      (package.value?.isAvailable ?? true);

  String get buyLabel => isSubscribed ? 'Renew Plan' : 'Buy Now';

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, (_) => isPaying.value = false);

    final args = Get.arguments;
    if (args is Map) {
      if (args['package'] is PackageItem) {
        package.value = args['package'] as PackageItem;
      }
      moduleKey = args['moduleKey']?.toString() ??
          package.value?.moduleKey ??
          '';
    }
    fetchPlans();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  Future<void> fetchPlans() async {
    if (moduleKey.isEmpty) {
      errorMessage.value = 'Package not found.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await PackagePricingRepo.getPlans(moduleKey);
      final data = res.data;
      if (res.status && data != null && data.tiers.isNotEmpty) {
        details.value = data;
        _selectDefaults();
      } else {
        errorMessage.value = res.message ??
            'No plans are available for this package right now.';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PackagePlanDetails] fetch failed: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _selectDefaults() {
    final recommended = tiers.indexWhere((t) => t.isRecommended);
    selectedTier.value = recommended >= 0 ? recommended : 0;
    _selectDefaultDuration();
    members.value = tier?.minMembers ?? 1;
  }

  void _selectDefaultDuration({String? keepInterval}) {
    final list = durations;
    if (list.isEmpty) {
      selectedDuration.value = 0;
      return;
    }
    if (keepInterval != null) {
      final same = list.indexWhere((d) => d.billingInterval == keepInterval);
      if (same >= 0) {
        selectedDuration.value = same;
        return;
      }
    }
    final recommended = list.indexWhere((d) => d.isRecommended);
    selectedDuration.value = recommended >= 0 ? recommended : 0;
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void selectTier(int index) {
    if (index == selectedTier.value || index < 0 || index >= tiers.length) {
      return;
    }
    final interval = duration?.billingInterval;
    selectedTier.value = index;
    _selectDefaultDuration(keepInterval: interval);
    members.value =
        members.value.clamp(tier!.minMembers, tier!.maxMembers).toInt();
  }

  void selectDuration(int index) {
    if (index < 0 || index >= durations.length) return;
    selectedDuration.value = index;
  }

  void incrementMembers() {
    final max = tier?.maxMembers ?? 1;
    if (members.value < max) {
      members.value++;
    } else {
      Utils().fluttertoast('Maximum $max members on ${tier?.name ?? 'this plan'}');
    }
  }

  void decrementMembers() {
    final min = tier?.minMembers ?? 1;
    if (members.value > min) {
      members.value--;
    } else {
      Utils().fluttertoast(
          'Minimum $min ${min == 1 ? 'member' : 'members'} on ${tier?.name ?? 'this plan'}');
    }
  }

  /// Returns an error message, or null when the value was applied
  String? setMembers(int? value) {
    final t = tier;
    if (t == null) return null;
    if (value == null || value < t.minMembers || value > t.maxMembers) {
      return 'Enter a number from ${t.minMembers} to ${t.maxMembers}';
    }
    members.value = value;
    return null;
  }

  // ---------------------------------------------------------------------------
  // Payment
  // ---------------------------------------------------------------------------

  Future<void> onBuy() async {
    final plan = duration;
    final planId = plan?.planId;
    if (!canBuy || plan == null || planId == null) return;

    if (PackagePricingRepo.useMock) {
      Utils().fluttertoast(
          'Sample data — payment opens once the backend packages API is live');
      return;
    }

    isPaying.value = true;
    try {
      final order = await PackagePricingRepo.createOrder(
        planId: planId,
        members: members.value,
      );
      if (!order.canOpenCheckout) {
        isPaying.value = false;
        CommonDialog.errorMessage(
            order.message ?? 'Could not start the payment. Please try again.');
        return;
      }
      _paymentId = order.paymentId;
      _razorpayOrderId = order.razorpayOrderId;

      final key = (order.razorpayKeyId?.isNotEmpty ?? false)
          ? order.razorpayKeyId!
          : ConstRes.activePaymentKey;

      final phone = _cleanPhone(
          Global.storageServices.get(PrefConst.userPhone)?.toString());
      final email =
          Global.storageServices.get(PrefConst.userEmail)?.toString();
      final name = Global.storageServices.get(PrefConst.userName)?.toString();

      _razorpay.open({
        'key': key,
        'amount': order.amount, // paise, from backend
        'currency': order.currency,
        'order_id': order.razorpayOrderId,
        'name': 'FG MANPOWER LLP',
        'description':
            '$title – ${tier?.name ?? ''} (${plan.displayLabel})',
        'timeout': 300,
        'theme': {'color': '#704AFA'},
        'retry': {'enabled': true, 'max_count': 3},
        'prefill': {
          if (phone != null) 'contact': phone,
          if (email != null && email.contains('@')) 'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
        },
        'notes': {
          'purpose': 'package_subscription',
          'moduleKey': moduleKey,
          'planId': planId.toString(),
          'members': members.value.toString(),
        },
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[PackagePlanDetails] open failed: $e');
      isPaying.value = false;
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // verify is idempotent on the backend, so retry network failures
    PackageVerifyPaymentResponse? result;
    for (var attempt = 1; attempt <= 3 && result == null; attempt++) {
      try {
        result = await PackagePricingRepo.verifyPayment(
          paymentId: _paymentId ?? 0,
          razorpayOrderId: response.orderId ?? _razorpayOrderId ?? '',
          razorpayPaymentId: response.paymentId ?? '',
          razorpaySignature: response.signature ?? '',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[PackagePlanDetails] verify $attempt: $e');
        if (attempt < 3) await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    isPaying.value = false;

    if (result == null) {
      // Razorpay webhook still activates the plan on the backend
      CommonDialog.errorMessage(
        'Payment received. Your $title plan will be active in a few minutes.',
        status: true,
        successBtnName: 'Done',
        onDismiss: _closeAfterPurchase,
      );
      return;
    }
    if (!result.status) {
      CommonDialog.errorMessage(result.message ??
          'Payment verification failed. If money was deducted it will be refunded in 5–7 working days.');
      return;
    }
    CommonDialog.errorMessage(
      result.message ?? 'Your $title plan is now active.',
      status: true,
      successBtnName: 'Done',
      onDismiss: _closeAfterPurchase,
    );
  }

  void _closeAfterPurchase() {
    Get.back(); // dialog
    Get.back(result: true); // details → list (list refreshes)
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    isPaying.value = false;
    if (_paymentId != null && _razorpayOrderId != null) {
      try {
        await PackagePricingRepo.paymentFailed(
          paymentId: _paymentId!,
          razorpayOrderId: _razorpayOrderId!,
          failureReason: (response.message?.isNotEmpty ?? false)
              ? response.message!
              : 'Payment cancelled',
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[PackagePlanDetails] failed-call: $e');
      }
    }
    CommonDialog.errorMessage(_errorMessageFor(response));
  }

  String _errorMessageFor(PaymentFailureResponse response) {
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment cancelled. No money was deducted.';
      case Razorpay.NETWORK_ERROR:
        return 'No internet connection. Check your network and try again.';
      case Razorpay.TLS_ERROR:
      case Razorpay.INCOMPATIBLE_PLUGIN:
        return "Payment couldn't start. Please update the app and try again.";
      default:
        return 'Payment failed. If money was deducted it will be refunded in 5–7 working days.';
    }
  }

  /// Last 10 digits, or null
  static String? _cleanPhone(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    return digits.substring(digits.length - 10);
  }
}
