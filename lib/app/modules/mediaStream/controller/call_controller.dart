import 'package:fgtracker/app/Model/GroupRes.dart';
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

  static const List<Map<String, String>> allContacts = [
    {
      'name': 'Vikram Singh',
      'phone': '+91 98765 43211',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Anjali Gupta',
      'phone': '+91 87654 32110',
      'avatar': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Karan Malhotra',
      'phone': '+91 76543 21099',
      'avatar': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'name': 'Sandeep Yadav',
      'phone': '+91 65432 10988',
      'avatar': 'https://i.pravatar.cc/150?img=4',
    },
    {
      'name': 'Manoj Kumar',
      'phone': '+91 54321 09876',
      'avatar': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Rakesh Patel',
      'phone': '+91 98760 11223',
      'avatar': 'https://i.pravatar.cc/150?img=6',
    },
    {
      'name': 'Deepak Sharma',
      'phone': '+91 87650 44321',
      'avatar': 'https://i.pravatar.cc/150?img=7',
    },
    {
      'name': 'Pooja Verma',
      'phone': '+91 76540 33211',
      'avatar': 'https://i.pravatar.cc/150?img=8',
    },
    {
      'name': 'Amit Singh',
      'phone': '+91 65430 22109',
      'avatar': 'https://i.pravatar.cc/150?img=9',
    },
    {
      'name': 'Sahil Mehta',
      'phone': '+91 54320 11098',
      'avatar': 'https://i.pravatar.cc/150?img=10',
    },
    {
      'name': 'Neha Yadav',
      'phone': '+91 98761 55432',
      'avatar': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Gaurav Kumar',
      'phone': '+91 87651 66778',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Sheetal Gupta',
      'phone': '+91 76541 77889',
      'avatar': 'https://i.pravatar.cc/150?img=13',
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

  List<Map<String, String>> get filteredContacts {
    final String query = _query;
    if (query.isEmpty) return allContacts;
    return allContacts
        .where((contact) =>
    (contact['name'] ?? '').toLowerCase().contains(query) ||
        (contact['phone'] ?? '').toLowerCase().contains(query))
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

  void onSearchChanged(String value) => searchQuery.value = value;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void loadGroups() => _groupController.getGroupData();

  @override
  void onClose() {
    searchController.dispose();
    searchQuery.close();
    selectedTab.close();
    super.onClose();
  }
}
