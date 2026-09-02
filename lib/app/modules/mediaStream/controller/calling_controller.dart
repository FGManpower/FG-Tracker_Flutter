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
import '../../../Data/Services/Socket/Socket_SignallingService.dart';

class CallingController extends GetxController {
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

  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;

  Timer? missedCallTimer;
  var missCallDurationSeconds = 40.obs;

  @override
  void onInit() {
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

    localRenderer.initialize();
    remoteRenderer.initialize();

    _setupPeer();
    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    WakelockPlus.enable();

    try {
      TrackingController.instance.initializeLocation();
    } catch (e) {
      log("==============CallLocationException======${e.toString()}");
    }

    super.onInit();
  }

  void _listenForCallEvents() {
    socket?.off("callRejected");
    socket?.off("callEnded");
    socket?.off("missedCall");
    socket?.off("callStatus");
    socket?.off("callCreated");
    socket?.off("newCall");
    socket?.off("sdpOfferFromCaller");


    socket?.on("sdpOfferFromCaller", (data) async {
      log("====== Received SDP Offer from Caller (CallKit flow) ======");
      log("Data: $data");

      if (peer == null) return;

      try {
        final sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;

        offer = sdp;
        callId = data["callId"] ?? callId;

        await peer!.setRemoteDescription(
          RTCSessionDescription(sdp["sdp"], sdp["type"]),
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
        log("Error handling sdpOfferFromCaller: $e");
      }
    });

    socket!.on("newCall", (data) {
      socket?.emit("CallingStatus", {
        "callId": data['callId'].toString(),
        "remoteUserId": int.tryParse(data['callerId'].toString()) ?? 0,
        "callingStatus": "Ringing",
      });
    });

    socket!.on("callRejected", (data) async {
      _clearTimers();

      if (CallSessionState.sessionId != null) {
        callEnded(CallSessionState.sessionId.toString(),
            type: "CallRejectedFromController");
      }

      resetPeer();
      Get.back();
    });

    socket!.on("callEnded", (data) async {
      _clearTimers();

      resetPeer();
      if (CallSessionState.sessionId != null) {
        callEnded(data['sessionId'].toString(),
            type: "callEndedFromController");
      }
      if (args["callType"] == "outGoing") {
        stopSound();
      }
      if (Get.currentRoute != Routes.Home_Screen) {
        Get.offAllNamed(Routes.Home_Screen);
      }
    });

    socket!.on("missedCall", (data) async {
      log("==========MissedCallCalled=======$data");
      _clearTimers();
      if (CallSessionState.sessionId != null) {
        callEnded(CallSessionState.sessionId.toString(),
            type: "missedCallFromController");
      }

      resetPeer();
      Get.back();
    });

    socket?.on("callStatus", (data) {
      log("CALL STATUS: $data");

      if (data['status'] != null) {
        callStatus.value = data['status'];
      }
    });

    socket?.on("callCreated", (data) {
      callId = data['callId'];
      startMissedCallTimer();
    });
  }

  void resetPeer() {
    try {
      peer?.close();
      localStream?.dispose();
    } catch (_) {}
    peer = null;
    localStream = null;
  }

  void safeAddCandidate(dynamic data) {
    if (peer == null) return;
    final c = RTCIceCandidate(
      data["iceCandidate"]["candidate"],
      data["iceCandidate"]["id"],
      data["iceCandidate"]["label"],
    );
    peer!.addCandidate(c);
  }

  Future<void> _setupPeer() async {
    resetPeer();

    socket!.off("IceCandidate");
    socket!.off("callAnswered");

    peer = await createPeerConnection({
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
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

    peer!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      update();

      missedCallTimer?.cancel();
      missedCallTimer = null;

      startCallTimer();
      callStatus.value = "Connected";
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': is_video == true
          ? {'facingMode': isFrontCamera ? 'user' : 'environment'}
          : false,
    });

    await enableSpeaker();

    for (var t in localStream!.getTracks()) {
      peer!.addTrack(t, localStream!);
    }

    localRenderer.srcObject = localStream;
    update();

    socket!.on("IceCandidate", (data) {
      if (peer == null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (peer != null) safeAddCandidate(data);
        });
        return;
      }
      safeAddCandidate(data);
    });

    // ========== INCOMING CALL (has SDP offer) ==========
    if (offer != null) {
      log("====== Normal Incoming Call (has offer) ======");

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
    }

    else if (fromCallKit || (args["callType"] == "Incoming" && offer == null)) {


      callStatus.value = "Connecting...";

      // Tell the caller that we accepted from CallKit and request the SDP
      socket!.emit("acceptCallFromCallKit", {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      });

      // We will receive the offer via "sdpOfferFromCaller" listener
    }

    else {
      log("====== Outgoing Call ======");

      peer!.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        await peer!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

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
  }

  Future<void> endCall({String? type}) async {
    _clearTimers();

    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final targetUser =
        (myUserId == callerId.toString()) ? remoteUserId : callerId;

    var param = {
      "callId": callId,
      "remoteUserId": targetUser.toString(),
    };



    if(callStatus.value != "Connected"){

    }
    if (type != "missedCall") {
      log("========CallEndParameterDetail:$param");
      socket?.emit("endCall", param);
    }

    resetPeer();

    if (CallSessionState.sessionId != null) {
      log("========CallerSideSessionId:${CallSessionState.sessionId}");
      callEnded(CallSessionState.sessionId.toString(),
          type: "endCallMethodHittedFromController-Type:${type}");
    }

    if (args["callType"] == "outGoing") {
      stopSound();
    }

    await WakelockPlus.disable();

    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
      log("========CallerSideSessionId2:${CallSessionState.sessionId}");
    }
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  void toggleCamera() {
    if (is_video == false) return;
    isVideoOn = !isVideoOn;
    localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn);
    update();
  }

  void switchCamera() {
    if (is_video == false) return;
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

    if (isSpeakerOn) {
      await ProximityScreenLock.setActive(false);
    } else {
      await ProximityScreenLock.setActive(true);
    }

    update();
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

    missedCallTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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
      },
    );
  }

  void missedCall(){
    var param = {
      "callId": callId,
      "remoteUserId": remoteUserId,
    };
    print("MISS CALL EMIT => $param");
    socket?.emit("missCall", param);
    log("=======MissedCallParam===$param");

    endCall(type: "missedCall");
  }
  void _clearTimers() {
    callTimer?.cancel();
    missedCallTimer?.cancel();
    callTimer = null;
    missedCallTimer = null;
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
    await ProximityScreenLock.setActive(true);
  }

  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);
  }

  @override
  void onClose() {
    _clearTimers();
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    if (args["callType"] == "outGoing") {
      stopSound();
    }
    WakelockPlus.disable();
    super.onClose();
  }
}
