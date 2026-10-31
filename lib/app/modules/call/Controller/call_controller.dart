import 'dart:async';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/CommonRes.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;
import 'contact_controller.dart';

class CallController extends GetxController {
  static CallController get instance => Get.isRegistered<CallController>()
      ? Get.find<CallController>()
      : Get.put(CallController());

  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  final TextEditingController searchController = TextEditingController();

  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;

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

  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedCallIds = <String>{}.obs;
  final RxBool isDeletingMultiple = false.obs;
  final RxBool isClearingAll = false.obs;

  final List<_RecentEntry> _recentRaw = <_RecentEntry>[];

  final RxBool isDialPadOpen = false.obs;
  final RxString dialNumber = ''.obs;
  final TextEditingController dialTextController = TextEditingController();
  final FocusNode dialFocusNode = FocusNode();
  Timer? _rebuildTimer;

  void _scheduleRebuild() {
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(const Duration(milliseconds: 150), () {
      if (_recentRaw.isNotEmpty) _rebuildRecentDisplay();
    });
  }

  @override
  void onInit() {
    super.onInit();

    loadGroups();
    getRecentCall();

    dialTextController.addListener(() {
      if (dialNumber.value != dialTextController.text) {
        dialNumber.value = dialTextController.text;
        filterUsers(_query);
      }
    });

    ever(_groupController.groupData, (_) => _scheduleRebuild());
    ever(allUserProfileData, (_) => _scheduleRebuild());
  }

  @override
  void onClose() {
    searchController.dispose();
    dialTextController.dispose();
    dialFocusNode.dispose();
    searchQuery.close();
    selectedTab.close();
    _rebuildTimer?.cancel();
    responseError.close();
    recentCallLoading.close();
    recentCallLoadingMore.close();
    recentCallResponseError.close();
    recentCallFilter.close();
    hasMoreRecentCalls.close();

    isDialPadOpen.close();
    dialNumber.close();
    isSelectionMode.close();
    selectedCallIds.close();
    isDeletingMultiple.close();
    isClearingAll.close();
    super.onClose();
  }

  UserListData? selectedDialUser;

  void toggleDialPad() {
    isDialPadOpen.value = !isDialPadOpen.value;
    if (isDialPadOpen.value) {
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialFocusNode.requestFocus();
      });
    } else {
      clearDialNumber();
      dialFocusNode.unfocus();
    }
    filterUsers(_query);
  }

  void selectUserToDial(UserListData user) {
    selectedDialUser = user;
    final String raw = (user.mobileNo ?? '').trim();
    final String digits = normalizePhone(raw);
    final String val = digits.isNotEmpty ? digits : raw;
    dialNumber.value = val;
    dialTextController.value = TextEditingValue(
      text: val,
      selection: TextSelection.collapsed(offset: val.length),
    );
    isDialPadOpen.value = true;
    filterUsers(_query);
  }

  void addDigit(String digit) {
    selectedDialUser = null;
    final text = dialTextController.text;
    if (text.length >= 15) return;

    final selection = dialTextController.selection;
    int start = selection.start;
    int end = selection.end;

    String newText;
    int newCursorPos;

    if (selection.isValid && start >= 0 && end >= 0) {
      if (start > end) {
        final temp = start;
        start = end;
        end = temp;
      }
      newText = text.replaceRange(start, end, digit);
      newCursorPos = start + digit.length;
    } else {
      newText = text + digit;
      newCursorPos = newText.length;
    }

    dialNumber.value = newText;
    dialTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    filterUsers(_query);
  }

  void removeLastDigit() {
    selectedDialUser = null;
    final text = dialTextController.text;
    if (text.isEmpty) return;

    final selection = dialTextController.selection;
    int start = selection.start;
    int end = selection.end;

    if (selection.isValid && start >= 0 && end >= 0 && start != end) {
      if (start > end) {
        final temp = start;
        start = end;
        end = temp;
      }
      final newText = text.replaceRange(start, end, '');
      dialNumber.value = newText;
      dialTextController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      filterUsers(_query);
      return;
    }

    int cursorPos = selection.isValid && start >= 0 ? start : text.length;
    if (cursorPos <= 0) return;

    final newText = text.replaceRange(cursorPos - 1, cursorPos, '');
    final newCursorPos = cursorPos - 1;

    dialNumber.value = newText;
    dialTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    filterUsers(_query);
  }

  void clearDialNumber() {
    selectedDialUser = null;
    dialNumber.value = '';
    dialTextController.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
    filterUsers(_query);
  }

  String _normalizeToCore10(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length > 10 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  Future<void> makeCall({bool isVideo = false}) async {
    final String input = dialNumber.value.trim();
    if (input.isEmpty) {
      Utils().fluttertoast("Please enter a phone number");
      return;
    }

    if (!CallValidation.validateCall(destinationPhone: input)) {
      return;
    }

    final String inputDigits = normalizePhone(input);
    final String inputCore10 = _normalizeToCore10(input);
    final currentUserId =
    Global.storageServices.get(PrefConst.userId)?.toString();

    if (currentUserId == null || currentUserId.isEmpty) {
      Utils().fluttertoast("Please login to make a call");
      return;
    }

    // Registered contacts pool merge
    final List<UserListData> contactPool = [
      ...allUserProfileData,
      if (Get.isRegistered<ContactController>())
        ...ContactController.instance.allUserProfileData,
    ];

    UserListData? targetUser;

    // 1. Agar list se tap kiya hua user pehle se selected ho
    if (selectedDialUser != null) {
      final String selDigits = normalizePhone(selectedDialUser?.mobileNo ?? '');
      final String selCore = _normalizeToCore10(selectedDialUser?.mobileNo ?? '');
      if (selDigits == inputDigits || (inputCore10.isNotEmpty && selCore == inputCore10)) {
        targetUser = selectedDialUser;
      }
    }

    // 2. Contacts pool me exact ya 10-digit number match dhoondo
    targetUser ??= contactPool.firstWhereOrNull((u) {
      final String pDigits = normalizePhone(u.mobileNo ?? '');
      final String pCore = _normalizeToCore10(u.mobileNo ?? '');
      return pDigits == inputDigits ||
          (inputCore10.isNotEmpty && pCore == inputCore10);
    });

    // STRICT RULE: Agar contacts me nahi mila to call bilkul nahi jayegi
    if (targetUser == null || targetUser.userId == null) {
      Utils().fluttertoast("Not exist in your contacts");
      return;
    }

    final String remoteUserId = targetUser.userId.toString();
    final String targetName = (targetUser.name?.trim().isNotEmpty == true)
        ? targetUser.name!.trim()
        : "User";

    if (!CallValidation.validateCall(
      destinationPhone: targetUser.mobileNo,
      destinationUserId: remoteUserId,
    )) {
      return;
    }

    isDialPadOpen.value = false;
    selectedDialUser = null;

    final ctx = Get.context;
    if (ctx != null) {
      CallService().startOutGoingCall(
        ctx,
        callerId: currentUserId,
        remoteUserId: remoteUserId,
        is_video: isVideo,
        callerName: targetName,
        callerProfile: targetUser.profileImage,
      );
    }
  }

  static const Map<String, String> _t9LetterToDigit = {
    'a': '2',
    'b': '2',
    'c': '2',
    'd': '3',
    'e': '3',
    'f': '3',
    'g': '4',
    'h': '4',
    'i': '4',
    'j': '5',
    'k': '5',
    'l': '5',
    'm': '6',
    'n': '6',
    'o': '6',
    'p': '7',
    'q': '7',
    'r': '7',
    's': '7',
    't': '8',
    'u': '8',
    'v': '8',
    'w': '9',
    'x': '9',
    'y': '9',
    'z': '9',
  };

  String _nameToT9(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      buffer.write(_t9LetterToDigit[char] ?? '');
    }
    return buffer.toString();
  }

  bool _matchesT9(String name, String queryDigits) {
    if (queryDigits.isEmpty) return false;
    final nameLower = name.toLowerCase();
    final fullT9 = _nameToT9(nameLower);
    if (fullT9.contains(queryDigits)) return true;

    final words = nameLower.split(RegExp(r'\s+'));
    for (final word in words) {
      if (_nameToT9(word).startsWith(queryDigits)) return true;
    }
    return false;
  }

  void filterUsers(String value) {
    final trimmed = value.trim().toLowerCase();

    if (trimmed.isEmpty) {
      filteredUsers.value = allUserProfileData;
      return;
    }

    final String queryDigits = normalizePhone(trimmed);

    filteredUsers.value = allUserProfileData.where((user) {
      final String name = (user.name ?? '').toLowerCase();
      final String mobile = (user.mobileNo ?? '').toLowerCase();
      final bool nameTextMatch = name.contains(trimmed);
      final bool mobileMatch = mobile.contains(trimmed) ||
          (queryDigits.isNotEmpty &&
              normalizePhone(user.mobileNo ?? '').contains(queryDigits));
      final bool t9Match =
          queryDigits.isNotEmpty && _matchesT9(name, queryDigits);

      return nameTextMatch || mobileMatch || t9Match;
    }).toList();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredUsers.value = allUserProfileData;
  }

  Future<void> getRecentCall() async {
    if (recentCallLoading.value || recentCallLoadingMore.value) return;

    recentCallLoading.value = true;
    recentCallResponseError.value = "";

    final stopwatch = Stopwatch()..start();

    try {
      final result = await CallRepo.getRecentCall(
        page: pagination.value.toString(),
      );

      debugPrint(
        "⏱️ Recent Calls API Time: ${stopwatch.elapsedMilliseconds} ms",
      );

      if (result.status == true) {
        final data = result.data;

        if (data != null) {
          if (data.allSections.isNotEmpty) {
            data.allSections.forEach((sec, list) {
              _addBucket(sec, list);
            });
          } else {
            _addBucket('today', data.today);
            _addBucket('yesterday', data.yesterday);
            _addBucket('older', data.older);
          }

          _rebuildRecentDisplay();

          final meta = result.pagination;

          if (meta != null) {
            if (meta.currentPage != null) {
              pagination.value = meta.currentPage!;
            }
            if (meta.hasNextPage != null) {
              hasMoreRecentCalls.value = meta.hasNextPage!;
            } else if (meta.totalPages != null) {
              hasMoreRecentCalls.value =
                  (meta.currentPage ?? pagination.value) < meta.totalPages!;
            } else if (meta.totalRecords != null) {
              hasMoreRecentCalls.value =
                  recentCallList.length < meta.totalRecords!;
            }
          } else {
            hasMoreRecentCalls.value =
            (data.older != null && data.older!.isNotEmpty);
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
      stopwatch.stop();
      recentCallLoading.value = false;
    }
  }

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
          final List<CallingDetail> newOlderCalls = [];
          if (data.older != null && data.older!.isNotEmpty) {
            newOlderCalls.addAll(data.older!);
          }
          if (data.allSections.isNotEmpty) {
            data.allSections.forEach((sec, list) {
              final lower = sec.toLowerCase().trim();
              if (lower != 'today' && lower != 'yesterday' && lower != 'older') {
                newOlderCalls.addAll(list);
              }
            });
          }
          if (newOlderCalls.isNotEmpty) {
            _addBucket('older', newOlderCalls, allowTodayYesterday: false);
          }
        }
        if (_recentRaw.length == before) {
          hasMoreRecentCalls.value = false;
        } else {
          pagination.value = result.pagination?.currentPage ?? nextPage;
          _rebuildRecentDisplay();
          final meta = result.pagination;
          if (meta != null) {
            if (meta.hasNextPage != null) {
              hasMoreRecentCalls.value = meta.hasNextPage!;
            } else if (meta.totalPages != null) {
              hasMoreRecentCalls.value =
                  (meta.currentPage ?? nextPage) < meta.totalPages!;
            } else {
              hasMoreRecentCalls.value = _recentRaw.length > before;
            }
          } else {
            hasMoreRecentCalls.value = _recentRaw.length > before;
          }
        }
      } else {
        hasMoreRecentCalls.value = false;
      }
    } catch (_) {
    } finally {
      recentCallLoadingMore.value = false;
    }
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

  void _addBucket(String section, List<CallingDetail>? items,
      {bool allowTodayYesterday = true}) {
    if (items == null || items.isEmpty) return;
    final lowerSec = section.toLowerCase().trim();
    if (!allowTodayYesterday &&
        (lowerSec == 'today' || lowerSec == 'yesterday')) {
      return;
    }
    final Set<String> existingKeys = _recentRaw
        .map((e) {
      final id = (e.call.id ?? '').trim();
      if (id.isNotEmpty) return id;
      return '${e.call.calledAt}_${e.call.callerId}_${e.call.type}'.trim();
    })
        .where((k) => k.isNotEmpty)
        .toSet();

    for (final CallingDetail call in items) {
      final String id = (call.id ?? '').trim();
      final String fallbackKey =
      '${call.calledAt}_${call.callerId}_${call.type}'.trim();
      final String checkKey = id.isNotEmpty ? id : fallbackKey;
      if (checkKey.isNotEmpty && existingKeys.contains(checkKey)) {
        continue;
      }
      if (checkKey.isNotEmpty) {
        existingKeys.add(checkKey);
      }
      _recentRaw.add(_RecentEntry(section, call));
    }
  }

  void _rebuildRecentDisplay() {
    recentCallList.value = _recentRaw.map(_buildRow).toList();
  }

  Map<String, String> _buildRow(_RecentEntry entry) {
    final CallingDetail call = entry.call;
    final RecentContact? contact = call.contact;
    final String rawCallId = (call.id ?? '').trim();

    String name = [
      contact?.firstName,
      contact?.lastName,
    ].whereType<String>().join(' ').trim();

    String mobileNo = (contact?.phoneNumber ?? '').trim();
    String avatar = (contact?.avatar ?? '').trim();

    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    String callerId = (contact?.id ?? '').trim();
    if (callerId.isEmpty || callerId == currentUserId) {
      if ((call.callerId ?? '').isNotEmpty && call.callerId != currentUserId) {
        callerId = call.callerId!.trim();
      } else if ((call.receiverId ?? '').isNotEmpty &&
          call.receiverId != currentUserId) {
        callerId = call.receiverId!.trim();
      } else {
        callerId = (call.callerId ?? call.receiverId ?? '').trim();
      }
    }

    final String targetGroupId =
    (call.groupId ?? contact?.groupId ?? '').trim();

    GroupsResData? matchedGroup;
    if (targetGroupId.isNotEmpty) {
      final int? gId = int.tryParse(targetGroupId);
      matchedGroup = _groupController.groupData.firstWhereOrNull(
            (g) =>
        (g.id != null && g.id == gId) || g.id?.toString() == targetGroupId,
      );
    }

    if (matchedGroup == null && callerId.isNotEmpty) {
      final int? cId = int.tryParse(callerId);
      matchedGroup = _groupController.groupData.firstWhereOrNull(
            (g) => (g.id != null && g.id == cId) || g.id?.toString() == callerId,
      );
    }

    final bool isGroupCall = call.isGroup == true ||
        contact?.isGroup == true ||
        matchedGroup != null ||
        (targetGroupId.isNotEmpty && targetGroupId != "0") ||
        (call.groupName != null && call.groupName!.trim().isNotEmpty) ||
        (contact?.groupName != null && contact!.groupName!.trim().isNotEmpty) ||
        (call.type ?? '').toLowerCase().contains('group');

    String resolvedGroupId = '';
    String memberCount = '0';

    if (isGroupCall) {
      resolvedGroupId = matchedGroup?.id?.toString() ??
          (targetGroupId.isNotEmpty ? targetGroupId : callerId);

      final String groupNameFound = (matchedGroup?.groupName ??
          call.groupName ??
          contact?.groupName ??
          '')
          .trim();

      if (groupNameFound.isNotEmpty) {
        name = groupNameFound;
      } else if (name.isEmpty || name.toLowerCase() == 'unknown') {
        name = resolvedGroupId.isNotEmpty
            ? 'Group $resolvedGroupId'
            : 'Group Call';
      }

      final String groupImg =
      (matchedGroup?.groupProfile ?? call.groupProfile ?? '').trim();
      if (groupImg.isNotEmpty) {
        avatar = groupImg;
      }

      memberCount = matchedGroup?.memberCount?.toString() ??
          call.memberCount?.toString() ??
          '0';
    } else {
      UserListData? matchedUser;
      if (callerId.isNotEmpty) {
        final int? contactUserId = int.tryParse(callerId);
        if (contactUserId != null) {
          matchedUser = allUserProfileData.firstWhereOrNull(
                (user) => user.userId == contactUserId,
          );
        }
      }

      if (matchedUser == null && mobileNo.isNotEmpty) {
        final String normMobile = normalizePhone(mobileNo);
        if (normMobile.isNotEmpty) {
          matchedUser = allUserProfileData.firstWhereOrNull(
                (user) => normalizePhone(user.mobileNo ?? '') == normMobile,
          );
        }
      }

      if (matchedUser != null) {
        if (mobileNo.isEmpty) {
          mobileNo = (matchedUser.mobileNo ?? '').trim();
        }

        if ((name.isEmpty || name.toLowerCase() == 'unknown') &&
            (matchedUser.name ?? '').isNotEmpty) {
          name = matchedUser.name!.trim();
        }

        if (avatar.isEmpty && (matchedUser.profileImage ?? '').isNotEmpty) {
          avatar = matchedUser.profileImage!.trim();
        }
      }

      if ((name.isEmpty || name.toLowerCase() == 'unknown') &&
          (call.callerName ?? '').trim().isNotEmpty &&
          call.callerId != currentUserId) {
        name = call.callerName!.trim();
      }

      if (name.isEmpty || name.toLowerCase() == 'unknown') {
        if (mobileNo.isNotEmpty) {
          name = formatPhoneForDisplay(mobileNo);
        } else if (callerId.isNotEmpty) {
          name = 'User $callerId';
        } else {
          name = 'Unknown';
        }
      }
    }

    return {
      'name': name.isEmpty ? 'Unknown' : name,
      'phone': mobileNo.isNotEmpty ? mobileNo : callerId,
      'type': _composeTypeLabel(call, isGroup: isGroupCall),
      'time': _composeTimeLabel(entry),
      'avatar': avatar,
      'callType': (call.type ?? '').trim(),
      'callerId': callerId,
      'mobileNo': mobileNo,
      'section': (call.section ?? entry.section).trim(),
      'isGroup': isGroupCall ? 'true' : 'false',
      'groupId': resolvedGroupId,
      'memberCount': memberCount,
      'localEntryId': entry.localId,
      'id': rawCallId,
      'callId': rawCallId,
      'apiTime': (call.time ?? '').trim(),
      'apiDate': (call.date ?? '').trim(),
      'apiDay': (call.day ?? '').trim(),
      'apiWeek': (call.week ?? '').trim(),
      'displayTime': (call.displayTime ?? '').trim(),
      'calledAt': (call.calledAt ?? '').trim(),
      'duration': (call.duration ?? '').trim(),
    };
  }

  String _composeTypeLabel(CallingDetail call, {bool isGroup = false}) {
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

    final bool showGroupTag = isGroup && !kind.toLowerCase().contains('group');
    final String groupTag = showGroupTag ? 'Group ' : '';

    final bool isOutgoing = direction == 'outgoing' ||
        direction == 'out' ||
        direction == 'outbound';
    final bool isIncoming =
        direction == 'incoming' || direction == 'in' || direction == 'inbound';

    if (status.contains('missed')) return 'Missed $groupTag$kind Call';
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('declin')) {
      return 'Rejected $kind Call';
    }
    if (isOutgoing) return 'Outgoing $groupTag$kind Call';
    if (isIncoming) return 'Incoming $groupTag$kind Call';
    return '$groupTag$kind Call';
  }

  String _composeTimeLabel(_RecentEntry entry) {
    final CallingDetail call = entry.call;

    if ((call.displayTime ?? '').trim().isNotEmpty) {
      String dt = call.displayTime!.trim();
      final bool isToday = entry.section.toLowerCase() == 'today' ||
          (call.date ?? '').toLowerCase().contains('today') ||
          (call.day ?? '').toLowerCase().contains('today');
      if (isToday) {
        dt = dt
            .replaceAll(RegExp(r'^today,?\s*', caseSensitive: false), '')
            .trim();
      }
      final bool isYesterday = entry.section.toLowerCase() == 'yesterday' ||
          (call.date ?? '').toLowerCase().contains('yesterday') ||
          (call.day ?? '').toLowerCase().contains('yesterday');
      if (isYesterday) {
        dt = dt
            .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
            .trim();
      }
      return dt;
    }

    final String apiTime = (call.time ?? '').trim();
    final String apiDate = (call.date ?? '').trim();
    final String apiDay = (call.day ?? '').trim();
    final String apiWeek = (call.week ?? '').trim();
    final String sec = (call.section ?? entry.section).trim().toLowerCase();

    String cleanTime = apiTime
        .replaceAll(
        RegExp(r'^(today|yesterday),?\s*', caseSensitive: false), '')
        .trim();

    if (cleanTime.isEmpty && (call.calledAt ?? '').isNotEmpty) {
      final DateTime? dt = DateTime.tryParse(call.calledAt!);
      if (dt != null) {
        final int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final String minute = dt.minute.toString().padLeft(2, '0');
        final String period = dt.hour >= 12 ? 'PM' : 'AM';
        cleanTime = '$hour:$minute $period';
      }
    }

    final bool isToday = sec == 'today' ||
        apiDate.toLowerCase().contains('today') ||
        apiDay.toLowerCase().contains('today');

    if (isToday) {
      return cleanTime.isNotEmpty ? cleanTime : apiTime;
    }

    final bool isYesterday = sec == 'yesterday' ||
        apiDate.toLowerCase().contains('yesterday') ||
        apiDay.toLowerCase().contains('yesterday');

    if (isYesterday) {
      cleanTime = cleanTime
          .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
          .trim();
      if (cleanTime.isNotEmpty) {
        return cleanTime;
      }
      final String timeWithoutYesterday = apiTime
          .replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '')
          .trim();
      return timeWithoutYesterday.isNotEmpty
          ? timeWithoutYesterday
          : 'Yesterday';
    }

    if (apiDay.isNotEmpty &&
        apiDay.toLowerCase() != 'today' &&
        apiDay.toLowerCase() != 'yesterday') {
      final String dayTitle = _capitalize(apiDay);
      return cleanTime.isNotEmpty ? '$dayTitle, $cleanTime' : dayTitle;
    }

    if (apiDate.isNotEmpty) {
      final String formattedDate = _formatDate(apiDate);
      return cleanTime.isNotEmpty
          ? '$formattedDate, $cleanTime'
          : formattedDate;
    }

    if (apiWeek.isNotEmpty) {
      return cleanTime.isNotEmpty ? '$apiWeek, $cleanTime' : apiWeek;
    }

    if ((call.calledAt ?? '').isNotEmpty) {
      final String formattedDate = _formatDate(call.calledAt!);
      return cleanTime.isNotEmpty
          ? '$formattedDate, $cleanTime'
          : formattedDate;
    }

    return cleanTime.isNotEmpty ? cleanTime : apiTime;
  }

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
    final String queryDigits = normalizePhone(query);

    return recentCallList.where((call) {
      final String name = (call['name'] ?? '').toLowerCase().trim();
      final String type = (call['type'] ?? '').toLowerCase();
      final String callerId = (call['callerId'] ?? '').trim();
      final String mobileNo = (call['mobileNo'] ?? '').trim();
      final String groupId = (call['groupId'] ?? '').trim();
      final String day = (call['apiDay'] ?? '').toLowerCase().trim();
      final String date = (call['apiDate'] ?? '').toLowerCase().trim();
      final String week = (call['apiWeek'] ?? '').toLowerCase().trim();
      final String phone = (call['phone'] ?? '').trim();

      final String normalizedCallerId = normalizePhone(callerId);
      final String normalizedMobileNo = normalizePhone(mobileNo);
      final String normalizedPhone = normalizePhone(phone);

      final bool nameMatch = query.isNotEmpty && name.contains(query);

      final bool callerIdMatch = (query.isNotEmpty &&
          callerId.contains(query)) ||
          (queryDigits.isNotEmpty && normalizedCallerId.contains(queryDigits));

      final bool mobileMatch = (query.isNotEmpty &&
          (mobileNo.contains(query) || phone.contains(query))) ||
          (queryDigits.isNotEmpty &&
              (normalizedMobileNo.contains(queryDigits) ||
                  normalizedPhone.contains(queryDigits)));

      final bool t9Match =
          queryDigits.isNotEmpty && _matchesT9(name, queryDigits);

      final bool groupMatch =
          query.isNotEmpty && (groupId.contains(query) || name.contains(query));

      final bool apiDateMatch = query.isNotEmpty &&
          (day.contains(query) || date.contains(query) || week.contains(query));

      final bool matchQuery = query.isEmpty ||
          nameMatch ||
          callerIdMatch ||
          mobileMatch ||
          t9Match ||
          groupMatch ||
          apiDateMatch ||
          type.contains(query);

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

  Map<String, List<Map<String, String>>> get groupedRecentCalls {
    final Map<String, List<Map<String, String>>> groups = {};

    for (final call in filteredRecentCalls) {
      final String rawSec = (call['section'] ?? '').trim();
      final String secTitle = formatSectionTitle(rawSec);

      groups.putIfAbsent(secTitle, () => <Map<String, String>>[]).add(call);
    }

    return groups;
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

  bool get isGroupsLoading => _groupController.groupDataLoading.value;
  String get groupsError => _groupController.responseError.value;
  List<GroupsResData> get groups => _groupController.groupData;

  String get _query {
    if (isDialPadOpen.value && dialNumber.value.trim().isNotEmpty) {
      return dialNumber.value.trim().toLowerCase();
    }
    return searchQuery.value.trim().toLowerCase();
  }

  void switchTab(int index) {
    if (selectedTab.value != index) {
      selectedTab.value = index;
      exitSelectionMode();
    }
    if (isDialPadOpen.value) {
      isDialPadOpen.value = false;
    }
    clearDialNumber();
    clearSearch();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    filterUsers(value);
  }

  void loadGroups() => _groupController.getGroupData();

  List<UserListData> get dialSuggestions {
    final input = dialNumber.value.trim();
    if (input.isEmpty) return [];

    final String queryDigits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (queryDigits.isEmpty) return [];

    final List<UserListData> allSources = [];
    allSources.addAll(allUserProfileData);
    if (Get.isRegistered<ContactController>()) {
      final contactCtrl = Get.find<ContactController>();
      allSources.addAll(contactCtrl.allUserProfileData);
      allSources.addAll(contactCtrl.inviteUsers);
    } else {
      try {
        final contactCtrl = ContactController.instance;
        allSources.addAll(contactCtrl.allUserProfileData);
        allSources.addAll(contactCtrl.inviteUsers);
      } catch (_) {}
    }

    final Set<String> seen = {};
    final List<UserListData> results = [];

    for (final user in allSources) {
      final String rawPhone = (user.mobileNo ?? '').trim();
      final String digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.isEmpty && (user.name ?? '').isEmpty) continue;

      final String normPhone = normalizePhone(rawPhone);
      final String key =
      (user.userId != null) ? 'u_${user.userId}' : 'p_$normPhone';
      if (!seen.add(key)) continue;

      final bool phoneMatch =
          digitsOnly.contains(queryDigits) || normPhone.contains(queryDigits);
      final bool t9Match =
          queryDigits.length >= 2 && _matchesT9(user.name ?? '', queryDigits);

      if (phoneMatch || t9Match) {
        results.add(user);
        if (results.length >= 10) break;
      }
    }

    return results;
  }

  final Set<String> _deletingCallIds = <String>{};
  bool isDeletingCall(String callId) => _deletingCallIds.contains(callId);

  Future<bool> deleteRecentCall(
      Map<String, String> call, {
        @visibleForTesting
        Future<CommonResponse> Function({required String callId})? apiCall,
      }) async {
    final String localEntryId = call['localEntryId'] ?? '';
    final String callId = (call['callId'] ?? call['id'] ?? '').trim();

    if (callId.isEmpty) {
      Utils().fluttertoast("Call ID not found");
      return false;
    }

    if (_deletingCallIds.contains(callId)) {
      return false;
    }
    _deletingCallIds.add(callId);

    try {
      final CommonResponse response = apiCall != null
          ? await apiCall(callId: callId)
          : await CallRepo.deleteSingleCallHistory(callId: callId);

      if (response.status == true) {
        if (localEntryId.isNotEmpty) {
          _recentRaw.removeWhere((e) => e.localId == localEntryId);
          recentCallList.removeWhere((e) => e['localEntryId'] == localEntryId);
        } else {
          final idx =
          _recentRaw.indexWhere((e) => (e.call.id ?? '').trim() == callId);
          if (idx != -1) {
            _recentRaw.removeAt(idx);
          }
          recentCallList.removeWhere((e) => (e['callId'] ?? e['id']) == callId);
        }

        if (_recentRaw.isNotEmpty) {
          _rebuildRecentDisplay();
        }

        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "Call entry deleted");
        return true;
      } else {
        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "Failed to delete call entry");
        return false;
      }
    } catch (e) {
      Utils().fluttertoast("Failed to delete call entry: $e");
      return false;
    } finally {
      _deletingCallIds.remove(callId);
    }
  }

  void enterSelectionMode() {
    isSelectionMode.value = true;
    selectedCallIds.clear();
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedCallIds.clear();
  }

  void toggleCallSelection(String callId) {
    final cleanId = callId.trim();
    if (cleanId.isEmpty) return;
    if (selectedCallIds.contains(cleanId)) {
      selectedCallIds.remove(cleanId);
    } else {
      selectedCallIds.add(cleanId);
    }
  }

  void selectAllCalls() {
    final allIds = recentCallList
        .map((e) => (e['callId'] ?? e['id'] ?? '').trim())
        .where((id) => id.isNotEmpty);
    selectedCallIds.addAll(allIds);
  }

  void clearSelection() {
    selectedCallIds.clear();
  }

  Future<bool> deleteSelectedRecentCalls({
    @visibleForTesting
    Future<CommonResponse> Function({required List<String> callIds})? apiCall,
  }) async {
    if (selectedCallIds.isEmpty || isDeletingMultiple.value) return false;
    isDeletingMultiple.value = true;
    final List<String> idsToDelete = selectedCallIds.toList();

    try {
      final CommonResponse response = apiCall != null
          ? await apiCall(callIds: idsToDelete)
          : await CallRepo.deleteMultipleCallHistory(callIds: idsToDelete);

      if (response.status == true) {
        final Set<String> toRemove = idsToDelete.toSet();
        _recentRaw
            .removeWhere((e) => toRemove.contains((e.call.id ?? '').trim()));
        recentCallList.removeWhere(
                (e) => toRemove.contains((e['callId'] ?? e['id'] ?? '').trim()));

        if (_recentRaw.isNotEmpty) {
          _rebuildRecentDisplay();
        }

        selectedCallIds.clear();
        isSelectionMode.value = false;

        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "Selected calls deleted");
        return true;
      } else {
        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "Failed to delete selected calls");
        return false;
      }
    } catch (e) {
      Utils().fluttertoast("Failed to delete selected calls: $e");
      return false;
    } finally {
      isDeletingMultiple.value = false;
    }
  }

  Future<bool> clearAllRecentCalls({
    @visibleForTesting
    Future<CommonResponse> Function()? apiCall,
  }) async {
    if (isClearingAll.value) return false;
    isClearingAll.value = true;

    try {
      final CommonResponse response = apiCall != null
          ? await apiCall()
          : await CallRepo.clearAllCallHistory();

      if (response.status == true) {
        _recentRaw.clear();
        recentCallList.clear();
        selectedCallIds.clear();
        isSelectionMode.value = false;
        hasMoreRecentCalls.value = false;

        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "All call history cleared");
        return true;
      } else {
        Utils().fluttertoast(response.message?.isNotEmpty == true
            ? response.message!
            : "Failed to clear call history");
        return false;
      }
    } catch (e) {
      Utils().fluttertoast("Failed to clear call history: $e");
      return false;
    } finally {
      isClearingAll.value = false;
    }
  }
}

class _RecentEntry {
  _RecentEntry(this.section, this.call)
      : localId = '${call.id ?? ""}_${_counter++}';

  static int _counter = 0;
  final String localId;
  final String section;
  final CallingDetail call;
}