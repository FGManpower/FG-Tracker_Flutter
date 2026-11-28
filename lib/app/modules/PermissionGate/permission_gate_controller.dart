import 'dart:async';

import 'package:get/get.dart';

import '../../Data/Services/PermissionGate/permission_flow.dart';
import '../../Data/Services/PermissionGate/permission_gate_models.dart';
import '../../Data/Services/PermissionGate/permission_gate_service.dart';
import '../../routes/app_pages.dart';
import '../auth/Controller/logout_controller.dart';

/// Blocking "Permissions Required" screen. Shown to any logged-in user while a
/// compulsory permission is missing. Unlocks by itself (→ Home) as soon as the
/// gate allows access, e.g. when the user comes back from Settings.
class PermissionGateController extends GetxController {
  PermissionGateController({Future<void> Function()? onLogout})
      : _onLogout = onLogout;

  final Future<void> Function()? _onLogout;

  late final PermissionGateService gate = PermissionGateService.to;
  late final PermissionFlow flow = PermissionFlow(gate);

  final RxBool busy = false.obs;
  bool _left = false;
  Worker? _worker;

  PermissionGateResult? get result => gate.result.value;

  bool get locationRequired => gate.flags.requireLocation;
  bool get notificationRequired => gate.flags.requireNotification;

  @override
  void onInit() {
    super.onInit();
    _worker = ever<PermissionGateResult?>(gate.result, _onResult);
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(gate.check());
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }

  void _onResult(PermissionGateResult? r) {
    if (r == null || !r.allowsAccess || _left) return;
    // Wait for any running request flow (its dialogs) to finish first.
    if (gate.isBusy) return;
    _left = true;
    Get.offAllNamed(Routes.Home_Screen);
  }

  Future<void> _run(Future<PermissionGateResult> Function() action) async {
    if (busy.value) return;
    busy.value = true;
    try {
      await action();
    } finally {
      busy.value = false;
    }
    _onResult(gate.result.value);
  }

  Future<void> fixLocation() => _run(flow.fixLocation);
  Future<void> fixNotification() => _run(flow.fixNotification);
  Future<void> retry() => _run(gate.check);

  Future<void> openSettings() async {
    await flow.openSettings();
  }

  /// Only enabled when nothing blocks (normally we auto-navigate anyway).
  void continueToApp() => _onResult(gate.result.value);

  Future<void> logout() async {
    if (busy.value) return;
    busy.value = true;
    try {
      _left = true;
      if (_onLogout != null) {
        await _onLogout();
      } else {
        await logOutController().logOutUser();
      }
    } finally {
      busy.value = false;
    }
  }
}
