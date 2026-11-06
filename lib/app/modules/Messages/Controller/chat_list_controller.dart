import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/GetMessageRepo.dart';
import '../../../Data/Services/active_chat_tracker.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_list_logic.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // TODO(cl-diagnostics)
import 'package:fgtracker/app/Core/util/arc_log.dart'; // TODO(arc-diagnostics)

/// Single store for the unified chat list and the Archived list.
///
/// Created once per logged-in session by HomeController (lives on the home
/// route), so its sockets and listeners stay active app-wide; logout's
/// Get.deleteAll disposes it. ChatListScreen's Get.put reuses the instance.
class ChatListController extends GetxController with WidgetsBindingObserver {
  static ChatListController? get instance =>
      Get.isRegistered<ChatListController>() ? Get.find<ChatListController>() : null;

  /// Finds an existing private chat model by peer user ID in either active or archived lists.
  PrivateChatModel? findPrivateChatByUserId(dynamic userId) {
    if (userId == null) return null;
    final uidStr = userId.toString().trim();
    if (uidStr.isEmpty) return null;

    final inPrivate = privateChats.firstWhereOrNull((c) {
      if (c.isGroup == true || c.chatType == "group" || c.groupId != null) return false;
      return c.userId?.toString() == uidStr;
    });
    if (inPrivate != null) return inPrivate;

    return archivedChats.firstWhereOrNull((c) {
      if (c.isGroup == true || c.chatType == "group" || c.groupId != null) return false;
      return c.userId?.toString() == uidStr;
    });
  }

  RxList<PrivateChatModel> privateChats = <PrivateChatModel>[].obs;

  /// chatKey -> "typing..." / "Rahul is typing..." for rows being typed in.
  final RxMap<String, String> typingLabels = <String, String>{}.obs;
  late final ChatTypingTracker _typing = ChatTypingTracker(
    onChanged: _publishTyping,
  );

  /// Snapshot taken before an optimistic action, restored if it fails.
  final Map<String, ({PrivateChatModel snapshot, bool wasArchived, String action})>
      _pendingActions = {};

  DateTime? _lastServerSync;
  Timer? _refetchDebounce;

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
      final hasIdentity = (name != null && name.isNotEmpty && name != "Unknown User") ||
          chat.userId != null ||
          chat.groupId != null ||
          chat.chatId != null ||
          chat.id != null;
      if (!hasIdentity) {
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

  /// Main-list chats with something unread (badge count or manual unread).
  int get mainUnreadChatCount => displayedChats
      .where((c) => (c.unreadCount ?? 0) > 0 || isChatMarkedUnread(c))
      .length;

  /// Unread messages inside archived chats (shown on the Archived entry,
  /// excluded from every main-list total).
  int get archivedUnreadCount => displayedArchivedChats.fold<int>(
        0,
        (sum, chat) => sum + (chat.unreadCount ?? 0),
      );

  /// Group deactivated by its admin (backend v2.5.0). A live
  /// `group_status_updated` event wins over the row's API value.
  /// Reactive: call inside Obx so the badge updates in real time.
  bool isGroupDeactivated(PrivateChatModel chat) {
    if (!_isGroupChat(chat)) return false;
    final id = (chat.groupId ?? chat.id)?.toString();
    final live = id == null ? null : socketService.groupDeactivated[id];
    return live ?? chat.isGroupDeactivated;
  }

  /// Typing label for a row, or null.
  String? typingLabelFor(PrivateChatModel chat) =>
      typingLabels[ChatListRules.chatKey(chat)];

  final socketService = SocketMessageService.instance;

  String get currentUserId {
    final value = Global.storageServices.get(PrefConst.userId);
    return value.toString();
  }

  @override
  void onInit() {
    super.onInit();

    // The "chat list viewed" marker is sent by the Chatting quick action
    // when the screen is opened; this controller now starts with the home
    // screen, so it must not clear the badge here.
    WidgetsBinding.instance.addObserver(this);
    _loadManuallyUnreadKeys();
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
      _syncChattingNotificationMarker();
    }
  }

  void _syncChattingNotificationMarker() {
    if (!Get.isRegistered<NotificationMarkerService>()) return;
    final markerService = NotificationMarkerService.instance;
    final hasPrivateUnread = privateChats.any((c) =>
        (c.isGroup != true && c.chatType != 'group') &&
        ((c.unreadCount ?? 0) > 0 || isChatMarkedUnread(c)));
    final hasGroupUnread = privateChats.any((c) =>
        (c.isGroup == true || c.chatType == 'group') &&
        ((c.unreadCount ?? 0) > 0 || isChatMarkedUnread(c)));

    markerService.setPrivateChatUnread(hasPrivateUnread);
    // Was only ever set to true, so the home "Chatting" dot stuck after all
    // group chats were read.
    markerService.setGroupChatUnread(hasGroupUnread);
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

  static String _getChatKey(PrivateChatModel chat) =>
      ChatListRules.chatKey(chat);

  bool _isGroupChat(PrivateChatModel c) =>
      c.isGroup == true || c.chatType == "group" || c.groupId != null;

  /// True when this chat is open on screen right now.
  bool _isViewingChat(PrivateChatModel c) => _isGroupChat(c)
      ? ActiveChatTracker.isViewing(isGroup: true, groupId: c.groupId ?? c.id)
      : ActiveChatTracker.isViewing(
          chatId: c.chatId ?? c.conversationId ?? c.id,
          peerUserId: c.userId,
        );

  /// Chats read on this device (key -> when). A realtime row update that is
  /// not a new message must not bring back a stale server unread count
  /// computed before our read reached the server.
  final Map<String, DateTime> _readLocallyAt = {};

  /// "chatKey#messageId" of messages already counted as unread, so the
  /// duplicate receive_message (same id) never counts twice.
  final Set<String> _countedMessageIds = {};

  /// TEMPORARY [CL] diagnostics (debug builds only).
  /// TODO(cl-diagnostics): remove after device QA.
  void _cl(String msg) {
    if (kDebugMode) debugPrint('[CL] $msg');
  }

  /// HttpUtil can return {status:false} instead of throwing.
  bool _isFailedResponse(dynamic res) =>
      res is Map && (res['status'] == false || res['success'] == false);

  /// The server sends lastMessage:null when "delete for me" removed the only
  /// message. The merge keeps old text for empty fields, so the deleted
  /// message stayed visible (main AND Archive list); clear the preview.
  void _applyExplicitNoMessage(
    PrivateChatModel row,
    Map<String, dynamic> payload,
  ) {
    final explicitNoMessage = (payload.containsKey('lastMessage') &&
            payload['lastMessage'] == null) ||
        (payload.containsKey('last_message') &&
            payload['last_message'] == null);
    if (!explicitNoMessage) return;
    row
      ..message = ''
      ..preview = ''
      ..messageType = 'text'
      ..lastMessageData = null
      ..isDeletedForEveryone = false;
    _cl('delete ${_getChatKey(row)} lastMessage:null => preview cleared');
  }

  /// [serverMain] is a server snapshot of NON-archived chats
  /// (includeArchived=false). A chat archived here that the server lists as
  /// not archived was unarchived (e.g. on another device): move it out of
  /// Archive. While our own archive request is still pending it stays
  /// archived and is removed from the snapshot. Returns the snapshot to use.
  List<PrivateChatModel> _reconcileArchived(List<PrivateChatModel> serverMain) {
    if (archivedChats.isEmpty) return serverMain;
    final result = <PrivateChatModel>[];
    var archiveChanged = false;
    for (final chat in serverMain) {
      final i = archivedChats.indexWhere((a) => _isSameChat(a, chat));
      if (i == -1) {
        result.add(chat);
        continue;
      }
      if (_pendingActions[_getChatKey(chat)]?.action == 'archive') {
        _cl('archive keep ${_getChatKey(chat)} (archive pending)');
        continue;
      }
      _cl('archive ${_getChatKey(chat)} unarchived on server => main');
      archivedChats.removeAt(i);
      archiveChanged = true;
      chat.isArchived = false;
      result.add(chat);
    }
    if (archiveChanged) archivedChats.refresh();
    return result;
  }

  /// Upserts server archived chats into Archive WITHOUT dropping local rows
  /// (an archived group missing from a private-only reply used to vanish).
  /// In-place updates keep the Archive row from rebuilding needlessly.
  void _mergeArchived(List<PrivateChatModel> serverArchived) {
    var changed = false;
    for (final chat in serverArchived) {
      chat.isArchived = true;
      if (_pendingActions[_getChatKey(chat)]?.action == 'unarchive') continue;
      final i = archivedChats.indexWhere((a) => _isSameChat(a, chat));
      if (i == -1) {
        archivedChats.add(chat);
      } else {
        final merged =
            _mergePrivateChat(archivedChats[i], chat, fromServer: true);
        merged.isArchived = true;
        archivedChats[i] = merged;
      }
      privateChats.removeWhere((p) => _isSameChat(p, chat));
      changed = true;
    }
    if (!changed) return;
    archivedChats.assignAll(ChatListRules.sort(archivedChats));
    privateChats.refresh();
    _syncChattingNotificationMarker();
  }

  /// Archive over REST (/chat-list?includeArchived=true, isArchived rows).
  /// The socket request alone was skipped whenever the list socket wasn't
  /// connected yet, so Archive often stayed empty.
  Future<void> _loadArchivedFromApi() async {
    try {
      final res = await MessageRepo.getChatList(
        page: 1,
        limit: 50,
        type: "all",
        includeArchived: true,
      );
      final archived =
          (res.data ?? []).where((c) => c.isArchived == true).toList();
      _cl('archive REST rows=${res.data?.length ?? 0} archived=${archived.length} '
          'groups=${archived.where(_isGroupChat).length}');
      _mergeArchived(archived);
    } catch (e) {
      _cl('archive REST failed: $e');
    }
  }

  bool _wasReadLocally(PrivateChatModel c) {
    final at = _readLocallyAt[_getChatKey(c)];
    return at != null &&
        DateTime.now().difference(at) < const Duration(minutes: 2);
  }

  PrivateChatModel? _findRow({
    required bool isGroup,
    dynamic groupId,
    dynamic chatId,
    dynamic peerUserId,
  }) {
    String? s(dynamic v) {
      final str = v?.toString().trim();
      return (str == null || str.isEmpty || str == 'null') ? null : str;
    }

    return privateChats.firstWhereOrNull((c) {
      if (isGroup) {
        return _isGroupChat(c) &&
            s(groupId) != null &&
            s(c.groupId ?? c.id) == s(groupId);
      }
      return !_isGroupChat(c) &&
          ((s(chatId) != null &&
                  s(c.chatId ?? c.conversationId ?? c.id) == s(chatId)) ||
              (s(peerUserId) != null && s(c.userId) == s(peerUserId)));
    });
  }

  /// The open chat screen knows the real last message. Called after a
  /// delete (for me / for everyone) and when the chat closes, so the row
  /// never keeps showing a message that was deleted or cleared.
  /// [last] null = the chat is now empty.
  void syncLastMessageFromChat({
    bool isGroup = false,
    dynamic groupId,
    dynamic chatId,
    dynamic peerUserId,
    required MessageData? last,
  }) {
    final row = _findRow(
      isGroup: isGroup,
      groupId: groupId,
      chatId: chatId,
      peerUserId: peerUserId,
    );
    if (row == null) return;

    if (last == null) {
      if ((row.message ?? '').isEmpty && (row.preview ?? '').isEmpty) return;
      row
        ..message = ''
        ..preview = ''
        ..messageType = 'text'
        ..lastMessageData = null
        ..isDeletedForEveryone = false;
      privateChats.refresh();
      return;
    }

    final deleted = last.isDeleted == true ||
        last.content?.toString() == MessagePreviewBuilder.deletedText;
    final preview = MessagePreviewBuilder.forMessage(last);
    final text = deleted ? MessagePreviewBuilder.deletedText : preview.display;
    if (row.preview == text &&
        (row.isDeletedForEveryone == true) == deleted) {
      return;
    }
    row
      ..message = text
      ..preview = text
      ..messageType = deleted ? 'text' : last.messageType?.toString()
      ..lastMessageData = null
      ..isDeletedForEveryone = deleted
      ..senderId = last.senderId?.toString() ?? row.senderId
      ..senderName = last.senderName?.toString() ?? row.senderName;
    privateChats.refresh();
  }

  /// Called when a chat screen closes: everything in it was read, so drop its
  /// unread badge locally (the read was also sent to the server).
  void clearUnreadForOpenedChat({
    bool isGroup = false,
    dynamic groupId,
    dynamic chatId,
    dynamic peerUserId,
  }) {
    String? s(dynamic v) {
      final str = v?.toString().trim();
      return (str == null || str.isEmpty || str == 'null') ? null : str;
    }

    var changed = false;
    for (final c in privateChats) {
      final bool match;
      if (isGroup) {
        match = _isGroupChat(c) &&
            s(groupId) != null &&
            s(c.groupId ?? c.id) == s(groupId);
      } else {
        match = !_isGroupChat(c) &&
            ((s(chatId) != null &&
                    s(c.chatId ?? c.conversationId ?? c.id) == s(chatId)) ||
                (s(peerUserId) != null && s(c.userId) == s(peerUserId)));
      }
      if (match) _readLocallyAt[_getChatKey(c)] = DateTime.now();
      final unread = c.unreadCount ?? 0;
      if (match && unread > 0) {
        unreadTotalCount.value =
            (unreadTotalCount.value - unread).clamp(0, 999999).toInt();
        c.unreadCount = 0;
        changed = true;
      }
    }
    if (changed) {
      privateChats.refresh();
      _syncChattingNotificationMarker();
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
      arcLog('main LOAD', // TODO(arc-diagnostics)
          'GET /chat-list?page=$requestedPage&includeArchived=false => '
          'rows=${response.data?.length ?? 0} '
          'withIsArchivedTrue=${(response.data ?? []).where((c) => c.isArchived == true).length}');

      // WhatsApp Rule (Recent Activity Only):
      // Strictly exclude empty chats (chats with 0 messages / no preview, or invalid name).
      // _reconcileArchived: a server list never re-adds a chat archived here
      // (unless the server says it was unarchived).
      final chats = _reconcileArchived((response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty) ||
            (chat.messageType != null &&
                chat.messageType!.trim().isNotEmpty &&
                chat.messageType != 'text');
        final name = (chat.name ?? chat.groupName)?.trim();
        final hasValidName = (name != null && name.isNotEmpty && name != "Unknown User") ||
            chat.userId != null ||
            chat.groupId != null ||
            chat.chatId != null ||
            chat.id != null;
        return hasMsg && hasValidName;
      }).toList());

      for (final chat in chats) {
        if ((chat.unreadCount ?? 0) > 0 && _isViewingChat(chat)) {
          chat.unreadCount = 0;
        }
      }

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
          final existing = existingChats[existingIndex];
          final merged = _mergePrivateChat(
            existing,
            apiChat,
            fromServer: true,
          );
          // Read here moments ago and no newer message on the server: a
          // positive server count predates our read (badge came back).
          // TODO(backend): server must reset unread on mark-read itself.
          if (_wasReadLocally(existing) &&
              !ChatListRules.isNewMessage(existing, apiChat)) {
            merged.unreadCount = 0;
          }
          mergedChats.add(merged);
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

      _lastServerSync = DateTime.now();

      if (response.pagination != null) {
        currentPage.value = response.pagination!.currentPage ?? requestedPage;

        totalPages.value = response.pagination!.totalPages ?? 0;
        hasNextPage.value = response.pagination!.hasNextPage ?? false;
        hasPreviousPage.value = response.pagination!.hasPreviousPage ?? false;
      }

      privateChats.refresh();
      _syncChattingNotificationMarker();
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

    // Registered once by reference; chat screens can't remove them.
    socketService.listenChatListTyping(
      onPrivateTyping: (data) => _onPrivateTyping(data, typing: true),
      onPrivateStopTyping: (data) => _onPrivateTyping(data, typing: false),
      onGroupTyping: (data) => _onGroupTyping(data, typing: true),
      onGroupStopTyping: (data) => _onGroupTyping(data, typing: false),
    );
    socketService.listenChatListReconnect(_resyncWithServer);
    socketService.listenGroupUpdated(callback: _handleGroupUpdated);

    // Group list updates, group typing and group "read" travel on /chat,
    // which otherwise only exists after a group chat was opened.
    socketService.ensureChatSocket(ConstRes.socketUrl, userId: userId);

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
      // _reconcileArchived: a server list never re-adds a chat archived here
      // (unless the server says it was unarchived).
      final chats = _reconcileArchived((response.data ?? []).where((chat) {
        if (chat.isArchived == true) return false;
        final hasMsg = (chat.message != null && chat.message!.trim().isNotEmpty) ||
            (chat.preview != null && chat.preview!.trim().isNotEmpty) ||
            (chat.messageType != null &&
                chat.messageType!.trim().isNotEmpty &&
                chat.messageType != 'text');
        final name = (chat.name ?? chat.groupName)?.trim();
        final hasValidName = (name != null && name.isNotEmpty && name != "Unknown User") ||
            chat.userId != null ||
            chat.groupId != null ||
            chat.chatId != null ||
            chat.id != null;
        return hasMsg && hasValidName;
      }).toList());

      for (final chat in chats) {
        if ((chat.unreadCount ?? 0) > 0 && _isViewingChat(chat)) {
          chat.unreadCount = 0;
        }
      }

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
        _syncChattingNotificationMarker();
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

  /// Realtime row update (`chat_list_updated` / `conversation_updated`) for
  /// private and group chats, main list and Archived list alike.
  ///
  /// Rules: a partial payload never removes a row; an archived chat stays
  /// archived unless the payload says `isArchived: false`; only a new message
  /// or a pin change reorders; an unknown chat with an incomplete payload is
  /// fetched from the API instead of dropped.
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

      // receive_message (also heard by the list socket) is a MESSAGE, not a
      // chat row: its `id` is the message id. Keep it as the row's last
      // message id so the duplicate event compares equal (counted once).
      final isMessagePayload = payload['lastMessage'] == null &&
          payload['last_message'] == null &&
          payload['lastActivity'] == null &&
          payload['senderId'] != null &&
          (payload.containsKey('content') || payload.containsKey('messageType'));
      final payloadMessageId = isMessagePayload ? payload['id'] : null;

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

      if (payload['userId'] == null && payload['senderId'] != null) {
        final sid = payload['senderId']?.toString();
        final rid = payload['receiverId']?.toString();
        payload['userId'] = (sid == currentUserId) ? rid : sid;
      }
      if (payload['chatId'] == null) {
        payload['chatId'] = payload['conversationId'] ?? payload['chat_id'];
      }
      if (payload['message'] == null) {
        payload['message'] = payload['text'] ?? payload['content'];
      }

      final updatedChat = PrivateChatModel.fromJson(payload);
      _clearAbsentFlags(updatedChat, payload);
      if (payloadMessageId != null && updatedChat.lastMessageData == null) {
        updatedChat.lastMessageData = {'id': payloadMessageId};
      }
      arcLog('realtime IN', arcPayload(payload)); // TODO(arc-diagnostics)

      if (updatedChat.id == null &&
          updatedChat.userId == null &&
          updatedChat.groupId == null) {
        return;
      }

      // The server answered for this chat: an optimistic action succeeded.
      _pendingActions.remove(_getChatKey(updatedChat));

      final mainIndex =
          privateChats.indexWhere((chat) => _isSameChat(chat, updatedChat));
      final archivedIndex =
          archivedChats.indexWhere((chat) => _isSameChat(chat, updatedChat));

      // A chat archived on this device stays archived. Message / read events
      // carry isArchived:false even for archived chats; letting that win
      // moved the chat to the main list until the next archived reload
      // moved it back (Archive row blinking, archived chats vanishing).
      // Unarchive comes from the user's action or the server list snapshot
      // (_reconcileArchived).
      final bool archived =
          archivedIndex >= 0 || updatedChat.isArchived == true;
      arcLog('realtime DECISION', // TODO(arc-diagnostics)
          '${arcChat(updatedChat)} inMain=${mainIndex >= 0} '
          'inArchived=${archivedIndex >= 0} => treatedAsArchived=$archived');

      if (archived) {
        if (mainIndex >= 0) {
          privateChats.removeAt(mainIndex);
          privateChats.refresh();
        }
        if (archivedIndex >= 0) {
          final merged =
              _applyRealtimeUpdate(archivedChats[archivedIndex], updatedChat);
          merged.isArchived = true;
          _applyExplicitNoMessage(merged, payload);
          archivedChats[archivedIndex] = merged;
        } else {
          if (!_isDisplayable(updatedChat)) {
            arcLog('realtime ACTION', // TODO(arc-diagnostics)
                'archived but not in archived list & payload incomplete => loadArchivedChats() REFETCH');
            loadArchivedChats();
            return;
          }
          updatedChat.isArchived = true;
          _prepareNewRow(updatedChat);
          archivedChats.add(updatedChat);
        }
        archivedChats.assignAll(ChatListRules.sort(archivedChats));
        _syncChattingNotificationMarker();
        arcLog('realtime ACTION', // TODO(arc-diagnostics)
            'updated ARCHIVED list (removedFromMain=${mainIndex >= 0}) ${arcLists(privateChats, archivedChats)}');
        return;
      }

      if (archivedIndex >= 0) {
        arcLog('realtime ACTION', // TODO(arc-diagnostics)
            'payload isArchived=false => MOVED archived -> MAIN');
        // Explicitly unarchived (isArchived: false).
        final moved =
            _applyRealtimeUpdate(archivedChats[archivedIndex], updatedChat);
        moved.isArchived = false;
        archivedChats.removeAt(archivedIndex);
        archivedChats.refresh();
        if (mainIndex == -1) {
          privateChats.add(moved);
        } else {
          privateChats[mainIndex] =
              _applyRealtimeUpdate(privateChats[mainIndex], updatedChat);
        }
        privateChats.assignAll(ChatListRules.sort(privateChats));
        _syncChattingNotificationMarker();
        return;
      }

      if (mainIndex == -1) {
        if (!_isDisplayable(updatedChat)) {
          arcLog('realtime ACTION', // TODO(arc-diagnostics)
              'not archived, not in main, payload incomplete => _scheduleServerRefetch()');
          // New chat, or not in the loaded page, and the payload lacks the
          // row details: fetch it instead of dropping the message.
          _scheduleServerRefetch();
          return;
        }
        arcLog('realtime ACTION', // TODO(arc-diagnostics)
            'not archived, not in main => ADDED to MAIN list');
        _prepareNewRow(updatedChat);
        privateChats.add(updatedChat);
        privateChats.assignAll(ChatListRules.sort(privateChats));
        _syncChattingNotificationMarker();
        return;
      }

      final current = privateChats[mainIndex];
      final newMessage = ChatListRules.isNewMessage(current, updatedChat);
      final merged = _applyRealtimeUpdate(current, updatedChat);
      _applyExplicitNoMessage(merged, payload);
      final pinChanged = (current.isPinned == true) != (merged.isPinned == true);
      privateChats[mainIndex] = merged;
      if (newMessage || pinChanged) {
        privateChats.assignAll(ChatListRules.sort(privateChats));
      } else {
        // Read/seen/online/profile update: change fields in place only.
        privateChats.refresh();
      }
      _syncChattingNotificationMarker();
    } catch (_) {}
  }

  /// Merges a realtime update into [current] and applies the unread policy.
  PrivateChatModel _applyRealtimeUpdate(
    PrivateChatModel current,
    PrivateChatModel updated,
  ) {
    final newMessage = ChatListRules.isNewMessage(current, updated);
    final merged = _mergePrivateChat(current, updated, fromServer: false);
    final key = _getChatKey(merged);
    // A genuinely new message makes the chat unread again.
    if (newMessage) _readLocallyAt.remove(key);
    // Count each message id once per chat (socket events arrive twice).
    final msgId = ChatListRules.lastMessageId(updated);
    final alreadyCounted =
        msgId != null && !_countedMessageIds.add('$key#$msgId');
    if (_countedMessageIds.length > 2000) _countedMessageIds.clear();
    final before = current.unreadCount ?? 0;
    merged.unreadCount = ChatListRules.resolveUnread(
      current: current,
      updated: updated,
      newMessage: newMessage,
      isViewing: _isViewingChat(merged),
      myUserId: currentUserId,
      readLocally: _wasReadLocally(merged),
      alreadyCounted: alreadyCounted,
    );
    _cl('count $key msgId=$msgId new=$newMessage alreadyCounted=$alreadyCounted '
        'server=${updated.unreadCount} $before -> ${merged.unreadCount}');
    if (newMessage) _typing.clearChat(_getChatKey(merged));
    return merged;
  }

  void _prepareNewRow(PrivateChatModel chat) {
    if ((chat.time == null || chat.time!.isEmpty) &&
        (chat.timestamp == null || chat.timestamp!.isEmpty)) {
      chat.time = DateTime.now().toUtc().toIso8601String();
      chat.timestamp = chat.time;
    }
    final sentByMe = chat.senderId != null && chat.senderId == currentUserId;
    // TODO(backend #7): per-recipient unread; my own message is never unread.
    if (_isViewingChat(chat) || sentByMe) chat.unreadCount = 0;
    _typing.clearChat(_getChatKey(chat));
  }

  bool _isDisplayable(PrivateChatModel chat) {
    final hasMsg = (chat.message?.trim().isNotEmpty ?? false) ||
        (chat.preview?.trim().isNotEmpty ?? false) ||
        (chat.messageType != null &&
            chat.messageType!.trim().isNotEmpty &&
            chat.messageType != 'text');
    final name = (chat.name ?? chat.groupName)?.trim();
    final hasIdentity = (name != null && name.isNotEmpty && name != "Unknown User") ||
        chat.userId != null ||
        chat.groupId != null ||
        chat.chatId != null ||
        chat.id != null;
    return hasMsg && hasIdentity;
  }

  /// PrivateChatModel.fromJson defaults a missing unread count to 0 and a
  /// missing pin/block flag to false. In a partial realtime payload that
  /// would wipe the badge or unpin the chat, so "absent" must stay null.
  void _clearAbsentFlags(PrivateChatModel chat, Map<String, dynamic> payload) {
    bool has(List<String> keys) => keys.any(payload.containsKey);
    if (!has(const ['unreadCount', 'unread_count', 'unread'])) {
      chat.unreadCount = null;
    }
    if (!has(const ['isPinned', 'is_pinned', 'pinned'])) chat.isPinned = null;
    if (!has(const ['isBlocked', 'is_blocked'])) chat.isBlocked = null;
    if (!has(const ['blockedByMe', 'blocked_by_me'])) chat.blockedByMe = null;
  }

  // ---------------------------------------------------------------------------
  // Server sync: reconnect, app resume, unknown chats
  // ---------------------------------------------------------------------------

  void _scheduleServerRefetch({
    Duration delay = const Duration(milliseconds: 600),
  }) {
    _refetchDebounce?.cancel();
    _refetchDebounce = Timer(delay, () {
      getPrivateChats(refresh: true);
    });
  }

  /// The /chat-list screen was opened: refresh from the server (throttled),
  /// since this store outlives the screen.
  void onChatListOpened() => _resyncWithServer();

  /// Socket (re)connected or app resumed: the server is the truth again.
  void _resyncWithServer() {
    final last = _lastServerSync;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(seconds: 3)) {
      return;
    }

    if (last != null) {
      _syncIncremental(last);
    } else {
      _scheduleServerRefetch(delay: const Duration(milliseconds: 300));
    }
    loadArchivedChats();
  }

  Future<void> _syncIncremental(DateTime since) async {
    try {
      final res = await MessageRepo.syncChat(
        sinceIsoTimestamp: since.toUtc().toIso8601String(),
      );
      if (res.status == true && res.data != null && res.data!.isNotEmpty) {
        for (final item in res.data!) {
          _handlePrivateChatUpdated(item.toJson());
        }
        _lastServerSync = DateTime.now();
        return;
      }
    } catch (_) {}
    _scheduleServerRefetch(delay: const Duration(milliseconds: 300));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final userId = currentUserId;
    if (userId.isEmpty || userId == "null") return;
    socketService.ensureChatSocket(ConstRes.socketUrl, userId: userId);
    if (!socketService.isPrivateChatListSocketConnected) {
      // Recreates the list socket; its connect handler calls _resyncWithServer.
      _initializePrivateChatListSocket();
    } else {
      _resyncWithServer();
    }
  }

  // ---------------------------------------------------------------------------
  // Typing indicator
  // ---------------------------------------------------------------------------

  void _publishTyping() {
    typingLabels.assignAll(
      _typing.labels(isGroup: (key) => key.startsWith('group_')),
    );
  }

  String? _str(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty || s == 'null') ? null : s;
  }

  void _onPrivateTyping(dynamic data, {required bool typing}) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    final typist = _str(m['userId'] ?? m['senderId'] ?? m['user_id']);
    if (typist == null || typist == currentUserId) return;

    // A GROUP typing event that also arrives as "typing" on the private
    // socket was shown on the typist's PRIVATE row (matched by userId).
    final chatType = _str(m['chatType'] ?? m['chat_type'])?.toLowerCase();
    if (chatType == 'group' || _str(m['groupId'] ?? m['group_id']) != null) {
      _cl('typing routed to group (payload groupId/chatType) from "typing"');
      _onGroupTyping(data, typing: typing);
      return;
    }

    final chatId = _str(m['chatId'] ?? m['conversationId'] ?? m['chat_id']);
    final candidates = [...privateChats, ...archivedChats]
        .where((c) => !_isGroupChat(c))
        .toList();
    // chatId first (exact chat), then the typist's private chat.
    final match = (chatId == null
            ? null
            : candidates.firstWhereOrNull(
                (c) => _str(c.chatId ?? c.conversationId ?? c.id) == chatId)) ??
        candidates.firstWhereOrNull((c) => _str(c.userId) == typist);
    final key = match != null ? _getChatKey(match) : 'private_$typist';
    _cl('typing private key=$key chatId=$chatId typist=$typist typing=$typing');

    if (typing && m['isTyping'] != false) {
      _typing.start(key, typist, name: _str(m['userName'] ?? m['senderName']));
    } else {
      _typing.stop(key, typist);
    }
  }

  void _onGroupTyping(dynamic data, {required bool typing}) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    final typist = _str(m['userId'] ?? m['senderId'] ?? m['user_id']);
    final groupId = _str(m['groupId'] ?? m['group_id']);
    if (typist == null || groupId == null || typist == currentUserId) return;
    final key = 'group_$groupId';
    if (typing && m['isTyping'] != false) {
      _typing.start(key, typist, name: _str(m['userName'] ?? m['senderName']));
    } else {
      _typing.stop(key, typist);
    }
  }

  @visibleForTesting
  void debugHandleChatUpdated(dynamic data) => _handlePrivateChatUpdated(data);

  @visibleForTesting
  void debugHandlePrivateTyping(dynamic data, {bool typing = true}) =>
      _onPrivateTyping(data, typing: typing);

  @visibleForTesting
  void debugHandleGroupTyping(dynamic data, {bool typing = true}) =>
      _onGroupTyping(data, typing: typing);

  @visibleForTesting
  void debugHandleArchivedChats(dynamic data) =>
      _handleArchivedPrivateChats(data);

  @visibleForTesting
  void debugHandleActionError(dynamic data) =>
      _handlePrivateChatActionError(data);

  PrivateChatModel _mergePrivateChat(
    PrivateChatModel current,
    PrivateChatModel updated, {
    bool fromServer = false,
  }) {
    if (fromServer) {
      // An API response that started before a realtime message arrived must
      // not roll the row back to the older message (and its older count).
      final apiTime = ChatListRules.lastMessageTime(updated);
      if (apiTime.millisecondsSinceEpoch > 0 &&
          ChatListRules.lastMessageTime(current).isAfter(apiTime) &&
          (current.message?.isNotEmpty ?? false)) {
        updated
          ..message = current.message
          ..preview = current.preview
          ..messageType = current.messageType
          ..isDeletedForEveryone = current.isDeletedForEveryone
          ..time = current.time
          ..timestamp = current.timestamp
          ..unreadCount = current.unreadCount
          ..senderId = current.senderId
          ..senderName = current.senderName
          ..lastMessageData = current.lastMessageData;
      }
      final serverHasMessage =
          updated.message != null && updated.message!.isNotEmpty;
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
        groupStatus: updated.groupStatus ?? current.groupStatus,
        isDeactivated: updated.isDeactivated ?? current.isDeactivated,
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
        // Sender + raw payload belong to the same message as `message`.
        senderId: serverHasMessage ? updated.senderId : current.senderId,
        senderName: serverHasMessage ? updated.senderName : current.senderName,
        lastMessageData: serverHasMessage
            ? updated.lastMessageData
            : current.lastMessageData,
      );
    }

    final updatedHasTime = (updated.timestamp != null &&
            updated.timestamp!.isNotEmpty) ||
        (updated.time != null && updated.time!.isNotEmpty);

    final updatedHasMessage =
        (updated.message != null && updated.message!.isNotEmpty);

    final currentTime = _parseDateTime(current.timestamp ?? current.time);
    final updatedTime = _parseDateTime(updated.timestamp ?? updated.time);

    final currentId = ChatListRules.lastMessageId(current);
    final updatedId = ChatListRules.lastMessageId(updated);

    final bool isDistinctNewId =
        currentId != null && updatedId != null && currentId != updatedId;

    final bool isDifferentText = updatedHasMessage &&
        current.message != null &&
        updated.message != current.message;

    final bool useUpdatedMessage = updatedHasMessage &&
        (isDistinctNewId ||
            isDifferentText ||
            !currentTime.isAfter(updatedTime.add(const Duration(seconds: 5))));

    // Same last message re-sent with a read/seen change (often a newer
    // updatedAt): take its fields but keep the time, so the row doesn't move.
    final sameMessage =
        currentId != null && currentId == updatedId;
    final takeUpdatedTime = useUpdatedMessage && !sameMessage;

    final resolvedTime = updatedHasTime
        ? (takeUpdatedTime ? (updated.time ?? current.time) : current.time)
        : current.time;

    final resolvedTimestamp = updatedHasTime
        ? (takeUpdatedTime
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
      groupStatus: updated.groupStatus ?? current.groupStatus,
      isDeactivated: updated.isDeactivated ?? current.isDeactivated,
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
      senderId: useUpdatedMessage ? updated.senderId : current.senderId,
      senderName: useUpdatedMessage ? updated.senderName : current.senderName,
      lastMessageData: useUpdatedMessage
          ? updated.lastMessageData
          : current.lastMessageData,
    );
  }

  void muteChat(
    PrivateChatModel chat, {
    String? mutedUntil,
  }) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId;
    if (effectiveId == null) {
      return;
    }

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup) {
      socketService.mutePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
        mutedUntil: mutedUntil,
      );
    }

    MessageRepo.muteConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isMuted: true,
      mutedUntil: mutedUntil,
    ).catchError((_) {});

    chat.isMuted = true;
    chat.mutedUntil = mutedUntil;

    privateChats.refresh();
    archivedChats.refresh();
  }

  void unmuteChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId;
    if (effectiveId == null) {
      return;
    }

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup) {
      socketService.unmutePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    MessageRepo.muteConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isMuted: false,
    ).catchError((_) {});

    chat.isMuted = false;
    chat.mutedUntil = null;

    privateChats.refresh();
    archivedChats.refresh();
  }

  // ---------------------------------------------------------------------------
  // Chat actions: optimistic UI, rolled back when the socket is offline or the
  // server replies with private_chat_action_error.
  // ---------------------------------------------------------------------------

  static const String _offlineMessage =
      "You're offline. The change wasn't saved, please try again.";

  void _beginAction(PrivateChatModel chat, String action) {
    final key = _getChatKey(chat);
    _pendingActions[key] = (
      snapshot: _copyChat(chat),
      wasArchived: archivedChats.any((c) => _isSameChat(c, chat)),
      action: action,
    );
    // No server reply within 15s: keep the optimistic state.
    Timer(const Duration(seconds: 15), () {
      if (_pendingActions[key]?.action == action) _pendingActions.remove(key);
    });
  }

  void _rollbackAction(String key, {String? message}) {
    final pending = _pendingActions.remove(key);
    if (pending == null) return;
    privateChats.removeWhere((c) => _getChatKey(c) == key);
    archivedChats.removeWhere((c) => _getChatKey(c) == key);
    if (pending.wasArchived) {
      archivedChats.add(pending.snapshot);
      archivedChats.assignAll(ChatListRules.sort(archivedChats));
    } else {
      privateChats.add(pending.snapshot);
      privateChats.assignAll(ChatListRules.sort(privateChats));
    }
    privateChats.refresh();
    archivedChats.refresh();
    _syncChattingNotificationMarker();
    _showActionError(message ?? "Couldn't update the chat. Please try again.");
  }

  void _showActionError(String message) {
    try {
      if (Get.context == null) return;
      Get.snackbar(
        "Chat",
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {}
  }

  PrivateChatModel _copyChat(PrivateChatModel c) => PrivateChatModel(
        id: c.id,
        chatId: c.chatId,
        conversationId: c.conversationId,
        groupId: c.groupId,
        chatType: c.chatType,
        userId: c.userId,
        name: c.name,
        groupName: c.groupName,
        memberCount: c.memberCount,
        role: c.role,
        message: c.message,
        preview: c.preview,
        isDeletedForEveryone: c.isDeletedForEveryone,
        time: c.time,
        timestamp: c.timestamp,
        messageType: c.messageType,
        mutedUntil: c.mutedUntil,
        unreadCount: c.unreadCount,
        status: c.status,
        isOnline: c.isOnline,
        lastSeen: c.lastSeen,
        isBlocked: c.isBlocked,
        blockedByMe: c.blockedByMe,
        isGroup: c.isGroup,
        isPinned: c.isPinned,
        pinnedAt: c.pinnedAt,
        isMuted: c.isMuted,
        isArchived: c.isArchived,
        groupStatus: c.groupStatus,
        isDeactivated: c.isDeactivated,
        moveToTop: c.moveToTop,
        image: c.image,
        isForwarded: c.isForwarded,
        forwardedLabel: c.forwardedLabel,
        forwardedFromMessageId: c.forwardedFromMessageId,
        senderId: c.senderId,
        senderName: c.senderName,
        lastMessageData: c.lastMessageData,
      );

  void pinChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId;
    if (effectiveId == null) {
      return;
    }

    _beginAction(chat, 'pin');

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup) {
      socketService.pinPrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    MessageRepo.pinConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isPinned: true,
    ).then((_) {
      _pendingActions.remove(_getChatKey(chat));
    }).catchError((e) {
      _rollbackAction(_getChatKey(chat), message: _offlineMessage);
    });

    chat.isPinned = true;
    chat.pinnedAt = DateTime.now().toUtc().toIso8601String();
    privateChats.assignAll(ChatListRules.sort(privateChats));
    privateChats.refresh();
  }

  void unpinChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId;
    if (effectiveId == null) {
      return;
    }

    _beginAction(chat, 'unpin');

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup) {
      socketService.unpinPrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    MessageRepo.pinConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isPinned: false,
    ).then((_) {
      _pendingActions.remove(_getChatKey(chat));
    }).catchError((e) {
      _rollbackAction(_getChatKey(chat), message: _offlineMessage);
    });

    chat.isPinned = false;
    chat.pinnedAt = null;
    privateChats.assignAll(ChatListRules.sort(privateChats));
    privateChats.refresh();
  }

  void archiveChat(PrivateChatModel chat) {
    final effectiveId =
        chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId ?? chat.userId;
    _beginAction(chat, 'archive');

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (chat.isPinned == true) {
      MessageRepo.pinConversation(
        chatId: cId,
        groupId: gId,
        chatType: isGroup ? "group" : "private",
        isPinned: false,
      ).catchError((_) {});

      if (!isGroup && effectiveId != null) {
        socketService.unpinPrivateChat(
          userId: currentUserId,
          chatId: effectiveId.toString(),
        );
      }
    }

    if (!isGroup && effectiveId != null) {
      socketService.archivePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    MessageRepo.archiveConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isArchived: true,
    ).then((res) {
      arcLog('archive API', // TODO(arc-diagnostics)
          'POST /archive chatId=$cId groupId=$gId chatType=${isGroup ? "group" : "private"} isArchived=true => $res');
      // The API can answer {status:false} without throwing: roll back.
      if (_isFailedResponse(res)) {
        _rollbackAction(_getChatKey(chat), message: _offlineMessage);
        return;
      }
      _pendingActions.remove(_getChatKey(chat));
    }).catchError((e) {
      arcLog('archive API', 'FAILED => $e (rollback)'); // TODO(arc-diagnostics)
      _rollbackAction(_getChatKey(chat), message: _offlineMessage);
    });

    chat.isArchived = true;
    chat.isPinned = false;
    chat.pinnedAt = null;

    privateChats.removeWhere(
      (item) => _isSameChat(item, chat),
    );

    final existingArchivedIndex = archivedChats.indexWhere(
      (item) => _isSameChat(item, chat),
    );
    if (existingArchivedIndex == -1) {
      archivedChats.add(chat);
    } else {
      final merged = _mergePrivateChat(
        archivedChats[existingArchivedIndex],
        chat,
      );
      merged.isArchived = true;
      archivedChats[existingArchivedIndex] = merged;
    }
    archivedChats.assignAll(ChatListRules.sort(archivedChats));

    privateChats.refresh();
    archivedChats.refresh();
    _syncChattingNotificationMarker();
    arcLog('archive LOCAL', // TODO(arc-diagnostics)
        '${arcChat(chat)} => ${arcLists(privateChats, archivedChats)}');
  }

  void unarchiveChat(PrivateChatModel chat) {
    final effectiveId =
        chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId ?? chat.userId;
    _beginAction(chat, 'unarchive');

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup && effectiveId != null) {
      socketService.unarchivePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    MessageRepo.archiveConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
      isArchived: false,
    ).then((res) {
      arcLog('unarchive API', // TODO(arc-diagnostics)
          'POST /archive chatId=$cId groupId=$gId isArchived=false => $res');
      if (_isFailedResponse(res)) {
        _rollbackAction(_getChatKey(chat), message: _offlineMessage);
        return;
      }
      _pendingActions.remove(_getChatKey(chat));
    }).catchError((e) {
      arcLog('unarchive API', 'FAILED => $e (rollback)'); // TODO(arc-diagnostics)
      _rollbackAction(_getChatKey(chat), message: _offlineMessage);
    });

    chat.isArchived = false;
    chat.isPinned = false;

    archivedChats.removeWhere(
      (item) => _isSameChat(item, chat),
    );

    final existingIndex = privateChats.indexWhere(
      (item) => _isSameChat(item, chat),
    );

    if (existingIndex == -1) {
      privateChats.add(chat);
    } else {
      final merged = _mergePrivateChat(
        privateChats[existingIndex],
        chat,
      );
      merged.isArchived = false;
      privateChats[existingIndex] = merged;
    }

    privateChats.assignAll(ChatListRules.sort(privateChats));

    archivedChats.refresh();
    privateChats.refresh();
    _syncChattingNotificationMarker();
  }

  /// Same read path the chat screen uses when it is opened.
  Future<void> markChatAsRead(PrivateChatModel chat) async {
    final previousUnread = chat.unreadCount ?? 0;
    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (isGroup) {
      if (gId != null) {
        socketService.markSeen(currentUserId, gId);
      }
    } else {
      if (cId != null) {
        socketService.markPrivateChatRead(
          userId: currentUserId,
          chatId: cId.toString(),
        );
      }
    }

    MessageRepo.markConversationRead(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
    ).catchError((_) {});

    final keys = _getAllChatKeys(chat);
    if (keys.isNotEmpty) {
      manuallyUnreadChatKeys.removeAll(keys);
      manuallyUnreadChatKeys.refresh();
      await _saveManuallyUnreadKeys();
    }

    if (previousUnread > 0) {
      unreadTotalCount.value =
          (unreadTotalCount.value - previousUnread).clamp(0, 999999).toInt();
    }
    chat.unreadCount = 0;
    privateChats.refresh();
    archivedChats.refresh();
    _syncChattingNotificationMarker();
  }

  void deleteChat(PrivateChatModel chat) {
    final effectiveId = chat.chatId ?? chat.conversationId ?? chat.id ?? chat.groupId;
    if (effectiveId == null) {
      return;
    }

    _beginAction(chat, 'delete');

    final bool isGroup = chat.isGroup == true || chat.groupId != null;
    final int? gId = isGroup ? (chat.groupId ?? chat.id) : null;
    final int? cId = isGroup ? null : (chat.chatId ?? chat.conversationId ?? chat.id);

    if (!isGroup) {
      socketService.deletePrivateChat(
        userId: currentUserId,
        chatId: effectiveId.toString(),
      );
    }

    // Call unified REST endpoint: for group chats, backend v2.2.0 performs
    // isolated "Clear Chat for Me" preserving DB messages for other members!
    MessageRepo.deleteConversation(
      chatId: cId,
      groupId: gId,
      chatType: isGroup ? "group" : "private",
    ).then((_) {
      _pendingActions.remove(_getChatKey(chat));
    }).catchError((e) {
      _rollbackAction(_getChatKey(chat), message: _offlineMessage);
    });

    privateChats.removeWhere((c) => _isSameChat(c, chat));
    archivedChats.removeWhere((c) => _isSameChat(c, chat));
    privateChats.refresh();
    archivedChats.refresh();
    _syncChattingNotificationMarker();
  }

  void _handleGroupUpdated(Map<String, dynamic> data) {
    final rawGid = data['groupId'] ?? data['id'] ?? data['chatId'];
    final gid = int.tryParse(rawGid?.toString() ?? '');
    if (gid == null) return;

    final newName = data['groupName']?.toString();
    final newImage = data['groupProfile']?.toString() ??
        data['groupProfileUrl']?.toString() ??
        data['profileImage']?.toString();
    if (newName == null && newImage == null) return;

    bool updatedAny = false;
    for (int i = 0; i < privateChats.length; i++) {
      final c = privateChats[i];
      if ((c.isGroup == true || c.chatType == 'group') &&
          (c.groupId == gid || c.id == gid)) {
        if (newName != null && newName.isNotEmpty) {
          c.name = newName;
          c.groupName = newName;
        }
        if (newImage != null && newImage.isNotEmpty) {
          c.image = newImage;
        }
        updatedAny = true;
      }
    }
    for (int i = 0; i < archivedChats.length; i++) {
      final c = archivedChats[i];
      if ((c.isGroup == true || c.chatType == 'group') &&
          (c.groupId == gid || c.id == gid)) {
        if (newName != null && newName.isNotEmpty) {
          c.name = newName;
          c.groupName = newName;
        }
        if (newImage != null && newImage.isNotEmpty) {
          c.image = newImage;
        }
        updatedAny = true;
      }
    }

    if (updatedAny) {
      privateChats.refresh();
      archivedChats.refresh();
    }
  }

  /// `private_chat_action_error`: roll back the matching optimistic action.
  void _handlePrivateChatActionError(dynamic data) {
    String? key;
    String? message;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      message = _str(m['message'] ?? m['error']);
      final chatId = _str(m['chatId'] ?? m['chat_id'] ?? m['conversationId']);
      if (chatId != null) {
        for (final entry in _pendingActions.entries) {
          final s = entry.value.snapshot;
          final ids = [s.chatId, s.conversationId, s.id, s.groupId]
              .map(_str)
              .whereType<String>();
          if (ids.contains(chatId)) {
            key = entry.key;
            break;
          }
        }
      }
    }
    // No usable chat id: roll back only when exactly one action is pending.
    key ??= _pendingActions.length == 1 ? _pendingActions.keys.first : null;
    if (key != null) {
      _rollbackAction(key, message: message);
    } else if (message != null) {
      _showActionError(message);
    }
  }

  List<PrivateChatModel> _sortPinnedChats(
    List<PrivateChatModel> chats,
  ) =>
      ChatListRules.sort(chats);

  void loadArchivedChats({
    int page = 1,
    int limit = 20,
  }) {
    arcLog('archived LOAD', // TODO(arc-diagnostics)
        'source=socket get_archived_private_chats page=$page limit=$limit '
        'socketConnected=${socketService.isPrivateChatListSocketConnected} '
        '(false = request silently skipped)');
    socketService.getArchivedPrivateChats(
      page: page,
      limit: limit,
    );
    if (page == 1) _loadArchivedFromApi();
  }

  void _handleArchivedPrivateChats(dynamic data) {
    try {
      if (data is! Map) {
        arcLog('archived RESPONSE', 'not a Map => archivedChats.clear()'); // TODO(arc-diagnostics)
        archivedChats.clear();
        return;
      }

      final rawData = data["data"];

      if (rawData is! List) {
        arcLog('archived RESPONSE', 'data is not a List => archivedChats.clear()'); // TODO(arc-diagnostics)
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

      arcLog('archived RESPONSE', // TODO(arc-diagnostics)
          'server items=${rawData.length} parsed=${chats.length} '
          'REPLACING list. before: ${arcLists(privateChats, archivedChats)} '
          'after: ${arcLists(privateChats, chats)} '
          'dropped=[${archivedChats.where((a) => !chats.any((c) => _isSameChat(a, c))).map(arcChat).join(' | ')}]');
      // Merge, never replace: the reply may hold only PRIVATE archived chats,
      // and replacing dropped archived groups from both lists. Sorted
      // client-side and removed from the main list inside _mergeArchived.
      _mergeArchived(chats);

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
      arcLog('archived RESPONSE', 'parse error $e => archivedChats.clear()'); // TODO(arc-diagnostics)
      archivedChats.clear();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    _refetchDebounce?.cancel();
    _typing.clearAll();
    _pendingActions.clear();
    searchController.dispose();
    socketService.disconnectPrivateChatListSocket();

    super.onClose();
  }
}
