import 'dart:async';
import 'dart:developer';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/util/CallKit/callkit_service.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Services/screen_share_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';

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

  RxBool isScreenSharing = false.obs;
  webrtc.MediaStream? screenStream;
  final RxSet<String> screenSharingUsers = <String>{}.obs;

  RxBool memberDataLoading = false.obs;
  var memberData = <MemberData>[].obs;
  var responseError = "".obs;

  RxList<GroupCallParticipant> activeParticipants =
      <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> allGroupMembers =
      <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> notInCallParticipants =
      <GroupCallParticipant>[].obs;

  webrtc.RTCVideoRenderer localRenderer = webrtc.RTCVideoRenderer();

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

    svc.onScreenShareStarted = (userId) {
      screenSharingUsers.add(userId);
      Utils()
          .fluttertoast("${svc.getParticipantName(userId)} is sharing screen");
    };
    svc.onScreenShareStopped = (userId) {
      screenSharingUsers.remove(userId);
    };

    _setupLocalMedia().then((_) {
      if (callType == "outgoing") {
        _playSound();
        final myName = Global.storageServices.get(PrefConst.userName) ?? "User";
        final myImage =
            Global.storageServices.get(PrefConst.profileImage)?.toString() ??
                "";

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

    getGroupMembersData(args["groupId"].toString());
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
        final uid = (m["userId"] ?? m["UserId"] ?? m["id"])?.toString();
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

    final stream =
        await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = stream;
    Socket_GroupCallService.instance.localStream = stream;
    Socket_GroupCallService.instance.activeVideoTrack =
        stream.getVideoTracks().firstOrNull;

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

  Future<void> toggleScreenShare() async {
    final myUserId = Global.storageServices.get(PrefConst.userId).toString();

    if (isScreenSharing.value) {
      isScreenSharing.value = false;
      screenSharingUsers.remove(myUserId);
      Socket_GroupCallService.instance.emitStopScreenShare();

      await ScreenShareForegroundService.stop();

      screenStream?.getTracks().forEach((t) => t.stop());
      await screenStream?.dispose();
      screenStream = null;

      final cameraTrack = Socket_GroupCallService.instance.localStream
          ?.getVideoTracks()
          .firstOrNull;
      if (cameraTrack != null) {
        await Socket_GroupCallService.instance.replaceVideoTrack(cameraTrack);
        localRenderer.srcObject = Socket_GroupCallService.instance.localStream;
        if (!isVideoOn.value) {
          cameraTrack.enabled = false;
        }
      }

      if (fullScreenShareUserId.value == myUserId) {
        closeFullScreenShare();
      }
    } else {
      try {
        await ScreenShareForegroundService.start(groupName: groupName);
        screenStream =
            await navigator.mediaDevices.getDisplayMedia({'video': true});

        isScreenSharing.value = true;
        screenSharingUsers.add(myUserId);

        Socket_GroupCallService.instance.emitStartScreenShare();

        final screenTrack = screenStream!.getVideoTracks().first;
        screenTrack.onEnded = () {
          if (isScreenSharing.value) toggleScreenShare();
        };
        final audioTrack = Socket_GroupCallService.instance.localStream
            ?.getAudioTracks()
            .firstOrNull;
        if (audioTrack != null && isAudioOn.value) {
          audioTrack.enabled = true;
        }

        WakelockPlus.enable();

        await Socket_GroupCallService.instance.replaceVideoTrack(screenTrack);
        localRenderer.srcObject = screenStream;
      } catch (e) {
        _log("Screen Share Error: $e");

        await ScreenShareForegroundService.stop();

        isScreenSharing.value = false;
        screenSharingUsers.remove(myUserId);
        Utils().fluttertoast("Screen share canceled or failed");
      }
    }
  }

  Future<void> startWebRTCForegroundService() async {
    if (WebRTC.platformIsAndroid) {
      try {
        await WebRTC.invokeMethod('startForegroundService', <String, dynamic>{
          'notificationTitle': 'Screen Sharing',
          'notificationText': 'Sharing your screen in group call',
        });
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        log('[ScreenShare] Foreground service start error: $e');
      }
    }
  }

  Future<void> stopWebRTCForegroundService() async {
    if (WebRTC.platformIsAndroid) {
      try {
        await WebRTC.invokeMethod('stopForegroundService');
      } catch (e) {
        log('[ScreenShare] Foreground service stop error: $e');
      }
    }
  }

  void openParticipantsSheet() {
    _refreshNotInCallList();
    GroupParticipantsSheet.show(this);
  }

  void openMoreSheet() {
    GroupCallMoreSheet.show(
      isScreenSharing: isScreenSharing,
      onShareScreen: () {
        Get.back();
        toggleScreenShare();
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

  void notifyParticipant(MemberData participant) {
    final svc = Socket_GroupCallService.instance;
    if (callId == null || callId!.isEmpty) {
      Utils().fluttertoast("Call not ready yet");
      return;
    }
    try {
      svc.socket?.emitWithAck("group_call_notify", {
        "callId": int.tryParse(callId!) ?? callId,
        "groupId": int.tryParse(groupId) ?? groupId,
        "userId": participant.userId,
      }, ack: (res) {
        if (res is Map && res["success"] == false) {
          Utils().fluttertoast(res["message"]?.toString() ?? "Notify failed");
        } else {
          Utils().fluttertoast("Notified ${participant.name}");
        }
      });
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
      ..addAll([if (local != null) local, ...remoteList])
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
    if (!isVideo || isScreenSharing.value) return;
    isVideoOn.value = !isVideoOn.value;
    Socket_GroupCallService.instance.localStream
        ?.getVideoTracks()
        .forEach((t) => t.enabled = isVideoOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isVideoOn.value =
        isVideoOn.value;
  }

  Future<void> switchCamera() async {
    if (!isVideo || !isVideoOn.value || isScreenSharing.value) return;

    try {
      final videoTrack = Socket_GroupCallService.instance.localStream
          ?.getVideoTracks()
          .firstOrNull;

      if (videoTrack != null) {
        await webrtc.Helper.switchCamera(videoTrack);
        isFrontCamera.value = !isFrontCamera.value;
        _log("Switched camera. Front camera: ${isFrontCamera.value}");
      } else {
        _log("No active video track found to switch");
      }
    } catch (e) {
      _log("Error switching camera: $e");
      Utils().fluttertoast("Unable to switch camera");
    }
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

    if (callId != null) {
      callEnded(callIdToUuid(callId.toString()), type: "GroupCallEnded-Type");
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

  void _playSound() {}
  void _stopSound() {}

  Future<void> getGroupMembersData(String groupId) async {
    try {
      memberDataLoading.value = true;
      var result = await GroupRepo.getMemberData(groupId);
      if (result.status == true) {
        memberData.value = result.memberData!;
        responseError.value = "";
      } else {
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      memberDataLoading.value = false;
    }
  }


  final RxnString fullScreenShareUserId = RxnString();

  bool isUserScreenSharing(dynamic userId) {
    if (userId == null) return false;
    final targetId = userId.toString().trim();

    if (screenSharingUsers.map((e) => e.toString().trim()).contains(targetId)) {
      return true;
    }

    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString().trim();
    if (targetId == myUserId && isScreenSharing.value) {
      return true;
    }
    return false;
  }

  void openFullScreenShare(dynamic userId) {
    if (userId == null) return;
    final idStr = userId.toString().trim();
    if (idStr.isEmpty) return;
    _log("Opening full screen share for userId: $idStr");
    fullScreenShareUserId.value = idStr;
  }

  void closeFullScreenShare() {
    _log("Closing full screen share");
    fullScreenShareUserId.value = null;
  }


  @override
  void onClose() {
    _clearTimers();
    _stopSound();

    if (isScreenSharing.value) {
      screenStream?.getTracks().forEach((t) => t.stop());
      screenStream?.dispose();
    }

    final svc = Socket_GroupCallService.instance;
    svc.onParticipantsUpdated = null;
    svc.onParticipantJoined = null;
    svc.onParticipantLeft = null;
    svc.onCallEnded = null;
    svc.onParticipantRejected = null;
    svc.onParticipantMuteChanged = null;
    svc.onScreenShareStarted = null;
    svc.onScreenShareStopped = null;

    try {
      localRenderer.srcObject = null;
      localRenderer.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    CallSessionState.reset();
    super.onClose();
  }
}
