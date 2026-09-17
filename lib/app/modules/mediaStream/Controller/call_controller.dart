import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/recent_call.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;

class CallController extends GetxController {
  static CallController get instance => Get.isRegistered<CallController>()
      ? Get.find<CallController>()
      : Get.put(CallController());

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

  // Dial pad state
  final RxBool isDialPadOpen = false.obs;
  final RxString dialNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getRegisteredContacts();
    loadGroups();
    getRecentCall();

    // Automatically re-resolve names and avatars when groups or contacts update
    ever(_groupController.groupData, (_) {
      if (_recentRaw.isNotEmpty) {
        _rebuildRecentDisplay();
      }
    });
    ever(allUserProfileData, (_) {
      if (_recentRaw.isNotEmpty) {
        _rebuildRecentDisplay();
      }
    });
  }

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

    isDialPadOpen.close();
    dialNumber.close();
    super.onClose();
  }

  void toggleDialPad() {
    isDialPadOpen.value = !isDialPadOpen.value;
    if (isDialPadOpen.value) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      clearDialNumber();
    }
  }

  void addDigit(String digit) {
    if (dialNumber.value.length >= 15) return;

    dialNumber.value += digit;

    searchController.value = TextEditingValue(
      text: dialNumber.value,
      selection: TextSelection.collapsed(
        offset: dialNumber.value.length,
      ),
    );

    onSearchChanged(dialNumber.value);
  }

  void removeLastDigit() {
    if (dialNumber.value.isEmpty) return;

    dialNumber.value =
        dialNumber.value.substring(0, dialNumber.value.length - 1);

    searchController.value = TextEditingValue(
      text: dialNumber.value,
      selection: TextSelection.collapsed(
        offset: dialNumber.value.length,
      ),
    );

    onSearchChanged(dialNumber.value);
  }

  void clearDialNumber() {
    dialNumber.value = '';
    searchController.clear();
    searchQuery.value = '';
    filteredUsers.value = allUserProfileData;
  }

  void makeCall() {
    if (dialNumber.value.isEmpty) return;
    debugPrint("Calling Number: ${dialNumber.value}");
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
    dialNumber.value = '';
    filteredUsers.value = allUserProfileData;
  }

  Future<void> refreshContacts() async {
    await getRegisteredContacts();
  }

  // =========================================================================
  // STATIC MOCKUP DATA (COMMENTED OUT AS REQUESTED)
  // Dynamic API integration is active below in getRecentCall()
  // =========================================================================
  /*
  final List<Map<String, String>> _staticMockRecentCalls = [
    // --- TODAY ---
    {
      'name': 'Vikram Singh',
      'type': 'Outgoing Video Call',
      'time': 'Today, 10:24 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '101',
      'mobileNo': '9876543210',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Anjali Gupta',
      'type': 'Missed Audio Call',
      'time': 'Today, 09:58 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '102',
      'mobileNo': '9876543211',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Karan Malhotra',
      'type': 'Outgoing Audio Call',
      'time': 'Today, 08:32 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '103',
      'mobileNo': '9876543212',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Neha Yadav',
      'type': 'Outgoing Video Call',
      'time': 'Today, 07:45 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '104',
      'mobileNo': '9876543213',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Sandeep Yadav',
      'type': 'Incoming Audio Call',
      'time': 'Today, 06:12 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '105',
      'mobileNo': '9876543214',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Manoj Kumar',
      'type': 'Missed Video Call',
      'time': 'Today, 04:36 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '106',
      'mobileNo': '9876543215',
      'section': 'today',
      'isOnline': 'false',
    },
    {
      'name': 'Pooja Verma',
      'type': 'Outgoing Audio Call',
      'time': 'Today, 02:17 AM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '107',
      'mobileNo': '9876543216',
      'section': 'today',
      'isOnline': 'true',
    },
    {
      'name': 'Amit Singh',
      'type': 'Outgoing Video Call',
      'time': 'Today, 01:03 AM',
      'avatar': '',
      'callType': 'video',
      'callerId': '108',
      'mobileNo': '9876543217',
      'section': 'today',
      'isOnline': 'false',
    },
    // --- YESTERDAY ---
    {
      'name': 'Rakesh Patel',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 11:20 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '109',
      'mobileNo': '9876543218',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Deepak Sharma',
      'type': 'Outgoing Video Call',
      'time': 'Yesterday, 09:15 PM',
      'avatar': '',
      'callType': 'video',
      'callerId': '110',
      'mobileNo': '9876543219',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Sahil Mehta',
      'type': 'Missed Audio Call',
      'time': 'Yesterday, 07:40 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '111',
      'mobileNo': '9876543220',
      'section': 'yesterday',
      'isOnline': 'false',
    },
    {
      'name': 'Sheetal Gupta',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 05:30 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '112',
      'mobileNo': '9876543221',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Rahul Verma',
      'type': 'Incoming Video Call',
      'time': 'Yesterday, 03:12 PM',
      'avatar': '',
      'callType': 'video',
      'callerId': '113',
      'mobileNo': '9876543222',
      'section': 'yesterday',
      'isOnline': 'true',
    },
    {
      'name': 'Priya Sharma',
      'type': 'Outgoing Audio Call',
      'time': 'Yesterday, 12:45 PM',
      'avatar': '',
      'callType': 'audio',
      'callerId': '114',
      'mobileNo': '9876543223',
      'section': 'yesterday',
      'isOnline': 'true',
    },
  ];
  */

  /// Dynamic API call to fetch real recent calls from backend
  Future<void> getRecentCall() async {
    if (recentCallLoading.value || recentCallLoadingMore.value) return;
    recentCallLoading.value = true;
    recentCallResponseError.value = "";
    try {
      final result = await CallRepo.getRecentCall(
        page: pagination.value.toString(),
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
          if (data.allSections.isNotEmpty) {
            data.allSections.forEach((sec, list) {
              _addBucket(sec, list);
            });
          } else {
            _addBucket('today', data.today);
            _addBucket('yesterday', data.yesterday);
            _addBucket('older', data.older);
          }
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

    String name = [
      contact?.firstName,
      contact?.lastName,
    ].whereType<String>().join(' ').trim();

    String mobileNo = '';
    String avatar = (contact?.avatar ?? '').trim();
    final String callerId = (contact?.id ?? call.callerId ?? '').trim();

    // Check if this is a group call or matches any group in GroupController
    final String targetGroupId =
        (call.groupId ?? contact?.groupId ?? '').trim();

    GroupsResData? matchedGroup;
    if (targetGroupId.isNotEmpty) {
      final int? gId = int.tryParse(targetGroupId);
      matchedGroup = _groupController.groupData.firstWhereOrNull(
        (g) =>
            (g.id != null && g.id == gId) ||
            g.id?.toString() == targetGroupId,
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

      final String groupImg = (matchedGroup?.groupProfile ??
              call.groupProfile ??
              '')
          .trim();
      if (groupImg.isNotEmpty) {
        avatar = groupImg;
      }

      memberCount = matchedGroup?.memberCount?.toString() ??
          call.memberCount?.toString() ??
          '0';
    } else {
      // Direct 1-on-1 contact matching
      if (callerId.isNotEmpty) {
        final int? contactUserId = int.tryParse(callerId);

        if (contactUserId != null) {
          final UserListData? matchedUser = allUserProfileData.firstWhereOrNull(
            (user) => user.userId == contactUserId,
          );

          if (matchedUser != null) {
            mobileNo = matchedUser.mobileNo ?? '';
            if ((name.isEmpty || name.toLowerCase() == 'unknown') &&
                (matchedUser.name ?? '').isNotEmpty) {
              name = matchedUser.name!.trim();
            }
            if (avatar.isEmpty && (matchedUser.profileImage ?? '').isNotEmpty) {
              avatar = matchedUser.profileImage!.trim();
            }
          }
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

    if (status.contains('missed')) return 'Missed $groupTag$kind Call';
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('declin')) {
      return 'Cancelled $groupTag$kind Call';
    }
    if (direction.contains('in')) return 'Incoming $groupTag$kind Call';
    if (direction.contains('out')) return 'Outgoing $groupTag$kind Call';
    return '$groupTag$kind Call';
  }

  String _composeTimeLabel(_RecentEntry entry) {
    final CallingDetail call = entry.call;

    // 1. If API provides display_time directly, use it
    if ((call.displayTime ?? '').trim().isNotEmpty) {
      String dt = call.displayTime!.trim();
      final bool isToday = entry.section.toLowerCase() == 'today' ||
          (call.date ?? '').toLowerCase().contains('today') ||
          (call.day ?? '').toLowerCase().contains('today');
      if (isToday) {
        dt = dt.replaceAll(RegExp(r'^today,?\s*', caseSensitive: false), '').trim();
      }
      final bool isYesterday = entry.section.toLowerCase() == 'yesterday' ||
          (call.date ?? '').toLowerCase().contains('yesterday') ||
          (call.day ?? '').toLowerCase().contains('yesterday');
      if (isYesterday) {
        dt = dt.replaceAll(RegExp(r'^yesterday,?\s*', caseSensitive: false), '').trim();
      }
      return dt;
    }

    // 2. Direct values from API
    final String apiTime = (call.time ?? '').trim();
    final String apiDate = (call.date ?? '').trim();
    final String apiDay = (call.day ?? '').trim();
    final String apiWeek = (call.week ?? '').trim();
    final String sec = (call.section ?? entry.section).trim().toLowerCase();

    // Clean any leading "Today, " or "Yesterday, " prefix from time
    String cleanTime = apiTime
        .replaceAll(RegExp(r'^(today|yesterday),?\s*', caseSensitive: false), '')
        .trim();

    // Fallback if time is completely empty in API
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

    // For Today: Only show API time (e.g. "5:05 AM")
    if (isToday) {
      return cleanTime.isNotEmpty ? cleanTime : apiTime;
    }

    final bool isYesterday = sec == 'yesterday' ||
        apiDate.toLowerCase().contains('yesterday') ||
        apiDay.toLowerCase().contains('yesterday');

    // For Yesterday: Only show API time (e.g. "3:34 PM")
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
      return timeWithoutYesterday.isNotEmpty ? timeWithoutYesterday : 'Yesterday';
    }

    // Weekday name from API (e.g. "Monday, 5:05 AM")
    if (apiDay.isNotEmpty &&
        apiDay.toLowerCase() != 'today' &&
        apiDay.toLowerCase() != 'yesterday') {
      final String dayTitle = _capitalize(apiDay);
      return cleanTime.isNotEmpty ? '$dayTitle, $cleanTime' : dayTitle;
    }

    // Date from API (e.g. "15 Sep, 5:19 PM")
    if (apiDate.isNotEmpty) {
      final String formattedDate = _formatDate(apiDate);
      return cleanTime.isNotEmpty ? '$formattedDate, $cleanTime' : formattedDate;
    }

    // Week from API (e.g. "This Week")
    if (apiWeek.isNotEmpty) {
      return cleanTime.isNotEmpty ? '$apiWeek, $cleanTime' : apiWeek;
    }

    if ((call.calledAt ?? '').isNotEmpty) {
      final String formattedDate = _formatDate(call.calledAt!);
      return cleanTime.isNotEmpty ? '$formattedDate, $cleanTime' : formattedDate;
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
    final String queryDigits = _normalizePhone(query);

    debugPrint("========== RECENT SEARCH ==========");
    debugPrint("Query: $query");
    debugPrint("Query Digits: $queryDigits");

    return recentCallList.where((call) {
      final String name = (call['name'] ?? '').toLowerCase().trim();
      final String type = (call['type'] ?? '').toLowerCase();
      final String callerId = (call['callerId'] ?? '').trim();
      final String mobileNo = (call['mobileNo'] ?? '').trim();
      final String groupId = (call['groupId'] ?? '').trim();
      final String day = (call['apiDay'] ?? '').toLowerCase().trim();
      final String date = (call['apiDate'] ?? '').toLowerCase().trim();
      final String week = (call['apiWeek'] ?? '').toLowerCase().trim();

      final String normalizedCallerId = _normalizePhone(callerId);
      final String normalizedMobileNo = _normalizePhone(mobileNo);

      final bool nameMatch =
          query.isNotEmpty && name.contains(query);

      final bool callerIdMatch =
          queryDigits.isNotEmpty &&
              normalizedCallerId.contains(queryDigits);

      final bool mobileMatch =
          queryDigits.isNotEmpty &&
              normalizedMobileNo.contains(queryDigits);

      final bool groupMatch =
          query.isNotEmpty && (groupId.contains(query) || name.contains(query));

      final bool apiDateMatch = query.isNotEmpty &&
          (day.contains(query) || date.contains(query) || week.contains(query));

      debugPrint(
        "CALL => name=$name | callerId=$callerId | mobileNo=$mobileNo | groupId=$groupId",
      );

      debugPrint(
        "MATCH => name=$nameMatch | callerId=$callerIdMatch | mobile=$mobileMatch | group=$groupMatch",
      );

      final bool matchQuery =
          query.isEmpty ||
              nameMatch ||
              callerIdMatch ||
              mobileMatch ||
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
      final String secTitle = _formatSectionTitle(rawSec);

      groups.putIfAbsent(secTitle, () => <Map<String, String>>[]).add(call);
    }

    return groups;
  }

  String _formatSectionTitle(String raw) {
    if (raw.isEmpty) return 'Recent';
    final lower = raw.toLowerCase().replaceAll(RegExp(r'[_-]'), ' ').trim();
    if (lower == 'today') return 'Today';
    if (lower == 'yesterday') return 'Yesterday';
    if (lower == 'this week' || lower == 'thisweek' || lower == 'week') {
      return 'This Week';
    }
    if (lower == 'last week' || lower == 'lastweek') return 'Last Week';
    if (lower == 'older') return 'Older';

    // Capitalize words
    return lower.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
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

  String get _query => searchQuery.value.trim().toLowerCase();

  void switchTab(int index) => selectedTab.value = index;

  void onSearchChanged(String value) {
    searchQuery.value = value;
    dialNumber.value = value;
    filterUsers(value);
  }

  void loadGroups() => _groupController.getGroupData();
}

class _RecentEntry {
  _RecentEntry(this.section, this.call);

  final String section;
  final CallingDetail call;
}
