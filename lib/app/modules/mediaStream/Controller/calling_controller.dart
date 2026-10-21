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

  List<RTCIceCandidate> iceCandidates = [];
  RxString callStatus = "Calling".obs;
  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCamera = true;
  dynamic callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
  bool isSpeakerOn = false;
  bool fromCallKit = false;
  bool _isCleaningUp = false;
  bool _remoteEndSent = false;
  bool _callKitConnectedSent = false;

  Timer? _peerDisconnectTimer;
  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;
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

  MediaStream? _remoteFallbackStream;

  Timer? _remoteVideoWatchdog;

  void toggleVideoViews() {
    if (!isVideoCall.value) return;
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
      await _cleanupCall(notifyRemote: true, navigateHome: true);
    }
  }

  Future<void> _cleanupCall({
    required bool notifyRemote,
    required bool navigateHome,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    try {
      _clearTimers();
      _controlsTimer?.cancel();
      _peerDisconnectTimer?.cancel();

      stopSound();
      await audioRouteController.stopCall();

      if (notifyRemote && !_remoteEndSent) {
        _remoteEndSent = true;
        var param = {
          "callId": callId,
          "remoteUserId": remoteUserId,
          "sessionId": _sessionId,
        };
        socket?.emit("endCall", param);
      }

      await _disposePeerResources();
      await _stopForegroundCallService();

      final String sessionId = _sessionId;
      if (sessionId.isNotEmpty) {
        try {
          await callEnded(sessionId, type: "CallCleanedUp");
        } catch (e) {
          log("[Call] Call cleanup error: $e");
        }
      }

      CallSessionState.reset();

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);

      if (navigateHome && Get.currentRoute != Routes.Home_Screen) {
        Get.offAllNamed(Routes.Home_Screen);
      }
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
    log("📱 CallingController: AppLifecycleState changed to: $state");
    if (state == AppLifecycleState.resumed) {
      log("App Foregrounded: Forcefully restoring audio routes...");
      _ensureAudioTracksActive();
    } else if (state == AppLifecycleState.paused) {
      log("⏸️ App Backgrounded: Keeping WebRTC mic tracks alive...");
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

      if (remoteRenderer.srcObject != null) {
        for (final track in remoteRenderer.srcObject!.getAudioTracks()) {
          track.enabled = true;
        }
        if (isVideoCall.value) {
          for (final track in remoteRenderer.srcObject!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      if (isVideoCall.value) {
        unawaited(_rebindRemoteRenderer());
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
    final MediaStream? s = stream ?? remoteRenderer.srcObject;
    if (s == null) return;

    remoteRenderer.srcObject = null;
    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (isClosed || peer == null) return;

    remoteRenderer.srcObject = s;
    update();
  }

  void _scheduleRemoteVideoCheck() {
    _remoteVideoWatchdog?.cancel();

    int attempts = 0;
    _remoteVideoWatchdog = Timer.periodic(const Duration(seconds: 2), (t) {
      attempts++;

      if (isClosed || peer == null || !isVideoCall.value || attempts > 5) {
        t.cancel();
        return;
      }

      final tracks = remoteRenderer.srcObject?.getVideoTracks() ?? [];
      if (tracks.isEmpty) return;

      int width = 0;
      try {
        width = remoteRenderer.videoWidth;
      } catch (_) {}

      if (width > 0) {
        t.cancel();
        return;
      }

      log("[Call] Remote video has no frames yet, rebinding renderer (attempt $attempts)");
      unawaited(_rebindRemoteRenderer());
    });
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    try {
      MediaStream? stream =
          event.streams.isNotEmpty ? event.streams.first : null;

      if (stream == null) {
        _remoteFallbackStream ??=
            await createLocalMediaStream('remote_fallback');
        await _remoteFallbackStream!.addTrack(event.track);
        stream = _remoteFallbackStream;
      }

      if (stream == null || peer == null) return;

      final bool isVideoTrack = event.track.kind == 'video';
      final bool sameStream = remoteRenderer.srcObject?.id == stream.id;

      if (!sameStream) {
        remoteRenderer.srcObject = stream;
      } else if (isVideoTrack) {
        await _rebindRemoteRenderer(stream);
      }

      missedCallTimer?.cancel();
      missedCallTimer = null;

      startCallTimer();
      callStatus.value = "Connected";
      update();

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
    isVideoOn = true;
    is_video = true;
    isVideoCall.value = true;
    isLocalVideoMain = false;
    pipPosition = null;
    if (isUpgradingToVideo.value) return;
    if (peer == null || localStream == null) {
      Utils().fluttertoast("Call not ready");
      return;
    }

    try {
      isUpgradingToVideo.value = true;

      final vids = localStream!.getVideoTracks();
      if (vids.isEmpty) {
        final videoStream = await navigator.mediaDevices.getUserMedia({
          'audio': false,
          'video': {
            'facingMode': isFrontCamera ? 'user' : 'environment',
            'width': {'ideal': 640},
            'height': {'ideal': 480},
          },
        });

        final videoTrack = videoStream.getVideoTracks().firstOrNull;
        if (videoTrack == null) {
          throw Exception("No video track available");
        }
        await localStream!.addTrack(videoTrack);
        await peer!.addTrack(videoTrack, localStream!);
      } else {
        for (var t in vids) {
          t.enabled = true;
        }
      }

      localRenderer.srcObject = localStream;
      isVideoOn = true;
      is_video = true;
      isVideoCall.value = true;

      final offer = await peer!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await peer!.setLocalDescription(offer);

      await audioRouteController.updateCallType(isVideo: true);

      final myUserId = Global.storageServices.get(PrefConst.userId).toString();
      final targetUserId =
          (myUserId == callerId.toString()) ? remoteUserId : callerId;

      socket?.emit("upgradeToVideo", {
        "callId": callId,
        "remoteUserId": targetUserId,
        "sdpOffer": offer.toMap(),
        "callerId": myUserId,
      });

      callStatus.value = "Video connecting";
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

        await peer!.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
        );

        final answer = await peer!.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true,
        });
        await peer!.setLocalDescription(answer);

        socket?.emit("upgradeToVideoAnswer", {
          "callId": callId,
          "remoteUserId": data["callerId"],
          "sdpAnswer": answer.toMap(),
        });

        is_video = true;
        isVideoCall.value = true;
        callStatus.value = "Connected";
        await audioRouteController.updateCallType(isVideo: true);
        update();

        _scheduleRemoteVideoCheck();
      } catch (e) {
        log("upgradeToVideo handler error: $e");
      }
    });

    socket?.on("upgradeToVideoAnswer", (data) async {
      try {
        if (peer == null) return;
        final sdp = data["sdpAnswer"];
        if (sdp == null) return;

        await peer!.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
        );

        is_video = true;
        isVideoOn = true;
        isVideoCall.value = true;
        callStatus.value = "Connected";
        await audioRouteController.updateCallType(isVideo: true);
        update();

        _scheduleRemoteVideoCheck();
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
    await _cleanupCall(notifyRemote: false, navigateHome: true);
  }

  Future<void> _onMissedCall(dynamic data) async {
    log("[Socket] missedCall RECEIVED: $data");

    if (_isCleaningUp) return;

    if (callTimer != null || callDurationSeconds > 0) {
      log("[Socket] missedCall ignored: call already connected");
      return;
    }

    _clearTimers();
    stopSound();

    final String sessionId = data["sessionId"]?.toString().isNotEmpty == true
        ? data["sessionId"].toString()
        : CallSessionState.sessionId?.toString() ?? "";

    if (sessionId.isNotEmpty) {
      await callEnded(sessionId, type: "missedCallFromSocket");
    }

    await resetPeer();
    await _stopForegroundCallService();
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);

    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
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

      stopSound();
      _clearTimers();

      await audioRouteController.stopCall();
      await resetPeer();

      if (Get.isOverlaysOpen) {
        Get.back();
      }

      Get.snackbar(
        "Call Failed",
        data?["message"]?.toString() ?? "Unable to make call",
      );
    });

    socket?.on("callBlocked", (data) async {
      log("CALL BLOCKED => $data");

      stopSound();
      _clearTimers();

      await audioRouteController.stopCall();
      await resetPeer();

      if (Get.isOverlaysOpen) {
        Get.back();
      }

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
            RTCSessionDescription(sdp["sdp"], sdp["type"]));
        await _markRemoteDescriptionSet();

        final answer = await peer!.createAnswer();
        await peer!.setLocalDescription(answer);

        socket!.emit("answerCall", {
          "callId": callId,
          "callerId": callerId,
          "sdpAnswer": answer.toMap(),
        });
        callStatus.value = "Connecting";
      } catch (e) {
        log("Error handling sdpOfferFromCaller: $e");
      }
    });

    socket?.on("newCall", _onNewCall);
    socket?.on("callEnded", _onCallEnded);
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
      await _cleanupCall(notifyRemote: false, navigateHome: true);
    });

    socket?.on("callStatus", (data) {
      print("========CallingStatusData:${data}");
      final status = data["status"]?.toString();
      if (status != null && status.isNotEmpty) {
        callStatus.value = status;
        if (data['callId'] != null) {
          callId = data['callId'];
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
      _remoteDescriptionSet = false;
      _pendingRemoteCandidates.clear();

      if (pc != null) {
        pc.onIceConnectionState = null;
        pc.onConnectionState = null;
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

      await _remoteFallbackStream?.dispose();
      _remoteFallbackStream = null;

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
    _peerDisconnectTimer = Timer(const Duration(seconds: 8), () {
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

      log("[Call] Connection did not recover in 8s, ending call");
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
      'video': is_video == true
          ? {'facingMode': isFrontCamera ? 'user' : 'environment'}
          : false,
    });

    for (var t in localStream!.getTracks()) {
      pc.addTrack(t, localStream!);
    }
    localRenderer.srcObject = localStream;

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
          RTCSessionDescription(offer["sdp"], offer["type"]));
      await _markRemoteDescriptionSet();

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": answer.toMap(),
      });
    } else if (fromCallKit ||
        (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";
      socket!.emit("acceptCallFromCallKit", {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      });
    } else {
      pc.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        if (!identical(peer, pc) || _remoteDescriptionSet) return;

        try {
          await pc.setRemoteDescription(
            RTCSessionDescription(
                data["sdpAnswer"]["sdp"], data["sdpAnswer"]["type"]),
          );
          await _markRemoteDescriptionSet();
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

      final sdpOffer = await pc.createOffer();
      await pc.setLocalDescription(sdpOffer);

      socket!.emit("makeCall", {
        "remoteUserId": remoteUserId,
        "sdpOffer": sdpOffer.toMap(),
        "is_video": is_video,
        "callerId": Global.storageServices.get(PrefConst.userId),
      });
    }
  }

  Future<void> endCall({
    String? type,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    try {
      _clearTimers();
      await audioRouteController.stopCall();
      await _stopForegroundCallService();

      final String myUserId =
          Global.storageServices.get(PrefConst.userId).toString();

      final String targetUser =
          myUserId == callerId.toString() ? remoteUserId : callerId;

      final Map<String, dynamic> payload = {
        "callId": callId,
        "remoteUserId": targetUser,
      };

      if (type != "missedCall") {
        socket?.emit("endCall", payload);
      }

      await resetPeer();

      final String sid = _sessionId;
      if (sid.isNotEmpty) {
        await callEnded(
          sid,
          type: "endCallMethodHittedFromController-Type:$type",
        );
      }

      if (args["callType"] == "outGoing") {
        stopSound();
      }

      CallSessionState.reset();

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);

      if (Get.currentRoute != Routes.Home_Screen) {
        Get.offAllNamed(Routes.Home_Screen);
      }
    } finally {
      _isCleaningUp = false;
    }
  }

  void _handlePeerDisconnected() {
    if (_isCleaningUp || isClosed) return;
    log("[Call] Remote peer disconnected");
    unawaited(_cleanupCall(notifyRemote: false, navigateHome: true));
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  void toggleCamera() {
    if (!isVideoCall.value) return;

    final vids = localStream?.getVideoTracks() ?? [];
    if (vids.isEmpty) {
      upgradeToVideoCall();
    } else {
      isVideoOn = !isVideoOn;
      for (var t in vids) {
        t.enabled = isVideoOn;
      }
      update();
    }
  }

  void switchCamera() {
    if (!isVideoCall.value || !isVideoOn) return;
    isFrontCamera = !isFrontCamera;
    localStream?.getVideoTracks().forEach((t) {
      Helper.switchCamera(t);
    });
    update();
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
    final minutes = (callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (callDurationSeconds % 60).toString().padLeft(2, '0');
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
      update();
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
