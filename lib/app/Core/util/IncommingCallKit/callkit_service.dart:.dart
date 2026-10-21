import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

typedef CallActionCallback = FutureOr<void> Function(
    String callId, Map<String, dynamic> extra, String? uuid);

void _ck(String msg) {
  dev.log('[CK] $msg');
  print('[CK] $msg');
}

class CallKitService {
  CallKitService._();
  static final instance = CallKitService._();

  StreamSubscription? _sub;
  bool _inited = false;
  bool _appReady = false;

  Map<String, dynamic>? pendingAccept;


  static final Set<String> _selfEnded = {};


  static final Set<String> _accepted = {};


  static final Set<String> _showing = {};


  static final Map<String, DateTime> _shown = {};

  CallActionCallback? onAcceptCall;
  CallActionCallback? onDeclineCall;
  CallActionCallback? onTimeoutCall;
  CallActionCallback? onEndCall;
  Future<void> Function(String token)? onVoipToken;
  Future<String?> Function(String callId)? getCallStatus;

  // ------------------------------------------------------------ helpers
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
        final cid = ckpExtra['callId']?.toString() ?? '';
        if (cid.isNotEmpty) result['callId'] = cid;
        final sid = ckpExtra['session_id']?.toString() ??
            ckpExtra['sessionId']?.toString();
        if (sid != null && sid.isNotEmpty) {
          result['sessionId'] = sid;
          result['uuid'] = sid;
        }
      }
      return result;
    }


    final body = _asMap(_eventBody(e));
    if (body.isNotEmpty) {
      final id = body['id']?.toString() ?? body['sessionId']?.toString();
      if (id != null && id.isNotEmpty) {
        result['uuid'] = id;
        result['sessionId'] = id;
      }
      final extra = _asMap(body['extra']);
      if (extra.isNotEmpty) {
        result['extra'] = extra;
        final cid = extra['callId']?.toString() ?? '';
        if (cid.isNotEmpty) result['callId'] = cid;
        final sid =
            extra['session_id']?.toString() ?? extra['sessionId']?.toString();
        if (sid != null && sid.isNotEmpty) {
          result['sessionId'] = sid;
          result['uuid'] = sid;
        }
      }
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

  static bool _truthy(dynamic v) => v == true || v == 'true' || v == 1;

  static Future<bool> _isAccepted(String sessionId) async {
    try {
      final calls = await FlutterCallkitIncoming.activeCalls();
      if (calls is List) {
        for (final c in calls) {
          if (_field(c, 'id')?.toString() == sessionId) {
            return _field(c, 'isAccepted') == true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  /// Decompress sdpOfferCompressed (gzip + base64).
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

    try {
      await FlutterCallkitIncoming.requestNotificationPermission({
        'title': 'Notification permission',
        'rationaleMessagePermission': 'Needed to show incoming calls.',
        'postNotificationMessageRequired': 'Enable notifications in Settings.',
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

    _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(
      (dynamic e) => _onEvent(e),
      onError: (err) => _ck('onEvent stream ERROR: $err'),
    );
    _ck('event listener ATTACHED');

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

    await _recoverAcceptedCall();
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
        final sessionId = extra['session_id']?.toString() ?? uuid;
        final callId = extra['callId']?.toString() ?? '';
        _accepted.add(uuid);
        _ck('recovered accepted call uuid=$uuid sessionId=$sessionId callId=$callId');
        await _handleAccept(callId, extra, uuid, sessionId: sessionId);
      }
    } catch (e) {
      _ck('_recoverAcceptedCall error: $e');
    }
  }


  Future<void> markAppReady() async {
    _ck('markAppReady() pendingAccept=$pendingAccept '
        'onAcceptCall=${onAcceptCall != null}');
    _appReady = true;
    final p = pendingAccept;
    if (p != null && onAcceptCall != null) {
      pendingAccept = null;
      final callId = p['callId']?.toString() ?? '';
      final uuid = p['uuid']?.toString() ?? '';
      final sessionId = p['sessionId']?.toString() ?? uuid;
      _ck('markAppReady -> opening pending accept callId=$callId sessionId=$sessionId');
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

    try {
      final active = await FlutterCallkitIncoming.activeCalls();
      if (active is List &&
          active.any((c) => _field(c, 'id')?.toString() == id)) {
        _ck('showIncoming SKIPPED already active sessionId=$id');
        return;
      }

      _ck('showIncoming sessionId=$id callId=$callId caller=$callerName video=$isVideo');
      final params = CallKitParams(
        id: id,
        nameCaller: callerName,
        appName: 'FG Tracker',
        avatar: avatar,
        handle: callerName,
        type: isVideo ? 1 : 0,
        duration: 45000,
        callingNotification: const NotificationParams(),
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: false,
          subtitle: 'Missed call',
        ),
        extra: <String, dynamic>{
          ...extra,
          'callId': callId,
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
        ios: const IOSParams(
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
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


  static Future<void> dismiss(String sessionId) async {
    final uuid = sessionId;
    _ck('dismiss uuid=$uuid (sessionId=$sessionId)');
    _selfEnded.add(uuid);
    Timer(const Duration(seconds: 10), () => _selfEnded.remove(uuid));
    _accepted.remove(uuid);
    _shown.remove(uuid);
    try {
      await FlutterCallkitIncoming.endCall(uuid);
    } catch (e) {
      _ck('dismiss error: $e');
    }
  }

  static Future<void> dismissAll() async {
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
    final accepted = await _isAccepted(id);
    _ck('markMissed sessionId=$id callId=$callId accepted=$accepted');
    if (accepted) return;
    await dismiss(id);
    if (Platform.isAndroid) {
      try {
        await FlutterCallkitIncoming.showMissCallNotification(CallKitParams(
          id: id,
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
        ));
      } catch (e) {
        _ck('showMissCallNotification error: $e');
      }
    }
  }


  static Future<void> setConnected(String sessionId) async {
    try {
      await FlutterCallkitIncoming.setCallConnected(sessionId);
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
        (cd['callId'] ?? d['callId'] ?? d['call_id'] ?? '').toString();
    final isVideo = _truthy(cd['isVideo']);

    switch (screen) {
      case 'incomingCall':
      case 'incomingGroupCall':
        if (Platform.isIOS) return true;
        if (sessionId.isEmpty) {
          _ck('handlePush incoming with EMPTY sessionId');
          return true;
        }
        await showIncoming(
          sessionId: sessionId,
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
        await dismiss(d['session_id'] ?? d['sessionId'] ?? sessionId);
        return true;

      case 'missedCall':
      case 'missedGroupCall':
        await markMissed(
          sessionId: d['session_id'] ?? d['sessionId'] ?? sessionId,
          callId: callId,
          callerName: (cd['callerName'] ?? 'Someone').toString(),
          isVideo: isVideo,
        );
        return true;
    }

    if (d['signal_type'] == 'endCall') {
      await dismiss(d['session_id'] ?? d['sessionId'] ?? sessionId);
      return true;
    }
    return false;
  }

  dynamic _boundSocket;

  late final void Function(dynamic) _hNewCall = (data) {
    final state = WidgetsBinding.instance.lifecycleState;
    _ck('socket newCall lifecycle=$state');

    if (state != null && state != AppLifecycleState.resumed) return;

    final m = _asMap(data);
    final cd = decodeCallData(m['callData']);
    final sessionId = (m['session_id'] ??
            m['sessionId'] ??
            cd['session_id'] ??
            cd['sessionId'] ??
            '')
        .toString();
    final callId = (m['callId'] ?? cd['callId'] ?? '').toString();
    if (sessionId.isEmpty) return;
    showIncoming(
      sessionId: sessionId,
      callId: callId,
      callerName:
          (m['caller_name'] ?? cd['callerName'] ?? 'Unknown').toString(),
      isVideo: _truthy(m['isVideo'] ?? m['is_video'] ?? cd['isVideo']),
      avatar: (m['caller_profile_image'] ?? cd['callerProfileImage'] ?? '')
          .toString(),
      extra: cd.map((k, v) => MapEntry(k, v.toString())),
    );
  };

  late final void Function(dynamic) _hEnded = (data) {
    final m = _asMap(data);
    final sessionId =
        (m['session_id'] ?? m['sessionId'] ?? m['callId'] ?? '').toString();
    _ck('socket callEnded/endCall sessionId=$sessionId data=$m');
    if (sessionId.isNotEmpty) dismiss(sessionId);
  };

  late final void Function(dynamic) _hMissed = (data) {
    final m = _asMap(data);
    final sessionId =
        (m['session_id'] ?? m['sessionId'] ?? m['callId'] ?? '').toString();
    _ck('socket missedCall sessionId=$sessionId data=$m');
    if (sessionId.isNotEmpty) dismiss(sessionId);
  };


  void bindSocket(dynamic socket) {
    if (socket == null) return;
    _ck('bindSocket');
    if (_boundSocket != null) {
      _boundSocket.off('newCall', _hNewCall);
      for (final ev in ['callEnded', 'endCall', 'call_ended']) {
        _boundSocket.off(ev, _hEnded);
      }
      _boundSocket.off('missedCall', _hMissed);
    }
    _boundSocket = socket;
    socket.on('newCall', _hNewCall);
    for (final ev in ['callEnded', 'endCall', 'call_ended']) {
      socket.on(ev, _hEnded);
    }
    socket.on('missedCall', _hMissed);
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

      _ck('EVENT normalized="$name" '
          'sessionId="$sessionId" uuid=$uuid callId="$callId" '
          'extraKeys=${extra.keys.toList()} '
          'toString="${e.toString()}"');

      switch (name) {
        case 'actioncallaccept':
          if (uuid != null) _accepted.add(uuid);
          _handleAccept(callId, extra, uuid, sessionId: sessionId);
          break;

        case 'actioncalldecline':
          if (uuid != null) _accepted.remove(uuid);
          _ck('DECLINE onDeclineCall=${onDeclineCall != null} '
              'sessionId=$sessionId callId=$callId');

          onDeclineCall?.call(callId, extra, uuid);
          break;

        case 'actioncalltimeout':
          onTimeoutCall?.call(callId, extra, uuid);
          break;

        case 'actioncallended':
          if (uuid != null && _selfEnded.remove(uuid)) {
            _ck('ENDED ignored (our own dismiss)');
            break;
          }
          if (uuid != null && _accepted.remove(uuid)) {
            _ck('ENDED by user from system UI');
            onEndCall?.call(callId, extra, uuid);
          }
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
    _ck('_handleAccept callId="$callId" uuid=$uuid sessionId=$resolvedSessionId '
        'appReady=$_appReady onAcceptCall=${onAcceptCall != null}');


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
          final cid = fallbackExtra['callId']?.toString() ?? '';
          if (cid.isNotEmpty) callId = cid;
          final sid = fallbackExtra['session_id']?.toString() ?? id ?? '';
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
      _ck('accept STORED as pendingAccept callId=$callId sessionId=$resolvedSessionId '
          '(waiting for markAppReady() from Home screen)');
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
        final callId = extra['callId']?.toString();
        if (callId == null || callId.isEmpty) continue;
        if (getCallStatus != null) {
          final status = (await getCallStatus!(callId))?.toLowerCase();
          _ck('restoreActiveCalls callId=$callId sessionId=$sessionId status=$status');
          if (status != null && status != 'ringing') {
            if (sessionId.isNotEmpty) dismiss(sessionId);
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
