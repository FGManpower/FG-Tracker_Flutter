import 'package:fgtracker/app/Data/Repositories/TrackRepo.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LivesStatusController extends GetxController {
  static LivesStatusController get instance =>
      Get.put(LivesStatusController());

  final TextEditingController searchController =
  TextEditingController();

  final RxList<UserMemberData> memberData =
      <UserMemberData>[].obs;

  final RxList<UserMemberData> filteredMembers =
      <UserMemberData>[].obs;

  final RxString searchQuery = ''.obs;

  final RxBool memberLoading = false.obs;
  final RxBool memberLoadingMore = false.obs;

  final RxString responseError = ''.obs;

  final RxInt pagination = 0.obs;

  final RxBool hasMoreMembers = true.obs;

  final RxString memberFilter = 'online'.obs;

  RxList<UserMemberData> get filtermember {
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
      final MemberLiveStatus result =
      await TrackRepo.getGroupMember(
        page: '0',
        filter: memberFilter.value,
      );

      if (result.status != true) {
        responseError.value =
            result.message ?? 'Something went wrong';
        return;
      }

      final List<UserMemberData> apiMembers =
      List<UserMemberData>.from(
        result.data ?? <UserMemberData>[],
      );

      final List<UserMemberData> onlineMembers =
      memberFilter.value.toLowerCase() == 'online'
          ? apiMembers
          .where((UserMemberData member) {
        return member.isOnline == 1;
      })
          .toList()
          : apiMembers;

      memberData.assignAll(onlineMembers);

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

      final MemberLiveStatus result =
      await TrackRepo.getGroupMember(
        page: nextPage.toString(),
        filter: memberFilter.value,
      );

      if (result.status != true) {
        hasMoreMembers.value = false;
        return;
      }

      final List<UserMemberData> apiMembers =
      List<UserMemberData>.from(
        result.data ?? <UserMemberData>[],
      );

      final List<UserMemberData> newMembers =
      memberFilter.value.toLowerCase() == 'online'
          ? apiMembers
          .where((UserMemberData member) {
        return member.isOnline == 1;
      })
          .toList()
          : apiMembers;

      if (newMembers.isNotEmpty) {
        memberData.addAll(newMembers);
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
      List<UserMemberData>.from(memberData),
    );
  }

  void _applySearch() {
    final String query =
    searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredMembers.assignAll(
        List<UserMemberData>.from(memberData),
      );
      return;
    }

    final List<UserMemberData> result =
    memberData.where((UserMemberData member) {
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
          (UserMemberData member) => member.isOnline == 1,
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