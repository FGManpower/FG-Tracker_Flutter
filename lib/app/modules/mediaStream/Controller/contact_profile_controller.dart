import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/call_repo.dart';
import '../../../Data/Services/call_service.dart';
import '../../../Data/Services/group_call_service.dart';
import '../../../Model/CallDetail.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../Model/recent_call.dart';
import '../../../routes/app_pages.dart';
import '../../call/widget/call_widget.dart';
import '../../Messages/Controller/MessageController.dart';
import '../../Messages/Views/Chat_Screen.dart';

class ContactProfileController extends GetxController {
  final MemberData? contactData;
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final String? groupAvatar;
  final String? callId;

  ContactProfileController({
    this.contactData,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.groupAvatar,
    this.callId,
  });

  static const int _maxPages = 15;
  static const int _maxCalls = 10;

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final detail = Rxn<CallHistoryDetailData>();
  final RxList<CallingDetail> calls = <CallingDetail>[].obs;

  bool get isListMode => !isGroup && (callId?.trim().isEmpty ?? true);

  String get _targetGroupId {
    final String g = groupId?.toString().trim() ?? '';
    if (g.isNotEmpty) return g;
    return detail.value?.groupId?.toString().trim() ?? '';
  }

  List<CallParticipant> get participants {
    final CallHistoryDetailData? d = detail.value;
    if (d == null) return [];
    final List<CallParticipant> out = [];
    final Set<String> seen = {};
    for (final p in [...?d.participants, ...?d.joinedMembers]) {
      final String key = (p.userId ?? p.id?.toString() ?? '').trim();
      if (key.isEmpty || seen.add(key)) out.add(p);
    }
    return out;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    if (isListMode) {
      await _fetchUserCalls();
      return;
    }

    final String id = callId?.trim() ?? '';
    if (id.isEmpty) {
      errorMessage.value = "Call id not found";
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final CallHistoryDetailRes res = await CallRepo.getCallHistoryDetail(id);
      if (isClosed) return;
      if (res.status == true && res.data != null) {
        detail.value = res.data;
      } else {
        errorMessage.value = res.message ?? "Failed to load call detail";
      }
    } catch (e, st) {
      log("[ContactProfile] getCallHistoryDetail error: $e\n$st");
      if (!isClosed) errorMessage.value = "Something went wrong";
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  bool _matchesUser(CallingDetail c, String uid) {
    if (c.isGroup == true) return false;
    return c.contact?.id == uid || c.callerId == uid || c.receiverId == uid;
  }

  Future<void> _fetchUserCalls() async {
    final String uid = contactData?.userId?.toString().trim() ?? '';
    if (uid.isEmpty) {
      errorMessage.value = "User not found";
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    calls.clear();

    try {
      final List<CallingDetail> found = [];
      final Set<String> seen = {};
      int page = 0;
      int lastPage = -1;

      for (int i = 0; i < _maxPages; i++) {
        final recent_Call_Res res =
            await CallRepo.getRecentCall(page: page.toString());
        if (isClosed) return;

        if (res.status != true) {
          if (i == 0) {
            errorMessage.value = res.message ?? "Failed to load recent calls";
          }
          break;
        }

        final Iterable<CallingDetail> all =
            (res.data?.allSections.values ?? const <List<CallingDetail>>[])
                .expand((List<CallingDetail> e) => e);

        for (final CallingDetail c in all) {
          if (!_matchesUser(c, uid)) continue;
          final String key = c.id ?? '${c.calledAt}_${c.status}_${c.type}';
          if (seen.add(key)) found.add(c);
        }

        final Pagination? pg = res.pagination;
        final int current = pg?.currentPage ?? page;
        if (pg?.hasNextPage != true) break;
        if (current == lastPage) break;
        lastPage = current;
        page = current + 1;

        if (found.length >= _maxCalls) break;
      }

      found.sort((CallingDetail a, CallingDetail b) {
        final DateTime? da = DateTime.tryParse(a.calledAt ?? '');
        final DateTime? db = DateTime.tryParse(b.calledAt ?? '');
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

      calls.assignAll(found.take(_maxCalls));
    } catch (e, st) {
      log("[ContactProfile] recent calls error: $e\n$st");
      if (!isClosed) errorMessage.value = "Something went wrong";
    } finally {
      if (!isClosed) isLoading.value = false;
    }
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
      final String phone = contactData?.mobileNo ?? '';

      if (!CallValidation.validateCall(
        destinationPhone: phone,
        destinationUserId: remoteId,
      )) {
        return;
      }

      if (remoteId.isNotEmpty) {
        CallService().startOutGoingCall(
          context,
          callerId: Global.storageServices.get(PrefConst.userId).toString(),
          remoteUserId: remoteId,
          is_video: isVideo,
          callerName: contactData?.name ?? 'User',
          callerProfile: contactData?.profileImage,
          destinationPhone: phone,
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
      return;
    }

    final MemberData? user = contactData;

    if (user == null || user.userId == null) {
      Utils().fluttertoast("Unable to open chat for this contact");
      return;
    }

    final d = detail.value;

    final int? chatId = user.chatId ?? detail.value?.chatId;
    log("PROFILE USER ID => ${user.userId}");
    log("PROFILE CHAT ID => ${user.chatId}");
    log("CHAT ID ARGUMENT => ${chatId?.toString()}");

    Get.to(
      () => ChatScreen(),
      arguments: {
        "userData": MemberData(
          userId: user.userId,
          name: user.name,
          mobileNo: user.mobileNo,
          profileImage: user.profileImage,
          isOnline: user.isOnline,
          chatId: chatId,
          groupId: 0,
        ),
        "type": "chatScreen",
        "chatType": "private",
        "chatId": chatId?.toString(),
        "groupId": 0,
        "groupName": user.name ?? "Chat",
      },
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MessageController>()) {
          Get.put(MessageController());
          log("MessageController CREATED");
        } else {
          log("MessageController ALREADY REGISTERED");
        }
      }),
    );
  }
}
