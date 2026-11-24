import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_platform.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/voip_token_uploader.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_entry.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

bool _isGroupCall(Map<dynamic, dynamic>? extra) {
  if (extra == null) return false;
  final screen = (extra['screen_name'] ?? extra['screenName'] ?? extra['screen'] ?? '').toString();
  if (screen == 'incomingGroupCall' || screen == 'groupCallNotify' || screen == 'group_call') return true;
  final type = (extra['type'] ?? extra['callType'] ?? '').toString();
  if (type == 'group_voice_call' || type == 'group_video_call') return true;
  final groupId = (extra['groupId'] ?? extra['group_id'] ?? '').toString().trim();
  if (groupId.isNotEmpty && groupId != '0' && groupId != 'null') return true;
  return false;
}

/// Wires the CallKit / Android full-screen call actions to the app.
/// Moved out of main.dart so it can be unit tested (doc 02 §5).
void setupCallKitHandlers() {
  final CallKitService callKit = CallKitService.instance;

  callKit.onAcceptCall = (callId, extra, uuid) async {
    if (extra['direction'] == 'outgoing') {
      log('[CALL] Ignored onAcceptCall for outgoing call: $extra');
      return;
    }
    final bool isGroup = _isGroupCall(extra);
    CallSessionState.sessionId = uuid ?? '';

    if (isGroup) {
      log('[CallKit] Group call accepted: $extra');
      final CallingController? live = _liveCall();
      if (live != null) {
        await live.endCall(type: 'switchFromSystemUi');
      }

      final String effectiveGroupId =
          (extra['groupId'] ?? extra['group_id'] ?? '').toString();
      final String effectiveGroupName =
          (extra['groupName'] ?? extra['group_name'] ?? 'Group Call').toString();
      final String effectiveCallerId =
          (extra['callerId'] ?? extra['caller_id'] ?? '').toString();
      final String effectiveCallerName =
          (extra['callerName'] ?? extra['nameCaller'] ?? extra['caller_name'] ?? '')
              .toString();
      final String effectiveCallId = (callId.isNotEmpty
              ? callId
              : (extra['callId'] ?? extra['call_id'] ?? ''))
          .toString();
      final bool isVideo = extra['isVideo'] == 'true' ||
          extra['isVideo'] == true ||
          extra['type'] == 1 ||
          extra['type'] == '1';

      if (uuid != null && uuid.isNotEmpty) {
        unawaited(CallPlatform.instance.dismissCallKit(uuid).catchError((_) {}));
      }

      Get.offNamed(
        Routes.groupCallingScreen,
        arguments: {
          "groupId": effectiveGroupId,
          "groupName": effectiveGroupName,
          "groupProfile": extra['groupProfile'] ?? extra['callerProfileImage'] ?? extra['caller_profile_image'],
          "callerId": effectiveCallerId,
          "callerName": effectiveCallerName,
          "callerProfileImage": extra['callerProfileImage'] ?? extra['caller_profile_image'],
          "isVideo": isVideo,
          "callId": effectiveCallId,
          "callType": "incoming",
          "fromCallKit": true,
        },
        preventDuplicates: false,
      );
      return;
    }

    // Accept on the system UI while already in a call (iOS "End & Accept",
    // Android second full-screen call): end the current call first, then
    // join the new one (BUG-CALL-05). Before, the accept was ignored.
    final CallingController? live = _liveCall();
    if (live != null) {
      if (live.callId?.toString() == callId) return; // same call
      await live.endCall(type: 'switchFromSystemUi');
    }

    log('Incoming call accepted: $extra');

    final String resolvedCallerId = (extra['callerId'] ??
            extra['caller_id'] ??
            extra['remoteUserId'] ??
            extra['user_id'] ??
            extra['userId'])
        ?.toString() ??
        '';

    final String resolvedCallerName = (extra['callerName'] ??
            extra['caller_name'] ??
            extra['name'])
        ?.toString() ??
        '';

    final dynamic resolvedProfileImage = extra['profileImage'] ??
        extra['callerProfileImage'] ??
        extra['caller_profile_image'] ??
        extra['avatar'];

    final bool resolvedIsVideo = extra['isVideo'] == 'true' ||
        extra['isVideo'] == true ||
        extra['is_video'] == 'true' ||
        extra['is_video'] == true ||
        extra['type'] == 1 ||
        extra['type'] == '1';

    final dynamic resolvedOffer = CallKitService.decodeOffer(
            extra['sdpOfferCompressed'] ?? extra['sdpOfferCompressed_string']) ??
        extra['sdpOffer'] ??
        extra['offer'];

    final args = incomingCallArgs(
      callerId: resolvedCallerId,
      callId: callId,
      sessionId: uuid,
      isVideo: resolvedIsVideo,
      callerName: resolvedCallerName,
      profileImage: resolvedProfileImage,
      offer: resolvedOffer,
      fromCallKit: true,
    );

    if (Get.currentRoute == Routes.callScreen) {
      Get.offNamed(Routes.callScreen, arguments: args, preventDuplicates: false);
    } else {
      Get.toNamed(Routes.callScreen, arguments: args);
    }
  };

  callKit.onDeclineCall = (callId, extra, uuid) async {
    if (_isGroupCall(extra)) {
      final String effectiveCallId = (callId.isNotEmpty
              ? callId
              : (extra['callId'] ?? extra['call_id'] ?? ''))
          .toString();
      final String effectiveGroupId =
          (extra['groupId'] ?? extra['group_id'] ?? '').toString();
      if (effectiveCallId.isNotEmpty && effectiveGroupId.isNotEmpty) {
        Socket_GroupCallService.instance
            .rejectGroupCall(effectiveCallId, effectiveGroupId);
      }
      return;
    }

    final String resolvedCallerId = (extra['callerId'] ??
            extra['caller_id'] ??
            extra['remoteUserId'] ??
            extra['user_id'] ??
            extra['userId'])
        ?.toString() ??
        '';

    final String effectiveCallId = (callId.isNotEmpty
            ? callId
            : (extra['callId'] ?? extra['call_id'] ?? ''))
        .toString();

    final s = SignallingService.instance.socket;
    if (s != null && s.connected) {
      s.emit(
        'rejectCall',
        rejectCallPayload(
          callId: effectiveCallId,
          callerId: resolvedCallerId,
        ),
      );
    } else {
      await rejectCallViaRest(
        effectiveCallId,
        callerId: resolvedCallerId,
        uuid: uuid,
      );
    }
  };

  callKit.onEndCall = (callId, extra, uuid) => handleSystemEndCall(
        callId: callId,
        uuid: uuid,
        extra: extra,
      );

  callKit.onTimeoutCall = (callId, extra, uuid) async {
    log('Incoming call timed out: $callId');
  };

  callKit.onMuteChanged = (id, muted) {
    final CallingController? live = _liveCall();
    if (live != null) {
      live.setMutedFromSystem(muted);
    }
  };

  if (Platform.isIOS) {
    const MethodChannel('com.fgtracker.audio_route')
        .setMethodCallHandler((call) async {
      if (call.method == 'onCallKitMuteChanged') {
        final bool muted = call.arguments?['muted'] == true;
        final CallingController? live = _liveCall();
        if (live != null) {
          live.setMutedFromSystem(muted);
        }
      }
      return null;
    });
  }

  // Clears stale ringing calls on start / resume. `null` (unknown, offline)
  // never dismisses anything (BUG-CALL-10, BUG-CALL-24).
  callKit.getCallStatus = (callId) => CallRepo.fetchCallStatus(callId);

  // Upload comes in Phase 3 (needs a backend endpoint, BUG-CALL-11).
  // Never log the token itself.
  callKit.onVoipToken = (token) async {
    if (kDebugMode) log('[CALL] VoIP token updated (length ${token.length})');
    // Upload every new token (BUG-CALL-11); OtpController is not touched.
    if (Platform.isIOS) await VoipTokenUploader.instance.upload(token, force: true);
  };

  // Hang-up push for the live call (its socket `callEnded` may be lost).
  callKit.onRemoteEndPush = (String sessionId, String callId) {
    _liveCall()?.onRemoteEndHint(sessionId: sessionId, callId: callId);
  };

  // Second call while in a call: waiting banner, not the system UI.
  callKit.isInCall = () => _liveCall() != null;
  callKit.onCallWaiting = (Map<String, dynamic> data) {
    _liveCall()?.showWaitingCall(data);
  };

  // Lock screen / CallKit / headset mute and hold (BUG-CALL-12).
  callKit.onMuteChanged = (String id, bool muted) {
    _liveCall()?.setMutedFromSystem(muted);
  };
  callKit.onHoldChanged = (String id, bool held) {
    _liveCall()?.setOnHoldFromSystem(held);
  };

  // "Call back" on the missed-call notification.
  callKit.onCallback = (Map<String, dynamic> extra) async {
    final String callerId =
        (extra['callerId'] ?? extra['caller_id'] ?? '').toString();
    final BuildContext? ctx = Get.context;
    if (callerId.isEmpty || ctx == null) return;
    final String me = Global.storageServices.get(PrefConst.userId).toString();
    await CallService().startOutGoingCall(
      ctx,
      callerId: me,
      remoteUserId: callerId,
      is_video: extra['isVideo']?.toString() == 'true',
      callerName: extra['callerName'],
      callerProfile: extra['callerProfileImage']?.toString(),
    );
  };
}

/// The live 1:1 call, if any.
CallingController? _liveCall() {
  if (!Get.isRegistered<CallingController>()) return null;
  final CallingController c = Get.find<CallingController>();
  return c.isCallLive ? c : null;
}

/// "End" pressed in the system call UI (iOS CallKit, Android call
/// notification).
///
/// Always ends the call, also while it is still connecting (BUG-CALL-09:
/// it used to be ignored then, leaving a ghost call). The only `End` that is
/// ignored is the one Android fires when the app itself releases the Telecom
/// call after accept (audio handover); that one is not a user action.
Future<void> handleSystemEndCall({
  required String callId,
  String? uuid,
  Map<String, dynamic> extra = const <String, dynamic>{},
}) async {
  if (!Get.isRegistered<CallingController>()) {
    final String resolvedCallerId = (extra['callerId'] ??
            extra['caller_id'] ??
            extra['remoteUserId'] ??
            extra['user_id'] ??
            extra['userId'])
        ?.toString() ??
        '';
    final s = SignallingService.instance.socket;
    if (s != null && s.connected) {
      s.emit(
        'rejectCall',
        rejectCallPayload(
          callId: callId,
          callerId: resolvedCallerId,
        ),
      );
      s.emit(
        'endCall',
        {
          'callId': callId,
          'to': resolvedCallerId,
          'remoteUserId': resolvedCallerId,
          'sessionId': uuid ?? extra['sessionId'],
        },
      );
    }
    await rejectCallViaRest(callId);
    await endCallViaRest(callId, targetUserId: resolvedCallerId);
    return;
  }
  final CallingController ctrl = Get.find<CallingController>();

  final Set<String> ids = <String>{
    callId,
    if (uuid != null) uuid,
    extra['sessionId']?.toString() ?? '',
    extra['session_id']?.toString() ?? '',
    ctrl.callId?.toString() ?? '',
  }..removeWhere((String id) => id.isEmpty || id == 'null');

  if (extra['direction'] == 'outgoing' && ctrl.isCallLive) {
    log('[CALL] system End ignored: active outgoing call');
    return;
  }

  if (ids.any(CallKitService.isAudioHandoverActive)) {
    log('[CALL] system End ignored: audio handover of this call');
    return;
  }
  await ctrl.endCall(type: 'callkit');
}

Future<void> endCallViaRest(dynamic callId, {String? targetUserId}) async {
  if (callId == null || callId.toString().isEmpty || callId.toString() == 'null') return;
  final String cid = callId.toString();
  try {
    final shared = await SharedPreferences.getInstance();
    final token = shared.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ?? '';
    if (token.isEmpty) return;

    final url = Uri.parse(
        '${ConstRes.aBaseUrl}callRejected?callId=$cid&reason=ended');
    unawaited(http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 5)).catchError((e) {
      log('REST endCall error: $e');
      return http.Response('', 500);
    }));

    if (targetUserId != null && targetUserId.isNotEmpty) {
      unawaited(CallRepo.updateCallingStatus(
        callId: cid,
        remoteUserId: targetUserId,
        callingStatus: "ended",
      ).catchError((_) {}));
    }
  } catch (e) {
    log('REST endCall error: $e');
  }
}

Future<void> rejectCallViaRest(
  String callId, {
  String? callerId,
  String? uuid,
  String? reason,
}) async {
  try {
    final shared = await SharedPreferences.getInstance();
    final token = shared.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ?? '';
    final myUserId = shared.getString(PrefConst.userId) ?? '';

    final queryParams = <String, String>{
      'callId': callId,
      'reason': reason ?? 'declined',
      if (myUserId.isNotEmpty) 'userId': myUserId,
      if (callerId != null && callerId.isNotEmpty) 'callerId': callerId,
      if (uuid != null && uuid.isNotEmpty) 'sessionId': uuid,
    };
    final uri = Uri.parse('${ConstRes.aBaseUrl}callRejected').replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    log('REST reject status: ${response.statusCode}');
  } catch (e) {
    log('REST reject error: $e');
  }
}
