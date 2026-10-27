import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListController extends GetxController {
  RxList<PrivateChatModel> privateChats = <PrivateChatModel>[].obs;

  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxList<PrivateChatModel> archivedChats = <PrivateChatModel>[].obs;

  RxInt unreadTotalCount = 0.obs;
  RxSet<String> manuallyUnreadChatKeys = <String>{}.obs;
  static const String _prefUnreadKeyPrefix = 'manual_unread_chat_keys_';
  String get _prefUnreadKey => '$_prefUnreadKeyPrefix$currentUserId';
  RxString searchQuery = "".obs;
  final searchController = TextEditingController();
  RxBool isSearching = false.obs;

  RxInt archivedCurrentPage = 1.obs;
  RxInt archivedTotalPages = 0.obs;
  RxBool archivedHasNextPage = false.obs;
  RxBool archivedHasPreviousPage = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  RxBool hasNextPage = false.obs;
  RxBool hasPreviousPage = false.obs;

  /// Filtered list of chats for the UI.
  /// 1. Excludes empty conversations (conversations with 0 messages / no preview or invalid name).
  /// 2. Performs instant client-side search across name, groupName, message, preview, and role.
  List<PrivateChatModel> get displayedChats {
    final query = searchQuery.value.trim().toLowerCase();

    final validChats = privateChats.where((chat) {
      if (chat.isArchived == true) return false;
      if (archivedChats.any((archived) => _isSameChat(archived, chat))) {
        return false;
      }
      final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
          (chat.preview != null && chat.preview!.trim().isNotEmpty) ||
          (chat.messageType != null &&
              chat.messageType!.trim().isNotEmpty &&
              chat.messageType != 'text');
      if (!hasMsg) return false;

      final name = (chat.name ?? chat.groupName)?.trim();
      if (name == null || name.isEmpty || name == "Unknown User") {
        return false;
      }
      return true;
    }).toList();

    if (query.isEmpty) {
      return validChats;
    }

    return validChats.where((chat) {
      final name = (chat.name ?? "").toLowerCase();
      final groupName = (chat.groupName ?? "").toLowerCase();
      final message = (chat.message ?? "").toLowerCase();
      final preview = (chat.preview ?? "").toLowerCase();
      final role = (chat.role ?? "").toLowerCase();

      return name.contains(query) ||
          groupName.contains(query) ||
          message.contains(query) ||
          preview.contains(query) ||
          role.contains(query);
    }).toList();
  }

  List<PrivateChatModel> get displayedArchivedChats {
    return archivedChats.where((chat) => chat.isArchived != false).toList();
  }


  /// Total count of all chats currently displayed (both private and group chats).
  int get allChatsCount => displayedChats.length;

  /// Total unread messages count across all chats (both private and group chats).
  int get totalUnreadCount {
    return displayedChats.fold<int>(
      0,
      (sum, chat) => sum + (chat.unreadCount ?? 0),
    );
  }

  final socketService = SocketMessageService.instance;

  String get currentUserId {
    final value = Global.storageServices.get(PrefConst.userId);
    return value.toString();
  }

  @override
  void onInit() {
    super.onInit();

    _loadManuallyUnreadKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketService.instance.markChatListViewed();
    });
    _initializePrivateChatListSocket();
    getPrivateChats();
    loadArchivedChats();
  }

  Future<void> _loadManuallyUnreadKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefUnreadKey) ?? [];
      manuallyUnreadChatKeys.assignAll(saved);
    } catch (_) {}
  }

  Future<void> _saveManuallyUnreadKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefUnreadKey, manuallyUnreadChatKeys.toList());
    } catch (_) {}
  }

  List<String> _getAllChatKeys(PrivateChatModel chat) {
    final isGroup =
        chat.isGroup == true || chat.chatType == "group" || chat.groupId != null;
    final keys = <String>[];
    if (isGroup) {
      if (chat.groupId != null) keys.add('group_${chat.groupId}');
      if (chat.id != null) keys.add('group_${chat.id}');
      if (chat.chatId != null) keys.add('group_${chat.chatId}');
      if (chat.conversationId != null) keys.add('group_${chat.conversationId}');
    } else {
      if (chat.userId != null) keys.add('private_${chat.userId}');
      if (chat.chatId != null) keys.add('private_${chat.chatId}');
      if (chat.conversationId != null) keys.add('private_${chat.conversationId}');
      if (chat.id != null) keys.add('private_${chat.id}');
    }
    return keys;
  }

  bool isChatMarkedUnread(PrivateChatModel chat) {
    final keys = _getAllChatKeys(chat);
    return keys.any((k) => manuallyUnreadChatKeys.contains(k));
  }

  Future<void> markChatAsUnread(PrivateChatModel chat) async {
    final keys = _getAllChatKeys(chat);
    if (keys.isEmpty) return;
    manuallyUnreadChatKeys.addAll(keys);
    manuallyUnreadChatKeys.refresh();
    privateChats.refresh();
    await _saveManuallyUnreadKeys();
  }

  Future<void> clearManualUnreadForGroup(dynamic groupId) async {
    if (groupId == null) return;
    final target = 'group_$groupId';
    if (manuallyUnreadChatKeys.contains(target)) {
      manuallyUnreadChatKeys.remove(target);
      manuallyUnreadChatKeys.refresh();
      privateChats.refresh();
      await _saveManuallyUnreadKeys();
    }
  }

  Future<void> clearManualUnreadForPrivate({dynamic userId, dynamic chatId}) async {
    bool changed = false;
    if (userId != null) {
      if (manuallyUnreadChatKeys.remove('private_$userId')) changed = true;
    }
    if (chatId != null) {
      if (manuallyUnreadChatKeys.remove('private_$chatId')) changed = true;
    }
    if (changed) {
      manuallyUnreadChatKeys.refresh();
      privateChats.refresh();
      await _saveManuallyUnreadKeys();
    }
  }

  void openSearch() {
    isSearching.value = true;
  }

  void closeSearch() {
    isSearching.value = false;
    clearSearch();
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (raw is DateTime) return raw.toUtc();

    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'undefined') {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    final numVal = int.tryParse(str);
    if (numVal != null) {
      if (numVal > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(numVal, isUtc: true);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(numVal * 1000, isUtc: true);
      }
    }

    final parsed = DateTime.tryParse(str);
    if (parsed != null) {
      return parsed.toUtc();
    }

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static bool _isPlaceholderImage(String? url) {
    if (url == null) return true;
    final lower = url.toLowerCase().trim();
    return lower.isEmpty ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower.endsWith('/null') ||
        lower.contains('default-profile') ||
        lower.contains('default_profile') ||
        lower.contains('default-avatar') ||
        lower.contains('default_avatar') ||
        lower.contains('default-group') ||
        lower.contains('default_group') ||
        lower.contains('default.png') ||
        lower.contains('default-image') ||
        lower.contains('default_image');
  }

  static String _getChatKey(PrivateChatModel chat) {
    final isGroup = chat.isGroup == true || chat.chatType == "group" || chat.groupId != null;
    if (isGroup) {
      final gid = chat.groupId ?? chat.id ?? chat.chatId ?? chat.conversationId ?? 0;
      return 'group_$gid';
    } else {
      final uid = chat.userId ?? chat.chatId ?? chat.conversationId ?? chat.id ?? 0;
      return 'private_$uid';
    }
  }

  bool _isSameChat(PrivateChatModel a, PrivateChatModel b) {
    final aIsGroup = a.isGroup == true || a.chatType == "group" || a.groupId != null;
    final bIsGroup = b.isGroup == true || b.chatType == "group" || b.groupId != null;

    // A group chat and a private 1-to-1 chat can NEVER be the same chat
    if (aIsGroup != bIsGroup) return false;

    if (aIsGroup) {
      if (a.groupId != null && b.groupId != null) return a.groupId == b.groupId;
      if (a.id != null && b.id != null) return a.id == b.id;
      if (a.chatId != null && b.chatId != null) return a.chatId == b.chatId;
      if (a.conversationId != null && b.conversationId != null) return a.conversationId == b.conversationId;
      final aAny = a.groupId ?? a.id ?? a.chatId ?? a.conversationId;
      final bAny = b.groupId ?? b.id ?? b.chatId ?? b.conversationId;
      if (aAny != null && bAny != null && aAny == bAny) return true;
      return false;
    } else {
      if (a.userId != null && b.userId != null) return a.userId == b.userId;
      if (a.chatId != null && b.chatId != null) return a.chatId == b.chatId;
      if (a.conversationId != null && b.conversationId != null) return a.conversationId == b.conversationId;
      if (a.id != null && b.id != null) return a.id == b.id;
      final aConv = a.conversationId ?? a.chatId ?? a.id;
      final bConv = b.conversationId ?? b.chatId ?? b.id;
      if (aConv != null && bConv != null && aConv == bConv) return true;
      return false;
    }
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

      // WhatsApp Rule (Recent Activity Only):
      // Strictly exclude empty chats (chats with 0 messages / no preview, or invalid name).
      final chats = (response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty) ||
            (chat.messageType != null &&
                chat.messageType!.trim().isNotEmpty &&
                chat.messageType != 'text');
        final name = (chat.name ?? chat.groupName)?.trim();
        final hasValidName = name != null && name.isNotEmpty && name != "Unknown User";
        return hasMsg && hasValidName;
      }).toList();

      final chatsUnreadSum = chats.fold<int>(
        0,
        (sum, chat) => sum + (chat.unreadCount ?? 0),
      );
      if (response.unreadTotalCount != null &&
          response.unreadTotalCount! > chatsUnreadSum) {
        unreadTotalCount.value = response.unreadTotalCount!;
      } else {
        unreadTotalCount.value = chatsUnreadSum;
      }

      final activeSearch = search ??
          (searchQuery.value.trim().isNotEmpty
              ? searchQuery.value.trim()
              : null);

      if (activeSearch != null && activeSearch.isNotEmpty) {
        // When searching, merge any found chats from server into privateChats
        // without discarding the existing master chat list.
        for (final apiChat in chats) {
          final existingIndex = privateChats.indexWhere(
            (existing) => _isSameChat(existing, apiChat),
          );
          if (existingIndex == -1) {
            privateChats.add(apiChat);
          } else {
            privateChats[existingIndex] = _mergePrivateChat(
              privateChats[existingIndex],
              apiChat,
              fromServer: true,
            );
          }
        }
        privateChats.assignAll(_sortPinnedChats(privateChats));
        return;
      }

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
              fromServer: true,
            ),
          );
        }
      }

      if (requestedPage == 1) {
        final uniqueMap = <String, PrivateChatModel>{};
        for (final chat in mergedChats) {
          final key = _getChatKey(chat);
          if (!uniqueMap.containsKey(key)) {
            uniqueMap[key] = chat;
          } else {
            uniqueMap[key] = _mergePrivateChat(uniqueMap[key]!, chat);
          }
        }
        privateChats.assignAll(_sortPinnedChats(uniqueMap.values.toList()));
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
              fromServer: true,
            );
          }
        }

        final uniqueMap = <String, PrivateChatModel>{};
        for (final chat in privateChats) {
          final key = _getChatKey(chat);
          if (!uniqueMap.containsKey(key)) {
            uniqueMap[key] = chat;
          } else {
            uniqueMap[key] = _mergePrivateChat(uniqueMap[key]!, chat);
          }
        }

        privateChats.assignAll(_sortPinnedChats(uniqueMap.values.toList()));
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

  Timer? _searchDebounce;

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      final q = value.trim();
      getPrivateChats(refresh: false, search: q.isNotEmpty ? q : null);
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    searchQuery.value = "";
    getPrivateChats(refresh: false);
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
      final response =
          PrivateChatResponse.fromJson(Map<String, dynamic>.from(data));
      final chats = (response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty) ||
            (chat.messageType != null &&
                chat.messageType!.trim().isNotEmpty &&
                chat.messageType != 'text');
        final name = (chat.name ?? chat.groupName)?.trim();
        final hasValidName = name != null && name.isNotEmpty && name != "Unknown User";
        return hasMsg && hasValidName;
      }).toList();

      final chatsUnreadSum = chats.fold<int>(
        0,
        (sum, chat) => sum + (chat.unreadCount ?? 0),
      );
      if (response.unreadTotalCount != null &&
          response.unreadTotalCount! > chatsUnreadSum) {
        unreadTotalCount.value = response.unreadTotalCount!;
      } else {
        unreadTotalCount.value = chatsUnreadSum;
      }

      if (chats.isNotEmpty) {
        final uniqueMap = <String, PrivateChatModel>{};
        for (final chat in chats) {
          final key = _getChatKey(chat);
          if (!uniqueMap.containsKey(key)) {
            uniqueMap[key] = chat;
          } else {
            uniqueMap[key] = _mergePrivateChat(uniqueMap[key]!, chat);
          }
        }
        privateChats.assignAll(_sortPinnedChats(uniqueMap.values.toList()));
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
      (chat) =>
          chat.id == conversationId ||
          chat.chatId == conversationId ||
          chat.conversationId == conversationId,
    );

    if (index == -1) {
      return;
    }

    privateChats.removeAt(index);
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
          archivedChats[archivedIndex].isArchived = true;
        } else {
          updatedChat.isArchived = true;
          archivedChats.insert(0, updatedChat);
        }

        privateChats.refresh();
        archivedChats.refresh();

        return;
      } else {
        archivedChats.removeWhere((chat) => _isSameChat(chat, updatedChat));
        archivedChats.refresh();
      }

      final hasMsg = (updatedChat.message != null && updatedChat.message!.trim().isNotEmpty) ||
          (updatedChat.preview != null && updatedChat.preview!.trim().isNotEmpty) ||
          (updatedChat.messageType != null &&
              updatedChat.messageType!.trim().isNotEmpty &&
              updatedChat.messageType != 'text');

      final name = (updatedChat.name ?? updatedChat.groupName)?.trim();
      final hasValidName = name != null && name.isNotEmpty && name != "Unknown User";

      if (index == -1) {
        if (!hasMsg || !hasValidName) {
          return;
        }

        final hasChatDetails = payload['lastActivity'] is Map ||
            payload.containsKey('message') ||
            payload.containsKey('lastMessage') ||
            payload.containsKey('last_message') ||
            updatedChat.unreadCount != null ||
            updatedChat.isPinned == true;

        if (!hasChatDetails) {
          return;
        }

        if ((updatedChat.time == null || updatedChat.time!.isEmpty) &&
            (updatedChat.timestamp == null || updatedChat.timestamp!.isEmpty)) {
          updatedChat.time = DateTime.now().toUtc().toIso8601String();
          updatedChat.timestamp = updatedChat.time;
        }

        privateChats.add(updatedChat);
        privateChats.assignAll(_sortPinnedChats(privateChats));
        privateChats.refresh();

        return;
      }

      if (!hasMsg || !hasValidName) {
        privateChats.removeAt(index);
        privateChats.refresh();
        return;
      }

      final currentChat = privateChats[index];
      final mergedChat = _mergePrivateChat(
        currentChat,
        updatedChat,
        fromServer: false,
      );

      privateChats[index] = mergedChat;
      privateChats.assignAll(_sortPinnedChats(privateChats));
      privateChats.refresh();
    } catch (e, stackTrace) {}
  }

  PrivateChatModel _mergePrivateChat(
    PrivateChatModel current,
    PrivateChatModel updated, {
    bool fromServer = false,
  }) {
    if (fromServer) {
      final isOnline = updated.isOnline ?? current.isOnline;
      final lastSeen = updated.lastSeen ?? current.lastSeen;

      return PrivateChatModel(
        id: updated.id ?? current.id,
        chatId: updated.chatId ?? current.chatId,
        conversationId: updated.conversationId ?? current.conversationId,
        groupId: updated.groupId ?? current.groupId,
        chatType: updated.chatType ?? current.chatType,
        userId: updated.userId ?? current.userId,
        name: (updated.name != null &&
                updated.name!.isNotEmpty &&
                updated.name != 'Unknown User')
            ? updated.name
            : current.name,
        groupName: updated.groupName ?? current.groupName,
        memberCount: updated.memberCount ?? current.memberCount,
        role: updated.role ?? current.role,
        message: (updated.message != null && updated.message!.isNotEmpty)
            ? updated.message
            : current.message,
        preview: (updated.preview != null && updated.preview!.isNotEmpty)
            ? updated.preview
            : (current.preview ?? current.message),
        isDeletedForEveryone:
            updated.isDeletedForEveryone ?? current.isDeletedForEveryone,
        time: (updated.time != null && updated.time!.isNotEmpty)
            ? updated.time
            : current.time,
        timestamp: (updated.timestamp != null && updated.timestamp!.isNotEmpty)
            ? updated.timestamp
            : (current.timestamp ?? updated.time ?? current.time),
        messageType: updated.messageType ?? current.messageType,
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
        image: (updated.image != null &&
                updated.image!.isNotEmpty &&
                !_isPlaceholderImage(updated.image))
            ? updated.image
            : current.image,
        isForwarded: updated.isForwarded ?? current.isForwarded,
        forwardedLabel: updated.forwardedLabel ?? current.forwardedLabel,
        forwardedFromMessageId:
            updated.forwardedFromMessageId ?? current.forwardedFromMessageId,
      );
    }

    final updatedHasTime = (updated.timestamp != null &&
            updated.timestamp!.isNotEmpty) ||
        (updated.time != null && updated.time!.isNotEmpty);

    final updatedHasMessage =
        (updated.message != null && updated.message!.isNotEmpty);

    final currentTime = _parseDateTime(current.timestamp ?? current.time);
    final updatedTime = _parseDateTime(updated.timestamp ?? updated.time);

    final bool useUpdatedMessage =
        updatedHasMessage && (!currentTime.isAfter(updatedTime));

    final resolvedTime = updatedHasTime
        ? (useUpdatedMessage ? (updated.time ?? current.time) : current.time)
        : current.time;

    final resolvedTimestamp = updatedHasTime
        ? (useUpdatedMessage
            ? (updated.timestamp ?? updated.time ?? current.timestamp)
            : current.timestamp)
        : current.timestamp;

    return PrivateChatModel(
      id: updated.id ?? current.id,
      chatId: updated.chatId ?? current.chatId,
      conversationId: updated.conversationId ?? current.conversationId,
      groupId: updated.groupId ?? current.groupId,
      chatType: updated.chatType ?? current.chatType,
      userId: updated.userId ?? current.userId,
      name: (updated.name != null &&
              updated.name!.isNotEmpty &&
              updated.name != 'Unknown User')
          ? updated.name
          : current.name,
      groupName: updated.groupName ?? current.groupName,
      memberCount: updated.memberCount ?? current.memberCount,
      role: updated.role ?? current.role,
      message: useUpdatedMessage ? updated.message : current.message,
      preview: useUpdatedMessage
          ? (updated.preview ?? updated.message ?? current.preview)
          : (current.preview ?? current.message),
      isDeletedForEveryone:
          updated.isDeletedForEveryone ?? current.isDeletedForEveryone,
      time: resolvedTime,
      timestamp: resolvedTimestamp,
      messageType: useUpdatedMessage
          ? (updated.messageType ?? current.messageType)
          : current.messageType,
      mutedUntil: updated.mutedUntil ?? current.mutedUntil,
      unreadCount: updated.unreadCount ?? current.unreadCount,
      status: updated.status ?? current.status,
      isOnline: updated.isOnline ?? current.isOnline,
      lastSeen: updated.lastSeen ?? current.lastSeen,
      isBlocked: updated.isBlocked ?? current.isBlocked,
      blockedByMe: updated.blockedByMe ?? current.blockedByMe,
      isGroup: updated.isGroup ?? current.isGroup,
      isPinned: updated.isPinned ?? current.isPinned,
      pinnedAt: updated.pinnedAt ?? current.pinnedAt,
      isMuted: updated.isMuted ?? current.isMuted,
      isArchived: updated.isArchived ?? current.isArchived,
      moveToTop: updated.moveToTop ?? current.moveToTop,
      image: (updated.image != null &&
              updated.image!.isNotEmpty &&
              !_isPlaceholderImage(updated.image))
          ? updated.image
          : current.image,
      isForwarded: updated.isForwarded ?? current.isForwarded,
      forwardedLabel: updated.forwardedLabel ?? current.forwardedLabel,
      forwardedFromMessageId:
          updated.forwardedFromMessageId ?? current.forwardedFromMessageId,
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
    final effectiveId =
        chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId ?? chat.userId;
    if (effectiveId != null) {
      socketService.archivePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    chat.isArchived = true;
    chat.isPinned = false;

    privateChats.removeWhere(
      (item) => _isSameChat(item, chat),
    );

    final existingArchivedIndex = archivedChats.indexWhere(
      (item) => _isSameChat(item, chat),
    );
    if (existingArchivedIndex == -1) {
      archivedChats.insert(0, chat);
    } else {
      final merged = _mergePrivateChat(
        archivedChats[existingArchivedIndex],
        chat,
      );
      merged.isArchived = true;
      archivedChats[existingArchivedIndex] = merged;
    }

    privateChats.refresh();
    archivedChats.refresh();
  }

  void unarchiveChat(PrivateChatModel chat) {
    final effectiveId =
        chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId ?? chat.userId;
    if (effectiveId != null) {
      socketService.unarchivePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    chat.isArchived = false;
    chat.isPinned = false;

    archivedChats.removeWhere(
      (item) => _isSameChat(item, chat),
    );

    final existingIndex = privateChats.indexWhere(
      (item) => _isSameChat(item, chat),
    );

    if (existingIndex == -1) {
      privateChats.insert(0, chat);
    } else {
      final merged = _mergePrivateChat(
        privateChats[existingIndex],
        chat,
      );
      merged.isArchived = false;
      privateChats[existingIndex] = merged;
    }

    privateChats.assignAll(_sortPinnedChats(privateChats));

    archivedChats.refresh();
    privateChats.refresh();
  }

  Future<void> markChatAsRead(PrivateChatModel chat) async {
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

    final keys = _getAllChatKeys(chat);
    if (keys.isNotEmpty) {
      manuallyUnreadChatKeys.removeAll(keys);
      manuallyUnreadChatKeys.refresh();
      await _saveManuallyUnreadKeys();
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
    // Deprecated: _sortPinnedChats handles accurate WhatsApp ordering (pinned chats first, then latest activity)
  }

  List<PrivateChatModel> _sortPinnedChats(
    List<PrivateChatModel> chats,
  ) {
    final sortedChats = List<PrivateChatModel>.from(chats);

    final originalIndices = <PrivateChatModel, int>{};
    for (int i = 0; i < chats.length; i++) {
      originalIndices[chats[i]] = i;
    }

    DateTime getPinnedTimestamp(PrivateChatModel chat) {
      return _parseDateTime(chat.pinnedAt);
    }

    DateTime getTimestamp(PrivateChatModel chat) {
      return _parseDateTime(chat.timestamp ?? chat.time);
    }

    sortedChats.sort((a, b) {
      final aPinned = a.isPinned == true;
      final bPinned = b.isPinned == true;

      // 1. Pinned conversations first
      if (aPinned != bPinned) {
        return aPinned ? -1 : 1;
      }
      if (aPinned && bPinned) {
        final aPinnedTime = getPinnedTimestamp(a);
        final bPinnedTime = getPinnedTimestamp(b);
        final cmp = bPinnedTime.compareTo(aPinnedTime);
        if (cmp != 0) return cmp;
      }

      // 2. Latest message/activity timestamp DESC (newest first)
      final aTime = getTimestamp(a);
      final bTime = getTimestamp(b);
      final cmpTime = bTime.compareTo(aTime);
      if (cmpTime != 0) return cmpTime;

      // 3. Preserve original server order
      final aIdx = originalIndices[a] ?? 0;
      final bIdx = originalIndices[b] ?? 0;
      return aIdx.compareTo(bIdx);
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
          .where((chat) =>
              chat.id != null ||
              chat.chatId != null ||
              chat.userId != null ||
              chat.groupId != null)
          .toList();

      for (final chat in chats) {
        chat.isArchived = true;
      }

      archivedChats.value = chats;

      // Ensure mutual exclusivity: remove any archived chats from privateChats
      for (final a in chats) {
        privateChats.removeWhere((p) => _isSameChat(p, a));
      }
      privateChats.refresh();

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
    _searchDebounce?.cancel();
    searchController.dispose();
    socketService.disconnectPrivateChatListSocket();

    super.onClose();
  }
}
