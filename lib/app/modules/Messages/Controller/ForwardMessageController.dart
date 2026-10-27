import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart' show normalizePhone;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Model/GetMessage.dart';
import '../../../Model/ForwardMessageModel.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../routes/app_pages.dart';
import '../../call/Controller/contact_controller.dart';
import 'MessageController.dart';

class ForwardMessageController extends GetxController {
  late MessageData message;

  final TextEditingController searchController = TextEditingController();

  final RxList<ForwardDestination> destinations = <ForwardDestination>[].obs;
  final RxList<ForwardDestination> filteredDestinations =
      <ForwardDestination>[].obs;
  final RxList<ForwardDestination> selectedDestinations =
      <ForwardDestination>[].obs;
  final RxList<ForwardDestination> recentChats =
      <ForwardDestination>[].obs;

  final RxList<ForwardDestination> allGroups =
      <ForwardDestination>[].obs;

  final RxList<ForwardDestination> myContacts =
      <ForwardDestination>[].obs;

  final RxList<ForwardDestination> otherContacts =
      <ForwardDestination>[].obs;

  final List<ForwardDestination> _allRecentChats = [];
  final List<ForwardDestination> _allGroups = [];
  final List<ForwardDestination> _allMyContacts = [];
  final List<ForwardDestination> _allOtherContacts = [];
  final RxBool isLoading = false.obs;
  final RxBool isForwarding = false.obs;
  late String sourceType;
  final RxString responseError = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments == null || arguments["message"] == null) {
      Get.back();
      return;
    }

    message = arguments["message"] as MessageData;
    sourceType = arguments["sourceType"] ?? "private";

    loadForwardList();
  }

  Future<void> _ensurePhoneBook(ContactController contactController) async {
    if (contactController.phoneContactNameMap.isNotEmpty) return;

    if (!contactController.isContactPermissionGranted.value) {
      await contactController.checkContactPermission();
    } else if (!contactController.contactLoading.value) {
      await contactController.getRegisteredContacts();
    }

    // Agar contacts pehle se load ho rahe hain to complete hone ka wait karo
    int tries = 0;
    while (contactController.contactLoading.value && tries < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      tries++;
    }
  }

  Future<void> loadForwardList() async {
    try {
      isLoading.value = true;
      responseError.value = '';

      final response = await MessageRepo.getForwardList();

      if (response.status == false) {
        responseError.value =
            response.message ?? "Unable to load forward list.";

        destinations.clear();
        filteredDestinations.clear();
        _clearDisplayLists();
        return;
      }

      final contactController = ContactController.instance;
      await _ensurePhoneBook(contactController);

      final phoneBook = contactController.phoneContactNameMap;
      bool matchWithContacts(ForwardDestination user) {
        final phone = normalizePhone(user.mobileNo ?? '');
        if (phone.isEmpty) return false;

        final contactName = phoneBook[phone];
        if (contactName == null || contactName.trim().isEmpty) return false;

        user.name = contactName.trim();
        return true;
      }

      final List<ForwardDestination> matchedUsers = response.destinations
          .where((item) => !item.isGroup && matchWithContacts(item))
          .toList();

      final List<ForwardDestination> groupList =
      response.destinations.where((item) => item.isGroup).toList();

      final List<ForwardDestination> matchedRecent = response.recentChats
          .where((item) => item.isGroup || matchWithContacts(item))
          .toList();

      destinations.assignAll([...groupList, ...matchedUsers]);
      filteredDestinations.assignAll([...groupList, ...matchedUsers]);

      _allRecentChats
        ..clear()
        ..addAll(matchedRecent);

      _allGroups
        ..clear()
        ..addAll(groupList);

      _allMyContacts
        ..clear()
        ..addAll(matchedUsers);

      _allOtherContacts.clear();

      _applyForwardSearch(searchController.text);
    } catch (e) {
      responseError.value = "Unable to load forward list.";
      destinations.clear();
      filteredDestinations.clear();
      _clearDisplayLists();
    } finally {
      isLoading.value = false;
    }
  }

  void _clearDisplayLists() {
    _allRecentChats.clear();
    _allGroups.clear();
    _allMyContacts.clear();
    _allOtherContacts.clear();

    recentChats.clear();
    allGroups.clear();
    myContacts.clear();
    otherContacts.clear();
  }

  void _applyForwardSearch(String value) {
    final query = value.trim().toLowerCase();

    bool matches(ForwardDestination item) {
      return item.displayName.toLowerCase().contains(query) ||
          (item.mobileNo ?? '').toLowerCase().contains(query);
    }

    recentChats.assignAll(
      _allRecentChats.where(matches),
    );

    allGroups.assignAll(
      _allGroups.where(matches),
    );

    myContacts.assignAll(
      _allMyContacts.where(matches),
    );

    otherContacts.assignAll(
      _allOtherContacts.where(matches),
    );

    filteredDestinations.assignAll(
      destinations.where(matches),
    );
  }

  Future<void> refreshForwardList() async {
    await loadForwardList();
  }

  void search(String value) {
    _applyForwardSearch(value);
  }

  void clearSearch() {
    searchController.clear();
    _applyForwardSearch('');
  }

  bool isSelected(ForwardDestination destination) {
    final targetId = destination.targetId;

    if (targetId == null) return false;

    return selectedDestinations.any(
          (selected) =>
      selected.type == destination.type && selected.targetId == targetId,
    );
  }

  void toggleDestination(ForwardDestination destination) {
    final targetId = destination.targetId;

    if (targetId == null) return;

    final index = selectedDestinations.indexWhere(
          (selected) =>
      selected.type == destination.type && selected.targetId == targetId,
    );

    if (index != -1) {
      selectedDestinations.removeAt(index);
    } else {
      selectedDestinations.add(destination);
    }
  }

  int get selectedCount => selectedDestinations.length;

  bool get hasSelection => selectedDestinations.isNotEmpty;

  bool _hasName(ForwardDestination destination) {
    return ('${destination.name ?? ''}').trim().isNotEmpty;
  }

  List<ForwardDestination> get users {
    return filteredDestinations
        .where((destination) => !destination.isGroup && _hasName(destination))
        .toList();
  }

  List<ForwardDestination> get groups {
    return filteredDestinations
        .where((destination) => destination.isGroup)
        .toList();
  }

  List<ForwardDestination> get numberUsers {
    return filteredDestinations
        .where((destination) => !destination.isGroup && !_hasName(destination))
        .toList();
  }

  Future<void> forwardMessage() async {
    if (isForwarding.value) return;

    if (!hasSelection) {
      Get.snackbar(
        "Select Destination",
        "Please select at least one person or group.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (message.id == null) {
      Get.snackbar(
        "Error",
        "Message ID is missing.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isForwarding.value = true;

      final selected = List<ForwardDestination>.from(selectedDestinations);

      final targets = selected
          .where((destination) => destination.targetId != null)
          .map(
            (destination) => ForwardTarget(
          type: destination.isGroup ? "group" : "private",
          userId: destination.isGroup ? null : destination.targetId!,
          groupId: destination.isGroup ? destination.targetId! : null,
        ),
      )
          .toList();

      final response = await MessageRepo.forwardMessage(
        messageId: message.id!,
        sourceType: sourceType,
        targets: targets,
      );

      if (response.status == false) {
        Get.snackbar(
          "Error",
          response.message ?? "Unable to forward message.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Utils().fluttertoast("Message forwarded");

      final bool isSingle = selected.length == 1;

      if (isSingle) {
        final target = selected.first;
        Get.back();

        if (target.isGroup) {
          Get.toNamed(
            Routes.groupChatScreen,
            arguments: {
              "groupId": target.targetId,
              "groupName": target.displayName,
              "groupProfile": target.displayImage,
              "groupImage": target.displayImage,
            },
          );
        } else {
          final userData = MemberData(
            userId: target.targetId!,
            name: target.displayName,
            profileImage: target.displayImage,
            groupId: 0,
          );
          Get.toNamed(
            Routes.chatScreen,
            arguments: {
              "userData": userData,
            },
          );
        }
      } else {
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to forward message.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isForwarding.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}