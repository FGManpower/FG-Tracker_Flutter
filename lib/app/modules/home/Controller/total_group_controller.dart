import 'package:fgtracker/app/Model/GroupChatListModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

class TotalGroupController extends GetxController {
  final RxList<GroupChatData> groupList = <GroupChatData>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString searchText = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPages = 1;
  int perPage = 20;

  bool get hasNextPage => currentPage <= totalPages && currentPage > 1;

  List<GroupChatData> get filteredGroupList {
    final query = searchText.value.trim().toLowerCase();

    if (query.isEmpty) {
      return groupList;
    }

    return groupList.where((group) {
      final name = group.groupName?.toLowerCase() ?? '';
      final message = group.lastMessage?.content?.toLowerCase() ?? '';

      return name.contains(query) || message.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    scrollController.addListener(_scrollListener);

    getGroupChatList();
  }

  Future<void> getGroupChatList({
    bool refresh = false,
  }) async {
    if (refresh) {
      currentPage = 1;
      totalPages = 1;
      groupList.clear();
      hasError.value = false;
      errorMessage.value = '';
    }

    if (isLoading.value || isLoadingMore.value) {
      return;
    }

    if (!refresh && currentPage > 1 && !hasNextPage) {
      return;
    }

    if (currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await MessageRepo.getGroupChatList(
        page: currentPage,
        limit: perPage,
      );

      if (response.status == true) {
        final newData = response.data ?? [];

        if (currentPage == 1) {
          groupList.assignAll(newData);
        } else {
          groupList.addAll(newData);
        }

        final pagination = response.pagination;

        totalPages = pagination?.totalPages ?? 1;
        perPage = pagination?.perPage ?? perPage;

        if (currentPage < totalPages) {
          currentPage++;
        }
      } else {
        if (currentPage == 1) {
          groupList.clear();
        }

        hasError.value = true;
        errorMessage.value =
            response.message ?? 'Unable to fetch groups';
      }
    } catch (e) {
      if (currentPage == 1) {
        groupList.clear();
      }

      hasError.value = true;
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void _scrollListener() {
    if (!scrollController.hasClients) {
      return;
    }

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasNextPage) {
        getGroupChatList();
      }
    }
  }

  Future<void> refreshGroups() async {
    await getGroupChatList(refresh: true);
  }

  void clearSearch() {
    searchController.clear();
  }

  String getGroupName(GroupChatData group) {
    final name = group.groupName?.trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'No Name Group';
  }

  String getGroupDescription(GroupChatData group) {
    final lastMessage = group.lastMessage;

    if (lastMessage == null) {
      return '';
    }

    if (lastMessage.isDeletedForEveryone == 1) {
      return 'Message deleted';
    }

    final messageType = lastMessage.messageType?.toLowerCase();

    if (messageType == 'audio') {
      return 'Audio';
    }

    if (messageType == 'image') {
      return 'Image';
    }

    if (messageType == 'video') {
      return 'Video';
    }

    if (messageType == 'document') {
      return 'Document';
    }

    final content = lastMessage.content?.trim();

    if (content != null && content.isNotEmpty) {
      return content;
    }

    final caption = lastMessage.caption?.trim();

    if (caption != null && caption.isNotEmpty) {
      return caption;
    }

    return '';
  }

  int getMemberCount(GroupChatData group) {
    return 0;
  }

  int getUnreadCount(GroupChatData group) {
    return group.unreadCount ?? 0;
  }

  String getGroupDate(GroupChatData group) {
    final timestamp = group.lastMessage?.timestamp;

    if (timestamp == null || timestamp.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final date = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );

      final difference = today.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      }

      if (difference == 1) {
        return 'Yesterday';
      }

      if (difference > 1 && difference < 7) {
        const weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];

        return weekdays[dateTime.weekday - 1];
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${dateTime.day} ${months[dateTime.month - 1]}';
    } catch (e) {
      return '';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}