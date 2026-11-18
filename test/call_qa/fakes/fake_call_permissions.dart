// Scriptable device + UI for the call permission flow (Phase 2).
// Same idea as test/support/fake_permission_backend.dart (gate), but for
// calls: microphone, camera, Bluetooth, notifications, full-screen intent.
import 'dart:async';

import 'package:fgtracker/app/modules/mediaStream/Services/call_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

class FakeCallPermissionBackend extends CallPermissionBackend {
  FakeCallPermissionBackend({
    Map<Permission, CallPermStatus>? statuses,
    this.android = true,
  }) : statuses = statuses ?? <Permission, CallPermStatus>{};

  /// Everything granted (default for call lifecycle tests).
  factory FakeCallPermissionBackend.allGranted() => FakeCallPermissionBackend(
        statuses: <Permission, CallPermStatus>{
          Permission.microphone: CallPermStatus.granted,
          Permission.camera: CallPermStatus.granted,
          Permission.bluetoothConnect: CallPermStatus.granted,
          Permission.notification: CallPermStatus.granted,
        },
      );

  final Map<Permission, CallPermStatus> statuses;

  /// What the next system dialog answers (default: unchanged).
  final Map<Permission, CallPermStatus> onRequest =
      <Permission, CallPermStatus>{};

  /// What the user changed in Settings before coming back (P-03 / P-12).
  final Map<Permission, CallPermStatus> afterSettings =
      <Permission, CallPermStatus>{};

  bool android;
  bool fullScreenAllowed = true;
  bool fullScreenAfterRequest = true;
  bool primerShown = false;

  final List<Permission> requests = <Permission>[];
  int settingsOpened = 0;
  int resumes = 0;
  int fullScreenRequests = 0;

  CallPermStatus _of(Permission p) => statuses[p] ?? CallPermStatus.canAsk;

  @override
  Future<CallPermStatus> status(Permission p) async => _of(p);

  /// Permissions whose system dialog never answers (iOS lock screen: the
  /// prompt only shows once the app is in front).
  final Set<Permission> hangOnRequest = <Permission>{};

  @override
  Future<CallPermStatus> request(Permission p) async {
    requests.add(p);
    if (hangOnRequest.contains(p)) {
      return Completer<CallPermStatus>().future; // never completes
    }
    final CallPermStatus? answer = onRequest[p];
    if (answer != null) statuses[p] = answer;
    return _of(p);
  }

  @override
  Future<void> openSettings() async {
    settingsOpened++;
    statuses.addAll(afterSettings);
  }

  @override
  Future<void> waitForResume({
    Duration timeout = const Duration(minutes: 2),
  }) async =>
      resumes++;

  @override
  bool get isAndroid => android;

  @override
  Future<bool> canUseFullScreenIntent() async => !android || fullScreenAllowed;

  @override
  Future<void> requestFullScreenIntent() async {
    fullScreenRequests++;
    fullScreenAllowed = fullScreenAfterRequest;
  }

  @override
  Future<bool> micPrimerShown() async => primerShown;

  @override
  Future<void> markMicPrimerShown() async => primerShown = true;
}

/// Answers sheets from a script; records what was shown.
class FakeCallPermissionUi implements CallPermissionUi {
  FakeCallPermissionUi([List<CallPermChoice>? answers])
      : answers = answers ?? <CallPermChoice>[];

  final List<CallPermChoice> answers;
  final List<CallPermSheet> shown = <CallPermSheet>[];

  @override
  Future<CallPermChoice> show(CallPermSheet sheet) async {
    shown.add(sheet);
    return answers.isEmpty ? CallPermChoice.cancel : answers.removeAt(0);
  }
}
