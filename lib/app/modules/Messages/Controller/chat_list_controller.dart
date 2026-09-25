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
  final Map<String, int> _previousChatPositions = {};
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  RxBool hasNextPage = false.obs;
  RxBool hasPreviousPage = false.obs;

  final socketService = SocketMessageService.instance;

  String get currentUserId =>
      Global.storageServices.get(PrefConst.userId).toString();

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

      final chats = response.data ?? [];

      privateChats.value = _sortPinnedChats(chats);

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

  void _initializePrivateChatListSocket() {
    final userId = currentUserId;

    if (userId.isEmpty || userId == "null") {
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
      userId: userId,
    );
  }

  void pinChat(PrivateChatModel chat) {
    if (chat.id == null) {
      log("PIN CHAT ERROR => chatId is null");
      return;
    }

    final chatId = chat.id!.toString();

    final index = privateChats.indexWhere(
      (item) => item.id == chat.id,
    );

    if (index != -1 && chat.isPinned != true) {
      _previousChatPositions[chatId] = index;
    }

    log(
      "PIN CHAT => userId=$currentUserId, chatId=$chatId",
    );

    socketService.pinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isPinned = true;

    _moveChatToTop(chat);

    privateChats.refresh();

    log("PIN CHAT UI UPDATED => ${chat.name}");
  }

  void unpinChat(PrivateChatModel chat) {
    if (chat.id == null) {
      log("UNPIN CHAT ERROR => chatId is null");
      return;
    }

    final chatId = chat.id!.toString();

    log(
      "UNPIN CHAT => userId=$currentUserId, chatId=$chatId",
    );

    socketService.unpinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    final currentIndex = privateChats.indexWhere(
      (item) => item.id == chat.id,
    );

    final previousIndex = _previousChatPositions[chatId];

    chat.isPinned = false;

    if (currentIndex != -1) {
      final updatedChat = privateChats.removeAt(currentIndex);

      int insertIndex = previousIndex ?? currentIndex;

      if (insertIndex < 0) {
        insertIndex = 0;
      }

      if (insertIndex > privateChats.length) {
        insertIndex = privateChats.length;
      }

      privateChats.insert(insertIndex, updatedChat);
    }

    _previousChatPositions.remove(chatId);

    privateChats.refresh();

    log("UNPIN CHAT UI UPDATED => ${chat.name}");
  }

  void _moveChatToTop(PrivateChatModel chat) {
    final index = privateChats.indexWhere(
      (item) => item.id == chat.id,
    );

    if (index == -1) {
      return;
    }

    final updatedChat = privateChats.removeAt(index);

    privateChats.insert(0, updatedChat);

    privateChats.refresh();
  }

  void _handlePrivateChatUpdated(dynamic data) {
    if (data is! Map) {
      return;
    }

    try {
      final updatedChat = PrivateChatModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (updatedChat.id == null && updatedChat.userId == null) {
        log(
          "PRIVATE CHAT UPDATED: chatId/userId missing",
        );
        return;
      }

      int index = -1;

      if (updatedChat.id != null) {
        index = privateChats.indexWhere(
          (chat) => chat.id == updatedChat.id,
        );
      }

      if (index == -1 && updatedChat.userId != null) {
        index = privateChats.indexWhere(
          (chat) => chat.userId == updatedChat.userId,
        );
      }

      final chatId = updatedChat.id?.toString();

      if (updatedChat.isPinned == true) {
        if (index != -1) {
          privateChats.removeAt(index);
        }

        privateChats.insert(0, updatedChat);
      } else {
        if (index != -1) {
          privateChats[index] = updatedChat;
        } else {
          privateChats.add(updatedChat);
        }
      }

      privateChats.refresh();

      log(
        "PRIVATE CHAT UPDATED: "
        "${updatedChat.name} | "
        "chatId=${updatedChat.id} | "
        "isPinned=${updatedChat.isPinned}",
      );
    } catch (e) {
      log(
        "PRIVATE CHAT UPDATED PARSE ERROR => $e",
      );
    }
  }

  void muteChat(
      PrivateChatModel chat, {
        String? mutedUntil,
      }) {
    if (chat.id == null) {
      log("MUTE CHAT ERROR => chatId is null");
      return;
    }

    final chatId = chat.id!.toString();

    log(
      "MUTE CHAT => userId=$currentUserId, "
          "chatId=$chatId, mutedUntil=$mutedUntil",
    );

    socketService.mutePrivateChat(
      userId: currentUserId,
      chatId: chatId,
      mutedUntil: mutedUntil,
    );

    chat.isMuted = true;
    chat.mutedUntil = mutedUntil;

    privateChats.refresh();

    log(
      "MUTE CHAT UI UPDATED => ${chat.name} | "
          "isMuted=${chat.isMuted} | "
          "mutedUntil=${chat.mutedUntil}",
    );
  }


  void unmuteChat(PrivateChatModel chat) {
    if (chat.id == null) {
      log("UNMUTE CHAT ERROR => chatId is null");
      return;
    }

    final chatId = chat.id!.toString();

    log(
      "UNMUTE CHAT => userId=$currentUserId, chatId=$chatId",
    );

    socketService.unmutePrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isMuted = false;
    chat.mutedUntil = null;

    privateChats.refresh();

    log(
      "UNMUTE CHAT UI UPDATED => ${chat.name} | "
          "isMuted=${chat.isMuted} | "
          "mutedUntil=${chat.mutedUntil}",
    );
  }








  List<PrivateChatModel> _sortPinnedChats(
    List<PrivateChatModel> chats,
  ) {
    final pinned = chats.where((chat) => chat.isPinned == true).toList();

    final unpinned = chats.where((chat) => chat.isPinned != true).toList();

    return [
      ...pinned,
      ...unpinned,
    ];
  }

  @override
  void onClose() {
    socketService.disconnectPrivateChatListSocket();

    super.onClose();
  }
}
