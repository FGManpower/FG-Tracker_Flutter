import 'dart:developer';
import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/ghost_member_model.dart';
import 'package:fgtracker/app/Model/online_member_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LivesStatusController extends GetxController {
  static LivesStatusController get instance =>
      Get.put(LivesStatusController());

  final TextEditingController searchController =
  TextEditingController();

  final RxList<OnlineMemberData> memberData =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> currentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> recentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> filteredMembers =
      <OnlineMemberData>[].obs;

  final RxString searchQuery = ''.obs;

  final RxBool memberLoading = false.obs;
  final RxBool memberLoadingMore = false.obs;

  final RxString responseError = ''.obs;

  final RxInt pagination = 0.obs;

  final RxBool hasMoreMembers = true.obs;

  final RxString memberFilter = 'online'.obs;

  final RxList<GhostMemberData> privateMemberData =
      <GhostMemberData>[].obs;

  final RxBool privateMemberLoading = false.obs;
  final RxBool privateMemberLoadingMore = false.obs;

  final RxString privateResponseError = ''.obs;

  final RxInt privatePagination = 0.obs;

  final RxBool hasMorePrivateMembers = true.obs;

  final RxList<OnlineMemberData> allMemberData =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> allCurrentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> allRecentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> filteredAllMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> filteredCurrentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxList<OnlineMemberData> filteredRecentOnlineMembers =
      <OnlineMemberData>[].obs;

  final RxBool allMemberLoading = false.obs;
  final RxBool allMemberLoadingMore = false.obs;

  final RxString allResponseError = ''.obs;

  final RxInt allPagination = 0.obs;

  final RxBool hasMoreAllMembers = true.obs;

  final RxInt totalMembersCount = 0.obs;
  final RxInt activeMembersCount = 0.obs;
  final RxInt inactiveMembersCount = 0.obs;
  final RxInt privateMembersCount = 0.obs;
  final RxInt newMembersCount = 0.obs;

  RxList<OnlineMemberData> get filtermember {
    return filteredMembers;
  }

  @override
  void onInit() {
    super.onInit();

    getGroupMember();
    getPrivateMembers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> getGroupMember() async {
    if (memberLoading.value ||
        memberLoadingMore.value) {
      return;
    }

    memberLoading.value = true;
    responseError.value = '';

    pagination.value = 0;
    hasMoreMembers.value = true;

    memberData.clear();
    filteredMembers.clear();

    try {
      final OnlineMemberModel result =
      await TrackRepo.getGroupMember(
        page: '1',
        filter: 'online',
        limit: 20,
      );

      if (result.status != true) {
        responseError.value =
            result.message ?? 'Something went wrong';
        return;
      }

      final List<OnlineMemberData> currentOnline =
          result.data?.currentOnline ??
              <OnlineMemberData>[];

      final List<OnlineMemberData> recentOnline =
          result.data?.recentOnline ??
              <OnlineMemberData>[];

      currentOnlineMembers.assignAll(currentOnline);
      recentOnlineMembers.assignAll(recentOnline);

      final List<OnlineMemberData> apiMembers = [
        ...currentOnline,
        ...recentOnline,
      ];

      memberData.assignAll(apiMembers);

      pagination.value =
          result.pagination?.currentPage ?? 1;

      hasMoreMembers.value =
          result.pagination?.hasNextPage ?? (apiMembers.length >= 20);

      _applySearch();
    } catch (error) {
      responseError.value = error.toString();
    } finally {
      memberLoading.value = false;
    }
  }

  Future<void> loadMoreMembers() async {
    if (memberLoading.value ||
        memberLoadingMore.value ||
        !hasMoreMembers.value) {
      return;
    }

    memberLoadingMore.value = true;

    try {
      final int nextPage =
          pagination.value + 1;

      final OnlineMemberModel result =
      await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: 'online',
        limit: 20,
      );

      if (result.status != true) {
        hasMoreMembers.value = false;
        return;
      }

      final List<OnlineMemberData> currentOnline =
          result.data?.currentOnline ??
              <OnlineMemberData>[];

      final List<OnlineMemberData> recentOnline =
          result.data?.recentOnline ??
              <OnlineMemberData>[];

      final List<OnlineMemberData> apiMembers = [
        ...currentOnline,
        ...recentOnline,
      ];

      if (apiMembers.isEmpty) {
        hasMoreMembers.value = false;
        return;
      }

      for (final OnlineMemberData member in currentOnline) {
        if (member.userId == null) {
          currentOnlineMembers.add(member);
        } else if (!currentOnlineMembers.any((m) => m.userId == member.userId)) {
          currentOnlineMembers.add(member);
        }
      }

      for (final OnlineMemberData member in recentOnline) {
        if (member.userId == null) {
          recentOnlineMembers.add(member);
        } else if (!recentOnlineMembers.any((m) => m.userId == member.userId)) {
          recentOnlineMembers.add(member);
        }
      }

      for (final OnlineMemberData member in apiMembers) {
        if (member.userId == null) {
          memberData.add(member);
          continue;
        }

        final bool exists = memberData.any(
              (OnlineMemberData existing) =>
          existing.userId == member.userId,
        );

        if (!exists) {
          memberData.add(member);
        }
      }

      pagination.value =
          result.pagination?.currentPage ??
              nextPage;

      hasMoreMembers.value =
          result.pagination?.hasNextPage ?? (apiMembers.length >= 20);

      _applySearch();
    } catch (error) {
      responseError.value = error.toString();
    } finally {
      memberLoadingMore.value = false;
    }
  }

  Future<void> getAllMembers() async {
    if (allMemberLoading.value ||
        allMemberLoadingMore.value) {
      log("⚠️ [LiveStatusController] getAllMembers skipped: already loading");
      return;
    }

    log("🟢 [LiveStatusController] getAllMembers() started...");

    allMemberLoading.value = true;
    allResponseError.value = '';

    allPagination.value = 0;
    hasMoreAllMembers.value = true;

    allMemberData.clear();
    allCurrentOnlineMembers.clear();
    allRecentOnlineMembers.clear();
    filteredAllMembers.clear();
    filteredCurrentOnlineMembers.clear();
    filteredRecentOnlineMembers.clear();

    try {
      final OnlineMemberModel result =
      await TrackRepo.getGroupMember(
        page: '1',
        filter: 'all',
        limit: 20,
      );

      if (result.status != true) {
        log("❌ [LiveStatusController] getAllMembers failed: ${result.message}");
        allResponseError.value =
            result.message ?? 'Something went wrong';
        return;
      }

      List<OnlineMemberData> currentOnline =
          result.data?.currentOnline ??
              <OnlineMemberData>[];

      List<OnlineMemberData> recentOnline =
          result.data?.recentOnline ??
              <OnlineMemberData>[];

      // Fallback: If recentOnline is empty but currentOnline contains offline members, split them
      if (recentOnline.isEmpty && currentOnline.any((m) => m.isOnline != 1 && !m.online)) {
        final onlineOnly = currentOnline.where((m) => m.isOnline == 1 || m.online).toList();
        final offlineOnly = currentOnline.where((m) => m.isOnline != 1 && !m.online).toList();
        currentOnline = onlineOnly;
        recentOnline = offlineOnly;
      }

      allCurrentOnlineMembers.assignAll(currentOnline);
      allRecentOnlineMembers.assignAll(recentOnline);

      final List<OnlineMemberData> members = [
        ...currentOnline,
        ...recentOnline,
      ];

      allMemberData.assignAll(members);

      totalMembersCount.value =
          result.metaData?.totalMembers ??
              members.length;

      activeMembersCount.value =
          result.metaData?.totalOnlineMembers ??
              currentOnline.length;

      inactiveMembersCount.value =
          result.metaData?.totalOfflineMembers ??
              recentOnline.length;

      privateMembersCount.value =
          result.metaData?.totalPrivateMembers ?? 0;

      newMembersCount.value =
          result.metaData?.totalNewMembers ?? 0;

      allPagination.value =
          result.pagination?.currentPage ?? 1;

      hasMoreAllMembers.value =
          result.pagination?.hasNextPage ?? (members.length >= 20);

      _applyAllSearch();

      log("🟢 [LiveStatusController] getAllMembers loaded: ${members.length} members (online: ${currentOnline.length}, recent: ${recentOnline.length}, total: ${totalMembersCount.value})");
    } catch (error) {
      log("❌ [LiveStatusController] getAllMembers error: $error");
      allResponseError.value = error.toString();
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

    try {
      final int nextPage =
          allPagination.value + 1;

      final OnlineMemberModel result =
      await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: 'all',
        limit: 20,
      );

      if (result.status != true) {
        hasMoreAllMembers.value = false;
        return;
      }

      List<OnlineMemberData> currentOnline =
          result.data?.currentOnline ??
              <OnlineMemberData>[];

      List<OnlineMemberData> recentOnline =
          result.data?.recentOnline ??
              <OnlineMemberData>[];

      if (recentOnline.isEmpty && currentOnline.any((m) => m.isOnline != 1 && !m.online)) {
        final onlineOnly = currentOnline.where((m) => m.isOnline == 1 || m.online).toList();
        final offlineOnly = currentOnline.where((m) => m.isOnline != 1 && !m.online).toList();
        currentOnline = onlineOnly;
        recentOnline = offlineOnly;
      }

      final List<OnlineMemberData> members = [
        ...currentOnline,
        ...recentOnline,
      ];

      if (members.isEmpty) {
        hasMoreAllMembers.value = false;
        return;
      }

      for (final OnlineMemberData member in currentOnline) {
        if (member.userId == null) {
          allCurrentOnlineMembers.add(member);
        } else if (!allCurrentOnlineMembers.any((m) => m.userId == member.userId)) {
          allCurrentOnlineMembers.add(member);
        }
      }

      for (final OnlineMemberData member in recentOnline) {
        if (member.userId == null) {
          allRecentOnlineMembers.add(member);
        } else if (!allRecentOnlineMembers.any((m) => m.userId == member.userId)) {
          allRecentOnlineMembers.add(member);
        }
      }

      for (final OnlineMemberData member in members) {
        if (member.userId == null) {
          allMemberData.add(member);
          continue;
        }

        final bool exists = allMemberData.any(
              (OnlineMemberData existing) =>
          existing.userId == member.userId,
        );

        if (!exists) {
          allMemberData.add(member);
        }
      }

      if (result.metaData != null) {
        if (result.metaData!.totalMembers != null) {
          totalMembersCount.value = result.metaData!.totalMembers!;
        }
        if (result.metaData!.totalOnlineMembers != null) {
          activeMembersCount.value = result.metaData!.totalOnlineMembers!;
        }
        if (result.metaData!.totalOfflineMembers != null) {
          inactiveMembersCount.value = result.metaData!.totalOfflineMembers!;
        }
        if (result.metaData!.totalPrivateMembers != null) {
          privateMembersCount.value = result.metaData!.totalPrivateMembers!;
        }
        if (result.metaData!.totalNewMembers != null) {
          newMembersCount.value = result.metaData!.totalNewMembers!;
        }
      }

      allPagination.value =
          result.pagination?.currentPage ??
              nextPage;

      hasMoreAllMembers.value =
          result.pagination?.hasNextPage ?? (members.length >= 20);

      _applyAllSearch();

      log("🟢 [LiveStatusController] loadMoreAllMembers loaded page $nextPage with ${members.length} items");
    } catch (error) {
      log("❌ [LiveStatusController] loadMoreAllMembers error: $error");
      allResponseError.value = error.toString();
    } finally {
      allMemberLoadingMore.value = false;
    }
  }

  Future<void> getPrivateMembers() async {
    if (privateMemberLoading.value ||
        privateMemberLoadingMore.value) {
      return;
    }

    privateMemberLoading.value = true;
    privateResponseError.value = '';

    privatePagination.value = 0;
    hasMorePrivateMembers.value = true;

    privateMemberData.clear();

    try {
      final GhostMemberModel result =
      await TrackRepo.getPrivateMembers(
        page: '1',
        limit: 20,
      );

      if (result.status != true) {
        privateResponseError.value =
            result.message ?? 'Something went wrong';
        return;
      }

      final List<GhostMemberData> members =
      List<GhostMemberData>.from(
        result.data ??
            <GhostMemberData>[],
      );

      privateMemberData.assignAll(members);

      privatePagination.value =
          result.pagination?.currentPage ?? 1;

      hasMorePrivateMembers.value =
          result.pagination?.hasNextPage ?? false;
    } catch (error) {
      privateResponseError.value =
          error.toString();
    } finally {
      privateMemberLoading.value = false;
    }
  }

  Future<void> loadMorePrivateMembers() async {
    if (privateMemberLoading.value ||
        privateMemberLoadingMore.value ||
        !hasMorePrivateMembers.value) {
      return;
    }

    privateMemberLoadingMore.value = true;

    try {
      final int nextPage =
          privatePagination.value + 1;

      final GhostMemberModel result =
      await TrackRepo.getPrivateMembers(
        page: nextPage.toString(),
        limit: 20,
      );

      if (result.status != true) {
        hasMorePrivateMembers.value = false;
        return;
      }

      final List<GhostMemberData> members =
      List<GhostMemberData>.from(
        result.data ??
            <GhostMemberData>[],
      );

      if (members.isNotEmpty) {
        privateMemberData.addAll(members);
      }

      privatePagination.value =
          result.pagination?.currentPage ??
              nextPage;

      hasMorePrivateMembers.value =
          result.pagination?.hasNextPage ?? false;
    } catch (error) {
      privateResponseError.value =
          error.toString();
    } finally {
      privateMemberLoadingMore.value = false;
    }
  }

  Future<void> refreshPrivateMembers() async {
    privateMemberLoading.value = false;
    privateMemberLoadingMore.value = false;

    await getPrivateMembers();
  }

  Future<void> loadMoreRecentCalls() async {
    await loadMoreMembers();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _applySearch();
  }

  void onAllSearchChanged(String value) {
    searchQuery.value = value;
    _applyAllSearch();
  }

  void searchMembers(String value) {
    onSearchChanged(value);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';

    filteredMembers.assignAll(
      List<OnlineMemberData>.from(
        memberData,
      ),
    );
  }

  void clearAllSearch() {
    searchController.clear();
    searchQuery.value = '';

    filteredAllMembers.assignAll(
      List<OnlineMemberData>.from(allMemberData),
    );
    filteredCurrentOnlineMembers.assignAll(
      List<OnlineMemberData>.from(allCurrentOnlineMembers),
    );
    filteredRecentOnlineMembers.assignAll(
      List<OnlineMemberData>.from(allRecentOnlineMembers),
    );
  }

  void _applySearch() {
    final String query =
    searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredMembers.assignAll(
        List<OnlineMemberData>.from(
          memberData,
        ),
      );
      return;
    }

    final List<OnlineMemberData> result =
    memberData.where(
          (OnlineMemberData member) {
        final String name =
            member.name?.toLowerCase() ?? '';

        final String mobile =
            member.mobileNo?.toLowerCase() ?? '';

        return name.contains(query) ||
            mobile.contains(query);
      },
    ).toList();

    filteredMembers.assignAll(result);
  }

  void _applyAllSearch() {
    final String query =
    searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredAllMembers.assignAll(
        List<OnlineMemberData>.from(allMemberData),
      );
      filteredCurrentOnlineMembers.assignAll(
        List<OnlineMemberData>.from(allCurrentOnlineMembers),
      );
      filteredRecentOnlineMembers.assignAll(
        List<OnlineMemberData>.from(allRecentOnlineMembers),
      );
      return;
    }

    bool matches(OnlineMemberData member) {
      final String name = member.name?.toLowerCase() ?? '';
      final String mobile = member.mobileNo?.toLowerCase() ?? '';
      final String dept = member.department?.toLowerCase() ?? '';
      return name.contains(query) ||
          mobile.contains(query) ||
          dept.contains(query);
    }

    filteredAllMembers.assignAll(
      allMemberData.where(matches).toList(),
    );
    filteredCurrentOnlineMembers.assignAll(
      allCurrentOnlineMembers.where(matches).toList(),
    );
    filteredRecentOnlineMembers.assignAll(
      allRecentOnlineMembers.where(matches).toList(),
    );
  }

  Future<void> refreshMembers() async {
    memberLoading.value = false;
    memberLoadingMore.value = false;

    await getGroupMember();
  }

  Future<void> refreshAllMembers() async {
    allMemberLoading.value = false;
    allMemberLoadingMore.value = false;

    await getAllMembers();
  }

  Future<void> changeFilter(String filter) async {
    final bool isSame =
        memberFilter.value == filter;

    memberFilter.value = filter;

    if (isSame && memberData.isNotEmpty) {
      return;
    }

    await getGroupMember();
  }

  int get onlineMembersCount {
    return memberData
        .where(
          (OnlineMemberData member) =>
      member.isOnline == 1 ||
          member.online,
    )
        .length;
  }

  int get recentlyOnlineCount {
    return memberData
        .where(
          (OnlineMemberData member) =>
      member.isOnline != 1 &&
          !member.online,
    )
        .length;
  }

  bool get isInitialLoading {
    return memberLoading.value &&
        memberData.isEmpty;
  }

  bool get isLoadingMore {
    return memberLoadingMore.value;
  }
}