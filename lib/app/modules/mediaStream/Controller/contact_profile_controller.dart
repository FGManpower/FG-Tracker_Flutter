import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/constant/urls.dart';
import '../../../Core/util/http/http_util.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Services/call_service.dart';
import '../../../Data/Services/group_call_service.dart';
import '../../../Model/CallDetail.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../routes/app_pages.dart';
import '../../Messages/Controller/MessageController.dart';
import '../../Messages/Views/Chat_Screen.dart';

class ContactProfileController extends GetxController {
  final MemberData? contactData;
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final String? groupAvatar;

  ContactProfileController({
    this.contactData,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.groupAvatar,
  });


  static const int _maxPages = 10;

  var isLoading = false.obs;
  var recentCalls = <CallHistoryDetailData>[].obs;

  String get _targetGroupId => groupId?.toString().trim() ?? '';
  String get _targetUserId => contactData?.userId?.toString().trim() ?? '';
  String get _targetPhone => _cleanPhone(contactData?.mobileNo ?? '');

  @override
  void onInit() {
    super.onInit();
    fetchCallHistory();
  }

  Future<void> fetchCallHistory() async {
    isLoading.value = true;
    final Set<String> seen = {};
    final List<CallHistoryDetailData> matched = [];
    int emptyStreak = 0;

    try {
      for (int page = 0; page < _maxPages; page++) {
        if (isClosed) return;

        final Map<String, dynamic>? raw = await _fetchPage(page);

        if (raw == null || raw['status'] != true) {
          if (page == 0) recentCalls.clear();
          break;
        }

        final List<CallHistoryDetailData> pageCalls =
        _extractCallList(raw['data']);

        int fresh = 0;
        for (final c in pageCalls) {
          final String key = c.id ?? '${c.callId}_${c.calledAt}';
          if (seen.add(key)) {
            fresh++;
            if (_isRelevant(c)) matched.add(c);
          }
        }

        if (isClosed) return;
        recentCalls.assignAll(matched);
        if (page == 0) isLoading.value = false;

        emptyStreak = fresh == 0 ? emptyStreak + 1 : 0;
        if (emptyStreak >= 2 || !_hasNextPage(raw['pagination'])) break;
      }
    } catch (e, stackTrace) {
      log("Error fetching contact call history: $e\n$stackTrace");
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> _fetchPage(int page) async {
    try {
      dynamic res = await HttpUtil()
          .getRecentCall("${Urls.recentCallHistory}?page=$page&type=all");
      if (res is String) res = jsonDecode(res);
      if (res is Map) return Map<String, dynamic>.from(res);
    } catch (e) {
      log("ContactProfile _fetchPage($page) error: $e");
    }
    return null;
  }

  bool _hasNextPage(dynamic pagination) {
    if (pagination is! Map) return false;
    for (final v in pagination.values) {
      if (v is Map && v['hasNextPage'] == true) return true;
    }
    return false;
  }

  List<CallHistoryDetailData> _extractCallList(dynamic data) {
    final List<CallHistoryDetailData> list = [];
    if (data == null) return list;

    void parseItems(List items) {
      for (final e in items) {
        if (e is! Map) continue;
        try {
          list.add(CallHistoryDetailData.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          log("Skipping bad call item: $err");
        }
      }
    }

    if (data is Map) {
      for (final v in data.values) {
        if (v is List) parseItems(v);
      }
    } else if (data is List) {
      parseItems(data);
    }
    return list;
  }

  bool _isGroupCall(CallHistoryDetailData c) =>
      c.callType == 'group' || c.groupId != null || c.group != null;

  bool _isRelevant(CallHistoryDetailData c) =>
      isGroup ? _matchesGroup(c) : _matchesContact(c);

  bool _matchesGroup(CallHistoryDetailData c) {
    if (!_isGroupCall(c)) return false;
    final String gId =
        (c.groupId ?? c.group?.groupId ?? c.group?.id)?.toString() ?? '';
    return gId.isNotEmpty && _targetGroupId.isNotEmpty && gId == _targetGroupId;
  }

  bool _matchesContact(CallHistoryDetailData c) {
    if (_isGroupCall(c)) return false;

    bool isTarget(String? id, String? userId, String? phone) {
      final String a = id?.trim() ?? '';
      final String b = userId?.trim() ?? '';
      final String p = _cleanPhone(phone ?? '');
      if (_targetUserId.isNotEmpty && (a == _targetUserId || b == _targetUserId)) {
        return true;
      }
      return _targetPhone.isNotEmpty && p == _targetPhone;
    }

    for (final u in [c.contact, c.caller, c.receiver]) {
      if (u != null && isTarget(u.id, u.userId, u.phoneNumber)) return true;
    }

    return c.participants?.any((p) => isTarget(p.id?.toString(), p.userId, p.phoneNumber)) ??
        false;
  }

  void startCall(BuildContext context, {required bool isVideo}) {
    if (isGroup) {
      if (_targetGroupId.isNotEmpty) {
        GroupCallService.instance.startGroupCall(
          context,
          groupId: _targetGroupId,
          groupName: groupName ?? "Group Call",
          groupProfile: groupAvatar,
          isVideo: isVideo,
        );
      }
    } else {
      final String remoteId = contactData?.userId?.toString() ?? '';
      if (remoteId.isNotEmpty) {
        CallService().startCall(
          context,
          callerId: Global.storageServices.get(PrefConst.userId).toString(),
          remoteUserId: remoteId,
          is_video: isVideo,
          callerName: contactData?.name ?? 'User',
        );
      } else {
        Utils().fluttertoast("Unable to call this contact");
      }
    }
  }

  void openMessage() {
    if (isGroup) {
      if (_targetGroupId.isEmpty) return;
      Get.toNamed(
        Routes.groupChatScreen,
        arguments: {
          "groupId": _targetGroupId,
          "groupName": groupName ?? "Group",
          "groupProfile": groupAvatar,
        },
      );
    } else {
      final MemberData? user = contactData;
      if (user == null || user.userId == null) {
        Utils().fluttertoast("Unable to open chat for this contact");
        return;
      }Get.to(
            () => ChatScreen(),
        arguments: {
          "userData": MemberData(
            userId: user.userId,
            name: user.name,
            mobileNo: user.mobileNo,
            profileImage: user.profileImage,
            isOnline: user.isOnline,
            groupId: 0,
          ),
        },
        binding: BindingsBuilder(() {
          Get.put(MessageController());
        }),
      );
    }
  }

  String _cleanPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length > 10) {
      cleaned = cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
  }
}