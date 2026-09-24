import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Model/GetMessage.dart';
import '../../../Model/ForwardMessageModel.dart';
import '../../../Model/MemberDataRes.dart';
import '../Views/Chat_Screen.dart';
import '../Views/ChatList_Screen.dart';
import 'MessageController.dart';

class ForwardMessageController extends GetxController {
  late MessageData message;

  final TextEditingController searchController = TextEditingController();

  final RxList<ForwardDestination> destinations = <ForwardDestination>[].obs;
  final RxList<ForwardDestination> filteredDestinations =
      <ForwardDestination>[].obs;
  final RxList<ForwardDestination> selectedDestinations =
      <ForwardDestination>[].obs;

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
        return;
      }

      destinations.assignAll(response.destinations);
      filteredDestinations.assignAll(response.destinations);
    } catch (e) {
      responseError.value = "Unable to load forward list.";
      destinations.clear();
      filteredDestinations.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshForwardList() async {
    await loadForwardList();
  }

  void search(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredDestinations.assignAll(destinations);
      return;
    }

    filteredDestinations.assignAll(
      destinations.where((destination) {
        return destination.displayName.toLowerCase().contains(query);
      }).toList(),
    );
  }

  void clearSearch() {
    searchController.clear();
    filteredDestinations.assignAll(destinations);
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

  List<ForwardDestination> get users {
    return filteredDestinations
        .where((destination) => !destination.isGroup)
        .toList();
  }

  List<ForwardDestination> get groups {
    return filteredDestinations
        .where((destination) => destination.isGroup)
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
              userId: destination.targetId!,
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

      final bool isSinglePerson = selected.length == 1 &&
          !selected.first.isGroup &&
          selected.first.targetId != null;

      if (isSinglePerson) {
        await _openPrivateChat(selected.first);
      } else {
        _replaceStackWithChatList(instant: false);
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

  void _replaceStackWithChatList({required bool instant}) {
    Get.offUntil(
      GetPageRoute(
        page: () => ChatListScreen(),
        transition: instant ? Transition.noTransition : null,
        transitionDuration:
            instant ? Duration.zero : const Duration(milliseconds: 300),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> _openPrivateChat(ForwardDestination destination) async {
    final userData = MemberData(
      userId: destination.targetId!,
      name: destination.displayName,
      profileImage: destination.displayImage,
      groupId: 0,
    );

    _replaceStackWithChatList(instant: true);

    await Future.delayed(const Duration(milliseconds: 50));

    Get.to(
      () => ChatScreen(),
      arguments: {
        "userData": userData,
      },
      binding: BindingsBuilder(() {
        Get.put(MessageController());
      }),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
