import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:socket_io_client/socket_io_client.dart' show Socket;
import 'package:fgtracker/l10n/l10n.dart';
import '../../../Data/Services/IncommingCallKit/call_session.dart'
    show CallSessionState;
import '../../../Data/Services/IncommingCallKit/call_kit_handlers.dart'
    show endCallViaRest;
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../Widget/audio_route_sheet.dart';
import '../../call/Controller/call_controller.dart';
import '../Services/call_connection_monitor.dart';
import '../Services/call_end_probe.dart';
import '../Services/call_events.dart';
import '../Services/call_entry.dart';
import '../Services/call_foreground_service.dart';
import '../Services/call_permissions.dart';
import '../Services/call_pip.dart';
import '../Services/call_platform.dart';
import '../Services/call_quality.dart';
import '../Services/call_socket_handlers.dart';
import '../Services/in_app_call_overlay_service.dart';
import '../Services/turn_credentials.dart';
import '../Views/call_ended_screen.dart';

class CallingController extends GetxController with WidgetsBindingObserver {
  static CallingController get instance => Get.find<CallingController>();
  final RxBool isMinimized = false.obs;

  static const String _camTag = 'a=x-cam-on:';

  RTCPeerConnection? _screenPc;
  MediaStream? _screenStream;
  RTCRtpSender? _screenSender;
  final List<RTCIceCandidate> _screenPendingLocalIce = [];
  final List<Map<String, dynamic>> _screenPendingRemoteIce = [];
  bool _screenRemoteDescSet = false;
  bool _screenShareStarting = false;
  bool _screenShareAnnounced = false;
  bool _screenRendererReleased = false;
  final RxBool isScreenSharing = false.obs;
  final RxBool isScreenShareLive = false.obs;
  final RxBool isScreenShareWaiting = false.obs;
  final RxBool isRemoteScreenSharing = false.obs;
  MediaStream? _remoteScreenStream;
  final RTCVideoRenderer screenRenderer = RTCVideoRenderer();

  /// Always the CURRENT signaling socket. It is re-created on login, so a
  /// copy taken at construction can be dead (BUG-CALL-02).
  Socket? get socket => SignallingService.instance.socket;

  /// This call's socket handlers only. `socket.off(event)` without a handler
  /// would also remove the global SignallingService handlers (BUG-CALL-03).
  late final CallSocketHandlers _handlers = CallSocketHandlers(() => socket);

  CallPlatform get _platform => CallPlatform.instance;

  /// Set by every end path. A finished controller is never reused for the
  /// next call (BUG-CALL-01).
  bool _callFinished = false;

  /// True once anything about this call was sent to the other user.
  bool _callAnnounced = false;

  /// Own camera is off because the camera permission is missing (P-06):
  /// the call runs as voice for us, the other side's video still shows,
  /// and the screen offers "Camera off · Allow".
  final RxBool cameraBlockedByPermission = false.obs;
  bool _cameraBlocked = false;

  /// Sent with endCall so the other side knows why (e.g. permission_denied).
  String? _endReason;

  // ---- Phase 3 (WhatsApp / IMO parity), doc 02 §7 ------------------------

  /// Reconnect / ICE restart / give-up timing (BUG-CALL-06).
  late final CallLinkMonitor _linkMonitor = CallLinkMonitor(
    onAction: _onLinkAction,
    // The original caller restarts ICE first; the callee only if that does
    // not help (avoids both sides offering at once).
    isInitiator: !_isIncoming,
  );

  /// While "Reconnecting…": asks the server whether the other side already
  /// hung up (its socket `callEnded` can be lost), so the screen does not
  /// sit on "Reconnecting…" until the 25 s give-up.
  late final CallEndProbe _endProbe = CallEndProbe(
    check: () => _serverSaysCallOver(linkDown: true),
    onEnded: () => unawaited(_endBecauseServerSaysOver('probe')),
  );
  bool _serverCheckInFlight = false;

  /// A second incoming call while on this call (BUG-CALL-05).
  final Rx<WaitingCall?> waitingCall = Rx<WaitingCall?>(null);
  Timer? _waitingTimer;

  /// Other side's state (BUG-CALL-17): "X muted", "Video paused".
  final RxBool remoteMicMuted = false.obs;
  final RxBool remoteVideoPaused = false.obs;

  /// "Poor connection" from getStats (RTT, loss, jitter).
  final RxBool isPoorConnection = false.obs;
  final CallQualityEvaluator _quality = CallQualityEvaluator();
  final CallStatsReader _statsReader = CallStatsReader();
  Timer? _statsTimer;

  /// Held by CallKit (e.g. a cellular call), BUG-CALL-12.
  final RxBool isOnHold = false.obs;
  bool _audioBeforeHold = true;

  /// iOS: id of this OUTGOING call in CallKit (incoming calls use the
  /// session id).
  String _outgoingCallKitId = '';

  /// Why the call ended, for the end screen (Call again / Cancel).
  CallEndOutcome? _endOutcome;

  /// Last end-screen info (read by tests and by the end screen route).
  @visibleForTesting
  static CallEndInfo? lastEndInfo;

  String get _callKitId =>
      _outgoingCallKitId.isNotEmpty ? _outgoingCallKitId : _sessionId;

  String get _myUserId =>
      Global.storageServices.get(PrefConst.userId).toString();

  /// The other user of this call, whichever side started it.
  String get _peerUserId {
    final String me = _myUserId;
    String t = (me == callerId.toString()) ? remoteUserId : callerId;
    if (t.isEmpty || t == me) {
      t = (remoteUserId.isNotEmpty && remoteUserId != me)
          ? remoteUserId
          : callerId;
    }
    return t;
  }

  /// True while this call can still be shown again (e.g. from the overlay).
  bool get isCallLive => !_callFinished && !isClosed;

  /// Call before opening the call screen for a NEW outgoing call.
  ///
  /// - A live call (for example minimized in the overlay) is never deleted:
  ///   the user is told and taken back to it, and `false` is returned.
  /// - A finished controller left over from an earlier call is removed so the
  ///   binding creates a fresh one.
  ///
  /// Replaces the old `Get.delete<CallingController>(force: true)` before a
  /// call, which turned a minimized call into a zombie (BUG-CALL-21).
  static bool prepareForNewCall({bool notifyUser = true}) {
    if (!Get.isRegistered<CallingController>()) return true;
    final CallingController existing = Get.find<CallingController>();
    if (existing.isCallLive) {
      if (notifyUser) {
        Utils().fluttertoast(appL10n.call_alreadyInCall);
        if (existing.isMinimized.value) {
          InAppCallOverlayService.instance.expandCall(existing);
        }
      }
      return false;
    }
    existing.isMinimized.value = false;
    Get.delete<CallingController>(force: true);
    return true;
  }

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? peer;
  MediaStream? localStream;
  MediaStream? _remoteMediaStream;
  MediaStreamTrack? _remoteVideoTrack;
  RTCRtpSender? _localVideoSender;
  bool _remoteCamStateKnown = false;
  RTCRtpTransceiver? _remoteVideoTransceiver;
  MediaStream? _fallbackRemoteStream;
  bool _videoSlotReady = false;
  Timer? _firstFrameTimer;
  Timer? _qualityTimer;
  final RxBool isRemoteVideoLoading = false.obs;

  List<RTCIceCandidate> iceCandidates = [];
  RxString callStatus = "Calling".obs;
  final RxBool isAudioOnRx = true.obs;
  bool get isAudioOn => isAudioOnRx.value;
  set isAudioOn(bool v) => isAudioOnRx.value = v;
  bool isVideoOn = false;
  bool isRemoteVideoOn = false;
  bool isFrontCamera = true;
  bool _isSwitchingCamera = false;
  dynamic callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
  bool fromCallKit = false;
  bool _isCleaningUp = false;
  bool _hasExitedScreen = false;
  bool _remoteEndSent = false;
  bool _callKitConnectedSent = false;
  bool _callKitAudioHandoverDone = false;
  bool _audioRouteRestored = false;
  bool _renegotiating = false;
  bool _pendingRenegotiation = false;
  bool _pendingIceRestart = false;
  bool _localOfferPending = false;

  Timer? _peerDisconnectTimer;

  bool _everConnected = false;
  /// Route arguments of THIS call, read in [onInit] (BUG-CALL-01).
  dynamic args = const <String, dynamic>{};
  Timer? callTimer;
  int callDurationSeconds = 0;
  final RxInt callDurationRx = 0.obs;
  Offset? pipPosition;

  Timer? missedCallTimer;
  var missCallDurationSeconds = kCallRingTimeout.inSeconds.obs;

  final RxBool isVideoCall = false.obs;
  final RxBool isUpgradingToVideo = false.obs;
  final RxBool isRemoteUpgrading = false.obs;
  Timer? _remoteUpgradeTimer;

  bool isLocalVideoMain = false;

  final RxBool areControlsVisible = true.obs;
  Timer? _controlsTimer;

  late final CallAudioRouteController audioRouteController;

  final List<dynamic> _pendingRemoteCandidates = [];
  bool _remoteDescriptionSet = false;

  Map<String, dynamic> _videoCaptureConstraints() {
    final String facing = isFrontCamera ? 'user' : 'environment';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return <String, dynamic>{
        'facingMode': facing,
        'width': 1280,
        'height': 720,
        'frameRate': 30,
      };
    }

    return <String, dynamic>{
      'facingMode': facing,
      'width': <String, dynamic>{'ideal': 1280, 'max': 1280},
      'height': <String, dynamic>{'ideal': 720, 'max': 720},
      'frameRate': <String, dynamic>{'min': 24, 'ideal': 30, 'max': 30},
    };
  }

  String _preferH264InSdp(String sdp) {
    if (sdp.isEmpty || !sdp.contains('m=video')) return sdp;

    final String lineSep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = sdp.split(lineSep);

    int i = 0;
    while (i < lines.length) {
      if (!lines[i].startsWith('m=video ')) {
        i++;
        continue;
      }

      final int mLineIdx = i;
      int sectionEnd = i + 1;
      while (sectionEnd < lines.length && !lines[sectionEnd].startsWith('m=')) {
        sectionEnd++;
      }

      final List<String> h264BaselinePts = <String>[];
      final List<String> h264OtherPts = <String>[];
      final Map<String, String> rtxByApt = <String, String>{};
      final Map<String, String> fmtpByPt = <String, String>{};

      for (int k = mLineIdx + 1; k < sectionEnd; k++) {
        final String line = lines[k];
        if (line.startsWith('a=fmtp:')) {
          final int space = line.indexOf(' ');
          if (space > 7) {
            final String pt = line.substring(7, space).trim();
            final String params = line.substring(space + 1).trim();
            fmtpByPt[pt] = params.toLowerCase();
            final RegExpMatch? aptMatch = RegExp(
              r'(?:^|;\s*)apt=(\d+)',
            ).firstMatch(params);
            if (aptMatch != null) {
              rtxByApt[aptMatch.group(1)!] = pt;
            }
          }
        }
      }

      for (int k = mLineIdx + 1; k < sectionEnd; k++) {
        final RegExpMatch? m = RegExp(
          r'^a=rtpmap:(\d+)\s+H264/90000',
          caseSensitive: false,
        ).firstMatch(lines[k]);
        if (m == null) continue;
        final String pt = m.group(1)!;
        final String fmtp = fmtpByPt[pt] ?? '';
        if (fmtp.contains('42e0') || fmtp.contains('4200')) {
          h264BaselinePts.add(pt);
        } else {
          h264OtherPts.add(pt);
        }
      }

      final List<String> orderedH264 = <String>[
        ...h264BaselinePts,
        ...h264OtherPts,
      ];

      if (orderedH264.isNotEmpty) {
        final List<String> parts = lines[mLineIdx].trim().split(RegExp(r'\s+'));
        if (parts.length > 4) {
          final List<String> header = parts.sublist(0, 3);
          final List<String> origPayloads = parts.sublist(3);
          final Set<String> origSet = origPayloads.toSet();
          final List<String> reordered = <String>[];

          for (final String pt in orderedH264) {
            if (origSet.contains(pt) && !reordered.contains(pt)) {
              reordered.add(pt);
            }
            final String? rtxPt = rtxByApt[pt];
            if (rtxPt != null &&
                origSet.contains(rtxPt) &&
                !reordered.contains(rtxPt)) {
              reordered.add(rtxPt);
            }
          }

          for (final String pt in origPayloads) {
            if (!reordered.contains(pt)) {
              reordered.add(pt);
            }
          }

          lines[mLineIdx] = <String>[...header, ...reordered].join(' ');
        }
      }

      i = sectionEnd;
    }

    return lines.join(lineSep);
  }

  String _stripCamTag(String sdp) {
    if (sdp.isEmpty || !sdp.contains(_camTag)) return sdp;
    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    return sdp
        .split(sep)
        .where((String line) => !line.trim().startsWith(_camTag))
        .join(sep);
  }

  String _withCamTag(String sdp, bool cameraOn) {
    if (sdp.isEmpty) return sdp;
    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final String tag = '$_camTag${cameraOn ? 1 : 0}';
    final List<String> out = <String>[];
    for (final String line in _stripCamTag(sdp).split(sep)) {
      out.add(line);
      if (line.startsWith('m=video ')) out.add(tag);
    }
    return out.join(sep);
  }

  bool? _camStateFromSdp(String? sdp) {
    if (sdp == null || sdp.isEmpty || !sdp.contains(_camTag)) return null;
    return sdp.contains('${_camTag}1');
  }

  String _sdpInfo(String? sdp) {
    if (sdp == null || sdp.isEmpty) return 'sdp=empty';

    final String sep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = sdp.split(sep);
    final List<String> mlines = <String>[];
    int msid = 0;
    int ssrc = 0;
    int ssrcGroup = 0;
    int rtpmap = 0;
    int fmtpH264 = 0;
    String current = '?';

    for (final String raw in lines) {
      final String line = raw.trim();
      if (line.startsWith('m=')) {
        final List<String> p = line.split(RegExp(r'\s+'));
        current = p.isNotEmpty ? p[0].substring(2) : '?';
        mlines.add('$current:?');
      } else if (line.startsWith('a=sendrecv') ||
          line.startsWith('a=recvonly') ||
          line.startsWith('a=sendonly') ||
          line.startsWith('a=inactive')) {
        if (mlines.isNotEmpty) {
          mlines[mlines.length - 1] = '$current:${line.substring(2)}';
        }
      } else if (line.startsWith('a=msid:')) {
        msid++;
      } else if (line.startsWith('a=ssrc:')) {
        ssrc++;
      } else if (line.startsWith('a=ssrc-group:')) {
        ssrcGroup++;
      } else if (line.startsWith('a=rtpmap:')) {
        rtpmap++;
        if (line.toUpperCase().contains('H264')) fmtpH264++;
      }
    }

    return 'mlines=${mlines.join(',')} msid=$msid ssrc=$ssrc '
        'ssrcGroup=$ssrcGroup rtpmap=$rtpmap h264=$fmtpH264';
  }

  RTCSessionDescription _prepareRemote(String? sdp, String? type) {
    final String raw = _stripCamTag(sdp ?? '');
    return RTCSessionDescription(_preferH264InSdp(raw), type);
  }

  Future<void> _tuneLocalVideoSender({double? scaleDown, int? maxBitrate}) async {
    if (isScreenSharing.value && defaultTargetPlatform == TargetPlatform.iOS) {
      log("[SHARE] local sender tune skipped: iOS screen share running");
      return;
    }
    final RTCRtpSender? sender = _localVideoSender;
    if (sender == null) return;
    try {
      final RTCRtpParameters params = sender.parameters;
      params.degradationPreference =
          RTCDegradationPreference.MAINTAIN_FRAMERATE;
      final List<RTCRtpEncoding>? encodings = params.encodings;
      if (encodings != null && encodings.isNotEmpty) {
        for (final RTCRtpEncoding enc in encodings) {
          enc.active = true;
          enc.maxBitrate = maxBitrate ?? 1800000;
          enc.maxFramerate = 30;
          if (scaleDown != null && scaleDown > 0) {
            enc.scaleResolutionDownBy = scaleDown;
          }
        }
      }
      await sender.setParameters(params);
      log(
        "[CAM] tune sender scaleDown=${scaleDown ?? 'keep'} "
        "enc=${encodings?.length ?? 0}",
      );
    } catch (e) {
      log("[Call] Video sender tuning skipped: $e");
    }
  }

  Future<void> _applyLocalVideoSending(MediaStreamTrack? track) async {
    final RTCRtpSender? sender = _localVideoSender;
    if (sender == null) return;
    try {
      await sender.replaceTrack(track);
    } catch (e) {
      log("[Call] replaceTrack error: $e");
    }
  }

  Future<MediaStream?> _remoteStreamForVideo() async {
    final MediaStream? stored = _remoteMediaStream;
    if (stored != null && stored.getVideoTracks().isNotEmpty) return stored;

    final MediaStreamTrack? track = _remoteVideoTrack;
    if (track == null) return null;

    final MediaStream? existing = _fallbackRemoteStream;
    if (existing != null && existing.getVideoTracks().isNotEmpty) {
      return existing;
    }

    try {
      final MediaStream stream = await createLocalMediaStream('cam_fallback');
      await stream.addTrack(track);
      _fallbackRemoteStream = stream;
      log("[CAM] fallback stream built for remote video id=${track.id}");
      return stream;
    } catch (e) {
      log("[CAM] fallback stream failed: $e");
      return null;
    }
  }

  Future<void> _ensureRemoteVideoBound() async {
    if (isClosed || peer == null) return;
    if (remoteRenderer.srcObject != null) {
      log("[CAM] ensureBound: already bound");
      return;
    }
    log(
      "[CAM] ensureBound: binding now track=${_remoteVideoTrack?.id} "
      "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
    );

    final MediaStream? stream = await _remoteStreamForVideo();
    if (stream == null) return;

    final String? trackId =
        _remoteVideoTrack?.id ?? stream.getVideoTracks().last.id;

    await remoteRenderer.setSrcObject(stream: stream, trackId: trackId);
  }

  Future<void> _syncVideoState() async {
    if (isVideoOn || isRemoteVideoOn) {
      isVideoCall.value = true;
      is_video = true;
    }

    if (!isVideoCall.value) {
      isLocalVideoMain = false;
      update();
      return;
    }

    if (isVideoOn && !isRemoteVideoOn) {
      isLocalVideoMain = true;
    } else if (!isVideoOn && isRemoteVideoOn) {
      isLocalVideoMain = false;
    }

    await _ensureRemoteVideoBound();

    update();
  }

  Future<bool> _ensureLocalVideoTrackAttached(
    RTCPeerConnection pc, {
    bool muted = false,
  }) async {
    bool needsRenegotiation = false;
    if (localStream == null) return needsRenegotiation;

    final List<MediaStreamTrack> existingTracks = localStream!.getVideoTracks();
    MediaStreamTrack? videoTrack =
        existingTracks.isNotEmpty ? existingTracks.first : null;

    if (videoTrack == null) {
      final MediaStream videoStream = await navigator.mediaDevices.getUserMedia(
        {'audio': false, 'video': _videoCaptureConstraints()},
      );
      videoTrack = videoStream.getVideoTracks().firstOrNull;
      if (videoTrack == null) {
        throw Exception("No video track available");
      }
      await localStream!.addTrack(videoTrack);
    }

    for (final MediaStreamTrack t in localStream!.getVideoTracks()) {
      t.enabled = !muted;
    }

    if (_localVideoSender == null) {
      final RTCRtpTransceiver? slot = _remoteVideoTransceiver;
      if (_videoSlotReady && slot != null) {
        _localVideoSender = slot.sender;
        await _applyLocalVideoSending(videoTrack);
        log("[CAM] attach: replaced track on negotiated slot");
      } else {
        _localVideoSender = await pc.addTrack(videoTrack, localStream!);
        needsRenegotiation = true;
        log("[CAM] attach: addTrack needsRenegotiation=true");
      }
    } else {
      await _applyLocalVideoSending(videoTrack);
    }

    if (!muted) {
      await localRenderer.setSrcObject(
        stream: localStream,
        trackId: videoTrack.id,
      );
    }

    _logCaptureSettings(muted ? "answer-muted" : "upgrade");
    await _tuneLocalVideoSender();
    return needsRenegotiation;
  }

  /// Sends a new offer over the existing `upgradeToVideo` relay. With
  /// [iceRestart] it is an ICE restart (new network path, BUG-CALL-06):
  /// the other side answers with `upgradeToVideoAnswer` as for any
  /// renegotiation, so today's server needs no change.
  Future<void> _renegotiateVideo({bool iceRestart = false}) async {
    final RTCPeerConnection? pc = peer;
    if (pc == null || isClosed) return;

    if (_renegotiating) {
      _pendingRenegotiation = true;
      _pendingIceRestart = _pendingIceRestart || iceRestart;
      return;
    }

    _renegotiating = true;
    try {
      if (iceRestart) {
        try {
          await pc.restartIce();
        } catch (e) {
          log("[CALL] restartIce error: $e");
        }
      }
      final RTCSessionDescription rawOffer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription desc = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawOffer.sdp ?? ''), isVideoOn),
        rawOffer.type,
      );
      await pc.setLocalDescription(desc);
      _localOfferPending = true;
      log(
        "[SDP] local offer ${_sdpInfo(desc.sdp)} "
        "videoOn=$isVideoOn sender=${_localVideoSender != null}",
      );

      final String myUserId =
          Global.storageServices.get(PrefConst.userId).toString();
      final String targetUser =
          (myUserId == callerId.toString()) ? remoteUserId : callerId;

      socket?.emit("upgradeToVideo", {
        "callId": callId,
        "remoteUserId": targetUser,
        "sdpOffer": desc.toMap(),
        "callerId": myUserId,
        if (iceRestart) "iceRestart": true,
      });
    } catch (e) {
      log("[Call] renegotiate error: $e");
    } finally {
      _renegotiating = false;
      if (_pendingRenegotiation) {
        _pendingRenegotiation = false;
        final bool again = _pendingIceRestart;
        _pendingIceRestart = false;
        unawaited(_renegotiateVideo(iceRestart: again));
      }
    }
  }

  Future<void> _applyRemoteSdp(RTCPeerConnection pc, dynamic sdp) async {
    final RTCSessionDescription desc = _prepareRemote(
      sdp?["sdp"]?.toString(),
      sdp?["type"]?.toString(),
    );
    log(
      "[SDP] setRemote type=${desc.type} ${_sdpInfo(desc.sdp)} "
      "samePeer=${identical(peer, pc)}",
    );
    try {
      await pc.setRemoteDescription(desc);
    } catch (e) {
      log("[Call] setRemoteDescription retry after rollback: $e");
      try {
        await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
      } catch (_) {}
      await pc.setRemoteDescription(desc);
    }
    await _markRemoteDescriptionSet();
  }

  void _emitEndCallRealtime({Map<String, dynamic>? customPayload}) {
    if (_remoteEndSent) return;
    _remoteEndSent = true;

    final String myUserId = _myUserId;
    final String peerId = _peerUserId;
    final String targetUser = peerId.isNotEmpty
        ? peerId
        : (myUserId == callerId.toString() ? remoteUserId : callerId);

    final String actualCallerId =
        (myUserId == callerId.toString()) ? myUserId : targetUser;
    final String actualReceiverId =
        (myUserId == callerId.toString()) ? targetUser : myUserId;

    final Map<String, dynamic> payload = customPayload ??
        <String, dynamic>{
          "callId": callId,
          "to": targetUser,
          "remoteUserId": targetUser,
          "callerId": actualCallerId,
          "receiverId": actualReceiverId,
          "sessionId": _sessionId,
          if (_endReason != null) "reason": _endReason,
        };

    final Socket? s = socket;
    if (s != null) {
      try {
        // While disconnected, socket.io buffers the emit and sends it once on
        // reconnect. The old extra once("connect") re-emit sent endCall twice.
        s.emit("endCall", payload);
        if (!s.connected && !s.active) s.connect();
      } catch (e) {
        log("[Call] _emitEndCallRealtime error: $e");
      }
    }

    final String cid =
        (callId != null && callId.toString() != 'null') ? callId.toString() : '';
    if (cid.isNotEmpty) {
      unawaited(endCallViaRest(cid, targetUserId: targetUser));
    }
  }

  void _exitCallScreen() {
    if (_hasExitedScreen) return;
    _hasExitedScreen = true;

    // Minimized: the call screen is no longer on the stack (minimize popped
    // it). Popping now would close the page the user is on (BUG-CALL-22).
    if (isMinimized.value) return;

    // Caller side "No answer / Declined / On another call / Unavailable /
    // Connection lost": replace the call screen with the end screen
    // (Call again / Cancel), WhatsApp-like (BUG-CALL-17).
    final CallEndInfo? info = _endInfo;
    if (info != null) {
      final NavigatorState? nav = Get.key.currentState;
      nav?.popUntil((route) => route is! PopupRoute);
      Get.off<void>(() => CallEndedScreen(info: info),
          transition: Transition.fadeIn);
      return;
    }

    final NavigatorState? nav = Get.key.currentState;
    if (nav != null) {
      nav.popUntil((route) => route is! PopupRoute);
      if (nav.canPop()) {
        nav.pop();

        String? topRouteName;
        nav.popUntil((route) {
          topRouteName = route.settings.name;
          return true;
        });

        final String normalized = (topRouteName ?? '').trim().toLowerCase();
        final bool landedOnSplash = normalized.isEmpty ||
            normalized == '/' ||
            normalized.contains('splash') ||
            (fromCallKit &&
                !nav.canPop() &&
                topRouteName != Routes.Home_Screen);

        if (!landedOnSplash) {
          return;
        }
      }
    }

    Get.offAllNamed(Routes.Home_Screen);
  }

  void minimizeCall() {
    if (_hasExitedScreen || _isCleaningUp) return;
    isMinimized.value = true;
    InAppCallOverlayService.instance.showOverlay(this);
    final NavigatorState? nav = Get.key.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  void toggleVideoViews() {
    if (!isVideoCall.value) return;
    if (!isVideoOn || !isRemoteVideoOn) {
      showControlsTemporarily();
      update();
      return;
    }
    isLocalVideoMain = !isLocalVideoMain;
    showControlsTemporarily();
    update();
  }

  void showControlsTemporarily() {
    areControlsVisible.value = true;
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (!isClosed) {
        areControlsVisible.value = false;
      }
    });
    update();
  }

  void toggleControls() {
    areControlsVisible.value = !areControlsVisible.value;
    _controlsTimer?.cancel();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    args = Get.arguments ?? const <String, dynamic>{};
    callerId = args["callerId"]?.toString() ?? "";
    remoteUserId = args["remoteUserId"]?.toString() ?? "";
    offer = args["offer"];
    is_video = args["is_video"] == true;
    fromCallKit = args["fromCallKit"] == true;

    if (args["callId"] != null) {
      callId = args["callId"];
    }

    if (callId == null && args["sessionId"] != null) {
      callId = args["sessionId"];
    }

    if (args["sessionId"] != null && args["sessionId"].toString().isNotEmpty) {
      CallSessionState.sessionId = args["sessionId"].toString();
    }

    isVideoOn = is_video;
    isRemoteVideoOn = is_video;
    isVideoCall.value = is_video;

    log(
      "[CAM] init callType=${args["callType"]} is_video=$is_video "
      "callerId=$callerId remoteUserId=$remoteUserId callId=$callId "
      "hasOffer=${offer != null} fromCallKit=$fromCallKit",
    );

    audioRouteController = _platform.audioRoute();

    _listenForCallEvents();
    _startPhase3();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    unawaited(_platform.setWakelock(true).catchError((_) {}));

    // Android: keep mic (+camera) alive from the first second, while the app
    // is still visible. Starting only after ICE connected let the OS cut
    // them if the user left the app while connecting (BUG-CALL-15).
    CallForegroundService.onHangUp = () {
      if (isCallLive) unawaited(endCall(type: 'notification'));
    };
    unawaited(_platform.startCallService(video: is_video));

    // Tracking keep-alive, without any dialog over the call (BUG-CALL-18).
    unawaited(_platform.keepTrackingAlive());

    unawaited(_initializeCall());
  }

  void _onRendererFrameEvent([int? width, int? height]) {
    if (!isClosed) update();
  }

  void _logCaptureSettings(String tag) {
    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty) {
      log("[CAM] capture($tag): no video track");
      return;
    }
    final Map<String, dynamic> st = vids.first.getSettings();
    log(
      "[CAM] capture($tag): ${st['width']}x${st['height']} "
      "fps=${st['frameRate']}",
    );
  }

  Future<void> _rebindRemoteForFirstFrames({bool generic = false}) async {
    if (isClosed || peer == null) return;

    final MediaStream? stream = await _remoteStreamForVideo();
    if (stream == null) {
      log("[CAM] rebind skipped: no remote video stream available");
      return;
    }

    final String? trackId =
        _remoteVideoTrack?.id ?? stream.getVideoTracks().last.id;
    try {
      remoteRenderer.srcObject = null;
      if (generic) {
        await remoteRenderer.setSrcObject(stream: stream);
        log("[CAM] rebind generic stream=${stream.id}");
      } else {
        await remoteRenderer.setSrcObject(stream: stream, trackId: trackId);
        log("[CAM] rebind on remote camera on id=$trackId");
      }
    } catch (e) {
      log("[CAM] rebind failed: $e");
    }
  }

  Future<int> _logStats(String tag) async {
    final RTCPeerConnection? pc = peer;
    if (pc == null || isClosed) return -1;

    int decoded = -1;
    log("[STAT] $tag begin");
    try {
      final List<StatsReport> reports = await pc.getStats();
      final Map<String, int> types = <String, int>{};

      for (final StatsReport r in reports) {
        final Map<dynamic, dynamic> v = r.values;
        final String type = r.type;
        types[type] = (types[type] ?? 0) + 1;

        if (v['framesDecoded'] != null) {
          decoded = int.tryParse('${v['framesDecoded']}') ?? -1;
          log(
            "[STAT] $tag IN recv=${v['framesReceived']} "
            "dec=${v['framesDecoded']} drop=${v['framesDropped']} "
            "bytes=${v['bytesReceived']} pli=${v['pliCount']} "
            "size=${v['frameWidth']}x${v['frameHeight']}",
          );
        }
        if (v['framesEncoded'] != null) {
          log(
            "[STAT] $tag OUT enc=${v['framesEncoded']} "
            "key=${v['keyFramesEncoded']} sent=${v['framesSent']} "
            "bytes=${v['bytesSent']} "
            "qlim=${v['qualityLimitationReason']}",
          );
        }
      }
      log("[STAT] $tag types=$types");
    } catch (e) {
      log("[STAT] $tag error: $e");
    }
    log("[STAT] $tag end");
    return decoded;
  }

  void _requestKeyframe() {
    final String myUserId =
        Global.storageServices.get(PrefConst.userId).toString();
    String target = (myUserId == callerId.toString()) ? remoteUserId : callerId;
    if (target.isEmpty || target == myUserId) {
      target = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (target.isEmpty || target == myUserId) return;

    log("[CAM] request keyframe from=$target");
    socket?.emit("upgradeToVideo", {
      "callId": callId,
      "remoteUserId": target,
      "callerId": myUserId,
      "needKeyframe": true,
    });
  }

  Future<void> _forceKeyframe() async {
    if (isScreenSharing.value) {
      log("[SHARE] forceKeyframe skipped while screen sharing");
      return;
    }

    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty || _localVideoSender == null || !isVideoOn) return;

    log("[CAM] force keyframe: restart sender at half resolution");
    await _tuneLocalVideoSender(scaleDown: 2.0);
    await _applyLocalVideoSending(null);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _applyLocalVideoSending(vids.first);
    _scheduleQualityRestore();
  }

  void _scheduleQualityRestore() {
    _qualityTimer?.cancel();
    _qualityTimer = Timer(const Duration(seconds: 10), () {
      if (isClosed || !isVideoOn || isScreenSharing.value) return;
      log("[CAM] restore full resolution");
      unawaited(_tuneLocalVideoSender(scaleDown: 1.0));
    });
  }

  void _startFirstFrameWatchdog() {
    _firstFrameTimer?.cancel();
    if (!isRemoteVideoOn) {
      isRemoteVideoLoading.value = false;
      return;
    }

    isRemoteVideoLoading.value = true;
    update();

    int decodedFrames = -1;

    _firstFrameTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (!isRemoteVideoOn) {
        timer.cancel();
        isRemoteVideoLoading.value = false;
        update();
        return;
      }

      if (remoteRenderer.value.width > 0) {
        timer.cancel();
        isRemoteVideoLoading.value = false;
        update();
        log("[CAM] first remote frame arrived w=${remoteRenderer.value.width}");
        return;
      }

      if (timer.tick == 2 || timer.tick == 5 || timer.tick == 9) {
        decodedFrames = await _logStats("wait${timer.tick}s");
        log(
          "[CAM] wait ${timer.tick}s: renderW=${remoteRenderer.value.width} "
          "decoded=$decodedFrames",
        );

        if (decodedFrames > 0) {
          log("[CAM] decoded but no pixels -> rebind #${timer.tick}");
          await _rebindRemoteForFirstFrames(generic: timer.tick >= 9);
        } else {
          log("[CAM] no decoded frames -> request keyframe");
          _requestKeyframe();
        }
      }

      if (timer.tick >= 15) {
        timer.cancel();
        log("[CAM] give up waiting for first frame");
        update();
      }
    });
  }

  void _watchRemoteVideo(String tag) {
    final RTCPeerConnection? pc = peer;
    if (pc == null) return;

    int ticks = 0;
    bool healed = false;

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      ticks++;
      if (isClosed || !identical(peer, pc)) {
        timer.cancel();
        return;
      }

      final int decoded = await _logStats("$tag+${ticks * 2}s");

      if (decoded == 0 && !healed && isRemoteVideoOn) {
        healed = true;
        log("[CAM] no decoded frames after ${ticks * 2}s, rebinding");
        await _rebindRemoteForFirstFrames();
      }

      if (ticks >= 6) timer.cancel();
    });
  }

  void _logRemoteFrameState() {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (isClosed) return;
      final int w = remoteRenderer.value.width.toInt();
      final int h = remoteRenderer.value.height.toInt();
      log("[CAM] after3s render=${remoteRenderer.renderVideo} size=${w}x$h");
    });
  }

  Future<void> _initializeCall() async {
    // Permissions on the call screen, for every way a call is opened
    // (outgoing, in-app accept, CallKit accept). Phase 2, P-05 / P-06.
    if (!await _ensureCallPermissions()) return;
    if (!_platform.mediaEnabled) return;
    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      await screenRenderer.initialize();

      localRenderer.onFirstFrameRendered = _onRendererFrameEvent;
      remoteRenderer.onFirstFrameRendered = _onRendererFrameEvent;
      localRenderer.onResize = _onRendererFrameEvent;
      remoteRenderer.onResize = _onRendererFrameEvent;

      await _setupPeer();
    } on CallSignalingUnavailable catch (e) {
      log("[Call] Initialization error: $e");
      await _cleanupCall(notifyRemote: _callAnnounced, navigateBack: true);
      Get.snackbar(appL10n.call_failedTitle, appL10n.call_cannotReachCallServer);
    } catch (e, stackTrace) {
      log("[Call] Initialization error: $e", stackTrace: stackTrace);
      // Incoming: the caller is waiting, tell them. Outgoing: only if
      // makeCall already went out.
      await _cleanupCall(
        notifyRemote: _callAnnounced || _isIncoming,
        navigateBack: true,
      );
    }
  }

  bool get _isIncoming => fromCallKit || args["callType"] == "Incoming";

  /// True unless [data] clearly names a different call. Events without ids,
  /// or before this call has an id, are treated as ours (old behaviour).
  bool _isForThisCall(dynamic data) {
    if (data is! Map) return true;
    final Set<String> theirs = <String>{
      for (final String k in const <String>['callId', 'call_id', 'sessionId', 'session_id'])
        if (data[k] != null && data[k].toString().isNotEmpty && data[k].toString() != 'null')
          data[k].toString(),
    };
    final Set<String> ours = <String>{
      if (callId != null && callId.toString() != 'null') callId.toString(),
      if (_sessionId.isNotEmpty) _sessionId,
    };
    if (theirs.isEmpty || ours.isEmpty) return true;
    if (theirs.any(ours.contains)) return true;

    for (final String id in theirs) {
      final String mapped = CallKitService.mappedUuid(id);
      if (mapped.isNotEmpty && ours.contains(mapped)) return true;
    }
    for (final String id in ours) {
      final String mapped = CallKitService.mappedUuid(id);
      if (mapped.isNotEmpty && theirs.contains(mapped)) return true;
    }

    final String peer = _peerUserId;
    if (peer.isNotEmpty) {
      final String from = (data['callerId'] ?? data['caller_id'] ?? data['from'] ?? '')?.toString() ?? '';
      final String to = (data['remoteUserId'] ?? data['receiverId'] ?? data['to'] ?? '')?.toString() ?? '';
      if (from == peer || to == peer) {
        return true;
      }
    }

    return false;
  }

  // ---- Phase 3 helpers (doc 02 §7) ----------------------------------------

  /// Live call history: refresh Recent calls right after a call (both
  /// directions), so it does not wait for a manual refresh.
  void _refreshCallHistory() {
    Future<void>.delayed(const Duration(seconds: 2), () {
      try {
        if (Get.isRegistered<CallController>()) {
          unawaited(CallController.instance.refreshRecentCalls());
        }
      } catch (_) {}
    });
  }

  /// Started from onInit, after the socket handlers.
  void _startPhase3() {
    // Signaling reconnect during the call: tell the server we are still in
    // this call (`rejoinCall`, backend handover) and restart ICE if the media
    // link is down (BUG-CALL-06).
    _handlers.on("connect", (_) => _onSignalingReconnected());
    _handlers.on("mediaState", (dynamic data) {
      if (data is Map && data["mediaState"] is Map) {
        _applyRemoteMediaState(data["mediaState"] as Map);
      } else if (data is Map) {
        _applyRemoteMediaState(data);
      }
    });
    ever<bool>(isMinimized, (_) => _refreshAutoPip());
    ever<bool>(isVideoCall, (_) => _refreshAutoPip());
    ever<bool>(isScreenSharing, (_) => _refreshAutoPip());

    // iOS: outgoing calls in CallKit too (BUG-CALL-12).
    if (!_isIncoming && kReportOutgoingCallsToCallKit) {
      _outgoingCallKitId = CallKitService.newUuid();
      unawaited(_platform.reportOutgoingToCallKit(
        uuid: _outgoingCallKitId,
        name: args["callerName"]?.toString() ?? '',
        handle: remoteUserId,
        isVideo: is_video,
      ));
    }
  }

  void _onSignalingReconnected() {
    if (!isCallLive) return;
    final String cid = callId?.toString() ?? '';
    if (cid.isEmpty || cid == 'null') return;
    if (kDebugMode) log("[CALL] signaling reconnected: rejoinCall $cid");
    socket?.emit("rejoinCall", <String, dynamic>{
      "callId": callId,
      "sessionId": _sessionId,
      "remoteUserId": _peerUserId,
    });
    _linkMonitor.onSignalingReconnected();
    // A hang-up sent while our socket was down is not replayed: ask the
    // server once.
    unawaited(verifyCallStillActive(reason: 'signalingReconnected'));
  }

  bool _isThisCallIds({String sessionId = '', String callId = ''}) =>
      _isForThisCall(<String, dynamic>{
        if (sessionId.isNotEmpty) 'sessionId': sessionId,
        if (callId.isNotEmpty) 'callId': callId,
      });

  Future<bool> _serverSaysCallOver({required bool linkDown}) async {
    if (!isCallLive) return false;
    final String cid = callId?.toString() ?? '';
    if (cid.isEmpty || cid == 'null') return false;
    try {
      final CallServerState? st = await _platform.fetchCallServerState(cid);
      if (kDebugMode) log('[CALL] server state $st linkDown=$linkDown');
      return isServerCallOver(st, linkDown: linkDown);
    } catch (_) {
      return false;
    }
  }

  Future<void> _endBecauseServerSaysOver(String why) async {
    if (!isCallLive) return;
    log('[CALL] the call is over ($why): ending');
    await _cleanupCall(notifyRemote: false, navigateBack: true);
  }

  /// One-shot check (signaling reconnect, an `endCall` push, app resume):
  /// ends the call when the server says it is over. Never ends on an
  /// unknown / failed answer.
  Future<void> verifyCallStillActive({String reason = ''}) async {
    if (!isCallLive || _serverCheckInFlight) return;
    _serverCheckInFlight = true;
    try {
      final bool over =
          await _serverSaysCallOver(linkDown: _linkMonitor.isReconnecting);
      if (over) await _endBecauseServerSaysOver(reason);
    } finally {
      _serverCheckInFlight = false;
    }
  }

  /// The other side hung up according to a push (FCM `endCall`), which can
  /// arrive when the socket event was lost. Ignored when it names another
  /// call. Ends at once when the media link is already down; otherwise the
  /// server confirms first (a late push must never end a healthy call).
  void onRemoteEndHint({String sessionId = '', String callId = ''}) {
    if (!isCallLive) return;
    if (sessionId.isEmpty && callId.isEmpty) return;
    if (!_isThisCallIds(sessionId: sessionId, callId: callId)) return;
    if (_linkMonitor.isReconnecting) {
      unawaited(_endBecauseServerSaysOver('endCall push, link down'));
      return;
    }
    unawaited(verifyCallStillActive(reason: 'endCall push'));
  }

  /// Sends mic / camera / background state to the other side.
  void _emitMediaState({bool videoPaused = false}) {
    final String to = _peerUserId;
    if (to.isEmpty || to == _myUserId || !isCallLive) return;
    socket?.emit(
      "upgradeToVideo",
      mediaStatePayload(
        callId: callId,
        to: to,
        me: _myUserId,
        micMuted: !isAudioOn,
        cameraOn: isVideoOn,
        videoPaused: videoPaused,
      ),
    );
  }

  void _applyRemoteMediaState(Map<dynamic, dynamic> s) {
    bool flag(dynamic v) => v == true || v.toString() == 'true';
    if (s.containsKey("micMuted")) remoteMicMuted.value = flag(s["micMuted"]);
    if (s.containsKey("videoPaused")) {
      remoteVideoPaused.value = flag(s["videoPaused"]);
    }
    update();
  }

  /// Mute from the iOS lock screen / CallKit / headset (BUG-CALL-12).
  /// Does not echo back to CallKit.
  void setMutedFromSystem(bool muted) {
    if (isAudioOn == !muted) return;
    isAudioOn = !muted;
    final bool enabled = isAudioOn;
    if (localStream != null) {
      for (final t in localStream!.getAudioTracks()) {
        t.enabled = enabled;
        try {
          Helper.setMicrophoneMute(!enabled, t);
        } catch (_) {}
      }
    }
    if (peer != null) {
      peer!.getSenders().then((senders) {
        for (final sender in senders) {
          if (sender.track?.kind == 'audio') {
            sender.track?.enabled = enabled;
          }
        }
      }).catchError((_) {});
    }
    _emitMediaState();
    update();
  }

  /// Hold from CallKit (e.g. a cellular call comes in) and resume.
  void setOnHoldFromSystem(bool held) {
    if (isOnHold.value == held) return;
    isOnHold.value = held;
    if (held) {
      _audioBeforeHold = isAudioOn;
      isAudioOn = false;
    } else {
      isAudioOn = _audioBeforeHold;
    }
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    if (isVideoOn) {
      localStream?.getVideoTracks().forEach((t) => t.enabled = !held);
    }
    _emitMediaState(videoPaused: held);
    update();
  }

  /// getStats every 3 s while connected: "Poor connection", lower video
  /// quality on a weak link, suggest camera off once (IMO-like).
  void _startQualityMonitor() {
    if (_statsTimer != null) return;
    _statsTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final RTCPeerConnection? pc = peer;
      if (pc == null || isClosed || _callFinished) return;
      try {
        final List<StatsReport> reports = await pc.getStats();
        final CallQualitySample sample = _statsReader.read(
          reports.map((StatsReport r) =>
              MapEntry<String, Map<dynamic, dynamic>>(r.type, r.values)),
        );
        _onQualitySample(sample);
      } catch (_) {}
    });
  }

  void _onQualitySample(CallQualitySample sample) {
    if (_quality.add(sample)) {
      isPoorConnection.value = _quality.isPoor;
      if (kDebugMode) log("[CALL] quality poor=${_quality.isPoor} $sample");
      if (isVideoOn && !isScreenSharing.value) {
        unawaited(_quality.isPoor
            ? _tuneLocalVideoSender(scaleDown: 2.0, maxBitrate: 400000)
            : _tuneLocalVideoSender(scaleDown: 1.0));
      }
      update();
    }
    if (_quality.takeCameraOffSuggestion(videoOn: isVideoOn)) {
      Utils().fluttertoast(appL10n.call_poorConnectionTip);
    }
  }

  /// Test hook for the quality logic.
  @visibleForTesting
  void debugQualitySample(CallQualitySample sample) => _onQualitySample(sample);

  void _refreshAutoPip() {
    final bool on = isCallLive &&
        CallPip.shouldAutoPip(
          video: isVideoCall.value && (isRemoteVideoOn || isVideoOn),
          connected: callTimer != null,
          minimized: isMinimized.value,
          screenSharing: isScreenSharing.value,
        );
    unawaited(_platform.setAutoPip(on));
  }

  /// Info for the end screen; null when no end screen is shown.
  CallEndInfo? get _endInfo {
    final CallEndOutcome? o = _endOutcome;
    if (o == null) return null;
    return CallEndInfo(
      outcome: o,
      remoteUserId: _peerUserId,
      name: args["callerName"]?.toString() ?? '',
      avatar: (args["profileImage"] ?? args["callerProfile"])?.toString(),
      isVideo: is_video,
    );
  }

  /// Mic (+ camera for video) before any media is opened.
  ///
  /// - Incoming (in-app or CallKit accept): the system dialog is shown on
  ///   the call screen. Refused: the call ends cleanly, the caller gets
  ///   `reason: permission_denied`, the user sees why (P-05; before, the
  ///   call dropped silently). Camera refused: join as voice with the
  ///   camera off and "Camera off · Allow" (P-06).
  /// - Outgoing: CallService already ran the same flow, so this returns at
  ///   once; it only guards entry points that skip CallService.
  Future<bool> _ensureCallPermissions() async {
    final CallPermResult r = await CallPermissionFlow().beforeCall(
      video: is_video,
      incoming: _isIncoming,
      settingsWait: const Duration(seconds: 45),
    );
    if (isClosed || _callFinished) return false;

    if (!r.proceed) {
      if (_isIncoming) {
        _endReason = 'permission_denied';
        Utils().fluttertoast(appL10n.call_permMicNeededToAnswer);
      }
      await _finishCall(
        notifyRemote: _isIncoming,
        navigateBack: true,
        type: 'permission_denied',
      );
      return false;
    }

    if (is_video && !r.video) {
      _cameraBlocked = true;
      isVideoOn = false;
      cameraBlockedByPermission.value = r.cameraBlocked;
      update();
    }
    return true;
  }

  /// Camera ON during a call (P-07). The call continues whatever happens.
  Future<bool> _cameraAllowed() async {
    final bool ok = await CallPermissionFlow().cameraDuringCall();
    if (ok && (_cameraBlocked || cameraBlockedByPermission.value)) {
      _cameraBlocked = false;
      cameraBlockedByPermission.value = false;
      update();
    }
    return ok;
  }

  /// "Camera off · Allow" chip (P-06): ask, then turn the camera on.
  Future<void> allowCameraFromChip() async {
    if (await _cameraAllowed()) {
      await toggleCamera();
    }
  }

  Future<void> _cleanupCall({
    required bool notifyRemote,
    required bool navigateBack,
  }) {
    return _finishCall(
      notifyRemote: notifyRemote,
      navigateBack: navigateBack,
      type: "CallCleanedUp",
    );
  }

  /// The ONE end path of a call. Every way a call ends (own hang-up, remote
  /// end, reject, missed, CallKit / notification End, overlay End, failure)
  /// comes here, and it always releases this controller at the end, so the
  /// next call gets a fresh one (BUG-CALL-01).
  Future<void> _finishCall({
    required bool notifyRemote,
    required bool navigateBack,
    required String type,
    String? sessionId,
  }) async {
    if (_isCleaningUp || _callFinished) return;
    _isCleaningUp = true;
    _callFinished = true;

    final String sid = (sessionId != null && sessionId.isNotEmpty)
        ? sessionId
        : _sessionId;
    if (kDebugMode) log("[CALL] finish type=$type notifyRemote=$notifyRemote");

    try {
      _clearTimers();
      _controlsTimer?.cancel();
      _peerDisconnectTimer?.cancel();

      stopSound();
      _linkMonitor.dispose();
      _endProbe.dispose();
      waitingCall.value = null;
      unawaited(_platform.setAutoPip(false));
      lastEndInfo = _endInfo;
      // Short end tone (busy tone when the other side is busy).
      if (_callAnnounced) {
        _platform.playTone(_endOutcome == CallEndOutcome.busy
            ? kCallBusyToneAsset
            : kCallEndToneAsset);
      }

      if (notifyRemote) {
        _emitEndCallRealtime();
      }

      CallSessionState.reset();

      if (navigateBack) {
        // A navigation error must not skip the cleanup below (foreground
        // service, CallKit, wakelock would stay on).
        try {
          _exitCallScreen();
        } catch (e) {
          log("[Call] exit screen error: $e");
        }
      }
      try {
        InAppCallOverlayService.instance.hideOverlay();
      } catch (_) {}

      await _disposePeerResources();
      await audioRouteController.stopCall();
      await _platform.stopCallService();

      if (sid.isNotEmpty) {
        _platform.clearCallKitAudioHandover(
          sid,
          callId: callId?.toString() ?? '',
        );
        await _platform.dismissCallKit(sid);
        try {
          await _platform.callEndedCleanup(sid, type: type);
        } catch (e) {
          log("[Call] Call cleanup error: $e");
        }
      }
      if (_outgoingCallKitId.isNotEmpty) {
        await _platform.dismissCallKit(_outgoingCallKitId);
      }

      await _platform.setWakelock(false);
      await _platform.setProximity(false);
    } catch (e, stackTrace) {
      log("[Call] General cleanup error: $e", stackTrace: stackTrace);
    } finally {
      _isCleaningUp = false;
      _releaseController();
    }
  }

  void _releaseController() {
    CallForegroundService.onHangUp = null;
    _refreshCallHistory();
    isMinimized.value = false;
    if (Get.isRegistered<CallingController>() &&
        identical(Get.find<CallingController>(), this)) {
      Get.delete<CallingController>(force: true);
    }
  }

  String get _sessionId {
    if (CallSessionState.sessionId != null &&
        CallSessionState.sessionId!.isNotEmpty) {
      return CallSessionState.sessionId!;
    }
    return callId != null ? callId.toString() : "";
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensureAudioTracksActive();
      unawaited(_restoreVideoAfterForeground());
      if (isVideoOn) _emitMediaState();
      // A hang-up while we were in the background may have been missed.
      if (callTimer != null) {
        unawaited(verifyCallStillActive(reason: 'appResumed'));
      }
    } else if (state == AppLifecycleState.paused) {
      _keepTracksAliveInBackground();
      // Other side shows "Video paused" (unless we are in PiP).
      if (isVideoOn && !CallPip.inPip.value) _emitMediaState(videoPaused: true);
    }
  }

  Future<void> _restoreVideoAfterForeground() async {
    if (isClosed || !isVideoCall.value) return;
    log(
      "[CAM] resume: restoring video localOn=$isVideoOn "
      "remoteOn=$isRemoteVideoOn sharing=${isScreenSharing.value}",
    );

    if (isScreenSharing.value) {
      log("[CAM] resume: screen share active - camera rebind/tune skipped");
    } else if (isVideoOn && localStream != null) {
      final MediaStreamTrack? v = localStream!.getVideoTracks().firstOrNull;
      if (v != null) {
        try {
          await localRenderer.setSrcObject(stream: localStream, trackId: v.id);
        } catch (e) {
          log("[CAM] resume: local rebind failed: $e");
        }
      }
      await _tuneLocalVideoSender();
    }

    if (isRemoteVideoOn) {
      await _rebindRemoteForFirstFrames();
      _startFirstFrameWatchdog();
      _requestKeyframe();
      _watchRemoteVideo("resume");
    }

    update();
  }

  void _ensureAudioTracksActive() {
    try {
      if (localStream != null) {
        for (final MediaStreamTrack track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        if (isVideoOn) {
          for (final MediaStreamTrack track in localStream!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      final MediaStream? remoteStream =
          _remoteMediaStream ?? remoteRenderer.srcObject;
      if (remoteStream != null) {
        for (final MediaStreamTrack track in remoteStream.getAudioTracks()) {
          track.enabled = true;
        }
        if (isRemoteVideoOn) {
          for (final MediaStreamTrack track in remoteStream.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      if (isRemoteVideoOn) {
        unawaited(_ensureRemoteVideoBound());
      }

      unawaited(audioRouteController.restoreCurrentRoute());
    } catch (e) {
      log("Error restoring active WebRTC audio states: $e");
    }
  }

  void _keepTracksAliveInBackground() {
    try {
      if (localStream != null) {
        for (final MediaStreamTrack track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        for (final MediaStreamTrack track in localStream!.getVideoTracks()) {
          track.enabled = false;
        }
      }
    } catch (e) {
      log("Error keeping background WebRTC audio alive: $e");
    }
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    try {
      final MediaStream? stream =
          event.streams.isNotEmpty ? event.streams.first : null;

      if (peer == null) return;

      final bool isVideoTrack = event.track.kind == 'video';

      if (isVideoTrack) {
        if (stream != null) {
          _remoteMediaStream = stream;
        }
        _remoteVideoTrack = event.track;
        _remoteVideoTransceiver = event.transceiver;
        event.track.enabled = true;

        if (!_remoteCamStateKnown) {
          isRemoteVideoOn = true;
        }
        isLocalVideoMain = isRemoteVideoOn ? false : isVideoOn;
        is_video = true;
        isVideoCall.value = true;

        log(
          "[CAM] onTrack video id=${event.track.id} "
          "known=$_remoteCamStateKnown remoteOn=$isRemoteVideoOn",
        );

        log(
          "[CAM] onTrack streams=${event.streams.length} "
          "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
        );

        final MediaStream? targetStream = await _remoteStreamForVideo();
        if (targetStream == null) {
          log("[CAM] bind skipped: no remote video stream available");
        } else {
          log(
            "[CAM] bind remote id=${event.track.id} "
            "stream=${targetStream.id} "
            "tracks=${targetStream.getVideoTracks().length}",
          );
          await remoteRenderer.setSrcObject(
            stream: targetStream,
            trackId: event.track.id,
          );
          _logRemoteFrameState();
          _startFirstFrameWatchdog();
          _watchRemoteVideo("bind");
        }
      } else {
        event.track.enabled = true;
        if (stream != null) {
          _remoteMediaStream ??= stream;
        }
        unawaited(audioRouteController.onRemoteAudioTrack(event.track));
        log(
          "[CAM] onTrack audio id=${event.track.id} "
          "streams=${event.streams.length} "
          "storedVideo=${_remoteMediaStream?.getVideoTracks().length ?? -1}",
        );
      }

      stopSound();
      missedCallTimer?.cancel();
      missedCallTimer = null;

      startCallTimer();
      callStatus.value = "Connected";
      update();

      if (!_audioRouteRestored) {
        _audioRouteRestored = true;
        unawaited(audioRouteController.restoreCurrentRoute());
      }

      if (!_callKitConnectedSent &&
          !_callKitAudioHandoverDone &&
          (fromCallKit || args["callType"] == "Incoming")) {
        _callKitConnectedSent = true;
        unawaited(_platform.markCallKitConnected(_sessionId));
      }
    } catch (e, stackTrace) {
      log("[Call] onTrack error: $e", stackTrace: stackTrace);
    }
  }

  void _emitUpgradeIntent() {
    final String myUserId =
        Global.storageServices.get(PrefConst.userId).toString();
    String target = (myUserId == callerId.toString()) ? remoteUserId : callerId;
    if (target.isEmpty || target == myUserId) {
      target = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (target.isEmpty || target == myUserId) return;

    log("[CAM] announce upgrade intent to=$target");
    socket?.emit("requestVideoUpgrade", {
      "callId": callId,
      "remoteUserId": target,
      "callerId": myUserId,
    });
  }

  void _markRemoteUpgrading(String source) {
    if (isUpgradingToVideo.value) return;
    isRemoteUpgrading.value = true;
    log("[CAM] remote upgrading ($source) -> video button disabled");
    _remoteUpgradeTimer?.cancel();
    _remoteUpgradeTimer = Timer(const Duration(seconds: 20), () {
      if (isClosed) return;
      isRemoteUpgrading.value = false;
      log("[CAM] remote upgrade flag cleared (timeout)");
      update();
    });
    update();
  }

  void _clearRemoteUpgrading() {
    if (!isRemoteUpgrading.value) return;
    _remoteUpgradeTimer?.cancel();
    _remoteUpgradeTimer = null;
    isRemoteUpgrading.value = false;
    log("[CAM] remote upgrade flag cleared");
    update();
  }

  Future<void> upgradeToVideoCall() async {
    if (isUpgradingToVideo.value) return;
    if (!await _cameraAllowed()) return;
    if (isRemoteUpgrading.value) {
      log("[CAM] upgrade blocked: remote is already upgrading");
      Utils().fluttertoast(appL10n.call_otherStartingVideo);
      return;
    }
    if (peer == null || localStream == null) {
      Utils().fluttertoast(appL10n.call_notReady);
      return;
    }
    _emitUpgradeIntent();

    try {
      isUpgradingToVideo.value = true;
      log(
        "[CAM] upgrade start videoOn=$isVideoOn remoteOn=$isRemoteVideoOn "
        "sender=${_localVideoSender != null} slotReady=$_videoSlotReady",
      );
      if (!isVideoCall.value) {
        pipPosition = null;
        await audioRouteController.updateCallType(isVideo: true);
      }

      final bool needsRenegotiation = await _ensureLocalVideoTrackAttached(
        peer!,
      );
      log(
        "[CAM] upgrade attach done sender=${_localVideoSender != null} "
        "slotReady=$_videoSlotReady needsReneg=$needsRenegotiation",
      );

      isVideoOn = true;
      isLocalVideoMain = !isRemoteVideoOn;

      await _tuneLocalVideoSender(scaleDown: 2.0);
      _scheduleQualityRestore();

      if (needsRenegotiation || !_videoSlotReady) {
        log("[CAM] upgrade: renegotiating (video m-line not signalled)");
        await _renegotiateVideo();
      } else {
        log("[CAM] upgrade: slot live, no renegotiation needed");
      }

      _emitCameraState(true);
      _clearRemoteUpgrading();
      await _syncVideoState();

      if (callTimer == null && callDurationSeconds == 0) {
        callStatus.value = "Video connecting";
      }
      update();
    } catch (e) {
      log("upgradeToVideoCall error: $e");
    } finally {
      isUpgradingToVideo.value = false;
    }
  }

  void _listenVideoUpgradeEvents() {
    _handlers.off("upgradeToVideo");
    _handlers.off("upgradeToVideoAnswer");
    _handlers.off("requestVideoUpgrade");

    _handlers.on("requestVideoUpgrade", (data) {
      final String from = data["callerId"]?.toString() ?? "";
      log("[CAM] requestVideoUpgrade from=$from");
      _markRemoteUpgrading("intent");
    });

    _handlers.on("upgradeToVideo", (data) async {
      try {
        // Other side's mic / camera / app state (BUG-CALL-17), sent over
        // this relay so today's server forwards it unchanged.
        if (data is Map && data["mediaState"] is Map) {
          _applyRemoteMediaState(data["mediaState"] as Map);
          if (data["sdpOffer"] == null) return;
        }
        final RTCPeerConnection? pc = peer;
        if (pc == null) return;
        final dynamic sdp = data["sdpOffer"];
        // ICE restart: same offer/answer, but no video-upgrade side effects.
        final bool iceRestart = data["iceRestart"] == true;
        log(
          "[CAM] upgradeToVideo recv hasSdp=${sdp != null} "
          "cameraState=${data["cameraState"]} from=${data["callerId"]} "
          "videoOn=$isVideoOn remoteOn=$isRemoteVideoOn",
        );

        if (sdp != null && !_localOfferPending && !iceRestart) {
          _markRemoteUpgrading("offer");
        }

        if (sdp == null) {
          if (data["needKeyframe"] == true) {
            await _forceKeyframe();
            return;
          }

          final dynamic state = data["cameraState"];
          if (state is bool) {
            final bool wasRemoteVideoOn = isRemoteVideoOn;
            _remoteCamStateKnown = true;
            isRemoteVideoOn = state;
            log("[CAM] recv cameraState=$state from=${data["callerId"]}");
            _clearRemoteUpgrading();
            if (!wasRemoteVideoOn && isRemoteVideoOn) {
              isLocalVideoMain = false;
              await _rebindRemoteForFirstFrames();
              _startFirstFrameWatchdog();
              _watchRemoteVideo("camOn");
            } else if (!state && isVideoOn) {
              isLocalVideoMain = true;
            }
            await _syncVideoState();
          }
          return;
        }

        if (_localOfferPending) {
          final String myId =
              Global.storageServices.get(PrefConst.userId).toString();
          final String peerId = data["callerId"]?.toString() ?? "";
          final bool polite = myId.compareTo(peerId) > 0;
          log("[CAM] glare offer from=$peerId polite=$polite");

          if (!polite) {
            log("[CAM] glare: ignoring incoming offer, our offer wins");
            return;
          }

          try {
            await pc.setLocalDescription(RTCSessionDescription('', 'rollback'));
            log("[CAM] glare: rolled back our offer");
          } catch (e) {
            log("[CAM] glare rollback failed: $e");
          }
          _localOfferPending = false;
          _renegotiating = false;
          _pendingRenegotiation = false;
        }

        final bool? remoteCam = _camStateFromSdp(sdp["sdp"]?.toString() ?? '');
        final bool remoteSendingVideo = remoteCam ?? isRemoteVideoOn;
        if (remoteCam != null) {
          _remoteCamStateKnown = true;
        }

        if (!isVideoCall.value && remoteSendingVideo) {
          await audioRouteController.updateCallType(isVideo: true);
        }

        await _applyRemoteSdp(pc, sdp);

        isRemoteVideoOn = remoteSendingVideo;
        if (isRemoteVideoOn) {
          isLocalVideoMain = isVideoOn ? isLocalVideoMain : false;
        } else if (isVideoOn) {
          isLocalVideoMain = true;
        }

        if (!iceRestart && _localVideoSender == null && !isVideoOn) {
          try {
            final bool answerNeedsReneg = await _ensureLocalVideoTrackAttached(
              pc,
              muted: true,
            );
            log(
              "[CAM] answer: muted video track attached before answer "
              "(reneg=$answerNeedsReneg)",
            );
          } catch (e) {
            log("[CAM] answer: muted attach failed: $e");
          }
        }

        bool slotAdvertised = false;
        try {
          final RTCRtpTransceiver? slot = _remoteVideoTransceiver;
          if (slot != null && !iceRestart) {
            await slot.setDirection(TransceiverDirection.SendRecv);
            slotAdvertised = true;
            log("[CAM] answer: video slot advertised sendrecv");
          } else {
            log("[CAM] answer: no video transceiver captured yet");
          }
        } catch (e) {
          log("[CAM] answer: setDirection failed: $e");
        }

        RTCSessionDescription rawAnswer;
        try {
          rawAnswer = await pc.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': true,
          });
        } catch (e) {
          log("[CAM] answer: createAnswer failed with sendrecv: $e");
          if (slotAdvertised) {
            try {
              await _remoteVideoTransceiver?.setDirection(
                TransceiverDirection.RecvOnly,
              );
            } catch (_) {}
            slotAdvertised = false;
          }
          rawAnswer = await pc.createAnswer({
            'offerToReceiveAudio': true,
            'offerToReceiveVideo': true,
          });
        }

        final RTCSessionDescription answer = RTCSessionDescription(
          _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
          rawAnswer.type,
        );
        await pc.setLocalDescription(answer);
        log(
          "[SDP] answer ${_sdpInfo(answer.sdp)} "
          "slotAdvertised=$slotAdvertised",
        );

        if (slotAdvertised) {
          try {
            final TransceiverDirection? current =
                await _remoteVideoTransceiver?.getCurrentDirection();
            _videoSlotReady = current == TransceiverDirection.SendRecv ||
                current == TransceiverDirection.SendOnly;
          } catch (_) {
            _videoSlotReady = false;
          }
          log("[CAM] answer: slotReady=$_videoSlotReady");
        }

        if (isVideoOn) {
          await _tuneLocalVideoSender();
        }

        socket?.emit("upgradeToVideoAnswer", {
          "callId": callId,
          "remoteUserId": data["callerId"],
          "sdpAnswer": answer.toMap(),
        });
        _clearRemoteUpgrading();

        callStatus.value = "Connected";
        await _syncVideoState();
      } catch (e) {
        log("upgradeToVideo handler error: $e");
      }
    });

    _handlers.on("upgradeToVideoAnswer", (data) async {
      try {
        final RTCPeerConnection? pc = peer;
        if (pc == null) return;
        final dynamic sdp = data["sdpAnswer"];
        log(
          "[CAM] upgradeToVideoAnswer recv hasSdp=${sdp != null} "
          "pending=$_localOfferPending",
        );
        if (sdp == null) return;

        if (!_localOfferPending) {
          log("[CAM] ignoring answer: no local offer pending");
          return;
        }
        _localOfferPending = false;

        final bool? remoteCam = _camStateFromSdp(sdp["sdp"]?.toString() ?? '');
        final bool remoteSendingVideo = remoteCam ?? isRemoteVideoOn;
        if (remoteCam != null) {
          _remoteCamStateKnown = true;
        }

        await _applyRemoteSdp(pc, sdp);

        isRemoteVideoOn = remoteSendingVideo;
        if (isRemoteVideoOn) {
          isLocalVideoMain = isVideoOn ? isLocalVideoMain : false;
        } else if (isVideoOn) {
          isLocalVideoMain = true;
        }

        if (isVideoOn) {
          await _tuneLocalVideoSender();
        }

        callStatus.value = "Connected";
        await _syncVideoState();
      } catch (e) {
        log("upgradeToVideoAnswer error: $e");
      }
    });
  }

  /// A `newCall` while this call is live: a SECOND call (BUG-CALL-05).
  /// Before: "Ringing" was sent to that caller although we were busy.
  /// Now: the caller is told "busy" (shows "On another call") and this
  /// screen shows a waiting-call banner: End & accept / Decline.
  void _onNewCall(dynamic data) => showWaitingCall(data);

  /// Also called for an FCM / push of a second call (CallKitService hook).
  void showWaitingCall(dynamic data) {
    if (!isCallLive) return;
    final WaitingCall? w = WaitingCall.parse(
      data,
      decodeCallData: CallKitService.decodeCallData,
      decodeOffer: CallKitService.decodeOffer,
    );
    if (w == null) return;
    // The current call itself, or the same waiting call twice.
    if (w.callId == callId?.toString() || w.callerId == _peerUserId) return;
    if (waitingCall.value?.callId == w.callId) return;

    socket?.emit("CallingStatus", <String, dynamic>{
      "callId": w.callId,
      "remoteUserId": int.tryParse(w.callerId) ?? w.callerId,
      "callingStatus": "busy",
    });
    waitingCall.value = w;
    _waitingTimer?.cancel();
    _waitingTimer = Timer(kCallRingTimeout, () {
      if (waitingCall.value?.callId == w.callId) waitingCall.value = null;
    });
    update();
  }

  /// Waiting call → Decline: the caller gets `reason: busy`.
  void declineWaitingCall() {
    final WaitingCall? w = waitingCall.value;
    if (w == null) return;
    waitingCall.value = null;
    _waitingTimer?.cancel();
    socket?.emit("rejectCall", <String, dynamic>{
      ...rejectCallPayload(callId: w.callId, callerId: w.callerId),
      "reason": "busy",
    });
    final String sid = w.sessionId ?? w.callId;
    unawaited(_platform.dismissCallKit(sid).catchError((_) {}));
    update();
  }

  /// Waiting call → End & accept: end this call, then join the new one.
  Future<void> endAndAcceptWaitingCall() async {
    final WaitingCall? w = waitingCall.value;
    if (w == null) return;
    waitingCall.value = null;
    _waitingTimer?.cancel();
    await endCall(type: "switchToWaitingCall");
    Get.toNamed(
      Routes.callScreen,
      arguments: incomingCallArgs(
        callerId: w.callerId,
        callId: w.callId,
        sessionId: w.sessionId,
        isVideo: w.isVideo,
        callerName: w.callerName,
        profileImage: w.avatar,
        offer: w.offer,
        fromCallKit: false,
      ),
    );
  }

  /// Remote end. Ignored when it names another call (late / replayed event
  /// from an earlier call after a quick redial or a reconnect).
  Future<void> _onCallEnded(dynamic data) async {
    if (!_isForThisCall(data)) {
      log("[CALL] callEnded for another call ignored");
      return;
    }
    // Utils().fluttertoast('Call Ended By ${args["callerName"] ?? "Unknown"}');
    await _cleanupCall(notifyRemote: false, navigateBack: true);
  }

  /// Caller cancelled / ring timed out before an answer (backend
  /// `callCancelled`). Ignored once the call is running or for another call.
  Future<void> _onCallCancelled(dynamic data) async {
    if (!isCallLive || !_isForThisCall(data)) return;
    if (callTimer != null || callDurationSeconds > 0) return;
    await _cleanupCall(notifyRemote: false, navigateBack: true);
  }

  /// The callee answered (backend `callAccepted`, before or without the
  /// SDP answer): stop the no-answer timer and show "Connecting".
  void _onCallAcceptedByServer(dynamic data) {
    if (!isCallLive || !_isForThisCall(data)) return;
    missedCallTimer?.cancel();
    missedCallTimer = null;
    stopSound();
    if (callTimer == null && callDurationSeconds == 0) {
      callStatus.value = "Connecting";
      update();
    }
  }

  Future<void> _onMissedCall(dynamic data) async {
    if (_isCleaningUp) return;
    // The server now sends missedCall to BOTH sides: ignore other calls.
    if (!_isForThisCall(data)) return;

    if (callTimer != null || callDurationSeconds > 0) {
      return;
    }
    // Caller: the server's ring timeout = "No answer" + Call again.
    if (!_isIncoming) _endOutcome = CallEndOutcome.noAnswer;

    final String sessionId = data is Map &&
            data["sessionId"]?.toString().isNotEmpty == true
        ? data["sessionId"].toString()
        : _sessionId;

    await _finishCall(
      notifyRemote: false,
      navigateBack: true,
      type: "missedCallFromSocket",
      sessionId: sessionId,
    );
  }

  void _onCallCreated(dynamic data) {
    try {
      if (data['callId'] != null) callId = data['callId'];
      final sid = data['sessionId'] ?? data['session_id'];
      if (sid != null && sid.toString().isNotEmpty) {
        CallSessionState.sessionId = sid.toString();
      }
    } catch (e) {
      log("[Call] callCreated parse error: $e");
    }
  }

  void _listenForCallEvents() {
    _handlers.off("callRejected");
    _handlers.off("callEnded");
    _handlers.off("endCall");
    _handlers.off("missedCall");
    for (final String ev in kCallCancelSignals) {
      _handlers.off(ev);
    }
    _handlers.off("callAccepted");
    _handlers.off("callStatus");
    _handlers.off("callCreated");
    _handlers.off("newCall");
    _handlers.off("sdpOfferFromCaller");
    _handlers.off("callError");
    _handlers.off("callBlocked");
    _handlers.off("screen_share_started");
    _handlers.off("screen_share_stopped");
    _handlers.off("screen_share_offer");
    _handlers.off("screen_share_answer");
    _handlers.off("screen_share_ice");

    _handlers.on("callCreated", _onCallCreated);

    _handlers.on("callError", (data) async {
      log("CALL ERROR => $data");
      final String code = (data is Map ? data["code"] : null)?.toString() ?? '';
      // Only tear down the call if it has not connected yet, or if it is fatal (call_expired / call_unavailable)
      if (!isCallLive || code == "call_expired" || code == "call_unavailable") {
        if (!_isIncoming) _endOutcome = CallEndOutcome.unavailable;
        await _cleanupCall(notifyRemote: false, navigateBack: true);
        Get.snackbar(
          appL10n.call_failedTitle,
          data?["message"]?.toString() ?? appL10n.call_unableToMakeCall,
        );
      } else {
        log("[Call] Non-fatal callError ignored during active connection: $data");
      }
    });

    _handlers.on("callBlocked", (data) async {
      log("CALL BLOCKED => $data");
      await _cleanupCall(notifyRemote: false, navigateBack: true);
      Get.snackbar(
        appL10n.call_unavailableTitle,
        data?["message"]?.toString() ??
            appL10n.call_communicationUnavailable,
      );
    });

    _handlers.on("sdpOfferFromCaller", (data) async {
      final RTCPeerConnection? pc = peer;
      if (pc == null) return;

      try {
        final dynamic sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;
        offer = sdp;
        callId = data["callId"] ?? callId;

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": callerId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };

        await _applyRemoteSdp(pc, sdp);

        final RTCSessionDescription rawAnswer = await pc.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true,
        });
        final RTCSessionDescription answer = RTCSessionDescription(
          _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
          rawAnswer.type,
        );
        await pc.setLocalDescription(answer);
        log("[SDP] callkit answer ${_sdpInfo(answer.sdp)}");

        _callAnnounced = true;
        socket!.emit("answerCall", {
          "callId": callId,
          "callerId": callerId,
          "sdpAnswer": answer.toMap(),
        });
        if (callTimer == null && callDurationSeconds == 0) {
          callStatus.value = "Connecting";
        }
      } catch (e) {
        log("Error handling sdpOfferFromCaller: $e");
      }
    });

    _handlers.on("newCall", _onNewCall);
    _handlers.on("callEnded", _onCallEnded);
    _handlers.on("endCall", _onCallEnded);
    _handlers.on("missedCall", _onMissedCall);
    // Agreed with the backend (point 7); today's server does not send them.
    for (final String ev in kCallCancelSignals) {
      if (ev == 'cancelCall') continue; // not a socket event today
      _handlers.on(ev, _onCallCancelled);
    }
    _handlers.on("callAccepted", _onCallAcceptedByServer);

    _handlers.on("callRejected", (data) async {
      if (!_isForThisCall(data)) return;
      if (callTimer != null || callDurationSeconds > 0) {
        return;
      }
      if (!_isIncoming) _endOutcome = rejectOutcome(data);

      // Utils().fluttertoast(
      //   'Call Rejected By ${args["callerName"] ?? "Unknown"}',
      //   bgColor: Colors.red,
      // );
      await _cleanupCall(notifyRemote: false, navigateBack: true);
    });

    _handlers.on("callStatus", (data) {
      final status = (data["status"] ?? data["callingStatus"])?.toString();
      if (status == null || status.isEmpty) return;
      // Never let a status for another (earlier) call touch this one.
      if (!_isForThisCall(data)) return;

      if (data['callId'] != null) {
        callId = data['callId'];
      }

      final String normalized = status.trim().toLowerCase();
      if (normalized == "rejected" || normalized == "declined") {
        if (callTimer == null && callDurationSeconds == 0) {
          if (!_isIncoming) _endOutcome = rejectOutcome(data);
          // Utils().fluttertoast(
          //   'Call Rejected By ${args["callerName"] ?? "Unknown"}',
          //   bgColor: Colors.red,
          // );
          unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
          return;
        }
      } else if (normalized == "busy") {
        // The callee is on another call; they may still take this one.
        if (callTimer == null && callDurationSeconds == 0) {
          callStatus.value = "On another call";
          update();
        }
        return;
      } else if (normalized == "ended" ||
          normalized == "callended" ||
          normalized == "disconnected" ||
          normalized == "cancelled" ||
          normalized == "canceled") {
        unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
        return;
      } else if (normalized == "connected" ||
          normalized == "accepted" ||
          normalized == "in_call") {
        // Answered / rejoinCall reply: keep the running timer as is, and
        // never show the raw server word.
        if (callTimer == null && callDurationSeconds == 0) {
          missedCallTimer?.cancel();
          missedCallTimer = null;
          callStatus.value = "Connecting";
          update();
        }
        return;
      }

      if (callTimer == null && callDurationSeconds == 0) {
        callStatus.value = status;
      }
    });

    _handlers.on("screen_share_started", (data) {
      log("[SHARE] remote started: $data");
      isRemoteScreenSharing.value = true;
      showControlsTemporarily();
      update();
    });

    _handlers.on("screen_share_stopped", (data) async {
      log("[SHARE] remote stopped: $data");
      isRemoteScreenSharing.value = false;
      _remoteScreenStream = null;
      _clearScreenRenderer();
      showControlsTemporarily();

      if (isScreenSharing.value) {
        log("[SHARE] stop echo ignored: we are the sharer");
        update();
        return;
      }

      await _teardownScreenStream();
      update();
    });

    _handlers.on("screen_share_offer", (data) async {
      try {
        final sdp = data["sdpOffer"];
        if (sdp == null) return;

        if (isScreenSharing.value) {
          log("[SHARE] incoming offer ignored: we are the sharer");
          return;
        }

        await _teardownScreenStream();

        final pc = await createPeerConnection({
          'sdpSemantics': 'unified-plan',
          'iceServers': await TurnCredentialService.instance.iceServers(),
        });
        _screenPc = pc;

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          if (_screenRemoteDescSet) {
            socket?.emit("screen_share_ice", {
              "callId": callId,
              "remoteUserId": _screenPeerUserId,
              "iceCandidate": {
                "id": c.sdpMid,
                "label": c.sdpMLineIndex,
                "candidate": c.candidate,
              },
            });
          } else {
            _screenPendingLocalIce.add(c);
          }
        };

        pc.onTrack = (event) async {
          if (event.track.kind != 'video') return;
          final stream = event.streams.isNotEmpty
              ? event.streams.first
              : await createLocalMediaStream('remote_screen');
          if (event.streams.isEmpty) await stream.addTrack(event.track);
          _remoteScreenStream = stream;
          try {
            await screenRenderer.setSrcObject(
              stream: stream,
              trackId: event.track.id,
            );
          } catch (e) {
            log("[SHARE] remote screen bind error: $e");
          }
          isRemoteScreenSharing.value = true;
          update();
          log("[SHARE] remote screen track bound id=${event.track.id}");
        };

        await pc.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
        );
        _screenRemoteDescSet = true;

        for (final c in _screenPendingRemoteIce) {
          await pc.addCandidate(
            RTCIceCandidate(c["candidate"], c["id"], c["label"]),
          );
        }
        _screenPendingRemoteIce.clear();

        final answer = await pc.createAnswer({
          'offerToReceiveAudio': false,
          'offerToReceiveVideo': true,
        });
        await pc.setLocalDescription(answer);

        socket?.emit("screen_share_answer", {
          "callId": callId,
          "remoteUserId":
              data["sharerId"] ?? data["userId"] ?? _screenPeerUserId,
          "sdpAnswer": answer.toMap(),
        });

        for (final c in _screenPendingLocalIce) {
          socket?.emit("screen_share_ice", {
            "callId": callId,
            "remoteUserId": _screenPeerUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        _screenPendingLocalIce.clear();
      } catch (e, st) {
        log("[SHARE] offer handler error: $e\n$st");
      }
    });

    _handlers.on("screen_share_answer", (data) async {
      try {
        final sdp = data["sdpAnswer"];
        final pc = _screenPc;
        if (sdp == null || pc == null) return;
        await pc.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
        );
        _screenRemoteDescSet = true;

        for (final c in _screenPendingLocalIce) {
          socket?.emit("screen_share_ice", {
            "callId": callId,
            "remoteUserId": _screenPeerUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        _screenPendingLocalIce.clear();
        for (final c in _screenPendingRemoteIce) {
          await pc.addCandidate(
            RTCIceCandidate(c["candidate"], c["id"], c["label"]),
          );
        }
        _screenPendingRemoteIce.clear();
      } catch (e) {
        log("[SHARE] answer handler error: $e");
      }
    });

    _handlers.on("screen_share_ice", (data) async {
      try {
        final ice = data["iceCandidate"];
        if (ice == null) return;
        final pc = _screenPc;
        final cand = RTCIceCandidate(ice["candidate"], ice["id"], ice["label"]);
        if (pc != null && _screenRemoteDescSet) {
          await pc.addCandidate(cand);
        } else {
          _screenPendingRemoteIce.add({
            "candidate": ice["candidate"],
            "id": ice["id"],
            "label": ice["label"],
          });
        }
      } catch (e) {
        log("[SHARE] ice handler error: $e");
      }
    });

    _listenVideoUpgradeEvents();
  }

  Future<void> resetPeer() async {
    await _disposePeerResources();
  }

  void _clearScreenRenderer() {
    try {
      screenRenderer.srcObject = null;
    } catch (_) {}
  }

  void _disposeScreenRenderer() {
    try {
      screenRenderer.dispose();
    } catch (_) {}
  }

  Future<void> _disposePeerResources() async {
    try {
      _peerDisconnectTimer?.cancel();
      _peerDisconnectTimer = null;
      _clearScreenRenderer();
      navigator.mediaDevices.ondevicechange = null;

      final RTCPeerConnection? pc = peer;
      peer = null;
      _localVideoSender = null;
      _remoteMediaStream = null;
      _remoteVideoTrack = null;
      _remoteCamStateKnown = false;
      _remoteVideoTransceiver = null;
      _videoSlotReady = false;
      _fallbackRemoteStream = null;
      _remoteDescriptionSet = false;
      _audioRouteRestored = false;
      _renegotiating = false;
      _pendingRenegotiation = false;
      _localOfferPending = false;
      isRemoteUpgrading.value = false;
      _remoteUpgradeTimer?.cancel();
      isRemoteVideoOn = false;
      isRemoteVideoLoading.value = false;
      _pendingRemoteCandidates.clear();

      if (pc != null) {
        pc.onIceConnectionState = null;
        pc.onConnectionState = null;
        pc.onSignalingState = null;
        pc.onTrack = null;
        pc.onIceCandidate = null;
      }

      localStream?.getTracks().forEach((track) {
        track.stop();
      });

      await localStream?.dispose();
      localStream = null;

      // Throws on a renderer that was never initialized (call failed early);
      // that used to skip the rest of this cleanup.
      try {
        remoteRenderer.srcObject = null;
        localRenderer.srcObject = null;
      } catch (_) {}

      await pc?.close();

      _screenSender = null;
      final MediaStream? screenStreamToStop = _screenStream;
      _screenStream = null;
      try {
        screenStreamToStop?.getTracks().forEach((t) => t.stop());
        await screenStreamToStop?.dispose();
      } catch (_) {}
      final RTCPeerConnection? screenPcToClose = _screenPc;
      _screenPc = null;
      try {
        await screenPcToClose?.close();
      } catch (_) {}
      _screenShareAnnounced = false;
      _screenRemoteDescSet = false;
      _screenPendingLocalIce.clear();
      _screenPendingRemoteIce.clear();
      isScreenSharing.value = false;
      isScreenShareLive.value = false;

      _handlers.off("IceCandidate");
      _handlers.off("callAnswered");
    } catch (e, stackTrace) {
      log("[Call] Peer dispose error: $e", stackTrace: stackTrace);
    }
  }

  void safeAddCandidate(dynamic data) {
    try {
      final ice = data["iceCandidate"];
      if (ice == null) return;

      if (peer == null || !_remoteDescriptionSet) {
        _pendingRemoteCandidates.add(data);
        return;
      }

      final c = RTCIceCandidate(ice["candidate"], ice["id"], ice["label"]);

      unawaited(
        peer!.addCandidate(c).catchError((e) {
          log("[Call] addCandidate error: $e");
        }),
      );
    } catch (e) {
      log("[Call] safeAddCandidate error: $e");
    }
  }

  Future<void> _markRemoteDescriptionSet() async {
    _remoteDescriptionSet = true;

    if (_pendingRemoteCandidates.isEmpty) return;

    final List<dynamic> pending = List<dynamic>.from(_pendingRemoteCandidates);
    _pendingRemoteCandidates.clear();

    for (final d in pending) {
      safeAddCandidate(d);
    }
  }

  // ICE disconnected / failed → CallLinkMonitor (BUG-CALL-06): show
  // "Reconnecting…", restart ICE, end only after the give-up limit.
  // (Before: 30 s / 12 s timer, then hang up, no ICE restart.)
  void _startPeerDisconnectTimer({
    Duration grace = const Duration(seconds: 30),
  }) {
    _linkMonitor.onState(
      grace.inSeconds <= 12 ? CallLinkState.failed : CallLinkState.disconnected,
    );
  }

  void _cancelPeerDisconnectTimer() {
    _linkMonitor.onState(CallLinkState.connected);
  }

  void _onLinkAction(CallLinkAction action) {
    if (isClosed || _callFinished) return;
    if (kDebugMode) log("[CALL] link action=$action");
    switch (action) {
      case CallLinkAction.showReconnecting:
        if (_everConnected || _linkMonitor.everConnected) {
          callStatus.value = "Reconnecting...";
          update();
        }
        _endProbe.start();
        break;
      case CallLinkAction.iceRestart:
        unawaited(_renegotiateVideo(iceRestart: true));
        break;
      case CallLinkAction.recovered:
        _endProbe.stop();
        if (callStatus.value == "Reconnecting...") {
          callStatus.value = callTimer != null ? "Connected" : "Connecting";
          update();
        }
        break;
      case CallLinkAction.connectionLost:
        _endProbe.dispose();
        _endReason = 'connection_lost';
        _endOutcome = CallEndOutcome.connectionLost;
        _handlePeerDisconnected();
        break;
    }
  }

  /// Test hook: drive the reconnect logic without a real peer connection.
  @visibleForTesting
  void debugLinkAction(CallLinkAction action) => _onLinkAction(action);

  /// Test hook: feed a media-link state into the real link monitor.
  @visibleForTesting
  void debugLinkState(CallLinkState state) => _linkMonitor.onState(state);

  /// Test hook: true while the server-check probe runs.
  @visibleForTesting
  bool get debugEndProbeRunning => _endProbe.isRunning;

  Future<void> _setupPeer() async {
    await resetPeer();

    // Use the CURRENT socket and wait until it is connected (BUG-CALL-02).
    // Nothing is sent to the other user if signaling is unreachable.
    final Socket? live = await SignallingService.instance.ensureConnected();
    if (live == null) {
      throw const CallSignalingUnavailable();
    }
    if (isClosed || _callFinished) return;
    // Handlers registered in onInit may sit on an older socket object.
    _listenForCallEvents();

    _handlers.off("IceCandidate");
    _handlers.off("callAnswered");

    _handlers.on("IceCandidate", (data) {
      safeAddCandidate(data);
    });

    // Short-lived TURN credentials from the backend when available, else
    // the static list (now incl. TURN over TLS 443). BUG-CALL-07.
    final List<Map<String, dynamic>> iceServers =
        await TurnCredentialService.instance.iceServers();
    final RTCPeerConnection pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'iceServers': iceServers,
      'iceTransportPolicy': 'all',
    });
    peer = pc;

    pc.onIceConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] ICE state: $state");

      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _everConnected = true;
        _cancelPeerDisconnectTimer();
        missedCallTimer?.cancel();
        missedCallTimer = null;
        // Normally already running since onInit; restarts it if that failed.
        unawaited(_platform.startCallService(video: isVideoCall.value));
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        unawaited(_serverSaysCallOver(linkDown: true).then((over) {
          if (over) _endBecauseServerSaysOver('ice-disconnected');
        }));
        _startPeerDisconnectTimer();
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        unawaited(_serverSaysCallOver(linkDown: true).then((over) {
          if (over) _endBecauseServerSaysOver('ice-failed');
        }));
        _startPeerDisconnectTimer(grace: const Duration(seconds: 12));
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        return;
      }
    };

    pc.onConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] Peer connection state: $state");

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _everConnected = true;
        _cancelPeerDisconnectTimer();
        // Normally already running since onInit; restarts it if that failed.
        unawaited(_platform.startCallService(video: isVideoCall.value));
        unawaited(audioRouteController.reapplyCurrentRoute());
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        unawaited(_serverSaysCallOver(linkDown: true).then((over) {
          if (over) _endBecauseServerSaysOver('peer-failed');
        }));
        _startPeerDisconnectTimer(grace: const Duration(seconds: 12));
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        unawaited(_serverSaysCallOver(linkDown: true).then((over) {
          if (over) _endBecauseServerSaysOver('peer-disconnected');
        }));
        _startPeerDisconnectTimer();
        return;
      }

      // Closed under a live call (we detach these handlers before closing
      // it ourselves): the media is gone. Reconnect / server check instead
      // of silently showing a frozen call.
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed &&
          isCallLive &&
          (_everConnected || _linkMonitor.everConnected)) {
        _startPeerDisconnectTimer(grace: const Duration(seconds: 12));
      }
    };

    pc.onTrack = (event) {
      if (!identical(peer, pc)) return;
      unawaited(_handleRemoteTrack(event));
    };

    await audioRouteController.prepareCall(isVideo: is_video == true);
    // unawaited(startCallForegroundService());

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': is_video == true && !_cameraBlocked
          ? _videoCaptureConstraints()
          : false,
    });

    for (final MediaStreamTrack t in localStream!.getTracks()) {
      final RTCRtpSender sender = await pc.addTrack(t, localStream!);
      if (t.kind == 'video') {
        _localVideoSender = sender;
      }
    }

    if (is_video == true && !_cameraBlocked) {
      _logCaptureSettings("setup");
      await _tuneLocalVideoSender();
      final MediaStreamTrack? vidTrack =
          localStream!.getVideoTracks().firstOrNull;
      if (vidTrack != null) {
        await localRenderer.setSrcObject(
          stream: localStream,
          trackId: vidTrack.id,
        );
      } else {
        localRenderer.srcObject = localStream;
      }
    } else {
      localRenderer.srcObject = null;
    }

    final bool isIncomingCall = fromCallKit || args["callType"] == "Incoming";
    log(
      "[Call] Audio route start video=$is_video incoming=$isIncomingCall "
      "fromCallKit=$fromCallKit callType=${args["callType"]}",
    );
    unawaited(
      audioRouteController
          .startCall(isVideo: is_video, isIncoming: isIncomingCall)
          .catchError((e) {
        log("[Call] Audio route start error: $e");
      }),
    );

    update();

    if (offer != null) {
      pc.onIceCandidate = (c) {
        if (c.candidate == null) return;
        socket!.emit("IceCandidate", {
          "remoteUserId": callerId,
          "iceCandidate": {
            "id": c.sdpMid,
            "label": c.sdpMLineIndex,
            "candidate": c.candidate,
          },
        });
      };

      await _applyRemoteSdp(pc, offer);

      final RTCSessionDescription rawAnswer = await pc.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription answer = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawAnswer.sdp ?? ''), isVideoOn),
        rawAnswer.type,
      );
      await pc.setLocalDescription(answer);
      log("[SDP] initial answer ${_sdpInfo(answer.sdp)}");

      _callAnnounced = true;
      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": answer.toMap(),
      });
      unawaited(_handoverCallKitAudio());
    } else if (fromCallKit ||
        (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";
      final dynamic resolvedReceiverId = _myUserId.isNotEmpty
          ? _myUserId
          : Global.storageServices.get(PrefConst.userId);
      final acceptPayload = {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": resolvedReceiverId,
      };
      _callAnnounced = true;
      socket?.emit("acceptCallFromCallKit", acceptPayload);
      unawaited(_handoverCallKitAudio());
    } else {
      pc.onIceCandidate = (c) => iceCandidates.add(c);

      _handlers.on("callAnswered", (data) async {
        if (!identical(peer, pc) || _remoteDescriptionSet) return;

        stopSound();
        missedCallTimer?.cancel();
        missedCallTimer = null;

        try {
          await _applyRemoteSdp(pc, data["sdpAnswer"]);
          if (isVideoCall.value && isVideoOn) {
            await _tuneLocalVideoSender();
          }
        } catch (e) {
          log("[Call] callAnswered handler error: $e");
          return;
        }

        for (final c in iceCandidates) {
          if (c.candidate == null) continue;
          socket!.emit("IceCandidate", {
            "callId": callId,
            "call_id": callId,
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        iceCandidates.clear();

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "callId": callId,
            "call_id": callId,
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };
      });

      final RTCSessionDescription rawOffer = await pc.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      final RTCSessionDescription sdpOffer = RTCSessionDescription(
        _withCamTag(_preferH264InSdp(rawOffer.sdp ?? ''), isVideoOn),
        rawOffer.type,
      );
      await pc.setLocalDescription(sdpOffer);
      log("[SDP] initial offer ${_sdpInfo(sdpOffer.sdp)}");

      _callAnnounced = true;
      socket!.emit("makeCall", {
        "remoteUserId": remoteUserId,
        "sdpOffer": sdpOffer.toMap(),
        "is_video": is_video,
        "callerId": Global.storageServices.get(PrefConst.userId),
      });

      startMissedCallTimer();
    }
  }

  Future<void> _handoverCallKitAudio() async {
    if (_callKitAudioHandoverDone) return;
    if (!(fromCallKit || args["callType"] == "Incoming")) return;

    if (defaultTargetPlatform != TargetPlatform.android) return;

    _callKitAudioHandoverDone = true;

    final String sid =
        _sessionId.isNotEmpty ? _sessionId : (callId?.toString() ?? '');
    if (sid.isEmpty) return;

    bool done = false;
    for (int attempt = 1; attempt <= 5 && !done; attempt++) {
      try {
        done = await CallKitService.releaseAudioOwnership(
          sid,
          callId: callId?.toString() ?? '',
        );
        log("[Call] CallKit handover attempt=$attempt done=$done sid=$sid");
      } catch (e) {
        log("[Call] CallKit handover attempt=$attempt error: $e");
      }
      if (!done) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    if (isClosed || _isCleaningUp) return;

    try {
      await audioRouteController.reapplyCurrentRoute();
      log(
        "[Call] route re-asserted after handover "
        "route=${audioRouteController.currentRoute.value}",
      );
    } catch (e) {
      log("[Call] route re-assert after handover error: $e");
    }
  }

  /// Local hang-up (End button, overlay End, CallKit / notification End,
  /// missed-call timeout). Always tells the other side once.
  Future<void> endCall({String? type}) {
    return _finishCall(
      notifyRemote: true,
      navigateBack: true,
      type: "endCall:${type ?? 'button'}",
    );
  }

  void _handlePeerDisconnected() {
    if (_isCleaningUp || isClosed) return;
    unawaited(_cleanupCall(notifyRemote: true, navigateBack: true));
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    final bool enabled = isAudioOn;
    if (localStream != null) {
      for (final t in localStream!.getAudioTracks()) {
        t.enabled = enabled;
        try {
          Helper.setMicrophoneMute(!enabled, t);
        } catch (_) {}
      }
    }
    if (peer != null) {
      peer!.getSenders().then((senders) {
        for (final sender in senders) {
          if (sender.track?.kind == 'audio') {
            sender.track?.enabled = enabled;
          }
        }
      }).catchError((_) {});
    }
    _emitMediaState();
    // Keep the iOS lock screen / CallKit mute button in sync.
    unawaited(_platform.syncCallKitMute(_callKitId, !enabled));
    update();
  }

  void _emitCameraState(bool cameraOn) {
    final String myUserId =
        Global.storageServices.get(PrefConst.userId).toString();
    String targetUser =
        (myUserId == callerId.toString()) ? remoteUserId : callerId;

    if (targetUser.isEmpty || targetUser == myUserId) {
      targetUser = (remoteUserId.isNotEmpty && remoteUserId != myUserId)
          ? remoteUserId
          : callerId;
    }
    if (targetUser.isEmpty || targetUser == myUserId) {
      log(
        "[CAM] no peer for cameraState=$cameraOn "
        "(callerId=$callerId remoteUserId=$remoteUserId)",
      );
      return;
    }

    log("[CAM] send cameraState=$cameraOn to=$targetUser");

    socket?.emit("upgradeToVideo", {
      "callId": callId,
      "remoteUserId": targetUser,
      "callerId": myUserId,
      "cameraState": cameraOn,
    });
  }

  Future<void> toggleCamera() async {
    final RTCPeerConnection? pc = peer;
    if (pc == null) return;

    final List<MediaStreamTrack> vids =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (vids.isEmpty) {
      await upgradeToVideoCall();
      return;
    }

    // Turning the camera ON needs the permission (P-07). Off never does.
    if (!isVideoOn && !await _cameraAllowed()) return;

    isVideoOn = !isVideoOn;
    for (final MediaStreamTrack t in vids) {
      t.enabled = isVideoOn;
    }
    log(
      "[CAM] toggle -> on=$isVideoOn tracks=${vids.length} "
      "sender=${_localVideoSender != null} slotReady=$_videoSlotReady",
    );

    if (isVideoOn) {
      if (localStream != null && !isScreenSharing.value) {
        await localRenderer.setSrcObject(
          stream: localStream,
          trackId: vids.first.id,
        );
      }
      if (!isRemoteVideoOn) {
        isLocalVideoMain = true;
      }
    } else if (isRemoteVideoOn) {
      isLocalVideoMain = false;
    }
    update();

    _emitCameraState(isVideoOn);

    try {
      await _applyLocalVideoSending(isVideoOn ? vids.first : null);
      log("[CAM] toggle applied replaceTrack=${isVideoOn ? 'track' : 'null'}");
      if (isVideoOn && !isScreenSharing.value) {
        await _tuneLocalVideoSender();
      }
      await _syncVideoState();
    } catch (e) {
      log("[Call] toggleCamera error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_isSwitchingCamera || !isVideoCall.value || !isVideoOn) return;
    final List<MediaStreamTrack> tracks =
        localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (tracks.isEmpty) return;

    _isSwitchingCamera = true;
    showControlsTemporarily();
    try {
      final MediaStreamTrack track = tracks.first;
      await Helper.switchCamera(track);
      isFrontCamera = !isFrontCamera;
      update();
      unawaited(_forceKeyframe());
    } catch (e) {
      log("[Call] switchCamera error: $e");
    } finally {
      _isSwitchingCamera = false;
    }
  }

  Future<void> toggleSpeaker(BuildContext context) async {
    final bool hasExternal = (audioRouteController.isBluetoothConnected.value &&
            CallAudioRouteController.bluetoothPermitted.value) ||
        audioRouteController.isHeadsetConnected.value;
    if (!hasExternal) {
      final CallAudioRoute current = audioRouteController.currentRoute.value;
      final CallAudioRoute next = current == CallAudioRoute.speaker
          ? CallAudioRoute.earpiece
          : CallAudioRoute.speaker;
      await audioRouteController.selectRoute(next);
      update();
      return;
    }
    showAudioRoutePicker(context);
  }

  Future<void> showAudioRoutePicker(BuildContext context) async {
    if (!context.mounted) return;

    await audioRouteController.checkDevices();
    if (!context.mounted) return;

    // Android 12+: Bluetooth audio needs BLUETOOTH_CONNECT. Asked only here,
    // when a Bluetooth device is present; denied = Bluetooth hidden (P-08).
    CallAudioRouteController.bluetoothPermitted.value =
        await CallPermissionFlow().bluetoothForRoutes(
      devicePresent: audioRouteController.isBluetoothConnected.value,
    );
    if (!context.mounted) return;

    final CallAudioRoute? selected = await showAudioRouteSheet(
      context,
      audioRouteController,
    );

    if (selected != null) {
      await audioRouteController.selectRoute(selected);
    }
  }

  String get formattedDuration {
    final int secs = callDurationRx.value;
    final minutes = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void startCallTimer() {
    if (callTimer != null) return;
    // The ringback stops when the call connects. This used to happen as a
    // side effect of the `formattedDuration` getter (BUG-CALL-18).
    stopSound();
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDurationSeconds++;
      callDurationRx.value = callDurationSeconds;
      if (!isVideoCall.value) {
        update();
      }
    });
    _startQualityMonitor();
    _refreshAutoPip();
    if (_outgoingCallKitId.isNotEmpty) {
      unawaited(_platform.markCallKitConnected(_outgoingCallKitId));
    }
  }

  void startMissedCallTimer() {
    missedCallTimer?.cancel();
    missCallDurationSeconds.value = kCallRingTimeout.inSeconds;
    missedCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (missCallDurationSeconds.value > 0) {
        missCallDurationSeconds.value--;
      }
      if (missCallDurationSeconds.value == 0) {
        timer.cancel();
        missedCall(timedOut: true);
      }
    });
  }

  /// Caller side: ring timeout ([timedOut], shows "No answer" with Call
  /// again) or the user cancelled before an answer.
  Future<void> missedCall({bool timedOut = false}) async {
    if (!isCallLive) return;
    if (timedOut) _endOutcome = CallEndOutcome.noAnswer;
    final Map<String, dynamic> param = {
      "callId": callId,
      "remoteUserId": remoteUserId,
    };

    socket?.emit("missCall", param);

    await endCall(type: "missedCall");
  }

  void _clearTimers() {
    callTimer?.cancel();
    _statsTimer?.cancel();
    _statsTimer = null;
    _waitingTimer?.cancel();
    missedCallTimer?.cancel();
    _firstFrameTimer?.cancel();
    _qualityTimer?.cancel();
    _remoteUpgradeTimer?.cancel();
    callTimer = null;
    missedCallTimer = null;
    _firstFrameTimer = null;
    _qualityTimer = null;
    missCallDurationSeconds.value = 0;
  }

  void playSound() {
    _platform.playRingback(_platform.ringbackAsset);
  }

  void stopSound() {
    _platform.stopRingtone();
  }

  void updatePipPosition({
    required Offset delta,
    required double pipWidth,
    required double pipHeight,
    required double minLeft,
    required double maxLeft,
    required double minTop,
    required double maxTop,
  }) {
    final Offset currentPosition = pipPosition ?? Offset(minLeft, maxTop);
    final double boundedMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;
    final double boundedMaxTop = maxTop < minTop ? minTop : maxTop;

    pipPosition = Offset(
      (currentPosition.dx + delta.dx).clamp(minLeft, boundedMaxLeft),
      (currentPosition.dy + delta.dy).clamp(minTop, boundedMaxTop),
    );
    update();
  }

  String get _screenPeerUserId {
    final myId = Global.storageServices.get(PrefConst.userId).toString();
    return (myId == callerId.toString()) ? remoteUserId : callerId;
  }

  Future<void> startScreenShare() async {
    if (_screenShareStarting || isScreenSharing.value) return;
    if (peer == null || isClosed) {
      Utils().fluttertoast(appL10n.call_notReady);
      return;
    }
    if (isRemoteScreenSharing.value) {
      Utils().fluttertoast(appL10n.call_otherAlreadySharing);
      return;
    }

    _screenShareStarting = true;
    _screenShareAnnounced = false;
    _screenRemoteDescSet = false;
    _screenPendingLocalIce.clear();
    _screenPendingRemoteIce.clear();
    isScreenShareWaiting.value = false;
    log("[SHARE] start begin videoOn=$isVideoOn");

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool ready = await _prepareAndroidProjection();
        if (!ready) {
          log("[SHARE] android projection not ready - share aborted");
          return;
        }
      }

      final Map<String, dynamic> constraints = WebRTC.platformIsIOS
          ? <String, dynamic>{
              'video': <String, dynamic>{'deviceId': 'broadcast'},
            }
          : <String, dynamic>{'video': true, 'audio': false};

      final MediaStream? stream =
          await navigator.mediaDevices.getDisplayMedia(constraints);
      if (stream == null || stream.getVideoTracks().isEmpty) {
        log("[SHARE] getDisplayMedia returned no video track");
        throw Exception("No screen stream");
      }

      _screenStream = stream;
      final MediaStreamTrack screenTrack = stream.getVideoTracks().first;
      screenTrack.enabled = true;
      log(
        "[SHARE] getDisplayMedia ok stream=${stream.id} "
        "track=${screenTrack.id} ios=${WebRTC.platformIsIOS}",
      );

      screenTrack.onEnded = () {
        log("[SHARE] screen track onEnded sharing=${isScreenSharing.value}");
        if (isScreenSharing.value) {
          unawaited(stopScreenShare());
        }
      };

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        isScreenShareWaiting.value = true;
        final bool started = await _waitForIosCapture(stream);
        isScreenShareWaiting.value = false;
        if (!started) {
          log("[SHARE] ios: capture never started - share aborted, remote "
              "was never notified");
          await _teardownScreenStream();
          isScreenSharing.value = false;
          isScreenShareLive.value = false;
          update();
          return;
        }
      }

      socket?.emit("start_screen_share", {
        "callId": callId,
        "remoteUserId": _screenPeerUserId,
      });
      _screenShareAnnounced = true;
      log("[SHARE] start_screen_share to=$_screenPeerUserId callId=$callId");

      final pc = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
        'iceServers': await TurnCredentialService.instance.iceServers(),
      });
      _screenPc = pc;

      pc.onIceCandidate = (c) {
        if (c.candidate == null) return;
        if (_screenRemoteDescSet) {
          socket?.emit("screen_share_ice", {
            "callId": callId,
            "remoteUserId": _screenPeerUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        } else {
          _screenPendingLocalIce.add(c);
        }
      };

      pc.onConnectionState = (s) {
        log("[SHARE] screen PC state=$s");
        if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            s == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          if (isScreenSharing.value && !isClosed) {
            unawaited(stopScreenShare());
          }
        }
      };

      _screenSender = await pc.addTrack(screenTrack, stream);
      log("[SHARE] sender ready id=${_screenSender?.track?.id}");

      if (WebRTC.platformIsIOS) {
        log("[SHARE] sender tune skipped on iOS (broadcast owns the encoder)");
      } else {
        await _tuneScreenSender();
      }

      final RTCSessionDescription raw = await pc.createOffer({
        'offerToReceiveAudio': false,
        'offerToReceiveVideo': false,
      });
      await pc.setLocalDescription(raw);

      socket?.emit("screen_share_offer", {
        "callId": callId,
        "remoteUserId": _screenPeerUserId,
        "sdpOffer": raw.toMap(),
      });
      log("[SHARE] screen_share_offer sent to=$_screenPeerUserId");

      isScreenSharing.value = true;
      update();

      unawaited(_watchScreenSender());
    } catch (e, st) {
      log("[SHARE] start error: $e\n$st");
      isScreenShareWaiting.value = false;
      await _teardownScreenStream();
      isScreenSharing.value = false;
      Utils().fluttertoast(appL10n.call_unableToShareScreen);
    } finally {
      _screenShareStarting = false;
      update();
    }
  }

  Future<bool> _waitForIosCapture(MediaStream stream) async {
    final RTCVideoRenderer probe = RTCVideoRenderer();
    try {
      await probe.initialize();
      await probe.setSrcObject(stream: stream);
      log(
        "[SHARE] ios: system picker is up - waiting for 'Start Broadcast' "
        "(share does not start until a frame arrives)",
      );

      for (int i = 1; i <= 48; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (isClosed || !_screenShareStarting) {
          log("[SHARE] ios: capture wait cancelled at ${i * 500}ms");
          return false;
        }

        final int width = probe.value.width.toInt();
        if (width > 0) {
          log("[SHARE] ios: broadcast started at ${i * 500}ms w=$width");
          return true;
        }

        if (i % 10 == 0) {
          log(
            "[SHARE] ios: still waiting for Start Broadcast "
            "(${i * 500}ms of 24000ms)",
          );
        }
      }

      log("[SHARE] ios: Start Broadcast not tapped within 24s - giving up");
      return false;
    } catch (e) {
      log("[SHARE] ios: capture wait error: $e");
      return false;
    } finally {
      try {
        probe.srcObject = null;
        await probe.dispose();
      } catch (_) {}
    }
  }

  void cancelScreenShare() {
    if (!isScreenShareWaiting.value) return;
    log("[SHARE] waiting cancelled by the user");
    _screenShareStarting = false;
    isScreenShareWaiting.value = false;
    update();
  }

  Future<void> _watchScreenSender() async {
    bool live = false;
    int stuckTicks = 0;
    int baseline = 0;

    final RTCPeerConnection? firstPc = _screenPc;
    if (firstPc != null) {
      try {
        final List<StatsReport> reports = await firstPc.getStats();
        for (final StatsReport r in reports) {
          final Map<dynamic, dynamic> v = r.values;
          if (v['framesEncoded'] != null) {
            baseline = int.tryParse('${v['framesEncoded']}') ?? 0;
          }
        }
      } catch (_) {}
    }
    log("[SHARE] encoder baseline frames=$baseline");

    final bool isIos = defaultTargetPlatform == TargetPlatform.iOS;

    for (int i = 1;; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));

      final RTCPeerConnection? pc = _screenPc;
      if (!isScreenSharing.value || isClosed || pc == null) return;

      int outFrames = -1;
      int outW = 0;
      int outH = 0;
      int outBps = 0;
      try {
        final List<StatsReport> reports = await pc.getStats();
        for (final StatsReport r in reports) {
          final Map<dynamic, dynamic> v = r.values;
          if (v['framesEncoded'] == null) continue;
          outFrames = int.tryParse('${v['framesEncoded']}') ?? outFrames;
          outW = int.tryParse('${v['frameWidth'] ?? 0}') ?? 0;
          outH = int.tryParse('${v['frameHeight'] ?? 0}') ?? 0;
          outBps = int.tryParse('${v['mediaBitrateSent'] ?? 0}') ?? 0;
        }
      } catch (_) {}

      final int added = outFrames < 0 ? -1 : outFrames - baseline;

      String trackState = 'gone';
      final List<MediaStreamTrack> screenTracks =
          _screenStream?.getVideoTracks() ?? <MediaStreamTrack>[];
      if (screenTracks.isNotEmpty) {
        trackState = screenTracks.first.muted == true ? 'muted' : 'live';
      }

      final bool flowing = added > 0 && outW > 0;
      if (!live || i % 10 == 0 || flowing != live) {
        log(
          "[SHARE] frames t=${i}s encodeOut=${outW}x$outH "
          "newFrames=$added bps=$outBps track=$trackState",
        );
      }

      if (flowing) {
        stuckTicks = 0;
        if (!live) {
          live = true;
          log("[SHARE] screen frames confirmed flowing to peer");
        }
        if (!isScreenShareLive.value) {
          isScreenShareLive.value = true;
          update();
        }
        continue;
      }

      if (live) {
        stuckTicks++;
        log("[SHARE] frames stalled (tick=$stuckTicks of 5) t=${i}s");
        if (stuckTicks >= 5) {
          log(
            "[SHARE] frames stopped for 5s - broadcast ended or sender died, "
            "stopping the share",
          );
          await stopScreenShare();
          Utils().fluttertoast(appL10n.call_screenShareStopped);
          return;
        }
        continue;
      }

      if (isIos) {
        if (i == 5) {
          log(
            "[SHARE] no frames yet - tap Start Broadcast in the picker; "
            "the share stays open and starts the moment frames arrive",
          );
        }
        if (i == 20 || (i > 20 && i % 30 == 0)) {
          log(
            "[SHARE] still no capture at t=${i}s - Start Broadcast not "
            "tapped (share kept alive on purpose, no abort on iOS)",
          );
        }
        continue;
      }

      if (i == 8) {
        log("[SHARE] no encoded screen frames yet (t=8s)");
      }
    }
  }

  Future<void> stopScreenShare() async {
    if (!isScreenSharing.value && _screenPc == null && _screenStream == null) {
      return;
    }
    log("[SHARE] stop requested announced=$_screenShareAnnounced");

    try {
      if (_screenShareAnnounced) {
        socket?.emit("stop_screen_share", {
          "callId": callId,
          "remoteUserId": _screenPeerUserId,
        });
        log("[SHARE] stop_screen_share to=$_screenPeerUserId callId=$callId");
      }
    } catch (_) {}

    _screenShareAnnounced = false;

    await _teardownScreenStream();
    isScreenSharing.value = false;
    update();
  }

  Future<void> _teardownScreenStream() async {
    try {
      _screenShareAnnounced = false;
      _screenSender = null;
      _screenPendingLocalIce.clear();
      _screenPendingRemoteIce.clear();
      _screenRemoteDescSet = false;
      isScreenShareLive.value = false;
      isScreenShareWaiting.value = false;

      final MediaStream? stream = _screenStream;
      _screenStream = null;
      try {
        stream?.getTracks().forEach((t) => t.stop());
        await stream?.dispose();
      } catch (e) {
        log("[SHARE] screen stream dispose error: $e");
      }

      final RTCPeerConnection? pc = _screenPc;
      _screenPc = null;
      try {
        await pc?.close();
      } catch (e) {
        log("[SHARE] screen PC close error: $e");
      }

      await _stopScreenShareForeground();
      log("[SHARE] teardown done");
    } catch (e) {
      log("[SHARE] teardown error: $e");
    }
  }

  Future<bool> _prepareAndroidProjection() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    bool granted = false;
    try {
      granted = await Helper.requestCapturePermission();
      log("[SHARE] android capture permission granted=$granted");
    } catch (e) {
      log("[SHARE] android capture permission error: $e");
      Utils().fluttertoast(appL10n.call_screenShareStartFailed);
      return false;
    }

    if (!granted) {
      log("[SHARE] android capture permission denied by user");
      Utils().fluttertoast(appL10n.call_screenSharePermissionDenied);
      return false;
    }

    final bool serviceUp = await _startScreenShareForeground();
    if (!serviceUp) {
      log("[SHARE] android projection service failed - share aborted");
      Utils().fluttertoast(appL10n.call_screenShareStartFailed);
      _stopScreenShareForeground();
    }
    return serviceUp;
  }

  Future<bool> _startScreenShareForeground() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    try {
      if (!FlutterForegroundTask.isInitialized) {
        FlutterForegroundTask.init(
          androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'fgtracker_call_service',
            channelName: appL10n.call_ongoingChannelName,
            channelDescription: appL10n.call_ongoingChannelDescription,
          ),
          iosNotificationOptions: const IOSNotificationOptions(
            showNotification: false,
          ),
          foregroundTaskOptions: ForegroundTaskOptions(
            eventAction: ForegroundTaskEventAction.nothing(),
          ),
        );
        log("[SHARE] foreground task initialized");
      }

      // Screen share replaces the call's service with its own (it adds
      // mediaProjection); the call takes it back when sharing stops.
      CallForegroundService.yieldToScreenShare();
      for (int attempt = 1; attempt <= 2; attempt++) {
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
          log("[SHARE] old foreground service stopped to add mediaProjection");
        }

        final ServiceRequestResult result =
            await FlutterForegroundTask.startService(
          serviceId: 9911,
          serviceTypes: const <ForegroundServiceTypes>[
            ForegroundServiceTypes.microphone,
            ForegroundServiceTypes.mediaProjection,
          ],
          notificationTitle: appL10n.call_screenSharingTitle,
          notificationText: appL10n.call_youAreSharingScreen,
        );

        log("[SHARE] foreground service attempt=$attempt result=$result");

        if (await _awaitForegroundRunning()) {
          log("[SHARE] foreground service running with mediaProjection");
          return true;
        }
      }

      log("[SHARE] foreground service never reported running");
      return false;
    } catch (e) {
      log("[SHARE] foreground service start error: $e");
      return false;
    }
  }

  Future<bool> _awaitForegroundRunning() async {
    for (int i = 0; i < 10; i++) {
      if (await FlutterForegroundTask.isRunningService) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  Future<void> _stopScreenShareForeground() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
        log("[SHARE] screen share foreground service stopped");
      }
    } catch (e) {
      log("[SHARE] foreground service stop error: $e");
    }
    // The call continues: give it its own ongoing-call service back.
    if (isCallLive && !_isCleaningUp) {
      unawaited(_platform.startCallService(video: isVideoCall.value));
    }
  }

  Future<void> _tuneScreenSender() async {
    final RTCRtpSender? sender = _screenSender;
    if (sender == null) return;
    try {
      final RTCRtpParameters params = sender.parameters;
      params.degradationPreference =
          RTCDegradationPreference.MAINTAIN_RESOLUTION;
      final List<RTCRtpEncoding>? encodings = params.encodings;
      if (encodings != null && encodings.isNotEmpty) {
        for (final RTCRtpEncoding enc in encodings) {
          enc.active = true;
          enc.maxBitrate = 2500000;
          enc.maxFramerate = 15;
          enc.scaleResolutionDownBy = 1.0;
        }
      }
      await sender.setParameters(params);
      log("[SHARE] screen sender tuned bitrate=2.5M fps=15");
    } catch (e) {
      log("[SHARE] screen sender tune error: $e");
    }
  }

  @override
  void onClose() {
    // Normally every end path ran _finishCall before the delete. If this
    // controller is deleted while the call is still live (old code paths),
    // end it properly instead of leaving a zombie call (BUG-CALL-21).
    final bool wasLive = !_callFinished;
    _callFinished = true;
    _isCleaningUp = true;

    WidgetsBinding.instance.removeObserver(this);

    _peerDisconnectTimer?.cancel();
    _controlsTimer?.cancel();
    _clearTimers();

    if (wasLive) {
      log("[Call] onClose with a live call: ending it");
      stopSound();
      _emitEndCallRealtime();
      InAppCallOverlayService.instance.hideOverlay();
      unawaited(_disposePeerResources());
      unawaited(_platform.stopCallService());
      unawaited(audioRouteController.stopCall());
      final String sid = _sessionId;
      if (sid.isNotEmpty) {
        unawaited(_platform.dismissCallKit(sid).catchError((_) {}));
        unawaited(
          _platform.callEndedCleanup(sid, type: "onClose").catchError((_) {}),
        );
      }
      CallSessionState.reset();
      unawaited(_platform.setWakelock(false).catchError((_) {}));
      unawaited(_platform.setProximity(false).catchError((_) {}));
    }

    if (CallForegroundService.onHangUp != null && wasLive) {
      CallForegroundService.onHangUp = null;
    }

    // Only this call's handlers; global ones stay (BUG-CALL-03).
    _handlers.offAll();

    if (_platform.mediaEnabled) {
      navigator.mediaDevices.ondevicechange = null;
      if (!_screenRendererReleased) {
        _screenRendererReleased = true;
        _clearScreenRenderer();
        _disposeScreenRenderer();
      }
      // One controller per call now, so the renderers must go with it.
      unawaited(localRenderer.dispose().catchError((_) {}));
      unawaited(remoteRenderer.dispose().catchError((_) {}));
    }

    if (Get.isRegistered<CallAudioRouteController>()) {
      Get.delete<CallAudioRouteController>(force: true);
    }

    super.onClose();
  }
}

/// Thrown when the signaling socket cannot be reached before a call starts.
class CallSignalingUnavailable implements Exception {
  const CallSignalingUnavailable();
  @override
  String toString() => 'CallSignalingUnavailable';
}
