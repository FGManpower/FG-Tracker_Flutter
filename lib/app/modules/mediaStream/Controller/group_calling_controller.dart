import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Core/util/CallKit/callkit_service.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_SignallingService.dart';
import 'package:fgtracker/app/Data/Services/screen_share_service.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import '../Widget/group_call_sheets.dart';

enum AudioRoute { speaker, earpiece, bluetooth }

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

  final Rx<AudioRoute> audioRoute = AudioRoute.speaker.obs;
  final RxBool isBluetoothConnected = false.obs;

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

  final RxnString pinnedUserId = RxnString();
  final RxnString fullScreenShareUserId = RxnString();

  final RxBool showControls = true.obs;
  Timer? _controlsTimer;








  @override
  void onInit() {
    super.onInit();

    // Already running (user returned from PiP) → just refresh UI bindings
    if (callId != null && activeParticipants.isNotEmpty && callType == 'ongoing') {
      WakelockPlus.enable();
      resetControlsTimer();
      return;
    }

    _initData();
    WakelockPlus.enable();

    resetControlsTimer();

    final svc = Socket_GroupCallService.instance;
    svc.onParticipantsUpdated = _syncParticipants;
    svc.onParticipantJoined = _onParticipantJoined;
    svc.onParticipantLeft = _onParticipantLeft;
    svc.onCallEnded = _onRemoteCallEnded;
    svc.onParticipantRejected = _onParticipantRejected;
    svc.onParticipantMuteChanged = _onParticipantMuteChanged;
    svc.onParticipantCameraChanged = _onParticipantCameraChanged;

    svc.onScreenShareStarted = (userId) {
      screenSharingUsers.add(userId);
      pinnedUserId.value = userId;
      Utils()
          .fluttertoast("${svc.getParticipantName(userId)} is sharing screen");
    };
    svc.onScreenShareStopped = (userId) {
      screenSharingUsers.remove(userId);
      if (pinnedUserId.value == userId) {
        pinnedUserId.value = null;
      }
      if (fullScreenShareUserId.value == userId) {
        closeFullScreenShare();
      }
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
      Utils().fluttertoast("Camera or Mic permissions are required");
      Get.back();
    });

    getGroupMembersData(args["groupId"].toString());
  }

  void resetControlsTimer() {
    _controlsTimer?.cancel();
    if (showControls.value) {
      _controlsTimer = Timer(const Duration(seconds: 5), () {
        showControls.value = false;
      });
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    resetControlsTimer();
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

  Future<void> initAudioRouting() async {
    await _refreshBluetoothState();

    if (isBluetoothConnected.value) {
      await _applyAudioRoute(AudioRoute.bluetooth);
    } else if (isVideo) {
      await _applyAudioRoute(AudioRoute.speaker);
    } else {
      await _applyAudioRoute(AudioRoute.earpiece);
    }
  }

  Future<void> _refreshBluetoothState() async {
    try {
      final devices = await webrtc.navigator.mediaDevices.enumerateDevices();
      final hasBt = devices.any((d) {
        final label = (d.label).toLowerCase();
        final kind = (d.kind)?.toLowerCase();
        return kind!.contains('audiooutput') &&
            (label.contains('bluetooth') ||
                label.contains('headset') ||
                label.contains('airpods') ||
                label.contains('buds'));
      });
      isBluetoothConnected.value = hasBt;
    } catch (_) {}
  }

  Future<void> _applyAudioRoute(AudioRoute route) async {
    audioRoute.value = route;
    switch (route) {
      case AudioRoute.speaker:
        await webrtc.Helper.setSpeakerphoneOn(true);
        isSpeakerOn.value = true;
        await ProximityScreenLock.setActive(false);
        break;
      case AudioRoute.earpiece:
        await webrtc.Helper.setSpeakerphoneOn(false);
        isSpeakerOn.value = false;
        await ProximityScreenLock.setActive(true);
        break;
      case AudioRoute.bluetooth:
        await webrtc.Helper.setSpeakerphoneOn(false);
        isSpeakerOn.value = false;
        await ProximityScreenLock.setActive(false);
        break;
    }
  }

  Future<void> toggleSpeaker() async {
    await _refreshBluetoothState();
    final hasBt = isBluetoothConnected.value;
    final current = audioRoute.value;
    late AudioRoute next;

    if (hasBt) {
      switch (current) {
        case AudioRoute.bluetooth:
          next = AudioRoute.earpiece;
          break;
        case AudioRoute.earpiece:
          next = AudioRoute.speaker;
          break;
        case AudioRoute.speaker:
          next = AudioRoute.bluetooth;
          break;
      }
    } else {
      next = current == AudioRoute.speaker
          ? AudioRoute.earpiece
          : AudioRoute.speaker;
    }

    await _applyAudioRoute(next);
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

    // --- START BACKGROUND FOREGROUND SERVICE FOR ACTIVE CALL ---
    if (Platform.isAndroid) {
      try {
        await ScreenShareForegroundService.start(groupName: groupName);
      } catch (e) {
        log("Foreground service error: $e");
      }
    }

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
    await initAudioRouting();
  }

  void togglePinUser(String userId) {
    if (pinnedUserId.value == userId) {
      pinnedUserId.value = null;
    } else {
      pinnedUserId.value = userId;
    }
  }

  bool isUserScreenSharing(dynamic userId) {
    if (userId == null) return false;
    final targetId = userId.toString().trim();
    if (screenSharingUsers.map((e) => e.toString().trim()).contains(targetId))
      return true;
    final myUserId =
    Global.storageServices.get(PrefConst.userId)?.toString().trim();
    if (targetId == myUserId && isScreenSharing.value) return true;
    return false;
  }

  void openFullScreenShare(dynamic userId) {
    if (userId == null) return;
    final idStr = userId.toString().trim();
    if (idStr.isEmpty) return;
    fullScreenShareUserId.value = idStr;
  }

  void closeFullScreenShare() {
    fullScreenShareUserId.value = null;
  }

  Future<void> toggleScreenShare() async {
    final myUserId = Global.storageServices.get(PrefConst.userId).toString();

    if (isScreenSharing.value) {
      isScreenSharing.value = false;
      screenSharingUsers.remove(myUserId);
      Socket_GroupCallService.instance.emitStopScreenShare();

      screenStream?.getTracks().forEach((t) => t.stop());
      await screenStream?.dispose();
      screenStream = null;

      final cameraTrack = Socket_GroupCallService.instance.localStream
          ?.getVideoTracks()
          .firstOrNull;
      if (cameraTrack != null) {
        await Socket_GroupCallService.instance.replaceVideoTrack(cameraTrack);
        localRenderer.srcObject = Socket_GroupCallService.instance.localStream;
        if (!isVideoOn.value) cameraTrack.enabled = false;
      }

      if (pinnedUserId.value == myUserId) pinnedUserId.value = null;
      if (fullScreenShareUserId.value == myUserId) closeFullScreenShare();
    } else {
      try {
        final constraints = webrtc.WebRTC.platformIsIOS
            ? {
          'video': {
            'deviceId': 'broadcast',
          },
        }
            : {
          'video': true,
          'audio': false,
        };

        screenStream =
        await webrtc.navigator.mediaDevices.getDisplayMedia(constraints);

        if (screenStream == null || screenStream!.getVideoTracks().isEmpty) {
          throw Exception("No screen stream captured");
        }

        final screenTrack = screenStream!.getVideoTracks().first;

        isScreenSharing.value = true;
        screenSharingUsers.add(myUserId);
        pinnedUserId.value = myUserId;

        Socket_GroupCallService.instance.emitStartScreenShare();

        screenTrack.onEnded = () {
          if (isScreenSharing.value) {
            toggleScreenShare();
          }
        };

        await Socket_GroupCallService.instance.replaceVideoTrack(screenTrack);
        localRenderer.srcObject = screenStream;
      } catch (e, stackTrace) {
        log('[ScreenShare] Error: $e', stackTrace: stackTrace);

        screenStream?.getTracks().forEach((track) => track.stop());
        await screenStream?.dispose();
        screenStream = null;

        isScreenSharing.value = false;
        screenSharingUsers.remove(myUserId);
        pinnedUserId.value = null;

        if (!e.toString().contains("Canceled") && !e.toString().contains("cancel")) {
          Utils().fluttertoast("Screen share canceled or failed");
        }
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
      Get.toNamed(Routes.groupChatScreen, arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "fromCall": true,
      });
    } catch (e) {
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
      svc.socket?.emitWithAck(
        "group_call_notify",
        {
          "callId": int.tryParse(callId!) ?? callId,
          "groupId": int.tryParse(groupId) ?? groupId,
          "userId": participant.userId,
        },
        ack: (res) {
          if (res is Map && res["success"] == false) {
            Utils().fluttertoast(res["message"]?.toString() ?? "Notify failed");
          } else {
            Utils().fluttertoast("Notified ${participant.name}");
          }
        },
      );
    } catch (e) {
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
    activeParticipants.removeWhere((p) => p.userId == userId);
    activeParticipants.refresh();
    if (pinnedUserId.value == userId) pinnedUserId.value = null;
    if (fullScreenShareUserId.value == userId) closeFullScreenShare();
    _refreshNotInCallList();
  }

  void _onParticipantRejected(
      String userId, String? userName, String? userProfile) {
    final svc = Socket_GroupCallService.instance;
    final name = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim()
        : svc.getParticipantName(userId);
    Utils().fluttertoast("$name rejected the call");
    _refreshNotInCallList();
  }

  void _onParticipantMuteChanged(String userId, bool isMuted) {
    final p = activeParticipants.firstWhereOrNull((e) => e.userId == userId);
    if (p != null) {
      p.isMuted.value = isMuted;
      activeParticipants.refresh();
    } else {
      _syncParticipants();
    }
  }

  void _onParticipantCameraChanged(String userId, bool isVideoOn) {
    final participant =
    activeParticipants.firstWhereOrNull((p) => p.userId == userId);

    if (participant != null) {
      participant.isVideoOn.value = isVideoOn;
      activeParticipants.refresh();
    }
  }



  void _onRemoteCallEnded() {
    _clearTimers();
    _stopSound();
    if (Get.currentRoute == Routes.groupCallingScreen)
      Get.offAllNamed(Routes.Home_Screen);
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
            svc.remoteCameraStates[userId] ?? existing.isVideoOn.value;
        existing.isConnected.value = true;
        remoteList.add(existing);
      } else {
        remoteList.add(
          GroupCallParticipant(
            userId: userId,
            name: name,
            profileImage: image,
            isLocal: false,
            videoOn: svc.remoteCameraStates[userId] ?? true,
            connected: true,
            renderer: renderer,
            stream: renderer.srcObject,
          )..isMuted.value = muted,
        );
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

    Socket_GroupCallService.instance.emitCameraChange(
      isVideoOn: isVideoOn.value,
    );
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
      }
    } catch (e) {
      Utils().fluttertoast("Unable to switch camera");
    }
  }

  Future<void> endCall() async {
    try {
      if (PictureInPicture.isActive) {
        PictureInPicture.stopPiP();
      }
    } catch (_) {}

    _clearTimers();
    _stopSound();

    if (Platform.isAndroid) {
      try {
        await ScreenShareForegroundService.stop();
      } catch (_) {}
    }

    if (callType == "outgoing") {
      Socket_GroupCallService.instance.endGroupCall();
    } else {
      Socket_GroupCallService.instance.leaveGroupCall();
    }
    // ... CallKit uuid etc.

    CallSessionState.reset();

    if (Get.isRegistered<GroupCallingController>()) {
      Get.delete<GroupCallingController>(force: true);
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
    _controlsTimer?.cancel();
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

  @override
  void onClose() {
    if (PictureInPicture.isActive) {
      super.onClose();
      return;
    }
    _clearTimers();
    _stopSound();

    if (Platform.isAndroid) {
      try {
        ScreenShareForegroundService.stop();
      } catch (_) {}
    }

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
    svc.onParticipantCameraChanged = null;
    try {
      localRenderer.srcObject = null;
      localRenderer.dispose();
    } catch (_) {}
    // inside endCall(), after cleanup:
    if (Get.isRegistered<GroupCallingController>()) {
      Get.delete<GroupCallingController>(force: true);
    }
    WakelockPlus.disable();
    ProximityScreenLock.setActive(false);
    CallSessionState.reset();
    super.onClose();
  }
}