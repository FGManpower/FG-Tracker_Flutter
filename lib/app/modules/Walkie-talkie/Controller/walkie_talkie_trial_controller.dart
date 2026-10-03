import 'dart:async';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WalkieTalkieTrialController extends GetxController
    with WidgetsBindingObserver {
  final WalkieTalkieTrialService _service = WalkieTalkieTrialService();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<WalkieOverviewData> overview = Rxn<WalkieOverviewData>();
  final RxInt remainingSeconds = 0.obs;

  int _requestVersion = 0;

  // =====================================================
  // BASE DATA GETTERS
  // =====================================================

  WalkieOverviewData? get data => overview.value;
  WalkieAccess? get access => data?.access;
  WalkieTrial? get trial => data?.trial;
  WalkieSubscriptionsState? get subscriptions => data?.subscriptions;
  WalkieAvailablePlans? get availablePlans => data?.availablePlans;
  WalkiePricing? get pricing => data?.pricing;
  WalkieActions? get actions => data?.actions;

  int? get currentLoggedInUserId {
    try {
      final raw = Global.storageServices.get(PrefConst.userId);
      if (raw != null && raw.toString().isNotEmpty) {
        return int.tryParse(raw.toString());
      }
    } catch (_) {}
    return null;
  }

  // =====================================================
  // ACCESS & PERMISSIONS (AUTHORITATIVE FROM BACKEND)
  // =====================================================

  bool get canUseWalkie => access?.canUseWalkie == true;

  bool get canUseWalkieTalkie => canUseWalkie;

  String get accessType => access?.accessType ?? 'none';

  // =====================================================
  // INDEPENDENT SUBSCRIPTION STATE
  // =====================================================

  WalkieIndividualSubscriptionState? get individualState =>
      subscriptions?.individual;

  WalkieTeamSubscriptionState? get teamState =>
      subscriptions?.team;

  bool get hasPurchasedIndividualBefore =>
      individualState?.hasPurchasedBefore == true;

  bool get hasPurchasedTeamBefore =>
      teamState?.hasPurchasedBefore == true;

  List<WalkieTeamSubscriptionDetails> get activeTeamSubscriptions {
    if (teamState == null) return const [];
    if (teamState!.subscriptions.isNotEmpty) {
      return teamState!.subscriptions;
    }
    if (teamState!.currentSubscription != null) {
      return [teamState!.currentSubscription!];
    }
    return const [];
  }

  bool get hasActiveIndividualSubscription =>
      individualState?.hasActiveSubscription == true &&
      individualState?.currentSubscription != null;

  bool get hasActiveTeamSubscription =>
      (teamState?.hasActiveSubscription == true ||
          activeTeamSubscriptions.any((s) => s.isActive)) &&
      activeTeamSubscriptions.isNotEmpty;

  WalkieIndividualSubscriptionDetails? get activeIndividualSubscription =>
      individualState?.currentSubscription;

  WalkieTeamSubscriptionDetails? get activeTeamSubscription =>
      activeTeamSubscriptions.isNotEmpty
          ? activeTeamSubscriptions.first
          : teamState?.currentSubscription;

  bool get hasAssignedTeamAccess =>
      access?.hasTeamAccess == true ||
      access?.accessType == 'team' ||
      teamState?.currentSubscription?.isAssignedMember == true ||
      activeTeamSubscriptions.any((s) => s.isAssignedMember);

  bool get hasAnyActiveSubscription =>
      hasActiveIndividualSubscription ||
      hasActiveTeamSubscription ||
      hasAssignedTeamAccess ||
      (access?.canUseWalkie == true && access?.accessType != 'trial');

  /// Backward-compatible getter for other screens/controllers
  bool get hasActiveSubscription => hasAnyActiveSubscription;

  // =====================================================
  // AVAILABLE PLANS (CATALOG)
  // =====================================================

  List<WalkieSubscriptionPlan> get availableIndividualPlans =>
      availablePlans?.individual ?? const <WalkieSubscriptionPlan>[];

  List<WalkieSubscriptionPlan> get availableTeamPlans =>
      availablePlans?.team ?? const <WalkieSubscriptionPlan>[];

  bool get hasAvailablePlans =>
      availableIndividualPlans.isNotEmpty || availableTeamPlans.isNotEmpty;

  // =====================================================
  // VISIBILITY CHECKS
  // =====================================================

  bool get shouldShowTrialCard => trial != null;

  bool get shouldShowPurchaseCTA => !hasAnyActiveSubscription;

  // =====================================================
  // TRIAL STATE & HELPERS
  // =====================================================

  bool get isTrialEligible => trial?.isEligibleForTrial == true;

  bool get isTrialActive =>
      trial?.isActive == true && remainingSeconds.value > 0;

  bool get isTrialConsumed =>
      trial?.status.toLowerCase() == 'consumed' ||
      (trial?.hasReceivedTrial == true &&
          remainingSeconds.value <= 0 &&
          trial?.isActive != true);

  bool get isTrialExpired =>
      trial?.status.toLowerCase() == 'expired' ||
      (trial?.isExpired == true && !isTrialActive);

  int get totalSeconds {
    final value = trial?.totalSeconds ?? trial?.durationSeconds;
    if (value == null || value <= 0) {
      return 3600;
    }
    return value;
  }

  int get usedSeconds {
    if (trial?.isActive == true) {
      return (totalSeconds - remainingSeconds.value)
          .clamp(0, totalSeconds)
          .toInt();
    }
    return (trial?.usedSeconds ?? 0).clamp(0, totalSeconds).toInt();
  }

  double get usageProgress {
    if (totalSeconds <= 0) return 0.0;
    return (usedSeconds / totalSeconds).clamp(0.0, 1.0).toDouble();
  }

  String get usageLabel =>
      '${formatDuration(usedSeconds)} / ${formatDuration(totalSeconds)}';

  String get remainingLabel => formatDuration(remainingSeconds.value);

  String get trialDurationFormatted => formatDuration(totalSeconds);

  String get trialDurationHuman {
    if (totalSeconds % 3600 == 0) {
      final hours = totalSeconds ~/ 3600;
      return hours == 1 ? '1 Hour' : '$hours Hours';
    }
    if (totalSeconds % 60 == 0) {
      final minutes = totalSeconds ~/ 60;
      return '$minutes Minutes';
    }
    return formatDuration(totalSeconds);
  }

  String get trialDurationFreeLabel => '$trialDurationHuman Free';

  // =====================================================
  // PRICING FORMATTERS
  // =====================================================

  String get priceLabel {
    if (availableIndividualPlans.isNotEmpty) {
      final p = availableIndividualPlans.first.pricePerMember;
      final formatted = p == p.roundToDouble()
          ? p.toStringAsFixed(0)
          : p.toStringAsFixed(2);
      final currency = availableIndividualPlans.first.currency;
      return currency.toUpperCase() == 'INR' ? '₹$formatted' : '$currency $formatted';
    }

    final amount = pricing?.price;
    if (amount == null || amount <= 0) {
      return '₹999';
    }
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    final currency = pricing?.currency ?? 'INR';
    if (currency.toUpperCase() == 'INR') {
      return '₹$formatted';
    }
    return '$currency $formatted';
  }

  String get priceTypeLabel {
    if (availableIndividualPlans.isNotEmpty) {
      return availableIndividualPlans.first.billingInterval.toLowerCase() == 'monthly'
          ? 'month'
          : availableIndividualPlans.first.billingInterval;
    }
    return 'month';
  }

  // =====================================================
  // TIME FORMATTERS
  // =====================================================

  String formatDuration(int value) {
    final seconds = value < 0 ? 0 : value;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainder = seconds % 60;

    return '$hours:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  String formatDaysRemaining(DateTime? expiresAt) {
    if (expiresAt == null) return '';
    final now = data?.serverTime ?? DateTime.now();
    final difference = expiresAt.difference(now);
    final days = difference.inDays;
    if (days > 0) {
      return '$days days left';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins left';
    }
    return 'Expiring soon';
  }

  // =====================================================
  // INIT & LIFECYCLE
  // =====================================================

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchOverview();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchOverview(refresh: true);
    }
  }

  @override
  void onClose() {
    _requestVersion++;
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // =====================================================
  // FETCH OVERVIEW API
  // =====================================================

  Future<void> fetchOverview({bool refresh = false}) async {
    final requestId = ++_requestVersion;

    if (refresh || data != null) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final result = await _service.getOverview();

      if (isClosed || requestId != _requestVersion) return;

      overview.value = result;

      // Authoritative countdown setup
      _configureCountdown(result);
    } on WalkieTrialException catch (error) {
      if (isClosed || requestId != _requestVersion) return;
      errorMessage.value = error.message;
    } on SocketException catch (_) {
      if (isClosed || requestId != _requestVersion) return;
      errorMessage.value =
          'No internet connection. Please check your network and try again.';
    } on TimeoutException catch (_) {
      if (isClosed || requestId != _requestVersion) return;
      errorMessage.value = 'The request timed out. Please try again.';
    } on FormatException catch (_) {
      if (isClosed || requestId != _requestVersion) return;
      errorMessage.value = 'Invalid response received from server.';
    } catch (error, stackTrace) {
      if (isClosed || requestId != _requestVersion) return;
      debugPrint('Walkie-Talkie overview error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage.value =
          'Unable to load Walkie-Talkie details. Please check your connection.';
    } finally {
      if (!isClosed && requestId == _requestVersion) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  // =====================================================
  // COUNTDOWN LOGIC
  // =====================================================

  void _configureCountdown(WalkieOverviewData result) {
    final currentTrial = result.trial;
    if (currentTrial == null) {
      remainingSeconds.value = 0;
      return;
    }

    // Trial remaining seconds is authoritative from backend
    // It only decreases during active PTT voice sessions (speaking/listening), NOT on overview screen
    remainingSeconds.value = currentTrial.remainingSeconds.clamp(0, totalSeconds).toInt();
  }
}