import 'dart:developer';

import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

/// One phonebook number, already de-duplicated.
class PhonebookEntry {
  final String name;
  final String phone;
  final String norm;
  const PhonebookEntry(this.name, this.phone, this.norm);
}

class ContactMatchResult {
  /// Phonebook contacts that are FG users (phonebook name + number,
  /// server id / photo / online / chat id).
  final List<UserListData> matched;

  /// Phonebook contacts not on the app (invite list).
  final List<UserListData> unmatched;

  const ContactMatchResult(this.matched, this.unmatched);
}

/// The single source of truth for "which phonebook contacts are on FG".
///
/// Used by All Contacts (`NewChatController`) and the Calls → Contacts tab
/// (`ContactController`) so both screens always show the same people, the
/// same names, the same numbers and the same order.
class ContactMatcher {
  ContactMatcher._();

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  /// Digits only, Indian `91` prefix dropped, last 10 digits kept.
  static String normalizePhone(String phone) {
    String digits = phone.replaceAll(_nonDigit, '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  /// Phonebook numbers in phonebook order, one entry per 10-digit number.
  /// A contact without a name uses its number as the name.
  static List<PhonebookEntry> buildEntries(List<Contact> deviceContacts) {
    final List<PhonebookEntry> entries = [];
    final Set<String> seen = {};

    for (final contact in deviceContacts) {
      final String name = contact.displayName.trim();
      for (final phone in contact.phones) {
        final String norm = normalizePhone(phone.number);
        if (norm.length != 10 || !seen.add(norm)) continue;
        entries.add(PhonebookEntry(
          name.isNotEmpty ? name : phone.number,
          phone.number,
          norm,
        ));
      }
    }
    return entries;
  }

  /// Splits the phonebook into FG users and invites using `/getAllUser`.
  /// The logged-in user (and their own number saved in the phonebook) is
  /// left out of both lists.
  static ContactMatchResult match(
    List<PhonebookEntry> entries,
    List<UserListData> users, {
    String? ownUserId,
  }) {
    final Map<String, UserListData> registeredMap = {};
    String? myNorm;

    for (final user in users) {
      final String norm = normalizePhone(user.mobileNo ?? '');

      if (ownUserId != null && user.userId?.toString() == ownUserId) {
        if (norm.isNotEmpty) myNorm = norm;
        continue;
      }

      if (norm.isNotEmpty) {
        registeredMap[norm] = user;
      }
    }

    final List<UserListData> matched = [];
    final List<UserListData> unmatched = [];

    for (final e in entries) {
      if (myNorm != null && e.norm == myNorm) continue;

      final registeredUser = registeredMap[e.norm];
      if (registeredUser != null) {
        matched.add(UserListData(
          userId: registeredUser.userId,
          name: e.name,
          mobileNo: e.phone,
          profileImage: registeredUser.profileImage,
          isOnline: registeredUser.isOnline,
          chatId: registeredUser.privateChatId ??
              registeredUser.chatId ??
              registeredUser.conversationId,
          conversationId: registeredUser.conversationId,
          privateChatId: registeredUser.privateChatId,
        ));
      } else {
        unmatched.add(UserListData(
          userId: null,
          name: e.name,
          mobileNo: e.phone,
          profileImage: null,
        ));
      }
    }

    return ContactMatchResult(matched, unmatched);
  }

  /// userId → private chat id, from the user's chat list.
  static Future<Map<int, int>> loadPrivateChatIdMap() async {
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
    } catch (e) {
      log("CHAT ID MAP ERROR => $e");
    }

    return map;
  }

  /// Fills a missing chat id from [map]; returns null when nothing changed.
  static List<UserListData>? patchChatIds(
      List<UserListData> users, Map<int, int> map) {
    if (map.isEmpty || users.isEmpty) return null;

    bool changed = false;
    final List<UserListData> updated = users.map((u) {
      if (u.chatId != null || u.userId == null) return u;
      final int? cid = map[u.userId!];
      if (cid == null) return u;
      changed = true;
      return UserListData(
        userId: u.userId,
        name: u.name,
        mobileNo: u.mobileNo,
        profileImage: u.profileImage,
        isOnline: u.isOnline,
        chatId: cid,
        conversationId: u.conversationId,
        privateChatId: u.privateChatId,
      );
    }).toList();

    return changed ? updated : null;
  }
}
