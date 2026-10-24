import 'dart:async';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/call_widget.dart';

class _PhoneEntry {
  final String name;
  final String phone;
  final String key10;
  final String key9;
  const _PhoneEntry(this.name, this.phone, this.key10, this.key9);
}

class ContactController extends GetxController {
  static ContactController get instance => Get.isRegistered<ContactController>()
      ? Get.find<ContactController>()
      : Get.put(ContactController());

  final RxString responseError = "".obs;

  final ContactService _contactService = ContactService();

  final Map<String, String> phoneContactNameMap = {};
  Set<String> get savedContactNumbers => phoneContactNameMap.keys.toSet();

  final Map<String, String> _nameByKey10 = {};
  final Map<String, String> _nameByKey9 = {};

  final List<_PhoneEntry> _phoneEntries = [];

  final Map<int, int> chatIdMap = {};
  int? chatIdFor(int? userId) => userId == null ? null : chatIdMap[userId];

  final RxBool contactLoading = false.obs;

  final RxBool isContactPermissionGranted = false.obs;
  final RxBool hasAllowedContacts = false.obs;
  final RxInt contactPagination = 1.obs;

  static const int contactPageLimit = 10;

  static const int _minMatchesPerLoad = 10;

  static const int _maxPagesPerLoad = 10;

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  final RxBool contactLoadingMore = false.obs;
  final RxBool hasMoreContacts = true.obs;

  final RxString searchQuery = ''.obs;
  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  var inviteUsers = <UserListData>[].obs;
  var filteredInviteUsers = <UserListData>[].obs;

  bool _initialLoadDone = false;

  int _session = 0;

  Future<void>? _phoneBookFuture;
  Future<bool>? _allUsersFuture;

  final Set<String> _seen = <String>{};

  String _digits(String? raw) => (raw ?? '').replaceAll(_nonDigit, '');

  String _matchKey(String? raw) {
    String d = _digits(raw);
    if (d.length > 10) d = d.substring(d.length - 10);
    return d;
  }

  String? _lookupName(String? rawPhone) {
    final String d = _digits(rawPhone);
    if (d.length < 8) return null;

    final String k10 = _matchKey(rawPhone);
    final String? exact = _nameByKey10[k10];
    if (exact != null && exact.isNotEmpty) return exact;

    if (d.length == 9) {
      final String? partial = _nameByKey9[d];
      if (partial != null && partial.isNotEmpty) return partial;
    }
    return null;
  }

  String? _ownUserId() {
    try {
      return Global.storageServices.get(PrefConst.userId)?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> checkContactPermission() async {
    try {
      final bool granted =
      await FlutterContacts.requestPermission(readonly: true);
      isContactPermissionGranted.value = granted;
      if (granted) {
        hasAllowedContacts.value = true;
        if (!_initialLoadDone && !contactLoading.value) {
          await getRegisteredContacts();
        }
      }
    } catch (e) {
      debugPrint("Error checking contact permission: $e");
    }
  }

  Future<void> requestContactPermission() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        isContactPermissionGranted.value = true;
        hasAllowedContacts.value = true;
        await getRegisteredContacts();
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      } else {
        isContactPermissionGranted.value = false;
      }
    } catch (e) {
      debugPrint("Error requesting contact permission: $e");
    }
  }

  Future<void> _loadPhoneBook() => _phoneBookFuture ??= _readPhoneBook();

  Future<void> _readPhoneBook() async {
    final List<Contact> deviceContacts = await _contactService.getContacts();

    phoneContactNameMap.clear();
    _nameByKey10.clear();
    _nameByKey9.clear();
    _phoneEntries.clear();

    final Set<String> entrySeen = <String>{};

    for (final Contact contact in deviceContacts) {
      final String displayName = contact.displayName.trim();
      if (displayName.isEmpty) continue;

      for (final Phone phone in contact.phones) {
        final String norm = normalizePhone(phone.number);
        if (norm.isNotEmpty) {
          phoneContactNameMap[norm] = displayName;
        }

        final String d = _digits(phone.number);
        if (d.length < 8) continue;

        final String k10 = _matchKey(phone.number);
        _nameByKey10.putIfAbsent(k10, () => displayName);

        String k9 = '';
        if (d.length >= 9) {
          k9 = d.substring(d.length - 9);
          _nameByKey9.putIfAbsent(k9, () => displayName);
        }

        if (k10.length == 10 && entrySeen.add(k10)) {
          _phoneEntries.add(_PhoneEntry(displayName, phone.number, k10, k9));
        }
      }
    }
    debugPrint("PHONEBOOK KEYS => ${_nameByKey10.length}");
  }

  void _mergeUsers(List<UserListData> incoming) {
    if (incoming.isEmpty) return;

    final List<UserListData> merged =
    List<UserListData>.from(allUserProfileData);
    bool changed = false;

    for (final UserListData user in incoming) {
      final String id = user.userId != null
          ? 'u:${user.userId}'
          : 'p:${_matchKey(user.mobileNo)}';
      if (_seen.add(id)) {
        merged.add(user);
        changed = true;
      }
    }

    if (!changed) return;

    merged.sort((a, b) =>
        (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

    allUserProfileData.value = merged;
    filterUsers(searchQuery.value);
  }

  void _buildInvites(Set<String> reg10, Set<String> reg9, String? myKey) {
    for (final u in allUserProfileData) {
      final String k = _matchKey(u.mobileNo);
      if (k.isNotEmpty) reg10.add(k);
    }

    final List<UserListData> invites = <UserListData>[];

    for (final _PhoneEntry e in _phoneEntries) {
      if (myKey != null && e.key10 == myKey) continue;
      if (reg10.contains(e.key10)) continue;
      if (e.key9.isNotEmpty && reg9.contains(e.key9)) continue;

      invites.add(UserListData(
        userId: null,
        name: e.name,
        mobileNo: e.phone,
        profileImage: null,
      ));
    }

    invites.sort((a, b) =>
        (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

    inviteUsers.value = invites;
    filterUsers(searchQuery.value);
  }

  Future<List<GroupMemberData>> _fetchMembers(int page) async {
    final GroupMemberModel res = await TrackRepo.getGroupMember(
      page: page.toString(),
      filter: 'all',
      limit: contactPageLimit,
    );
    return res.data?.allMember?.memberList ?? res.data?.allMemberList ?? [];
  }

  Future<bool> _loadAllUsersAndMerge(int session) async {
    try {
      await _loadPhoneBook();

      final result = await GroupRepo.getAllUserData();
      if (session != _session) return true;

      if (result.status != true) return false;

      final String? me = _ownUserId();
      final List<UserListData> matched = <UserListData>[];

      final Set<String> reg10 = <String>{};
      final Set<String> reg9 = <String>{};
      String? myKey;

      for (final user in (result.userData ?? <UserListData>[])) {
        final String d = _digits(user.mobileNo);
        final bool isMe = me != null && user.userId?.toString() == me;

        if (d.length >= 8) {
          if (isMe) {
            myKey = _matchKey(user.mobileNo);
          } else {
            reg10.add(_matchKey(user.mobileNo));
            if (d.length == 9) reg9.add(d);
          }
        }

        if (isMe) continue;

        final String? name = _lookupName(user.mobileNo);
        if (name == null) continue;

        final int? chatId =
            user.privateChatId ?? user.chatId ?? user.conversationId;
        if (user.userId != null &&
            chatId != null &&
            !chatIdMap.containsKey(user.userId)) {
          chatIdMap[user.userId!] = chatId;
        }

        matched.add(UserListData(
          userId: user.userId,
          profileImage: user.profileImage,
          name: name.trim(),
          mobileNo: user.mobileNo,
          isOnline: user.isOnline,
        ));
      }

      _mergeUsers(matched);
      _buildInvites(reg10, reg9, myKey);
      return true;
    } catch (e) {
      debugPrint("getAllUser hybrid load error: $e");
      return false;
    }
  }

  Future<void> getRegisteredContacts({bool loadMore = false}) async {
    if (loadMore) {
      if (contactLoading.value ||
          contactLoadingMore.value ||
          !hasMoreContacts.value) {
        return;
      }
      contactLoadingMore.value = true;
    } else {
      if (contactLoading.value) return;
      contactLoading.value = true;
      responseError.value = "";
      contactPagination.value = 1;
      hasMoreContacts.value = true;
      chatIdMap.clear();
      allUserProfileData.clear();
      filteredUsers.clear();
      inviteUsers.clear();
      filteredInviteUsers.clear();
      _seen.clear();
      _session++;
      _allUsersFuture = null;
    }

    final int session = _session;

    try {
      Future<List<GroupMemberData>>? firstPage;

      if (!loadMore) {
        firstPage = _fetchMembers(contactPagination.value);
        firstPage.ignore();
        _allUsersFuture = _loadAllUsersAndMerge(session);
      }

      await _loadPhoneBook();
      isContactPermissionGranted.value = true;

      final String? me = _ownUserId();
      final List<UserListData> matchedUsers = <UserListData>[];
      bool apiHasMore = true;
      bool groupApiFailed = false;
      int pagesFetched = 0;

      while (matchedUsers.length < _minMatchesPerLoad &&
          apiHasMore &&
          pagesFetched < _maxPagesPerLoad) {
        List<GroupMemberData> members;
        try {
          if (pagesFetched == 0 && firstPage != null) {
            members = await firstPage;
          } else {
            members = await _fetchMembers(contactPagination.value);
          }
        } catch (e) {
          debugPrint("Error fetching group members for call contacts: $e");
          groupApiFailed = true;
          break;
        }

        pagesFetched++;
        apiHasMore = members.length >= contactPageLimit;
        contactPagination.value = contactPagination.value + 1;

        for (final GroupMemberData member in members) {
          if (me != null && member.userId?.toString() == me) continue;

          final String phoneNum = member.mobileNo ?? member.phone ?? '';
          final String? phoneBookName = _lookupName(phoneNum);
          if (phoneBookName == null) continue;

          if (member.userId != null && member.chatId != null) {
            chatIdMap[member.userId!] = member.chatId!;
          }

          matchedUsers.add(UserListData(
            userId: member.userId,
            profileImage: member.profileImage,
            name: phoneBookName.trim(),
            mobileNo: phoneNum,
            isOnline: member.online,
          ));
        }
      }

      if (session != _session) return;

      hasMoreContacts.value = groupApiFailed ? false : apiHasMore;
      _mergeUsers(matchedUsers);

      if (!loadMore && allUserProfileData.isEmpty && _allUsersFuture != null) {
        final bool ok = await _allUsersFuture!;
        if (!ok && allUserProfileData.isEmpty && groupApiFailed) {
          responseError.value = "Something went wrong";
        }
      } else if (!loadMore && groupApiFailed && _allUsersFuture != null) {
        await _allUsersFuture;
      }

      if (!loadMore && !groupApiFailed) _initialLoadDone = true;

      filterUsers(searchQuery.value);
    } catch (e) {
      if (!loadMore) responseError.value = e.toString();
    } finally {
      if (loadMore) {
        contactLoadingMore.value = false;
      } else {
        contactLoading.value = false;
      }
    }
  }

  Future<void> loadMoreContacts() => getRegisteredContacts(loadMore: true);

  Future<void> refreshContacts() async {
    _phoneBookFuture = null;
    phoneContactNameMap.clear();
    _nameByKey10.clear();
    _nameByKey9.clear();
    _phoneEntries.clear();
    await getRegisteredContacts();
  }

  void filterUsers(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      filteredUsers.value = List<UserListData>.from(allUserProfileData);
      filteredInviteUsers.value = List<UserListData>.from(inviteUsers);
      return;
    }

    final String digits = q.replaceAll(_nonDigit, '');

    bool match(UserListData user) {
      final String name = (user.name ?? '').toLowerCase();
      final String phone = (user.mobileNo ?? '').replaceAll(_nonDigit, '');
      if (name.contains(q)) return true;
      if (digits.isNotEmpty && phone.contains(digits)) return true;
      return false;
    }

    filteredUsers.value = allUserProfileData.where(match).toList();
    filteredInviteUsers.value = inviteUsers.where(match).toList();
  }

  void applySearch(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    filterUsers(query);
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CallController>()) {
      ever<String>(CallController.instance.searchQuery, applySearch);
    }
    checkContactPermission();
  }

  @override
  void onClose() {
    responseError.close();
    contactLoading.close();
    isContactPermissionGranted.close();
    hasAllowedContacts.close();
    contactPagination.close();
    contactLoadingMore.close();
    hasMoreContacts.close();
    searchQuery.close();
    allUserProfileData.close();
    filteredUsers.close();
    inviteUsers.close();
    filteredInviteUsers.close();
    super.onClose();
  }
}