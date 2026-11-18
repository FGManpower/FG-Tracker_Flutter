import 'dart:async';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/contact_matcher.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/call/Controller/call_controller.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/call_widget.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';

/// Calls → Contacts tab.
///
/// The list is built exactly like All Contacts (`NewChatController`):
/// phonebook × `/getAllUser` through [ContactMatcher], so both screens show
/// the same people with the same names, numbers and order.
class ContactController extends GetxController {
  static ContactController get instance => Get.isRegistered<ContactController>()
      ? Get.find<ContactController>()
      : Get.put(ContactController());

  final RxString responseError = "".obs;

  final ContactService _contactService = ContactService();

  /// Normalized phone → phonebook name (used by Forward message).
  final Map<String, String> phoneContactNameMap = {};
  Set<String> get savedContactNumbers => phoneContactNameMap.keys.toSet();

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

  /// UI par ek baar me itne registered contacts dikhenge (client-side paging).
  static const int uiPageSize = 20;

  /// Itne seconds ke andar dobara non-forced refresh nahi chalega.
  static const Duration _refreshThrottle = Duration(seconds: 10);

  static final RegExp _nonDigit = RegExp(r'[^0-9]');

  /// Whole list comes in one API call now; kept for the tab's footer.
  final RxBool contactLoadingMore = false.obs;

  final RxString searchQuery = ''.obs;

  /// FG users from the phonebook, in phonebook order (same as All Contacts).
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

  DateTime? _lastLoadAt;

  Future<void>? _permCheckFuture;
  bool _permissionPrompted = false;

  String? _ownUserId() {
    try {
      final s = Global.storageServices.get(PrefConst.userId)?.toString().trim();
      return (s == null || s.isEmpty || s == 'null') ? null : s;
    } catch (_) {
      return null;
    }
  }

  // ───────────────────────── Permission ─────────────────────────

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
      AppLog.d("Error checking contact permission: $e");
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

  Future<bool> requestContactPermission() async {
    try {
      final bool granted =
      await FlutterContacts.requestPermission(readonly: true);
      if (granted) {
        isContactPermissionGranted.value = true;
        hasAllowedContacts.value = true;
        permissionChecked.value = true;
        if (!_initialLoadDone) {
          await getRegisteredContacts();
        } else {
          await silentRefresh(force: true);
        }
      }
      return granted;
    } catch (e) {
      AppLog.d("Error requesting contact permission: $e");
      return false;
    }
  }

  // ───────────────────────── Phone book ─────────────────────────

  /// Reads the phonebook (fresh every load, like All Contacts) and returns
  /// its entries; also refreshes [phoneContactNameMap].
  Future<List<PhonebookEntry>> _readPhoneBook() async {
    final List<Contact> deviceContacts = await _contactService.getContacts();

    phoneContactNameMap.clear();
    for (final Contact contact in deviceContacts) {
      final String displayName = contact.displayName.trim();
      if (displayName.isEmpty) continue;
      for (final Phone phone in contact.phones) {
        final String norm = normalizePhone(phone.number);
        if (norm.isNotEmpty) phoneContactNameMap[norm] = displayName;
      }
    }

    return ContactMatcher.buildEntries(deviceContacts);
  }

  // ───────────────────────── Main loader ─────────────────────────

  void _applyLists(List<UserListData> matched, List<UserListData> invites) {
    chatIdMap.clear();
    for (final u in matched) {
      if (u.userId != null && u.chatId != null) chatIdMap[u.userId!] = u.chatId!;
    }
    allUserProfileData.value = matched;
    inviteUsers.value = invites;
    filterUsers(searchQuery.value);
  }

  void _patchChatIds(Map<int, int> map) {
    if (isClosed) return;
    final updated = ContactMatcher.patchChatIds(allUserProfileData, map);
    if (updated == null) return;
    _applyLists(updated, List<UserListData>.from(inviteUsers));
  }

  /// Loads the list. [silent] keeps the current list on screen while
  /// refreshing; a failed silent refresh leaves it untouched.
  Future<void> getRegisteredContacts({bool silent = false}) async {
    if (!isContactPermissionGranted.value) return;
    if (contactLoading.value || _isRefreshing) return;

    if (silent) {
      _isRefreshing = true;
    } else {
      contactLoading.value = true;
      chatIdMap.clear();
      allUserProfileData.clear();
      _fullFiltered = <UserListData>[];
      filteredUsers.clear();
      inviteUsers.clear();
      filteredInviteUsers.clear();
      _visibleCount = uiPageSize;
    }
    responseError.value = "";

    try {
      final usersFuture =
          GroupRepo.getAllUserData().timeout(const Duration(seconds: 10));
      usersFuture.ignore();
      final chatMapFuture = ContactMatcher.loadPrivateChatIdMap();

      final List<PhonebookEntry> entries = await _readPhoneBook();
      isContactPermissionGranted.value = true;

      final result = await usersFuture;

      if (result.status == true) {
        final match = ContactMatcher.match(
          entries,
          result.userData ?? <UserListData>[],
          ownUserId: _ownUserId(),
        );
        _applyLists(match.matched, match.unmatched);
        _initialLoadDone = true;
        unawaited(chatMapFuture.then(_patchChatIds));
      } else if (allUserProfileData.isEmpty && inviteUsers.isEmpty) {
        responseError.value =
            result.message ?? appL10n.common_somethingWentWrong;
      }
    } catch (e) {
      AppLog.d("Call contacts load error: $e");
      if (allUserProfileData.isEmpty && inviteUsers.isEmpty) {
        responseError.value = e.toString();
      }
    } finally {
      _lastLoadAt = DateTime.now();
      isFirstLoadDone.value = true;
      if (silent) {
        _isRefreshing = false;
      } else {
        contactLoading.value = false;
      }
    }
  }

  /// Shows the next page of the already-loaded list.
  Future<void> loadMoreContacts() async {
    if (filteredUsers.length < _fullFiltered.length) {
      _visibleCount += uiPageSize;
      _applyPage();
    }
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

    await getRegisteredContacts(silent: true);
  }

  Future<void> refreshContacts() =>
      silentRefresh(force: true, reloadPhoneBook: true);

  Future<void> onTabOpened() async {
    final bool wasLoaded = _initialLoadDone;
    await checkContactPermission();
    if (wasLoaded && isContactPermissionGranted.value) {
      await silentRefresh(force: true);
    }
  }

  Future<void> onAppResumed() async {
    await checkContactPermission(prompt: false);
    if (isContactPermissionGranted.value && _initialLoadDone) {
      await silentRefresh();
    }
  }

  // ───────────────────────── Search + paging ─────────────────────────

  void _applyPage() {
    if (_fullFiltered.length <= _visibleCount) {
      filteredUsers.value = List<UserListData>.from(_fullFiltered);
    } else {
      filteredUsers.value =
      List<UserListData>.from(_fullFiltered.take(_visibleCount));
    }
  }

  Timer? _searchDebounceTimer;

  void filterUsers(String query) {
    final String q = query.trim().toLowerCase();

    if (q.isEmpty) {
      _fullFiltered = List<UserListData>.from(allUserProfileData);
      filteredInviteUsers.value = List<UserListData>.from(inviteUsers);
      _applyPage();
      return;
    }

    final String digits = q.replaceAll(_nonDigit, '');

    // Extract core query digits without leading country code (91) or trunk prefix (0)
    String queryCore = digits;
    if (queryCore.length > 2 && queryCore.startsWith('91')) {
      queryCore = queryCore.substring(2);
    } else if (queryCore.length > 1 && queryCore.startsWith('0')) {
      queryCore = queryCore.substring(1);
    }

    bool match(UserListData user) {
      final String name = (user.name ?? '').toLowerCase();
      if (name.contains(q)) return true;

      if (digits.isEmpty) return false;

      final String rawPhone = user.mobileNo ?? '';
      final String phoneDigits = rawPhone.replaceAll(_nonDigit, '');
      if (phoneDigits.isEmpty) return false;

      // 1. Direct digit match anywhere (start, middle, end)
      if (phoneDigits.contains(digits)) return true;

      // 2. Contact phone without 91 or leading 0
      String phoneCore = phoneDigits;
      if (phoneCore.length >= 12 && phoneCore.startsWith('91')) {
        phoneCore = phoneCore.substring(2);
      } else if (phoneCore.length >= 11 && phoneCore.startsWith('0')) {
        phoneCore = phoneCore.substring(1);
      }

      if (phoneCore.contains(digits)) return true;

      // 3. Cross match with query core
      if (queryCore.isNotEmpty) {
        if (phoneDigits.contains(queryCore)) return true;
        if (phoneCore.contains(queryCore)) return true;
      }

      return false;
    }

    _fullFiltered = allUserProfileData.where(match).toList();
    filteredInviteUsers.value = inviteUsers.where(match).toList();
    _applyPage();
  }

  void applySearch(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    _visibleCount = uiPageSize;
    filterUsers(query);
  }

  void _onSearchOrDialChanged() {
    if (!Get.isRegistered<CallController>()) return;
    final callCtrl = CallController.instance;
    final String query = (callCtrl.isDialPadOpen.value &&
        callCtrl.dialNumber.value.trim().isNotEmpty)
        ? callCtrl.dialNumber.value.trim()
        : callCtrl.searchQuery.value.trim();

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 60), () {
      applySearch(query);
    });
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<CallController>()) {
      final callCtrl = CallController.instance;
      ever<String>(callCtrl.searchQuery, (_) => _onSearchOrDialChanged());
      ever<String>(callCtrl.dialNumber, (_) => _onSearchOrDialChanged());
      ever<bool>(callCtrl.isDialPadOpen, (_) => _onSearchOrDialChanged());
    }
    checkContactPermission();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    responseError.close();
    contactLoading.close();
    isFirstLoadDone.close();
    permissionChecked.close();
    isContactPermissionGranted.close();
    hasAllowedContacts.close();
    contactLoadingMore.close();
    searchQuery.close();
    allUserProfileData.close();
    filteredUsers.close();
    inviteUsers.close();
    filteredInviteUsers.close();
    super.onClose();
  }
}
