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
    getRecentCall();
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
    final String callerId = (contact?.id ?? '').trim();

    if (callerId.isNotEmpty) {
      final int? contactUserId = int.tryParse(callerId);

      if (contactUserId != null) {
        final UserListData? matchedUser = allUserProfileData.firstWhereOrNull(
          (user) => user.userId == contactUserId,
        );

        if (matchedUser != null) {
          mobileNo = matchedUser.mobileNo ?? '';
          if (name.isEmpty && (matchedUser.name ?? '').isNotEmpty) {
            name = matchedUser.name!.trim();
          }
          if (avatar.isEmpty && (matchedUser.profileImage ?? '').isNotEmpty) {
            avatar = matchedUser.profileImage!.trim();
          }
        }
      }
    }

    return {
      'name': name.isEmpty ? 'Unknown' : name,
      'phone': mobileNo.isNotEmpty ? mobileNo : callerId,
      'type': _composeTypeLabel(call),
      'time': _composeTimeLabel(entry),
      'avatar': avatar,
      'callType': (call.type ?? '').trim(),
      'callerId': callerId,
      'mobileNo': mobileNo,
      'section': entry.section.trim().toLowerCase(),
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

      debugPrint(
        "CALL => name=$name | callerId=$callerId | mobileNo=$mobileNo",
      );

      debugPrint(
        "MATCH => name=$nameMatch | callerId=$callerIdMatch | mobile=$mobileMatch",
      );

      final bool matchQuery =
          query.isEmpty ||
              nameMatch ||
              callerIdMatch ||
              mobileMatch ||
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
    final Map<String, List<Map<String, String>>> groups = {
      'Today': <Map<String, String>>[],
      'Yesterday': <Map<String, String>>[],
      'Older': <Map<String, String>>[],
    };

    for (final call in filteredRecentCalls) {
      final String sec = (call['section'] ?? '').toLowerCase();
      if (sec == 'today') {
        groups['Today']!.add(call);
      } else if (sec == 'yesterday') {
        groups['Yesterday']!.add(call);
      } else {
        groups['Older']!.add(call);
      }
    }

    groups.removeWhere((key, value) => value.isEmpty);
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
