import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../gen/assets.gen.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Model/callDetailRes.dart';
import 'package:intl/intl.dart';
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

  final Rxn<CallDetail> apiCallDetail = Rxn<CallDetail>();

  final RxBool isBluetoothConnected = false.obs;
  final RxString currentAudioRoute = "earpiece".obs;
  Timer? _deviceCheckTimer;

  Timer? missedCallTimer;
  var missCallDurationSeconds = 40.obs;

  final RxBool isVideoCall = false.obs;
  final RxBool isUpgradingToVideo = false.obs;

  bool isLocalVideoMain = false;

  final RxBool areControlsVisible = true.obs;
  Timer? _controlsTimer;

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
    isVideoCall.value = is_video == true;
    localRenderer.initialize();
    remoteRenderer.initialize();

    _setupPeer();
    _listenForCallEvents();

    if (args["callType"] == "outGoing") {
      playSound();
    }

    WakelockPlus.enable();

    try {
      GroupTrackingController.instance.initializeLocation();
    } catch (e) {
      log("==============CallLocationException======${e.toString()}");
    }

    if (callId != null) {
      fetchCallDetail();
    }

    super.onInit();
  }


  Future<void> upgradeToVideoCall() async {
    isVideoOn = true;
    is_video = true;
    isVideoCall.value = true;
    isLocalVideoMain = false;
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

        for (var t in vids) { t.enabled = true; }
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
      await setDefaultAudioRouteForCallType(isVideo: true);

      final myUserId = Global.storageServices.get(PrefConst.userId).toString();
      final targetUserId = (myUserId == callerId.toString()) ? remoteUserId : callerId;


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
        await setDefaultAudioRouteForCallType(isVideo: true);
        update();
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
        await setDefaultAudioRouteForCallType(isVideo: true);

        update();
      } catch (e) {
        log("upgradeToVideoAnswer error: $e");
      }
    });
  }

  void _listenForCallEvents() {
    socket?.off("callRejected");
    socket?.off("callEnded");
    socket?.off("missedCall");
    socket?.off("callStatus");
    socket?.off("callCreated");
    socket?.off("newCall");
    socket?.off("sdpOfferFromCaller");
    socket?.off("callError");
    socket?.off("callBlocked");

    socket?.on("callError", (data) {
      log("CALL ERROR => $data");
      stopSound();
      _clearTimers();
      resetPeer();
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      Get.snackbar("Call Failed", data?['message']?.toString() ?? "Unable to make call");
    });

    socket?.on("callBlocked", (data) {
      log("CALL BLOCKED => $data");
      stopSound();
      _clearTimers();
      resetPeer();
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      Get.snackbar("Call unavailable", data?['message']?.toString() ?? "Communication is not available with this user");
    });

    socket?.on("sdpOfferFromCaller", (data) async {
      log("====== Received SDP Offer from Caller (CallKit flow) ======");
      log("Data: $data");
      if (peer == null) return;

      try {
        final sdp = data["sdpOffer"] ?? data["offer"];
        if (sdp == null) return;
        offer = sdp;
        callId = data["callId"] ?? callId;

        await peer!.setRemoteDescription(RTCSessionDescription(sdp["sdp"], sdp["type"]));
        final answer = await peer!.createAnswer();
        await peer!.setLocalDescription(answer);

        peer!.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": callerId,
            "iceCandidate": {"id": c.sdpMid, "label": c.sdpMLineIndex, "candidate": c.candidate},
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
        callEnded(CallSessionState.sessionId.toString(), type: "CallRejectedFromController");
      }
      resetPeer();
      Get.back();
    });

    socket!.on("callEnded", (data) async {
      _clearTimers();
      resetPeer();
      if (CallSessionState.sessionId != null) {
        callEnded(data['sessionId'].toString(), type: "callEndedFromController");
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
        callEnded(CallSessionState.sessionId.toString(), type: "missedCallFromController");
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
      fetchCallDetail();
      startMissedCallTimer();
    });

    _listenVideoUpgradeEvents();
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
        {'urls': ['stun:stun.l.google.com:19302']},
        {'urls': Urls.rtcUrl, 'username': Urls.rtcUserName, 'credential': Urls.rtcCredential}
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
      fetchCallDetail();
    };

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': is_video == true ? {'facingMode': isFrontCamera ? 'user' : 'environment'} : false,
    });

    _startDeviceMonitoring();

    await setDefaultAudioRouteForCallType(isVideo: is_video == true);

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
      await peer!.setRemoteDescription(RTCSessionDescription(offer["sdp"], offer["type"]));
      final answer = await peer!.createAnswer();
      await peer!.setLocalDescription(answer);

      peer!.onIceCandidate = (c) {
        if (c.candidate == null) return;
        socket!.emit("IceCandidate", {
          "remoteUserId": callerId,
          "iceCandidate": {"id": c.sdpMid, "label": c.sdpMLineIndex, "candidate": c.candidate},
        });
      };

      socket!.emit("answerCall", {
        "callId": callId,
        "callerId": callerId,
        "sdpAnswer": answer.toMap(),
      });
    } else if (fromCallKit || (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";
      socket!.emit("acceptCallFromCallKit", {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      });
    } else {
      peer!.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        await peer!.setRemoteDescription(
          RTCSessionDescription(data["sdpAnswer"]["sdp"], data["sdpAnswer"]["type"]),
        );

        for (var c in iceCandidates) {
          if (c.candidate == null) continue;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {"id": c.sdpMid, "label": c.sdpMLineIndex, "candidate": c.candidate},
          });
        }
        iceCandidates.clear();

        peer!.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket!.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {"id": c.sdpMid, "label": c.sdpMLineIndex, "candidate": c.candidate},
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

    if (type != "missedCall") {
      socket?.emit("endCall", param);
    }

    resetPeer();

    if (CallSessionState.sessionId != null) {
      callEnded(CallSessionState.sessionId.toString(),
          type: "endCallMethodHittedFromController-Type:$type");
    }

    if (args["callType"] == "outGoing") {
      stopSound();
    }

    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);

    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
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

  Future<void> enableSpeaker() async {
    await Helper.setSpeakerphoneOn(true);
    isSpeakerOn = true;
    currentAudioRoute.value = "speaker";
    await ProximityScreenLock.setActive(false);
    update();
  }

  Future<void> disableSpeaker() async {
    await Helper.setSpeakerphoneOn(false);
    isSpeakerOn = false;
    currentAudioRoute.value =
    isBluetoothConnected.value ? "bluetooth" : "earpiece";

    if (!isVideoCall.value && !isBluetoothConnected.value) {
      await ProximityScreenLock.setActive(true);
    } else {
      await ProximityScreenLock.setActive(false);
    }
    update();
  }




  Future<void> toggleSpeaker() async {
    if (isSpeakerOn) {
      await disableSpeaker();
    } else {
      await enableSpeaker();
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

  Future<void> fetchCallDetail() async {
    if (callId == null) return;
    try {
      final res = await CallRepo.callDetailData(callId.toString());
      if (res.status == true && res.callDetail != null) {
        apiCallDetail.value = res.callDetail;
        final rawTime = res.callDetail?.startTime;

      }
    } catch (e) {
      log("Error fetching call detail: $e");
    }

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

  void missedCall() {
    var param = {"callId": callId, "remoteUserId": remoteUserId};
    socket?.emit("missCall", param);
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
    if (!isBluetoothConnected.value) {
      await ProximityScreenLock.setActive(true);
    }
  }


  Future<void> setDefaultAudioRouteForCallType({required bool isVideo}) async {
    await checkAudioDevices();

    if (isBluetoothConnected.value) {
      await disableSpeaker();
    } else {
      if (isVideo) {
        await enableSpeaker();
      } else {
        await disableSpeaker();
      }
    }
  }
  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);
  }
  void _startDeviceMonitoring() {
    checkAudioDevices();

    navigator.mediaDevices.ondevicechange = (event) {
      log("🔄 Audio Routing Device Changed!");
      checkAudioDevices();
    };

    _deviceCheckTimer?.cancel();
    _deviceCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkAudioDevices();
    });
  }
  Future<void> checkAudioDevices() async {
    try {
      final List<MediaDeviceInfo> devices =
      await navigator.mediaDevices.enumerateDevices();
      bool isBtFound = false;

      for (var device in devices) {
        if (device.kind == 'audiooutput') {
          final String label = device.label.toLowerCase();
          if (label.contains('bluetooth') ||
              label.contains('blue') ||
              label.contains('buds') ||
              label.contains('headset') ||
              label.contains('freebuds') ||
              label.contains('airpods') ||
              label.contains('hands-free') ||
              label.contains('wireless') ||
              label.contains('hearing aid')) {
            isBtFound = true;
            break;
          }
        }
      }

      isBluetoothConnected.value = isBtFound;

      // Active channel determination
      if (isSpeakerOn) {
        currentAudioRoute.value = "speaker";
      } else if (isBtFound) {
        currentAudioRoute.value = "bluetooth";
      } else {
        currentAudioRoute.value = "earpiece";
      }
      update();
    } catch (e) {
      log("❌ checkAudioDevices error: $e");
    }
  }
  @override
  void onClose() {
    _controlsTimer?.cancel();

    _clearTimers();
    resetPeer();
    localRenderer.dispose();
    remoteRenderer.dispose();

    if (args["callType"] == "outGoing") {
      stopSound();
    }

    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);

    super.onClose();
  }
}