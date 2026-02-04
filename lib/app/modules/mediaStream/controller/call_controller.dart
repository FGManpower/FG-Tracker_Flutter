import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../main.dart';
import '../../../Data/Services/SignallingService.dart';

class CallController extends GetxController {
  final socket = SignallingService.instance.socket;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? peer;
  MediaStream? localStream;

  List<RTCIceCandidate> iceCandidates = [];

  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCamera = true;
  var callId;
  late String callerId;
  late String remoteUserId;
  late bool is_video;
  dynamic offer;
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
    playSound();
    super.onInit();
  }

  void _listenForCallEvents() {

    socket?.off("callRejected");
    // Caller receives callId
    socket!.on("callCreated", (data) {
      callId = data["callId"].toString();
      update();
    });

    // Receiver: new incoming call received
    socket!.on("newCall", (data) {
      callId = data["callId"].toString();
      update();
    });


    socket!.on("callRejected", (data) {
      log("==================CallRejectedEventCalled");
      callTimer?.cancel();
      callTimer = null;
      resetPeer();
      Get.back();
      // Get.snackbar("Call", "Call rejected by ${data['rejectedBy']}");
    });

    socket!.on("callEnded", (data) {
      callTimer?.cancel();
      callTimer = null;
      resetPeer();
      Get.back();
      // Get.snackbar("Call", "Call ended by ${data['endedBy']}");
    });

    socket!.on("missedCall", (data) {
      callTimer?.cancel();
      callTimer = null;
      resetPeer();
      Get.back();
      // Get.snackbar("Call", "Call ended by ${data['endedBy']}");
    });

  }


  void resetPeer() {
    try {
      peer?.close();
      localStream?.dispose();
    } catch (_) {}
    peer = null;
    localStream = null;
    iceCandidates.clear();
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
      startCallTimer();
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': is_video == true
          ? {'facingMode': isFrontCamera ? 'user' : 'environment'}
          : false,
    });

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
      log("---------------------CallId---$callId");
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
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate
            }
          });
        }
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



  void endCall() {
    callTimer?.cancel();
    callTimer = null;
    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final targetUser = (myUserId == callerId.toString()) ? remoteUserId : callerId;

    print('======CallId==${callId}=======>MyUserId:${myUserId}');
    socket?.emit("endCall", {
      "callId": callId,
      "remoteUserId": targetUser.toString(),
    });

    resetPeer();
    // if (Get.currentRoute != Routes.Home_Screen) {
    //   Get.back();
    // } else {
      Get.offAllNamed(Routes.Home_Screen);
    // }



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

  String get formattedDuration {
    final minutes = (callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (callDurationSeconds % 60).toString().padLeft(2, '0');
    if( Utility.isNotNullEmptyOrFalse("$minutes:$seconds")){
      stopSound();
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

  playSound(){
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.ringing,
      looping: true,
      volume: 1.0,
    );
  }
  stopSound(){
    FlutterRingtonePlayer().stop();
  }


  @override
  void onClose() {
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }
}
