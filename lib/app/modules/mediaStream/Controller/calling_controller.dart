import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart:.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../gen/assets.gen.dart';
import 'package:fgtracker/app/Model/callDetailRes.dart';
import '../../../Data/Services/IncommingCallKit/call_session.dart'
    show CallSessionState;
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../Widget/audio_route_sheet.dart';

class CallingController extends GetxController with WidgetsBindingObserver {
  final socket = SignallingService.instance.socket;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? peer;
  MediaStream? localStream;
  MediaStream? _remoteMediaStream;
  MediaStreamTrack? _remoteVideoTrack;
  RTCRtpSender? _localVideoSender;

  List<RTCIceCandidate> iceCandidates = [];
  RxString callStatus = "Calling".obs;
  bool isAudioOn = true;
  bool isVideoOn = false;
  bool isRemoteVideoOn = false;
  bool isFrontCamera = true;
  bool _isSwitchingCamera = false;
  dynamic callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
  bool isSpeakerOn = false;
  bool fromCallKit = false;
  bool _isCleaningUp = false;
  bool _hasExitedScreen = false;
  bool _remoteEndSent = false;
  bool _callKitConnectedSent = false;
  bool _initialAudioRouteApplied = false;

  Timer? _peerDisconnectTimer;
  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;
  final RxInt callDurationRx = 0.obs;
  Offset? pipPosition;
  final Rxn<CallDetail> apiCallDetail = Rxn<CallDetail>();

  Timer? missedCallTimer;
  var missCallDurationSeconds = 40.obs;

  final RxBool isVideoCall = false.obs;
  final RxBool isUpgradingToVideo = false.obs;

  bool isLocalVideoMain = false;

  final RxBool areControlsVisible = true.obs;
  Timer? _controlsTimer;

  late final CallAudioRouteController audioRouteController;
  late final String _audioRouteTag;

  final List<dynamic> _pendingRemoteCandidates = [];
  bool _remoteDescriptionSet = false;

  Timer? _remoteVideoWatchdog;

  Map<String, dynamic> _videoCaptureConstraints() => {
    'facingMode': isFrontCamera ? 'user' : 'environment',
    'width': {'ideal': 1280, 'max': 1280},
    'height': {'ideal': 720, 'max': 720},
    'frameRate': {'min': 24, 'ideal': 30, 'max': 30},
  };

  bool _sdpHasSendingVideo(String? sdp) {
    if (sdp == null || sdp.isEmpty || !sdp.contains('m=video')) return false;

    final String lineSep = sdp.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = sdp.split(lineSep);

    int i = 0;
    while (i < lines.length) {
      if (!lines[i].startsWith('m=video ')) {
        i++;
        continue;
      }

      final List<String> mParts = lines[i].trim().split(RegExp(r'\s+'));
      final int port = mParts.length > 1 ? (int.tryParse(mParts[1]) ?? 0) : 0;

      int sectionEnd = i + 1;
      while (sectionEnd < lines.length && !lines[sectionEnd].startsWith('m=')) {
        sectionEnd++;
      }

      if (port > 0) {
        String direction = 'sendrecv';
        for (int k = i + 1; k < sectionEnd; k++) {
          final String trimmed = lines[k].trim();
          if (trimmed == 'a=sendrecv' ||
              trimmed == 'a=sendonly' ||
              trimmed == 'a=recvonly' ||
              trimmed == 'a=inactive') {
            direction = trimmed.substring(2);
            break;
          }
        }
        if (direction == 'sendrecv' || direction == 'sendonly') {
          return true;
        }
      }

      i = sectionEnd;
    }

    return false;
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
            final RegExpMatch? aptMatch =
            RegExp(r'(?:^|;\s*)apt=(\d+)').firstMatch(params);
            if (aptMatch != null) {
              rtxByApt[aptMatch.group(1)!] = pt;
            }
          }
        }
      }

      for (int k = mLineIdx + 1; k < sectionEnd; k++) {
        final String line = lines[k];
        if (line.startsWith('a=rtpmap:')) {
          final RegExpMatch? m =
          RegExp(r'^a=rtpmap:(\d+)\s+H264/90000', caseSensitive: false)
              .firstMatch(line);
          if (m != null) {
            final String pt = m.group(1)!;
            final String fmtp = fmtpByPt[pt] ?? '';
            if (fmtp.contains('42e0') || fmtp.contains('4200')) {
              h264BaselinePts.add(pt);
            } else {
              h264OtherPts.add(pt);
            }
          }
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

  RTCSessionDescription _withPreferredVideoCodec(RTCSessionDescription desc) {
    final String? rawSdp = desc.sdp;
    if (rawSdp == null || rawSdp.isEmpty) return desc;
    return RTCSessionDescription(_preferH264InSdp(rawSdp), desc.type);
  }

  Future<void> _tuneVideoSenders(RTCPeerConnection pc) async {
    try {
      final List<RTCRtpSender> senders = await pc.getSenders();
      for (final RTCRtpSender sender in senders) {
        if (sender.track?.kind != 'video') continue;

        final RTCRtpParameters params = sender.parameters;
        params.degradationPreference =
            RTCDegradationPreference.MAINTAIN_FRAMERATE;

        final List<RTCRtpEncoding>? encodings = params.encodings;
        if (encodings != null && encodings.isNotEmpty) {
          for (final RTCRtpEncoding enc in encodings) {
            enc.active = true;
            enc.maxBitrate = 1800000;
            enc.maxFramerate = 30;
          }
        }
        await sender.setParameters(params);
      }
    } catch (e) {
      log("[Call] Video sender tuning skipped: $e");
    }
  }

  Future<RTCRtpTransceiver?> _getVideoTransceiver(RTCPeerConnection pc) async {
    final List<RTCRtpTransceiver> transceivers = await pc.getTransceivers();
    for (final RTCRtpTransceiver tr in transceivers) {
      if (tr.receiver.track?.kind == 'video' ||
          tr.sender.track?.kind == 'video') {
        return tr;
      }
    }
    return null;
  }

  Future<void> _ensureRemoteVideoBound({bool forceRebind = false}) async {
    if (isClosed || peer == null) return;
    if (!isRemoteVideoOn) {
      remoteRenderer.srcObject = null;
      return;
    }

    final MediaStream? stream = _remoteMediaStream ?? remoteRenderer.srcObject;
    if (stream == null) return;

    if (_remoteVideoTrack != null) {
      _remoteVideoTrack!.enabled = true;
    }

    final String? trackId =
        _remoteVideoTrack?.id ?? stream.getVideoTracks().lastOrNull?.id;

    if (forceRebind) {
      remoteRenderer.srcObject = null;
    }

    if (trackId != null) {
      await remoteRenderer.setSrcObject(
        stream: stream,
        trackId: trackId,
      );
    } else {
      remoteRenderer.srcObject = stream;
    }
  }

  Future<void> _syncVideoState() async {
    if (!isVideoOn) {
      localRenderer.srcObject = null;
    }
    if (!isRemoteVideoOn) {
      remoteRenderer.srcObject = null;
    }

    final bool anyVideoActive = isVideoOn || isRemoteVideoOn;
    is_video = anyVideoActive;
    isVideoCall.value = anyVideoActive;

    if (!anyVideoActive) {
      isLocalVideoMain = false;
      await audioRouteController.updateCallType(isVideo: false);
    } else if (isVideoOn && !isRemoteVideoOn) {
      isLocalVideoMain = true;
    } else if (!isVideoOn && isRemoteVideoOn) {
      isLocalVideoMain = false;
    }

    if (isRemoteVideoOn) {
      await _ensureRemoteVideoBound(forceRebind: true);
    }

    update();
  }

  Future<void> _setLocalVideoTransceiverDirection(
      RTCPeerConnection pc,
      TransceiverDirection direction, {
        MediaStreamTrack? senderTrack,
        bool updateSenderTrack = false,
      }) async {
    try {
      final RTCRtpTransceiver? tr = await _getVideoTransceiver(pc);
      if (tr != null) {
        if (updateSenderTrack) {
          await tr.sender.replaceTrack(senderTrack);
          _localVideoSender = tr.sender;
        }
        await tr.setDirection(direction);
      }
    } catch (e) {
      log("[Call] _setLocalVideoTransceiverDirection error: $e");
    }
  }

  Future<void> _ensureLocalVideoTrackAttached(RTCPeerConnection pc) async {
    if (localStream == null) return;

    final existingTracks = localStream!.getVideoTracks();
    MediaStreamTrack? videoTrack =
    existingTracks.isNotEmpty ? existingTracks.first : null;

    if (videoTrack == null) {
      final MediaStream videoStream =
      await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': _videoCaptureConstraints(),
      });
      videoTrack = videoStream.getVideoTracks().firstOrNull;
      if (videoTrack == null) {
        throw Exception("No video track available");
      }
      await localStream!.addTrack(videoTrack);
    } else {
      for (final t in existingTracks) {
        t.enabled = true;
      }
    }

    await localRenderer.setSrcObject(
      stream: localStream,
      trackId: videoTrack.id,
    );

    final RTCRtpTransceiver? existingVideoTr = await _getVideoTransceiver(pc);
    if (existingVideoTr != null) {
      await existingVideoTr.sender.replaceTrack(videoTrack);
      _localVideoSender = existingVideoTr.sender;
      await existingVideoTr.setDirection(TransceiverDirection.SendRecv);
    } else {
      _localVideoSender = await pc.addTrack(videoTrack, localStream!);
      await _setLocalVideoTransceiverDirection(
        pc,
        TransceiverDirection.SendRecv,
      );
    }

    await _tuneVideoSenders(pc);
  }

  Future<void> _sendVideoRenegotiationOffer() async {
    if (peer == null) return;

    final rawOffer = await peer!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    });
    final preferredOffer = _withPreferredVideoCodec(rawOffer);
    await peer!.setLocalDescription(preferredOffer);

    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final targetUserId =
    (myUserId == callerId.toString()) ? remoteUserId : callerId;

    socket?.emit("upgradeToVideo", {
      "callId": callId,
      "remoteUserId": targetUserId,
      "sdpOffer": preferredOffer.toMap(),
      "callerId": myUserId,
    });
  }

  void _emitEndCallRealtime({Map<String, dynamic>? customPayload}) {
    if (_remoteEndSent) return;
    _remoteEndSent = true;

    final String myUserId =
    Global.storageServices.get(PrefConst.userId).toString();
    final String targetUser =
    myUserId == callerId.toString() ? remoteUserId : callerId;

    final Map<String, dynamic> payload = customPayload ??
        <String, dynamic>{
          "callId": callId,
          "to": targetUser,
          "remoteUserId": targetUser,
          "callerId": callerId,
          "receiverId": remoteUserId,
          "sessionId": _sessionId,
        };

    final dynamic s = socket;
    if (s == null) return;

    try {
      if (s.connected == true) {
        s.emit("endCall", payload);
      } else {
        s.emit("endCall", payload);
        s.once("connect", (_) {
          try {
            s.emit("endCall", payload);
          } catch (_) {}
        });
        s.connect();
      }
    } catch (e) {
      log("[Call] _emitEndCallRealtime error: $e");
    }
  }

  void _exitCallScreen() {
    if (_hasExitedScreen) return;
    _hasExitedScreen = true;

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
            (fromCallKit && !nav.canPop() && topRouteName != Routes.Home_Screen);

        if (!landedOnSplash) {
          return;
        }
      }
    }

    Get.offAllNamed(Routes.Home_Screen);
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
    _controlsTimer = Timer(
      const Duration(seconds: 5),
          () {
        if (!isClosed) {
          areControlsVisible.value = false;
        }
      },
    );
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

    _audioRouteTag =
    "call_audio_${callId ?? DateTime.now().microsecondsSinceEpoch}";

    audioRouteController = Get.put(
      CallAudioRouteController(),
      tag: _audioRouteTag,
    );

    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    WakelockPlus.enable();

    try {
      GroupTrackingController.instance.initializeLocation();
    } catch (e) {
      log("[Call] Location initialization error: $e");
    }

    unawaited(_initializeCall());
  }

  Future<void> _initializeCall() async {
    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      await _setupPeer();
    } catch (e, stackTrace) {
      log("[Call] Initialization error: $e", stackTrace: stackTrace);
      await _cleanupCall(notifyRemote: true, navigateBack: true);
    }
  }

  Future<void> _cleanupCall({
    required bool notifyRemote,
    required bool navigateBack,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    final String sessionId = _sessionId;

    try {
      _clearTimers();
      _controlsTimer?.cancel();
      _peerDisconnectTimer?.cancel();

      stopSound();

      if (notifyRemote) {
        _emitEndCallRealtime();
      }

      CallSessionState.reset();

      if (navigateBack) {
        _exitCallScreen();
      }

      await _disposePeerResources();
      await audioRouteController.stopCall();
      await _stopForegroundCallService();

      if (sessionId.isNotEmpty) {
        await CallKitService.dismiss(sessionId);
        try {
          await callEnded(sessionId, type: "CallCleanedUp");
        } catch (e) {
          log("[Call] Call cleanup error: $e");
        }
      }

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } catch (e, stackTrace) {
      log("[Call] General cleanup error: $e", stackTrace: stackTrace);
    } finally {
      _isCleaningUp = false;
    }
  }

  String get _sessionId {
    if (CallSessionState.sessionId != null &&
        CallSessionState.sessionId!.isNotEmpty) {
      return CallSessionState.sessionId!;
    }
    return callId != null ? callId.toString() : "";
  }

  Future<void> _stopForegroundCallService() async {
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      log("Error stopping call foreground task: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("CallingController: AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.resumed) {
      _ensureAudioTracksActive();
    } else if (state == AppLifecycleState.paused) {
      _keepTracksAliveInBackground();
    }
  }

  void _ensureAudioTracksActive() {
    try {
      if (localStream != null) {
        for (final track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        if (isVideoCall.value && isVideoOn) {
          for (final track in localStream!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      final MediaStream? remoteStream =
          _remoteMediaStream ?? remoteRenderer.srcObject;
      if (remoteStream != null) {
        for (final track in remoteStream.getAudioTracks()) {
          track.enabled = true;
        }
        if (isVideoCall.value && isRemoteVideoOn) {
          for (final track in remoteStream.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      if (isVideoCall.value && isRemoteVideoOn) {
        unawaited(_ensureRemoteVideoBound(forceRebind: true));
        _scheduleRemoteVideoCheck();
      }

      unawaited(audioRouteController.restoreCurrentRoute());
    } catch (e) {
      log("Error restoring active WebRTC audio states: $e");
    }
  }

  void _keepTracksAliveInBackground() {
    try {
      if (localStream != null) {
        for (var track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        if (isVideoCall.value) {
          for (var track in localStream!.getVideoTracks()) {
            track.enabled = false;
          }
        }
      }
    } catch (e) {
      log("Error keeping background WebRTC audio alive: $e");
    }
  }

  Future<void> _rebindRemoteRenderer([MediaStream? stream]) async {
    final MediaStream? s =
        stream ?? _remoteMediaStream ?? remoteRenderer.srcObject;
    if (s == null || !isRemoteVideoOn) return;

    final String? videoTrackId =
        _remoteVideoTrack?.id ?? s.getVideoTracks().lastOrNull?.id;
    remoteRenderer.srcObject = null;
    await Future<void>.delayed(const Duration(milliseconds: 30));

    if (isClosed || peer == null || !isRemoteVideoOn) return;

    if (videoTrackId != null) {
      await remoteRenderer.setSrcObject(stream: s, trackId: videoTrackId);
    } else {
      remoteRenderer.srcObject = s;
    }
    update();
  }

  void _scheduleRemoteVideoCheck() {
    _remoteVideoWatchdog?.cancel();

    _remoteVideoWatchdog = Timer(const Duration(milliseconds: 2500), () {
      if (isClosed || peer == null || !isVideoCall.value || !isRemoteVideoOn) {
        return;
      }

      final tracks = remoteRenderer.srcObject?.getVideoTracks() ?? [];
      if (tracks.isEmpty) return;

      int width = 0;
      try {
        width = remoteRenderer.videoWidth;
      } catch (_) {}

      if (width > 0) return;

      log("[Call] Remote video width still 0 after 2.5s, rebinding once");
      unawaited(_rebindRemoteRenderer());
    });
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    try {
      final MediaStream? stream =
      event.streams.isNotEmpty ? event.streams.first : null;

      if (peer == null) return;

      final bool isVideoTrack = event.track.kind == 'video';
      event.track.enabled = true;

      if (isVideoTrack) {
        if (stream != null) {
          _remoteMediaStream = stream;
        }
        _remoteVideoTrack = event.track;
        isRemoteVideoOn = true;
        isLocalVideoMain = false;
        is_video = true;
        isVideoCall.value = true;
        final MediaStream? targetStream = stream ?? _remoteMediaStream;
        if (targetStream != null) {
          remoteRenderer.srcObject = null;
          await remoteRenderer.setSrcObject(
            stream: targetStream,
            trackId: event.track.id,
          );
        }
      } else if (stream != null) {
        _remoteMediaStream ??= stream;
      }

      stopSound();
      missedCallTimer?.cancel();
      missedCallTimer = null;

      startCallTimer();
      callStatus.value = "Connected";
      update();

      if (!_initialAudioRouteApplied) {
        _initialAudioRouteApplied = true;
        unawaited(audioRouteController.restoreCurrentRoute());
      }

      if (!_callKitConnectedSent &&
          (fromCallKit || args["callType"] == "Incoming")) {
        _callKitConnectedSent = true;
        unawaited(CallKitService.setConnected(_sessionId));
      }

      if (isVideoTrack) {
        _scheduleRemoteVideoCheck();
      }
    } catch (e, stackTrace) {
      log("[Call] onTrack error: $e", stackTrace: stackTrace);
    }
  }

  Future<void> upgradeToVideoCall() async {
    if (isUpgradingToVideo.value) return;
    if (peer == null || localStream == null) {
      Utils().fluttertoast("Call not ready");
      return;
    }

    try {
      isUpgradingToVideo.value = true;
      if (!isVideoCall.value) {
        pipPosition = null;
        await audioRouteController.updateCallType(isVideo: true);
      }

      await _ensureLocalVideoTrackAttached(peer!);

      isVideoOn = true;
      isLocalVideoMain = !isRemoteVideoOn;

      await _sendVideoRenegotiationOffer();
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
    socket?.off("upgradeToVideo");
    socket?.off("upgradeToVideoAnswer");
    socket?.off("requestVideoUpgrade");

    socket?.on("upgradeToVideo", (data) async {
      try {
        if (peer == null) return;
        final sdp = data["sdpOffer"];
        if (sdp == null) return;

        final String rawRemoteSdp = sdp["sdp"]?.toString() ?? "";
        final bool remoteSendingVideo = _sdpHasSendingVideo(rawRemoteSdp);
        final bool wasRemoteVideoOn = isRemoteVideoOn;

        if (!isVideoCall.value && (remoteSendingVideo || isVideoOn)) {
          await audioRouteController.updateCallType(isVideo: true);
        }

        await peer!.setRemoteDescription(
          _withPreferredVideoCodec(
            RTCSessionDescription(rawRemoteSdp, sdp["type"]),
          ),
        );

        isRemoteVideoOn = remoteSendingVideo;
        if (!wasRemoteVideoOn && isRemoteVideoOn) {
          isLocalVideoMain = false;
        }

        final rawAnswer = await peer!.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true,
        });
        final preferredAnswer = _withPreferredVideoCodec(rawAnswer);
        await peer!.setLocalDescription(preferredAnswer);

        if (isVideoOn) {
          await _tuneVideoSenders(peer!);
        }

        socket?.emit("upgradeToVideoAnswer", {
          "callId": callId,
          "remoteUserId": data["callerId"],
          "sdpAnswer": preferredAnswer.toMap(),
        });

        callStatus.value = "Connected";
        await _syncVideoState();

        if (isRemoteVideoOn) {
          _scheduleRemoteVideoCheck();
        }
      } catch (e) {
        log("upgradeToVideo handler error: $e");
      }
    });

    socket?.on("upgradeToVideoAnswer", (data) async {
      try {
        if (peer == null) return;
        final sdp = data["sdpAnswer"];
        if (sdp == null) return;

        final String rawRemoteSdp = sdp["sdp"]?.toString() ?? "";
        final bool remoteSendingVideo = _sdpHasSendingVideo(rawRemoteSdp);
        final bool wasRemoteVideoOn = isRemoteVideoOn;

        await peer!.setRemoteDescription(
          _withPreferredVideoCodec(
            RTCSessionDescription(rawRemoteSdp, sdp["type"]),
          ),
        );

        isRemoteVideoOn = remoteSendingVideo;
        if (!wasRemoteVideoOn && isRemoteVideoOn) {
          isLocalVideoMain = false;
        }
        if (isVideoOn) {
          await _tuneVideoSenders(peer!);
        }

        callStatus.value = "Connected";
        await _syncVideoState();

        if (isRemoteVideoOn) {
          _scheduleRemoteVideoCheck();
        }
      } catch (e) {
        log("upgradeToVideoAnswer error: $e");
      }
    });
  }

  void _onNewCall(dynamic data) {
    socket?.emit("CallingStatus", {
      "callId": data['callId'].toString(),
      "remoteUserId": int.tryParse(data['callerId'].toString()) ?? 0,
      "callingStatus": "Ringing",
    });
  }

  Future<void> _onCallEnded(dynamic data) async {
    log("[Socket] callEnded RECEIVED: $data");
    Utils().fluttertoast('Call Ended By ${args["callerName"] ?? "Unknown"}');
    await _cleanupCall(notifyRemote: false, navigateBack: true);
  }

  Future<void> _onMissedCall(dynamic data) async {
    log("[Socket] missedCall RECEIVED: $data");

    if (_isCleaningUp) return;

    if (callTimer != null || callDurationSeconds > 0) {
      log("[Socket] missedCall ignored: call already connected");
      return;
    }

    _isCleaningUp = true;
    try {
      _clearTimers();
      stopSound();

      final String sessionId = data["sessionId"]?.toString().isNotEmpty == true
          ? data["sessionId"].toString()
          : _sessionId;

      CallSessionState.reset();
      _exitCallScreen();

      await resetPeer();
      await audioRouteController.stopCall();

      if (sessionId.isNotEmpty) {
        await CallKitService.dismiss(sessionId);
        await callEnded(sessionId, type: "missedCallFromSocket");
      }

      await _stopForegroundCallService();
      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } finally {
      _isCleaningUp = false;
    }
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
    socket?.off("callRejected");
    socket?.off("callEnded", _onCallEnded);
    socket?.off("endCall", _onCallEnded);
    socket?.off("missedCall", _onMissedCall);
    socket?.off("callStatus");
    socket?.off("callCreated");
    socket?.off("newCall", _onNewCall);
    socket?.off("sdpOfferFromCaller");
    socket?.off("callError");
    socket?.off("callBlocked");

    socket?.on("callCreated", _onCallCreated);

    socket?.on("callError", (data) async {
      log("CALL ERROR => $data");
      await _cleanupCall(notifyRemote: false, navigateBack: true);
      Get.snackbar(
        "Call Failed",
        data?["message"]?.toString() ?? "Unable to make call",
      );
    });

    socket?.on("callBlocked", (data) async {
      log("CALL BLOCKED => $data");
      await _cleanupCall(notifyRemote: false, navigateBack: true);
      Get.snackbar(
        "Call unavailable",
        data?["message"]?.toString() ??
            "Communication is not available with this user",
      );
    });

    socket?.on("sdpOfferFromCaller", (data) async {
      log("====== Received SDP Offer from Caller (CallKit flow) ======");
      if (peer == null) return;

      try {
        final sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;
        offer = sdp;
        callId = data["callId"] ?? callId;

        peer!.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": callerId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate
            },
          });
        };

        await peer!.setRemoteDescription(
          _withPreferredVideoCodec(
            RTCSessionDescription(sdp["sdp"], sdp["type"]),
          ),
        );
        await _markRemoteDescriptionSet();

        final rawAnswer = await peer!.createAnswer();
        final preferredAnswer = _withPreferredVideoCodec(rawAnswer);
        await peer!.setLocalDescription(preferredAnswer);

        socket!.emit("answerCall", {
          "callId": callId,
          "callerId": callerId,
          "sdpAnswer": preferredAnswer.toMap(),
        });
        if (callTimer == null && callDurationSeconds == 0) {
          callStatus.value = "Connecting";
        }
      } catch (e) {
        log("Error handling sdpOfferFromCaller: $e");
      }
    });

    socket?.on("newCall", _onNewCall);
    socket?.on("callEnded", _onCallEnded);
    socket?.on("endCall", _onCallEnded);
    socket?.on("missedCall", _onMissedCall);

    socket?.on("callRejected", (data) async {
      log("[Socket] callRejected RECEIVED: $data");

      if (callTimer != null || callDurationSeconds > 0) {
        log("[Socket] callRejected ignored: call already connected");
        return;
      }

      Utils().fluttertoast(
          'Call Rejected By ${args["callerName"] ?? "Unknown"}',
          bgColor: Colors.red);
      await _cleanupCall(notifyRemote: false, navigateBack: true);
    });

    socket?.on("callStatus", (data) {
      log("========CallingStatusData:$data");
      final status = (data["status"] ?? data["callingStatus"])?.toString();
      if (status != null && status.isNotEmpty) {
        if (data['callId'] != null) {
          callId = data['callId'];
        }

        final String normalized = status.trim().toLowerCase();
        if (normalized == "rejected" || normalized == "declined") {
          if (callTimer == null && callDurationSeconds == 0) {
            Utils().fluttertoast(
              'Call Rejected By ${args["callerName"] ?? "Unknown"}',
              bgColor: Colors.red,
            );
            unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
            return;
          }
        } else if (normalized == "ended" ||
            normalized == "callended" ||
            normalized == "disconnected" ||
            normalized == "cancelled" ||
            normalized == "canceled") {
          unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
          return;
        }

        if (callTimer == null && callDurationSeconds == 0) {
          callStatus.value = status;
        }
      }
    });

    _listenVideoUpgradeEvents();
  }

  Future<void> resetPeer() async {
    await _disposePeerResources();
  }

  Future<void> _disposePeerResources({
    bool stopDeviceMonitoring = true,
  }) async {
    try {
      _peerDisconnectTimer?.cancel();
      _peerDisconnectTimer = null;
      _remoteVideoWatchdog?.cancel();
      _remoteVideoWatchdog = null;

      if (stopDeviceMonitoring) {
        navigator.mediaDevices.ondevicechange = null;
      }

      final RTCPeerConnection? pc = peer;
      peer = null;
      _localVideoSender = null;
      _remoteMediaStream = null;
      _remoteVideoTrack = null;
      _remoteDescriptionSet = false;
      _initialAudioRouteApplied = false;
      isRemoteVideoOn = false;
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

      remoteRenderer.srcObject = null;
      localRenderer.srcObject = null;

      await pc?.close();

      socket?.off("IceCandidate");
      socket?.off("callAnswered");
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

      final c = RTCIceCandidate(
        ice["candidate"],
        ice["id"],
        ice["label"],
      );

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

    log("[Call] Flushing ${pending.length} queued remote ICE candidates");
    for (final d in pending) {
      safeAddCandidate(d);
    }
  }

  void _startPeerDisconnectTimer() {
    _peerDisconnectTimer?.cancel();
    _peerDisconnectTimer = Timer(const Duration(seconds: 3), () {
      final RTCIceConnectionState? ice = peer?.iceConnectionState;
      final RTCPeerConnectionState? conn = peer?.connectionState;

      final bool recovered =
          ice == RTCIceConnectionState.RTCIceConnectionStateConnected ||
              ice == RTCIceConnectionState.RTCIceConnectionStateCompleted ||
              conn == RTCPeerConnectionState.RTCPeerConnectionStateConnected;

      if (recovered) {
        log("[Call] Connection recovered, keeping the call");
        return;
      }

      log("[Call] Connection did not recover in 3s, ending call");
      _handlePeerDisconnected();
    });
  }

  void _cancelPeerDisconnectTimer() {
    _peerDisconnectTimer?.cancel();
    _peerDisconnectTimer = null;
  }

  Future<void> _setupPeer() async {
    await resetPeer();

    if (socket == null) {
      throw Exception("Socket is not initialized");
    }

    socket!.off("IceCandidate");
    socket!.off("callAnswered");

    socket!.on("IceCandidate", (data) {
      safeAddCandidate(data);
    });

    final RTCPeerConnection pc = await createPeerConnection({
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302']
        },
        {
          'urls': Urls.rtcUrl,
          'username': Urls.rtcUserName,
          'credential': Urls.rtcCredential
        }
      ],
      'iceTransportPolicy': 'all',
    });
    peer = pc;

    pc.onIceConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] ICE state: $state");

      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _cancelPeerDisconnectTimer();
        missedCallTimer?.cancel();
        missedCallTimer = null;
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        _startPeerDisconnectTimer();
        return;
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        _handlePeerDisconnected();
      }
    };

    pc.onConnectionState = (state) {
      if (!identical(peer, pc)) return;
      log("[Call] Peer connection state: $state");

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _cancelPeerDisconnectTimer();
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _handlePeerDisconnected();
        return;
      }

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _startPeerDisconnectTimer();
      }
    };

    pc.onTrack = (event) {
      if (!identical(peer, pc)) return;
      unawaited(_handleRemoteTrack(event));
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': is_video == true ? _videoCaptureConstraints() : false,
    });

    for (var t in localStream!.getTracks()) {
      final sender = await pc.addTrack(t, localStream!);
      if (t.kind == 'video') {
        _localVideoSender = sender;
      }
    }
    if (is_video == true) {
      await _tuneVideoSenders(pc);
      final vidTrack = localStream!.getVideoTracks().firstOrNull;
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

    unawaited(
      audioRouteController
          .startCall(
        isVideo: is_video,
      )
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
            "candidate": c.candidate
          },
        });
      };

      await pc.setRemoteDescription(
        _withPreferredVideoCodec(
          RTCSessionDescription(offer["sdp"], offer["type"]),
        ),
      );
      await _markRemoteDescriptionSet();

      final rawAnswer = await pc.createAnswer();
      final preferredAnswer = _withPreferredVideoCodec(rawAnswer);
      await pc.setLocalDescription(preferredAnswer);

      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": preferredAnswer.toMap(),
      });
    } else if (fromCallKit ||
        (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";
      final acceptPayload = {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      };
      socket!.emit("acceptCallFromCallKit", acceptPayload);
    } else {
      pc.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        if (!identical(peer, pc) || _remoteDescriptionSet) return;

        stopSound();
        missedCallTimer?.cancel();
        missedCallTimer = null;

        try {
          await pc.setRemoteDescription(
            _withPreferredVideoCodec(
              RTCSessionDescription(
                data["sdpAnswer"]["sdp"],
                data["sdpAnswer"]["type"],
              ),
            ),
          );
          await _markRemoteDescriptionSet();
          if (isVideoCall.value && isVideoOn) {
            await _tuneVideoSenders(pc);
          }
        } catch (e) {
          log("[Call] callAnswered handler error: $e");
          return;
        }

        for (var c in iceCandidates) {
          if (c.candidate == null) continue;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate
            },
          });
        }
        iceCandidates.clear();

        pc.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate
            },
          });
        };
      });

      final rawOffer = await pc.createOffer();
      final sdpOffer = _withPreferredVideoCodec(rawOffer);
      await pc.setLocalDescription(sdpOffer);

      socket!.emit("makeCall", {
        "remoteUserId": remoteUserId,
        "sdpOffer": sdpOffer.toMap(),
        "is_video": is_video,
        "callerId": Global.storageServices.get(PrefConst.userId),
      });

      startMissedCallTimer();
    }
  }

  Future<void> endCall({
    String? type,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    final String sid = _sessionId;

    try {
      _clearTimers();
      stopSound();

      _emitEndCallRealtime();

      CallSessionState.reset();
      _exitCallScreen();

      await resetPeer();
      await audioRouteController.stopCall();
      await _stopForegroundCallService();

      if (sid.isNotEmpty) {
        await CallKitService.dismiss(sid);
        await callEnded(
          sid,
          type: "endCallMethodHittedFromController-Type:$type",
        );
      }

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);
    } finally {
      _isCleaningUp = false;
    }
  }

  void _handlePeerDisconnected() {
    if (_isCleaningUp || isClosed) return;
    log("[Call] Remote peer disconnected");
    unawaited(_cleanupCall(notifyRemote: false, navigateBack: true));
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  Future<void> toggleCamera() async {
    if (peer == null) return;

    final vids = localStream?.getVideoTracks() ?? [];
    if (vids.isEmpty) {
      await upgradeToVideoCall();
      return;
    }

    isVideoOn = !isVideoOn;
    for (final t in vids) {
      t.enabled = isVideoOn;
    }

    if (isVideoOn && localStream != null) {
      await localRenderer.setSrcObject(
        stream: localStream,
        trackId: vids.first.id,
      );
      if (!isRemoteVideoOn) {
        isLocalVideoMain = true;
      }
    } else {
      localRenderer.srcObject = null;
      if (isRemoteVideoOn) {
        isLocalVideoMain = false;
      }
    }
    update();

    try {
      await _setLocalVideoTransceiverDirection(
        peer!,
        isVideoOn
            ? TransceiverDirection.SendRecv
            : TransceiverDirection.RecvOnly,
        senderTrack: isVideoOn ? vids.first : null,
        updateSenderTrack: true,
      );
      if (isVideoOn) {
        await _tuneVideoSenders(peer!);
      }
      await _sendVideoRenegotiationOffer();
      await _syncVideoState();
    } catch (e) {
      log("[Call] toggleCamera renegotiation error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_isSwitchingCamera || !isVideoCall.value || !isVideoOn) return;
    final tracks = localStream?.getVideoTracks() ?? [];
    if (tracks.isEmpty) return;

    _isSwitchingCamera = true;
    showControlsTemporarily();
    try {
      for (final t in tracks) {
        await Helper.switchCamera(t);
      }
      isFrontCamera = !isFrontCamera;
      update();
    } catch (e) {
      log("[Call] switchCamera error: $e");
    } finally {
      _isSwitchingCamera = false;
    }
  }

  Future<void> toggleSpeaker(BuildContext context) async {
    showAudioRoutePicker(context);
  }

  Future<void> showAudioRoutePicker(BuildContext context) async {
    if (!context.mounted) return;

    await audioRouteController.checkDevices();
    if (!context.mounted) return;

    final CallAudioRoute? selected =
    await showAudioRouteSheet(context, audioRouteController);

    if (selected != null) {
      await audioRouteController.selectRoute(selected);
    }
  }

  String get formattedDuration {
    final int secs = callDurationRx.value;
    final minutes = (secs ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    if (Utility.isNotNullEmptyOrFalse("$minutes:$seconds")) {
      if (args["callType"] == "outGoing") {
        stopSound();
      }
    }
    return "$minutes:$seconds";
  }

  void startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDurationSeconds++;
      callDurationRx.value = callDurationSeconds;
      if (!isVideoCall.value) {
        update();
      }
    });
  }

  void startMissedCallTimer() {
    missedCallTimer?.cancel();
    missCallDurationSeconds.value = 40;
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
        missedCall();
      }
    });
  }

  Future<void> missedCall() async {
    final Map<String, dynamic> param = {
      "callId": callId,
      "remoteUserId": remoteUserId,
    };

    socket?.emit("missCall", param);

    await endCall(type: "missedCall");
  }

  void _clearTimers() {
    callTimer?.cancel();
    missedCallTimer?.cancel();
    _remoteVideoWatchdog?.cancel();
    callTimer = null;
    missedCallTimer = null;
    _remoteVideoWatchdog = null;
    missCallDurationSeconds.value = 0;
  }

  void playSound() {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.ringing,
      looping: true,
      volume: 1.0,
    );
  }

  void stopSound() {
    FlutterRingtonePlayer().stop();
  }

  Future<void> startAudioCall() async {
    await WakelockPlus.enable();

    if (!audioRouteController.isBluetoothConnected.value) {
      await ProximityScreenLock.setActive(true);
    }
  }

  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    _peerDisconnectTimer?.cancel();
    _controlsTimer?.cancel();
    _remoteVideoWatchdog?.cancel();

    stopSound();

    navigator.mediaDevices.ondevicechange = null;

    socket?.off("IceCandidate");
    socket?.off("callAnswered");
    socket?.off("upgradeToVideo");
    socket?.off("upgradeToVideoAnswer");
    socket?.off("callRejected");
    socket?.off("callEnded", _onCallEnded);
    socket?.off("endCall", _onCallEnded);
    socket?.off("missedCall", _onMissedCall);
    socket?.off("callStatus");
    socket?.off("callCreated", _onCallCreated);
    socket?.off("newCall", _onNewCall);
    socket?.off("sdpOfferFromCaller");
    socket?.off("callError");
    socket?.off("callBlocked");

    unawaited(_disposePeerResources());
    unawaited(_stopForegroundCallService());
    unawaited(audioRouteController.stopCall());

    if (Get.isRegistered<CallAudioRouteController>(
      tag: _audioRouteTag,
    )) {
      Get.delete<CallAudioRouteController>(
        tag: _audioRouteTag,
      );
    }

    _clearTimers();

    final sid = _sessionId;
    if (sid.isNotEmpty) {
      unawaited(callEnded(sid, type: "onClose"));
    }

    CallSessionState.reset();

    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);

    super.onClose();
  }
}