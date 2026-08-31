import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Model/GetMessage.dart';
import '../../../Model/GroupRes.dart';
import '../../../Model/user_profileList_res.dart';
import '../../../modules/Group/controller/search_controller.dart';
import '../../Group/controller/Group_Controller.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';

class ForwardMessageController extends GetxController {
  late MessageData message;
  late SearchUserController userController;
  late GroupController groupController;
  final TextEditingController searchController = TextEditingController();
  final RxList<UserListData> filteredUsers = <UserListData>[].obs;
  final RxList<GroupsResData> filteredGroups = <GroupsResData>[].obs;
  final RxList<UserListData> selectedUsers = <UserListData>[].obs;

  final RxList<GroupsResData> selectedGroups = <GroupsResData>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments == null || arguments["message"] == null) {
      Get.back();
      return;
    }

    message = arguments["message"] as MessageData;

    userController = Get.isRegistered<SearchUserController>()
        ? Get.find<SearchUserController>()
        : Get.put(SearchUserController());

    groupController = Get.isRegistered<GroupController>()
        ? Get.find<GroupController>()
        : Get.put(GroupController());
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      if (userController.allUserProfileData.isEmpty) {
        await userController.getRegisteredContacts();
      }
      if (groupController.groupData.isEmpty) {
        await groupController.getGroupData();
      }
      filteredUsers.assignAll(
        userController.allUserProfileData,
      );
      final groups = <GroupsResData>[
        ...groupController.groupData,
      ];
      filteredGroups.assignAll(groups);
    } catch (e) {
      debugPrint(
        "ForwardMessageController loadData error: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void search(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredUsers.assignAll(
        userController.allUserProfileData,
      );

      filteredGroups.assignAll([
        ...groupController.groupData,
      ]);

      return;
    }

    filteredUsers.assignAll(
      userController.allUserProfileData.where((user) {
        final name = (user.name ?? "").toLowerCase();

        final mobile = (user.mobileNo ?? "").toLowerCase();

        return name.contains(query) || mobile.contains(query);
      }).toList(),
    );

    final groups = <GroupsResData>[
      ...groupController.groupData,
    ];

    filteredGroups.assignAll(
      groups.where((group) {
        final groupName = (group.groupName ?? "").toLowerCase();

        return groupName.contains(query);
      }).toList(),
    );
  }

  void clearSearch() {
    searchController.clear();

    filteredUsers.assignAll(
      userController.allUserProfileData,
    );

    filteredGroups.assignAll([
      ...groupController.groupData,
    ]);
  }

  bool isUserSelected(UserListData user) {
    return selectedUsers.any(
      (selected) => selected.userId.toString() == user.userId.toString(),
    );
  }

  void toggleUser(UserListData user) {
    final index = selectedUsers.indexWhere(
      (selected) => selected.userId.toString() == user.userId.toString(),
    );

    if (index != -1) {
      selectedUsers.removeAt(index);
    } else {
      selectedUsers.add(user);
    }
  }

  bool isGroupSelected(GroupsResData group) {
    return selectedGroups.any(
      (selected) => selected.id == group.id,
    );
  }

  void toggleGroup(GroupsResData group) {
    final index = selectedGroups.indexWhere(
      (selected) => selected.id == group.id,
    );

    if (index != -1) {
      selectedGroups.removeAt(index);
    } else {
      selectedGroups.add(group);
    }
  }

  int get selectedCount => selectedUsers.length + selectedGroups.length;

  bool get hasSelection => selectedCount > 0;

  Future<void> forwardMessage() async {
    if (!hasSelection) {
      Get.snackbar(
        "Select Destination",
        "Please select at least one person or group.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final socketService = SocketMessageService.instance;

      for (final user in selectedUsers) {
        final receiverId = user.userId?.toString();

        if (receiverId == null || receiverId.isEmpty) {
          continue;
        }

        socketService.forwardMessage(
          messageId: message.id!,
          receiverId: receiverId,
          groupId: null,
        );
      }

      // Forward to selected groups
      for (final group in selectedGroups) {
        final groupId = group.id;

        if (groupId == null) {
          continue;
        }

        socketService.forwardMessage(
          messageId: message.id!,
          receiverId: null,
          groupId: groupId,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to send forward request.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
