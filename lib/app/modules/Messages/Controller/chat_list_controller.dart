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
  RxList<PrivateChatModel> archivedChats = <PrivateChatModel>[].obs;

  RxInt archivedCurrentPage = 1.obs;
  RxInt archivedTotalPages = 0.obs;
  RxBool archivedHasNextPage = false.obs;
  RxBool archivedHasPreviousPage = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  RxBool hasNextPage = false.obs;
  RxBool hasPreviousPage = false.obs;

  final socketService = SocketMessageService.instance;

  String get currentUserId {
    final value = Global.storageServices.get(PrefConst.userId);
    return value.toString();
  }

  @override
  void onInit() {
    super.onInit();

    _initializePrivateChatListSocket();
    getPrivateChats();
    loadArchivedChats();
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

      final requestedPage = currentPage.value;

      final response = await MessageRepo.getPrivateChatList(
        page: requestedPage,
        limit: 10,
      );

      final chats = (response.data ?? [])
          .where((chat) => chat.isArchived != true)
          .toList();

      final existingChats = List<PrivateChatModel>.from(privateChats);
      final mergedChats = <PrivateChatModel>[];

      for (final apiChat in chats) {
        final existingIndex = existingChats.indexWhere(
              (existing) =>
          (apiChat.id != null && existing.id == apiChat.id) ||
              (apiChat.userId != null && existing.userId == apiChat.userId),
        );

        if (existingIndex == -1) {
          mergedChats.add(apiChat);
        } else {
          mergedChats.add(
            _mergePrivateChat(
              existingChats[existingIndex],
              apiChat,
            ),
          );
        }
      }

      if (requestedPage == 1) {
        privateChats.assignAll(_sortPinnedChats(mergedChats));
      } else {
        for (final apiChat in mergedChats) {
          final existingIndex = privateChats.indexWhere(
                (existing) =>
            (apiChat.id != null && existing.id == apiChat.id) ||
                (apiChat.userId != null && existing.userId == apiChat.userId),
          );

          if (existingIndex == -1) {
            privateChats.add(apiChat);
          } else {
            privateChats[existingIndex] = _mergePrivateChat(
              privateChats[existingIndex],
              apiChat,
            );
          }
        }

        privateChats.assignAll(_sortPinnedChats(privateChats));
      }

      if (response.pagination != null) {
        currentPage.value =
            response.pagination!.currentPage ?? requestedPage;

        totalPages.value = response.pagination!.totalPages ?? 0;
        hasNextPage.value = response.pagination!.hasNextPage ?? false;
        hasPreviousPage.value =
            response.pagination!.hasPreviousPage ?? false;
      }

      privateChats.refresh();
    } catch (e, stackTrace) {
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
      return;
    }

    socketService.listenPrivateChatListUpdated(
      callback: (data) {
        _handlePrivateChatUpdated(data);
      },
    );

    socketService.listenPrivateChatRemoved(
      callback: _handlePrivateChatRemoved,
    );

    socketService.listenPrivateChatActionError(
      callback: _handlePrivateChatActionError,
    );

    socketService.listenArchivedPrivateChats(
      callback: (data) {
        _handleArchivedPrivateChats(data);
      },
    );

    socketService.initPrivateChatListSocket(
      ConstRes.socketUrl,
      userId: userId,
    );
  }

  void _handlePrivateChatRemoved(dynamic data) {
    if (data is! Map) {
      return;
    }

    final chatId = int.tryParse(
      (data["chatId"] ??
          data["chat_id"] ??
          data["conversationId"] ??
          data["conversation_id"] ??
          data["id"])
          .toString(),
    );

    if (chatId == null) {
      return;
    }

    privateChats.removeWhere(
          (chat) => chat.id == chatId,
    );

    privateChats.refresh();
  }

  void pinChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.pinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isPinned = true;
    privateChats.assignAll(_sortPinnedChats(privateChats));
    privateChats.refresh();
  }

  void unpinChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.unpinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isPinned = false;
    privateChats.assignAll(_sortPinnedChats(privateChats));
    privateChats.refresh();
  }

  void _handlePrivateChatUpdated(dynamic data) {
    if (data is! Map) {
      return;
    }

    try {
      final rawPayload = Map<String, dynamic>.from(data);
      final nestedData = rawPayload['data'];
      final payload = nestedData is Map
          ? Map<String, dynamic>.from(nestedData)
          : rawPayload;

      if (payload['lastActivity'] == null &&
          payload['lastMessage'] is Map) {
        payload['lastActivity'] = Map<String, dynamic>.from(
          payload['lastMessage'] as Map,
        );
      } else if (payload['lastActivity'] == null &&
          payload['last_message'] is Map) {
        payload['lastActivity'] = Map<String, dynamic>.from(
          payload['last_message'] as Map,
        );
      }

      final updatedChat = PrivateChatModel.fromJson(payload);

      if (updatedChat.id == null && updatedChat.userId == null) {
        return;
      }

      bool isSameChat(PrivateChatModel chat) {
        if (updatedChat.id != null && chat.id != null) {
          if (updatedChat.id == chat.id) {
            return true;
          }
        }

        if (updatedChat.userId != null && chat.userId != null) {
          return updatedChat.userId == chat.userId;
        }

        return false;
      }

      final index = privateChats.indexWhere(isSameChat);

      if (updatedChat.isArchived == true) {
        privateChats.removeWhere(isSameChat);

        final archivedIndex = archivedChats.indexWhere(isSameChat);

        if (archivedIndex >= 0) {
          archivedChats[archivedIndex] = _mergePrivateChat(
            archivedChats[archivedIndex],
            updatedChat,
          );
        } else {
          archivedChats.insert(0, updatedChat);
        }

        privateChats.refresh();
        archivedChats.refresh();

        return;
      }

      if (index == -1) {
        final hasChatDetails =
            payload['lastActivity'] is Map ||
                payload.containsKey('message') ||
                payload.containsKey('lastMessage') ||
                payload.containsKey('last_message') ||
                updatedChat.unreadCount != null;

        if (!hasChatDetails) {
          return;
        }

        privateChats.add(updatedChat);
        privateChats.assignAll(_sortPinnedChats(privateChats));

        if (updatedChat.moveToTop == true) {
          _moveUpdatedChatToTop(updatedChat);
        }

        privateChats.refresh();

        return;
      }

      final currentChat = privateChats[index];
      final mergedChat = _mergePrivateChat(currentChat, updatedChat);

      privateChats[index] = mergedChat;
      privateChats.assignAll(_sortPinnedChats(privateChats));

      if (updatedChat.moveToTop == true) {
        _moveUpdatedChatToTop(mergedChat);
      }

      privateChats.refresh();
    } catch (e, stackTrace) {
    }
  }

  PrivateChatModel _mergePrivateChat(
      PrivateChatModel current,
      PrivateChatModel updated,
      ) {
    final currentTime = DateTime.tryParse(current.time ?? '')?.toUtc();
    final updatedTime = DateTime.tryParse(updated.time ?? '')?.toUtc();

    final keepCurrentMessage = current.message != null &&
        current.message!.isNotEmpty &&
        (currentTime != null &&
            (updatedTime == null || currentTime.isAfter(updatedTime)));

    final isOnline = updated.isOnline ?? current.isOnline;
    final lastSeen = updated.lastSeen ?? current.lastSeen;

    return PrivateChatModel(
      id: updated.id ?? current.id,
      userId: updated.userId ?? current.userId,
      name: updated.name ?? current.name,
      role: updated.role ?? current.role,
      message: keepCurrentMessage
          ? current.message
          : (updated.message != null && updated.message!.isNotEmpty
          ? updated.message
          : current.message),
      time: keepCurrentMessage
          ? current.time
          : (updated.time != null && updated.time!.isNotEmpty
          ? updated.time
          : current.time),
      messageType: keepCurrentMessage
          ? current.messageType
          : (updated.messageType ?? current.messageType),
      mutedUntil: updated.mutedUntil ?? current.mutedUntil,
      unreadCount: updated.unreadCount ?? current.unreadCount,
      status: isOnline != null
          ? (isOnline ? "Online" : "Offline")
          : updated.status ?? current.status,
      isOnline: isOnline,
      lastSeen: lastSeen,
      isGroup: updated.isGroup ?? current.isGroup,
      isPinned: updated.isPinned ?? current.isPinned,
      isMuted: updated.isMuted ?? current.isMuted,
      isArchived: updated.isArchived ?? current.isArchived,
      moveToTop: updated.moveToTop ?? current.moveToTop,
      image: updated.image ?? current.image,
    );
  }

  void muteChat(
      PrivateChatModel chat, {
        String? mutedUntil,
      }) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.mutePrivateChat(
      userId: currentUserId,
      chatId: chatId,
      mutedUntil: mutedUntil,
    );

    chat.isMuted = true;
    chat.mutedUntil = mutedUntil;

    privateChats.refresh();
  }

  void unmuteChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.unmutePrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isMuted = false;
    chat.mutedUntil = null;

    privateChats.refresh();
  }

  void archiveChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.archivePrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    privateChats.removeWhere(
          (item) => item.id == chat.id,
    );

    privateChats.refresh();
  }

  void unarchiveChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    final chatId = chat.id!.toString();

    socketService.unarchivePrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isArchived = false;
    chat.isPinned = false;

    archivedChats.removeWhere(
          (item) => item.id == chat.id,
    );

    final existingIndex = privateChats.indexWhere(
          (item) => item.id == chat.id,
    );

    if (existingIndex == -1) {
      privateChats.add(chat);
    } else {
      privateChats[existingIndex] = _mergePrivateChat(
        privateChats[existingIndex],
        chat,
      );
    }

    privateChats.assignAll(_sortPinnedChats(privateChats));

    archivedChats.refresh();
    privateChats.refresh();
  }

  void markChatAsRead(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    socketService.markPrivateChatRead(
      userId: currentUserId,
      chatId: chat.id.toString(),
    );

    chat.unreadCount = 0;
    privateChats.refresh();
  }

  void deleteChat(PrivateChatModel chat) {
    if (chat.id == null) {
      return;
    }

    socketService.deletePrivateChat(
      userId: currentUserId,
      chatId: chat.id.toString(),
    );
  }

  void _handlePrivateChatActionError(dynamic data) {}

  void _moveUpdatedChatToTop(PrivateChatModel chat) {
    final index = privateChats.indexWhere(
          (item) =>
      (chat.id != null && item.id == chat.id) ||
          (chat.userId != null && item.userId == chat.userId),
    );

    if (index <= 0) {
      return;
    }

    final updatedChat = privateChats.removeAt(index);
    privateChats.insert(0, updatedChat);
  }

  List<PrivateChatModel> _sortPinnedChats(
      List<PrivateChatModel> chats,
      ) {
    final sortedChats = List<PrivateChatModel>.from(chats);

    DateTime getTimestamp(PrivateChatModel chat) {
      return DateTime.tryParse(chat.time ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    sortedChats.sort((a, b) {
      final aPinned = a.isPinned == true;
      final bPinned = b.isPinned == true;

      if (aPinned != bPinned) {
        return aPinned ? -1 : 1;
      }

      return getTimestamp(b).compareTo(getTimestamp(a));
    });

    return sortedChats;
  }

  void loadArchivedChats({
    int page = 1,
    int limit = 20,
  }) {
    socketService.getArchivedPrivateChats(
      page: page,
      limit: limit,
    );
  }

  void _handleArchivedPrivateChats(dynamic data) {
    try {
      if (data is! Map) {
        archivedChats.clear();
        return;
      }

      final rawData = data["data"];

      if (rawData is! List) {
        archivedChats.clear();
        return;
      }

      final chats = rawData
          .whereType<Map>()
          .map(
            (item) => PrivateChatModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .where((chat) => chat.id != null)
          .toList();

      archivedChats.value = chats;

      final pagination = data["pagination"];

      if (pagination is Map) {
        archivedCurrentPage.value = int.tryParse(
          pagination["currentPage"]?.toString() ?? "",
        ) ??
            1;

        archivedTotalPages.value = int.tryParse(
          pagination["totalPages"]?.toString() ?? "",
        ) ??
            0;

        archivedHasNextPage.value = pagination["hasNextPage"] == true;

        archivedHasPreviousPage.value =
            pagination["hasPreviousPage"] == true;
      }

      archivedChats.refresh();
    } catch (e) {
      archivedChats.clear();
    }
  }

  @override
  void onClose() {
    socketService.disconnectPrivateChatListSocket();

    super.onClose();
  }
}