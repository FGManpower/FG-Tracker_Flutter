import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../Data/Services/SignallingService.dart';
import '../../../Data/Services/CallStateTracker.dart';

enum CallState { idle, calling, ringing, connected, ended }

class CallController extends GetxController {
  final socket = SignallingService.instance.socket;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? peer;
  MediaStream? localStream;

  List<RTCIceCandidate> iceCandidates = [];

  RxString callStatus = "Calling".obs;
  Rx<CallState> callState = CallState.idle.obs;

  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCamera = true;
  bool isSpeakerOn = false;
  bool fromCallKit = false;
  bool _isEnding = false; // Prevent double end call

  dynamic callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;

  final args = Get.arguments;
  Timer? callTimer;
  Timer? missedCallTimer;
  int callDurationSeconds = 0;
  var missCallDurationSeconds = 40.obs;

  @override
  void onInit() {
    super.onInit();
    _parseArgs();
    _initRenderers();
    _setupPeer();
    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    WakelockPlus.enable();

    try {
      TrackingController.instance.initializeLocation();
    } catch (e) {
      log("CallLocationException: $e");
    }
  }

  void _parseArgs() {
    callerId = args["callerId"]?.toString() ?? "";
    remoteUserId = args["remoteUserId"]?.toString() ?? "";
    offer = args["offer"];
    is_video = args["is_video"] == true;
    fromCallKit = args["fromCallKit"] == true;
    callId = args["callId"] ?? args["sessionId"];
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void _listenForCallEvents() {
    // Remove old listeners first
    socket?.off("callRejected");
    socket?.off("callEnded");
    socket?.off("missedCall");
    socket?.off("callStatus");
    socket?.off("callCreated");
    socket?.off("callAnswered");
    socket?.off("sdpOfferFromCaller");
    socket?.off("requestSdpOffer");

    // ======= CALL CREATED (Outgoing) =======
    socket?.on("callCreated", (data) {
      log("✅ callCreated: $data");
      callId = data['callId'];
      callState.value = CallState.calling;
      _startMissedCallTimer();
    });

    // ======= CALL STATUS =======
    socket?.on("callStatus", (data) {
      log("📞 callStatus: $data");
      final status = data['status']?.toString() ?? "";
      callStatus.value = status;

      if (status == "Busy") {
        _handleBusy();
      } else if (status == "Ringing") {
        callState.value = CallState.ringing;
      }
    });

    // ======= CALL REJECTED =======
    socket?.on("callRejected", (data) {
      log("❌ callRejected: $data");
      if (_isEnding) return;
      _clearTimers();
      stopSound();
      _navigateHome();
    });

    // ======= CALL ENDED =======
    Future<void> endCall({String? type}) async {
      if (_isEnding) return;
      _isEnding = true;

      log("📵 endCall: callId=$callId, type=$type, state=${callState.value}");
      _clearTimers();
      stopSound();

      try {
        final myUserId = Global.storageServices.get(PrefConst.userId).toString();
        final targetUser = (myUserId == callerId.toString())
            ? remoteUserId
            : callerId;

        if (type != "missedCall") {
          // If call not yet connected, emit cancelCall instead of endCall
          if (callState.value == CallState.calling ||
              callState.value == CallState.ringing ||
              callState.value == CallState.idle) {

            log("🚫 Emitting cancelCall (not yet answered)");
            socket?.emit("cancelCall", {
              "callId": callId,
              "remoteUserId": targetUser.toString(),
            });
          } else {
            log("📵 Emitting endCall (call was active)");
            socket?.emit("endCall", {
              "callId": callId,
              "remoteUserId": targetUser.toString(),
            });
          }
        }
      } catch (e) {
        log("endCall emit error: $e");
      }

      resetPeer();

      if (CallSessionState.sessionId != null) {
        await callEnded(CallSessionState.sessionId.toString());
      }

      await WakelockPlus.disable();
      await ProximityScreenLock.setActive(false);

      _navigateHome();
    }


    // ======= MISSED CALL =======
    socket?.on("missedCall", (data) async {
      log("📵 missedCall in controller: $data");
      if (_isEnding) return;
      _isEnding = true;
      _clearTimers();
      stopSound();
      resetPeer();

      final sessionId = data['sessionId']?.toString() ??
          data['callId']?.toString();
      if (sessionId != null) {
        await callEnded(sessionId);
      }

      _navigateHome();
    });

    socket?.on("callCancelled", (data) async {
      log("🚫 callCancelled in controller: $data");
      if (_isEnding) return;
      _isEnding = true;

      _clearTimers();
      stopSound();
      resetPeer();

      final callId = data['callId']?.toString();
      if (CallSessionState.sessionId != null) {
        await callEnded(CallSessionState.sessionId!);
      } else if (callId != null) {
        await callEnded(callId);
      }

      _navigateHome();
    });

    // ======= REQUEST SDP OFFER (CallKit accept on receiver side) =======
    // Caller receives this and resends the SDP offer
    socket?.on("requestSdpOffer", (data) async {
      log("📤 requestSdpOffer received: $data");
      if (peer == null) return;

      try {
        final sdpOffer = await peer!.createOffer();
        await peer!.setLocalDescription(sdpOffer);

        socket!.emit("sdpOfferFromCaller", {
          "receiverId": data["receiverId"],
          "callId": data["callId"] ?? callId,
          "sdpOffer": sdpOffer.toMap(),
        });

        log("✅ SDP Offer resent to receiver");
      } catch (e) {
        log("requestSdpOffer error: $e");
      }
    });

    // ======= SDP OFFER FROM CALLER (receiver gets this after CallKit accept) =======
    socket?.on("sdpOfferFromCaller", (data) async {
      log("📥 sdpOfferFromCaller: $data");
      if (peer == null) return;

      try {
        final sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;

        callId = data["callId"] ?? callId;

        await peer!.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
        );

        final answer = await peer!.createAnswer();
        await peer!.setLocalDescription(answer);

        socket!.emit("answerCall", {
          "callId": callId,
          "callerId": callerId,
          "sdpAnswer": answer.toMap(),
        });

        callStatus.value = "Connecting";
        callState.value = CallState.connected;
      } catch (e) {
        log("sdpOfferFromCaller error: $e");
      }
    });
  }

  void _handleBusy() {
    callStatus.value = "User is Busy";
    stopSound();
    _clearTimers();

    // Show busy dialog then navigate home
    Future.delayed(const Duration(seconds: 2), () {
      _navigateHome();
    });
  }

  void resetPeer() {
    try {
      peer?.close();
      localStream?.getTracks().forEach((t) => t.stop());
      localStream?.dispose();
    } catch (_) {}
    peer = null;
    localStream = null;
  }

  void safeAddCandidate(dynamic data) {
    if (peer == null) return;
    try {
      final c = RTCIceCandidate(
        data["iceCandidate"]["candidate"],
        data["iceCandidate"]["id"],
        data["iceCandidate"]["label"],
      );
      peer!.addCandidate(c);
    } catch (e) {
      log("safeAddCandidate error: $e");
    }
  }

  Future<void> _setupPeer() async {
    resetPeer();

    socket?.off("IceCandidate");
    socket?.off("callAnswered");

    peer = await createPeerConnection({
      'iceServers': [
        {'urls': ['stun:stun.l.google.com:19302']},
        {
          'urls': [
            'turn:89.116.23.2:3478?transport=udp',
            'turn:89.116.23.2:3478?transport=tcp',
            'turns:89.116.23.2:443?transport=tcp',
          ],
          'username': 'fgtracker',
          'credential': 'FGM_Tracker@2025',
        }
      ],
      'iceTransportPolicy': 'all',
    });

    // When remote track arrives → call is connected
    peer!.onTrack = (event) {
      log("✅ Remote track received");
      remoteRenderer.srcObject = event.streams[0];
      callState.value = CallState.connected;
      callStatus.value = "Connected";
      _clearMissedCallTimer();
      _startCallTimer();
      stopSound();
      update();
    };

    // Connection state change
    peer!.onConnectionState = (state) {
      log("🔗 Peer connection state: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        log("⚠️ Peer disconnected");
        if (!_isEnding) endCall();
      }
    };

    // Get local media
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': is_video
            ? {'facingMode': isFrontCamera ? 'user' : 'environment'}
            : false,
      });
    } catch (e) {
      log("getUserMedia error: $e");
      return;
    }

    await enableSpeaker();

    for (var t in localStream!.getTracks()) {
      peer!.addTrack(t, localStream!);
    }

    localRenderer.srcObject = localStream;
    update();

    // ICE Candidate handler
    socket!.on("IceCandidate", (data) {
      if (peer == null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (peer != null) safeAddCandidate(data);
        });
        return;
      }
      safeAddCandidate(data);
    });

    // ========== INCOMING CALL (has SDP offer) ==========
    if (offer != null) {
      log("📥 Normal Incoming Call (has offer)");
      await _handleIncomingCall();
    }
    // ========== CALLKIT ACCEPT (no offer yet) ==========
    else if (fromCallKit ||
        (args["callType"] == "Incoming" && offer == null)) {
      log("📲 CallKit Accept Flow");
      await _handleCallKitAccept();
    }
    // ========== OUTGOING CALL ==========
    else {
      log("📤 Outgoing Call");
      await _handleOutgoingCall();
    }
  }

  Future<void> _handleIncomingCall() async {
    try {
      await peer!.setRemoteDescription(
        RTCSessionDescription(offer["sdp"], offer["type"]),
      );
      final answer = await peer!.createAnswer();
      await peer!.setLocalDescription(answer);

      peer!.onIceCandidate = (c) {
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

      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": answer.toMap(),
      });

      callStatus.value = "Connecting";
    } catch (e) {
      log("_handleIncomingCall error: $e");
    }
  }

  Future<void> _handleCallKitAccept() async {
    callStatus.value = "Connecting...";

    socket!.emit("acceptCallFromCallKit", {
      "callerId": callerId,
      "sessionId": CallSessionState.sessionId ?? args["sessionId"],
      "callId": callId,
      "receiverId": Global.storageServices.get(PrefConst.userId),
    });

    peer!.onIceCandidate = (c) {
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
  }

  Future<void> _handleOutgoingCall() async {
    peer!.onIceCandidate = (c) => iceCandidates.add(c);

    socket!.on("callAnswered", (data) async {
      log("✅ callAnswered: $data");
      _clearMissedCallTimer();
      stopSound();

      try {
        await peer!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        // Send all buffered ICE candidates
        for (var c in iceCandidates) {
          if (c.candidate == null) continue;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        iceCandidates.clear();

        // Live ICE candidates going forward
        peer!.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };

        callStatus.value = "Connecting";
      } catch (e) {
        log("callAnswered error: $e");
      }
    });

    final sdpOffer = await peer!.createOffer();
    await peer!.setLocalDescription(sdpOffer);

    socket!.emit("makeCall", {
      "remoteUserId": remoteUserId,
      "sdpOffer": sdpOffer.toMap(),
      "is_video": is_video,
      "callerId": Global.storageServices.get(PrefConst.userId),
    });
  }

  // ======================== END CALL ========================
  Future<void> endCall({String? type}) async {
    if (_isEnding) return;
    _isEnding = true;

    log("📵 Ending call: callId=$callId, type=$type");
    _clearTimers();
    stopSound();

    try {
      final myUserId = Global.storageServices.get(PrefConst.userId).toString();
      final targetUser = (myUserId == callerId.toString())
          ? remoteUserId
          : callerId;

      if (type != "missedCall") {
        socket?.emit("endCall", {
          "callId": callId,
          "remoteUserId": targetUser.toString(),
        });
      }
    } catch (e) {
      log("endCall emit error: $e");
    }

    resetPeer();

    if (CallSessionState.sessionId != null) {
      await callEnded(CallSessionState.sessionId.toString());
    }

    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);

    _navigateHome();
  }

  void _navigateHome() {
    CallStateTracker.isIncomingCallScreenOpen = false;
    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  // ======================== CONTROLS ========================
  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  void toggleCamera() {
    if (!is_video) return;
    isVideoOn = !isVideoOn;
    localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn);
    update();
  }

  void switchCamera() {
    if (!is_video) return;
    isFrontCamera = !isFrontCamera;
    localStream?.getVideoTracks().forEach((t) => t.switchCamera());
    update();
  }

  Future<void> enableSpeaker() async {
    await Helper.setSpeakerphoneOn(true);
    isSpeakerOn = true;
    update();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;
    await Helper.setSpeakerphoneOn(isSpeakerOn);
    await ProximityScreenLock.setActive(!isSpeakerOn);
    update();
  }

  // ======================== TIMERS ========================
  void _startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDurationSeconds++;
      update();
    });
  }

  void _startMissedCallTimer() {
    _clearMissedCallTimer();
    missCallDurationSeconds.value = 40;

    missedCallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) { timer.cancel(); return; }

      if (missCallDurationSeconds.value > 0) {
        missCallDurationSeconds.value--;
      }

      if (missCallDurationSeconds.value == 0) {
        timer.cancel();
        log("⏱️ Missed call timer expired");
        socket?.emit("missCall", {
          "callId": callId,
          "remoteUserId": remoteUserId,
          "sessionId": remoteUserId,
        });
        endCall(type: "missedCall");
      }
    });
  }

  void _clearMissedCallTimer() {
    missedCallTimer?.cancel();
    missedCallTimer = null;
  }

  void _clearTimers() {
    callTimer?.cancel();
    missedCallTimer?.cancel();
    callTimer = null;
    missedCallTimer = null;
    callDurationSeconds = 0;
    missCallDurationSeconds.value = 0;
  }

  String get formattedDuration {
    final m = (callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (callDurationSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
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
    try { FlutterRingtonePlayer().stop(); } catch (_) {}
  }

  @override
  void onClose() {
    _clearTimers();
    stopSound();
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    super.onClose();
  }
}