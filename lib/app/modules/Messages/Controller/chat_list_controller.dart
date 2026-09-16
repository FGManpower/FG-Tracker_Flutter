import 'dart:developer';

import 'package:get/get.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';

class ChatListController extends GetxController {
  RxList<PrivateChatModel> privateChats = <PrivateChatModel>[].obs;

  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;

  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  RxBool hasNextPage = false.obs;
  RxBool hasPreviousPage = false.obs;

  final socketService = SocketMessageService.instance;

  @override
  void onInit() {
    super.onInit();

    _initializePrivateChatListSocket();
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

        hasPreviousPage.value =
            response.pagination!.hasPreviousPage ?? false;
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

  void _initializePrivateChatListSocket() {
    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    if (currentUserId.isEmpty || currentUserId == "null") {
      log("PRIVATE CHAT LIST SOCKET: USER ID NOT FOUND");
      return;
    }

    socketService.listenPrivateChatListUpdated(
      callback: (data) {
        log("PRIVATE CHAT LIST UPDATED => $data");
        _handlePrivateChatUpdated(data);
      },
    );

    socketService.initPrivateChatListSocket(
      ConstRes.socketUrl,
      userId: currentUserId,
    );
  }

  void _handlePrivateChatUpdated(dynamic data) {
    if (data is! Map) return;

    try {
      final updatedChat =
      PrivateChatModel.fromJson(Map<String, dynamic>.from(data));

      if (updatedChat.userId == null) {
        log("PRIVATE CHAT UPDATED: userId missing");
        return;
      }

      final index = privateChats.indexWhere(
            (chat) => chat.userId == updatedChat.userId,
      );

      if (index != -1) {
        privateChats.removeAt(index);
      }

      privateChats.insert(0, updatedChat);

      privateChats.refresh();

      log(
        "PRIVATE CHAT LIST UPDATED: "
            "${updatedChat.name} - ${updatedChat.message}",
      );
    } catch (e) {
      log("PRIVATE CHAT UPDATED PARSE ERROR => $e");
    }
  }

  @override
  void onClose() {
    socketService.disconnectPrivateChatListSocket();
    super.onClose();
  }
}