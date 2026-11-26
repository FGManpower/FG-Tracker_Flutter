import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart'
    show kCallRingTimeout;
import 'package:fgtracker/app/modules/mediaStream/Services/call_events.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/voip_token_uploader.dart';

import '../Socket/Socket_SignallingService.dart';
import '../group_call_service.dart';

/// Android system incoming-call screen colours, matching the in-app call
/// design (CallColors in call_widget.dart). Hex because the plugin takes
/// strings. iOS shows Apple's CallKit UI, which apps cannot restyle.
const String kCallKitAudioBackground = '#3A2A9E'; // deep CallColors.primary
const String kCallKitVideoBackground = '#0E0C14'; // CallColors.videoBg
const String kCallKitAcceptColor = '#16B364'; // CallColors.accept

String kCallKitBackgroundColor({required bool isVideo}) =>
    isVideo ? kCallKitVideoBackground : kCallKitAudioBackground;

typedef CallActionCallback = FutureOr<void> Function(
  String callId,
  Map<String, dynamic> extra,
  String? uuid,
);

void _ck(String msg) {
  if (kDebugMode) {
    dev.log('[CK] $msg');
  }
}

class CallKitService with WidgetsBindingObserver {
  CallKitService._();

  static final instance = CallKitService._();

  StreamSubscription? _sub;
  bool _inited = false;
  bool _appReady = false;
  bool _usingOnAny = false;

  bool get isCallKitActive => _showing.isNotEmpty;

  Map<String, dynamic>? pendingAccept;

  static const MethodChannel _callkitEvents = MethodChannel(
    'com.fgtracker.callkit_events',
  );

  static FutureOr<void> Function(String handle, bool isVideo)?
      onRecentsCallback;

  static final Set<String> _selfEnded = {};
  static DateTime? _selfEndedAllAt;

  static final Set<String> _accepted = {};

  static final Set<String> _showing = {};

  static final Map<String, DateTime> _shown = {};

  static final Map<String, String> _uuidByKey = {};

  static String mappedUuid(String key) => _uuidByKey[key] ?? '';

  // ───────────────────────────────────────────────────────────────────────────
  // NEW: audio ownership handover (Android Telecom / ConnectionService)
  // ───────────────────────────────────────────────────────────────────────────
  // Incoming call par flutter_callkit_incoming ek self-managed ConnectionService
  // call banata hai. Jab tak wo call zinda hai, Android Telecom audio route ka
  // owner hota hai (default = earpiece) aur app ki koi bhi route request
  // (setSpeakerphoneOn / setCommunicationDevice) ignore ho jati hai.
  // Isi liye "call receive karne par speaker kaam nahi karta, khud call karne
  // par karta hai".
  //
  // In-app call screen jab media sambhal le, tab CallKit call ko end kar dete
  // hain -> Telecom ka route client hat jata hai -> flutter_webrtc ka
  // AudioSwitch asli owner ban jata hai. Call zinda rehti hai kyunki dismiss()
  // `_selfEnded` me id daal deta hai, jisse aane wala `actionCallEnded` event
  // ignore ho jata hai (onEndCall fire nahi hota).
  static final Set<String> _audioHandover = {};

  static bool isAudioHandoverActive(String sessionId) =>
      _audioHandover.contains(sessionId);

  static const Set<String> _socketEndEvents = {
    'callEnded',
    'endCall',
    'call_ended',
    'callRejected',
    'cancelCall',
    'groupCallEnded',
    // agreed with the backend (caller cancel / ring timeout)
    'callCancelled',
    'call_cancelled',
    'callCanceled',
    'call_canceled',
  };

  static const Set<String> _socketMissedEvents = {
    'missedCall',
    'missCall',
    'missedGroupCall',
  };

  static const Set<String> _terminalStatuses = {
    'missed',
    'missedcall',
    'ended',
    'callended',
    'rejected',
    'declined',
    'cancelled',
    'canceled',
    'disconnected',
  };

  CallActionCallback? onAcceptCall;
  CallActionCallback? onDeclineCall;
  CallActionCallback? onTimeoutCall;
  CallActionCallback? onEndCall;
  Future<void> Function(String token)? onVoipToken;
  Future<String?> Function(String callId)? getCallStatus;

  /// True while a 1:1 call is live in the app (set by call_kit_handlers).
  /// A second call then goes to the call screen's waiting banner instead
  /// of the system incoming UI (BUG-CALL-05).
  bool Function()? isInCall;
  void Function(Map<String, dynamic> data)? onCallWaiting;

  /// CallKit / lock-screen mute and hold (BUG-CALL-12), and "Call back" on
  /// the missed-call notification.
  void Function(String id, bool muted)? onMuteChanged;
  void Function(String id, bool onHold)? onHoldChanged;
  void Function(Map<String, dynamic> extra)? onCallback;

  /// An "end" push (FCM `callEnded` / `signal_type: endCall`) arrived. The
  /// live call checks whether it names it (set by call_kit_handlers). A
  /// second path for a hang-up whose socket `callEnded` was lost.
  void Function(String sessionId, String callId)? onRemoteEndPush;

  void _notifyRemoteEndPush(String sessionId, String callId) {
    try {
      onRemoteEndPush?.call(sessionId, callId);
    } catch (e) {
      _ck('onRemoteEndPush error: $e');
    }
  }

  static void _registerUuidMapping({
    String? uuid,
    String? sessionId,
    String? callId,
  }) {
    if (uuid == null || uuid.isEmpty) return;
    _uuidByKey[uuid] = uuid;
    if (sessionId != null && sessionId.isNotEmpty) {
      _uuidByKey[sessionId] = uuid;
    }
    if (callId != null && callId.isNotEmpty) {
      _uuidByKey[callId] = uuid;
    }
  }

  void _clearPendingAcceptMatching({
    String? uuid,
    String? sessionId,
    String? callId,
    bool forceAll = false,
  }) {
    final p = pendingAccept;
    if (p == null) return;
    if (forceAll) {
      pendingAccept = null;
      return;
    }
    final pUuid = p['uuid']?.toString() ?? '';
    final pSid = p['sessionId']?.toString() ?? '';
    final pCid = p['callId']?.toString() ?? '';
    final matched =
        (uuid != null && uuid.isNotEmpty && (uuid == pUuid || uuid == pSid)) ||
            (sessionId != null &&
                sessionId.isNotEmpty &&
                (sessionId == pSid || sessionId == pUuid)) ||
            (callId != null && callId.isNotEmpty && callId == pCid);
    if (matched) {
      _ck(
        'Clearing stale pendingAccept for ended/declined call '
        'callId=$pCid sessionId=$pSid',
      );
      pendingAccept = null;
    }
  }

  static dynamic _field(dynamic obj, String key) {
    if (obj == null) return null;
    if (obj is Map) return obj[key];
    try {
      final json = (obj as dynamic).toJson();
      if (json is Map) return json[key];
    } catch (_) {}
    try {
      final map = (obj as dynamic).toMap();
      if (map is Map) return map[key];
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return <String, dynamic>{};
  }

  static String _eventName(dynamic e) {
    dynamic raw;
    try {
      raw = (e as dynamic).event;
    } catch (_) {}
    if (raw == null) {
      try {
        raw = (e as dynamic).eventName;
      } catch (_) {}
    }
    if (raw == null) {
      try {
        raw = (e as dynamic).name;
      } catch (_) {}
    }
    return (raw ?? '')
        .toString()
        .split('.')
        .last
        .replaceAll('_', '')
        .toLowerCase();
  }

  static dynamic _eventBody(dynamic e) {
    final getters = <dynamic Function()>[
      () => (e as dynamic).body,
      () => (e as dynamic).data,
      () => (e as dynamic).args,
      () => (e as dynamic).arguments,
      () => (e as dynamic).payload,
      () => (e as dynamic).toJson(),
      () => (e as dynamic).toMap(),
    ];
    for (final g in getters) {
      try {
        final v = g();
        if (v is Map && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return null;
  }

  static Map<String, dynamic> _extractAcceptPayload(dynamic e) {
    final result = <String, dynamic>{
      'uuid': null,
      'callId': '',
      'sessionId': '',
      'extra': <String, dynamic>{},
    };

    dynamic ckp;
    try {
      ckp = (e as dynamic).callKitParams;
    } catch (_) {}

    if (ckp != null) {
      final id = _field(ckp, 'id')?.toString();
      if (id != null && id.isNotEmpty) {
        result['uuid'] = id;
        result['sessionId'] = id;
      }
      final ckpExtra = _asMap(_field(ckp, 'extra'));
      if (ckpExtra.isNotEmpty) {
        result['extra'] = ckpExtra;
        final cid = ckpExtra['callId']?.toString() ??
            ckpExtra['call_id']?.toString() ??
            '';
        if (cid.isNotEmpty) result['callId'] = cid;
        final sid = ckpExtra['session_id']?.toString() ??
            ckpExtra['sessionId']?.toString();
        if (sid != null && sid.isNotEmpty) {
          result['sessionId'] = sid;
          result['uuid'] ??= sid;
        }
      }
      _registerUuidMapping(
        uuid: result['uuid']?.toString(),
        sessionId: result['sessionId']?.toString(),
        callId: result['callId']?.toString(),
      );
      return result;
    }

    final body = _asMap(_eventBody(e));
    if (body.isNotEmpty) {
      final id = body['id']?.toString();
      if (id != null && id.isNotEmpty) {
        result['uuid'] = id;
        result['sessionId'] = id;
      }
      final extra = _asMap(body['extra']);
      if (extra.isNotEmpty) {
        result['extra'] = extra;
        final cid =
            extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
        if (cid.isNotEmpty) result['callId'] = cid;
        final sid =
            extra['session_id']?.toString() ?? extra['sessionId']?.toString();
        if (sid != null && sid.isNotEmpty) {
          result['sessionId'] = sid;
          result['uuid'] ??= sid;
        }
      } else {
        final topSid = body['sessionId']?.toString();
        if (topSid != null && topSid.isNotEmpty) {
          result['sessionId'] = topSid;
          result['uuid'] ??= topSid;
        }
      }
      _registerUuidMapping(
        uuid: result['uuid']?.toString(),
        sessionId: result['sessionId']?.toString(),
        callId: result['callId']?.toString(),
      );
    }
    return result;
  }

  static Map<String, dynamic> decodeCallData(dynamic raw) {
    try {
      if (raw is String && raw.isNotEmpty) return _asMap(jsonDecode(raw));
      return _asMap(raw);
    } catch (_) {
      return {};
    }
  }

  static Future<bool> _isAccepted(
    String sessionId, {
    String callId = '',
  }) async {
    final targetUuid = _uuidByKey[sessionId] ?? sessionId;
    final targetCallUuid =
        callId.isNotEmpty ? (_uuidByKey[callId] ?? callId) : '';
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is List) {
        for (final c in calls) {
          final cid = _field(c, 'id')?.toString() ?? '';
          final extra = _asMap(_field(c, 'extra'));
          final sid =
              extra['session_id']?.toString() ?? extra['sessionId']?.toString();
          final extraCallId =
              extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
          if (cid == targetUuid ||
              cid == sessionId ||
              sid == sessionId ||
              (callId.isNotEmpty &&
                  (cid == targetCallUuid ||
                      cid == callId ||
                      extraCallId == callId))) {
            return _field(c, 'isAccepted') == true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  static dynamic decodeOffer(dynamic compressed) {
    try {
      final s = compressed?.toString() ?? '';
      if (s.isEmpty) return null;
      return jsonDecode(utf8.decode(gzip.decode(base64Decode(s))));
    } catch (e) {
      _ck('decodeOffer error: $e');
      return null;
    }
  }

  Future<void> init() async {
    _ck('init() called, alreadyInited=$_inited');
    if (_inited) return;
    _inited = true;

    WidgetsBinding.instance.addObserver(this);

    _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(
      (dynamic e) => _onEvent(e),
      onError: (err) => _ck('onEvent stream ERROR: $err'),
    );
    _ck('event listener ATTACHED');

    _callkitEvents.setMethodCallHandler(_onCallkitEvent);

    bool hasActiveCallNow = false;
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is List && calls.isNotEmpty) {
        hasActiveCallNow = true;
      }
    } catch (_) {}

    await _recoverAcceptedCall();

    unawaited(postInitBackgroundTasks(skipPermissions: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _ensureSocketHandlersAttached();
    if (state == AppLifecycleState.resumed) {
      unawaited(restoreActiveCalls());
      if (Platform.isIOS) {
        unawaited(syncVoipToken(force: false));
      }
    }
  }

  Future<void> postInitBackgroundTasks({required bool skipPermissions}) async {
    if (!skipPermissions) {
      try {
        final l = await loadAppL10nFromPrefs();
        await FlutterCallkitIncoming.requestNotificationPermission({
          'title': l.call_notificationPermissionTitle,
          'rationaleMessagePermission': l.call_notificationPermissionRationale,
          'postNotificationMessageRequired':
              l.call_notificationPermissionSettings,
        });
        if (Platform.isAndroid) {
          final ok = await FlutterCallkitIncoming.canUseFullScreenIntent();
          _ck('canUseFullScreenIntent=$ok');
          if (ok != true) {
            await FlutterCallkitIncoming.requestFullIntentPermission();
          }
        }
      } catch (e) {
        _ck('permission error: $e');
      }
    }

    if (Platform.isIOS) {
      try {
        final t = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
        _ck('VoIP token received (length ${t?.toString().length ?? 0})');
        if (t != null && t.toString().isNotEmpty) {
          await _uploadVoipToken(t.toString());
        }
      } catch (e) {
        _ck('VoIP token error: $e');
      }
    }

    await restoreActiveCalls();
  }

  Future<void> _recoverAcceptedCall() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      _ck('_recoverAcceptedCall activeCalls=$calls');
      if (calls is! List) return;
      for (final c in calls) {
        if (_field(c, 'isAccepted') != true) continue;
        final uuid = _field(c, 'id')?.toString();
        if (uuid == null || _accepted.contains(uuid)) continue;
        final extra = _asMap(_field(c, 'extra'));
        final sessionId = extra['session_id']?.toString() ??
            extra['sessionId']?.toString() ??
            uuid;
        final callId =
            extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
        // P-11: the app was killed during this call (e.g. a permission was
        // revoked in Settings). If the server says the call is over, clear
        // CallKit instead of reopening a ghost call. Unknown status (offline)
        // keeps the old behaviour: reopen.
        if (callId.isNotEmpty && getCallStatus != null) {
          final String? status = (await getCallStatus!(callId))?.toLowerCase();
          if (status != null && _terminalStatuses.contains(status)) {
            _ck('recover skipped: call $callId already $status');
            await dismiss(sessionId, callId: callId, endAllUnaccepted: true);
            continue;
          }
        }
        _registerUuidMapping(uuid: uuid, sessionId: sessionId, callId: callId);
        _accepted.add(uuid);
        _ck(
          'recovered accepted call uuid=$uuid sessionId=$sessionId callId=$callId',
        );
        await _handleAccept(callId, extra, uuid, sessionId: sessionId);
      }
    } catch (e) {
      _ck('_recoverAcceptedCall error: $e');
    }
  }

  static Future<dynamic> _onCallkitEvent(MethodCall call) async {
    if (call.method != 'recentsCallback') return null;
    final Map<String, dynamic> args =
        (call.arguments as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final String handle = args['handle']?.toString() ?? '';
    final bool isVideo = args['isVideo'] == true;
    _ck('recentsCallback from CallKit handle=$handle isVideo=$isVideo');
    if (handle.isEmpty) return false;
    if (onRecentsCallback == null) {
      _ck('recentsCallback has no handler registered - ignored');
      return false;
    }
    try {
      await onRecentsCallback!(handle, isVideo);
      return true;
    } catch (e, st) {
      _ck('recentsCallback handler THREW: $e\n$st');
      return false;
    }
  }

  static String _iosHandle(
    Map<String, dynamic> extra,
    String fallbackName,
    String callId, {
    String unknownLabel = 'Unknown',
  }) {
    for (final String key in <String>[
      'callerPhone',
      'caller_phone',
      'phone',
      'mobile',
      'callerNumber',
    ]) {
      final String v = (extra[key] ?? '').toString().trim();
      if (v.isNotEmpty) return v;
    }
    for (final String key in <String>[
      'callerId',
      'caller_id',
      'remoteUserId',
    ]) {
      final String v = (extra[key] ?? '').toString().trim();
      if (v.isNotEmpty && v != '0') return v;
    }
    if (fallbackName.trim().isNotEmpty) return fallbackName.trim();
    if (callId.trim().isNotEmpty) return callId.trim();
    return unknownLabel;
  }

  static Map<String, dynamic> _sanitizedExtra(Map<String, dynamic> extra) {
    const List<String> blocked = <String>[
      'token',
      'jwt',
      'authorization',
      'bearer',
      'password',
      'secret',
      'cookie',
      'api_key',
      'apikey',
    ];
    final Map<String, dynamic> clean = <String, dynamic>{};
    extra.forEach((String key, dynamic value) {
      final String lowered = key.toLowerCase();
      final bool bad = blocked.any((String b) => lowered.contains(b));
      if (!bad) clean[key] = value;
    });
    return clean;
  }

  Future<void> markAppReady() async {
    _ck(
      'markAppReady() pendingAccept=$pendingAccept '
      'onAcceptCall=${onAcceptCall != null}',
    );
    _appReady = true;
    if (Platform.isIOS) {
      unawaited(syncVoipToken(force: true));
    }
    final p = pendingAccept;
    if (p != null && onAcceptCall != null) {
      pendingAccept = null;
      final callId = p['callId']?.toString() ?? '';
      final uuid = p['uuid']?.toString() ?? '';
      final sessionId = p['sessionId']?.toString() ?? uuid;
      _ck(
        'markAppReady -> opening pending accept callId=$callId sessionId=$sessionId',
      );
      _ck('markAppReadyprofileImage:${p['profileImage']}');
      try {
        await onAcceptCall!(callId, p, uuid);
        _ck('onAcceptCall finished OK');
      } catch (e, st) {
        _ck('onAcceptCall THREW: $e\n$st');
      }
    }
  }

  static Future<void> showIncoming({
    required String sessionId,
    String callId = '',
    required String callerName,
    required bool isVideo,
    String avatar = '',
    Map<String, dynamic> extra = const {},
    dynamic expiresAt,
  }) async {
    final id = sessionId;

    // Server ring deadline (backend point 3). Stale = a push delivered long
    // after the call expired (phone was off): do not ring a dead call.
    // Otherwise ring only for the time left. No timestamps: app default.
    final Duration? ringLeft = remainingRingTime(
      expiresAt: expiresAt ?? extra['expiresAt'] ?? extra['expires_at'],
      now: DateTime.now(),
      max: kCallRingTimeout,
    );
    if (ringLeft == Duration.zero) {
      final dynamic rawExp = expiresAt ?? extra['expiresAt'] ?? extra['expires_at'];
      final DateTime? exp = parseServerTime(rawExp);
      final int diffSec = exp != null ? DateTime.now().toUtc().difference(exp).inSeconds.abs() : 999;
      if (diffSec <= 180) {
        _ck('showIncoming ringLeft zero but diff <= 180s (possible clock skew), using 15s fallback sessionId=$id');
      } else {
        _ck('showIncoming SKIPPED (expired) sessionId=$id');
        return;
      }
    }

    // NEW: in-app call already is call ka audio sambhal raha hai -> dobara
    // Telecom connection khada karne ka matlab hoga speaker phir se toot jaye.
    if (_audioHandover.contains(id) ||
        (callId.isNotEmpty && _audioHandover.contains(callId))) {
      _ck('showIncoming SKIPPED (audio handover active) sessionId=$id');
      return;
    }

    final last = _shown[id];
    if (_showing.contains(id) ||
        (last != null && DateTime.now().difference(last).inSeconds < 60)) {
      _ck('showIncoming SKIPPED duplicate sessionId=$id');
      return;
    }
    _showing.add(id);
    _shown[id] = DateTime.now();
    _registerUuidMapping(uuid: id, sessionId: id, callId: callId);

    try {
      final active = await FlutterCallkitIncoming.activeCalls();
      if (active is List &&
          active.any((c) => _field(c, 'id')?.toString() == id)) {
        _ck('showIncoming SKIPPED already active sessionId=$id');
        return;
      }
      _ck("CallkitAvataravatar:${avatar}");
      _ck(
        'showIncoming sessionId=$id callId=$callId caller=$callerName video=$isVideo',
      );
      // May run in the FCM background isolate: read the saved language.
      final l = await loadAppL10nFromPrefs();
      final params = CallKitParams(
        id: id,
        nameCaller: callerName,
        appName: 'FG Tracker',
        avatar: avatar,
        handle:
            _iosHandle(extra, callerName, callId, unknownLabel: l.call_unknown),
        type: isVideo ? 1 : 0,
        // Same value as the caller's missed-call timer (BUG-CALL-08).
        duration: (ringLeft ?? kCallRingTimeout).inMilliseconds,
        callingNotification: const NotificationParams(),
        missedCallNotification: NotificationParams(
          showNotification: true,
          isShowCallback: true,
          callbackText: l.call_callBack,
          subtitle: l.call_missedCallNotification,
        ),
        extra: <String, dynamic>{
          ..._sanitizedExtra(extra),
          'callId': callId,
          'call_id': callId,
          'session_id': id,
          'sessionId': id,
        },
        android: AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          // App call design (CallColors): the old default blue #0955fa
          // looked like a different app. Native text is white, so a deep
          // brand purple for voice and the dark video background for video.
          backgroundColor: kCallKitBackgroundColor(isVideo: isVideo),
          actionColor: kCallKitAcceptColor,
          textColor: '#FFFFFF',
          incomingCallNotificationChannelName: l.call_incomingCallChannelName,
          missedCallNotificationChannelName: l.call_missedCallChannelName,
          textAccept: l.call_accept,
          textDecline: l.call_decline,
        ),
        ios: IOSParams(
          handleType: 'generic',
          normalHandle: 1,
          supportsVideo: isVideo,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: isVideo ? 'videoChat' : 'voiceChat',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: false,
          // Hold / resume from CallKit (e.g. a cellular call comes in).
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e, st) {
      _ck('showIncoming ERROR: $e\n$st');
    } finally {
      _showing.remove(id);
    }
  }

  static Future<void> dismiss(
    String sessionId, {
    String callId = '',
    bool endAllUnaccepted = false,
  }) async {
    if (sessionId.isEmpty && callId.isEmpty && !endAllUnaccepted) return;

    final resolvedUuid =
        sessionId.isNotEmpty ? (_uuidByKey.remove(sessionId) ?? sessionId) : '';
    final resolvedCallUuid =
        callId.isNotEmpty ? (_uuidByKey.remove(callId) ?? callId) : '';

    final lookupKeys = <String>{
      if (sessionId.isNotEmpty) sessionId,
      if (resolvedUuid.isNotEmpty) resolvedUuid,
      if (callId.isNotEmpty) callId,
      if (resolvedCallUuid.isNotEmpty) resolvedCallUuid,
    };

    _uuidByKey.removeWhere(
      (k, v) => lookupKeys.contains(k) || lookupKeys.contains(v),
    );

    final idsToEnd = <String>{...lookupKeys};
    bool matchedActiveCall = false;
    bool hasUnacceptedActiveCall = false;
    bool hasAcceptedDifferentCall = false;

    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is List) {
        for (final c in calls) {
          final activeId = _field(c, 'id')?.toString() ?? '';
          final isAccepted = _field(c, 'isAccepted') == true;
          final extra = _asMap(_field(c, 'extra'));
          final sid = extra['session_id']?.toString() ??
              extra['sessionId']?.toString() ??
              '';
          final cid =
              extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';

          final activeIdentifiers = <String>{
            if (activeId.isNotEmpty) activeId,
            if (sid.isNotEmpty) sid,
            if (cid.isNotEmpty) cid,
          };

          final isMatch =
              activeIdentifiers.any((id) => lookupKeys.contains(id));

          if (isMatch) {
            matchedActiveCall = true;
            if (activeId.isNotEmpty) idsToEnd.add(activeId);
            if (sid.isNotEmpty) idsToEnd.add(sid);
          } else if (!isAccepted) {
            if (cid.isEmpty || callId.isEmpty || cid == callId) {
              hasUnacceptedActiveCall = true;
              if (endAllUnaccepted && activeId.isNotEmpty) {
                idsToEnd.add(activeId);
              }
            }
          } else {
            hasAcceptedDifferentCall = true;
          }
        }
      }
    } catch (_) {}

    instance._clearPendingAcceptMatching(
      uuid: resolvedUuid.isNotEmpty ? resolvedUuid : resolvedCallUuid,
      sessionId: sessionId,
      callId: callId,
    );

    _ck(
      'dismiss targets=$idsToEnd matched=$matchedActiveCall '
      '(requested=$sessionId callId=$callId endAllUnaccepted=$endAllUnaccepted)',
    );

    for (final target in idsToEnd) {
      if (target.isEmpty) continue;
      _selfEnded.add(target);
      // R80: 10s -> 60s. Slow cold start par actionCallEnded late aata hai;
      // suppression khatam hone par onEndCall fire ho kar call cut kar deta tha.
      Timer(const Duration(seconds: 60), () => _selfEnded.remove(target));
      _accepted.remove(target);
      _shown.remove(target);
      try {
        await FlutterCallkitIncoming.hideCallkitIncoming(
          CallKitParams(id: target),
        );
      } catch (_) {}
      try {
        await FlutterCallkitIncoming.endCall(target);
      } catch (e) {
        _ck('dismiss error for $target: $e');
      }
    }

    if (endAllUnaccepted &&
        !hasAcceptedDifferentCall &&
        (_accepted.isEmpty || hasUnacceptedActiveCall || !matchedActiveCall)) {
      _selfEndedAllAt = DateTime.now();
      _shown.clear();
      try {
        await FlutterCallkitIncoming.endAllCalls();
      } catch (e) {
        _ck('dismiss endAllCalls fallback error: $e');
      }
    }
  }

  static Future<void> dismissAll() async {
    instance._clearPendingAcceptMatching(forceAll: true);
    _selfEndedAllAt = DateTime.now();
    _accepted.clear();
    _shown.clear();
    _uuidByKey.clear();
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (e) {
      _ck('dismissAll error: $e');
    }
  }

  static Future<void> markMissed({
    required String sessionId,
    String callId = '',
    required String callerName,
    required bool isVideo,
  }) async {
    final id = sessionId;
    final accepted = await _isAccepted(id, callId: callId);
    _ck('markMissed sessionId=$id callId=$callId accepted=$accepted');
    if (accepted) return;
    await dismiss(id, callId: callId, endAllUnaccepted: true);
    if (Platform.isAndroid) {
      try {
        // May run in the FCM background isolate: read the saved language.
        final l = await loadAppL10nFromPrefs();
        await FlutterCallkitIncoming.showMissCallNotification(
          CallKitParams(
            id: id.isNotEmpty ? id : callId,
            nameCaller: callerName,
            handle: callerName,
            type: isVideo ? 1 : 0,
            missedCallNotification: NotificationParams(
              showNotification: true,
              isShowCallback: true,
              callbackText: l.call_callBack,
              subtitle: l.call_missedCallNotification,
            ),
            extra: {'callId': callId, 'session_id': id},
            android: AndroidParams(
              missedCallNotificationChannelName: l.call_missedCallChannelName,
            ),
          ),
        );
      } catch (e) {
        _ck('showMissCallNotification error: $e');
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // NEW: Android audio ownership handover
  // ───────────────────────────────────────────────────────────────────────────
  /// In-app call screen ne audio sambhal liya. Telecom (self-managed
  /// ConnectionService) ka route client hata do, warna speaker/earpiece ki
  /// saari requests ignore hoti rahengi.
  ///
  /// Ye `dismiss()` ko reuse karta hai — matlab `_selfEnded` suppression +
  /// `hideCallkitIncoming` + `endCall` sab already tested path se hota hai,
  /// aur `actionCallEnded` aane par `onEndCall` fire NAHI hoga (call zinda
  /// rahegi).
  ///
  /// iOS par ye kuch nahi karta: wahan AVAudioSession app ke control me hota
  /// hai, CallKit route override nahi karta — aur CallKit call end karne se
  /// audio session bekaar me disturb hota hai.
  ///
  /// R80: `Future<bool>` return karta hai — `true` = Telecom route client hat
  /// gaya (ya pehle hi hat chuka tha), `false` = abhi koi active CallKit call
  /// nahi mili (caller retry karega).
  static Future<bool> releaseAudioOwnership(
    String sessionId, {
    String callId = '',
  }) async {
    if (!Platform.isAndroid) return false;
    if (sessionId.isEmpty && callId.isEmpty) return false;

    final id = sessionId.isNotEmpty ? sessionId : callId;
    if (_audioHandover.contains(id)) {
      _ck('releaseAudioOwnership SKIPPED (already handed over) id=$id');
      return true;
    }

    // Sirf tab karo jab wakai koi CallKit/Telecom call active ho.
    bool hasActive = false;
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is List) {
        for (final c in calls) {
          final activeId = _field(c, 'id')?.toString() ?? '';
          final extra = _asMap(_field(c, 'extra'));
          final sid = extra['session_id']?.toString() ??
              extra['sessionId']?.toString() ??
              '';
          final cid =
              extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
          if (activeId == id ||
              activeId == sessionId ||
              sid == sessionId ||
              (callId.isNotEmpty && cid == callId)) {
            hasActive = true;
            break;
          }
        }
      }
    } catch (_) {}

    if (!hasActive) {
      _ck('releaseAudioOwnership: no active CallKit call for id=$id (retry)');
      return false;
    }

    _audioHandover.add(id);
    if (callId.isNotEmpty) _audioHandover.add(callId);
    // safety TTL — call ke baad set saaf ho jaye
    Timer(const Duration(minutes: 10), () {
      _audioHandover.remove(id);
      if (callId.isNotEmpty) _audioHandover.remove(callId);
    });

    _ck('releaseAudioOwnership id=$id callId=$callId -> ending Telecom call');
    await dismiss(id, callId: callId);
    _ck('releaseAudioOwnership done id=$id (Telecom route released)');
    return true;
  }

  /// Call khatam hone par handover flag saaf karo (controller cleanup se).
  static void clearAudioHandover(String sessionId, {String callId = ''}) {
    _audioHandover.remove(sessionId);
    if (callId.isNotEmpty) _audioHandover.remove(callId);
  }

  static Future<void> setConnected(String sessionId) async {
    if (sessionId.isEmpty) return;
    final targetUuid = _uuidByKey[sessionId] ?? sessionId;
    try {
      await FlutterCallkitIncoming.setCallConnected(targetUuid);
    } catch (e) {
      _ck('setCallConnected error: $e');
    }
  }

  static Future<bool> handlePush(Map<String, dynamic> d) async {
    final screen = d['screen_name']?.toString();
    _ck('handlePush screen=$screen keys=${d.keys.toList()}');
    final cd = decodeCallData(d['callData']);

    final sessionId = (d['session_id'] ??
            d['sessionId'] ??
            cd['session_id'] ??
            cd['sessionId'] ??
            '')
        .toString();
    final callId =
        (cd['callId'] ?? cd['call_id'] ?? d['callId'] ?? d['call_id'] ?? '')
            .toString();
    final isVideo = cd['isVideo'].toString() == "true" ? true : false;

    switch (screen) {
      case 'incomingCall':
      case 'incomingGroupCall':
        if (Platform.isIOS) {
          // If CallKit is already displaying this call from VoIP PushKit, do not duplicate.
          if (_showing.contains(sessionId) || _shown.containsKey(sessionId)) {
            return true;
          }
        }
        if (screen == 'incomingCall' && instance.isInCall?.call() == true) {
          instance.onCallWaiting?.call(<String, dynamic>{...d, 'callData': cd});
          return true;
        }
        final incomingId = sessionId.isNotEmpty ? sessionId : callId;
        if (incomingId.isEmpty) {
          _ck('handlePush incoming with EMPTY sessionId');
          return true;
        }
        if (screen == 'incomingGroupCall' && !GroupCallService.isGroupCallEnabled) {
          _ck('handlePush incomingGroupCall SKIPPED (group calls disabled)');
          return true;
        }
        final l = await loadAppL10nFromPrefs();
        final extraMap = cd.map((k, v) => MapEntry(k, v.toString()));
        if (screen != null) {
          extraMap['screen_name'] = screen;
          extraMap['screenName'] = screen;
        }
        await showIncoming(
          sessionId: incomingId,
          callId: callId,
          callerName: screen == 'incomingGroupCall'
              ? (cd['groupName'] ?? l.call_kindGroupCall).toString()
              : (cd['callerName'] ?? l.call_unknown).toString(),
          isVideo: isVideo,
          avatar: (cd['callerProfileImage'] ?? '').toString(),
          extra: extraMap,
          expiresAt: cd['expiresAt'] ?? d['expiresAt'],
        );
        return true;

      case 'callEnded':
      case 'groupCallEnded':
      case 'missedCall':
      case 'missedGroupCall':
        final endTarget =
            (d['session_id'] ?? d['sessionId'] ?? sessionId).toString();
        instance._notifyRemoteEndPush(endTarget, callId);
        await dismiss(
          endTarget.isNotEmpty ? endTarget : callId,
          callId: callId,
          endAllUnaccepted: true,
        );
        return true;
    }

    // Any end signal (today `endCall`; agreed `call_cancelled`, also as
    // `type`), on the push itself or inside callData.
    if (endSignalOf(d) != null || endSignalOf(cd) != null) {
      final endTarget =
          (d['session_id'] ?? d['sessionId'] ?? sessionId).toString();
      instance._notifyRemoteEndPush(endTarget, callId);
      await dismiss(
        endTarget.isNotEmpty ? endTarget : callId,
        callId: callId,
        endAllUnaccepted: true,
      );
      return true;
    }
    return false;
  }

  dynamic _boundSocket;

  static MapEntry<String, String> _extractEndIds(dynamic data) {
    final m = _asMap(data);
    final cd = decodeCallData(m['callData']);
    final sessionId = (m['session_id'] ??
            m['sessionId'] ??
            cd['session_id'] ??
            cd['sessionId'] ??
            '')
        .toString();
    final callId =
        (m['callId'] ?? m['call_id'] ?? cd['callId'] ?? cd['call_id'] ?? '')
            .toString();
    return MapEntry<String, String>(sessionId, callId);
  }

  late final void Function(dynamic) _hNewCall = (data) {
    final state = WidgetsBinding.instance.lifecycleState;
    _ck('socket newCall lifecycle=$state');

    if (state != null && state != AppLifecycleState.resumed) return;

    final m = _asMap(data);
    if (isInCall?.call() == true) {
      _ck("socket newCall while in a call -> waiting banner, no system UI");
      return;
    }
    final cd = decodeCallData(m['callData']);
    final sessionId = (m['session_id'] ??
            m['sessionId'] ??
            cd['session_id'] ??
            cd['sessionId'] ??
            '')
        .toString();
    final callId = (m['callId'] ?? cd['callId'] ?? '').toString();
    final incomingId = sessionId.isNotEmpty ? sessionId : callId;
    if (incomingId.isEmpty) return;
    showIncoming(
      sessionId: incomingId,
      callId: callId,
      callerName: (m['caller_name'] ?? cd['callerName'] ?? appL10n.call_unknown)
          .toString(),
      isVideo: m['isVideo'].toString() == "true" ? true : false,
      avatar: (m['caller_profile_image'] ?? cd['callerProfileImage'] ?? '')
          .toString(),
      extra: cd.map((k, v) => MapEntry(k, v.toString())),
      expiresAt: cd['expiresAt'] ?? m['expiresAt'],
    );

    // Notify caller that receiver device is actively ringing (WhatsApp parity).
    final callerTarget = cd['callerId'] ?? m['callerId'];
    if (callerTarget != null && callerTarget.toString().isNotEmpty) {
      SignallingService.instance.socket?.emit("CallingStatus", {
        "callId": callId.isNotEmpty ? callId : sessionId,
        "remoteUserId": callerTarget,
        "callingStatus": "Ringing",
      });
    }
  };

  late final void Function(dynamic) _hEnded = (data) {
    final ids = _extractEndIds(data);
    final sessionId = ids.key;
    final callId = ids.value;
    _ck(
      'socket callEnded/endCall sessionId=$sessionId callId=$callId data=$data',
    );
    dismiss(
      sessionId.isNotEmpty ? sessionId : callId,
      callId: callId,
      endAllUnaccepted: true,
    );
  };

  late final void Function(dynamic) _hMissed = (data) {
    final ids = _extractEndIds(data);
    final sessionId = ids.key;
    final callId = ids.value;
    _ck('socket missedCall sessionId=$sessionId callId=$callId data=$data');
    dismiss(
      sessionId.isNotEmpty ? sessionId : callId,
      callId: callId,
      endAllUnaccepted: true,
    );
  };

  late final void Function(dynamic) _hStatus = (data) {
    final m = _asMap(data);
    final status = (m['status'] ?? m['callingStatus'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (!_terminalStatuses.contains(status)) return;
    final ids = _extractEndIds(data);
    final sessionId = ids.key;
    final callId = ids.value;
    _ck(
      'socket terminal callStatus=$status sessionId=$sessionId callId=$callId',
    );
    dismiss(
      sessionId.isNotEmpty ? sessionId : callId,
      callId: callId,
      endAllUnaccepted: true,
    );
  };

  late final void Function(String, dynamic) _hAny = (event, data) {
    if (event == 'newCall') {
      _hNewCall(data);
    } else if (_socketEndEvents.contains(event)) {
      _hEnded(data);
    } else if (_socketMissedEvents.contains(event)) {
      _hMissed(data);
    } else if (event == 'callStatus') {
      _hStatus(data);
    }
  };

  late final void Function(dynamic) _hConnect = (_) {
    _ck('socket reconnected -> checking active calls');
    unawaited(restoreActiveCalls());
  };

  void _detachSocket(dynamic sock) {
    if (sock == null) return;
    try {
      if (_usingOnAny) {
        sock.offAny(_hAny);
      } else {
        sock.off('newCall', _hNewCall);
        for (final ev in _socketEndEvents) {
          sock.off(ev, _hEnded);
        }
        for (final ev in _socketMissedEvents) {
          sock.off(ev, _hMissed);
        }
        sock.off('callStatus', _hStatus);
      }
      sock.off('connect', _hConnect);
    } catch (_) {}
  }

  void _ensureSocketHandlersAttached() {
    final sock = _boundSocket;
    if (sock == null || _usingOnAny) return;
    try {
      if (sock.hasListeners('missedCall') != true) {
        sock.on('missedCall', _hMissed);
      }
      if (sock.hasListeners('missCall') != true) {
        sock.on('missCall', _hMissed);
      }
      if (sock.hasListeners('callEnded') != true) {
        sock.on('callEnded', _hEnded);
      }
      if (sock.hasListeners('endCall') != true) {
        sock.on('endCall', _hEnded);
      }
      if (sock.hasListeners('newCall') != true) {
        sock.on('newCall', _hNewCall);
      }
    } catch (_) {}
  }

  void bindSocket(dynamic socket) {
    if (socket == null) return;
    _ck('bindSocket');
    if (_boundSocket != null) {
      _detachSocket(_boundSocket);
    }
    _boundSocket = socket;
    _usingOnAny = false;

    try {
      socket.onAny(_hAny);
      _usingOnAny = true;
      _ck('bindSocket attached via immune onAny listener');
    } catch (_) {
      socket.on('newCall', _hNewCall);
      for (final ev in _socketEndEvents) {
        socket.on(ev, _hEnded);
      }
      for (final ev in _socketMissedEvents) {
        socket.on(ev, _hMissed);
      }
      socket.on('callStatus', _hStatus);
    }

    try {
      socket.on('connect', _hConnect);
    } catch (_) {}
  }

  void _onEvent(dynamic e) {
    if (e == null) {
      _ck('_onEvent got NULL event');
      return;
    }

    try {
      _ck('_onEvent got autoAcceptDAta:${e}');
      final name = _eventName(e);
      final acceptPayload = _extractAcceptPayload(e);
      final uuid = acceptPayload['uuid']?.toString();
      final sessionId = acceptPayload['sessionId']?.toString() ?? uuid ?? '';
      final extra = Map<String, dynamic>.from(acceptPayload['extra'] ?? {});
      final callId = acceptPayload['callId']?.toString() ?? '';

      _ck(
        'EVENT normalized="$name" '
        'sessionId="$sessionId" uuid=$uuid callId="$callId" '
        'extraKeys=${extra.keys.toList()} '
        'toString="${e.toString()}"',
      );

      switch (name) {
        case 'actioncallaccept':
          if (extra['direction'] == 'outgoing') {
            _ck('IGNORED actioncallaccept for outgoing call uuid=$uuid');
            break;
          }
          if (uuid != null) _accepted.add(uuid);
          _handleAccept(callId, extra, uuid, sessionId: sessionId);
          break;

        case 'actioncalldecline':
          if (uuid != null) _accepted.remove(uuid);
          _clearPendingAcceptMatching(
            uuid: uuid,
            sessionId: sessionId,
            callId: callId,
          );
          _ck(
            'DECLINE onDeclineCall=${onDeclineCall != null} '
            'sessionId=$sessionId callId=$callId',
          );

          onDeclineCall?.call(callId, extra, uuid);
          break;

        case 'actioncalltimeout':
          if (uuid != null) _accepted.remove(uuid);
          _clearPendingAcceptMatching(
            uuid: uuid,
            sessionId: sessionId,
            callId: callId,
          );
          onTimeoutCall?.call(callId, extra, uuid);
          break;

        case 'actioncallended':
          _clearPendingAcceptMatching(
            uuid: uuid,
            sessionId: sessionId,
            callId: callId,
          );
          if (extra['direction'] == 'outgoing') {
            _ck('IGNORED actioncallended for outgoing call uuid=$uuid');
            break;
          }
          final selfEndedAllRecent = _selfEndedAllAt != null &&
              DateTime.now().difference(_selfEndedAllAt!).inSeconds < 5;
          if (selfEndedAllRecent ||
              (uuid != null && _selfEnded.remove(uuid)) ||
              (sessionId.isNotEmpty && _selfEnded.remove(sessionId))) {
            _ck('ENDED ignored (our own dismiss)');
            break;
          }
          if (uuid != null) {
            _accepted.remove(uuid);
          }
          _ck('ENDED by user from system UI');
          onEndCall?.call(callId, extra, uuid);
          break;

        case 'actioncalltogglemute':
        case 'actioncalltogglehold':
        case 'actioncallcallback':
        case 'actioncalltoggleaudiosession':
          final CallKitSystemAction? a =
              mapSystemAction(name, _asMap(_eventBody(e)));
          _ck('system action $name -> $a');
          if (a == null) break;
          switch (a.kind) {
            case CallKitSystemActionKind.mute:
              onMuteChanged?.call(a.id, a.value);
              break;
            case CallKitSystemActionKind.hold:
              onHoldChanged?.call(a.id, a.value);
              break;
            case CallKitSystemActionKind.callback:
              onCallback?.call(extra);
              break;
            case CallKitSystemActionKind.audioSession:
              break; // handled natively (AppDelegate)
          }
          break;

        case 'actioncallstart':
          final targetHandle = extra['handle']?.toString() ??
              extra['callerId']?.toString() ??
              extra['remoteUserId']?.toString() ??
              (e as dynamic).body?['handle']?.toString() ??
              '';
          final bool isVid = extra['isVideo'] == true ||
              extra['type'] == 1 ||
              (e as dynamic).body?['type'] == 1;
          if (targetHandle.isNotEmpty && onRecentsCallback != null) {
            final res = onRecentsCallback!(targetHandle, isVid);
            if (res is Future<void>) unawaited(res);
          }
          break;

        case 'actioncallconnected':
        case 'actioncallincoming':
          break;

        case 'actiondidupdatedevicepushtokenvoip':
          final t = (e as dynamic).body?['deviceTokenVoIP']?.toString() ?? '';
          if (t.isNotEmpty) _uploadVoipToken(t);
          break;

        default:
          _ck('EVENT not handled: "$name"');
      }
    } catch (err, st) {
      _ck('_onEvent PARSE ERROR: $err\n$st\nraw: $e');
    }
  }

  Future<void> _handleAccept(
    String callId,
    Map<String, dynamic> extra,
    String? uuid, {
    String? sessionId,
  }) async {
    var resolvedSessionId = sessionId ?? uuid ?? '';
    _ck(
      '_handleAccept callId="$callId" uuid=$uuid sessionId=$resolvedSessionId '
      'appReady=$_appReady onAcceptCall=${onAcceptCall != null}',
    );

    if (resolvedSessionId.isEmpty || callId.isEmpty) {
      try {
        final calls = await FlutterCallkitIncoming.activeCalls();
        _ck('_handleAccept fallback activeCalls=$calls');
        if (calls is List && calls.isNotEmpty) {
          dynamic pick;
          for (final c in calls) {
            if (_field(c, 'isAccepted') == true) pick = c;
          }
          pick ??= calls.last;
          final id = _field(pick, 'id')?.toString();
          if (id != null) {
            uuid = id;
            _accepted.add(id);
            if (resolvedSessionId.isEmpty) resolvedSessionId = id;
          }
          final fallbackExtra = _asMap(_field(pick, 'extra'));
          extra.addAll(fallbackExtra);
          final cid = fallbackExtra['callId']?.toString() ??
              fallbackExtra['call_id']?.toString() ??
              '';
          if (cid.isNotEmpty) callId = cid;
          final sid = fallbackExtra['session_id']?.toString() ??
              fallbackExtra['sessionId']?.toString() ??
              id ??
              '';
          if (sid.isNotEmpty) resolvedSessionId = sid;
        }
      } catch (e) {
        _ck('_handleAccept fallback error: $e');
      }
    }

    if (resolvedSessionId.isEmpty) {
      _ck('_handleAccept ABORT: still no sessionId/callId');
      return;
    }

    _registerUuidMapping(
      uuid: uuid,
      sessionId: resolvedSessionId,
      callId: callId,
    );

    final payload = {
      ...extra,
      'uuid': uuid,
      'callId': callId,
      'sessionId': resolvedSessionId,
    };
    if (_appReady && onAcceptCall != null) {
      try {
        await onAcceptCall!(callId, payload, uuid);
        _ck('onAcceptCall finished OK sessionId=$resolvedSessionId');
      } catch (e, st) {
        _ck('onAcceptCall THREW: $e\n$st');
      }
    } else {
      pendingAccept = payload;
      _ck(
        'accept STORED as pendingAccept callId=$callId sessionId=$resolvedSessionId '
        '(waiting for markAppReady() from Home screen)',
      );
    }
  }

  Future<void> restoreActiveCalls() async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is! List) return;
      for (final c in calls) {
        if (_field(c, 'isAccepted') == true) continue;
        final extra = _asMap(_field(c, 'extra'));
        final sessionId =
            (extra['session_id'] ?? extra['sessionId'] ?? _field(c, 'id'))
                    ?.toString() ??
                '';
        final callId =
            extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
        if (callId.isEmpty) continue;

        // WhatsApp-grade protection: Never dismiss a call that was recently shown (< 25s)
        // on cold start or app resume from background / screen lock.
        final DateTime? shownTime =
            _shown[sessionId] ?? (callId.isNotEmpty ? _shown[callId] : null);
        if (shownTime != null &&
            DateTime.now().difference(shownTime).inSeconds < 25) {
          _ck(
            'restoreActiveCalls: call $callId ($sessionId) was recently shown '
            '(${DateTime.now().difference(shownTime).inSeconds}s ago), skipping dismiss',
          );
          continue;
        }

        if (getCallStatus != null) {
          final status = (await getCallStatus!(callId))?.toLowerCase();
          _ck(
            'restoreActiveCalls callId=$callId sessionId=$sessionId status=$status',
          );
          // Only dismiss if the server explicitly confirms a terminal state ('ended', 'missed', 'rejected', etc.)
          // Non-terminal states like 'ringing', 'initiated', 'created', 'calling' must NEVER be dismissed!
          if (status != null && _terminalStatuses.contains(status)) {
            _ck('restoreActiveCalls: dismissing terminal call $callId status=$status');
            await dismiss(sessionId, callId: callId, endAllUnaccepted: true);
          }
        }
      }
    } catch (e) {
      _ck('restoreActiveCalls error: $e');
    }
  }

  Future<void> _uploadVoipToken(String token, {bool force = false}) async {
    if (onVoipToken != null) {
      await onVoipToken!(token);
    } else {
      await VoipTokenUploader.instance.upload(token, force: force);
    }
  }

  Future<void> syncVoipToken({bool force = false}) async {
    if (!Platform.isIOS) return;
    try {
      final t = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      _ck('syncVoipToken length=${t?.toString().length ?? 0}');
      if (t != null && t.toString().isNotEmpty) {
        await _uploadVoipToken(t.toString(), force: force);
      }
    } catch (e) {
      _ck('syncVoipToken error: $e');
    }
  }

  /// Maps a CallKit system action (lock screen, headset, cellular call) to
  /// what the call screen must do. Pure: unit-tested (CT-14).
  static CallKitSystemAction? mapSystemAction(
    String name,
    Map<String, dynamic> body,
  ) {
    bool flag(List<String> keys) {
      for (final String k in keys) {
        final dynamic v = body[k];
        if (v is bool) return v;
        if (v != null) return v.toString() == 'true' || v.toString() == '1';
      }
      return false;
    }

    final String id = (body['id'] ?? body['uuid'] ?? '').toString();
    switch (name) {
      case 'actioncalltogglemute':
        return CallKitSystemAction(CallKitSystemActionKind.mute, id,
            flag(<String>['isMuted', 'muted']));
      case 'actioncalltogglehold':
        return CallKitSystemAction(CallKitSystemActionKind.hold, id,
            flag(<String>['isOnHold', 'onHold']));
      case 'actioncalltoggleaudiosession':
        return CallKitSystemAction(CallKitSystemActionKind.audioSession, id,
            flag(<String>['isActivate', 'isActive']));
      case 'actioncallcallback':
        return CallKitSystemAction(CallKitSystemActionKind.callback, id, true);
    }
    return null;
  }

  /// Random RFC 4122 v4 id for an outgoing CallKit call.
  static String newUuid() {
    final Random r = Random.secure();
    final List<int> b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final String h =
        b.map((int x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// iOS: report an OUTGOING call to CallKit (BUG-CALL-12), so it shows in
  /// the system call UI / Recents, the lock screen and headset can end or
  /// mute it, and a cellular call can hold it. Audio uses the same manual
  /// CallKit path as incoming calls (AppDelegate `prepareCallKitAudio`).
  static Future<void> startOutgoing({
    required String uuid,
    required String name,
    required String handle,
    required bool isVideo,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await const MethodChannel('com.fgtracker.audio_route')
          .invokeMethod<dynamic>('prepareCallKitAudio', <String, dynamic>{
        'isVideo': isVideo,
      });
    } catch (e) {
      _ck('prepareCallKitAudio error: $e');
    }
    try {
      _registerUuidMapping(uuid: uuid, sessionId: uuid, callId: '');
      await FlutterCallkitIncoming.startCall(
        CallKitParams(
          id: uuid,
          nameCaller: name,
          handle: handle.isNotEmpty ? handle : name,
          type: isVideo ? 1 : 0,
          extra: <String, dynamic>{'direction': 'outgoing'},
          ios: IOSParams(
            handleType: 'generic',
            supportsVideo: isVideo,
            supportsHolding: true,
            maximumCallGroups: 1,
            maximumCallsPerCallGroup: 1,
            audioSessionMode: isVideo ? 'videoChat' : 'voiceChat',
            audioSessionActive: true,
            audioSessionPreferredSampleRate: 44100.0,
            audioSessionPreferredIOBufferDuration: 0.005,
          ),
        ),
      );
      _ck('outgoing call reported to CallKit uuid=$uuid');
    } catch (e) {
      _ck('startCall error: $e');
    }
  }

  /// Keep the CallKit mute state in sync with the in-app mute button.
  static Future<void> syncMute(String id, bool muted) async {
    if (!Platform.isIOS || id.isEmpty) return;
    try {
      final targetId = _uuidByKey[id] ?? id;
      await FlutterCallkitIncoming.muteCall(targetId, isMuted: muted);
    } catch (e) {
      _ck('muteCall error: $e');
    }
  }
}

enum CallKitSystemActionKind { mute, hold, audioSession, callback }

class CallKitSystemAction {
  const CallKitSystemAction(this.kind, this.id, this.value);
  final CallKitSystemActionKind kind;
  final String id;
  final bool value;

  @override
  String toString() => 'CallKitSystemAction($kind, id=$id, value=$value)';
}
