import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Data/Services/PermissionGate/permission_flow.dart';
import '../../../Data/Services/PermissionGate/permission_gate_models.dart';
import '../../../Data/Services/PermissionGate/permission_gate_service.dart';
import '../../../routes/app_pages.dart';

class PermissionItem {
  final String title;
  final String description;
  final IconData icon;
  final String why;

  const PermissionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.why,
  });
}

/// "New customer" permission screen shown after login / registration.
///
/// Location ("Allow all the time" + Precise + GPS) and Push Notification are
/// compulsory (see [PermissionGateService]); everything else is optional.
/// Nothing is requested automatically — only when the user taps.
class PermissionSetupController extends GetxController
    with WidgetsBindingObserver {
  static const int locationIndex = 0;
  static const int notificationIndex = 1;

  final RxInt selectedIndex = 0.obs;
  final RxSet<int> expandedItems = <int>{0}.obs;
  final RxSet<int> grantedItems = <int>{}.obs;
  final RxBool loading = false.obs;

  /// True while the initial check runs (loader instead of a flashing list).
  final RxBool checking = true.obs;

  bool _waitingForSettings = false;
  bool _navigatedHome = false;
  Worker? _gateWorker;
  Timer? _safetyTimer;

  late final PermissionGateService gate = PermissionGateService.to;
  late final PermissionFlow flow = PermissionFlow(gate);

  // ORDER: 0 Location, 1 Notifications, 2 Camera, 3 Microphone, 4 Contacts
  List<PermissionItem> get items => [
    PermissionItem(
      title: appL10n.permission_location,
      description: appL10n.permission_locationDescription,
      why: '${PermissionReasons.location} ${appL10n.permission_locationWhyExtra}',
      icon: Icons.location_on_rounded,
    ),
    PermissionItem(
      title: appL10n.permission_notifications,
      description: appL10n.permission_notificationsDescription,
      why: '${PermissionReasons.notification} ${appL10n.permission_notificationsWhyExtra}',
      icon: Icons.notifications_rounded,
    ),
    PermissionItem(
      title: appL10n.permission_camera,
      description: appL10n.permission_cameraDescription,
      why: appL10n.permission_cameraWhy,
      icon: Icons.camera_alt_rounded,
    ),
    PermissionItem(
      title: appL10n.permission_microphone,
      description: appL10n.permission_microphoneDescription,
      why: appL10n.permission_microphoneWhy,
      icon: Icons.mic_rounded,
    ),
    PermissionItem(
      title: appL10n.permission_contacts,
      description: appL10n.permission_contactsDescription,
      why: appL10n.permission_contactsWhy,
      icon: Icons.groups_rounded,
    ),
  ];

  PermissionItem get currentItem => items[selectedIndex.value];

  /// Required → blocks the app ("Required" badge). Driven by Remote Config.
  bool isRequired(int index) {
    if (index == locationIndex) return gate.flags.requireLocation;
    if (index == notificationIndex) return gate.flags.requireNotification;
    return false;
  }

  /// Compulsory-but-switched-off-remotely permission ("Recommended" badge).
  bool isRecommended(int index) =>
      (index == locationIndex || index == notificationIndex) &&
      !isRequired(index);

  /// "Continue" is enabled only when every required permission is granted.
  bool get canContinue => gate.result.value?.allowsAccess ?? false;

  /// Label for the primary action of the selected card.
  String get primaryLabel {
    final idx = selectedIndex.value;
    final r = gate.result.value;
    if (idx == locationIndex && r != null) {
      return PermissionFlow.locationActionLabel(r.locationStep);
    }
    if (idx == notificationIndex && r != null) {
      return PermissionFlow.notificationActionLabel(r.notificationStep);
    }
    return appL10n.permission_allowNamed(items[idx].title);
  }

  /// Extra status line under Location / Notifications (null for others).
  String? statusText(int index) {
    final r = gate.result.value;
    if (r == null) return null;
    if (index == locationIndex) {
      return PermissionFlow.locationStatusText(r.locationStep);
    }
    if (index == notificationIndex) {
      return PermissionFlow.notificationStatusText(r.notificationStep);
    }
    return null;
  }

  // ---------------------------------------------------------------- lifecycle

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _gateWorker = ever<PermissionGateResult?>(gate.result, _applyGateResult);
  }

  @override
  void onReady() {
    super.onReady();
    // Safety watchdog: ensure the loading screen can never remain stuck permanently.
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 3), () {
      if (checking.value && !_navigatedHome) {
        debugPrint('[PermissionSetup] Safety watchdog fired: releasing loading state.');
        checking.value = false;
      }
    });
    _checkInitialAndContinue();
  }

  @override
  void onClose() {
    _safetyTimer?.cancel();
    _gateWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Login / Register always route here. If every compulsory permission is
  /// already granted, skip this screen and go straight to Home.
  Future<void> _checkInitialAndContinue() async {
    try {
      await checkAllPermissionStatus().timeout(
        const Duration(milliseconds: 2500),
        onTimeout: () {
          debugPrint('[PermissionSetup] Initial check timed out; falling back to UI.');
        },
      );
      if (canContinue) {
        _goHome();
        return;
      }
      _selectAndExpandPermission(_firstPendingIndex() ?? locationIndex);
    } catch (e) {
      debugPrint('[PermissionSetup] _checkInitialAndContinue error: $e');
    } finally {
      _safetyTimer?.cancel();
      if (!_navigatedHome) checking.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _navigatedHome) return;
    // Re-check whenever the user comes back (Settings, manual changes).
    // Skip while a request flow is in progress — it re-checks itself.
    if (_waitingForSettings ||
        (!loading.value && !checking.value && !gate.isBusy)) {
      _waitingForSettings = false;
      verifyCurrentPermission();
    }
  }

  void _goHome() {
    if (_navigatedHome) return;
    _navigatedHome = true;
    _safetyTimer?.cancel();
    Get.offAllNamed(Routes.Home_Screen);
  }

  // ------------------------------------------------------------------- status

  void _applyGateResult(PermissionGateResult? r) {
    if (r == null) return;
    if (r.locationOk) {
      grantedItems.add(locationIndex);
    } else {
      grantedItems.remove(locationIndex);
    }
    if (r.notificationOk) {
      grantedItems.add(notificationIndex);
    } else {
      grantedItems.remove(notificationIndex);
    }
    grantedItems.refresh();
  }

  Future<void> checkAllPermissionStatus() async {
    try {
      final r = await gate.check().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('[PermissionSetup] gate.check timed out, using fallback.');
          return gate.result.value ?? PermissionGateResult.error(gate.flags);
        },
      );

      final granted = <int>{};
      if (r.locationOk) granted.add(locationIndex);
      if (r.notificationOk) granted.add(notificationIndex);

      grantedItems
        ..clear()
        ..addAll(granted);
      grantedItems.refresh();

      // If compulsory permissions already allow access, return immediately so
      // the user doesn't wait for optional checks before navigating Home.
      if (r.allowsAccess) {
        return;
      }

      // Check optional permissions in parallel with individual timeouts
      final optionalFutures = <Future<void>>[];
      for (int i = 2; i < items.length; i++) {
        final idx = i;
        final p = _permissionForIndex(idx);
        if (p == null) continue;
        optionalFutures.add(() async {
          try {
            final s = await gate.backend.status(p).timeout(
              const Duration(milliseconds: 800),
            );
            if (s.isGranted || s.isLimited) {
              grantedItems.add(idx);
            }
          } catch (_) {}
        }());
      }

      await Future.wait(optionalFutures);
      grantedItems.refresh();
    } catch (e) {
      debugPrint('[PermissionSetup] checkAllPermissionStatus error: $e');
    }
  }

  int? _firstPendingIndex() {
    // Compulsory ones first, in order: Location → Notification.
    for (final i in [locationIndex, notificationIndex]) {
      if (!grantedItems.contains(i)) return i;
    }
    for (int i = 2; i < items.length; i++) {
      if (!grantedItems.contains(i)) return i;
    }
    return null;
  }

  Future<void> verifyCurrentPermission() async {
    await checkAllPermissionStatus();
    final next = _firstPendingIndex();
    if (next == null) {
      // Everything granted (e.g. user enabled all from Settings) → Home.
      _goHome();
      return;
    }
    // Only move the selection if the selected card is now done.
    if (grantedItems.contains(selectedIndex.value) ||
        (!grantedItems.contains(locationIndex) &&
            selectedIndex.value != locationIndex &&
            isRequired(locationIndex))) {
      _selectAndExpandPermission(next);
    }
  }

  // ------------------------------------------------------------------ actions

  void toggleExpanded(int index) {
    if (expandedItems.contains(index)) {
      expandedItems.remove(index);
    } else {
      expandedItems.add(index);
    }
    expandedItems.refresh();
  }

  void selectCard(int index) {
    selectedIndex.value = index;
  }

  Future<void> allowCurrentPermission() async {
    if (loading.value) return;
    loading.value = true;

    try {
      final idx = selectedIndex.value;

      if (grantedItems.contains(idx)) {
        _advanceSelection(idx);
        return;
      }

      // One at a time, Location first.
      if (idx != locationIndex &&
          isRequired(locationIndex) &&
          !grantedItems.contains(locationIndex)) {
        _selectAndExpandPermission(locationIndex);
        PermissionFlow.showMessage(appL10n.permission_allowLocationFirst);
        return;
      }

      if (idx == locationIndex) {
        final r = await flow.fixLocation();
        _applyGateResult(r);
        if (r.locationOk) _advanceSelection(idx);
        return;
      }

      if (idx == notificationIndex) {
        final r = await flow.fixNotification();
        _applyGateResult(r);
        if (r.notificationOk) _advanceSelection(idx);
        return;
      }

      await _requestOptional(idx);
    } on PlatformException catch (e) {
      PermissionFlow.showMessage(e.message ?? appL10n.permission_unableToRequest);
    } catch (e) {
      PermissionFlow.showMessage(appL10n.common_somethingWentWrong);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _requestOptional(int idx) async {
    final permission = _permissionForIndex(idx);
    if (permission == null) return;

    var status = await gate.backend.status(permission);
    if (status.isGranted || status.isLimited) {
      _markGrantedAndAdvance(idx);
      return;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog();
      return;
    }

    status = await gate.backend.request(permission);
    if (status.isGranted || status.isLimited) {
      _markGrantedAndAdvance(idx);
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog();
    } else {
      PermissionFlow.showMessage(
        appL10n.permission_notGrantedNamed(items[idx].title),
      );
    }
  }

  /// Optional permissions only.
  void skipCurrentPermission() {
    if (loading.value) return;
    final idx = selectedIndex.value;
    if (isRequired(idx)) return;
    _advanceSelection(idx);
  }

  /// "Continue" button: enabled only when the required permissions are
  /// granted; remaining optional permissions are skipped.
  Future<void> continueToApp() async {
    if (loading.value) return;
    final r = await gate.check();
    if (!r.allowsAccess) {
      PermissionFlow.showMessage(
        appL10n.permission_locationAndNotificationRequired,
      );
      _selectAndExpandPermission(_firstPendingIndex() ?? locationIndex);
      return;
    }
    _goHome();
  }

  /// Kept for compatibility — same as [continueToApp].
  Future<void> skipAllRemaining() => continueToApp();

  void _markGrantedAndAdvance(int index) {
    grantedItems.add(index);
    grantedItems.refresh();
    _advanceSelection(index);
  }

  void _advanceSelection(int fromIndex) {
    final next = _firstPendingIndex();
    if (next == null) {
      _goHome();
      return;
    }
    _selectAndExpandPermission(next);
  }

  void _selectAndExpandPermission(int index) {
    selectedIndex.value = index;
    expandedItems
      ..clear()
      ..add(index);
    expandedItems.refresh();
  }

  Permission? _permissionForIndex(int index) {
    switch (index) {
      case 2:
        return Permission.camera;
      case 3:
        return Permission.microphone;
      case 4:
        return Permission.contacts;
      default:
        return null;
    }
  }

  String _settingsMessage(int idx) {
    switch (idx) {
      case 2:
        return appL10n.permission_cameraSettingsMessage;
      case 3:
        return appL10n.permission_microphoneSettingsMessage;
      case 4:
        return appL10n.permission_contactsSettingsMessage;
      default:
        return appL10n.permission_genericSettingsMessage;
    }
  }

  /// Settings dialog for OPTIONAL permissions (camera / mic / contacts).
  Future<void> _showSettingsDialog() async {
    final context = Get.context;
    if (context == null) return;

    final idx = selectedIndex.value;
    final item = items[idx];

    const Color brand = Color(0xFF6C5DD3);
    const Color navy = Color(0xFF11145A);
    const Color grey = Color(0xFF686B9D);

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: brand,
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 26.sp),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                appL10n.permission_required,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                _settingsMessage(idx),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5.sp, height: 1.45, color: grey),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: brand,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          side: BorderSide(
                            color: brand.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            appL10n.common_cancel,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            appL10n.permission_openSettings,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (openSettings == true) {
      _waitingForSettings = true;
      await gate.backend.openAppSettings();
    } else if (openSettings == false) {
      _advanceSelection(idx);
    }
  }
}
