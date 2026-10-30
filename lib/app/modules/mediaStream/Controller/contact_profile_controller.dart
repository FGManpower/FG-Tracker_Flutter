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

  // Max API pages scanned per batch (API returns all users' calls)
  static const int _maxPages = 15;
  // Calls added per batch (first load + each "load more")
  static const int _pageSize = 10;

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final detail = Rxn<CallHistoryDetailData>();
  final RxList<CallingDetail> calls = <CallingDetail>[].obs;

  // Pagination state for the recent calls list
  var isLoadingMore = false.obs;
  var hasMore = false.obs;
  int _nextPage = 0;
  final Set<String> _seenCallKeys = {};

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
    _seenCallKeys.clear();
    _nextPage = 0;
    hasMore.value = false;

    try {
      await _loadCallsBatch(uid, isFirst: true);
    } catch (e, st) {
      log("[ContactProfile] recent calls error: $e\n$st");
      if (!isClosed) errorMessage.value = "Something went wrong";
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// Next batch of this contact's calls (called on scroll end / "Load more")
  Future<void> loadMoreCalls() async {
    if (!isListMode ||
        isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value) {
      return;
    }
    final String uid = contactData?.userId?.toString().trim() ?? '';
    if (uid.isEmpty) return;

    isLoadingMore.value = true;
    try {
      await _loadCallsBatch(uid, isFirst: false);
    } catch (e, st) {
      log("[ContactProfile] load more calls error: $e\n$st");
    } finally {
      if (!isClosed) isLoadingMore.value = false;
    }
  }

  /// Scans API pages from [_nextPage] until [_pageSize] new calls of this
  /// contact are found, the API has no more pages, or [_maxPages] are scanned.
  Future<void> _loadCallsBatch(String uid, {required bool isFirst}) async {
    final List<CallingDetail> found = [];
    bool apiHasMore = true;

    for (int i = 0; i < _maxPages; i++) {
      final int page = _nextPage;
      final recent_Call_Res res =
          await CallRepo.getRecentCall(page: page.toString());
      if (isClosed) return;

      if (res.status != true) {
        if (isFirst && i == 0) {
          errorMessage.value = res.message ?? "Failed to load recent calls";
          apiHasMore = false;
        }
        // Keep apiHasMore so the user can try loading more again
        break;
      }

      final Iterable<CallingDetail> all =
          (res.data?.allSections.values ?? const <List<CallingDetail>>[])
              .expand((List<CallingDetail> e) => e);

      for (final CallingDetail c in all) {
        if (!_matchesUser(c, uid)) continue;
        final String key = c.id ?? '${c.calledAt}_${c.status}_${c.type}';
        if (_seenCallKeys.add(key)) found.add(c);
      }

      final Pagination? pg = res.pagination;
      final int current = pg?.currentPage ?? page;
      if (pg?.hasNextPage != true || current < page) {
        apiHasMore = false;
        break;
      }
      _nextPage = current + 1;

      if (found.length >= _pageSize) break;
    }

    final List<CallingDetail> merged = [...calls, ...found];
    merged.sort((CallingDetail a, CallingDetail b) {
      final DateTime? da = DateTime.tryParse(a.calledAt ?? '');
      final DateTime? db = DateTime.tryParse(b.calledAt ?? '');
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    calls.assignAll(merged);
    hasMore.value = apiHasMore;
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
