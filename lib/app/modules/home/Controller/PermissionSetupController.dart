import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  late final PermissionGateService gate = PermissionGateService.to;
  late final PermissionFlow flow = PermissionFlow(gate);

  // ORDER: 0 Location, 1 Notifications, 2 Camera, 3 Microphone, 4 Contacts
  final List<PermissionItem> items = const [
    PermissionItem(
      title: 'Location',
      description:
          'Needed for attendance, live tracking and safe zone — including when '
          'the app is in the background.',
      why: '${PermissionReasons.location} Please choose "Allow all the time" '
          'and keep Precise location on.',
      icon: Icons.location_on_rounded,
    ),
    PermissionItem(
      title: 'Notifications',
      description:
          'Needed to receive incoming calls, chat messages and attendance / '
          'safe-zone alerts.',
      why: '${PermissionReasons.notification} Incoming calls cannot ring '
          'without this permission.',
      icon: Icons.notifications_rounded,
    ),
    PermissionItem(
      title: 'Camera',
      description: 'Used by the app features that capture photos or videos.',
      why:
          'Allows you to capture photos and videos for supported profile, chat and other app features.',
      icon: Icons.camera_alt_rounded,
    ),
    PermissionItem(
      title: 'Microphone / Audio',
      description:
          'Used by voice, walkie-talkie, and calling features where applicable.',
      why:
          'Allows voice communication, walkie-talkie transmission and calls when you use these features.',
      icon: Icons.mic_rounded,
    ),
    PermissionItem(
      title: 'Contacts',
      description:
          'Used to discover or select contacts for contact-related app features.',
      why:
          'Helps you find and select contacts when using supported contact-related features.',
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
    return 'Allow ${items[idx].title}';
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
    _checkInitialAndContinue();
  }

  @override
  void onClose() {
    _gateWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Login / Register always route here. If every compulsory permission is
  /// already granted, skip this screen and go straight to Home.
  Future<void> _checkInitialAndContinue() async {
    try {
      await checkAllPermissionStatus();
      if (canContinue) {
        _goHome();
        return;
      }
      _selectAndExpandPermission(_firstPendingIndex() ?? locationIndex);
    } catch (_) {
      // Show the screen so the user can grant manually.
    } finally {
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
    final r = await gate.check();

    final granted = <int>{};
    if (r.locationOk) granted.add(locationIndex);
    if (r.notificationOk) granted.add(notificationIndex);

    for (int i = 2; i < items.length; i++) {
      final p = _permissionForIndex(i);
      if (p == null) continue;
      try {
        final s = await gate.backend.status(p);
        if (s.isGranted || s.isLimited) granted.add(i);
      } catch (_) {}
    }

    grantedItems
      ..clear()
      ..addAll(granted);
    grantedItems.refresh();
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
        PermissionFlow.showMessage('Please allow Location first.');
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
      PermissionFlow.showMessage(e.message ?? 'Unable to request permission.');
    } catch (e) {
      PermissionFlow.showMessage('Something went wrong. Please try again.');
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
        '${items[idx].title} permission was not granted. Please try again.',
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
        'Location and Notification permissions are required to continue.',
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
        return 'Camera permission is needed to capture photos and videos. Please enable it from app settings.';
      case 3:
        return 'Microphone permission is needed for voice, walkie-talkie and calls. Please enable it from app settings.';
      case 4:
        return 'Contacts permission is needed to find and select contacts. Please enable it from app settings.';
      default:
        return 'This permission is needed. Please enable it from app settings.';
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
                'Permission Required',
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
                            'Cancel',
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
                            'Open Settings',
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
