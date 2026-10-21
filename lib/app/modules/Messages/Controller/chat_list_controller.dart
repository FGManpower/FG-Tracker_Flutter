import 'package:flutter/material.dart';
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

  RxInt unreadTotalCount = 0.obs;
  RxString searchQuery = "".obs;
  final searchController = TextEditingController();

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

  bool _isSameChat(PrivateChatModel a, PrivateChatModel b) {
    if (a.id != null && b.id != null && a.id == b.id) return true;
    if (a.chatId != null && b.chatId != null && a.chatId == b.chatId) return true;
    if (a.conversationId != null && b.conversationId != null && a.conversationId == b.conversationId) return true;

    final aIsGroup = a.isGroup == true || a.chatType == "group";
    final bIsGroup = b.isGroup == true || b.chatType == "group";

    if (aIsGroup && bIsGroup) {
      if (a.groupId != null && b.groupId != null) {
        return a.groupId == b.groupId;
      }
    } else if (!aIsGroup && !bIsGroup) {
      if (a.userId != null && b.userId != null) {
        return a.userId == b.userId;
      }
    }

    return false;
  }

  Future<void> getPrivateChats({
    bool refresh = false,
    String? search,
  }) async {
    try {
      if (refresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
      } else {
        isLoading.value = true;
      }

      final requestedPage = currentPage.value;

      // -------------------------------------------------------------------
      // Existing Private Chat API (Commented out):
      // final response = await MessageRepo.getPrivateChatList(
      //   page: requestedPage,
      //   limit: 10,
      // );
      // -------------------------------------------------------------------

      // NEW Unified Chat List API (WhatsApp Behavior):
      final response = await MessageRepo.getChatList(
        page: requestedPage,
        limit: 20,
        search: search ?? (searchQuery.value.trim().isNotEmpty ? searchQuery.value.trim() : null),
        type: "all",
        includeArchived: false,
      );

      if (response.unreadTotalCount != null) {
        unreadTotalCount.value = response.unreadTotalCount!;
      }

      // WhatsApp Rule (Recent Activity Only):
      // Chats with 0 messages are excluded unless pinned. Only conversations with visible messages appear.
      final chats = (response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty);
        return hasMsg || chat.isPinned == true;
      }).toList();

      final existingChats = List<PrivateChatModel>.from(privateChats);
      final mergedChats = <PrivateChatModel>[];

      for (final apiChat in chats) {
        final existingIndex = existingChats.indexWhere(
          (existing) => _isSameChat(existing, apiChat),
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
            (existing) => _isSameChat(existing, apiChat),
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
        currentPage.value = response.pagination!.currentPage ?? requestedPage;

        totalPages.value = response.pagination!.totalPages ?? 0;
        hasNextPage.value = response.pagination!.hasNextPage ?? false;
        hasPreviousPage.value = response.pagination!.hasPreviousPage ?? false;
      }

      privateChats.refresh();
    } catch (e, stackTrace) {
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Unified WhatsApp chat list fetch method
  Future<void> getChatList({
    bool isRefresh = false,
    bool refresh = false,
    String? search,
  }) =>
      getPrivateChats(
        refresh: isRefresh || refresh,
        search: search,
      );

  /// Alias for getChatList to reflect unified chat list
  Future<void> getChats({
    bool isRefresh = false,
    bool refresh = false,
    String? search,
  }) =>
      getChatList(
        isRefresh: isRefresh,
        refresh: refresh,
        search: search,
      );

  void onSearchChanged(String value) {
    searchQuery.value = value;
    getPrivateChats(refresh: true, search: value);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
    getPrivateChats(refresh: true);
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

    socketService.listenFullChatList(
      callback: (data) {
        _handleFullChatListSocket(data);
      },
    );

    socketService.listenPrivateChatRemoved(
      callback: _handlePrivateChatRemoved,
    );

    socketService.listenPrivateChatClearedOnListSocket(
      callback: _handlePrivateChatCleared,
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

  void _handleFullChatListSocket(dynamic data) {
    if (data is! Map) return;
    try {
      final response = PrivateChatResponse.fromJson(Map<String, dynamic>.from(data));
      if (response.unreadTotalCount != null) {
        unreadTotalCount.value = response.unreadTotalCount!;
      }
      final chats = (response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty);
        return hasMsg || chat.isPinned == true;
      }).toList();

      if (chats.isNotEmpty) {
        privateChats.assignAll(_sortPinnedChats(chats));
        privateChats.refresh();
      }
    } catch (_) {}
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

  void _handlePrivateChatCleared(
    Map<String, dynamic> data,
  ) {
    final conversationId = int.tryParse(
      (data['conversationId'] ??
                  data['conversation_id'] ??
                  data['chatId'] ??
                  data['chat_id'] ??
                  data['id'])
              ?.toString() ??
          '',
    );

    if (conversationId == null) {
      return;
    }

    final index = privateChats.indexWhere(
      (chat) => chat.id == conversationId,
    );

    if (index == -1) {
      return;
    }

    final chat = privateChats[index];

    chat.message = '';
    chat.time = '';
    chat.messageType = '';

    privateChats.refresh();
  }

  void pinChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id;
    if (effectiveId == null) {
      return;
    }

    final chatId = effectiveId.toString();

    socketService.pinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isPinned = true;
    chat.pinnedAt = DateTime.now().toUtc().toIso8601String();
    privateChats.assignAll(_sortPinnedChats(privateChats));
    privateChats.refresh();
  }

  void unpinChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id;
    if (effectiveId == null) {
      return;
    }

    final chatId = effectiveId.toString();

    socketService.unpinPrivateChat(
      userId: currentUserId,
      chatId: chatId,
    );

    chat.isPinned = false;
    chat.pinnedAt = null;
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

      if (payload['lastActivity'] == null && payload['lastMessage'] is Map) {
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

      if (updatedChat.id == null &&
          updatedChat.userId == null &&
          updatedChat.groupId == null) {
        return;
      }

      final index =
          privateChats.indexWhere((chat) => _isSameChat(chat, updatedChat));

      if (updatedChat.isArchived == true) {
        privateChats.removeWhere((chat) => _isSameChat(chat, updatedChat));

        final archivedIndex =
            archivedChats.indexWhere((chat) => _isSameChat(chat, updatedChat));

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
        final hasChatDetails = payload['lastActivity'] is Map ||
            payload.containsKey('message') ||
            payload.containsKey('lastMessage') ||
            payload.containsKey('last_message') ||
            updatedChat.unreadCount != null ||
            updatedChat.isPinned == true;

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
    } catch (e, stackTrace) {}
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
      chatId: updated.chatId ?? current.chatId,
      conversationId: updated.conversationId ?? current.conversationId,
      groupId: updated.groupId ?? current.groupId,
      chatType: updated.chatType ?? current.chatType,
      userId: updated.userId ?? current.userId,
      name: updated.name ?? current.name,
      groupName: updated.groupName ?? current.groupName,
      memberCount: updated.memberCount ?? current.memberCount,
      role: updated.role ?? current.role,
      message: keepCurrentMessage
          ? current.message
          : (updated.message != null && updated.message!.isNotEmpty
              ? updated.message
              : current.message),
      preview: updated.preview ?? current.preview,
      isDeletedForEveryone:
          updated.isDeletedForEveryone ?? current.isDeletedForEveryone,
      time: keepCurrentMessage
          ? current.time
          : (updated.time != null && updated.time!.isNotEmpty
              ? updated.time
              : current.time),
      timestamp: updated.timestamp ?? current.timestamp,
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
      isBlocked: updated.isBlocked ?? current.isBlocked,
      blockedByMe: updated.blockedByMe ?? current.blockedByMe,
      isGroup: updated.isGroup ?? current.isGroup,
      isPinned: updated.isPinned ?? current.isPinned,
      pinnedAt: updated.pinnedAt ?? current.pinnedAt,
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
    if (chat.isGroup == true) {
      final gId = chat.groupId ?? chat.id;
      if (gId != null) {
        socketService.markSeen(currentUserId, gId);
      }
    } else {
      final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id;
      if (effectiveId != null) {
        socketService.markPrivateChatRead(
          userId: currentUserId,
          chatId: effectiveId.toString(),
        );
      }
    }

    final cUnread = chat.unreadCount ?? 0;
    if (cUnread > 0) {
      unreadTotalCount.value =
          (unreadTotalCount.value - cUnread).clamp(0, 999999).toInt();
    }
    chat.unreadCount = 0;
    privateChats.refresh();
  }

  void deleteChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id;
    if (effectiveId == null) {
      return;
    }

    if (chat.isGroup != true) {
      socketService.deletePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    privateChats.removeWhere((c) => _isSameChat(c, chat));
    privateChats.refresh();
  }

  void _handlePrivateChatActionError(dynamic data) {}

  void _moveUpdatedChatToTop(PrivateChatModel chat) {
    final index = privateChats.indexWhere(
      (item) => _isSameChat(item, chat),
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

    DateTime getPinnedTimestamp(PrivateChatModel chat) {
      final p = chat.pinnedAt;
      if (p == null || p.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.tryParse(p)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    DateTime getTimestamp(PrivateChatModel chat) {
      final t = chat.timestamp ?? chat.time;
      if (t == null || t.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
      }
      return DateTime.tryParse(t)?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    sortedChats.sort((a, b) {
      final aPinned = a.isPinned == true;
      final bPinned = b.isPinned == true;

      // 1. Pinned conversations first (pinnedAt DESC)
      if (aPinned != bPinned) {
        return aPinned ? -1 : 1;
      }
      if (aPinned && bPinned) {
        final aPinnedTime = getPinnedTimestamp(a);
        final bPinnedTime = getPinnedTimestamp(b);
        final cmp = bPinnedTime.compareTo(aPinnedTime);
        if (cmp != 0) return cmp;
      }

      // 2. Latest message/activity timestamp DESC
      final cmpTime = getTimestamp(b).compareTo(getTimestamp(a));
      if (cmpTime != 0) return cmpTime;

      // 3. Conversation ID DESC
      final aId = a.conversationId ?? a.chatId ?? a.id ?? 0;
      final bId = b.conversationId ?? b.chatId ?? b.id ?? 0;
      return bId.compareTo(aId);
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

        archivedHasPreviousPage.value = pagination["hasPreviousPage"] == true;
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
