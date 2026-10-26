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

  /// Pehla load (success ya fail) hone se pehle UI hamesha skeleton dikhayega,
  /// taki "No data found" ka flash na aaye.
  final RxBool isFirstLoadDone = false.obs;

  /// Permission check complete hua ya nahi (tab tak skeleton).
  final RxBool permissionChecked = false.obs;
  final RxBool isContactPermissionGranted = false.obs;
  final RxBool hasAllowedContacts = false.obs;
  final RxInt contactPagination = 1.obs;

  /// Server (group member API) page size.
  static const int contactPageLimit = 10;

  /// UI par ek baar me itne registered contacts dikhenge (client-side paging).
  /// getAllUser API paginated nahi hai (sab users ek saath aate hain), isliye
  /// merged list ko screen par chunks me dikhate hain.
  static const int uiPageSize = 20;

  static const int _minMatchesPerLoad = 10;

  static const int _maxPagesPerLoad = 10;

  /// Itne seconds ke andar dobara non-forced refresh nahi chalega.
  static const Duration _refreshThrottle = Duration(seconds: 10);

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  final RxBool contactLoadingMore = false.obs;
  final RxBool hasMoreContacts = true.obs;

  final RxString searchQuery = ''.obs;

  /// Poori merged list (server pages + getAllUser), name se sorted.
  var allUserProfileData = <UserListData>[].obs;

  /// UI ye list dekhta hai: search-filtered list ka current page tak ka hissa.
  var filteredUsers = <UserListData>[].obs;

  var inviteUsers = <UserListData>[].obs;
  var filteredInviteUsers = <UserListData>[].obs;

  /// Search ke baad poori (unpaged) list. filteredUsers isi ka slice hai.
  List<UserListData> _fullFiltered = <UserListData>[];

  /// Abhi UI par kitne registered contacts allowed hain.
  int _visibleCount = uiPageSize;

  bool _initialLoadDone = false;

  /// Silent refresh chal raha hai (list screen par rehti hai, clear nahi hoti).
  bool _isRefreshing = false;

  /// Silent refresh me pehla merge purani list ko replace karega.
  bool _replaceOnNextMerge = false;

  DateTime? _lastLoadAt;

  int _session = 0;

  Future<void>? _phoneBookFuture;
  Future<bool>? _allUsersFuture;

  Future<void>? _permCheckFuture;
  bool _permissionPrompted = false;

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

  // ───────────────────────── Permission ─────────────────────────

  /// Concurrent calls ek hi check share karti hain (dialog 2 baar nahi aayega).
  /// [prompt] true ho to pehli baar system dialog dikhayega.
  Future<void> checkContactPermission({bool prompt = true}) {
    return _permCheckFuture ??=
        _checkPermission(prompt).whenComplete(() => _permCheckFuture = null);
  }

  Future<void> _checkPermission(bool prompt) async {
    bool granted = false;
    try {
      final PermissionStatus status = await Permission.contacts.status;
      granted = status.isGranted || status.isLimited;

      if (!granted && prompt && !_permissionPrompted) {
        _permissionPrompted = true;
        granted = await FlutterContacts.requestPermission(readonly: true);
      }
    } catch (e) {
      debugPrint("Error checking contact permission: $e");
    }

    isContactPermissionGranted.value = granted;
    permissionChecked.value = true;

    if (granted) {
      hasAllowedContacts.value = true;
      if (!_initialLoadDone && !contactLoading.value && !_isRefreshing) {
        await getRegisteredContacts();
      }
    }
  }

  /// "Allow Access" button par: dialog dikhata hai. true = granted.
  /// false aaye to UI settings page par bhejega.
  Future<bool> requestContactPermission() async {
    try {
      final bool granted =
      await FlutterContacts.requestPermission(readonly: true);
      if (granted) {
        isContactPermissionGranted.value = true;
        hasAllowedContacts.value = true;
        permissionChecked.value = true;
        _phoneBookFuture = null;
        if (!_initialLoadDone) {
          await getRegisteredContacts();
        } else {
          await silentRefresh(force: true);
        }
      }
      return granted;
    } catch (e) {
      debugPrint("Error requesting contact permission: $e");
      return false;
    }
  }

  // ───────────────────────── Phone book ─────────────────────────

  Future<void> _loadPhoneBook() {
    return _phoneBookFuture ??= _readPhoneBook().catchError((Object e) {
      // fail hua future cache nahi hona chahiye, warna hamesha fail rahega
      _phoneBookFuture = null;
      throw e;
    });
  }

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

  // ───────────────────────── Merge helpers ─────────────────────────

  void _mergeUsers(List<UserListData> incoming) {
    if (incoming.isEmpty) return;

    // Silent refresh me pehla merge purani list ko replace karta hai
    final List<UserListData> merged = _replaceOnNextMerge
        ? <UserListData>[]
        : List<UserListData>.from(allUserProfileData);
    _replaceOnNextMerge = false;
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

  // ───────────────────────── Main loader ─────────────────────────

  /// [silent] = true: list clear nahi hoti, skeleton nahi aata. Naya data
  /// aate hi purani list replace hoti hai aur current search filter dobara lagta hai.
  Future<void> getRegisteredContacts({
    bool loadMore = false,
    bool silent = false,
  }) async {
    if (!isContactPermissionGranted.value) return;

    if (loadMore) {
      if (contactLoading.value ||
          contactLoadingMore.value ||
          _isRefreshing ||
          !hasMoreContacts.value) {
        return;
      }
      contactLoadingMore.value = true;
    } else if (silent) {
      if (contactLoading.value || _isRefreshing) return;
      _isRefreshing = true;
      responseError.value = "";
      contactPagination.value = 1;
      hasMoreContacts.value = true;
      _seen.clear();
      _replaceOnNextMerge = true;
      _session++;
      _allUsersFuture = null;
      // silent refresh me _visibleCount reset nahi hota (scroll position bani rahe)
    } else {
      if (contactLoading.value || _isRefreshing) return;
      contactLoading.value = true;
      responseError.value = "";
      contactPagination.value = 1;
      hasMoreContacts.value = true;
      chatIdMap.clear();
      allUserProfileData.clear();
      _fullFiltered = <UserListData>[];
      filteredUsers.clear();
      inviteUsers.clear();
      filteredInviteUsers.clear();
      _seen.clear();
      _replaceOnNextMerge = false;
      _visibleCount = uiPageSize;
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

      if (silent) {
        // all-users call ka wait karo taki replace sahi ho
        final bool ok = _allUsersFuture != null ? await _allUsersFuture! : true;
        if (session != _session) return;

        // Server ne sach me kuch nahi diya -> purani list hata do
        if (_replaceOnNextMerge && ok && !groupApiFailed) {
          _replaceOnNextMerge = false;
          allUserProfileData.clear();
          _fullFiltered = <UserListData>[];
          filteredUsers.clear();
        }
      } else if (!loadMore &&
          allUserProfileData.isEmpty &&
          _allUsersFuture != null) {
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
      // silent fail par purani list screen par rehti hai
      if (!loadMore) responseError.value = e.toString();
    } finally {
      if (loadMore) {
        contactLoadingMore.value = false;
      } else {
        _replaceOnNextMerge = false;
        _lastLoadAt = DateTime.now();
        isFirstLoadDone.value = true;
        if (silent) {
          _isRefreshing = false;
        } else {
          contactLoading.value = false;
        }
      }
    }
  }

  /// Scroll end par call hota hai.
  /// 1) Pehle local merged list me se agle [uiPageSize] contacts dikhata hai (instant).
  /// 2) Local list khatam ho gayi to server ka agla page (group member API) laata hai.
  Future<void> loadMoreContacts() async {
    if (filteredUsers.length < _fullFiltered.length) {
      _visibleCount += uiPageSize;
      _applyPage();
      return;
    }
    await getRegisteredContacts(loadMore: true);
  }

  Future<void> silentRefresh({
    bool force = false,
    bool reloadPhoneBook = false,
  }) async {
    if (!isContactPermissionGranted.value) return;

    if (!_initialLoadDone) {
      if (!contactLoading.value && !_isRefreshing) {
        await getRegisteredContacts();
      }
      return;
    }

    if (contactLoading.value || _isRefreshing) return;

    if (!force &&
        _lastLoadAt != null &&
        DateTime.now().difference(_lastLoadAt!) < _refreshThrottle) {
      return;
    }

    if (reloadPhoneBook) _phoneBookFuture = null;

    await getRegisteredContacts(silent: true);
  }

  Future<void> refreshContacts() =>
      silentRefresh(force: true, reloadPhoneBook: true);

  /// Contacts tab open hone par.
  Future<void> onTabOpened() async {
    final bool wasLoaded = _initialLoadDone;
    await checkContactPermission();
    if (wasLoaded && isContactPermissionGranted.value) {
      await silentRefresh(force: true);
    }
  }

  /// App background se wapas aane par (settings se permission dekar aane par bhi).
  Future<void> onAppResumed() async {
    await checkContactPermission(prompt: false);
    if (isContactPermissionGranted.value && _initialLoadDone) {
      await silentRefresh();
    }
  }

  // ───────────────────────── Search + paging ─────────────────────────

  /// _fullFiltered ka pehla [_visibleCount] hissa filteredUsers me daalta hai.
  void _applyPage() {
    if (_fullFiltered.length <= _visibleCount) {
      filteredUsers.value = List<UserListData>.from(_fullFiltered);
    } else {
      filteredUsers.value =
      List<UserListData>.from(_fullFiltered.take(_visibleCount));
    }
  }

  void filterUsers(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      _fullFiltered = List<UserListData>.from(allUserProfileData);
      filteredInviteUsers.value = List<UserListData>.from(inviteUsers);
      _applyPage();
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

    _fullFiltered = allUserProfileData.where(match).toList();
    filteredInviteUsers.value = inviteUsers.where(match).toList();
    _applyPage();
  }

  void applySearch(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    _visibleCount = uiPageSize; // nayi search = paging dobara pehle page se
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
    isFirstLoadDone.close();
    permissionChecked.close();
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