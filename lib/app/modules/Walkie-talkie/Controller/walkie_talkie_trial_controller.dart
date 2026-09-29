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
  final WalkieTalkieTrialService _service = WalkieTalkieTrialService();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<WalkieOverviewData> overview = Rxn<WalkieOverviewData>();
  final RxInt remainingSeconds = 0.obs;

  Timer? _countdownTimer;
  DateTime? _localExpiry;
  int _requestVersion = 0;

  WalkieOverviewData? get data => overview.value;
  WalkieTrial? get trial => data?.trial;
  WalkiePricing? get pricing => data?.pricing;

  bool get canUseWalkie => data?.access?.canUseWalkie == true;

  bool get isTrialEligible => trial?.isEligibleForTrial == true;

  bool get isTrialActive =>
      trial?.isActive == true && remainingSeconds.value > 0;

  bool get hasActiveSubscription =>
      data?.subscription?.hasActiveSubscription == true;

  bool get showTrialCountdown =>
      data?.actions?.showTrialCountdown == true && trial?.isActive == true;

  bool get showSubscribe =>
      data?.actions?.showSubscribe == true && pricing?.available == true;

  bool get showTrialExpired =>
      data?.actions?.showTrialExpired == true || trial?.isExpired == true;

  int get totalSeconds {
    final value = trial?.totalSeconds ?? trial?.durationSeconds;
    if (value == null || value <= 0) {
      return 3600;
    }
    return value;
  }

  int get usedSeconds {
    if (trial?.isActive == true && trial?.expiresAt != null) {
      return (totalSeconds - remainingSeconds.value).clamp(0, totalSeconds);
    }
    return (trial?.usedSeconds ?? 0).clamp(0, totalSeconds);
  }

  double get usageProgress {
    if (totalSeconds == 0) return 0;
    return (usedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  String get usageLabel =>
      '${formatDuration(usedSeconds)} / ${formatDuration(totalSeconds)}';

  String get remainingLabel => formatDuration(remainingSeconds.value);

  String get priceLabel {
    final amount = pricing?.price;
    if (amount == null) {
      return '₹49';
    }
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final currency = pricing?.currency ?? 'INR';
    return currency == 'INR' ? '₹$formatted' : '$currency $formatted';
  }

  String get priceTypeLabel {
    switch (pricing?.priceType) {
      case 'individual':
        return 'month';
      case 'team':
        return 'team';
      default:
        return 'month';
    }
  }

  String formatDuration(int value) {
    final seconds = value < 0 ? 0 : value;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainder = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  String get trialDurationFormatted => formatDuration(totalSeconds);
  String get trialDurationHuman => formatDuration(totalSeconds);
  String get trialDurationFreeLabel => '${formatDuration(totalSeconds)} Free';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchOverview();
  }

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

      if (isClosed || requestId != _requestVersion) {
        return;
      }

      overview.value = result;
      _configureCountdown(result);
    } on DioException catch (dioError) {
      if (isClosed || requestId != _requestVersion) {
        return;
      }
      if (dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.sendTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.error is SocketException) {
        errorMessage.value =
            'No internet connection. Please check your network and try again.';
      } else {
        errorMessage.value =
            'Unable to connect to server. Please try again later.';
      }
    } on WalkieTrialException catch (error) {
      if (isClosed || requestId != _requestVersion) {
        return;
      }
      errorMessage.value = error.message;
    } on SocketException {
      if (isClosed || requestId != _requestVersion) {
        return;
      }
      errorMessage.value =
          'No internet connection. Please check your network and try again.';
    } on TimeoutException {
      if (isClosed || requestId != _requestVersion) {
        return;
      }
      errorMessage.value = 'The request timed out. Please try again.';
    } catch (error, stackTrace) {
      if (isClosed || requestId != _requestVersion) {
        return;
      }
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

  void _configureCountdown(WalkieOverviewData result) {
    _countdownTimer?.cancel();
    _localExpiry = null;

    final currentTrial = result.trial;
    if (currentTrial?.isActive != true) {
      remainingSeconds.value = 0;
      return;
    }

    int seconds = currentTrial!.remainingSeconds;
    final serverTime = result.serverTime;
    final expiresAt = currentTrial.expiresAt;

    if (serverTime != null && expiresAt != null) {
      seconds = expiresAt.difference(serverTime).inSeconds;
    }

    seconds = seconds.clamp(
      0,
      currentTrial.totalSeconds > 0
          ? currentTrial.totalSeconds
          : currentTrial.durationSeconds,
    );

    remainingSeconds.value = seconds;
    if (seconds == 0) {
      return;
    }

    _localExpiry = DateTime.now().add(Duration(seconds: seconds));
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickCountdown(),
    );
  }

  void _tickCountdown() {
    final expiry = _localExpiry;
    if (expiry == null) return;

    final milliseconds = expiry.difference(DateTime.now()).inMilliseconds;
    remainingSeconds.value =
        milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();

    if (remainingSeconds.value == 0) {
      _countdownTimer?.cancel();
      fetchOverview(refresh: true);
    }
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
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
