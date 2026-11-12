import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart' show normalizePhone;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import '../../../Model/GetMessage.dart';
import '../../../Model/ForwardMessageModel.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../Core/util/chat_navigation.dart';
import '../../call/Controller/contact_controller.dart';
import 'MessageController.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // TODO(fwd-diagnostics)
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
      _fwdLogResponse(response); // TODO(fwd-diagnostics)

      if (response.status == false) {
        responseError.value =
            response.message ?? appL10n.chatList_forwardListLoadFailed;

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

      // Recent chats = every chat the server returns (like the Chat List and
      // WhatsApp). The address-book match used to DROP private chats with
      // people not saved in the phone contacts (and all of them when contacts
      // permission was off); now it only shows the saved contact name.
      for (final item in response.recentChats) {
        if (!item.isGroup) matchWithContacts(item);
      }
      final List<ForwardDestination> matchedRecent =
          _sortLikeChatList(_dedupeByChatKey(response.recentChats));

      if (kDebugMode) {
        debugPrint('[FWD] phoneBook=${phoneBook.length} '
            'recent: server=${response.recentChats.length} '
            '(private=${response.recentChats.where((d) => !d.isGroup).length} '
            'group=${response.recentChats.where((d) => d.isGroup).length}) '
            '-> after address-book filter=${matchedRecent.length} | '
            'destinations: server=${response.destinations.length} '
            'groups=${groupList.length} matchedUsers=${matchedUsers.length}'); // TODO(fwd-diagnostics)
      }

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
      responseError.value = appL10n.chatList_forwardListLoadFailed;
      destinations.clear();
      filteredDestinations.clear();
      _clearDisplayLists();
    } finally {
      isLoading.value = false;
    }
  }

  /// One row per chat: "group_<id>" / "private_<id>", so a private chat and a
  /// group with the same id are never merged. Rows without an id are kept.
  List<ForwardDestination> _dedupeByChatKey(List<ForwardDestination> items) {
    final seen = <String>{};
    return [
      for (final d in items)
        if (d.targetId == null || seen.add('${d.type}_${d.targetId}')) d,
    ];
  }

  /// Chat List order: pinned first, then newest activity. Rows without a
  /// time keep the server's order (stable sort).
  List<ForwardDestination> _sortLikeChatList(List<ForwardDestination> items) {
    DateTime? at(ForwardDestination d) =>
        DateTime.tryParse(d.lastActivityAt ?? '')?.toUtc();
    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      if (a.$2.isPinned != b.$2.isPinned) return a.$2.isPinned ? -1 : 1;
      final ta = at(a.$2);
      final tb = at(b.$2);
      if (ta != null && tb != null && ta != tb) return tb.compareTo(ta);
      return a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// TEMPORARY [FWD] diagnostics (debug builds only).
  /// TODO(fwd-diagnostics): remove after the fix is confirmed.
  void _fwdLogResponse(ForwardListResponse r) {
    if (!kDebugMode) return;
    String row(ForwardDestination d) =>
        '{type=${d.type} id=${d.id} userId=${d.userId} groupId=${d.groupId} '
        'targetId=${d.targetId} name=${d.name} mobileNo=${d.mobileNo}}';
    debugPrint('[FWD] GET /forward/list (no page/limit) status=${r.status} '
        'recentChats=${r.recentChats.length} destinations=${r.destinations.length}');
    for (final d in r.recentChats.take(3)) {
      debugPrint('[FWD] recent sample ${row(d)}');
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
        appL10n.chatList_selectDestination,
        appL10n.chatList_selectDestinationMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (message.id == null) {
      Get.snackbar(
        appL10n.common_error,
        appL10n.chatList_messageIdMissing,
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
        content: message.content?.toString(),
        messageType: message.messageType?.toString(),
        images: message.images,
        videos: message.videos?.map((v) => v.toJson()).toList(),
        caption: message.caption?.toString(),
      );

      if (response.status == false) {
        Get.snackbar(
          appL10n.common_error,
          response.message ?? appL10n.chatList_forwardFailed,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Proactively broadcast real-time socket events to recipients so they receive full message data instantly
      for (final dest in selected) {
        try {
          if (dest.isGroup && dest.targetId != null) {
            SocketMessageService.instance.forwardMessage(
              messageId: message.id!,
              groupId: dest.targetId,
              content: message.content,
              messageType: message.messageType,
              images: message.images,
              videos: message.videos?.map((v) => v.toJson()).toList(),
              caption: message.caption,
            );
          } else if (!dest.isGroup && dest.targetId != null) {
            SocketMessageService.instance.forwardMessage(
              messageId: message.id!,
              receiverId: dest.targetId!.toString(),
              content: message.content,
              messageType: message.messageType,
              images: message.images,
              videos: message.videos?.map((v) => v.toJson()).toList(),
              caption: message.caption,
            );
          }
        } catch (socketErr) {
          AppLog.d("Failed to emit forwardMessage socket event: $socketErr");
        }
      }

      Utils().fluttertoast(appL10n.chatList_messageForwarded);

      final bool isSingle = selected.length == 1;

      if (isSingle) {
        final target = selected.first;
        Get.back();

        // ChatNavigation: forwarding from inside a chat to another chat of
        // the same type used to be ignored (duplicate route).
        if (target.isGroup) {
          ChatNavigation.openGroupChat({
            "groupId": target.targetId,
            "groupName": target.displayName,
            "groupProfile": target.displayImage,
            "groupImage": target.displayImage,
          });
        } else {
          final userData = MemberData(
            userId: target.targetId!,
            name: target.displayName,
            profileImage: target.displayImage,
            groupId: 0,
          );
          ChatNavigation.openPrivateChat({
            "userData": userData,
            "type": "chatScreen",
            "chatType": "private",
          });
        }
      } else {
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        appL10n.common_error,
        appL10n.chatList_forwardFailed,
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