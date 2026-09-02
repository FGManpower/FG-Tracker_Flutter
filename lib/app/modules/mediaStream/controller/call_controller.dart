import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import '../../../Core/global/launchedFromCall.dart';

class CallController extends GetxController {
  static CallController get instance => Get.put(CallController());

  // Controller Dependencies
  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  final ContactService _contactService = ContactService();
  final TextEditingController searchController = TextEditingController();

  // Observable Variables (UI State)
  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString responseError = "".obs;

  // Contacts Lists
  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  // WebRTC & Call State Fields
  final RxString callStatus = "Connecting...".obs;
  final RxInt callDurationSeconds = 0.obs;
  Timer? _durationTimer;

  RTCPeerConnection? peer;
  MediaStream? localStream;
  final List<RTCIceCandidate> iceCandidates = [];
  dynamic socket;

  Map<String, dynamic> get args => Get.arguments ?? {};
  bool get fromCallKit => args["fromCallKit"] ?? false;
  dynamic get offer => args["offer"];
  dynamic get callerId => args["callerId"];
  dynamic get callId => args["callId"];
  dynamic get remoteUserId => args["remoteUserId"];
  bool get is_video => args["is_video"] ?? false;

  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCamera = true;
  bool isSpeakerOn = false;

  static const List<Map<String, String>> recentCalls = [
    {
      'name': 'Vikram Singh',
      'type': 'Outgoing Video Call',
      'time': 'Today, 10:24 AM',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Anjali Gupta',
      'type': 'Missed Audio Call',
      'time': 'Today, 09:58 AM',
      'avatar': 'https://i.pravatar.cc/150?img=45',
    },
    {
      'name': 'Karan Malhotra',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 06:45 PM',
      'avatar': 'https://i.pravatar.cc/150?img=13',
    },
    {
      'name': 'Neha Yadav',
      'type': 'Outgoing Video Call',
      'time': 'Yesterday, 05:30 PM',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
    {
      'name': 'Sandeep Yadav',
      'type': 'Incoming Audio Call',
      'time': 'Yesterday, 02:15 PM',
      'avatar': 'https://i.pravatar.cc/150?img=33',
    },
  ];

  @override
  void onClose() {
    searchController.dispose();
    searchQuery.close();
    selectedTab.close();
    contactLoading.close();
    responseError.close();
    _clearTimers();
    super.onClose();
  }

  Future<void> getRegisteredContacts() async {
    try {
      contactLoading.value = true;
      responseError.value = "";

      final contactNumbers = await _contactService.getMobileNumbers();

      if (contactNumbers.isEmpty) {
        allUserProfileData.clear();
        filteredUsers.clear();
        return;
      }

      final result = await GroupRepo.getAllUserData();

      if (result.status == true) {
        final users = result.userData ?? [];
        final contactNumberSet = contactNumbers.toSet();

        final matchedUsers = users.where((user) {
          final String mobileNo = _normalizePhone(user.mobileNo ?? '');
          return contactNumberSet.contains(mobileNo);
        }).toList();

        allUserProfileData.value = matchedUsers;
        filteredUsers.value = matchedUsers;
      } else {
        responseError.value = result.message ?? "Something went wrong";
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      contactLoading.value = false;
    }
  }

  void filterUsers(String value) {
    value = value.trim().toLowerCase();

    if (value.isEmpty) {
      filteredUsers.value = allUserProfileData;
      return;
    }

    final String queryDigits = _normalizePhone(value);

    filteredUsers.value = allUserProfileData.where((user) {
      final String name = (user.name ?? '').toLowerCase();
      final bool mobileMatch = queryDigits.isNotEmpty &&
          _normalizePhone(user.mobileNo ?? '').contains(queryDigits);

      return name.contains(value) || mobileMatch;
    }).toList();
  }

  String _normalizePhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredUsers.value = allUserProfileData;
  }

  Future<void> refreshContacts() async {
    await getRegisteredContacts();
  }

  Future<void> initializeCall() async {
    if (fromCallKit || (args["callType"] == "Incoming" && offer == null)) {
      callStatus.value = "Connecting...";

      socket?.emit("acceptCallFromCallKit", {
        "callerId": callerId,
        "sessionId": CallSessionState.sessionId ?? args["sessionId"],
        "callId": callId,
        "receiverId": Global.storageServices.get(PrefConst.userId),
      });
    } else {
      log("====== Outgoing Call ======");

      peer?.onIceCandidate = (c) => iceCandidates.add(c);

      socket?.on("callAnswered", (data) async {
        await peer?.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );

        for (var c in iceCandidates) {
          if (c.candidate == null) continue;
          socket?.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        }
        iceCandidates.clear();

        peer?.onIceCandidate = (c) {
          if (c.candidate == null) return;
          socket?.emit("IceCandidate", {
            "remoteUserId": remoteUserId,
            "iceCandidate": {
              "id": c.sdpMid,
              "label": c.sdpMLineIndex,
              "candidate": c.candidate,
            },
          });
        };
      });

      final sdpOffer = await peer?.createOffer();
      if (sdpOffer != null) {
        await peer?.setLocalDescription(sdpOffer);

        socket?.emit("makeCall", {
          "remoteUserId": remoteUserId,
          "sdpOffer": sdpOffer.toMap(),
          "is_video": is_video,
          "callerId": Global.storageServices.get(PrefConst.userId),
        });
      }
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

    if (callStatus.value != "Connected") {
      // Logic for non-connected call disconnects (optional)
    }

    if (type != "missedCall") {
      log("========CallEndParameterDetail:$param");
      socket?.emit("endCall", param);
    }

    resetPeer();

    if (CallSessionState.sessionId != null) {
      log("========CallerSideSessionId:${CallSessionState.sessionId}");
      callEnded(
        CallSessionState.sessionId.toString(),
        type: "endCallMethodHittedFromController-Type:$type",
      );
    }

    if (args["callType"] == "outGoing") {
      stopSound();
    }

    await WakelockPlus.disable();

    if (Get.currentRoute != Routes.Home_Screen) {
      Get.offAllNamed(Routes.Home_Screen);
      log("========CallerSideSessionId2:${CallSessionState.sessionId}");
    }
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

  Future<void> enableSpeaker() async {
    await Helper.setSpeakerphoneOn(true);
    isSpeakerOn = true;
    update();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;
    await Helper.setSpeakerphoneOn(isSpeakerOn);
    update();
  }

  Future<void> startAudioCall() async {
    await WakelockPlus.enable();
    // await ProximityScreenLock.setActive(true);
  }

  Future<void> endAudioCall() async {
    await WakelockPlus.disable();
    // await ProximityScreenLock.setActive(false);
  }

  List<GroupsResData> get filteredGroups {
    final String query = _query;
    if (query.isEmpty) return _groupController.groupData;
    return _groupController.groupData.where((group) {
      final String name = (group.groupName ?? '').toLowerCase();
      final String code = (group.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();
  }

  List<Map<String, String>> get filteredRecentCalls {
    final String query = _query;
    if (query.isEmpty) return recentCalls;
    return recentCalls
        .where((call) =>
            (call['name'] ?? '').toLowerCase().contains(query) ||
            (call['type'] ?? '').toLowerCase().contains(query))
        .toList();
  }

  bool get isGroupsLoading => _groupController.groupDataLoading.value;
  String get groupsError => _groupController.responseError.value;
  List<GroupsResData> get groups => _groupController.groupData;

  String get _query => searchQuery.value.trim().toLowerCase();

  void switchTab(int index) => selectedTab.value = index;

  void onSearchChanged(String value) {
    searchQuery.value = value;
    filterUsers(value);
  }

  void loadGroups() => _groupController.getGroupData();

  String get formattedDuration {
    final minutes =
        (callDurationSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (callDurationSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void stopSound() {
    FlutterRingtonePlayer().stop();
  }

  void resetPeer() {
    peer?.dispose();
    peer = null;
    localStream?.dispose();
    localStream = null;
  }

  void _clearTimers() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void callEnded(String sessionId, {required String type}) {
    log("Session Call Ended: $sessionId with execution type: $type");
  }
}
