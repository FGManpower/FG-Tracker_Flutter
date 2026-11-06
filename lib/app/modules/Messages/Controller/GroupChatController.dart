import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';

import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/global.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

import '../../../Model/GetMessage.dart';

import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import '../../../Data/Services/chat_translation_service.dart';
import '../../../Data/Services/active_chat_tracker.dart';
import '../../Attendance/controller/attendance_controller.dart';

import 'chat_list_controller.dart';
import 'chat_screen_logic.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/util/rt_attachment_log.dart'; // TODO(rt-diagnostics)
import 'group_profile_details_controller.dart';
import '../../Group/controller/MemberController.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // TODO(gc-diagnostics)
class GroupMessageController extends GetxController with WidgetsBindingObserver {
  final socketService = SocketMessageService.instance;

  final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final List<MessageData> _messages = [];

  late final TextEditingController textEditingController = TextEditingController();
  final RxBool showScrollToBottom = false.obs;
  final RxInt unreadBelowCount = 0.obs;
  bool _wasKeyboardOpen = false;
  bool _wasAtBottom = true;

  final StreamController<List<MessageData>> _messageStreamController =
      StreamController<List<MessageData>>.broadcast();

  Stream<List<MessageData>> get messageStream =>
      _messageStreamController.stream;

  List<MessageData> get messageData => _messages;

  void updateMessageStream() {
    if (_messageStreamController.isClosed) return;

    _messageStreamController.add(
      List.unmodifiable(_messages),
    );
  }

  RxList<String> videoPaths = <String>[].obs;
  RxList<Uint8List?> videoThumbnails = <Uint8List?>[].obs;
  RxList<LocationData> groupMembers = <LocationData>[].obs;
  final Rxn<MessageData> editingMessage = Rxn<MessageData>();
  final RxString groupName = ''.obs;
  final RxString groupDesc = ''.obs;
  late String groupImage;
  RxBool isLoadingMembers = false.obs;
  final RxBool isUploadingVideo = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  RxList<File> imagePaths = <File>[].obs;
  RxList<String> videoDurations = <String>[].obs;
  RxString documentPath = "".obs;
  RxBool isSending = false.obs;
  RxBool isLoading = true.obs;
  RxString messageText = "".obs;
  final RxBool showEmoji = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = "".obs;
  final RxList<int> searchResultIds = <int>[].obs;
  final RxInt currentSearchIndex = (-1).obs;
  RxBool isCreator = true.obs;
  final Rxn<MessageData> pinnedMessage = Rxn<MessageData>();
  final RxBool showPinnedBanner = true.obs;
  Rx<MessageData?> replyMessage = Rx<MessageData?>(null);
  RxInt highlightedMessageId = (-1).obs;
  final RxSet<int> uploadingVideoIndexes = <int>{}.obs;
  final RxMap<String, String> groupTypingUsers = <String, String>{}.obs;
  final RxString groupTypingText = "".obs;
  RxString groupTypingUser = "".obs;
  DateTime? _lastGroupTypingEmitTime;
  Timer? _groupTypingDebounceTimer;
  final Map<String, Timer> _groupTypingUserTimers = {};
  final RxMap<int, double> videoUploadProgress = <int, double>{}.obs;
  final RxString floatingDate = "".obs;
  final RxBool showFloatingDate = false.obs;
  Timer? _floatingDateTimer;
  RxInt groupCurrentPage = 1.obs;
  RxBool isLoadingOlderMessages = false.obs;
  RxBool hasMoreOlderMessages = true.obs;

  /// Pushes this group's real last message to the chat list row (after a
  /// delete, a clear, and on close). Only once history is loaded, so a
  /// failed load never blanks the row.
  void _syncChatListPreview() {
    if (!_historyLoaded || !Get.isRegistered<ChatListController>()) return;
    Get.find<ChatListController>().syncLastMessageFromChat(
      isGroup: true,
      groupId: groupId,
      last: _messages.isEmpty ? null : _messages.last,
    );
  }

  /// Group member's display name by user id (null when unknown).
  String? memberNameFor(dynamic userId) {
    final id = userId?.toString();
    if (id == null || id.isEmpty) return null;
    final member =
        groupMembers.firstWhereOrNull((m) => m.userId?.toString() == id);
    final name = member?.name?.toString().trim() ?? '';
    return name.isEmpty ? null : name;
  }

  /// Fills a missing sender name/image from the member list.
  /// Returns true if something was filled.
  bool fillSenderFromMembers(MessageData m) {
    final hasName = (m.senderName?.toString().trim() ?? '').isNotEmpty &&
        m.senderName?.toString() != 'null';
    if (hasName) return false;
    final id = m.senderId?.toString();
    final member = groupMembers
        .firstWhereOrNull((x) => x.userId?.toString() == id);
    final name = member?.name?.toString().trim() ?? '';
    if (name.isEmpty) return false;
    m.senderName = name;
    final img = m.senderImage?.toString() ?? '';
    if (img.isEmpty || img == 'null') m.senderImage = member?.profileImage;
    return true;
  }

  MessageData? findMessageById(dynamic id) {
    final key = id?.toString().trim() ?? '';
    if (key.isEmpty || key == 'null') return null;
    for (final m in _messages) {
      if (m.id?.toString() == key) return m;
    }
    return null;
  }

  Future<void> scrollToMessage(int messageId) async {
    var index = _messages.indexWhere((e) => e.id == messageId);

    if (index == -1) {
      // Original not loaded yet (reply to an old message): page back.
      index = await _loadOlderUntilFound(messageId);
      if (index == -1) {
        if (!isClosed) Utils().fluttertoast("Message not available");
        return;
      }
    }

    highlightedMessageId.value = messageId;

    if (itemScrollController.isAttached) {
      await itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    highlightedMessageId.value = -1;
  }

  void setReply(MessageData message) {
    replyMessage.value = message;
  }

  void clearReply() {
    replyMessage.value = null;
  }

  Map<String, dynamic>? arguments = Get.arguments;

  late int groupId;

  @override
  void onInit() {
    super.onInit();
    ChatTranslationService.instance.resetVisibility();

    groupId = arguments?["groupId"] is int
        ? (arguments!["groupId"] as int)
        : (int.tryParse(arguments?["groupId"]?.toString() ?? '0') ?? 0);

    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().clearManualUnreadForGroup(groupId);
    }

    groupName.value = arguments?["groupName"]?.toString() ?? "";
    groupDesc.value = arguments?["groupDesc"]?.toString() ?? "";
    groupImage = arguments?["groupImage"] ?? arguments?["groupProfile"] ?? "";
    _deactivatedOnOpen = _readDeactivatedFromArguments();

    WidgetsBinding.instance.addObserver(this);
    initializeGroupChat();
    itemPositionsListener.itemPositions.addListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.addListener(_updateScrollBottomState);
    itemPositionsListener.itemPositions.addListener(_onScrollForOlderMessages);
  }

  int? _attendanceListenerToken;

  // ---- Deactivated group (backend v2.5.0) ----
  bool _deactivatedOnOpen = false;

  /// "groupStatus": "deactivated" / "isDeactivated": true from the opener
  /// (chat list passes it), or an explicit "isActive": false.
  bool _readDeactivatedFromArguments() {
    final status = arguments?["groupStatus"]?.toString().toLowerCase();
    final flag = arguments?["isDeactivated"];
    final active = arguments?["isActive"]?.toString().toLowerCase();
    return status == "deactivated" ||
        flag == true ||
        flag?.toString() == "true" ||
        active == "false";
  }

  /// True while the group is deactivated by its admin: the screen shows a
  /// banner instead of the input and sending is blocked. A live
  /// `group_status_updated` event wins over the value the screen opened
  /// with. Reactive (read inside Obx).
  bool get isGroupDeactivated =>
      socketService.groupDeactivated[groupId.toString()] ??
      _deactivatedOnOpen;

  /// Send guard: nothing is sent to a deactivated group.
  bool _blockIfDeactivated() {
    if (!isGroupDeactivated) return false;
    Utils().fluttertoast("This group has been deactivated by the Admin");
    return true;
  }

  bool _isOtherGroup(dynamic eventGroupId) =>
      eventGroupId != null && eventGroupId.toString() != groupId.toString();

  void toggleEmoji() {
    showEmoji.toggle();
  }

  void hideEmoji() {
    showEmoji.value = false;
  }

  void initializeGroupChat() {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    // This screen now owns the /chat chat-screen listeners.
    socketService.claimGroupChatEvents(this);

    socketService.init(
      ConstRes.socketUrl,
      userId: currentUserId,
      groupId: groupId,
    );

    socketService.joinGroupChat(
      groupId: groupId,
      userId: currentUserId,
    );

    socketService.markSeen(currentUserId, groupId);
    ActiveChatTracker.openGroup(groupId);

    socketService.listenSeenUpdate(
      groupId: groupId,
      callback: (data) {
        AppLog.d("GROUP SEEN UPDATE => $data");
        if (data is Map) {
          if (_isOtherGroup(data["groupId"] ?? data["group_id"])) return;
          final userId = data["userId"]?.toString();
          if (userId != null && userId.isNotEmpty) {
            // My own mark_seen echo must not put me in "Seen by", and a
            // reader is never recorded on their own messages.
            final changed = ChatScreenRules.applyGroupSeen(
              _messages,
              readerId: userId,
              currentUserId:
                  Global.storageServices.get(PrefConst.userId)?.toString(),
            );
            if (changed) updateMessageStream();
          }
        }
      },
    );

    socketService.receiveGroupMessage(
      callback: (message) {
        AppLog.d("GROUP RECEIVE EVENT => $message");

        if (message is! Map) return;

        // Backend diagnostic: after each vote it echoes the poll on this event
        // with messageType "attendance_test". It is not a chat message, so it
        // must never become a bubble; treat it as a live poll update instead.
        if (message["messageType"]?.toString() == "attendance_test") {
          if (message["poll"] is Map) {
            _onAttendanceEvent("attendance:updated", message);
          }
          return;
        }

        final incomingMessage =
            MessageData.fromJson(Map<String, dynamic>.from(message));
        // Socket payloads often carry only senderId: the bubble then showed
        // no name and replying to it showed "Unknown". Fill from members.
        fillSenderFromMembers(incomingMessage);
        AppLog.d("RECEIVED MESSAGE ID => ${incomingMessage.id}");

        final eventGroupId = message["groupId"] ??
            message["group_id"] ??
            message["message"]?["groupId"] ??
            message["message"]?["group_id"] ??
            message["data"]?["groupId"] ??
            incomingMessage.groupId;
        if (eventGroupId != null && eventGroupId.toString() != groupId.toString()) {
          AppLog.d("GROUP MESSAGE IGNORED => DIFFERENT GROUP $eventGroupId vs $groupId");
          rtDecision('group listener', incomingMessage,
              'SKIPPED: different group ($eventGroupId vs $groupId)'); // TODO(rt-diagnostics)
          return;
        }

        final incomingId = incomingMessage.id;
        final clientMsgId = incomingMessage.clientMessageId;

        final currentUserId =
            Global.storageServices.get(PrefConst.userId)?.toString();
        final isMyMessage = incomingMessage.senderId?.toString() == currentUserId;
        final wasAtBottom = isUserAtBottom();

        int existingIndex = _messages.indexWhere((item) {
          if (clientMsgId != null &&
              clientMsgId.isNotEmpty &&
              item.clientMessageId == clientMsgId) {
            return true;
          }
          return incomingId != null && item.id == incomingId;
        });

        // Fallback for sender's optimistic bubble when server does not echo clientMessageId
        if (existingIndex == -1 && isMyMessage) {
          existingIndex = _messages.lastIndexWhere((item) =>
              item.id == null &&
              item.senderId?.toString() == currentUserId &&
              item.messageType == incomingMessage.messageType);
        }
        rtModel('group socket', incomingMessage,
            extra: 'matchedIndex=$existingIndex '
                'matchedIsTemp=${existingIndex != -1 && _messages[existingIndex].id == null} '
                'matchedImages=${existingIndex != -1 ? _messages[existingIndex].images : '-'} '
                'matchedContent=${existingIndex != -1 ? _messages[existingIndex].content : '-'}'); // TODO(rt-diagnostics)

        if (existingIndex != -1) {
          final existing = _messages[existingIndex];
          // Our own temp (optimistic) bubble: no server id yet.
          final wasTemp = existing.id == null;
          if (incomingId != null) existing.id = incomingId;
          existing.isDelivered = true;
          if (incomingMessage.timestamp != null &&
              incomingMessage.timestamp.toString().isNotEmpty) {
            existing.timestamp = incomingMessage.timestamp;
          }
          final hasOldContent = (existing.content?.toString().trim().isNotEmpty ?? false) ||
              (existing.caption?.toString().trim().isNotEmpty ?? false) ||
              (existing.images?.isNotEmpty ?? false) ||
              (existing.videos?.isNotEmpty ?? false);
          final hasNewContent = (incomingMessage.content?.toString().trim().isNotEmpty ?? false) ||
              (incomingMessage.caption?.toString().trim().isNotEmpty ?? false) ||
              (incomingMessage.images?.isNotEmpty ?? false) ||
              (incomingMessage.videos?.isNotEmpty ?? false);
          if (!hasOldContent && hasNewContent) {
            existing.content = incomingMessage.content;
            existing.caption = incomingMessage.caption;
            existing.images = incomingMessage.images;
            existing.videos = incomingMessage.videos;
            existing.messageType = incomingMessage.messageType;
            existing.thumbnail = incomingMessage.thumbnail;
          }
          // The check above skips a bubble that already has content (a temp
          // bubble always does), so the server's attachment never reached it
          // and media/voice only worked after re-opening. Temp bubble: the
          // server copy wins; duplicate event: fill what's still missing.
          existing.mergeAttachmentFrom(incomingMessage, overwrite: wasTemp);
          if (incomingMessage.senderName != null && incomingMessage.senderName.toString().isNotEmpty) {
            existing.senderName = incomingMessage.senderName;
          }
          if (incomingMessage.senderImage != null && incomingMessage.senderImage.toString().isNotEmpty) {
            existing.senderImage = incomingMessage.senderImage;
          }
          updateMessageStream();
          AppLog.d("DUPLICATE OR OPTIMISTIC MESSAGE MERGED => $incomingId (client: $clientMsgId)");
          rtDecision('group list', incomingMessage,
              'MERGED into index $existingIndex (contentUpdated=${!hasOldContent && hasNewContent}) '
              'bubbleNowShows images=${existing.images} content=${existing.content} '
              'listLength=${_messages.length} streamEmitted=true'); // TODO(rt-diagnostics)
          return;
        }

        final hasContent = (incomingMessage.content?.toString().trim().isNotEmpty ?? false) ||
            (incomingMessage.caption?.toString().trim().isNotEmpty ?? false) ||
            (incomingMessage.images?.isNotEmpty ?? false) ||
            (incomingMessage.videos?.isNotEmpty ?? false);

        if (incomingMessage.isForwarded == true && !hasContent) {
          final fromId = incomingMessage.forwardedFromMessageId;
          if (fromId != null) {
            final source = _messages.firstWhereOrNull(
              (m) => m.id == fromId || m.id?.toString() == fromId.toString(),
            );
            if (source != null) {
              incomingMessage.content = source.content;
              incomingMessage.caption = source.caption;
              incomingMessage.images = source.images;
              incomingMessage.videos = source.videos;
              incomingMessage.messageType = source.messageType;
              incomingMessage.thumbnail = source.thumbnail;
            }
          }

          if ((incomingMessage.content?.toString().trim().isEmpty ?? true) &&
              (incomingMessage.caption?.toString().trim().isEmpty ?? true) &&
              (incomingMessage.images?.isEmpty ?? true) &&
              (incomingMessage.videos?.isEmpty ?? true)) {
            _resolveForwardedGroupMessageContent(incomingMessage);
          }
        }

        _messages.add(incomingMessage);
        updateMessageStream();
        rtDecision('group list', incomingMessage,
            'ADDED listLength=${_messages.length} streamEmitted=true'); // TODO(rt-diagnostics)

        // The user is in this chat: the new message is read right away.
        if (!isMyMessage) _scheduleMarkGroupSeen();

        if (isMyMessage || wasAtBottom) {
          scrollToBottom();
        } else {
          unreadBelowCount.value++;
          showScrollToBottom.value = true;
        }
      },
    );
    socketService.listenMessageEdited(
      scope: ChatSocketScope.group,
      callback: (data) {
        if (data is! Map) return;
        final map = Map<String, dynamic>.from(data);
        if (_isOtherGroup(map["groupId"] ?? map["group_id"])) return;
        if (ChatScreenRules.applyEdit(_messages, map)) updateMessageStream();
      },
    );

    socketService.listenMessageDeleted(
      scope: ChatSocketScope.group,
      callback: (data) {
        AppLog.d("RAW DELETE EVENT: $data");

        if (data is! Map) return;

        final messageId = int.tryParse(
          (data["messageId"] ?? data["message_id"] ?? data["id"] ?? "")
              .toString(),
        );

        final eventGroupId = int.tryParse(
          (data["groupId"] ?? data["group_id"] ?? "").toString(),
        );

        if (messageId == null) return;
        if (eventGroupId != null && eventGroupId != groupId) return;

        final deleteType =
        (data["deleteType"] ?? data["delete_type"] ?? "for_everyone")
            .toString();

        final index = _messages.indexWhere((m) => m.id == messageId);

        AppLog.d(
          "DELETE TYPE => $deleteType | INDEX => $index | MSG ID => $messageId",
        );

        if (index != -1) {
          if (deleteType == "for_me") {
            // Only the user who deleted it loses it.
            final me =
                Global.storageServices.get(PrefConst.userId)?.toString();
            if (!ChatScreenRules.isDeleteForMeByMe(data, me)) return;
            _messages.removeAt(index);
          } else {
            ChatScreenRules.markDeletedForEveryone(_messages[index]);
          }
        }

        if (pinnedMessage.value?.id == messageId) {
          pinnedMessage.value = null;
          showPinnedBanner.value = false;
        }

        updateMessageStream();
        // The chat list row must not keep showing the deleted message.
        _syncChatListPreview();


      },
    );

    socketService.listenPinMessage(
      scope: ChatSocketScope.group,
      callback: (data) {
        final eventGroupId = int.tryParse(
          (data["groupId"] ?? data["group_id"] ?? "").toString(),
        );

        final messageId = int.tryParse(
          (data["messageId"] ?? data["message_id"] ?? "").toString(),
        );

        if (data["chatType"] != "group") return;
        if (eventGroupId != groupId || messageId == null) return;

        final msg = _messages.firstWhereOrNull(
          (e) => e.id == messageId,
        );

        if (msg != null) {
          pinnedMessage.value = msg;
          showPinnedBanner.value = true;
          updateMessageStream();
        }
      },
    );

    socketService.listenUnpinMessage(
      scope: ChatSocketScope.group,
      callback: (data) {
        if (data["chatType"] != "group") return;

        final dataGroupId = int.tryParse(data["groupId"].toString());

        if (dataGroupId != groupId) return;

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();
      },
    );

    socketService.listenMessageSent(
      scope: ChatSocketScope.group,
      callback: (data) {
        final clientMsgId = data['clientMessageId']?.toString();
        final serverId = int.tryParse(
          data['id']?.toString() ?? data['messageId']?.toString() ?? '',
        );
        if (serverId == null) return;

        bool updated = false;
        for (final msg in _messages) {
          if ((clientMsgId != null &&
                  clientMsgId.isNotEmpty &&
                  msg.clientMessageId == clientMsgId) ||
              (msg.id == serverId)) {
            msg.id = serverId;
            msg.isDelivered = true;
            updated = true;
            break;
          }
        }
        if (!updated) {
          final myId = Global.storageServices.get(PrefConst.userId)?.toString();
          for (int i = _messages.length - 1; i >= 0; i--) {
            final msg = _messages[i];
            if (msg.id == null && msg.senderId?.toString() == myId) {
              msg.id = serverId;
              msg.isDelivered = true;
              updated = true;
              break;
            }
          }
        }
        if (updated) updateMessageStream();
      },
    );

    socketService.listenGroupMessageSeen(
      callback: (data) {
        final evGid = int.tryParse((data['groupId'] ?? data['group_id'] ?? '').toString());
        if (evGid != null && evGid != groupId) return;
        final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();
        final seenBy = int.tryParse((data['seenBy'] ?? data['userId'] ?? '').toString());
        final rawIds = data['messageIds'] ?? data['message_ids'];
        final messageIds = (rawIds is List)
            ? rawIds.map((id) => int.tryParse(id.toString())).whereType<int>().toSet()
            : <int>{};
        final totalMembers = groupMembers.isNotEmpty ? groupMembers.length : 2;

        bool updated = false;
        for (final msg in _messages) {
          final isMyMsg = msg.senderId?.toString() == myUserId;
          if (isMyMsg && (messageIds.isEmpty || messageIds.contains(msg.id))) {
            msg.isDelivered = true;
            if (seenBy != null) {
              msg.seenBy ??= [];
              if (msg.seenBy is List && !(msg.seenBy as List).contains(seenBy)) {
                (msg.seenBy as List).add(seenBy);
              }
            }
            final seenLen = (msg.seenBy is List)
                ? (msg.seenBy as List).length
                : (msg.seenCount ?? 0);
            if (seenLen >= (totalMembers - 1)) {
              msg.seenCount = totalMembers - 1;
            }
            updated = true;
          }
        }
        if (updated) updateMessageStream();
      },
    );

    socketService.listenGroupUpdated(
      callback: (data) {
        final evGid = int.tryParse((data['groupId'] ?? data['group_id'] ?? data['id'] ?? '').toString());
        if (evGid != null && evGid != groupId) return;
        final newName = data['groupName']?.toString();
        final newProfile = data['groupProfile']?.toString() ?? data['groupProfileUrl']?.toString();
        final newDesc = data['groupDesc']?.toString() ?? data['description']?.toString();

        if (newName != null && newName.isNotEmpty) {
          groupName.value = newName;
        }
        if (newProfile != null && newProfile.isNotEmpty) {
          groupImage = newProfile;
        }
        if (newDesc != null) {
          groupDesc.value = newDesc;
        }
        update();
      },
    );

    socketService.listenGroupChatCleared(
      callback: (data) {
        final evGid = int.tryParse((data['groupId'] ?? data['group_id'] ?? '').toString());
        if (evGid != null && evGid != groupId) return;
        final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();
        final uId = data['userId']?.toString();
        if (uId != null && uId != myUserId) return;
        _messages.clear();
        updateMessageStream();
      },
    );

    AttendanceController.instance.markAllStale();
    _attendanceListenerToken = socketService.listenAttendanceEvents(
      onEvent: _onAttendanceEvent,
      // Runs on every (re)connect of the /chat socket: re-sync polls and
      // fetch any messages sent while we were disconnected.
      onReconnect: () {
        AttendanceController.instance.syncPolls(_visibleAttendancePollIds());
        syncNewerMessages();
      },
    );

    socketService.listenGroupTyping(
      onTyping: (data) {
        try {
          if (data is! Map) return;
          final dataMap = Map<String, dynamic>.from(data);
          final inner = dataMap['message'] is Map
              ? Map<String, dynamic>.from(dataMap['message'])
              : (dataMap['data'] is Map
                  ? Map<String, dynamic>.from(dataMap['data'])
                  : dataMap);

          final eventGroupId = int.tryParse(
            (inner["groupId"] ??
                    inner["group_id"] ??
                    dataMap["groupId"] ??
                    dataMap["group_id"] ??
                    "")
                .toString(),
          );

          if (eventGroupId != null && eventGroupId != groupId) return;

          final uid = (inner["userId"] ??
                  inner["user_id"] ??
                  inner["senderId"] ??
                  inner["sender_id"] ??
                  dataMap["userId"] ??
                  dataMap["senderId"])
              ?.toString();

          final currentUserId =
              Global.storageServices.get(PrefConst.userId)?.toString();

          if (uid == null || uid.isEmpty || uid == currentUserId) return;

          String? resolvedName;
          final member = groupMembers.firstWhereOrNull(
            (m) => m.userId?.toString() == uid,
          );
          if (member?.name != null && member!.name!.trim().isNotEmpty) {
            resolvedName = member.name!.trim();
          } else {
            final rawName = (inner["userName"] ??
                    inner["senderName"] ??
                    dataMap["userName"] ??
                    dataMap["senderName"])
                ?.toString()
                .trim();
            if (rawName != null && rawName.isNotEmpty && rawName != "Someone") {
              resolvedName = rawName;
            }
          }
          final finalName = resolvedName ?? "Someone";

          groupTypingUsers[uid] = finalName;
          _updateGroupTypingText();
          AppLog.d("[TYPING] Group typing active: ${groupTypingText.value}");

          _groupTypingUserTimers[uid]?.cancel();
          _groupTypingUserTimers[uid] =
              Timer(const Duration(milliseconds: 4500), () {
            if (!isClosed) {
              groupTypingUsers.remove(uid);
              _groupTypingUserTimers.remove(uid);
              _updateGroupTypingText();
              AppLog.d("[TYPING] Group typing timer expired for $uid: ${groupTypingText.value}");
            }
          });
        } catch (e) {
          AppLog.d("Error in onGroupTyping: $e");
        }
      },
      onStopTyping: (data) {
        try {
          if (data is! Map) return;
          final dataMap = Map<String, dynamic>.from(data);
          final inner = dataMap['message'] is Map
              ? Map<String, dynamic>.from(dataMap['message'])
              : (dataMap['data'] is Map
                  ? Map<String, dynamic>.from(dataMap['data'])
                  : dataMap);

          final eventGroupId = int.tryParse(
            (inner["groupId"] ??
                    inner["group_id"] ??
                    dataMap["groupId"] ??
                    dataMap["group_id"] ??
                    "")
                .toString(),
          );
          if (eventGroupId != null && eventGroupId != groupId) return;

          final uid = (inner["userId"] ??
                  inner["user_id"] ??
                  inner["senderId"] ??
                  inner["sender_id"] ??
                  dataMap["userId"] ??
                  dataMap["senderId"])
              ?.toString();

          if (uid != null && uid.isNotEmpty) {
            _groupTypingUserTimers[uid]?.cancel();
            _groupTypingUserTimers.remove(uid);
            groupTypingUsers.remove(uid);
            _updateGroupTypingText();
            AppLog.d("[TYPING] Group typing stopped for $uid: ${groupTypingText.value}");
          }
        } catch (_) {}
      },
    );

    // member_removed / member_left (group room). The socket service had
    // this listener but nothing registered it, so other members' lists only
    // updated after re-opening the group.
    socketService.listenMemberRemoved(callback: _onMemberRemoved);

    getGroupMessages();

    getGroupMembers();
  }

  /// A member was removed or left. Updates every member list of THIS group:
  /// the chat (header count, @mention list, attendance) right away, and the
  /// group info / members screen if open (quiet reload). Idempotent.
  void _onMemberRemoved(Map<String, dynamic> data) {
    final eventGroupId = data['groupId'] ?? data['group_id'];
    if (eventGroupId == null || _isOtherGroup(eventGroupId)) return;
    final removedId =
        (data['userId'] ?? data['removedUserId'] ?? data['user_id'])?.toString();
    if (removedId == null || removedId.isEmpty) return;

    final before = groupMembers.length;
    groupMembers.removeWhere((m) => m.userId?.toString() == removedId);
    groupMembers.refresh();
    if (kDebugMode) {
      debugPrint('[GC] member_removed group=$eventGroupId user=$removedId '
          'members $before -> ${groupMembers.length}'); // TODO(gc-diagnostics)
    }

    final me = Global.storageServices.get(PrefConst.userId)?.toString();
    if (removedId == me) {
      // No "you're no longer a member" UI exists in the app (not added).
      return;
    }

    if (Get.isRegistered<GroupProfileDetailsController>()) {
      Get.find<GroupProfileDetailsController>()
          .fetchProfileDetails(groupId, silent: true);
    }
    if (Get.isRegistered<MemberController>()) {
      Get.find<MemberController>().reloadIfShowing(groupId);
    }
  }

  void _updateGroupTypingText() {
    final count = groupTypingUsers.length;
    if (count == 0) {
      groupTypingText.value = "";
      groupTypingUser.value = "";
    } else if (count == 1) {
      final name = groupTypingUsers.values.first;
      groupTypingText.value = "$name is typing...";
      groupTypingUser.value = name;
    } else if (count == 2) {
      final names = groupTypingUsers.values.toList();
      groupTypingText.value = "${names[0]}, ${names[1]} are typing...";
      groupTypingUser.value = "${names[0]}, ${names[1]}";
    } else {
      groupTypingText.value = "$count people are typing...";
      groupTypingUser.value = "$count people";
    }
  }

  void onInputTextChanged(String text) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
    final currentUserName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? "Someone";

    if (currentUserId.isEmpty) return;

    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      final now = DateTime.now();
      // Throttle: emit immediately, then re-emit at most once every 2.5 seconds while typing continues
      if (_lastGroupTypingEmitTime == null ||
          now.difference(_lastGroupTypingEmitTime!).inMilliseconds >= 2500) {
        _lastGroupTypingEmitTime = now;
        socketService.sendGroupTyping(
          groupId: groupId,
          userId: currentUserId,
          userName: currentUserName,
        );
      }

      // Debounce: reset inactivity timer. After 2.5s without typing, emit stop typing
      _groupTypingDebounceTimer?.cancel();
      _groupTypingDebounceTimer = Timer(const Duration(milliseconds: 2500), () {
        _sendGroupStopTypingNow();
      });
    } else {
      _sendGroupStopTypingNow();
    }
  }

  void _sendGroupStopTypingNow() {
    _groupTypingDebounceTimer?.cancel();
    _lastGroupTypingEmitTime = null;
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
    final currentUserName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? "Someone";
    if (currentUserId.isNotEmpty) {
      socketService.sendGroupStopTyping(
        groupId: groupId,
        userId: currentUserId,
        userName: currentUserName,
      );
    }
  }

  void onInputFocusLost() {
    _sendGroupStopTypingNow();
  }

  Future<void> addVideos(List<String> paths) async {
    for (final path in paths) {
      await addVideo(path);
    }
  }

  Future<void> addVideo(String path) async {
    videoPaths.add(path);
    videoThumbnails.add(null);
    videoDurations.add('');

    final index = videoPaths.length - 1;

    try {
      final thumb = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 80,
      );

      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final duration = controller.value.duration;
      final durationStr = formatDuration(duration);
      await controller.dispose();

      if (index < videoThumbnails.length) {
        videoThumbnails[index] = thumb;
        videoDurations[index] = durationStr;
        videoThumbnails.refresh();
        videoDurations.refresh();
      }
    } catch (e) {
      AppLog.d("Video preview error: $e");
    }
  }

  void removeVideo(int index) {
    if (index < videoPaths.length) videoPaths.removeAt(index);
    if (index < videoThumbnails.length) videoThumbnails.removeAt(index);
    if (index < videoDurations.length) videoDurations.removeAt(index);
  }

  void clearVideos() {
    videoPaths.clear();
    videoThumbnails.clear();
    videoDurations.clear();
  }

  Future<bool> uploadVideoAtIndex(
    String path,
    String caption,
    int index,
  ) async {
    try {
      final thumbnailPath = await generateThumbnailFile(path);

      if (thumbnailPath == null) {
        return false;
      }

      var result = await MessageRepo.uploadChatVideo(
        videoPath: path,
        thumbnailPath: thumbnailPath,
        onSendProgress: (sent, total) {
          if (total > 0) {
            videoUploadProgress[index] = sent / total;
            videoUploadProgress.refresh();
          }
        },
      );

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          messageType: "video",
          content:
              "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
        return true;
      }
      return false;
    } catch (e) {
      log("Group upload error: $e");
      return false;
    }
  }

  void _addOptimisticMessage({
    required String clientMessageId,
    required String messageType,
    required String content,
    String? caption,
    List<String>? images,
    List<Map<String, dynamic>>? videos,
    Map<String, dynamic>? locationMeta,
    Map<String, dynamic>? contactMeta,
    dynamic duration,
    dynamic replyId,
    String? replyMessage,
    String? replyType,
    String? replySender,
  }) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();
    final currentUserName =
        Global.storageServices.get(PrefConst.userName)?.toString();
    final currentUserAvatar =
        Global.storageServices.get(PrefConst.profileImage)?.toString();

    final msg = MessageData(
      clientMessageId: clientMessageId,
      senderId: currentUserId,
      groupId: groupId,
      receiverId: groupId,
      messageType: messageType,
      content: content,
      caption: caption,
      images: images,
      videos: videos?.map((v) => MessageVideo.fromJson(v)).toList(),
      locationMeta: locationMeta,
      contactMeta: contactMeta,
      duration: duration,
      replyId: replyId,
      replyMessage: replyMessage,
      replyType: replyType,
      replySenderName: replySender,
      senderName: currentUserName ?? "You",
      senderImage: currentUserAvatar,
      timestamp: DateTime.now().toIso8601String(),
      isDelivered: false,
    );

    _messages.add(msg);
    updateMessageStream();
    rtModel('group optimistic', msg,
        extra: 'listLength=${_messages.length}'); // TODO(rt-diagnostics)
    scrollToBottom();
  }

  Future<void> sendMessage({
    required TextEditingController textController,
  }) async {
    if (isSending.value) return;
    if (_blockIfDeactivated()) return;
    _sendGroupStopTypingNow();
    isSending.value = true;
    var keepDraft = false;

    try {
      final text = textController.text.trim();

      final bool hasImages = imagePaths.isNotEmpty;
      final bool hasVideos = videoPaths.isNotEmpty;
      final bool hasDocument = documentPath.value.isNotEmpty;
      final bool hasMedia = hasImages || hasVideos || hasDocument;

      final bool shouldSendMixedMedia =
          (hasImages && hasVideos) || videoPaths.length > 1;

      if (shouldSendMixedMedia) {
        final imagesCopy = List<File>.from(imagePaths);
        final videosCopy = List<String>.from(videoPaths);
        final uploadedImages = <String>[];
        final uploadedVideos = <Map<String, dynamic>>[];
        final successfulVideoIndexes = <int>[];

        for (final image in imagesCopy) {
          try {
            final result = await MessageRepo.uploadChatImage(image);

            if (result.status == true && result.filename != null) {
              uploadedImages.add(result.filename!);
            } else {
              CommonDialog.errorMessage(
                "Failed to upload ${image.path}",
              );
            }
          } catch (e) {
            log("GROUP IMAGE UPLOAD ERROR => $e");
            CommonDialog.errorMessage(
              "Failed to upload ${image.path}",
            );
          }
        }

        for (int i = 0; i < videosCopy.length; i++) {
          final path = videosCopy[i];
          final currentIndex = videoPaths.indexOf(path);

          if (currentIndex == -1) continue;

          uploadingVideoIndexes.add(currentIndex);
          uploadingVideoIndexes.refresh();

          try {
            final thumbnailPath = await generateThumbnailFile(path);

            if (thumbnailPath == null) continue;

            final result = await MessageRepo.uploadChatVideo(
              videoPath: path,
              thumbnailPath: thumbnailPath,
              onSendProgress: (sent, total) {
                if (total > 0) {
                  videoUploadProgress[currentIndex] = sent / total;
                  videoUploadProgress.refresh();
                }
              },
            );

            if (result.status == true &&
                result.videoUrl != null &&
                result.videoUrl.toString().isNotEmpty) {
              uploadedVideos.add({
                "videoUrl": result.videoUrl,
                "thumbnail": result.thumbnail,
                "duration": result.duration,
              });

              successfulVideoIndexes.add(currentIndex);
            } else {
              CommonDialog.errorMessage(
                "Failed to upload video",
              );
            }
          } catch (e) {
            log("GROUP VIDEO UPLOAD ERROR => $e");
            CommonDialog.errorMessage(
              "Failed to upload video",
            );
          } finally {
            uploadingVideoIndexes.remove(currentIndex);
            videoUploadProgress.remove(currentIndex);
          }
        }

        if (uploadedImages.isNotEmpty || uploadedVideos.isNotEmpty) {
          final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
          _addOptimisticMessage(
            clientMessageId: clientMsgId,
            messageType: "media",
            content: "",
            images: uploadedImages,
            videos: uploadedVideos,
            caption: text,
            replyId: replyMessage.value?.id,
            replyMessage: replyMessage.value?.content,
            replyType: replyMessage.value?.messageType,
            replySender: replyMessage.value?.senderName,
          );

          socketService.sendGroupMessage(
            groupId: groupId,
            content: "",
            messageType: "media",
            clientMessageId: clientMsgId,
            images: uploadedImages,
            videos: uploadedVideos,
            caption: text,
            replyId: replyMessage.value?.id,
            replyMessage: replyMessage.value?.content,
            replyType: replyMessage.value?.messageType,
            replySender: replyMessage.value?.senderName,
          );

          clearReply();

          imagePaths.clear();

          successfulVideoIndexes.sort((a, b) => b.compareTo(a));

          for (final index in successfulVideoIndexes) {
            if (index < videoPaths.length) {
              removeVideo(index);
            }
          }
        }
      } else {
        if (imagePaths.isNotEmpty) {
          final imagesCopy = List<File>.from(imagePaths);
          final uploadedImages = <String>[];

          for (final image in imagesCopy) {
            try {
              final result = await MessageRepo.uploadChatImage(image);

              if (result.status == true && result.filename != null) {
                uploadedImages.add(result.filename!);
              } else {
                CommonDialog.errorMessage(
                  "Failed to upload ${image.path}",
                );
              }
            } catch (e) {
              log("GROUP IMAGE UPLOAD ERROR => $e");
              CommonDialog.errorMessage(
                "Failed to upload ${image.path}",
              );
            }
          }

          if (uploadedImages.isNotEmpty) {
            final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
            _addOptimisticMessage(
              clientMessageId: clientMsgId,
              messageType: "image",
              content: "",
              images: uploadedImages,
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );

            socketService.sendGroupMessage(
              groupId: groupId,
              content: "",
              messageType: "image",
              clientMessageId: clientMsgId,
              images: uploadedImages,
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );

            clearReply();
            imagePaths.clear();
          } else {
            // Every upload failed: keep the images and the caption.
            keepDraft = true;
          }
        }

        if (videoPaths.isNotEmpty) {
          final videoPath = videoPaths.first;
          final currentIndex = videoPaths.indexOf(videoPath);

          if (currentIndex != -1) {
            uploadingVideoIndexes.add(currentIndex);
            uploadingVideoIndexes.refresh();

            try {
              final success = await uploadVideoAtIndex(
                videoPath,
                text,
                currentIndex,
              );

              if (success) {
                final index = videoPaths.indexOf(videoPath);

                if (index != -1) {
                  removeVideo(index);
                }

                clearReply();
              }
            } finally {
              uploadingVideoIndexes.remove(currentIndex);
              videoUploadProgress.remove(currentIndex);
            }
          }
        }
      }

      if (documentPath.value.isNotEmpty) {
        await uploadDocument(documentPath.value, text);
        documentPath.value = "";
      }

      if (!hasMedia && text.isNotEmpty) {
        final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
        _addOptimisticMessage(
          clientMessageId: clientMsgId,
          messageType: "text",
          content: text,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        socketService.sendGroupMessage(
          groupId: groupId,
          content: text,
          messageType: "text",
          clientMessageId: clientMsgId,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }

      if (!keepDraft) {
        textController.clear();
        messageText.value = "";
        clearReply();
      }
      scrollToBottom();
    } catch (e) {
      log("GROUP SEND ERROR => $e");
    } finally {
      isSending.value = false;
    }
  }

  /// Called after POST /attendance/create succeeds. The backend broadcasts the
  /// attendance message over the socket; this adds it locally in case the
  /// broadcast doesn't reach the sender (duplicates are skipped by id).
  /// Called with the create-poll response ({pollId, messageId, message}).
  /// The backend also emits `attendance:created`; duplicates are skipped by id.
  void addCreatedAttendanceMessage(Map<String, dynamic> data) {
    final message = data["message"] is Map
        ? Map<String, dynamic>.from(data["message"])
        : <String, dynamic>{"id": data["messageId"]};
    final poll = data["poll"] is Map
        ? Map<String, dynamic>.from(data["poll"])
        : null;
    message["id"] ??= data["messageId"] ?? poll?["messageId"];
    message["pollId"] ??= data["pollId"] ?? poll?["pollId"] ?? poll?["id"];
    if (poll != null) message["attendance"] ??= poll;
    message["content"] ??= jsonEncode({
      "attendancePollId": message["pollId"],
      "title": poll?["title"],
      "eventDate": poll?["eventDate"],
    });
    message["timestamp"] ??= poll?["createdAt"];
    message["senderId"] ??=
        Global.storageServices.get(PrefConst.userId)?.toString();
    message["senderName"] ??=
        Global.storageServices.get(PrefConst.userName)?.toString();
    _insertAttendanceMessage(message);
  }

  void _insertAttendanceMessage(Map<String, dynamic> raw) {
    try {
      final msg = MessageData.fromJson(raw);
      msg.messageType = "attendance";
      if (msg.id == null) return;
      if (_messages.any((m) => m.id == msg.id)) return;

      final isMine = msg.senderId?.toString() ==
          Global.storageServices.get(PrefConst.userId)?.toString();
      final wasAtBottom = isUserAtBottom();
      _messages.add(msg);
      updateMessageStream();
      if (!isMine) _scheduleMarkGroupSeen();
      if (isMine || wasAtBottom) {
        scrollToBottom();
      } else {
        unreadBelowCount.value++;
        showScrollToBottom.value = true;
      }
    } catch (e) {
      log("ADD ATTENDANCE MESSAGE ERROR: $e");
    }
  }

  void _onAttendanceEvent(String event, dynamic data) {
    if (data is! Map) return;
    final poll = data["poll"];
    final eventGroupId = data["groupId"] ??
        (poll is Map ? poll["groupId"] : null) ??
        (data["message"] is Map ? data["message"]["groupId"] : null);
    if (_isOtherGroup(eventGroupId)) return;

    final message =
        AttendanceController.instance.handleSocketEvent(event, data);

    if (event == "attendance:created" && message != null) {
      if (poll is Map) {
        message["attendance"] ??= poll;
        message["pollId"] ??= poll["id"];
      }
      _insertAttendanceMessage(message);
    } else if (event == "attendance:deleted") {
      final pollId = int.tryParse(data["pollId"]?.toString() ?? "");
      if (pollId != null) markAttendanceDeleted(pollId);
    }
  }

  /// Shows a deleted poll's message as deleted (existing deleted-message UI).
  void markAttendanceDeleted(int pollId) {
    var changed = false;
    for (final msg in _messages) {
      if (msg.messageType == "attendance" &&
          _pollIdOf(msg)?.toString() == pollId.toString()) {
        msg.messageType = "text";
        msg.content = "This message was deleted";
        msg.attendance = null;
        msg.isDeleted = true;
        changed = true;
      }
    }
    if (changed) updateMessageStream();
  }

  dynamic _pollIdOf(MessageData msg) =>
      msg.attendancePollId ??
      msg.attendance?["id"] ??
      msg.attendance?["pollId"] ??
      (msg.attendance?["poll"] is Map ? msg.attendance!["poll"]["id"] : null);

  List<int> _visibleAttendancePollIds() => _messages
      .where((m) => m.messageType == "attendance")
      .map((m) => int.tryParse(_pollIdOf(m)?.toString() ?? ""))
      .whereType<int>()
      .toList();

  Future<void> uploadAudio(String path) async {
    if (_blockIfDeactivated()) return;
    try {
      var result = await MessageRepo.uploadChatAudio(path);

      if (result.status == true && (result.filename ?? "").isNotEmpty) {
        final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
        final duration = result.duration;

        _addOptimisticMessage(
          clientMessageId: clientMsgId,
          messageType: "audio",
          content: result.filename!,
          duration: duration,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        socketService.sendGroupMessage(
          groupId: groupId,
          content: result.filename!,
          messageType: "audio",
          clientMessageId: clientMsgId,
          duration: duration,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        clearReply();
      }
    } catch (e) {
      log(
        "GROUP AUDIO ERROR => $e",
      );
    }
  }

  Future<void> uploadVideo(String path, String caption) async {
    if (_blockIfDeactivated()) return;
    try {
      isUploadingVideo.value = true;

      final thumbnailPath = await generateThumbnailFile(path);

      if (thumbnailPath == null) {
        return;
      }

      var result = await MessageRepo.uploadChatVideo(
        videoPath: path,
        thumbnailPath: thumbnailPath,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (result.status == true) {
        final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
        final content =
            "${result.videoUrl}||${result.thumbnail}||${result.duration}";

        _addOptimisticMessage(
          clientMessageId: clientMsgId,
          messageType: "video",
          content: content,
          caption: caption,
          duration: result.duration,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        socketService.sendGroupMessage(
          groupId: groupId,
          messageType: "video",
          content: content,
          clientMessageId: clientMsgId,
          caption: caption,
          duration: result.duration,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }
    } catch (e) {
      log("GROUP AUDIO ERROR => $e");
    } finally {
      isUploadingVideo.value = false;
      clearReply();
    }
  }

  Future<void> uploadDocument(
    String path,
    String caption,
  ) async {
    if (_blockIfDeactivated()) return;
    try {
      var result = await MessageRepo.uploadChatDocument(path);

      if (result.status == true) {
        final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
        final content =
            "${result.filename}||${result.originalName ?? path.split(RegExp(r'[\\/]')).last}";

        _addOptimisticMessage(
          clientMessageId: clientMsgId,
          messageType: "document",
          content: content,
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        socketService.sendGroupMessage(
          groupId: groupId,
          content: content,
          messageType: "document",
          clientMessageId: clientMsgId,
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        clearReply();
      }
    } catch (e) {
      log(
        "GROUP Video ERROR => $e",
      );
    }
  }

  Future<void> sendLocation({
    required LocationMessage location,
  }) async {
    if (_blockIfDeactivated()) return;
    try {
      final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
      final locationMeta = {
        "latitude": location.latitude,
        "longitude": location.longitude,
        "name": location.locationName,
        "address": location.locationName,
        "locationName": location.locationName,
      };

      _addOptimisticMessage(
        clientMessageId: clientMsgId,
        messageType: "location",
        content: location.toContent(),
        locationMeta: locationMeta,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      socketService.sendGroupMessage(
        groupId: groupId,
        content: location.toContent(),
        messageType: "location",
        clientMessageId: clientMsgId,
        locationMeta: locationMeta,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      clearReply();

      scrollToBottom();
    } catch (e) {
      log("LOCATION SEND ERROR => $e");
    }
  }

  Future<void> sendContact({
    required ContactMessage contact,
  }) async {
    if (_blockIfDeactivated()) return;
    try {
      final clientMsgId = 'c_${DateTime.now().microsecondsSinceEpoch}';
      final contactMeta = {
        "name": contact.name,
        "phone": contact.phone,
      };

      _addOptimisticMessage(
        clientMessageId: clientMsgId,
        messageType: "contact",
        content: contact.toContent(),
        contactMeta: contactMeta,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      socketService.sendGroupMessage(
        groupId: groupId,
        content: contact.toContent(),
        messageType: "contact",
        clientMessageId: clientMsgId,
        contactMeta: contactMeta,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );

      clearReply();

      scrollToBottom();
    } catch (e) {
      log("CONTACT SEND ERROR => $e");
    }
  }

  Future<void> deleteMessage({
    required int messageId,
    required String deleteType,
  }) async {
    final userId =
    Global.storageServices.get(PrefConst.userId).toString();

    AppLog.d("========== DELETE MESSAGE START ==========");
    AppLog.d("DELETE messageId: $messageId");
    AppLog.d("DELETE userId: $userId");
    AppLog.d("DELETE deleteType: $deleteType");
    AppLog.d("DELETE groupId: $groupId");

    AppLog.d(
      "DELETE SOCKET CONNECTED: ${socketService.isSocketConnected}",
    );

    socketService.deleteMessage(
      messageId: messageId,
      userId: userId,
      deleteType: deleteType,
    );

    AppLog.d("DELETE MESSAGE EMIT CALLED");
    AppLog.d("==========================================");
  }

  Future<void> _resolveForwardedGroupMessageContent(MessageData target) async {
    try {
      final history = await MessageRepo.groupMessageHistory(
        groupId: groupId,
        page: 1,
        limit: 10,
      );

      if (history.status == true && history.messageData != null) {
        final found = history.messageData!.firstWhereOrNull(
          (m) =>
              (target.id != null && m.id == target.id) ||
              (target.forwardedFromMessageId != null &&
                  m.id?.toString() == target.forwardedFromMessageId?.toString()),
        );

        if (found != null) {
          final idx = _messages.indexWhere((m) => m.id == target.id);
          if (idx != -1) {
            final m = _messages[idx];
            m.content = found.content ?? m.content;
            m.caption = found.caption ?? m.caption;
            m.images = found.images ?? m.images;
            m.videos = found.videos ?? m.videos;
            m.messageType = found.messageType ?? m.messageType;
            m.thumbnail = found.thumbnail ?? m.thumbnail;
            updateMessageStream();
          }
        }
      }
    } catch (e) {
      AppLog.d("Error resolving forwarded group message content: $e");
    }
  }

  Future<void> getGroupMessages() async {
    if (_messages.isEmpty) isLoading.value = true;
    historyLoadFailed.value = false;
    _historyRequestInFlight = true;
    _pager.reset();
    hasMoreOlderMessages.value = true;

    try {
      final result = await MessageRepo.groupMessageHistory(
        groupId: groupId,
        page: 1,
        limit: ChatScreenRules.pageSize,
      );

      if (result.status == true) {
        final messages = result.messageData ?? [];

        // Merge, don't replace: socket messages that arrived before this
        // response survive, duplicates are dropped by id, order by time.
        final merged = ChatScreenRules.merge(_messages, messages);
        _messages
          ..clear()
          ..addAll(merged.messages);
        _pager.complete(
          page: 1,
          receivedCount: messages.length,
          hasNextPage: result.pagination?.hasNextPage,
        );
        groupCurrentPage.value = 1;
        hasMoreOlderMessages.value = _pager.hasMore;
        _historyLoaded = true;
        for (final m in _messages) {
          rtModel('group history', m); // TODO(rt-diagnostics)
        }

        final pinnedId = result.pinnedMessageId;

        if (pinnedId != null) {
          final pinned = _messages.firstWhereOrNull(
            (message) => message.id == pinnedId,
          );

          if (pinned != null) {
            pinnedMessage.value = pinned;
            showPinnedBanner.value = true;
          } else {
            pinnedMessage.value = null;
            showPinnedBanner.value = false;
          }
        } else {
          pinnedMessage.value = null;
          showPinnedBanner.value = false;
        }

        updateMessageStream();

        scrollToBottom(instant: true); // Instantly jumps to the latest message
      } else {
        CommonDialog.errorMessage(result.message);
        _pager.fail();
        // Keep whatever is shown; only an empty chat gets the Retry state.
        if (_messages.isEmpty) historyLoadFailed.value = true;
        updateMessageStream();
      }
    } catch (e) {
      log("GROUP HISTORY ERROR => $e");
      _pager.fail();
      if (_messages.isEmpty) historyLoadFailed.value = true;
      updateMessageStream();
    } finally {
      _historyRequestInFlight = false;
      isLoading.value = false;
    }
  }

  /// "Retry" on the load-error state.
  Future<void> retryLoadHistory() => getGroupMessages();

  Future getGroupMembers() async {
    try {
      isLoadingMembers.value = true;

      var result = await MessageRepo.getGroupMembers(
        groupId: groupId,
      );

      if (result.status == true) {
        groupMembers.value = result.locations ?? [];

        // Messages that arrived before the member list did: add names now.
        var filled = false;
        for (final m in _messages) {
          if (fillSenderFromMembers(m)) filled = true;
        }
        if (filled) updateMessageStream();

        final currentUserId =
            Global.storageServices.get(PrefConst.userId).toString();

        // Default
        isCreator.value = false;

        // Check current logged-in user
        for (final member in groupMembers) {
          if (member.userId.toString() == currentUserId) {
            isCreator.value = member.isCreator == true;
            break;
          }
        }
      }
    } catch (e) {
      log(
        "GROUP MEMBERS ERROR => $e",
      );
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void scrollToBottom({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomExecution(instant: instant);
    });
  }

  void _scrollToBottomExecution({bool instant = false, int retryCount = 0}) {
    if (_messages.isEmpty) return;

    if (itemScrollController.isAttached) {
      try {
        final targetIndex = _messages.length - 1;
        if (targetIndex < 0) return;

        if (instant) {
          itemScrollController.jumpTo(
            index: targetIndex,
          );
        } else {
          itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      } catch (e) {
        log("Scroll execution error: $e");
        if (retryCount < 6) {
          Future.delayed(const Duration(milliseconds: 60), () {
            _scrollToBottomExecution(instant: instant, retryCount: retryCount + 1);
          });
        }
      }
    } else if (retryCount < 10) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToBottomExecution(instant: instant, retryCount: retryCount + 1);
      });
    }
  }

  bool isUserAtBottom() {
    if (_messages.isEmpty) return true;

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return true;

    final visible = positions
        .where((e) => e.itemTrailingEdge > 0 && e.itemLeadingEdge < 1.0)
        .toList();

    if (visible.isEmpty) return true;

    final maxVisible =
        visible.map((e) => e.index).reduce((a, b) => a > b ? a : b);

    return maxVisible >= _messages.length - 2;
  }

  void _updateScrollBottomState() {
    if (_messages.isEmpty) {
      if (showScrollToBottom.value) showScrollToBottom.value = false;
      if (unreadBelowCount.value != 0) unreadBelowCount.value = 0;
      _wasAtBottom = true;
      return;
    }

    final atBottom = isUserAtBottom();
    _wasAtBottom = atBottom;

    if (atBottom) {
      if (showScrollToBottom.value) showScrollToBottom.value = false;
      if (unreadBelowCount.value != 0) unreadBelowCount.value = 0;
    } else {
      if (!showScrollToBottom.value) showScrollToBottom.value = true;
    }
  }

  void handleBackPressed(BuildContext context) {
    // socketService.disconnectSocket();

    _messages.clear();

    messageText.value = "";

    imagePaths.clear();
    clearVideos();
    isSending.value = false;
    pinnedMessage.value = null;
    showPinnedBanner.value = false;

    Navigator.of(context).pop();
  }

  final FocusNode focusNode = FocusNode();

  final RxList<LocationData> filteredMembers = <LocationData>[].obs;
  final RxBool showMentionList = false.obs;
  RxInt? mentionStartIndex = RxInt(-1);

  void onTextChanged({
    required TextEditingController textController,
  }) {
    messageText.value = textController.text;
    handleMentionDetection(textController: textController);
  }

  void handleMentionDetection({
    required TextEditingController textController,
  }) {
    final text = textController.text;
    final cursorPos = textController.selection.baseOffset;

    if (cursorPos <= 0) {
      hideMentionList();
      return;
    }

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex == -1) {
      hideMentionList();
      return;
    }

    final wordAfterAt = textBeforeCursor.substring(lastAtIndex);
    if (wordAfterAt.contains(' ')) {
      hideMentionList();
      return;
    }

    mentionStartIndex!.value = lastAtIndex;
    final query = wordAfterAt.substring(1).toLowerCase().trim();

    filteredMembers.value = groupMembers
        .where((member) =>
            (member.name?.toLowerCase().contains(query) ?? false) ||
            (member.name?.toLowerCase().contains(query) ?? false))
        .toList();

    showMentionList.value = filteredMembers.isNotEmpty;
  }

  void insertMention({
    required dynamic member,
    required TextEditingController textController,
  }) {
    if (mentionStartIndex!.value < 0) return;

    final text = textController.text;
    final cursorPos = textController.selection.baseOffset;

    final displayName = (member.name ?? member.username ?? "User").toString();

    final start = mentionStartIndex!.value; // int
    final replacement = "@$displayName ";

    final newText = text.replaceRange(
      start,
      cursorPos,
      replacement,
    );

    textController.text = newText;

    final newCursorOffset = start + replacement.length;

    textController.selection = TextSelection.collapsed(
      offset: newCursorOffset,
    );

    hideMentionList();
    messageText.value = newText;
  }

  void hideMentionList() {
    showMentionList.value = false;
    filteredMembers.clear();
    mentionStartIndex!.value = -1;
  }

  void startSearch() {
    // The search field takes focus (keyboard): the emoji panel must not
    // stay open under it (e.g. Profile > Search with emoji open).
    showEmoji.value = false;
    isSearching.value = true;
    searchQuery.value = "";
    searchResultIds.clear();
    currentSearchIndex.value = -1;
  }

  void stopSearch() {
    // Closing search restores the normal composer: no emoji panel and no
    // search keyboard left behind.
    showEmoji.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
    isSearching.value = false;
    searchQuery.value = "";
    searchResultIds.clear();
    currentSearchIndex.value = -1;
    highlightedMessageId.value = -1;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.trim();
    searchResultIds.clear();
    currentSearchIndex.value = -1;
    highlightedMessageId.value = -1;

    if (searchQuery.value.isEmpty) return;

    final results = _messages
        .where((msg) =>
            msg.messageType == "text" &&
            (msg.content?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                false))
        .map((msg) => msg.id!)
        .toList();

    searchResultIds.value = results;

    if (results.isNotEmpty) {
      currentSearchIndex.value = results.length - 1;
      _scrollToSearchResult();
    }
  }

  void nextSearchResult() {
    if (searchResultIds.isEmpty) return;
    if (currentSearchIndex.value > 0) {
      currentSearchIndex.value--;
      _scrollToSearchResult();
    }
  }

  void previousSearchResult() {
    if (searchResultIds.isEmpty) return;
    if (currentSearchIndex.value < searchResultIds.length - 1) {
      currentSearchIndex.value++;
      _scrollToSearchResult();
    }
  }

  void _scrollToSearchResult() {
    final id = searchResultIds[currentSearchIndex.value];
    final index = _messages.indexWhere((e) => e.id == id);
    highlightedMessageId.value = id;
    if (index == -1) return;
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void pinMessage(MessageData message) {
    socketService.pinMessage(
      chatType: "group",
      groupId: groupId,
      messageId: message.id!,
      pinnedByName: Global.storageServices.get(PrefConst.userName) ?? "User",
    );
  }

  void unpinMessage() {
    socketService.unpinMessageEvent(
      chatType: "group",
      groupId: groupId,
    );
  }

  void scrollToPinnedMessage() {
    if (pinnedMessage.value == null) return;
    final msgId = pinnedMessage.value!.id;
    if (msgId == null) return;

    final index = _messages.indexWhere((e) => e.id == msgId);
    if (index == -1) return;

    highlightedMessageId.value = msgId;

    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      highlightedMessageId.value = -1;
    });
  }

  void _onScrollDateChanged() {
    if (messageData.isEmpty) return;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return;

    final visible = positions.where((e) => e.itemTrailingEdge > 0).toList();

    if (visible.isEmpty) return;

    visible.sort((a, b) => a.index.compareTo(b.index));

    final firstVisibleIndex = visible.first.index;

    if (firstVisibleIndex >= messageData.length) return;

    final newDate = formatDateHeader(
      messageData[firstVisibleIndex].timestamp ?? "",
    );

    if (floatingDate.value != newDate) {
      floatingDate.value = newDate;
    }

    if (!showFloatingDate.value) {
      showFloatingDate.value = true;
    }

    _floatingDateTimer?.cancel();

    _floatingDateTimer = Timer(
      const Duration(milliseconds: 800),
      () {
        showFloatingDate.value = false;
      },
    );
  }

  void startEditingMessage(MessageData message) {
    if (message.messageType?.toString() != "text") {
      return;
    }

    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    if (message.senderId.toString() != currentUserId) {
      return;
    }

    editingMessage.value = message;
  }

  void cancelEditingMessage() {
    editingMessage.value = null;
  }

  void updateEditedMessage({
    required String newText,
  }) {
    final message = editingMessage.value;

    if (message == null) return;

    final text = newText.trim();

    if (text.isEmpty) return;

    socketService.editMessage(
      messageId: message.id!,
      content: text,
      userId: Global.storageServices.get(PrefConst.userId).toString(),
    );

    editingMessage.value = null;
  }

  /// Returns true when the server cleared the chat (the profile then also
  /// drops its media list).
  Future<bool> clearGroupChat() async {
    try {
      final response = await MessageRepo.clearGroupChat(
        groupId: groupId,
      );

      if (response['status'] == true) {
        _messages.clear();

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();

        Utils().fluttertoast(
          response['message']?.toString() ??
              'Group chat cleared successfully',
        );
        _syncChatListPreview();
        return true;
      } else {
        Utils().fluttertoast(
          response['message']?.toString() ??
              'Failed to clear group chat',
        );
      }
    } catch (e) {
      log('Clear group chat error: $e');

      Utils().fluttertoast('Failed to clear group chat');
    }
    return false;
  }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        final bottomInset = views.first.viewInsets.bottom;
        final isKeyboardOpen = bottomInset > 0;
        if (isKeyboardOpen != _wasKeyboardOpen) {
          _wasKeyboardOpen = isKeyboardOpen;
          if (isKeyboardOpen) {
            // Keep latest messages visible if user was at the bottom
            if (_wasAtBottom) {
              scrollToBottom(instant: false);
            }
          }
        }
      }
    } catch (_) {}
  }

  // ---- Read receipts for messages arriving while the chat is open ----
  Timer? _markSeenTimer;
  bool _markSeenPending = false;

  /// Debounced `mark_seen` so a burst of messages sends one event. If the app
  /// is in the background, the read is sent when it comes back.
  void _scheduleMarkGroupSeen() {
    // The socket listener outlives this screen; a closed chat must never
    // mark messages read (the user is on another screen).
    if (isClosed) return;
    if (!ActiveChatTracker.isAppInForeground) {
      _markSeenPending = true;
      return;
    }
    _markSeenTimer?.cancel();
    _markSeenTimer =
        Timer(const Duration(milliseconds: 400), _markGroupSeenNow);
  }

  void _markGroupSeenNow() {
    if (isClosed) return;
    _emitGroupSeen();
  }

  void _emitGroupSeen() {
    _markSeenPending = false;
    final userId = Global.storageServices.get(PrefConst.userId)?.toString();
    if (userId == null || userId.isEmpty) return;
    socketService.markSeen(userId, groupId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _sendGroupStopTypingNow();
    }
    if (state == AppLifecycleState.resumed) {
      if (_markSeenPending) _markGroupSeenNow();
      // Messages may have arrived while the app was in the background.
      syncNewerMessages();
      // A removal missed while in the background: refetch members once.
      getGroupMembers();
    }
  }

  @override
  void onClose() {
    // Everything shown in this chat has been read: tell the server once more
    // (covers a debounce still pending) and clear the list badge locally.
    _markSeenTimer?.cancel();
    if (ActiveChatTracker.isAppInForeground) _emitGroupSeen();
    ActiveChatTracker.closeGroup(groupId);
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>()
          .clearUnreadForOpenedChat(isGroup: true, groupId: groupId);
    }
    _syncChatListPreview();
    _sendGroupStopTypingNow();
    for (final timer in _groupTypingUserTimers.values) {
      timer.cancel();
    }
    _groupTypingUserTimers.clear();
    groupTypingUsers.clear();
    socketService.stopListeningGroupTyping();
    // The /chat socket stays alive for the chat list; without this, every
    // reconnect would re-join this closed group and mark it seen.
    socketService.clearActiveGroup(groupId);
    // Drop this screen's receive/edit/delete/pin/seen listeners unless a
    // newer group screen already replaced them.
    socketService.releaseGroupChatEvents(this);
    socketService.stopListeningAttendanceEvents(_attendanceListenerToken);
    ChatTranslationService.instance.resetVisibility();
    ChatTranslationService.instance.stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions.removeListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.removeListener(_updateScrollBottomState);
    itemPositionsListener.itemPositions.removeListener(_onScrollForOlderMessages);
    textEditingController.dispose();
    focusNode.dispose();
    _messageStreamController.close();
    _floatingDateTimer?.cancel();
    super.onClose();
  }

  void _onScrollForOlderMessages() {
    if (isLoadingOlderMessages.value) return;
    if (!hasMoreOlderMessages.value) return;
    if (isLoading.value) return;
    if (_messages.isEmpty) return;

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final visible =
        positions.where((position) => position.itemTrailingEdge > 0).toList();
    if (visible.isEmpty) return;

    visible.sort((a, b) => a.index.compareTo(b.index));
    final firstVisibleIndex = visible.first.index;

    if (firstVisibleIndex <= 2) {
      loadOlderGroupMessages();
    }
  }

  // ---------------------------------------------------------------------------
  // History paging and sync (rules in chat_screen_logic.dart)
  // ---------------------------------------------------------------------------

  final HistoryPager _pager = HistoryPager();
  bool _historyLoaded = false;
  bool _historyRequestInFlight = false;
  DateTime? _olderRetryAfter;

  /// True when the first load failed and nothing is shown: the list shows
  /// "Couldn't load messages" + Retry instead of "No messages here yet".
  final RxBool historyLoadFailed = false.obs;

  ItemPosition? _topAnchor() {
    final visible = itemPositionsListener.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return visible.isEmpty ? null : visible.first;
  }

  void _restoreAnchor(ItemPosition? anchor, int prepended) {
    if (anchor == null || prepended <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!itemScrollController.isAttached) return;
      itemScrollController.jumpTo(
        index: anchor.index + prepended,
        alignment: anchor.itemLeadingEdge,
      );
    });
  }

  /// Older page when the user reaches the top. One call at a time; stops
  /// when the API has no more; dedupes by id. The page counter advances
  /// even when a page held only duplicates (it used to stay put and refetch
  /// the same page forever once new messages had shifted the offsets).
  Future<void> loadOlderGroupMessages() async {
    if (_messages.isEmpty || !_historyLoaded) return;
    final retryAfter = _olderRetryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) return;

    final page = _pager.begin();
    if (page == null) return;

    isLoadingOlderMessages.value = true;
    final anchor = _topAnchor();

    try {
      log("OLDER GROUP MESSAGE API CALL => page=$page");
      final result = await MessageRepo.groupMessageHistory(
        groupId: groupId,
        page: page,
        limit: ChatScreenRules.pageSize,
      );
      if (isClosed) return;

      if (result.status != true) {
        _pager.fail();
        _olderRetryAfter = DateTime.now().add(const Duration(seconds: 3));
        return;
      }

      final older = result.messageData ?? [];
      final merged = ChatScreenRules.merge(_messages, older);
      _pager.complete(
        page: page,
        receivedCount: older.length,
        hasNextPage: result.pagination?.hasNextPage,
      );
      groupCurrentPage.value = _pager.lastLoadedPage;

      if (merged.added > 0) {
        _messages
          ..clear()
          ..addAll(merged.messages);
        updateMessageStream();
        _restoreAnchor(anchor, merged.prepended);
      }
    } catch (e) {
      log("Load Older Group Messages Error: $e");
      _pager.fail();
      _olderRetryAfter = DateTime.now().add(const Duration(seconds: 3));
    } finally {
      isLoadingOlderMessages.value = false;
      hasMoreOlderMessages.value = _pager.hasMore;
    }
  }

  /// After a socket reconnect or app resume: fetch the newest pages until
  /// they overlap what is loaded, so nothing sent meanwhile is missed.
  ///
  /// TODO(backend #6): replace with `after=<newest messageId>` once the API
  /// supports it; page 1..N is a stopgap.
  Future<void> syncNewerMessages() async {
    if (!_historyLoaded || _historyRequestInFlight || isClosed) return;
    _historyRequestInFlight = true;

    try {
      final wasAtBottom = isUserAtBottom();
      final currentUserId =
          Global.storageServices.get(PrefConst.userId)?.toString();
      var appended = 0;
      var appendedFromOthers = 0;

      for (var page = 1; page <= 5; page++) {
        final result = await MessageRepo.groupMessageHistory(
          groupId: groupId,
          page: page,
          limit: ChatScreenRules.pageSize,
        );
        if (isClosed || result.status != true) return;

        final batch = result.messageData ?? [];
        final before = _messages.map((m) => m.id?.toString()).toSet();
        final merged = ChatScreenRules.merge(_messages, batch);
        final overlapped = merged.added < batch.length;
        if (merged.added > 0) {
          appended += merged.added - merged.prepended;
          appendedFromOthers += batch
              .where((m) =>
                  !before.contains(m.id?.toString()) &&
                  m.senderId?.toString() != currentUserId)
              .length;
          _messages
            ..clear()
            ..addAll(merged.messages);
        }
        if (overlapped || batch.isEmpty || result.pagination?.hasNextPage == false) {
          break;
        }
      }

      if (appended > 0) {
        updateMessageStream();
        if (wasAtBottom) {
          scrollToBottom();
        } else {
          unreadBelowCount.value += appended;
          showScrollToBottom.value = true;
        }
        if (appendedFromOthers > 0) _scheduleMarkGroupSeen();
      }
    } catch (e) {
      log("Sync newer group messages error: $e");
    } finally {
      _historyRequestInFlight = false;
    }
  }

  /// Reply-jump to a message that is not loaded yet: page back until it is
  /// found (bounded). Returns its index, or -1.
  Future<int> _loadOlderUntilFound(int messageId) async {
    for (var i = 0; i < ChatScreenRules.maxReplyJumpPages; i++) {
      if (!_pager.hasMore) break;
      final before = _messages.length;
      await loadOlderGroupMessages();
      final index = _messages.indexWhere((e) => e.id == messageId);
      if (index != -1) return index;
      if (_messages.length == before && !_pager.hasMore) break;
    }
    return _messages.indexWhere((e) => e.id == messageId);
  }
}

typedef GroupChatController = GroupMessageController;
