import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/logoutuser.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SignallingService {
  Socket? socket;

  SignallingService._();
  static final instance = SignallingService._();

  void init({
    required String websocketUrl,
    required String selfCallerID,
  }) {
    log("Initializing Call Signaling Socket…");

    if (socket != null) {
      try {
        socket!.dispose();
      } catch (_) {}
      socket = null;
    }

    final s = io(
      "$websocketUrl/callSignaling",
      {
        "transports": ["websocket"],
        "query": {"callerId": selfCallerID},
        "autoConnect": true,
        "forceNew": true,
      },
    );
    socket = s;

    CallKitService.instance.bindSocket(s);

    s.onConnect((_) {
      log("Call Socket Connected (ID: $selfCallerID)");
    });

    s.on('force_logout', (data) {
      log("force_logout received on callSignaling socket: $data");
      LogoutUser().handleForceLogout();
    });

    s.onDisconnect((_) {
      log("Call Socket Disconnected");
    });

    s.on("callRejected", (data) async {
      log('CallRejectedByRemoteUser: $data');
      if (data is Map) {
        final sessionId = data['sessionId'] ??
            data['callId'] ??
            data['session_id'] ??
            data['id'];
        final sid = sessionId?.toString();
        if (sid != null && sid.isNotEmpty && sid != 'null') {
          await CallKitService.dismiss(sid);
          if (CallSessionState.sessionId == sid) {
            CallSessionState.reset();
          }
        }
      }
    });

    s.on("callEnded", (data) async {
      log('CallEndedFromRemote: $data');
      final sessionId = _extractSessionId(data);
      if (sessionId.isEmpty) return;

      // Do not overwrite the live session id: callEnded() resets it only
      // when this event is for the live call.
      await callEnded(sessionId, type: "socketCallEnded");
    });

    // Event names only: payloads carry SDP / ICE candidates (no full SDP in
    // logs).
    s.onAny((event, dynamic data) {
      if (kDebugMode) log("[CALL] signaling event: $event");
    });

    s.on('cancelMissedCallTimer', (data) {
      log("Cancel missed call timer received");
    });

    // A `newCall` during a live call is handled by the call screen (waiting
    // banner: End & accept / Decline, BUG-CALL-05). The old handler here
    // replaced the global CallKit accept handler, ended the current call and
    // opened the new one after a fixed 2 s, and never restored the handler.
    s.onConnectError((err) {
      log("Connect Error: $err");
    });

    s.onError((err) {
      log("Socket Error: $err");
    });
  }

  /// Returns the CURRENT socket once it is connected, or `null` after
  /// [timeout]. Creates it from the saved user id if it does not exist yet.
  /// Callers must read the socket through this service and never keep their
  /// own copy: it is re-created on login (BUG-CALL-02).
  Future<Socket?> ensureConnected({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    Socket? s = socket;
    if (s == null) {
      final dynamic userId = Global.storageServices.get(PrefConst.userId);
      if (userId == null || userId.toString().isEmpty) return null;
      init(websocketUrl: ConstRes.socketUrl, selfCallerID: userId.toString());
      s = socket;
      if (s == null) return null;
    }
    if (s.connected) return s;

    final Socket target = s;
    final Completer<bool> done = Completer<bool>();
    void onConnect(dynamic _) {
      if (!done.isCompleted) done.complete(true);
    }

    target.on('connect', onConnect);
    if (!target.active) target.connect();
    final bool ok = await done.future
        .timeout(timeout, onTimeout: () => target.connected);
    target.off('connect', onConnect);
    if (kDebugMode) log('[CALL] signaling ensureConnected ok=$ok');
    return ok && identical(target, socket) ? target : null;
  }

  void disconnect() {
    if (socket != null) {
      log("Disconnecting call socket…");
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }
  }

  static String _extractSessionId(dynamic data) {
    if (data is! Map) return '';
    final v = data['sessionId'] ??
        data['session_id'] ??
        data['callId'] ??
        data['call_id'];
    final s = v?.toString() ?? '';
    return (s == 'null') ? '' : s;
  }
}

Future<void> callEnded(String sessionId, {String? type}) async {
  if (sessionId.isEmpty || sessionId == 'null') return;

  await CallKitService.dismiss(sessionId);
  log('CallEnded: $sessionId, Type: $type');

  final current = CallSessionState.sessionId;
  if (current == null || current.isEmpty || current == sessionId) {
    CallSessionState.reset();
  }
}
