import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/status_repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Model/status_model.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class StatusFeedController extends GetxController {
  late final StatusSocketService _socket;

  final RxList<StatusItemModel> myStatuses = <StatusItemModel>[].obs;
  final RxList<ContactStatusGroupModel> contactGroups =
      <ContactStatusGroupModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString defaultPrivacyType = 'ALL_CONTACTS'.obs;
  final RxList<int> defaultTargetUserIds = <int>[].obs;
  final RxSet<int> highlightedUserIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initSocket();
    refreshAll();
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
      final res = await StatusRepo.getMyStatus();
      if (res.status) {
        myStatuses.assignAll(res.data);
      }
    } catch (_) {}
  }

  Future<void> fetchFeed() async {
    try {
      final res = await StatusRepo.getStatusFeed();
      if (res.status) {
        final myIds = myStatuses.map((e) => e.id).toSet();
        final filtered = res.data.where((group) {
          if (myIds.isEmpty) return true;
          return !group.statuses.every((s) => myIds.contains(s.id));
        }).toList();
        contactGroups.assignAll(filtered);
      }
    } catch (_) {}
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
        myStatuses.removeWhere((s) => s.id == statusId);
        await fetchFeed();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }
}