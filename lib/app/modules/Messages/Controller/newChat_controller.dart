import 'dart:developer';

import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class NewChatController extends GetxController {
  final ContactService _contactService = ContactService();

  var allUsers = <UserListData>[].obs;

  var matchedUsers = <UserListData>[].obs;
  var filteredMatchedUsers = <UserListData>[].obs;

  var otherUsers = <UserListData>[].obs;
  var filteredOtherUsers = <UserListData>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxString responseError = "".obs;

  @override
  void onInit() {
    super.onInit();
    getRegisteredContacts();
  }

  Future<Map<int, int>> _loadPrivateChatIdMap() async {
    final Map<int, int> map = {};

    try {
      final res = await MessageRepo.getChatList(
        page: 1,
        limit: 100,
        type: "private",
        includeArchived: true,
      );

      for (final item in res.data ?? <dynamic>[]) {
        if (item.isGroup == true) continue;

        final int? uid = item.userId;
        final int? cid = item.chatId ?? item.conversationId ?? item.id;

        if (uid != null && cid != null) {
          map[uid] = cid;
        }
      }

      log("CHAT ID MAP => $map");
    } catch (e) {
      log("CHAT ID MAP ERROR => $e");
    }

    return map;
  }

  Future<void> getRegisteredContacts() async {
    try {
      contactLoading.value = true;
      responseError.value = "";

      final List<Contact> deviceContacts = await _contactService.getContacts();

      final results = await Future.wait([
        GroupRepo.getAllUserData(),
        _loadPrivateChatIdMap(),
      ]);

      final result = results[0] as dynamic;
      final Map<int, int> chatIdMap = results[1] as Map<int, int>;

      if (result.status == true) {
        final List<UserListData> users = result.userData ?? [];

        final Map<String, UserListData> registeredMap = {};
        for (var user in users) {
          final String norm = _normalizePhone(user.mobileNo ?? '');
          if (norm.isNotEmpty) {
            registeredMap[norm] = user;
          }
        }

        final List<UserListData> matched = [];
        final List<UserListData> unmatched = [];
        final Set<String> processedPhones = {};

        for (var contact in deviceContacts) {
          for (var phone in contact.phones) {
            final String normalized = _normalizePhone(phone.number);

            if (normalized.length == 10 &&
                !processedPhones.contains(normalized)) {
              processedPhones.add(normalized);

              final String contactDisplayName =
              contact.displayName.trim().isNotEmpty
                  ? contact.displayName.trim()
                  : phone.number;

              if (registeredMap.containsKey(normalized)) {
                final registeredUser = registeredMap[normalized]!;

                final int? resolvedChatId = registeredUser.privateChatId ??
                    registeredUser.chatId ??
                    registeredUser.conversationId ??
                    (registeredUser.userId != null
                        ? chatIdMap[registeredUser.userId!]
                        : null);

                matched.add(UserListData(
                  userId: registeredUser.userId,
                  name: contactDisplayName,
                  mobileNo: phone.number,
                  profileImage: registeredUser.profileImage,
                  isOnline: registeredUser.isOnline,
                  chatId: resolvedChatId,
                  conversationId: registeredUser.conversationId,
                  privateChatId: registeredUser.privateChatId,
                ));
              } else {
                unmatched.add(UserListData(
                  userId: null,
                  name: contactDisplayName,
                  mobileNo: phone.number,
                  profileImage: null,
                ));
              }
            }
          }
        }

        allUsers.value = users;
        matchedUsers.value = matched;
        otherUsers.value = unmatched;

        filterContacts(searchQuery.value);
      } else {
        responseError.value = result.message ?? "Something went wrong";
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      contactLoading.value = false;
    }
  }

  void filterContacts(String query) {
    searchQuery.value = query;
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredMatchedUsers.value = matchedUsers;
      filteredOtherUsers.value = otherUsers;
    } else {
      filteredMatchedUsers.value = matchedUsers.where((user) {
        return (user.name ?? '').toLowerCase().contains(q) ||
            (user.mobileNo ?? '').toLowerCase().contains(q);
      }).toList();

      filteredOtherUsers.value = otherUsers.where((user) {
        return (user.name ?? '').toLowerCase().contains(q) ||
            (user.mobileNo ?? '').toLowerCase().contains(q);
      }).toList();
    }
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
}