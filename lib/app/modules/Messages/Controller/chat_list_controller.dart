import 'dart:developer';

import 'package:get/get.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

class ChatListController extends GetxController {
  RxList<PrivateChatModel> privateChats = <PrivateChatModel>[].obs;

  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;

  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  RxBool hasNextPage = false.obs;
  RxBool hasPreviousPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    getPrivateChats();
  }

  Future<void> getPrivateChats({
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
      } else {
        isLoading.value = true;
      }

      final response = await MessageRepo.getPrivateChatList(
        page: currentPage.value,
        limit: 10,
      );

      privateChats.value = response.data ?? [];

      if (response.pagination != null) {
        currentPage.value =
            response.pagination!.currentPage ?? currentPage.value;

        totalPages.value = response.pagination!.totalPages ?? 0;

        hasNextPage.value = response.pagination!.hasNextPage ?? false;

        hasPreviousPage.value = response.pagination!.hasPreviousPage ?? false;
      }

      log("Private Chats: ${privateChats.length}");
      log("Current Page: ${currentPage.value}");
      log("Total Pages: ${totalPages.value}");
      log("Has Next Page: ${hasNextPage.value}");
      log("Message: ${response.message}");
    } catch (e) {
      log("Private Chat Error: $e");
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshChats() async {
    await getPrivateChats(refresh: true);
  }

  Future<void> nextPage() async {
    if (!hasNextPage.value || isLoading.value) {
      return;
    }

    currentPage.value++;
    await getPrivateChats();
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage.value || isLoading.value) {
      return;
    }

    currentPage.value--;
    await getPrivateChats();
  }
}
