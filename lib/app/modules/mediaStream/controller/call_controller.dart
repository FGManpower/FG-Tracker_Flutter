import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
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

  late String callerId;
  late String remoteUserId;
  dynamic offer;

  @override
  void onInit() {
    final args = Get.arguments;
    callerId = args["callerId"];
    remoteUserId = args["remoteUserId"];
    offer = args["offer"];

    localRenderer.initialize();
    remoteRenderer.initialize();

    _setupPeer();
    super.onInit();
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
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });

    peer!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
      update();
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
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

      socket!.emit("answerCall", {
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
      });
    }
  }

  void endCall() {
    resetPeer();
    Get.back();
  }

  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
  }

  void toggleCamera() {
    isVideoOn = !isVideoOn;
    localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn);
    update();
  }

  void switchCamera() {
    isFrontCamera = !isFrontCamera;
    localStream?.getVideoTracks().forEach((t) => t.switchCamera());
    update();
  }

  @override
  void onClose() {
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }
}
