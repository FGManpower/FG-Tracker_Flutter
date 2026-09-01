import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallController extends GetxController {
  static CallController get instance => Get.put(CallController());

  final GroupController _groupController = Get.isRegistered<GroupController>()
      ? Get.find<GroupController>()
      : Get.put(GroupController());

  final TextEditingController searchController = TextEditingController();
  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;

  final ContactService _contactService = ContactService();

  RxBool contactLoading = false.obs;
  RxBool isSearching = false.obs;
  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;
  var responseError = "".obs;

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
    {
      'name': 'Manoj Kumar',
      'type': 'Missed Video Call',
      'time': 'Yesterday, 11:20 AM',
      'avatar': 'https://i.pravatar.cc/150?img=15',
    },
    {
      'name': 'Pooja Verma',
      'type': 'Outgoing Audio Call',
      'time': '15 May, 08:30 PM',
      'avatar': 'https://i.pravatar.cc/150?img=48',
    },
    {
      'name': 'Amit Singh',
      'type': 'Incoming Video Call',
      'time': '15 May, 07:10 PM',
      'avatar': 'https://i.pravatar.cc/150?img=68',
    },
    {
      'name': 'Rakesh Patel',
      'type': 'Outgoing Audio Call',
      'time': '15 May, 03:45 PM',
      'avatar': 'https://i.pravatar.cc/150?img=14',
    },
    {
      'name': 'Deepak Sharma',
      'type': 'Outgoing Video Call',
      'time': '14 May, 09:15 PM',
      'avatar': 'https://i.pravatar.cc/150?img=59',
    },
    {
      'name': 'Sahil Mehta',
      'type': 'Missed Audio Call',
      'time': '14 May, 07:40 PM',
      'avatar': 'https://i.pravatar.cc/150?img=32',
    },
    {
      'name': 'Sheetal Gupta',
      'type': 'Outgoing Audio Call',
      'time': '14 May, 05:30 PM',
      'avatar': 'https://i.pravatar.cc/150?img=11',
    },
  ];

  List<Map<String, String>> get filteredRecentCalls {
    final String query = _query;
    if (query.isEmpty) return recentCalls;
    return recentCalls
        .where((call) =>
    (call['name'] ?? '').toLowerCase().contains(query) ||
        (call['type'] ?? '').toLowerCase().contains(query))
        .toList();
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
    filterUsers(value);
  }

  void loadGroups() => _groupController.getGroupData();

  @override
  void onClose() {
    searchController.dispose();
    searchQuery.close();
    selectedTab.close();
    contactLoading.close();
    responseError.close();
    super.onClose();
  }
}
