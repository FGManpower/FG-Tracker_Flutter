import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/status_repo.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/status/controller/status_view_controller.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../Core/constant/pref_res.dart';

class StatusFeedController extends GetxController {
  late final StatusSocketService _socket;

  final RxList<StatusItemModel> myStatuses = <StatusItemModel>[].obs;
  final RxList<ContactStatusGroupModel> contactGroups =
      <ContactStatusGroupModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString defaultPrivacyType = 'ALL_CONTACTS'.obs;
  final RxList<int> defaultTargetUserIds = <int>[].obs;
  final RxSet<int> highlightedUserIds = <int>{}.obs;

  // ---- App cache (doc 07): the status strip shown at once ----

  /// Whose statuses are in memory. This controller is permanent, so it
  /// survives logout; another account must never see these lists.
  String? _loadedFor;
  bool _cacheReadDone = false;
  AppCachePerf? _perf;
  AppLifecycleListener? _lifecycle;

  String? _currentUser() {
    try {
      final v =
          Global.storageServices.get(PrefConst.userId)?.toString().trim();
      return (v == null || v.isEmpty || v == 'null') ? null : v;
    } catch (_) {
      return null; // storage not ready: the cache simply stays off
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initSocket(); // socket first, never waits for the cache (R1)
    _loadedFor = _currentUser();
    _perf = AppCachePerf('status')..mark('open');
    _showCachedStatuses();
    ever<List<StatusItemModel>>(myStatuses, (_) => _scheduleStatusSave());
    ever<List<ContactStatusGroupModel>>(
        contactGroups, (_) => _scheduleStatusSave());
    AppCache.addLogoutListener(_resetForLogout);
    // Gap fill (R4) + expiry: statuses posted / expired while in background.
    _lifecycle = AppLifecycleListener(onResume: () {
      _dropExpired();
      refreshAll();
    });
    refreshAll();
  }

  @override
  void onClose() {
    AppCache.removeLogoutListener(_resetForLogout);
    _lifecycle?.dispose();
    super.onClose();
  }

  /// Logout: the previous user's statuses leave memory at once.
  void _resetForLogout() {
    _cacheReadDone = false; // nothing of this user is saved any more
    myStatuses.clear();
    contactGroups.clear();
    highlightedUserIds.clear();
    _loadedFor = null;
  }

  /// Called by the status strip: after an account switch (this controller
  /// is permanent) load the new user's statuses.
  void ensureLoadedForCurrentUser() {
    final me = _currentUser();
    if (me == null || me == _loadedFor) return;
    _resetForLogout();
    _loadedFor = me;
    _showCachedStatuses();
    refreshAll();
  }

  /// Saved statuses, minus anything deleted or expired (never show an
  /// expired status). A list the API already filled wins (R3).
  Future<void> _showCachedStatuses() async {
    try {
      final mine = await AppCache.readAs(
          AppCache.statusMine, (m) => StatusItemModel.fromJson(m));
      final feed = await AppCache.readAs(
          AppCache.statusFeed, (m) => ContactStatusGroupModel.fromJson(m));
      if (isClosed) return;
      if (myStatuses.isEmpty) {
        myStatuses.assignAll(mine.where((s) => s.isShowableFromCache));
      }
      if (contactGroups.isEmpty) {
        contactGroups.assignAll(_withoutExpired(feed));
      }
      _perf?.mark('cache shown',
          extra: '${myStatuses.length} mine, ${contactGroups.length} contacts');
    } catch (_) {
    } finally {
      _cacheReadDone = true;
    }
  }

  static List<ContactStatusGroupModel> _withoutExpired(
      List<ContactStatusGroupModel> groups) {
    final out = <ContactStatusGroupModel>[];
    for (final g in groups) {
      final live = g.statuses.where((s) => s.isShowableFromCache).toList();
      if (live.isEmpty) continue;
      out.add(ContactStatusGroupModel(
        user: g.user,
        isAllViewed: live.every((s) => s.isViewed),
        latestTimestamp: g.latestTimestamp,
        statuses: live,
      ));
    }
    return out;
  }

  void _dropExpired() {
    myStatuses.removeWhere((s) => !s.isShowableFromCache);
    final kept = _withoutExpired(contactGroups);
    if (kept.length != contactGroups.length ||
        kept.fold<int>(0, (n, g) => n + g.statuses.length) !=
            contactGroups.fold<int>(0, (n, g) => n + g.statuses.length)) {
      contactGroups.assignAll(kept);
    }
  }

  void _scheduleStatusSave() {
    if (!_cacheReadDone || isClosed || _loadedFor == null) return;
    AppCache.scheduleWrite(
      AppCache.statusMine,
      () => [for (final s in myStatuses) s.toJson()],
      allowEmpty: true, // deleted / expired must not come back
    );
    AppCache.scheduleWrite(
      AppCache.statusFeed,
      () => [for (final g in contactGroups) g.toJson()],
      allowEmpty: true,
    );
  }

  void _initSocket() {
    if (Get.isRegistered<StatusSocketService>()) {
      _socket = Get.find<StatusSocketService>();
    } else {
      _socket = Get.put(StatusSocketService(), permanent: true);
      _socket.connect(
        baseUrl: ConstRes.socketUrl,
        token: Global.storageServices.getaccesstoken(),
      );
    }

    ever<Map<String, dynamic>?>(_socket.onNewStatusEvent, (data) {
      if (data == null) return;
      final userId = int.tryParse(data['userId']?.toString() ?? '');
      if (userId != null) {
        highlightedUserIds.add(userId);
      }
      refreshAll();
    });

    ever<Map<String, dynamic>?>(_socket.onStatusViewedEvent, (data) {
      if (data == null) return;
      fetchMyStatuses();
    });

    ever<Map<String, dynamic>?>(_socket.onStatusDeletedEvent, (data) {
      if (data == null) return;
      final int deletedStatusId = data['statusId'] is int
          ? data['statusId']
          : int.tryParse(data['statusId']?.toString() ?? '') ?? 0;
      final int creatorUserId = data['userId'] is int
          ? data['userId']
          : int.tryParse(data['userId']?.toString() ?? '') ?? 0;
      if (deletedStatusId > 0) {
        onStatusDeletedReceived(deletedStatusId, creatorUserId);
      }
    });
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchMyStatuses(),
        fetchFeed(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyStatuses() async {
    try {
      final res = await StatusRepo.getMyStatus()
          .timeout(const Duration(seconds: 10));
      if (res.status) {
        myStatuses.assignAll(res.data);
      }
    } catch (_) {}
  }

  Future<void> fetchFeed() async {
    try {
      final res = await StatusRepo.getStatusFeed()
          .timeout(const Duration(seconds: 10));
      if (res.status) {
        final myUserId = int.tryParse(
          Global.storageServices.get(PrefConst.userId)?.toString() ?? '',
        );
        final filtered = res.data.where((group) {
          if (myUserId != null && group.user.id == myUserId) {
            return false;
          }
          return group.statuses.isNotEmpty;
        }).toList();
        contactGroups.assignAll(filtered);
        _perf?.mark('API done', extra: '${filtered.length} contacts');
      }
    } catch (_) {}
  }

  void onStatusDeletedReceived(int deletedStatusId, int creatorUserId) {
    void applyUpdate() {
      // 1. Remove from myStatuses if it was my status
      myStatuses.removeWhere((item) => item.id == deletedStatusId);

      // 2. Find creator's status group in contactGroups
      int userFeedIndex = -1;
      if (creatorUserId > 0) {
        userFeedIndex = contactGroups.indexWhere(
          (feed) => feed.user.id == creatorUserId,
        );
      }
      if (userFeedIndex == -1) {
        userFeedIndex = contactGroups.indexWhere(
          (feed) => feed.statuses.any((item) => item.id == deletedStatusId),
        );
      }

      if (userFeedIndex != -1) {
        contactGroups[userFeedIndex].statuses.removeWhere(
          (item) => item.id == deletedStatusId,
        );

        if (contactGroups[userFeedIndex].statuses.isEmpty) {
          final removedUserId = contactGroups[userFeedIndex].user.id;
          highlightedUserIds.remove(removedUserId);
          contactGroups.removeAt(userFeedIndex);
        } else {
          final updatedStatuses = contactGroups[userFeedIndex].statuses;
          final allViewed = updatedStatuses.every((s) => s.isViewed);
          contactGroups[userFeedIndex] = ContactStatusGroupModel(
            user: contactGroups[userFeedIndex].user,
            isAllViewed: allViewed,
            latestTimestamp: contactGroups[userFeedIndex].latestTimestamp,
            statuses: updatedStatuses,
          );
          if (allViewed) {
            highlightedUserIds.remove(contactGroups[userFeedIndex].user.id);
          }
          contactGroups.refresh();
        }
      }

      // 3. Notify active Story Viewer if open
      if (Get.isRegistered<StatusViewController>()) {
        Get.find<StatusViewController>().handleStoryDeletionIfActive(
          deletedStatusId,
          creatorUserId: creatorUserId,
        );
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => applyUpdate());
    } else {
      applyUpdate();
    }
  }

  void markStatusViewedLocally(int statusId, {String? reactionEmoji}) {
    void applyUpdate() {
      for (int g = 0; g < contactGroups.length; g++) {
        final group = contactGroups[g];
        final idx = group.statuses.indexWhere((s) => s.id == statusId);
        if (idx != -1) {
          final updatedStatuses = List<StatusItemModel>.from(group.statuses);
          updatedStatuses[idx] = updatedStatuses[idx].copyWith(
            isViewed: true,
            myReaction: reactionEmoji ?? updatedStatuses[idx].myReaction,
          );
          final allViewed = updatedStatuses.every((s) => s.isViewed);
          contactGroups[g] = ContactStatusGroupModel(
            user: group.user,
            isAllViewed: allViewed,
            latestTimestamp: group.latestTimestamp,
            statuses: updatedStatuses,
          );
          highlightedUserIds.remove(group.user.id);
          break;
        }
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => applyUpdate());
    } else {
      applyUpdate();
    }
  }

  Future<bool> deleteMyStatus(int statusId) async {
    try {
      final res = await StatusRepo.deleteStatus(statusId);
      final ok = res.status == true;
      if (ok) {
        final myUserId = int.tryParse(
          Global.storageServices.get(PrefConst.userId)?.toString() ?? '',
        ) ?? 0;
        onStatusDeletedReceived(statusId, myUserId);
        await fetchFeed();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}