<<<<<<< HEAD
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
=======
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
<<<<<<< HEAD
import 'package:fgtracker/app/routes/app_pages.dart';
import '../../../Core/global/launchedFromCall.dart';
=======
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e

class CallController extends GetxController {
  static CallController get instance => Get.put(CallController());

  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  final ContactService _contactService = ContactService();
  final TextEditingController searchController = TextEditingController();

  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString responseError = "".obs;

  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  final RxBool recentCallLoading = false.obs;
  final RxBool recentCallLoadingMore = false.obs;
  final RxString recentCallResponseError = "".obs;
  final RxInt pagination = 1.obs;
  final RxBool hasMoreRecentCalls = true.obs;
  final RxString recentCallFilter = 'All'.obs;
  final RxList<Map<String, String>> recentCallList =
      <Map<String, String>>[].obs;

  final List<_RecentEntry> _recentRaw = <_RecentEntry>[];

  @override
  void onClose() {
    searchController.dispose();
    searchQuery.close();
    selectedTab.close();
    contactLoading.close();
    responseError.close();
    recentCallLoading.close();
    recentCallLoadingMore.close();
    recentCallResponseError.close();
    recentCallFilter.close();
    hasMoreRecentCalls.close();
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

<<<<<<< HEAD
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
=======
  Future<void> getRecentCall() async {
    if (recentCallLoading.value || recentCallLoadingMore.value) return;
    recentCallLoading.value = true;
    recentCallResponseError.value = "";
    try {
      final result = await CallRepo.getRecentCall(
        page: pagination.value.toString(),
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
      );
      if (result.status == true) {
        final data = result.data;
        if (data != null) {
          _addBucket('today', data.today);
          _addBucket('yesterday', data.yesterday);
          _addBucket('older', data.older);
          _rebuildRecentDisplay();
          final meta = result.pagination;
          if (meta != null) {
            hasMoreRecentCalls.value = meta.hasNextPage ??
                (meta.totalRecords != null &&
                    recentCallList.length < meta.totalRecords!);
          }
        } else {
          hasMoreRecentCalls.value = false;
        }
      } else {
        recentCallResponseError.value =
            result.message ?? "Something went wrong";
      }
    } catch (e) {
      recentCallResponseError.value = e.toString();
    } finally {
      recentCallLoading.value = false;
    }
  }

<<<<<<< HEAD
  void toggleMic() {
    isAudioOn = !isAudioOn;
    localStream?.getAudioTracks().forEach((t) => t.enabled = isAudioOn);
    update();
=======
  Future<void> loadMoreRecentCalls() async {
    if (recentCallLoading.value ||
        recentCallLoadingMore.value ||
        !hasMoreRecentCalls.value) {
      return;
    }
    recentCallLoadingMore.value = true;
    try {
      final int nextPage = pagination.value + 1;
      final result = await CallRepo.getRecentCall(
        page: nextPage.toString(),
      );
      if (result.status == true) {
        final int before = _recentRaw.length;
        final data = result.data;
        if (data != null) {
          _addBucket('today', data.today);
          _addBucket('yesterday', data.yesterday);
          _addBucket('older', data.older);
        }
        if (_recentRaw.length == before) {
          hasMoreRecentCalls.value = false;
        } else {
          pagination.value = nextPage;
          _rebuildRecentDisplay();
          final meta = result.pagination;
          if (meta != null) {
            hasMoreRecentCalls.value = meta.hasNextPage ??
                (meta.totalRecords != null &&
                    recentCallList.length < meta.totalRecords!);
          }
        }
      } else {
        hasMoreRecentCalls.value = false;
      }
    } catch (_) {
    } finally {
      recentCallLoadingMore.value = false;
    }
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
  }

  Future<void> refreshRecentCalls() async {
    _recentRaw.clear();
    recentCallList.clear();
    pagination.value = 1;
    hasMoreRecentCalls.value = true;
    recentCallLoading.value = false;
    recentCallLoadingMore.value = false;
    await getRecentCall();
  }

  void _addBucket(String section, List<CallingDetail>? items) {
    if (items == null) return;
    for (final CallingDetail call in items) {
      _recentRaw.add(_RecentEntry(section, call));
    }
  }

  void _rebuildRecentDisplay() {
    recentCallList.value = _recentRaw.map(_buildRow).toList();
  }

  Map<String, String> _buildRow(_RecentEntry entry) {
    final CallingDetail call = entry.call;
    final RecentContact? contact = call.contact;
    final String name = [
      contact?.firstName,
      contact?.lastName,
    ].whereType<String>().join(' ').trim();
    return {
      'name': name.isEmpty ? 'Unknown' : name,
      'type': _composeTypeLabel(call),
      'time': _composeTimeLabel(entry),
      'avatar': (contact?.avatar ?? '').trim(),
      'callType': (call.type ?? '').trim(),
      'callerId': (contact?.id ?? '').trim(),
    };
  }

  String _composeTypeLabel(CallingDetail call) {
    final String type = (call.type ?? '').trim().toLowerCase();
    final String direction = (call.direction ?? '').trim().toLowerCase();
    final String status = (call.status ?? '').trim().toLowerCase();

    String kind;
    if (type.contains('video')) {
      kind = 'Video';
    } else if (type.contains('audio')) {
      kind = 'Audio';
    } else {
      kind = type.isEmpty ? 'Call' : _capitalize(type);
    }

    if (status.contains('missed')) return 'Missed $kind Call';
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('declin')) {
      return 'Cancelled $kind Call';
    }
    if (direction.contains('in')) return 'Incoming $kind Call';
    if (direction.contains('out')) return 'Outgoing $kind Call';
    return '$kind Call';
  }

  String _composeTimeLabel(_RecentEntry entry) {
    final CallingDetail call = entry.call;
    final String time = (call.time ?? '').trim();
    final String dateRaw = (call.date ?? '').trim().toLowerCase();
    final String dateStr = (call.date ?? '').trim();

    String sectionLabel;
    if (dateRaw.contains('today')) {
      sectionLabel = 'Today';
    } else if (dateRaw.contains('yesterday')) {
      sectionLabel = 'Yesterday';
    } else if (entry.section == 'today') {
      sectionLabel = 'Today';
    } else if (entry.section == 'yesterday') {
      sectionLabel = 'Yesterday';
    } else if (dateStr.isNotEmpty) {
      sectionLabel = _formatDate(dateStr);
    } else if ((call.calledAt ?? '').isNotEmpty) {
      sectionLabel = _formatDate(call.calledAt!);
    } else {
      sectionLabel = '';
    }

    if (sectionLabel.isEmpty) return time;
    return time.isNotEmpty ? '$sectionLabel, $time' : sectionLabel;
  }

<<<<<<< HEAD
=======
  String _formatDate(String raw) {
    final DateTime? dt = DateTime.tryParse(raw);
    if (dt != null) {
      const List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    }
    return raw;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void setRecentCallFilter(String value) {
    if (recentCallFilter.value == value) return;
    recentCallFilter.value = value;
  }

  List<Map<String, String>> get filteredRecentCalls {
    final String query = _query;
    final String filter = recentCallFilter.value;
    return recentCallList.where((call) {
      final String name = (call['name'] ?? '').toLowerCase();
      final String type = (call['type'] ?? '').toLowerCase();
      final bool matchQuery =
          query.isEmpty || name.contains(query) || type.contains(query);
      bool matchFilter = filter == 'All';
      if (filter == 'Missed') {
        matchFilter = type.contains('missed');
      } else if (filter == 'Outgoing') {
        matchFilter = type.contains('outgoing');
      } else if (filter == 'Incoming') {
        matchFilter = type.contains('incoming');
      }
      return matchQuery && matchFilter;
    }).toList();
  }

>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
  List<GroupsResData> get filteredGroups {
    final String query = _query;
    if (query.isEmpty) return _groupController.groupData;
    return _groupController.groupData.where((group) {
      final String name = (group.groupName ?? '').toLowerCase();
      final String code = (group.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();
  }

<<<<<<< HEAD
  List<Map<String, String>> get filteredRecentCalls {
    final String query = _query;
    if (query.isEmpty) return recentCalls;
    return recentCalls
        .where((call) =>
            (call['name'] ?? '').toLowerCase().contains(query) ||
            (call['type'] ?? '').toLowerCase().contains(query))
        .toList();
  }

=======
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
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
}

<<<<<<< HEAD
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
=======
class _RecentEntry {
  _RecentEntry(this.section, this.call);

  final String section;
  final CallingDetail call;
>>>>>>> dad19844ab29312734af3c86f000edf4ffa19d1e
}
