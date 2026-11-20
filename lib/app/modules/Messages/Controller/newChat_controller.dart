import 'dart:async';
import 'package:fgtracker/l10n/l10n.dart';
import 'dart:developer';

import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/contact_matcher.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:get/get.dart';

class NewChatController extends GetxController {
  final bool autoLoad;

  NewChatController({this.autoLoad = true});

  final ContactService _contactService = ContactService();

  // ---------- Session cache ----------
  static List<UserListData>? _cachedMatched;
  static List<UserListData>? _cachedOther;
  static DateTime? _cachedAt;

  static List<UserListData>? get cachedMatched => _cachedMatched;
  static List<UserListData>? get cachedOther => _cachedOther;

  /// Pre-warms the session cache in background (reads disk cache `AppCache.fgContacts`)
  /// so when NewChatScreen opens, contacts render instantly on frame 0 with zero lag.
  static Future<void> preWarm() async {
    try {
      if (_cachedMatched != null && _cachedMatched!.isNotEmpty) return;
      final saved = await AppCache.readAs(
        AppCache.fgContacts,
        (m) => UserListData.fromJson(m),
      );
      if (saved.isNotEmpty &&
          (_cachedMatched == null || _cachedMatched!.isEmpty)) {
        _cachedMatched = saved;
        _cachedOther ??= const [];
        _cachedAt = DateTime.now();
      }
    } catch (_) {}
  }

  /// Whose contacts the session cache holds. It is static, so it survives
  /// logout (`Get.deleteAll`): another account on the same phone used to see
  /// the first account's list. Now it is dropped when the user changes.
  static String? _cachedFor;
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _previewCount = 20;

  /// Logout par call karna.
  static void clearCache() {
    _cachedMatched = null;
    _cachedOther = null;
    _cachedAt = null;
    _cachedFor = null;
  }

  @visibleForTesting
  static void debugSeedSessionCache(
      List<UserListData> matched, String forUser) {
    _cachedMatched = matched;
    _cachedOther = const [];
    _cachedAt = DateTime.now();
    _cachedFor = forUser;
  }

  /// "Couldn't refresh · Retry" over saved contacts (doc 07).
  final RxBool refreshFailed = false.obs;

  /// The registered FG users of this phonebook, saved on the device
  /// (AppCache `fg_contacts`): shown at once on the first open after a
  /// restart, while `/getAllUser` runs.
  Future<List<UserListData>> _readSavedMatched() =>
      AppCache.readAs(AppCache.fgContacts, (m) => UserListData.fromJson(m));

  void _saveMatched(List<UserListData> matched) {
    if (matched.isEmpty) return; // never wipe a saved list with nothing
    unawaited(AppCache.write(
      AppCache.fgContacts,
      [for (final u in matched) u.toJson()],
    ));
  }

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
    // Fast initial frame: if session cache exists, apply immediately on frame 0
    if (_cachedMatched != null && _cachedMatched!.isNotEmpty) {
      _applyLists(_cachedMatched!, _cachedOther ?? const []);
    }
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

  void _applyLists(List<UserListData> matched, List<UserListData> other) {
    matchedUsers.assignAll(matched);
    otherUsers.assignAll(other);
    _runFilter(searchQuery.value);
  }

  Future<void> getRegisteredContacts({bool forceRefresh = false}) async {
    if (_isFetching) return;

    // Account switch on the same phone: never show the previous user's list.
    if (_cachedFor != null && _cachedFor != _ownUserId()) clearCache();

    final perf = AppCachePerf('new_chat_contacts')..mark('open');
    bool hasCache = _cachedMatched != null && _cachedOther != null;

    if (hasCache) {
      _applyLists(_cachedMatched!, _cachedOther!);
      responseError.value = "";
      perf.mark('cache shown', extra: 'session, ${_cachedMatched!.length} users');

      final bool fresh = _cachedAt != null &&
          DateTime.now().difference(_cachedAt!) < _cacheTtl;
      if (fresh && !forceRefresh) return;
    }

    _isFetching = true;
    refreshFailed.value = false;
    responseError.value = "";

    // First open after a restart: the saved FG users at once (doc 07).
    if (!hasCache) {
      final saved = await _readSavedMatched();
      if (saved.isNotEmpty && !isClosed) {
        _applyLists(saved, otherUsers);
        hasCache = true;
        perf.mark('cache shown', extra: '${saved.length} users');
      }
    }
    if (!hasCache) contactLoading.value = true;

    final sw = Stopwatch()..start();

    try {
      final usersFuture =
          GroupRepo.getAllUserData().timeout(const Duration(seconds: 10));
      usersFuture.ignore();
      final chatMapFuture = ContactMatcher.loadPrivateChatIdMap();

      final List<Contact> deviceContacts = await _contactService.getContacts();
      log("TIMING contacts read: ${sw.elapsedMilliseconds} ms "
          "(${deviceContacts.length} contacts)");

      final List<PhonebookEntry> entries =
          ContactMatcher.buildEntries(deviceContacts);

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

        final match =
            ContactMatcher.match(entries, users, ownUserId: me);
        final List<UserListData> matched = match.matched;
        final List<UserListData> unmatched = match.unmatched;

        allUsers.assignAll(users);
        _cachedMatched = List<UserListData>.from(matched);
        _cachedOther = List<UserListData>.from(unmatched);
        _cachedAt = DateTime.now();
        _cachedFor = me;

        _applyLists(matched, unmatched);
        _saveMatched(matched);
        perf.mark('API done', extra: '${matched.length} users');
        perf.markAfterFrame('rendered');
        log("TIMING matching done: ${sw.elapsedMilliseconds} ms");

        unawaited(chatMapFuture.then(_patchChatIds));
      } else if (!hasCache) {
        responseError.value = result.message ?? appL10n.common_somethingWentWrong;
      } else {
        refreshFailed.value = true; // saved list stays on screen
      }
    } catch (e) {
      if (!hasCache) {
        responseError.value = e.toString();
      } else {
        refreshFailed.value = true; // saved list stays; offline / timeout
      }
      log("CONTACT LOAD ERROR => $e");
    } finally {
      _isFetching = false;
      isResolving.value = false;
      contactLoading.value = false;
    }
  }

  void _patchChatIds(Map<int, int> map) {
    if (isClosed) return;
    final updated = ContactMatcher.patchChatIds(matchedUsers, map);
    if (updated == null) return;

    matchedUsers.assignAll(updated);
    _cachedMatched = List<UserListData>.from(updated);
    _saveMatched(updated);
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
}