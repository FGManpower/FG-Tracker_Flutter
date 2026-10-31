import 'dart:convert';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:get/get.dart';

class GroupCountService extends GetxService {
  static const String storageKey = 'cached_group_dashboard_counts';

  static GroupCountService get instance {
    if (!Get.isRegistered<GroupCountService>()) {
      Get.put(GroupCountService(), permanent: true);
    }
    return Get.find<GroupCountService>();
  }

  final Rx<GroupCountDetail> groupCount = const GroupCountDetail().obs;

  int get totalGroups => groupCount.value.totalGroups;
  int get totalMembers => groupCount.value.totalMembers;
  int get activeMembers => groupCount.value.activeMembers;
  int get locationDisabledMembers => groupCount.value.locationDisabledMembers;

  @override
  void onInit() {
    super.onInit();
    loadFromCache();
  }

  void loadFromCache() {
    try {
      final cachedJsonStr = Global.storageServices.get(storageKey);
      if (cachedJsonStr != null && cachedJsonStr.trim().isNotEmpty) {
        final dynamic decoded = jsonDecode(cachedJsonStr);
        if (decoded is Map) {
          groupCount.value = GroupCountDetail.fromJson(decoded);
        }
      }
    } catch (_) {}
  }

  void updateFromSocket(dynamic data) {
    if (data != null) {
      final detail = GroupCountDetail.fromJson(data);
      groupCount.value = detail;
      try {
        Global.storageServices.setString(storageKey, jsonEncode(detail.toJson()));
      } catch (_) {}
    }
  }

  void clearCache() {
    groupCount.value = const GroupCountDetail();
    try {
      Global.storageServices.remove(storageKey);
    } catch (_) {}
  }
}