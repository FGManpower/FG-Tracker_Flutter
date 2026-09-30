import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fgtracker/app/Data/Services/walkie_talkie_trial_service.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WalkieTalkieTrialController extends GetxController
    with WidgetsBindingObserver {
  final WalkieTalkieTrialService _service =
  WalkieTalkieTrialService();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<WalkieOverviewData> overview =
  Rxn<WalkieOverviewData>();

  final RxInt remainingSeconds = 0.obs;

  Timer? _countdownTimer;
  DateTime? _localExpiry;

  int _requestVersion = 0;

  // =====================================================
  // BASE
  // =====================================================

  WalkieOverviewData? get data => overview.value;

  WalkieAccess? get access => data?.access;

  WalkieTrial? get trial => data?.trial;

  WalkiePricing? get pricing => data?.pricing;

  WalkieSubscription? get subscription =>
      data?.subscription;

  WalkieActions? get actions => data?.actions;

  WalkieCurrentSubscription? get currentSubscription =>
      subscription?.currentSubscription;

  WalkieSubscriptionPlan? get subscriptionPlan =>
      currentSubscription?.plan;

  // =====================================================
  // ACCESS
  // =====================================================

  bool get canUseWalkie =>
      access?.canUseWalkie == true;

  String get accessType =>
      access?.accessType ?? 'none';

  bool get isSubscriptionAccess =>
      canUseWalkie &&
          accessType.toLowerCase() == 'subscription';

  bool get isTrialAccess =>
      canUseWalkie &&
          accessType.toLowerCase() == 'trial';

  // =====================================================
  // SUBSCRIPTION
  // =====================================================

  bool get hasActiveSubscription =>
      subscription?.hasActiveSubscription == true;

  bool get hasValidSubscription =>
      hasActiveSubscription &&
          currentSubscription != null &&
          currentSubscription!.isActive;

  bool get isIndividualSubscription =>
      hasValidSubscription &&
          currentSubscription!.isIndividual;

  bool get isGroupSubscription =>
      hasValidSubscription &&
          currentSubscription!.isGroup;

  int? get subscriptionId =>
      currentSubscription?.id;

  int? get subscriptionGroupId =>
      currentSubscription?.groupId;

  int get purchasedSeats =>
      currentSubscription?.purchasedSeats ?? 0;

  String get subscriptionStatus =>
      currentSubscription?.status ?? '';

  String get subscriptionSource =>
      currentSubscription?.source ?? '';

  String get subscriptionPlanName =>
      subscriptionPlan?.name ??
          'Walkie Talkie Plan';

  String get subscriptionPlanType =>
      subscriptionPlan?.planType ?? '';

  String get subscriptionBillingInterval =>
      subscriptionPlan?.billingInterval ?? '';

  DateTime? get subscriptionStartsAt =>
      currentSubscription?.startsAt;

  DateTime? get subscriptionExpiresAt =>
      currentSubscription?.expiresAt;

  int get subscriptionRemainingSeconds =>
      currentSubscription?.remainingSeconds ?? 0;

  String get subscriptionRemainingLabel =>
      formatLongDuration(
        subscriptionRemainingSeconds,
      );

  // =====================================================
  // TRIAL
  // =====================================================

  bool get isTrialEligible =>
      !hasActiveSubscription &&
          trial?.isEligibleForTrial == true;

  bool get isTrialActive =>
      !hasActiveSubscription &&
          trial?.isActive == true &&
          remainingSeconds.value > 0;

  bool get showTrialCountdown =>
      !hasActiveSubscription &&
          actions?.showTrialCountdown == true &&
          trial?.isActive == true;

  bool get showTrialExpired =>
      !hasActiveSubscription &&
          (actions?.showTrialExpired == true ||
              trial?.isExpired == true);

  // =====================================================
  // SUBSCRIBE ACTION
  // =====================================================

  bool get showSubscribe =>
      !hasActiveSubscription &&
          !canUseWalkie &&
          actions?.showSubscribe == true &&
          pricing?.available == true;

  // =====================================================
  // UI STATE HELPERS
  // =====================================================

  bool get shouldShowOpenWalkie =>
      canUseWalkie;

  bool get shouldShowStartTrial =>
      !hasActiveSubscription &&
          !canUseWalkie &&
          isTrialEligible;

  bool get shouldShowSubscribe =>
      showSubscribe;

  // =====================================================
  // TRIAL TIME
  // =====================================================

  int get totalSeconds {
    final value =
        trial?.totalSeconds ??
            trial?.durationSeconds;

    if (value == null || value <= 0) {
      return 3600;
    }

    return value;
  }

  int get usedSeconds {
    if (trial?.isActive == true &&
        trial?.expiresAt != null) {
      return (totalSeconds -
          remainingSeconds.value)
          .clamp(
        0,
        totalSeconds,
      )
          .toInt();
    }

    return (trial?.usedSeconds ?? 0)
        .clamp(
      0,
      totalSeconds,
    )
        .toInt();
  }

  double get usageProgress {
    if (totalSeconds <= 0) {
      return 0.0;
    }

    return (usedSeconds / totalSeconds)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();
  }

  String get usageLabel =>
      '${formatDuration(usedSeconds)} / '
          '${formatDuration(totalSeconds)}';

  String get remainingLabel =>
      formatDuration(
        remainingSeconds.value,
      );

  // =====================================================
  // PRICING
  // =====================================================

  String get priceLabel {
    final amount = pricing?.price;

    if (amount == null) {
      return 'Price unavailable';
    }

    final formatted =
    amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    final currency =
        pricing?.currency ?? 'INR';

    if (currency.toUpperCase() == 'INR') {
      return '₹$formatted';
    }

    return '$currency $formatted';
  }

  String get priceTypeLabel {
    final selectedPlan =
        pricing?.selectedPlan;

    if (selectedPlan != null &&
        selectedPlan.billingInterval.isNotEmpty) {
      switch (
      selectedPlan.billingInterval.toLowerCase()) {
        case 'monthly':
          return 'month';

        case 'quarterly':
          return 'quarter';

        case 'yearly':
          return 'year';

        default:
          return selectedPlan.billingInterval;
      }
    }

    return 'month';
  }

  // =====================================================
  // FORMATTERS
  // =====================================================

  String formatDuration(int value) {
    final seconds =
    value < 0 ? 0 : value;

    final hours =
        seconds ~/ 3600;

    final minutes =
        (seconds % 3600) ~/ 60;

    final remainder =
        seconds % 60;

    return '$hours:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  String formatLongDuration(
      int value,
      ) {
    final seconds =
    value < 0 ? 0 : value;

    if (seconds == 0) {
      return 'Expired';
    }

    final days =
        seconds ~/ 86400;

    final hours =
        (seconds % 86400) ~/ 3600;

    final minutes =
        (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  String get trialDurationFormatted =>
      formatDuration(totalSeconds);

  String get trialDurationHuman {
    if (totalSeconds % 3600 == 0) {
      final hours =
          totalSeconds ~/ 3600;

      return hours == 1
          ? '1 Hour'
          : '$hours Hours';
    }

    if (totalSeconds % 60 == 0) {
      final minutes =
          totalSeconds ~/ 60;

      return '$minutes Minutes';
    }

    return formatDuration(totalSeconds);
  }

  String get trialDurationFreeLabel =>
      '$trialDurationHuman Free';

  // =====================================================
  // INIT
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance
        .addObserver(this);

    fetchOverview();
  }

  // =====================================================
  // FETCH
  // =====================================================

  Future<void> fetchOverview({
    bool refresh = false,
  }) async {
    final requestId = ++_requestVersion;

    if (refresh || data != null) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      // =====================================================
      // GET OVERVIEW
      // =====================================================

      final result = await _service.getOverview();

      // Ignore old/stale request
      if (isClosed || requestId != _requestVersion) {
        return;
      }

      overview.value = result;

      // =====================================================
      // SUBSCRIPTION HAS PRIORITY OVER TRIAL
      // =====================================================

      if (result.subscription?.hasActiveSubscription == true) {
        _stopTrialCountdown();

        debugPrint('=======================================');
        debugPrint('WALKIE SUBSCRIPTION ACTIVE');
        debugPrint(
          'Access Type: ${result.access?.accessType}',
        );
        debugPrint(
          'Subscription ID: '
              '${result.subscription?.currentSubscription?.id}',
        );
        debugPrint(
          'Plan Type: '
              '${result.subscription?.currentSubscription?.plan?.planType}',
        );
        debugPrint(
          'Group ID: '
              '${result.subscription?.currentSubscription?.groupId}',
        );
        debugPrint('=======================================');

        return;
      }

      // =====================================================
      // TRIAL COUNTDOWN
      // =====================================================

      _configureCountdown(result);
    } on DioException catch (dioError) {
      // =====================================================
      // DIO ERROR
      // =====================================================

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.error is SocketException) {
        errorMessage.value =
        'No internet connection. '
            'Please check your network and try again.';
      } else {
        errorMessage.value =
        'Unable to connect to server. '
            'Please try again later.';
      }
    } on WalkieTrialException catch (error) {
      // =====================================================
      // SERVICE ERROR
      // =====================================================

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      errorMessage.value = error.message;
    } on SocketException catch (_) {
      // =====================================================
      // SOCKET / INTERNET ERROR
      // =====================================================

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      errorMessage.value =
      'No internet connection. '
          'Please check your network and try again.';
    } on TimeoutException catch (_) {
      // =====================================================
      // TIMEOUT
      // =====================================================

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      errorMessage.value =
      'The request timed out. '
          'Please try again.';
    } catch (error, stackTrace) {
      // =====================================================
      // UNKNOWN ERROR
      // =====================================================

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      debugPrint(
        'Walkie-Talkie overview error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      errorMessage.value =
      'Unable to load Walkie-Talkie details. '
          'Please check your connection.';
    } finally {
      // =====================================================
      // RESET LOADER
      // =====================================================

      if (!isClosed && requestId == _requestVersion) {
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  // =====================================================
  // COUNTDOWN
  // =====================================================

  void _configureCountdown(
      WalkieOverviewData result,
      ) {
    _stopTrialCountdown();

    final currentTrial =
        result.trial;

    if (currentTrial?.isActive != true) {
      remainingSeconds.value = 0;
      return;
    }

    int seconds =
        currentTrial!.remainingSeconds;

    final serverTime =
        result.serverTime;

    final expiresAt =
        currentTrial.expiresAt;

    if (serverTime != null &&
        expiresAt != null) {
      seconds = expiresAt
          .difference(serverTime)
          .inSeconds;
    }

    final maximum =
    currentTrial.totalSeconds > 0
        ? currentTrial.totalSeconds
        : currentTrial.durationSeconds;

    seconds = seconds
        .clamp(
      0,
      maximum,
    )
        .toInt();

    remainingSeconds.value =
        seconds;

    if (seconds <= 0) {
      return;
    }

    _localExpiry =
        DateTime.now().add(
          Duration(
            seconds: seconds,
          ),
        );

    _countdownTimer =
        Timer.periodic(
          const Duration(seconds: 1),
              (_) {
            _tickCountdown();
          },
        );
  }

  void _tickCountdown() {
    final expiry =
        _localExpiry;

    if (expiry == null) {
      return;
    }

    final milliseconds =
        expiry
            .difference(
          DateTime.now(),
        )
            .inMilliseconds;

    remainingSeconds.value =
    milliseconds <= 0
        ? 0
        : (milliseconds / 1000)
        .ceil();

    if (remainingSeconds.value <= 0) {
      _countdownTimer?.cancel();

      _countdownTimer = null;
      _localExpiry = null;

      fetchOverview(
        refresh: true,
      );
    }
  }

  void _stopTrialCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = null;
    _localExpiry = null;

    remainingSeconds.value = 0;
  }

  // =====================================================
  // LIFECYCLE
  // =====================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state ==
        AppLifecycleState.resumed) {
      fetchOverview(
        refresh: true,
      );
    }
  }

  @override
  void onClose() {
    _requestVersion++;

    _countdownTimer?.cancel();

    WidgetsBinding.instance
        .removeObserver(this);

    super.onClose();
  }
}