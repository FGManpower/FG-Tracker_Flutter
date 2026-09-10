import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

import 'package:fgtracker/gen/assets.gen.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import '../Widget/group_call_sheets.dart';

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

  final RxList<GroupCallParticipant> allGroupMembers = <GroupCallParticipant>[].obs;

  final RxList<GroupCallParticipant> notInCallParticipants = <GroupCallParticipant>[].obs;

  RTCVideoRenderer localRenderer = RTCVideoRenderer();

  void _log(String message) => log('[GroupCallingController] $message');

  @override
  void onInit() {
    super.onInit();
    _initData();
    WakelockPlus.enable();

    final svc = Socket_GroupCallService.instance;
    svc.onParticipantsUpdated = _syncParticipants;
    svc.onParticipantJoined = _onParticipantJoined;
    svc.onParticipantLeft = _onParticipantLeft;
    svc.onCallEnded = _onRemoteCallEnded;
    svc.onParticipantRejected = _onParticipantRejected;
    svc.onParticipantMuteChanged = _onParticipantMuteChanged;

    _setupLocalMedia().then((_) {
      if (callType == "outgoing") {
        _playSound();
        final myName = Global.storageServices.get(PrefConst.userName) ?? "User";
        final myImage =
            Global.storageServices.get(PrefConst.profileImage)?.toString() ?? "";

        svc.startGroupCall(
          groupId: groupId,
          isVideo: isVideo,
          callerName: myName.toString(),
          callerProfileImage: myImage,
          onResponse: (success, generatedCallId, errorMessage) {
            if (success) {
              callId = generatedCallId;
              _log('Call started. callId=$callId');
            } else {
              _stopSound();
              Utils().fluttertoast(
                  errorMessage ?? "Unable to initialize group call");
              Get.back();
            }
          },
        );
      } else {
        callStatus.value = "Connecting...";
        if (callId != null) {
          svc.joinGroupCall(callId!, groupId, (success) {
            if (!success) {
              _stopSound();
              Utils().fluttertoast("Failed to connect to the call session");
              Get.back();
            } else {
              _syncParticipants();
            }
          });
        }
      }
    }).catchError((e) {
      _log('Local media error: $e');
      Utils().fluttertoast("Camera or Mic permissions are required");
      Get.back();
    });
  }

  void _initData() {
    groupId = args["groupId"]?.toString() ?? "";
    groupName = args["groupName"]?.toString() ?? "Group Call";
    groupProfile = args["groupProfile"]?.toString();
    isVideo = args["isVideo"] == true;
    totalMemberCount = args["memberCount"] ?? args["totalMemberCount"] ?? 0;
    callType = args["callType"]?.toString() ?? "outgoing";
    callId = args["callId"]?.toString();
    isVideoOn.value = isVideo;

    final callerId = args["callerId"]?.toString();
    final callerName = args["callerName"]?.toString();
    final callerImage =
    (args["callerProfileImage"] ?? args["groupProfile"])?.toString();
    if (callerId != null && callerId.isNotEmpty) {
      Socket_GroupCallService.instance.participantMeta[callerId] = {
        "name": callerName ?? "Someone",
        "profileImage": callerImage ?? "",
        "isMuted": false,
      };
    }

    final membersArg =
        args["groupMembers"] ?? args["members"] ?? args["participants"];
    final List<GroupCallParticipant> seeded = [];

    if (membersArg is List) {
      for (final m in membersArg) {
        if (m is! Map) continue;
        final uid =
        (m["userId"] ?? m["UserId"] ?? m["id"])?.toString();
        if (uid == null || uid.isEmpty) continue;

        final uName =
        (m["name"] ?? m["Name"] ?? m["userName"] ?? "User $uid").toString();
        final uImg = (m["profileImage"] ??
            m["ProfileImage"] ??
            m["userProfileImage"] ??
            m["image"] ??
            "")
            .toString();

        Socket_GroupCallService.instance.participantMeta[uid] = {
          "name": uName,
          "profileImage": uImg,
          "isMuted": false,
        };

        seeded.add(GroupCallParticipant(
          userId: uid,
          name: uName,
          profileImage: uImg.isEmpty ? null : uImg,
          isLocal: false,
          videoOn: false,
          connected: false,
        ));
      }
    }

    Socket_GroupCallService.instance.participantMeta.forEach((uid, meta) {
      if (seeded.any((e) => e.userId == uid)) return;
      seeded.add(GroupCallParticipant(
        userId: uid,
        name: (meta["name"] ?? "User $uid").toString(),
        profileImage: meta["profileImage"]?.toString(),
        isLocal: false,
        videoOn: false,
        connected: false,
      ));
    });

    allGroupMembers.assignAll(seeded);
    if (totalMemberCount <= 0) {
      totalMemberCount = allGroupMembers.length;
    }
    _refreshNotInCallList();
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
    final myImage =
    Global.storageServices.get(PrefConst.profileImage)?.toString();

    activeParticipants.add(GroupCallParticipant(
      userId: myUserId,
      name: myName.toString(),
      profileImage: myImage,
      isLocal: true,
      videoOn: isVideo,
      connected: true,
      renderer: localRenderer,
      stream: stream,
    ));

    if (!allGroupMembers.any((e) => e.userId == myUserId)) {
      allGroupMembers.add(GroupCallParticipant(
        userId: myUserId,
        name: myName.toString(),
        profileImage: myImage,
        isLocal: true,
        videoOn: isVideo,
        connected: true,
      ));
    }

    _refreshNotInCallList();
  }

  void openParticipantsSheet() {
    _refreshNotInCallList();
    GroupParticipantsSheet.show(this);
  }

  void openMoreSheet() {
    GroupCallMoreSheet.show(
      onShareScreen: () {
        Get.back();
        Utils().fluttertoast("Screen share coming soon");

      },
      onSendMessage: () {
        Get.back();
        _openGroupChat();
      },
    );
  }

  void _openGroupChat() {

    try {
      Get.toNamed(
        Routes.groupChatScreen,
        arguments: {
          "groupId": groupId,
          "groupName": groupName,
          "groupProfile": groupProfile,
          "fromCall": true,
        },
      );
    } catch (e) {
      _log("Chat route failed: $e");
      Utils().fluttertoast("Unable to open group chat");
    }
  }

  void notifyParticipant(GroupCallParticipant participant) {
    final svc = Socket_GroupCallService.instance;

    if (callId == null || callId!.isEmpty) {
      Utils().fluttertoast("Call not ready yet");
      return;
    }

    try {
      var param ={
        "callId": int.tryParse(callId!) ?? callId,
        "groupId": int.tryParse(groupId) ?? groupId,
        // "targetUserId": participant.userId,
        "userId": participant.userId,
        // "userId": Global.storageServices.get(PrefConst.userId),

      };

      print("=======notifyParam:${param}");
      svc.socket?.emitWithAck(
        "group_call_notify",
       param,
        ack: (res) {
          _log("group_call_notify ACK: $res");
          if (res is Map && res["success"] == false) {
            Utils().fluttertoast(res["message"]?.toString() ?? "Notify failed");
          } else {
            Utils().fluttertoast("Notified ${participant.name}");
          }
        },
      );
    } catch (e) {
      _log("notify emit error: $e");
      Utils().fluttertoast("Notified ${participant.name}");
    }
  }

  void _refreshNotInCallList() {
    final activeIds = activeParticipants.map((e) => e.userId).toSet();

    Socket_GroupCallService.instance.participantMeta.forEach((uid, meta) {
      final idx = allGroupMembers.indexWhere((e) => e.userId == uid);
      final name = (meta["name"] ?? "User $uid").toString();
      final image = meta["profileImage"]?.toString();
      if (idx >= 0) {
        allGroupMembers[idx].name = name;
        allGroupMembers[idx].profileImage = image;
      } else {
        allGroupMembers.add(GroupCallParticipant(
          userId: uid,
          name: name,
          profileImage: image,
          isLocal: false,
          videoOn: false,
          connected: false,
        ));
      }
    });

    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();

    final notIn = allGroupMembers.where((m) {
      if (m.userId == myUserId) return false;
      return !activeIds.contains(m.userId);
    }).toList();

    notInCallParticipants.assignAll(notIn);
  }

  void _onParticipantJoined(String userId) {
    _log('joined: $userId');

    final svc = Socket_GroupCallService.instance;
    if (!allGroupMembers.any((e) => e.userId == userId)) {
      allGroupMembers.add(GroupCallParticipant(
        userId: userId,
        name: svc.getParticipantName(userId),
        profileImage: svc.getParticipantProfileImage(userId),
        isLocal: false,
        videoOn: false,
        connected: true,
      ));
    }

    if (callStatus.value != "Connected") {
      _stopSound();
      callStatus.value = "Connected";
      startCallTimer();
    }
    _syncParticipants();
  }

  void _onParticipantLeft(String userId) {
    _log('left: $userId');
    activeParticipants.removeWhere((p) => p.userId == userId);
    activeParticipants.refresh();
    _refreshNotInCallList();
  }

  void _onParticipantRejected(String userId) {
    final name = Socket_GroupCallService.instance.getParticipantName(userId);
    Utils().fluttertoast("$name rejected the call");
    _refreshNotInCallList();
  }

  void _onParticipantMuteChanged(String userId, bool isMuted) {
    _log('mute changed user=$userId muted=$isMuted');
    final p = activeParticipants.firstWhereOrNull((e) => e.userId == userId);
    if (p != null) {
      p.isMuted.value = isMuted;
      activeParticipants.refresh();
    } else {
      _syncParticipants();
    }
  }

  void _onRemoteCallEnded() {
    _clearTimers();
    _stopSound();
    if (Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  void _syncParticipants() {
    final svc = Socket_GroupCallService.instance;
    final local = activeParticipants.firstWhereOrNull((p) => p.isLocal);
    final remoteList = <GroupCallParticipant>[];

    svc.remoteRenderers.forEach((userId, renderer) {
      final existing =
      activeParticipants.firstWhereOrNull((p) => p.userId == userId);

      final name = svc.getParticipantName(userId);
      final image = svc.getParticipantProfileImage(userId);
      final muted = svc.getParticipantMuted(userId);

      if (existing != null && !existing.isLocal) {
        existing.name = name;
        existing.profileImage = image;
        existing.renderer = renderer;
        existing.stream = renderer.srcObject;
        existing.isMuted.value = muted;
        existing.isVideoOn.value =
            renderer.srcObject?.getVideoTracks().any((t) => t.enabled) ?? false;
        existing.isConnected.value = true;
        remoteList.add(existing);
      } else {
        remoteList.add(GroupCallParticipant(
          userId: userId,
          name: name,
          profileImage: image,
          isLocal: false,
          videoOn: renderer.srcObject?.getVideoTracks().isNotEmpty ?? false,
          connected: true,
          renderer: renderer,
          stream: renderer.srcObject,
        )..isMuted.value = muted);
      }
    });

    activeParticipants
      ..clear()
      ..addAll([
        if (local != null) local,
        ...remoteList,
      ])
      ..refresh();

    _refreshNotInCallList();

    if (remoteList.isNotEmpty && callStatus.value != "Connected") {
      _stopSound();
      callStatus.value = "Connected";
      startCallTimer();
    }
  }

  void toggleMic() {
    isAudioOn.value = !isAudioOn.value;
    final muted = !isAudioOn.value;

    Socket_GroupCallService.instance.localStream
        ?.getAudioTracks()
        .forEach((t) => t.enabled = isAudioOn.value);

    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isMuted.value =
        muted;

    Socket_GroupCallService.instance.emitMute(isMuted: muted);
  }

  void toggleCamera() {
    if (!isVideo) return;
    isVideoOn.value = !isVideoOn.value;
    Socket_GroupCallService.instance.localStream
        ?.getVideoTracks()
        .forEach((t) => t.enabled = isVideoOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isVideoOn.value =
        isVideoOn.value;
  }

  void switchCamera() {
    if (!isVideo) return;
    isFrontCamera.value = !isFrontCamera.value;
    Socket_GroupCallService.instance.localStream
        ?.getVideoTracks()
        .forEach((t) => t.switchCamera());
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
    CallSessionState.reset();
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
    final m = (callDurationSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (callDurationSeconds.value % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _playSound() {
    // try {
    //   FlutterRingtonePlayer().play(
    //     asAlarm: false,
    //     fromAsset: Assets.music.ringing,
    //     looping: true,
    //     volume: 1.0,
    //   );
    // } catch (_) {
    //   try {
    //     FlutterRingtonePlayer().playRingtone(
    //       asAlarm: false,
    //       looping: true,
    //       volume: 1.0,
    //     );
    //   } catch (_) {}
    // }
  }

  void _stopSound() {
    try {
      // FlutterRingtonePlayer().stop();
    } catch (_) {}
  }

  @override
  void onClose() {
    _clearTimers();
    _stopSound();

    final svc = Socket_GroupCallService.instance;
    svc.onParticipantsUpdated = null;
    svc.onParticipantJoined = null;
    svc.onParticipantLeft = null;
    svc.onCallEnded = null;
    svc.onParticipantRejected = null;
    svc.onParticipantMuteChanged = null;

    try {
      localRenderer.srcObject = null;
      localRenderer.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    super.onClose();
  }
}