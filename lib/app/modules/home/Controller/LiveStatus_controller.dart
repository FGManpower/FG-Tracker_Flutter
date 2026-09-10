import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
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

  final RxList<OnlineMemberData> filteredMembers =
      <OnlineMemberData>[].obs;

  final RxString searchQuery = ''.obs;

  final RxBool memberLoading = false.obs;
  final RxBool memberLoadingMore = false.obs;

  final RxString responseError = ''.obs;

  final RxInt pagination = 0.obs;

  final RxBool hasMoreMembers = true.obs;

  final RxString memberFilter = 'online'.obs;

  RxList<OnlineMemberData> get filtermember {
    return filteredMembers;
  }

  @override
  void onInit() {
    super.onInit();

    getGroupMember();
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
        filter: memberFilter.value,
        limit: 20,
      );

      if (result.status != true) {
        responseError.value =
            result.message ?? 'Something went wrong';
        return;
      }

      final List<OnlineMemberData> apiMembers =
      List<OnlineMemberData>.from(
        result.data ?? <OnlineMemberData>[],
      );

      memberData.assignAll(apiMembers);

      pagination.value =
          result.pagination?.currentPage ?? 1;

      hasMoreMembers.value =
          result.pagination?.hasNextPage ?? false;

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
      final int nextPage = pagination.value + 1;

      final OnlineMemberModel result =
      await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: memberFilter.value,
        limit: 20,
      );

      if (result.status != true) {
        hasMoreMembers.value = false;
        return;
      }

      final List<OnlineMemberData> apiMembers =
      List<OnlineMemberData>.from(
        result.data ?? <OnlineMemberData>[],
      );

      if (apiMembers.isNotEmpty) {
        memberData.addAll(apiMembers);
      }

      pagination.value =
          result.pagination?.currentPage ?? nextPage;

      hasMoreMembers.value =
          result.pagination?.hasNextPage ?? false;

      _applySearch();
    } catch (error) {
      responseError.value = error.toString();
    } finally {
      memberLoadingMore.value = false;
    }
  }

  Future<void> loadMoreRecentCalls() async {
    await loadMoreMembers();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _applySearch();
  }

  void searchMembers(String value) {
    onSearchChanged(value);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';

    filteredMembers.assignAll(
      List<OnlineMemberData>.from(memberData),
    );
  }

  void _applySearch() {
    final String query =
    searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredMembers.assignAll(
        List<OnlineMemberData>.from(memberData),
      );
      return;
    }

    final List<OnlineMemberData> result =
    memberData.where((OnlineMemberData member) {
      final String name =
          member.name?.toLowerCase() ?? '';

      final String mobile =
          member.mobileNo?.toLowerCase() ?? '';

      return name.contains(query) ||
          mobile.contains(query);
    }).toList();

    filteredMembers.assignAll(result);
  }

  Future<void> refreshMembers() async {
    memberLoading.value = false;
    memberLoadingMore.value = false;

    await getGroupMember();
  }

  Future<void> changeFilter(String filter) async {
    if (memberFilter.value == filter) {
      return;
    }

    memberFilter.value = filter;

    await getGroupMember();
  }

  int get onlineMembersCount {
    return memberData
        .where(
          (OnlineMemberData member) => member.isOnline == 1 || member.online,
    )
        .length;
  }

  int get recentlyOnlineCount {
    return memberData
        .where(
          (OnlineMemberData member) => member.isOnline != 1 && !member.online,
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