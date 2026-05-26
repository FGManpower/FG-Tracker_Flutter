import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../Data/Services/SignallingService.dart';

class CallController extends GetxController {
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
  var callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
  bool isSpeakerOn = false;

  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;

  @override
  void onInit() {
    callerId = args["callerId"];
    remoteUserId = args["remoteUserId"];
    offer = args["offer"];
    is_video = args["is_video"];

    if (args["callId"] != null) {
      callId = args["callId"];
    }
    localRenderer.initialize();
    remoteRenderer.initialize();

    _setupPeer();
    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }
    WakelockPlus.enable();
    try{
      TrackingController.instance.initializeLocation();
    }catch(e){
      log("==============CallLocationException======${e.toString()}");
    }
    super.onInit();
  }

  void _listenForCallEvents() {
    socket?.off("callRejected");



    socket!.on("newCall", (data) {

      socket?.emit("CallingStatus", {
        "callId": data['callId'].toString(),
        "remoteUserId": int.parse(data['callerId']),
        "callingStatus": "Ringing",
      });
    });

    socket!.on("callRejected", (data) async {
      callTimer?.cancel();
      callTimer = null;

      if (CallSessionState.sessionId != null) {
        ConnectycubeFlutterCallKit.clearCallData(
          sessionId: CallSessionState.sessionId!,
        );
      }

      CallSessionState.reset();

      resetPeer();
      Get.back();
    });

    socket!.on("callEnded", (data) async {
      log("======================CallEnded==========$data");
      callTimer?.cancel();
      callTimer = null;

      resetPeer();
      if (CallSessionState.sessionId != null) {
        if (Platform.isAndroid) {
          ConnectycubeFlutterCallKit.clearCallData(
            sessionId: CallSessionState.sessionId!,
          );
        } else {
          FlutterCallkitIncoming.endCall(
            CallSessionState.sessionId!,
          );
        }
      }

      CallSessionState.reset();

      if (args["callType"] == "outGoing") {
        stopSound();
      }
      // await WakelockPlus.disable();
      Get.offAllNamed(Routes.Home_Screen);
    });

    socket!.on("missedCall", (data) async {
      callTimer?.cancel();
      callTimer = null;
      if (CallSessionState.sessionId != null) {
        if (Platform.isAndroid) {
          ConnectycubeFlutterCallKit.clearCallData(
            sessionId: CallSessionState.sessionId!,
          );
        } else {
          FlutterCallkitIncoming.endCall(
            CallSessionState.sessionId!,
          );
        }
      }

      CallSessionState.reset();
      resetPeer();
      Get.back();
    });

    socket?.on("callStatus", (data) {
      log("CALL STATUS: $data");

      if (data['status'] != null) {
        callStatus.value = data['status'];
      }
    });
  }

  void resetPeer() {
    try {
      peer?.close();
      localStream?.dispose();
    } catch (_) {}
    peer = null;
    localStream = null;
    // iceCandidates.clear();
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
      // 'iceTransportPolicy': 'relay', // it was working testing with divesh
    });

    peer!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      update();
      startCallTimer();
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

    if (offer != null) {
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
    } else {
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

        // "caller_name":  args["caller_name"],
        // "caller_profile_image":args["caller_profile_image"] ?? MyAppTheme.notFoundImg,
      });
    }
  }

  Future<void> endCall() async {
    callTimer?.cancel();
    callTimer = null;
    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final targetUser =
        (myUserId == callerId.toString()) ? remoteUserId : callerId;
    var param = {
      "callId": callId,
      "remoteUserId": targetUser.toString(),
    };
    log("=================EndCallDetail=========$param");
    socket?.emit("endCall",param);

    resetPeer();

    if (CallSessionState.sessionId != null) {
      if (Platform.isAndroid) {
        ConnectycubeFlutterCallKit.clearCallData(
          sessionId: CallSessionState.sessionId!,
        );
      } else {
        FlutterCallkitIncoming.endCall(
          CallSessionState.sessionId!,
        );
      }
    }

    CallSessionState.reset();

    if (args["callType"] == "outGoing") {
      stopSound();
    }
    await WakelockPlus.disable();
    Get.offAllNamed(Routes.Home_Screen);
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

  playSound() {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.ringing,
      looping: true,
      volume: 1.0,
    );
  }

  stopSound() {
    FlutterRingtonePlayer().stop();
  }

  @override
  void onClose() {
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    if (args["callType"] == "outGoing") {
      stopSound();
    }
    super.onClose();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    if (args["callType"] == "outGoing") {
      stopSound();
    }
  }
}
