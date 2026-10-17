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
import 'package:fgtracker/app/modules/mediaStream/Controller/call_audio_route_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/groupCallMore_Sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import '../Widget/audio_route_sheet.dart';
import '../Widget/group_call_sheets.dart';

class GroupCallingController extends GetxController {
  final args = Get.arguments;
  final RxInt participantsUiTick = 0.obs;

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
  RxBool isFrontCamera = true.obs;

  RxBool isScreenSharing = false.obs;
  webrtc.MediaStream? screenStream;
  final RxSet<String> screenSharingUsers = <String>{}.obs;

  RxBool memberDataLoading = false.obs;
  var memberData = <MemberData>[].obs;
  var responseError = "".obs;

  RxList<GroupCallParticipant> activeParticipants = <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> allGroupMembers = <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> notInCallParticipants = <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> sheetInCallParticipants = <GroupCallParticipant>[].obs;
  webrtc.RTCVideoRenderer localRenderer = webrtc.RTCVideoRenderer();

  final RxnString pinnedUserId = RxnString();
  final RxnString fullScreenShareUserId = RxnString();

  final RxBool showControls = true.obs;
  Timer? _controlsTimer;

  void _log(String message) => log('[GroupCallingController] $message');

  late final CallAudioRouteController audioRouteController;
  late final String _audioRouteTag;
  Worker? _routeWorker;
  final Set<String> _groupMemberIds = <String>{};

  // MAXIMUM ALLOWED VIDEO STREAMS IN THE GROUP
  static const int maxAllowedVideos = 4;

  @override
  void onInit() {
    super.onInit();

    _audioRouteTag = "group_call_audio_${callId ?? DateTime.now().microsecondsSinceEpoch}";

    audioRouteController = Get.put(
      CallAudioRouteController(),
      tag: _audioRouteTag,
    );

    _routeWorker = ever<CallAudioRoute>(
      audioRouteController.currentRoute,
          (_) => _updateProximitySensor(),
    );

    if (callId != null && activeParticipants.isNotEmpty && callType == 'ongoing') {
      WakelockPlus.enable();
      resetControlsTimer();
      _updateProximitySensor();
      return;
    }

    _initData();
    WakelockPlus.enable();
    resetControlsTimer();
    _bindServiceCallbacks();

    final svc = Socket_GroupCallService.instance;

    if (callType == "outgoing") {
      _playSound();
      final myName = Global.storageServices.get(PrefConst.userName) ?? "User";
      final myImage = Global.storageServices.get(PrefConst.profileImage)?.toString() ?? "";

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
            Utils().fluttertoast(errorMessage ?? "Unable to initialize group call");
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

    _setupLocalMedia().then((_) async {
      await Socket_GroupCallService.instance.onLocalStreamReady();
    }).catchError((e) {
      Utils().fluttertoast("Camera or Mic permissions are required");
      Get.back();
    });

    getGroupMembersData(args["groupId"].toString());
  }

  void _bindServiceCallbacks() {
    final svc = Socket_GroupCallService.instance;

    // Trigger sync when remote stream arrives or participant list updates
    svc.onParticipantsUpdated = _syncParticipants;
    svc.onParticipantJoined = _onParticipantJoined;
    svc.onParticipantLeft = _onParticipantLeft;
    svc.onCallEnded = _onRemoteCallEnded;
    svc.onParticipantRejected = _onParticipantRejected;
    svc.onParticipantMuteChanged = _onParticipantMuteChanged;
    svc.onParticipantCameraChanged = (uid, state) => _syncParticipants();
    svc.onParticipantsRosterUpdated = _onParticipantsRosterUpdated;

    svc.onScreenShareStarted = (userId) {
      screenSharingUsers.add(userId);
      pinnedUserId.value = userId;
      Utils().fluttertoast("${svc.getParticipantName(userId)} is sharing screen");
    };
    svc.onScreenShareStopped = (userId) {
      screenSharingUsers.remove(userId);
      if (pinnedUserId.value == userId) pinnedUserId.value = null;
      if (fullScreenShareUserId.value == userId) closeFullScreenShare();
    };
  }

  void _updateProximitySensor({bool forceDisable = false}) {
    if (forceDisable) {
      ProximityScreenLock.setActive(false);
      return;
    }
    bool isCallRoute = Get.currentRoute == Routes.groupCallingScreen;
    bool shouldEnable = !isVideo &&
        audioRouteController.currentRoute.value == CallAudioRoute.earpiece &&
        isCallRoute;
    ProximityScreenLock.setActive(shouldEnable);
  }

  void onSheetOpened() => _updateProximitySensor(forceDisable: true);
  void onSheetClosed() => _updateProximitySensor();

  Future<void> openAudioRoutePicker(BuildContext context) async {
    if (!context.mounted) return;
    onSheetOpened();
    try {
      await audioRouteController.checkDevices();
      if (!context.mounted) return;
      final CallAudioRoute? selected = await showAudioRouteSheet(context, audioRouteController);
      if (selected != null) await audioRouteController.selectRoute(selected);
    } finally {
      onSheetClosed();
    }
  }

  void _onParticipantsRosterUpdated(List<Map<String, dynamic>> participants, int total) {
    totalMemberCount = total > 0 ? total : totalMemberCount;
    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();

    for (final p in participants) {
      final uid = p['userId']?.toString();
      if (uid == null || uid.isEmpty) continue;

      _groupMemberIds.add(uid);

      final name = (p['name'] ?? 'User $uid').toString();
      final image = p['profileImage']?.toString();

      final idx = allGroupMembers.indexWhere((e) => e.userId == uid);
      if (idx >= 0) {
        if (name.isNotEmpty) allGroupMembers[idx].name = name;
        if (image != null && image.isNotEmpty) {
          allGroupMembers[idx].profileImage = image;
        }
      } else {
        allGroupMembers.add(GroupCallParticipant(
          userId: uid,
          name: name,
          profileImage: (image == null || image.isEmpty) ? null : image,
          isLocal: uid == myUserId,
          videoOn: false,
          connected: false,
        ));
      }
    }

    _syncParticipants();

    if (callStatus.value != "Connected" && activeParticipants.any((p) => !p.isLocal)) {
      _stopSound();
      callStatus.value = "Connected";
      startCallTimer();
    }
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
    final callerImage = (args["callerProfileImage"] ?? args["groupProfile"])?.toString();

    if (callerId != null && callerId.isNotEmpty) {
      _groupMemberIds.add(callerId);
      Socket_GroupCallService.instance.participantMeta[callerId] = {
        "name": callerName ?? "Someone",
        "profileImage": callerImage ?? "",
        "isMuted": false,
      };
    }

    final membersArg = args["groupMembers"] ?? args["members"] ?? args["participants"];
    final List<GroupCallParticipant> seeded = [];

    if (membersArg is List) {
      for (final m in membersArg) {
        if (m is! Map) continue;
        final uid = (m["userId"] ?? m["UserId"] ?? m["id"])?.toString();

        if (uid == null || uid.isEmpty) continue;
        _groupMemberIds.add(uid);
        final uName = (m["name"] ?? m["userName"] ?? "User $uid").toString();
        final uImg = (m["profileImage"] ?? m["image"] ?? "").toString();

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

    allGroupMembers.assignAll(seeded);
    if (totalMemberCount <= 0) totalMemberCount = allGroupMembers.length;
    _refreshNotInCallList();
  }

  Future<void> switchCamera() async {
    if (!isVideo || !isVideoOn.value || isScreenSharing.value) return;
    try {
      final videoTrack = Socket_GroupCallService.instance.localStream?.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await webrtc.Helper.switchCamera(videoTrack);
        isFrontCamera.value = !isFrontCamera.value;
      }
    } catch (e) {
      Utils().fluttertoast("Unable to switch camera");
    }
  }

  Future<void> _setupLocalMedia() async {
    await localRenderer.initialize();
    final mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
        'facingMode': isFrontCamera.value ? 'user' : 'environment',
        'width': {'ideal': 640},
        'height': {'ideal': 480}
      }
          : false,
    };

    final stream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = stream;
    Socket_GroupCallService.instance.localStream = stream;
    Socket_GroupCallService.instance.activeVideoTrack = stream.getVideoTracks().firstOrNull;

    if (Platform.isAndroid) {
      ScreenShareForegroundService.startCallService(groupName: groupName).catchError((_) {});
    }

    final myUserId = Global.storageServices.get(PrefConst.userId).toString();
    final myName = Global.storageServices.get(PrefConst.userName) ?? "You";
    final myImage = Global.storageServices.get(PrefConst.profileImage)?.toString();

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
          connected: true));
    }
    _refreshNotInCallList();

    unawaited(
      audioRouteController.startCall(isVideo: isVideo).catchError((e) {
        _log('Audio route start error: $e');
      }),
    );
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

      if (Platform.isAndroid) {
        await ScreenShareForegroundService.startCallService(groupName: groupName);
      }

      final cameraTrack = Socket_GroupCallService.instance.localStream?.getVideoTracks().firstOrNull;
      if (cameraTrack != null) {
        await Socket_GroupCallService.instance.replaceVideoTrack(cameraTrack);
        localRenderer.srcObject = Socket_GroupCallService.instance.localStream;
        if (!isVideoOn.value) cameraTrack.enabled = false;
      }
      if (pinnedUserId.value == myUserId) pinnedUserId.value = null;
    } else {
      try {
        final constraints = webrtc.WebRTC.platformIsIOS
            ? { 'video': {'deviceId': 'broadcast'} }
            : { 'video': true, 'audio': false };

        screenStream = await webrtc.navigator.mediaDevices.getDisplayMedia(constraints);
        if (screenStream == null || screenStream!.getVideoTracks().isEmpty) {
          throw Exception("No stream");
        }

        if (Platform.isAndroid) {
          await ScreenShareForegroundService.startScreenShareService(groupName: groupName);
        }

        final screenTrack = screenStream!.getVideoTracks().first;
        isScreenSharing.value = true;
        screenSharingUsers.add(myUserId);
        pinnedUserId.value = myUserId;
        Socket_GroupCallService.instance.emitStartScreenShare();

        screenTrack.onEnded = () {
          if (isScreenSharing.value) toggleScreenShare();
        };
        await Socket_GroupCallService.instance.replaceVideoTrack(screenTrack);
        localRenderer.srcObject = screenStream;
      } catch (e) {
        screenStream?.getTracks().forEach((track) => track.stop());
        await screenStream?.dispose();
        screenStream = null;
        isScreenSharing.value = false;
        screenSharingUsers.remove(myUserId);
        if (Platform.isAndroid) {
          await ScreenShareForegroundService.startCallService(groupName: groupName);
        }
      }
    }
  }

  Future<void> toggleSpeaker(BuildContext context) async {
    showAudioRoutePicker(context);
  }

  Future<void> showAudioRoutePicker(BuildContext context) async {
    if (!context.mounted) return;
    await audioRouteController.checkDevices();
    if (!context.mounted) return;

    final CallAudioRoute? selected = await showAudioRouteSheet(context, audioRouteController);
    if (selected != null) {
      await audioRouteController.selectRoute(selected);
    }
  }

  void openParticipantsSheet() {
    onSheetOpened();
    _refreshNotInCallList();
    GroupParticipantsSheet.show(this).whenComplete(onSheetClosed);
  }

  void openMoreSheet() {
    onSheetOpened();
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
    ).then((_) => onSheetClosed());
  }

  void _openGroupChat() {
    onSheetOpened();
    try {
      Get.toNamed(Routes.groupChatScreen, arguments: {
        "groupId": groupId,
        "groupName": groupName,
        "groupProfile": groupProfile,
        "fromCall": true
      })?.then((_) => onSheetClosed());
    } catch (_) {
      onSheetClosed();
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
            _refreshNotInCallList();
          }
        },
      );
    } catch (e) {
      _log("Notified-error: ${participant.name}");
    }
  }

  void _refreshNotInCallList() {
    final svc = Socket_GroupCallService.instance;
    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();
    if (myUserId != null && myUserId.isNotEmpty) _groupMemberIds.add(myUserId);

    svc.participantMeta.forEach((uid, meta) {
      final m = allGroupMembers.firstWhereOrNull((e) => e.userId == uid);
      if (m == null) return;
      final name = meta['name']?.toString();
      final image = meta['profileImage']?.toString();
      if (name != null && name.isNotEmpty) m.name = name;
      if (image != null && image.isNotEmpty) m.profileImage = image;
    });

    _mergeMemberDataIntoGroupMembers();

    final inCallIds = <String>{...svc.connectedRemoteIds};
    if (myUserId != null && myUserId.isNotEmpty) inCallIds.add(myUserId);

    final inCallList = <GroupCallParticipant>[];
    final seenIn = <String>{};

    for (final uid in inCallIds) {
      if (!seenIn.add(uid)) continue;
      final obj = activeParticipants.firstWhereOrNull((e) => e.userId == uid) ??
          allGroupMembers.firstWhereOrNull((e) => e.userId == uid) ??
          (GroupCallParticipant(
            userId: uid,
            name: svc.getParticipantName(uid),
            profileImage: svc.getParticipantProfileImage(uid),
            isLocal: uid == myUserId,
            videoOn: svc.remoteCameraStates[uid] ?? false,
            connected: true,
          )..isMuted.value = svc.getParticipantMuted(uid));
      inCallList.add(obj);
    }
    inCallList.sort((a, b) {
      if (a.isLocal != b.isLocal) return a.isLocal ? -1 : 1;
      return (a.name ?? '').compareTo(b.name ?? '');
    });

    allGroupMembers.removeWhere((m) => !m.isLocal && !_groupMemberIds.contains(m.userId));

    final notIn = <GroupCallParticipant>[];
    final seenOut = <String>{};
    for (final m in allGroupMembers) {
      final isIn = inCallIds.contains(m.userId);
      m.isConnected.value = isIn;
      if (isIn || m.userId == myUserId) continue;
      if (!seenOut.add(m.userId)) continue;
      notIn.add(m);
    }
    notIn.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    sheetInCallParticipants.assignAll(inCallList);
    notInCallParticipants.assignAll(notIn);
    participantsUiTick.value++;
  }

  void _onParticipantJoined(String userId) {
    final svc = Socket_GroupCallService.instance;
    _groupMemberIds.add(userId);
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
    screenSharingUsers.remove(userId);
    if (pinnedUserId.value == userId) pinnedUserId.value = null;
    _syncParticipants();
  }

  void _onParticipantRejected(String userId, String? userName, String? userProfile) {
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

  void _onRemoteCallEnded() {
    _clearTimers();
    _stopSound();
    unawaited(audioRouteController.stopCall());
    if (Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  /// Syncs UI participants and safely binds WebRTC Stream track objects.
  void _syncParticipants() {
    final svc = Socket_GroupCallService.instance;
    final local = activeParticipants.firstWhereOrNull((p) => p.isLocal);
    final remoteList = <GroupCallParticipant>[];
    final seen = <String>{};

    final remoteIds = svc.connectedRemoteIds;

    for (final userId in remoteIds) {
      if (userId.isEmpty) continue;
      if (!seen.add(userId)) continue;

      final renderer = svc.remoteRenderers[userId];
      final existing = activeParticipants.firstWhereOrNull((p) => p.userId == userId);

      final name = svc.getParticipantName(userId);
      final image = svc.getParticipantProfileImage(userId);
      final muted = svc.getParticipantMuted(userId);

      // Determine camera state safely (default to track existence if unknown)
      final hasVideoTrack = renderer?.srcObject?.getVideoTracks().isNotEmpty == true;
      final remoteCamState = svc.remoteCameraStates[userId] ?? hasVideoTrack;

      if (existing != null && !existing.isLocal) {
        existing.name = name;
        existing.profileImage = image;

        // FIXED: Cache renderer and ensure srcObject stream is bound
        if (renderer != null) {
          existing.renderer = renderer;
          existing.stream = renderer.srcObject;
        }

        existing.isMuted.value = muted;
        existing.isVideoOn.value = remoteCamState;
        existing.isConnected.value = true;

        remoteList.add(existing);
      } else {
        remoteList.add(
          GroupCallParticipant(
            userId: userId,
            name: name,
            profileImage: image,
            isLocal: false,
            videoOn: remoteCamState,
            connected: true,
            renderer: renderer,
            stream: renderer?.srcObject,
          )..isMuted.value = muted,
        );
      }
    }

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
    Socket_GroupCallService.instance.localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isMuted.value = !isAudioOn.value;
    Socket_GroupCallService.instance.emitMute(isMuted: !isAudioOn.value);
  }

  void toggleCamera() {
    if (!isVideo || isScreenSharing.value) return;

    // Check 4-video limit before allowing turn ON
    if (!isVideoOn.value) {
      final activeVideoCount = activeParticipants.where((p) => p.isVideoOn.value).length;
      if (activeVideoCount >= maxAllowedVideos) {
        Utils().fluttertoast("Sorry, camera access is currently unavailable. Please try again later.");
        return;
      }
    }

    isVideoOn.value = !isVideoOn.value;
    Socket_GroupCallService.instance.localStream?.getVideoTracks().forEach((t) => t.enabled = isVideoOn.value);
    activeParticipants.firstWhereOrNull((p) => p.isLocal)?.isVideoOn.value = isVideoOn.value;
    Socket_GroupCallService.instance.emitCameraChange(isVideoOn: isVideoOn.value);

    _syncParticipants();
  }

  Future<void> _releaseLocalMedia() async {
    try {
      localRenderer.srcObject = null;
      if (screenStream != null) {
        for (final t in List.of(screenStream!.getTracks())) {
          try {
            t.enabled = false;
            await t.stop();
          } catch (_) {}
        }
        try {
          await screenStream!.dispose();
        } catch (_) {}
        screenStream = null;
      }
      isScreenSharing.value = false;
    } catch (_) {}
  }

  Future<void> endCall() async {
    _updateProximitySensor(forceDisable: true);
    _clearTimers();
    _stopSound();
    await audioRouteController.stopCall();

    await _releaseLocalMedia();

    if (callType == "outgoing") {
      Socket_GroupCallService.instance.endGroupCall();
    } else {
      Socket_GroupCallService.instance.leaveGroupCall();
    }

    if (Platform.isAndroid) {
      try {
        await ScreenShareForegroundService.stop();
      } catch (_) {}
    }

    if (callId != null) {
      callEnded(callIdToUuid(callId.toString()), type: "GroupCallEnded-Type");
    }

    CallSessionState.reset();
    if (Get.currentRoute == Routes.groupCallingScreen) {
      Get.offAllNamed(Routes.Home_Screen);
    }
  }

  void startCallTimer() {
    if (callTimer != null) return;
    callTimer = Timer.periodic(const Duration(seconds: 1), (_) => callDurationSeconds.value++);
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
        memberData.value = result.memberData ?? [];
        _mergeMemberDataIntoGroupMembers();
        _refreshNotInCallList();
      }
    } catch (_) {
    } finally {
      memberDataLoading.value = false;
    }
  }

  void _mergeMemberDataIntoGroupMembers() {
    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();
    for (final m in memberData) {
      final uid = (m.userId ?? m.id)?.toString();
      if (uid == null || uid.isEmpty) continue;

      final name = (m.name ?? 'User $uid').toString();
      final image = m.profileImage?.toString();

      final meta = Socket_GroupCallService.instance.participantMeta[uid] ?? {};
      meta['name'] = meta['name'] ?? name;
      if (image != null && image.isNotEmpty) {
        meta['profileImage'] = meta['profileImage'] ?? image;
      }
      Socket_GroupCallService.instance.participantMeta[uid] = meta;

      final idx = allGroupMembers.indexWhere((e) => e.userId == uid);
      if (idx >= 0) {
        if (allGroupMembers[idx].name!.isEmpty || allGroupMembers[idx].name!.startsWith('User ')) {
          allGroupMembers[idx].name = name;
        }
        if ((allGroupMembers[idx].profileImage == null || allGroupMembers[idx].profileImage!.isEmpty) && image != null) {
          allGroupMembers[idx].profileImage = image;
        }
      } else {
        allGroupMembers.add(GroupCallParticipant(
            userId: uid,
            name: name,
            profileImage: image,
            isLocal: uid == myUserId,
            videoOn: false,
            connected: false));
      }
    }
    allGroupMembers.refresh();
  }

  void togglePinUser(String userId) {
    if (pinnedUserId.value == userId) {
      pinnedUserId.value = null;
    } else {
      pinnedUserId.value = userId;
    }
  }

  bool isUserScreenSharing(dynamic userId) => false;
  void openFullScreenShare(dynamic userId) {}
  void closeFullScreenShare() {}

  @override
  void onClose() {
    _routeWorker?.dispose();
    _routeWorker = null;

    _updateProximitySensor(forceDisable: true);
    _clearTimers();
    _stopSound();

    unawaited(audioRouteController.stopCall());
    if (Get.isRegistered<CallAudioRouteController>(tag: _audioRouteTag)) {
      Get.delete<CallAudioRouteController>(tag: _audioRouteTag);
    }

    unawaited(_releaseLocalMedia());
    unawaited(Socket_GroupCallService.instance.cleanupCallMedia());

    if (Platform.isAndroid) {
      try {
        ScreenShareForegroundService.stop();
      } catch (_) {}
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
    svc.onParticipantsRosterUpdated = null;

    try {
      localRenderer.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    CallSessionState.reset();
    super.onClose();
  }
}