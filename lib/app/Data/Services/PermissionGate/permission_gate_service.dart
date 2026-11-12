import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../Core/constant/notification_holder.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../Core/values/global.dart';
import '../../../Core/values/utility.dart';
import '../../../modules/Walkie-talkie/Services/walkie_notification_manager.dart';
import '../../../routes/app_pages.dart';
import '../Socket/Socket_Walkie-Talkie-Service.dart';
import 'permission_backend.dart';
import 'permission_flags.dart';
import 'permission_gate_models.dart';

/// Single source of truth for the compulsory permissions
/// (Location "Always" + Precise + GPS, and Push Notification).
///
/// Checked:
///  * on splash (InitiateController) for every logged-in user,
///  * after login (PermissionSetupController),
///  * on every app resume (this class) — so the app unlocks / locks itself
///    when the user comes back from Settings.
///
/// Route-level protection lives in [PermissionGateMiddleware].
class PermissionGateService extends GetxService with WidgetsBindingObserver {
  PermissionGateService({
    PermissionBackend? backend,
    PermissionFlagsSource? flagsSource,
    bool Function()? isLoggedIn,
    bool Function()? isCallOrWalkieActive,
    this.onNotificationGranted,
    this.flagsTimeout = const Duration(seconds: 7),
  })  : backend = backend ?? PluginPermissionBackend(),
        _flagsSource = flagsSource ?? RemoteConfigPermissionFlagsSource(),
        _isLoggedIn = isLoggedIn ?? _defaultIsLoggedIn,
        _isCallOrWalkieActive =
            isCallOrWalkieActive ?? _defaultIsCallOrWalkieActive;

  static PermissionGateService get to => Get.find<PermissionGateService>();

  final PermissionBackend backend;
  final PermissionFlagsSource _flagsSource;
  final bool Function() _isLoggedIn;
  final bool Function() _isCallOrWalkieActive;

  /// Called once each time notification permission turns from off → on
  /// (refreshes the FCM / APNs token).
  final Future<void> Function()? onNotificationGranted;
  final Duration flagsTimeout;

  /// Latest gate result; null until the first check.
  final Rx<PermissionGateResult?> result = Rx<PermissionGateResult?>(null);

  PermissionFlags _flags = PermissionFlags.defaults;
  PermissionFlags get flags => _flags;
  Future<PermissionFlags>? _flagsFuture;

  Future<PermissionGateResult>? _inFlight;
  int _busy = 0;

  /// Routes that are never redirected to the blocking screen: auth flow,
  /// the permission screens themselves, and call / walkie screens (an
  /// accepted call must never land on a blocking screen).
  static final Set<String> exemptRoutes = {
    Routes.Splash,
    Routes.Intro,
    Routes.Login,
    Routes.Register,
    Routes.OTPScreen,
    Routes.languageSelect,
    Routes.OTP_CHARGES,
    Routes.permissionSetup,
    Routes.permissionGate,
    Routes.forceUpdate,
    Routes.callScreen,
    Routes.IncomingCallScreen,
    Routes.groupWalkieScreen,
    Routes.groupCallingScreen,
    Routes.groupIncomingCallScreen,
  };

  // ---------------------------------------------------------------- lifecycle

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResume());
    }
  }

  Future<void> _onResume() async {
    // A permission flow is running (system dialog just closed) — it re-checks
    // by itself; don't race it.
    if (_busy > 0) return;
    if (!_isLoggedIn()) return;

    final r = await check();
    if (r.allowsAccess) return;

    final route = Get.currentRoute;
    // The permission screens react to [result] themselves.
    if (route == Routes.permissionGate || route == Routes.permissionSetup) {
      return;
    }
    if (exemptRoutes.contains(route) || _isCallOrWalkieActive()) return;

    log('[PermissionGate] permission revoked while on $route → blocking');
    Get.offAllNamed(Routes.permissionGate);
  }

  // ------------------------------------------------------------------- flags

  /// Loads the Remote Config switches once (subsequent calls reuse it).
  Future<PermissionFlags> loadFlags() {
    return _flagsFuture ??= () async {
      try {
        _flags = await _flagsSource.load().timeout(flagsTimeout);
      } catch (e) {
        log('[PermissionGate] flags load failed, defaults used: $e');
        _flags = PermissionFlags.defaults;
      }
      return _flags;
    }();
  }

  // ------------------------------------------------------------------- check

  /// Re-reads the device state and updates [result]. Never throws.
  Future<PermissionGateResult> check() {
    return _inFlight ??= _doCheck().whenComplete(() => _inFlight = null);
  }

  Future<PermissionGateResult> _doCheck() async {
    final flags = await loadFlags();
    final previous = result.value;
    PermissionGateResult next;
    try {
      final snap = await backend.snapshot().timeout(const Duration(seconds: 3));
      next = PermissionGateResult.evaluate(snap, flags);
    } catch (e) {
      log('[PermissionGate] snapshot failed: $e');
      next = PermissionGateResult.error(flags);
    }
    result.value = next;

    final wasGranted = previous?.notificationOk ?? false;
    if (next.notificationOk && !wasGranted && onNotificationGranted != null) {
      unawaited(Future(() async {
        try {
          await onNotificationGranted!();
        } catch (e) {
          log('[PermissionGate] token refresh failed: $e');
        }
      }));
    }
    return next;
  }

  /// Marks a permission request as running so app-resume events caused by
  /// system dialogs / Settings don't trigger competing navigation.
  Future<T> runExclusive<T>(Future<T> Function() body) async {
    _busy++;
    try {
      return await body();
    } finally {
      _busy--;
    }
  }

  bool get isBusy => _busy > 0;

  // --------------------------------------------------------- route guarding

  /// Used by the route middleware (synchronous → uses the cached result).
  bool shouldBlockRoute(String? route) {
    if (route != null && exemptRoutes.contains(route)) return false;
    final r = result.value;
    if (r == null || r.allowsAccess) return false;
    if (!_isLoggedIn()) return false;
    if (_isCallOrWalkieActive()) return false;
    return true;
  }

  // ---------------------------------------------------------------- defaults

  static bool _defaultIsLoggedIn() {
    try {
      final token = Global.storageServices.getaccesstoken();
      final isRegistered = Global.storageServices.get(PrefConst.isRegistered);
      return Utility.isNotNullEmptyOrFalse(token) && isRegistered == "true";
    } catch (_) {
      return false;
    }
  }

  static bool _defaultIsCallOrWalkieActive() {
    try {
      return CallSessionState.launchedFromCall ||
          CallSessionState.isCallActive ||
          WalkieLaunchTracker.fromWalkieCall ||
          WalkieNotificationManager.instance.isWalkieScreenActive.value ||
          GroupWalkieService.instance.currentGroupId != null;
    } catch (_) {
      return false;
    }
  }
}
