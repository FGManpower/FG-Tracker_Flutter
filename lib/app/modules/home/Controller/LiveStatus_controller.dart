import 'dart:developer';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/group_member_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Track/Controller/GroupTrackController.dart';

class LivesStatusController extends GetxController {
  static LivesStatusController get instance =>
      Get.isRegistered<LivesStatusController>()
          ? Get.find<LivesStatusController>()
          : Get.put(LivesStatusController());

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxList<GroupMemberData> allMemberList = <GroupMemberData>[].obs;
  final RxList<GroupMemberData> filteredAllMemberList = <GroupMemberData>[].obs;

  final Rx<MemberMetaData?> metaData = Rx<MemberMetaData?>(null);
  final RxInt totalMembersCount = 0.obs;
  final RxInt activeMembersCount = 0.obs;
  final RxInt inactiveMembersCount = 0.obs;
  final RxInt newMembersCount = 0.obs;

  final RxBool allMemberLoading = false.obs;
  final RxBool allMemberLoadingMore = false.obs;
  final RxString allResponseError = ''.obs;
  final RxInt allCurrentPage = 1.obs;
  final RxBool hasMoreAllMembers = true.obs;
  final RxBool isAllMembersAscending = true.obs;

  final RxList<GroupMemberData> onlineNowList = <GroupMemberData>[].obs;
  final RxList<GroupMemberData> recentlyOnlineList = <GroupMemberData>[].obs;
  final RxList<GroupMemberData> filteredOnlineNowList = <GroupMemberData>[].obs;
  final RxList<GroupMemberData> filteredRecentlyOnlineList =
      <GroupMemberData>[].obs;

  final RxBool onlineLoading = false.obs;
  final RxBool onlineLoadingMore = false.obs;
  final RxString onlineResponseError = ''.obs;
  final RxInt onlineCurrentPage = 1.obs;
  final RxBool hasMoreOnlineMembers = true.obs;

  final RxList<GroupMemberData> privateMemberList = <GroupMemberData>[].obs;
  final RxList<GroupMemberData> filteredPrivateMemberList =
      <GroupMemberData>[].obs;

  final RxBool privateLoading = false.obs;
  final RxBool privateLoadingMore = false.obs;
  final RxString privateResponseError = ''.obs;
  final RxInt privateCurrentPage = 1.obs;
  final RxBool hasMorePrivateMembers = true.obs;
  final RxBool isMyPrivateModeOn = false.obs;

  RxList<GroupMemberData> get memberData => onlineNowList;
  RxList<GroupMemberData> get currentOnlineMembers => onlineNowList;
  RxList<GroupMemberData> get recentOnlineMembers => recentlyOnlineList;
  RxList<GroupMemberData> get privateMemberData => privateMemberList;
  RxList<GroupMemberData> get allMemberData => allMemberList;
  RxBool get memberLoading => onlineLoading;
  RxBool get privateMemberLoading => privateLoading;

  @override
  void onInit() {
    super.onInit();
    _loadMyPrivateStatus();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadMyPrivateStatus() {
    final bool? syncVal =
        Global.storageServices.getBoolSync(PrefConst.locationSharing);
    if (syncVal != null) {
      isMyPrivateModeOn.value = !syncVal;
      return;
    }
    final rawSharing = Global.storageServices.get(PrefConst.locationSharing);
    if (rawSharing != null) {
      final s = rawSharing.trim().toLowerCase();
      isMyPrivateModeOn.value = (s == 'false' || s == '0');
    }
  }

  Future<void> getAllMembers({bool refresh = false}) async {
    if (allMemberLoading.value || allMemberLoadingMore.value) return;

    allMemberLoading.value = true;
    allResponseError.value = '';
    allCurrentPage.value = 1;
    hasMoreAllMembers.value = true;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: '1',
        filter: 'all',
        limit: 20,
      );

      if (result.status != true) {
        allResponseError.value = result.message ?? 'Failed to load members';
        return;
      }

      final AllMember? allMember = result.data?.allMember;
      if (allMember?.metaData != null) {
        metaData.value = allMember!.metaData;
        totalMembersCount.value = allMember.metaData?.totalMembers ?? 0;
        activeMembersCount.value = allMember.metaData?.totalOnlineMembers ?? 0;
        inactiveMembersCount.value =
            allMember.metaData?.totalOfflineMembers ?? 0;
        newMembersCount.value = allMember.metaData?.totalNewMembers ?? 0;
      }

      final List<GroupMemberData> list = allMember?.memberList ?? [];
      allMemberList.assignAll(list);
      _applyAllMembersFilter();

      final pagination = result.pagination;
      if (pagination != null) {
        hasMoreAllMembers.value = pagination.hasNextPage == true ||
            (pagination.currentPage != null &&
                pagination.totalPages != null &&
                pagination.currentPage! < pagination.totalPages!);
      } else {
        hasMoreAllMembers.value = list.length >= 20;
      }
    } catch (e) {
      log("❌ [LiveStatusController] getAllMembers error: $e");
      allResponseError.value = e.toString();
    } finally {
      allMemberLoading.value = false;
    }
  }

  Future<void> loadMoreAllMembers() async {
    if (allMemberLoading.value ||
        allMemberLoadingMore.value ||
        !hasMoreAllMembers.value) {
      return;
    }

    allMemberLoadingMore.value = true;
    final nextPage = allCurrentPage.value + 1;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: 'all',
        limit: 20,
      );

      if (result.status == true) {
        final List<GroupMemberData> newList =
            result.data?.allMember?.memberList ?? [];
        if (newList.isNotEmpty) {
          allCurrentPage.value = nextPage;
          for (final item in newList) {
            if (!allMemberList.any((e) => e.userId == item.userId)) {
              allMemberList.add(item);
            }
          }
          _applyAllMembersFilter();
        }

        final pagination = result.pagination;
        if (pagination != null) {
          hasMoreAllMembers.value = pagination.hasNextPage == true ||
              (pagination.currentPage != null &&
                  pagination.totalPages != null &&
                  pagination.currentPage! < pagination.totalPages!);
        } else {
          hasMoreAllMembers.value = newList.length >= 20;
        }
      } else {
        hasMoreAllMembers.value = false;
      }
    } catch (e) {
      log("❌ [LiveStatusController] loadMoreAllMembers error: $e");
    } finally {
      allMemberLoadingMore.value = false;
    }
  }

  void searchAllMembers(String query) {
    searchQuery.value = query;
    _applyAllMembersFilter();
  }

  void sortAllMembers({bool? ascending}) {
    if (ascending != null) {
      isAllMembersAscending.value = ascending;
    } else {
      isAllMembersAscending.value = !isAllMembersAscending.value;
    }
    _applyAllMembersFilter();
  }

  void _applyAllMembersFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    List<GroupMemberData> list = List.from(allMemberList);

    if (query.isNotEmpty) {
      list = list.where((item) {
        final name = item.displayName.toLowerCase();
        final dept = item.displayDepartment.toLowerCase();
        final phone = (item.phone ?? '').toLowerCase();
        return name.contains(query) ||
            dept.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    list.sort((a, b) {
      final comp =
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      return isAllMembersAscending.value ? comp : -comp;
    });

    filteredAllMemberList.assignAll(list);
  }

  Future<void> getOnlineMembers({bool refresh = false}) async {
    if (onlineLoading.value || onlineLoadingMore.value) return;

    onlineLoading.value = true;
    onlineResponseError.value = '';
    onlineCurrentPage.value = 1;
    hasMoreOnlineMembers.value = true;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: '1',
        filter: 'online',
        limit: 20,
      );

      if (result.status != true) {
        onlineResponseError.value =
            result.message ?? 'Failed to load online members';
        return;
      }

      final List<GroupMemberData> active = result.data?.active ?? [];
      final List<GroupMemberData> recent = result.data?.recentActive ?? [];

      onlineNowList.assignAll(active);
      recentlyOnlineList.assignAll(recent);

      _applyOnlineFilter();

      final pagination = result.pagination;
      if (pagination != null) {
        hasMoreOnlineMembers.value = pagination.hasNextPage == true ||
            (pagination.currentPage != null &&
                pagination.totalPages != null &&
                pagination.currentPage! < pagination.totalPages!);
      } else {
        hasMoreOnlineMembers.value = (active.length + recent.length) >= 20;
      }
    } catch (e) {
      log("❌ [LiveStatusController] getOnlineMembers error: $e");
      onlineResponseError.value = e.toString();
    } finally {
      onlineLoading.value = false;
    }
  }

  Future<void> getGroupMember() => getOnlineMembers();
  Future<void> loadMoreMembers() => loadMoreOnlineMembers();

  Future<void> loadMoreOnlineMembers() async {
    if (onlineLoading.value ||
        onlineLoadingMore.value ||
        !hasMoreOnlineMembers.value) {
      return;
    }

    onlineLoadingMore.value = true;
    final nextPage = onlineCurrentPage.value + 1;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: 'online',
        limit: 20,
      );

      if (result.status == true) {
        final List<GroupMemberData> newActive = result.data?.active ?? [];
        final List<GroupMemberData> newRecent = result.data?.recentActive ?? [];

        if (newActive.isNotEmpty || newRecent.isNotEmpty) {
          onlineCurrentPage.value = nextPage;

          for (final item in newActive) {
            if (!onlineNowList.any((e) => e.userId == item.userId)) {
              onlineNowList.add(item);
            }
          }
          for (final item in newRecent) {
            if (!recentlyOnlineList.any((e) => e.userId == item.userId)) {
              recentlyOnlineList.add(item);
            }
          }
          _applyOnlineFilter();
        }

        final pagination = result.pagination;
        if (pagination != null) {
          hasMoreOnlineMembers.value = pagination.hasNextPage == true ||
              (pagination.currentPage != null &&
                  pagination.totalPages != null &&
                  pagination.currentPage! < pagination.totalPages!);
        } else {
          hasMoreOnlineMembers.value =
              (newActive.length + newRecent.length) >= 20;
        }
      } else {
        hasMoreOnlineMembers.value = false;
      }
    } catch (e) {
      log("❌ [LiveStatusController] loadMoreOnlineMembers error: $e");
    } finally {
      onlineLoadingMore.value = false;
    }
  }

  void searchOnlineMembers(String query) {
    searchQuery.value = query;
    _applyOnlineFilter();
  }

  void _applyOnlineFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredOnlineNowList.assignAll(onlineNowList);
      filteredRecentlyOnlineList.assignAll(recentlyOnlineList);
      return;
    }

    filteredOnlineNowList.assignAll(
      onlineNowList.where((item) {
        final name = item.displayName.toLowerCase();
        final dept = item.displayDepartment.toLowerCase();
        return name.contains(query) || dept.contains(query);
      }),
    );

    filteredRecentlyOnlineList.assignAll(
      recentlyOnlineList.where((item) {
        final name = item.displayName.toLowerCase();
        final dept = item.displayDepartment.toLowerCase();
        return name.contains(query) || dept.contains(query);
      }),
    );
  }

  Future<void> getPrivateMembers({bool refresh = false}) async {
    if (privateLoading.value || privateLoadingMore.value) return;

    privateLoading.value = true;
    privateResponseError.value = '';
    privateCurrentPage.value = 1;
    hasMorePrivateMembers.value = true;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: '1',
        filter: 'private',
        limit: 20,
      );

      if (result.status != true) {
        privateResponseError.value =
            result.message ?? 'Failed to load private members';
        return;
      }

      final List<GroupMemberData> list = result.data?.private ?? [];
      privateMemberList.assignAll(list);
      _applyPrivateFilter();

      final pagination = result.pagination;
      if (pagination != null) {
        hasMorePrivateMembers.value = pagination.hasNextPage == true ||
            (pagination.currentPage != null &&
                pagination.totalPages != null &&
                pagination.currentPage! < pagination.totalPages!);
      } else {
        hasMorePrivateMembers.value = list.length >= 20;
      }
    } catch (e) {
      log("❌ [LiveStatusController] getPrivateMembers error: $e");
      privateResponseError.value = e.toString();
    } finally {
      privateLoading.value = false;
    }
  }

  Future<void> loadMorePrivateMembers() async {
    if (privateLoading.value ||
        privateLoadingMore.value ||
        !hasMorePrivateMembers.value) {
      return;
    }

    privateLoadingMore.value = true;
    final nextPage = privateCurrentPage.value + 1;

    try {
      final GroupMemberModel result = await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: 'private',
        limit: 20,
      );

      if (result.status == true) {
        final List<GroupMemberData> newList = result.data?.private ?? [];
        if (newList.isNotEmpty) {
          privateCurrentPage.value = nextPage;
          for (final item in newList) {
            if (!privateMemberList.any((e) => e.userId == item.userId)) {
              privateMemberList.add(item);
            }
          }
          _applyPrivateFilter();
        }

        final pagination = result.pagination;
        if (pagination != null) {
          hasMorePrivateMembers.value = pagination.hasNextPage == true ||
              (pagination.currentPage != null &&
                  pagination.totalPages != null &&
                  pagination.currentPage! < pagination.totalPages!);
        } else {
          hasMorePrivateMembers.value = newList.length >= 20;
        }
      } else {
        hasMorePrivateMembers.value = false;
      }
    } catch (e) {
      log("❌ [LiveStatusController] loadMorePrivateMembers error: $e");
    } finally {
      privateLoadingMore.value = false;
    }
  }

  void searchPrivateMembers(String query) {
    searchQuery.value = query;
    _applyPrivateFilter();
  }

  void _applyPrivateFilter() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredPrivateMemberList.assignAll(privateMemberList);
      return;
    }

    filteredPrivateMemberList.assignAll(
      privateMemberList.where((item) {
        final name = item.displayName.toLowerCase();
        final dept = item.displayDepartment.toLowerCase();
        return name.contains(query) || dept.contains(query);
      }),
    );
  }

  Future<bool> togglePrivateMode(bool enablePrivate) async {
    try {
      final bool newLocationSharing = !enablePrivate;

      final success = await TrackRepo.updateLocationSharing(newLocationSharing);

      if (success) {
        isMyPrivateModeOn.value = enablePrivate;

        Global.storageServices.setBool(
          PrefConst.locationSharing,
          newLocationSharing,
        );

        if (Get.isRegistered<GroupTrackingController>()) {
          final trackingController = Get.find<GroupTrackingController>();

          trackingController.isLocationSharing.value = newLocationSharing;
        }

        await getPrivateMembers(refresh: true);

        return true;
      }

      return false;
    } catch (e) {
      log("❌ [LiveStatusController] togglePrivateMode error: $e");
      return false;
    }
  }
}
