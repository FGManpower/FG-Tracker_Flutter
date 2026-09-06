import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

// Replace with your actual project imports
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

class GroupCallingController extends GetxController {
  final args = Get.arguments;

  late String groupId;
  late String groupName;
  String? groupProfile;
  late bool isVideo;
  int totalMemberCount = 0;
  String callType = "outgoing";
  String? callId;

  RxString callStatus = "Calling...".obs;
  Timer? callTimer;
  RxInt callDurationSeconds = 0.obs;

  RxBool isAudioOn = true.obs;
  RxBool isVideoOn = true.obs;
  RxBool isSpeakerOn = false.obs;
  RxBool isFrontCamera = true.obs;

  RxList<GroupCallParticipant> activeParticipants = <GroupCallParticipant>[].obs;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();

  void _log(String message) {
    log('🎛[GroupCallingController] $message');
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
    WakelockPlus.enable();

    Socket_GroupCallService.instance.onParticipantsUpdated = _syncParticipants;
    Socket_GroupCallService.instance.onParticipantJoined = _onParticipantJoined;
    Socket_GroupCallService.instance.onParticipantLeft = _onParticipantLeft;
    Socket_GroupCallService.instance.onCallEnded = _onRemoteCallEnded;

    _setupLocalMedia().then((_) {
      if (callType == "outgoing") {
        _playSound();
        final myName = Global.storageServices.get(PrefConst.userName) ?? "User";

        Socket_GroupCallService.instance.startGroupCall(
          groupId: groupId,
          isVideo: isVideo,
          callerName: myName.toString(),
          callerProfileImage: "",
          onResponse: (success, generatedCallId, errorMessage) {
            if (success) {
              callId = generatedCallId;
              _log('Outgoing call registered. ID: $callId');
            } else {
              _stopSound();
              Utils().fluttertoast( errorMessage ?? "Unable to initialize group call");
              Get.back();
            }
          },
        );
      } else {
        callStatus.value = "Connecting...";
        if (callId != null) {
          Socket_GroupCallService.instance.joinGroupCall(callId!, groupId, (success) {
            if (!success) {
              Utils().fluttertoast( "Failed to connect to the call session");
              Get.back();
            }
          });
        }
      }
    }).catchError((e) {
      _log('Error setting up local media constraints: $e');
      Utils().fluttertoast( "Camera or Mic permissions are required");
      Get.back();
    });
  }

  void _initData() {
    groupId = args["groupId"]?.toString() ?? "";
    groupName = args["groupName"]?.toString() ?? "Group Call";
    groupProfile = args["groupProfile"]?.toString();
    isVideo = args["isVideo"] == true;
    totalMemberCount = args["memberCount"] ?? 0;
    callType = args["callType"]?.toString() ?? "outgoing";
    callId = args["callId"]?.toString();

    isVideoOn.value = isVideo;
  }

  Future<void> _setupLocalMedia() async {
    await localRenderer.initialize();

    final mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
        'facingMode': isFrontCamera.value ? 'user' : 'environment',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
      }
          : false,
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = stream;
    Socket_GroupCallService.instance.localStream = stream;

    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final myName = Global.storageServices.get(PrefConst.userName) ?? "You";

    activeParticipants.add(GroupCallParticipant(
      userId: myUserId,
      name: myName.toString(),
      isLocal: true,
      videoOn: isVideo,
      connected: true,
      renderer: localRenderer,
      stream: stream,
    ));
  }

  void _onParticipantJoined(String userId) {
    if (callStatus.value != "Connected") {
      _stopSound();
      callStatus.value = "Connected";
      startCallTimer();
    }
    _syncParticipants();
  }

  void _onParticipantLeft(String userId) {
    activeParticipants.removeWhere((p) => p.userId == userId);
    activeParticipants.refresh();

    // If you are the only one remaining in an outgoing/incoming call, don't auto-disconnect
    // unless all remote peers disconnect and you wish to clean up.
  }

  void _onRemoteCallEnded() {
    _clearTimers();
    _stopSound();
    if (Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  void _syncParticipants() {
    final local = activeParticipants.firstWhereOrNull((p) => p.isLocal);
    final remoteList = <GroupCallParticipant>[];

    Socket_GroupCallService.instance.remoteRenderers.forEach((userId, renderer) {
      final existing = activeParticipants.firstWhereOrNull((p) => p.userId == userId);
      if (existing != null && !existing.isLocal) {
        existing.renderer = renderer;
        existing.stream = renderer.srcObject;
        existing.isVideoOn.value = renderer.srcObject?.getVideoTracks().any((t) => t.enabled) ?? false;
        existing.isConnected.value = true;
        remoteList.add(existing);
      } else {
        remoteList.add(GroupCallParticipant(
          userId: userId,
          name: "User $userId",
          isLocal: false,
          videoOn: renderer.srcObject?.getVideoTracks().isNotEmpty ?? false,
          connected: true,
          renderer: renderer,
          stream: renderer.srcObject,
        ));
      }
    });

    activeParticipants.clear();
    if (local != null) activeParticipants.add(local);
    activeParticipants.addAll(remoteList);
    activeParticipants.refresh();

    if (remoteList.isNotEmpty && callStatus.value != "Connected") {
      _stopSound();
      callStatus.value = "Connected";
      startCallTimer();
    }
  }

  void toggleMic() {
    isAudioOn.value = !isAudioOn.value;
    Socket_GroupCallService.instance.localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isMuted.value = !isAudioOn.value;
  }

  void toggleCamera() {
    if (!isVideo) return;
    isVideoOn.value = !isVideoOn.value;
    Socket_GroupCallService.instance.localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isVideoOn.value = isVideoOn.value;
  }

  void switchCamera() {
    if (!isVideo) return;
    isFrontCamera.value = !isFrontCamera.value;
    Socket_GroupCallService.instance.localStream?.getVideoTracks().forEach((t) => t.switchCamera());
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await Helper.setSpeakerphoneOn(isSpeakerOn.value);
    await ProximityScreenLock.setActive(!isSpeakerOn.value);
  }

  Future<void> endCall() async {
    _clearTimers();
    _stopSound();

    if (callType == "outgoing") {
      Socket_GroupCallService.instance.endGroupCall();
    } else {
      Socket_GroupCallService.instance.leaveGroupCall();
    }
    Get.offAllNamed(Routes.Home_Screen);
  }

  void startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    try {
      FlutterRingtonePlayer().play(
        asAlarm: false,
        fromAsset: Assets.music.ringing,
        looping: true,
        volume: 1.0,
      );
    } catch (_) {
      try {
        FlutterRingtonePlayer().playRingtone(
          asAlarm: false,
          looping: true,
          volume: 1.0,
        );
      } catch (_) {}
    }
  }

  void _stopSound() {
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  @override
  void onClose() {
    _clearTimers();
    _stopSound();

    Socket_GroupCallService.instance.onParticipantsUpdated = null;
    Socket_GroupCallService.instance.onParticipantJoined = null;
    Socket_GroupCallService.instance.onParticipantLeft = null;
    Socket_GroupCallService.instance.onCallEnded = null;

    try {
      localRenderer.srcObject = null;
      localRenderer.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    super.onClose();
  }
}