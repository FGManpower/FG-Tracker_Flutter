import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

typedef CallActionCallback = FutureOr<void> Function(
    String callId,
    Map<String, dynamic> extra,
    String? uuid,
    );

void _ck(String msg) {
  dev.log('[CK] $msg');
  print('[CK] $msg');
}

class CallKitService with WidgetsBindingObserver {
  CallKitService._();
  static final instance = CallKitService._();

  StreamSubscription? _sub;
  bool _inited = false;
  bool _appReady = false;
  bool _usingOnAny = false;

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

  static const Set<String> _socketEndEvents = {
    'callEnded',
    'endCall',
    'call_ended',
    'callRejected',
    'cancelCall',
    'groupCallEnded',
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
        final cid =
            ckpExtra['callId']?.toString() ??
                ckpExtra['call_id']?.toString() ??
                '';
        if (cid.isNotEmpty) result['callId'] = cid;
        final sid =
            ckpExtra['session_id']?.toString() ??
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
    final targetCallUuid = callId.isNotEmpty
        ? (_uuidByKey[callId] ?? callId)
        : '';
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

    unawaited(postInitBackgroundTasks(
      skipPermissions: true,
    ));  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _ensureSocketHandlersAttached();
    if (state == AppLifecycleState.resumed) {
      unawaited(restoreActiveCalls());
    }
  }

  Future<void> postInitBackgroundTasks({required bool skipPermissions}) async {
    if (!skipPermissions) {
      try {
        await FlutterCallkitIncoming.requestNotificationPermission({
          'title': 'Notification permission',
          'rationaleMessagePermission': 'Needed to show incoming calls.',
          'postNotificationMessageRequired':
          'Enable notifications in Settings.',
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
        _ck('VoIP token: $t');
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
        final sessionId =
            extra['session_id']?.toString() ??
                extra['sessionId']?.toString() ??
                uuid;
        final callId =
            extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';
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
      String callId,
      ) {
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
    return 'Unknown';
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
  }) async {
    final id = sessionId;

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
      final params = CallKitParams(
        id: id,
        nameCaller: callerName,
        appName: 'FG Tracker',
        avatar: avatar,
        handle: _iosHandle(extra, callerName, callId),
        type: isVideo ? 1 : 0,
        duration: 45000,
        callingNotification: const NotificationParams(),
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: false,
          subtitle: 'Missed call',
        ),
        extra: <String, dynamic>{
          ..._sanitizedExtra(extra),
          'callId': callId,
          'call_id': callId,
          'session_id': id,
          'sessionId': id,
        },
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: 'Incoming Call',
          missedCallNotificationChannelName: 'Missed Call',
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
          supportsHolding: false,
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

    final resolvedUuid = sessionId.isNotEmpty
        ? (_uuidByKey.remove(sessionId) ?? sessionId)
        : '';
    final resolvedCallUuid = callId.isNotEmpty
        ? (_uuidByKey.remove(callId) ?? callId)
        : '';

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
          final sid =
              extra['session_id']?.toString() ??
                  extra['sessionId']?.toString() ??
                  '';
          final cid =
              extra['callId']?.toString() ?? extra['call_id']?.toString() ?? '';

          final activeIdentifiers = <String>{
            if (activeId.isNotEmpty) activeId,
            if (sid.isNotEmpty) sid,
            if (cid.isNotEmpty) cid,
          };

          final isMatch = activeIdentifiers.any(
                (id) => lookupKeys.contains(id),
          );

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
      Timer(const Duration(seconds: 10), () => _selfEnded.remove(target));
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
        await FlutterCallkitIncoming.showMissCallNotification(
          CallKitParams(
            id: id.isNotEmpty ? id : callId,
            nameCaller: callerName,
            handle: callerName,
            type: isVideo ? 1 : 0,
            missedCallNotification: const NotificationParams(
              showNotification: true,
              isShowCallback: false,
              subtitle: 'Missed call',
            ),
            extra: {'callId': callId, 'session_id': id},
            android: const AndroidParams(
              missedCallNotificationChannelName: 'Missed Call',
            ),
          ),
        );
      } catch (e) {
        _ck('showMissCallNotification error: $e');
      }
    }
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

    final sessionId =
    (d['session_id'] ??
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
        if (Platform.isIOS) return true;
        final incomingId = sessionId.isNotEmpty ? sessionId : callId;
        if (incomingId.isEmpty) {
          _ck('handlePush incoming with EMPTY sessionId');
          return true;
        }
        await showIncoming(
          sessionId: incomingId,
          callId: callId,
          callerName: screen == 'incomingGroupCall'
              ? (cd['groupName'] ?? 'Group call').toString()
              : (cd['callerName'] ?? 'Unknown').toString(),
          isVideo: isVideo,
          avatar: (cd['callerProfileImage'] ?? '').toString(),
          extra: cd.map((k, v) => MapEntry(k, v.toString())),
        );
        return true;

      case 'callEnded':
      case 'groupCallEnded':
      case 'missedCall':
      case 'missedGroupCall':
        final endTarget = (d['session_id'] ?? d['sessionId'] ?? sessionId)
            .toString();
        await dismiss(
          endTarget.isNotEmpty ? endTarget : callId,
          callId: callId,
          endAllUnaccepted: true,
        );
        return true;
    }

    if (d['signal_type'] == 'endCall') {
      final endTarget = (d['session_id'] ?? d['sessionId'] ?? sessionId)
          .toString();
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
    final sessionId =
    (m['session_id'] ??
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
    final cd = decodeCallData(m['callData']);
    final sessionId =
    (m['session_id'] ??
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
      callerName: (m['caller_name'] ?? cd['callerName'] ?? 'Unknown')
          .toString(),
      isVideo: m['isVideo'].toString() == "true" ? true : false,
      avatar: (m['caller_profile_image'] ?? cd['callerProfileImage'] ?? '')
          .toString(),
      extra: cd.map((k, v) => MapEntry(k, v.toString())),
    );
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
          final selfEndedAllRecent =
              _selfEndedAllAt != null &&
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
          final cid =
              fallbackExtra['callId']?.toString() ??
                  fallbackExtra['call_id']?.toString() ??
                  '';
          if (cid.isNotEmpty) callId = cid;
          final sid =
              fallbackExtra['session_id']?.toString() ??
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
        await onAcceptCall!(callId, extra, uuid);
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
        if (getCallStatus != null) {
          final status = (await getCallStatus!(callId))?.toLowerCase();
          _ck(
            'restoreActiveCalls callId=$callId sessionId=$sessionId status=$status',
          );
          if (status != null && status != 'ringing') {
            await dismiss(sessionId, callId: callId, endAllUnaccepted: true);
          }
        }
      }
    } catch (e) {
      _ck('restoreActiveCalls error: $e');
    }
  }

  Future<void> _uploadVoipToken(String token) async {
    if (onVoipToken != null) await onVoipToken!(token);
  }
}
