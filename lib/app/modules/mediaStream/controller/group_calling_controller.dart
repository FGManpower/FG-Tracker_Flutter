import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart' as prefix0;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Core/values/utility.dart';
import '../../../Model/group_call_participant.dart';
import '../../../Data/Services/Socket/Socket_SignallingService.dart';
import '../Widget/group_call_sheets.dart';
import '../../../routes/app_pages.dart';

class GroupCallingController extends GetxController {
  final socket = SignallingService.instance.socket;
  final args = Get.arguments;

  late String groupId;
  late String groupName;
  String? groupProfile;
  late bool isVideo;
  int totalMemberCount = 0;
  String callType = "outgoing";

  String? callId;
  RxString callStatus = "Calling".obs;
  Timer? callTimer;
  RxInt callDurationSeconds = 0.obs;

  RxBool isAudioOn = true.obs;
  RxBool isVideoOn = true.obs;
  RxBool isSpeakerOn = false.obs;
  RxBool isFrontCamera = true.obs;

  RxList<GroupCallParticipant> activeParticipants = <GroupCallParticipant>[].obs;
  RxList<GroupCallParticipant> notInCallParticipants = <GroupCallParticipant>[].obs;

  MediaStream? localStream;
  RxBool isLocalRendererReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
    _setupUIAndMockParticipants();
    _setupLocalMedia();
    _listenForGroupSocketEvents();

    WakelockPlus.enable();

    if (callType == "outgoing") {
      _playSound();
      Future.delayed(const Duration(seconds: 3), () {
        _stopSound();
        callStatus.value = "Connected";
        startCallTimer();
      });
    } else {
      callStatus.value = "Connected";
      startCallTimer();
    }
  }

  void _initData() {
    groupId = args["groupId"]?.toString() ?? "";
    groupName = args["groupName"]?.toString() ?? "Unknown Group";
    groupProfile = args["groupProfile"]?.toString();
    isVideo = args["isVideo"] == true;
    totalMemberCount = args["memberCount"] ?? 0;
    callType = args["callType"]?.toString() ?? "outgoing";
    callId = args["callId"];
  }

  void _setupUIAndMockParticipants() {
    final myUserId = Global.storageServices.get(PrefConst.userId).toString();

    final localUser = GroupCallParticipant(
      userId: myUserId,
      name: "You",
      isLocal: true,
      videoOn: isVideo,
      connected: true,
    );
    activeParticipants.add(localUser);

    // TODO: Populate remote participants from backend / MemberController.
  }

  Future<void> _setupLocalMedia() async {
    try {
      final localUser = activeParticipants.firstWhereOrNull((p) => p.isLocal);
      if (localUser == null) return;

      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      localUser.renderer = renderer;

      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': isVideo
            ? {
          'facingMode': isFrontCamera.value ? 'user' : 'environment',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
        }
            : false,
      };

      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      renderer.srcObject = localStream;
      localUser.stream = localStream;

      localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn.value);
      if (isVideo) {
        localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn.value);
      }

      isLocalRendererReady.value = true;
      activeParticipants.refresh();

      log("==== Local media initialized successfully ====");
    } catch (e) {
      log("==== Error initializing local media: $e ====");
    }
  }

  void _listenForGroupSocketEvents() {
    // TODO: Integrate backend group-call socket events here.
  }


  void toggleMic() {
    isAudioOn.value = !isAudioOn.value;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isMuted.value = !isAudioOn.value;
    // TODO: Emit mute event to socket.
  }

  void toggleCamera() {
    if (!isVideo) return;
    isVideoOn.value = !isVideoOn.value;
    localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isVideoOn.value = isVideoOn.value;
    // TODO: Emit camera-toggled event to socket.
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    try {
      await Helper.setSpeakerphoneOn(isSpeakerOn.value);
    } catch (e) {
      log("Speaker toggle error: $e");
    }
    await ProximityScreenLock.setActive(!isSpeakerOn.value);
  }

  void switchCamera() {
    if (!isVideo) return;
    isFrontCamera.value = !isFrontCamera.value;
    localStream?.getVideoTracks().forEach((t) => t.switchCamera());
  }

  Future<void> endCall() async {
    _clearTimers();
    _stopSound();

    // TODO: Emit leave/end group call event to backend.

    try {
      final localUser = activeParticipants.firstWhereOrNull((p) => p.isLocal);
      localUser?.renderer?.srcObject = null;
      await localUser?.renderer?.dispose();
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
    } catch (_) {}

    await WakelockPlus.disable();
    await ProximityScreenLock.setActive(false);

    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }


  void startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDurationSeconds.value++;
    });
  }

  void _clearTimers() {
    callTimer?.cancel();
    callTimer = null;
    callDurationSeconds.value = 0;
  }

  String get formattedDuration {
    final minutes = (callDurationSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (callDurationSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _playSound() {
    FlutterRingtonePlayer().play(
      asAlarm: false,
      fromAsset: Assets.music.ringing,
      looping: true,
      volume: 1.0,
    );
  }

  void _stopSound() {
    FlutterRingtonePlayer().stop();
  }

  void openParticipantsSheet() {
    GroupParticipantsSheet.show(this as prefix0.GroupCallingController);
  }

  void openMoreOptionsSheet() {
    GroupCallMoreSheet.show(
      onShareScreen: () {
        Get.back();
        // TODO: Implement screen sharing logic.
      },
      onSendMessage: () {
        Get.back();
        // TODO: Navigate to group chat.
      },
    );
  }

  void notifyParticipant(GroupCallParticipant participant) {
    // TODO: Emit notification event to socket.
    Get.snackbar("Notified", "Sent a ring to ${participant.name}");
  }

  @override
  void onClose() {
    _clearTimers();
    _stopSound();
    try {
      final localUser = activeParticipants.firstWhereOrNull((p) => p.isLocal);
      localUser?.renderer?.srcObject = null;
      localUser?.renderer?.dispose();
      localStream?.getTracks().forEach((t) => t.stop());
      localStream?.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    super.onClose();
  }
}