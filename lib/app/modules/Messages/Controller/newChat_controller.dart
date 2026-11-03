import 'dart:async';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class _ContactEntry {
  final String name;
  final String phone;
  final String norm;
  const _ContactEntry(this.name, this.phone, this.norm);
}

class NewChatController extends GetxController {
  final bool autoLoad;

  NewChatController({this.autoLoad = true});

  final ContactService _contactService = ContactService();

  // ---------- Session cache ----------
  static List<UserListData>? _cachedMatched;
  static List<UserListData>? _cachedOther;
  static DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _previewCount = 20;

  /// Logout par call karna.
  static void clearCache() {
    _cachedMatched = null;
    _cachedOther = null;
    _cachedAt = null;
  }

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  var allUsers = <UserListData>[].obs;

  var matchedUsers = <UserListData>[].obs;
  var filteredMatchedUsers = <UserListData>[].obs;

  var otherUsers = <UserListData>[].obs;
  var filteredOtherUsers = <UserListData>[].obs;

  final RxList<UserListData> previewUsers = <UserListData>[].obs;
  final RxBool isResolving = false.obs;

  final RxString searchQuery = ''.obs;
  final RxBool contactLoading = false.obs;
  final RxString responseError = "".obs;

  Timer? _debounce;
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      getRegisteredContacts();
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// Logged-in user ki id.
  String? _ownUserId() {
    try {
      final v = Global.storageServices.get(PrefConst.userId);
      final s = v?.toString().trim();
      return (s == null || s.isEmpty || s == 'null') ? null : s;
    } catch (_) {
      return null;
    }
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
    } catch (e) {
      log("CHAT ID MAP ERROR => $e");
    }

    return map;
  }

  void _applyLists(List<UserListData> matched, List<UserListData> other) {
    matchedUsers.assignAll(matched);
    otherUsers.assignAll(other);
    _runFilter(searchQuery.value);
  }

  List<_ContactEntry> _buildEntries(List<Contact> deviceContacts) {
    final List<_ContactEntry> entries = [];
    final Set<String> seen = {};

    for (final contact in deviceContacts) {
      final String name = contact.displayName.trim();
      for (final phone in contact.phones) {
        final String norm = _normalizePhone(phone.number);
        if (norm.length != 10 || !seen.add(norm)) continue;
        entries.add(_ContactEntry(
          name.isNotEmpty ? name : phone.number,
          phone.number,
          norm,
        ));
      }
    }
    return entries;
  }

  Future<void> getRegisteredContacts({bool forceRefresh = false}) async {
    if (_isFetching) return;

    final bool hasCache = _cachedMatched != null && _cachedOther != null;

    if (hasCache) {
      _applyLists(_cachedMatched!, _cachedOther!);
      responseError.value = "";

      final bool fresh = _cachedAt != null &&
          DateTime.now().difference(_cachedAt!) < _cacheTtl;
      if (fresh && !forceRefresh) return;
    } else {
      contactLoading.value = true;
    }

    responseError.value = "";
    _isFetching = true;
    final sw = Stopwatch()..start();

    try {
      final usersFuture = GroupRepo.getAllUserData();
      usersFuture.ignore();
      final chatMapFuture = _loadPrivateChatIdMap();

      final List<Contact> deviceContacts = await _contactService.getContacts();
      log("TIMING contacts read: ${sw.elapsedMilliseconds} ms "
          "(${deviceContacts.length} contacts)");

      final List<_ContactEntry> entries = _buildEntries(deviceContacts);

      // ---------- Phase 1: pehle 20 turant ----------
      if (!hasCache) {
        previewUsers.assignAll(entries.take(_previewCount).map((e) {
          return UserListData(userId: null, name: e.name, mobileNo: e.phone);
        }));
        isResolving.value = true;
        contactLoading.value = false;
      }

      // ---------- Phase 2: API aane par matching ----------
      final result = await usersFuture;
      log("TIMING users API done: ${sw.elapsedMilliseconds} ms");

      if (result.status == true) {
        final List<UserListData> users = result.userData ?? [];
        final String? me = _ownUserId();

        final Map<String, UserListData> registeredMap = {};
        String? myNorm; // apna number (phonebook se bhi hatane ke liye)

        for (final user in users) {
          final String norm = _normalizePhone(user.mobileNo ?? '');

          // Apna account: list mein mat daalo, number yaad rakho
          if (me != null && user.userId?.toString() == me) {
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
          // Phonebook mein saved apna number bhi skip
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

        allUsers.assignAll(users);
        _cachedMatched = List<UserListData>.from(matched);
        _cachedOther = List<UserListData>.from(unmatched);
        _cachedAt = DateTime.now();

        _applyLists(matched, unmatched);
        log("TIMING matching done: ${sw.elapsedMilliseconds} ms");

        unawaited(chatMapFuture.then(_patchChatIds));
      } else if (!hasCache) {
        responseError.value = result.message ?? "Something went wrong";
      }
    } catch (e) {
      if (!hasCache) responseError.value = e.toString();
      log("CONTACT LOAD ERROR => $e");
    } finally {
      _isFetching = false;
      isResolving.value = false;
      contactLoading.value = false;
    }
  }

  void _patchChatIds(Map<int, int> map) {
    if (isClosed || map.isEmpty || matchedUsers.isEmpty) return;

    bool changed = false;
    final List<UserListData> updated = matchedUsers.map((u) {
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

    if (!changed) return;

    matchedUsers.assignAll(updated);
    _cachedMatched = List<UserListData>.from(updated);
    _runFilter(searchQuery.value);
  }

  void filterContacts(String query) {
    searchQuery.value = query;
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _runFilter(query);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () {
      _runFilter(query);
    });
  }

  void _runFilter(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredMatchedUsers.assignAll(List<UserListData>.from(matchedUsers));
      filteredOtherUsers.assignAll(List<UserListData>.from(otherUsers));
      return;
    }

    bool match(UserListData user) =>
        (user.name ?? '').toLowerCase().contains(q) ||
            (user.mobileNo ?? '').toLowerCase().contains(q);

    filteredMatchedUsers.assignAll(matchedUsers.where(match).toList());
    filteredOtherUsers.assignAll(otherUsers.where(match).toList());
  }

  String _normalizePhone(String phone) {
    String digits = phone.replaceAll(_nonDigit, '');
    if (digits.startsWith('91') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }
}