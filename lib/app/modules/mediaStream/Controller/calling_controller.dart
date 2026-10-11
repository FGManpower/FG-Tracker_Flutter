import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../gen/assets.gen.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Model/callDetailRes.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../Data/Services/Socket/Socket_SignallingService.dart';

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

  final args = Get.arguments;
  Timer? callTimer;
  int callDurationSeconds = 0;
  Offset? pipPosition;
  final Rxn<CallDetail> apiCallDetail = Rxn<CallDetail>();

  final RxBool isBluetoothConnected = false.obs;
  final RxBool isWiredHeadsetConnected = false.obs;
  final RxString currentAudioRoute = "earpiece".obs;

  Timer? _deviceCheckTimer;
  String? _earpieceDeviceId;
  String? _speakerDeviceId;
  String? _bluetoothDeviceId;
  String? _wiredDeviceId;

  Future<void> _routeQueue = Future.value();
  Future<void>? _deviceCheck;

  Timer? missedCallTimer;
  var missCallDurationSeconds = 40.obs;

  final RxBool isVideoCall = false.obs;
  final RxBool isUpgradingToVideo = false.obs;

  bool isLocalVideoMain = false;

  final RxBool areControlsVisible = true.obs;
  Timer? _controlsTimer;

  IconData get currentAudioRouteIcon {
    switch (currentAudioRoute.value) {
      case "speaker":
        return Icons.volume_up_rounded;
      case "bluetooth":
        return Icons.bluetooth_audio_rounded;
      case "wired":
        return Icons.headset_rounded;
      case "earpiece":
      default:
        return Icons.phone_in_talk_rounded;
    }
  }

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
    WidgetsBinding.instance.addObserver(this);
    _initForegroundTask();

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

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'fgtracker_call_channel',
        channelName: 'FG Tracker Ongoing Call',
        channelDescription:
        'Maintains active microphone and audio in background',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
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
      log("🔄 App Foregrounded: Forcefully restoring audio routes...");
      _ensureAudioTracksActive();
    } else if (state == AppLifecycleState.paused) {
      log("⏸️ App Backgrounded: Keeping WebRTC mic tracks alive...");
      _keepTracksAliveInBackground();
    }
  }

  void _ensureAudioTracksActive() {
    try {
      if (localStream != null) {
        for (var track in localStream!.getAudioTracks()) {
          track.enabled = isAudioOn;
        }
        if (isVideoCall.value && isVideoOn) {
          for (var track in localStream!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }
      if (remoteRenderer.srcObject != null) {
        for (var track in remoteRenderer.srcObject!.getAudioTracks()) {
          track.enabled = true;
        }
        if (isVideoCall.value) {
          for (var track in remoteRenderer.srcObject!.getVideoTracks()) {
            track.enabled = true;
          }
        }
      }

      _setRoute(currentAudioRoute.value);
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
      await setDefaultAudioRouteForCallType(isVideo: true);

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
      Get.snackbar(
          "Call Failed", data?['message']?.toString() ?? "Unable to make call");
    });

    socket?.on("callBlocked", (data) {
      log("CALL BLOCKED => $data");
      stopSound();
      _clearTimers();
      resetPeer();
      if (Get.isOverlaysOpen) {
        Get.back();
      }
      Get.snackbar(
          "Call unavailable",
          data?['message']?.toString() ??
              "Communication is not available with this user");
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

        await peer!.setRemoteDescription(
            RTCSessionDescription(sdp["sdp"], sdp["type"]));
        final answer = await peer!.createAnswer();
        await peer!.setLocalDescription(answer);

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
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        'googEchoCancellation': true,
        'googAutoGainControl': true,
        'googNoiseSuppression': true,
        'googHighpassFilter': true,
      },
      'video': is_video == true
          ? {'facingMode': isFrontCamera ? 'user' : 'environment'}
          : false,
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
      await peer!.setRemoteDescription(
          RTCSessionDescription(offer["sdp"], offer["type"]));
      final answer = await peer!.createAnswer();
      await peer!.setLocalDescription(answer);

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
      peer!.onIceCandidate = (c) => iceCandidates.add(c);

      socket!.on("callAnswered", (data) async {
        await peer!.setRemoteDescription(
          RTCSessionDescription(
              data["sdpAnswer"]["sdp"], data["sdpAnswer"]["type"]),
        );

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

        peer!.onIceCandidate = (c) {
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
    await _stopForegroundCallService();

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


  Future<void> _setRoute(String route) {
    _routeQueue = _routeQueue.then((_) => _applyRoute(route)).catchError((e) {
      log("Audio route '$route' failed: $e");
    });
    return _routeQueue;
  }

  Future<void> _applyRoute(String route) async {
    log("🔈 Applying audio route => $route");


    if (route == "earpiece" && isWiredHeadsetConnected.value) {
      route = "wired";
    }

    switch (route) {
      case "speaker":
        await _selectOutput("speaker", _speakerDeviceId);
        break;
      case "bluetooth":
        await _selectOutput("bluetooth", _bluetoothDeviceId);
        break;
      case "wired":
        await _selectOutput("wired", _wiredDeviceId);
        break;
      case "earpiece":
      default:
        route = "earpiece";
        await _selectOutput("earpiece", _earpieceDeviceId);
        break;
    }

    isSpeakerOn = route == "speaker";
    currentAudioRoute.value = route;

    await ProximityScreenLock.setActive(
      route == "earpiece" && !isVideoCall.value,
    );

    update();
  }

  Future<void> _selectOutput(String route, String? deviceId) async {
    if (Platform.isIOS) {
      if (route == "speaker") {
        await Helper.setSpeakerphoneOn(true);
      } else if (route == "bluetooth") {
        await Helper.setSpeakerphoneOnButPreferBluetooth();
      } else {
        await Helper.setSpeakerphoneOn(false);
      }
      return;
    }

    const fallbackIds = {
      "speaker": "speaker",
      "bluetooth": "bluetooth",
      "wired": "wired-headset",
      "earpiece": "earpiece",
    };

    await Helper.selectAudioOutput(deviceId ?? fallbackIds[route]!);


    if (route == "speaker") {
      await Helper.setSpeakerphoneOn(true);
    }
  }

  Future<void> selectEarpiece() => _setRoute("earpiece");

  Future<void> enableSpeaker() => _setRoute("speaker");

  Future<void> selectBluetooth() => _setRoute("bluetooth");

  Future<void> selectWired() => _setRoute("wired");

  Future<void> toggleSpeaker(BuildContext context) async {
    showAudioRoutePicker(context);
  }

  void showAudioRoutePicker(BuildContext context) async {
    await checkAudioDevices();
    if (!context.mounted) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    double calculatedOffsetHeight = 95.h;
    if (isBluetoothConnected.value) calculatedOffsetHeight += 35.h;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(
        offset.dx,
        offset.dy - calculatedOffsetHeight,
        renderBox.size.width,
        renderBox.size.height,
      ),
      Offset.zero & MediaQuery.of(context).size,
    );

    const Color primaryPurple = Color(0xFF7B58FF);

    final String? selectedRoute = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: primaryPurple.withOpacity(0.12),
          width: 0.8,
        ),
      ),
      constraints: BoxConstraints(
        minWidth: 110.w,
        maxWidth: 135.w,
      ),
      items: [
        if (!isWiredHeadsetConnected.value)
          PopupMenuItem<String>(
            value: "earpiece",
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildRouteRow(
              icon: Icons.phone_in_talk_rounded,
              label: "Earpiece",
              routeKey: "earpiece",
            ),
          ),
        if (isWiredHeadsetConnected.value)
          PopupMenuItem<String>(
            value: "wired",
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildRouteRow(
              icon: Icons.headset_rounded,
              label: "Headphones",
              routeKey: "wired",
            ),
          ),
        PopupMenuItem<String>(
          value: "speaker",
          height: 35.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: _buildRouteRow(
            icon: Icons.volume_up_rounded,
            label: "Speaker",
            routeKey: "speaker",
          ),
        ),
        if (isBluetoothConnected.value)
          PopupMenuItem<String>(
            value: "bluetooth",
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildRouteRow(
              icon: Icons.bluetooth_audio_rounded,
              label: "Bluetooth",
              routeKey: "bluetooth",
            ),
          ),
      ],
    );

    if (selectedRoute != null) {
      await _setRoute(selectedRoute);
    }
  }

  Widget _buildRouteRow({
    required IconData icon,
    required String label,
    required String routeKey,
  }) {
    final bool isSelected = currentAudioRoute.value == routeKey;
    const Color primaryPurple = Color(0xFF7B58FF);
    const Color darkText = Color(0xFF0F0B4C);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? primaryPurple : darkText.withOpacity(0.6),
          size: 15.sp,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primaryPurple : darkText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          isSelected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off_rounded,
          color: isSelected ? primaryPurple : darkText.withOpacity(0.2),
          size: 13.sp,
        ),
      ],
    );
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
    if (!isBluetoothConnected.value && !isWiredHeadsetConnected.value) {
      await ProximityScreenLock.setActive(true);
    }
  }

  Future<void> setDefaultAudioRouteForCallType({
    required bool isVideo,
  }) async {
    await checkAudioDevices();

    if (isBluetoothConnected.value) {
      await selectBluetooth();
    } else if (isWiredHeadsetConnected.value) {
      await selectWired();
    } else if (isVideo) {
      await enableSpeaker();
    } else {
      await selectEarpiece();
    }

    update();
  }

  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);
  }

  void _startDeviceMonitoring() {
    checkAudioDevices();

    navigator.mediaDevices.ondevicechange = (event) {
      log("🔄 Audio Routing Device Change Event Fired!");
      checkAudioDevices();
    };

    _deviceCheckTimer?.cancel();
    _deviceCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkAudioDevices();
    });
  }

  bool _isBluetoothLabel(String label) {
    return label.contains('bluetooth') ||
        label.contains('blue') ||
        label.contains('buds') ||
        label.contains('airpods') ||
        label.contains('hands-free') ||
        label.contains('handsfree') ||
        label.contains('hearing aid') ||
        label.contains('a2dp');
  }

  bool _isWiredLabel(String label) {
    return label.contains('wired') ||
        label.contains('headphone') ||
        label.contains('jack') ||
        label.contains('aux') ||
        label.contains('usb') ||
        label.contains('headset');
  }

  String? _classifyOutput(String id, String label) {
    final String i = id.toLowerCase();
    final String l = label.toLowerCase();

    if (i == 'bluetooth') return 'bluetooth';
    if (i == 'wired-headset' || i == 'wired_headset') return 'wired';
    if (i == 'speaker' || i == 'speakerphone') return 'speaker';
    if (i == 'earpiece') return 'earpiece';

    if (_isBluetoothLabel(l)) return 'bluetooth';
    if (_isWiredLabel(l)) return 'wired';
    if (l.contains('speaker') || l == 'default') return 'speaker';
    if (l.contains('earpiece') ||
        l.contains('receiver') ||
        l.contains('handset') ||
        l.contains('telephony')) {
      return 'earpiece';
    }
    return null;
  }

  Future<void> checkAudioDevices() {
    return _deviceCheck ??=
        _checkAudioDevices().whenComplete(() => _deviceCheck = null);
  }

  Future<void> _checkAudioDevices() async {
    try {
      final List<MediaDeviceInfo> devices =
      await navigator.mediaDevices.enumerateDevices();
      bool isBtFound = false;
      bool isWiredFound = false;

      String? earId;
      String? spkId;
      String? btId;
      String? wiredId;

      for (var device in devices) {
        if (device.kind != 'audiooutput') continue;

        final String id = device.deviceId;
        log("Audio Peripheral Checked - Label: ${device.label} | id: $id");

        switch (_classifyOutput(id, device.label)) {
          case 'bluetooth':
            isBtFound = true;
            btId ??= id;
            break;
          case 'wired':
            isWiredFound = true;
            wiredId ??= id;
            break;
          case 'speaker':
            spkId ??= id;
            break;
          case 'earpiece':
            earId ??= id;
            break;
          default:
            break;
        }
      }

      _earpieceDeviceId = earId;
      _speakerDeviceId = spkId;
      _bluetoothDeviceId = btId;
      _wiredDeviceId = wiredId;

      final bool wasBtConnected = isBluetoothConnected.value;
      final bool wasWiredConnected = isWiredHeadsetConnected.value;

      isBluetoothConnected.value = isBtFound;
      isWiredHeadsetConnected.value = isWiredFound;

      final bool btPlugged = isBtFound && !wasBtConnected;
      final bool wiredPlugged = isWiredFound && !wasWiredConnected;
      final bool btUnplugged = !isBtFound && wasBtConnected;
      final bool wiredUnplugged = !isWiredFound && wasWiredConnected;

      if (btPlugged) {
        await selectBluetooth();
      } else if (wiredPlugged) {
        await selectWired();
      } else if (btUnplugged && currentAudioRoute.value == "bluetooth") {
        if (isWiredFound) {
          await selectWired();
        } else if (isVideoCall.value) {
          await enableSpeaker();
        } else {
          await selectEarpiece();
        }
      } else if (wiredUnplugged && currentAudioRoute.value == "wired") {
        if (isBtFound) {
          await selectBluetooth();
        } else if (isVideoCall.value) {
          await enableSpeaker();
        } else {
          await selectEarpiece();
        }
      }

      update();
    } catch (e) {
      log("checkAudioDevices error: $e");
    }
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
    final Offset currentPosition = pipPosition ??
        Offset(
          minLeft,
          maxTop,
        );

    final double boundedMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;
    final double boundedMaxTop = maxTop < minTop ? minTop : maxTop;

    pipPosition = Offset(
      (currentPosition.dx + delta.dx).clamp(
        minLeft,
        boundedMaxLeft,
      ),
      (currentPosition.dy + delta.dy).clamp(
        minTop,
        boundedMaxTop,
      ),
    );

    update();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopForegroundCallService();

    _controlsTimer?.cancel();
    _deviceCheckTimer?.cancel();
    navigator.mediaDevices.ondevicechange = null;
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