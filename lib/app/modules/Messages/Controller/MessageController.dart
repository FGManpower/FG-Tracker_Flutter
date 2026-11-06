import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:fgtracker/app/Data/Services/call_service.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/modules/Track/Controller/GroupTrackController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../Data/Services/Tracking.dart';
import '../../../routes/app_pages.dart';
import '../../../Data/Services/Socket/Socket_Message_Services.dart';
import '../../../Data/Services/chat_translation_service.dart';
import '../../../Data/Services/active_chat_tracker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'chat_list_controller.dart';
import 'chat_screen_logic.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/util/rt_attachment_log.dart'; // TODO(rt-diagnostics)
void log(String message, {Object? error, StackTrace? stackTrace, String? name}) {
  if (kDebugMode) {
    developer.log(message, error: error, stackTrace: stackTrace, name: name ?? 'MessageController');
  }
}

class MessageController extends GetxController with WidgetsBindingObserver {
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

  void updateMessageStream() {
    if (_messageStreamController.isClosed) return;

    _messageStreamController.add(
      List.unmodifiable(_messages),
    );
  }

  List<MessageData> get messageData => _messages;
  RxList<File> imagePaths = <File>[].obs;
  RxList<String> videoPaths = <String>[].obs;
  RxString documentPath = "".obs;
  RxBool isSending = false.obs;
  RxString messageText = "".obs;
  final RxBool isUploadingVideo = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  late MemberData memberData;
  Map<String, dynamic>? arguments;
  RxBool isCreator = false.obs;
  final Rxn<MessageData> pinnedMessage = Rxn<MessageData>();
  final RxBool showPinnedBanner = true.obs;
  RxList<Uint8List?> videoThumbnails = <Uint8List?>[].obs;
  RxList<String> videoDurations = <String>[].obs;
  Rx<MessageData?> replyMessage = Rx<MessageData?>(null);
  RxInt highlightedMessageId = (-1).obs;
  final RxBool showEmoji = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = "".obs;
  final RxList<int> searchResultIds = <int>[].obs;
  final RxInt currentSearchIndex = (-1).obs;
  final RxSet<int> uploadingVideoIndexes = <int>{}.obs;
  final RxMap<int, double> videoUploadProgress = <int, double>{}.obs;
  final RxString floatingDate = "".obs;
  final RxBool showFloatingDate = false.obs;
  final Rxn<MessageData> editingMessage = Rxn<MessageData>();
  final RxBool isBlocking = false.obs;
  final RxBool isUnblocking = false.obs;
  final RxBool isBlocked = false.obs;
  final RxBool blockedByMe = false.obs;
  RxBool isPeerOnline = false.obs;
  // Blank until chat history API returns, so "Offline" doesn't flash first
  final RxString peerLastSeen = "".obs;
  final RxBool isPeerTyping = false.obs;
  DateTime? _lastTypingEmitTime;
  Timer? _typingDebounceTimer;
  Timer? _peerTypingResetTimer;
  RxString privateChatId = "".obs;

  RxInt privateCurrentPage = 1.obs;
  RxBool isLoadingOlderMessages = false.obs;
  RxBool hasMoreOlderMessages = true.obs;
  RxBool isLoadingInitialMessages = false.obs;

  Timer? _floatingDateTimer;


  @override
  void onInit() {
    super.onInit();
    arguments = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : null;

    log("CHAT ROUTE ARGUMENTS => $arguments");
    log("CHAT ROUTE chatId => ${arguments?['chatId']}");
    log("CHAT ROUTE userData => ${arguments?['userData']}");

    log("========== CHAT DEBUG 1: onInit START ==========");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("========== CHAT DEBUG 2: POST FRAME CALLBACK ==========");

      if (!isClosed) {
        log("========== CHAT DEBUG 3: RESET VISIBILITY START ==========");

        try {
          ChatTranslationService.instance.resetVisibility();
          log("========== CHAT DEBUG 4: RESET VISIBILITY SUCCESS ==========");
        } catch (e, stackTrace) {
          log("CHAT DEBUG: RESET VISIBILITY ERROR => $e");
          log("$stackTrace");
        }
      } else {
        log("CHAT DEBUG: Controller already closed");
      }
    });

    log("========== CHAT DEBUG 5: ADD OBSERVER ==========");

    WidgetsBinding.instance.addObserver(this);

    log("========== CHAT DEBUG 6: GET ARGUMENTS ==========");
    log("CHAT ARGUMENTS => $arguments");

    memberData = arguments?['userData'];

    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().clearManualUnreadForPrivate(
        userId: memberData.userId,
        chatId: arguments?['chatId'],
      );
    }

    log("========== CHAT DEBUG 7: MEMBER DATA ==========");
    log("MEMBER DATA => $memberData");
    log("MEMBER USER ID => ${memberData.userId}");

    log("========== CHAT DEBUG 8: BEFORE INITIALIZE ==========");

    try {
      _initializeChat();

      log("========== CHAT DEBUG 9: INITIALIZE CALLED ==========");
    } catch (e, stackTrace) {
      log("CHAT DEBUG: INITIALIZE ERROR => $e");
      log("$stackTrace");
    }

    log("========== CHAT DEBUG 10: ADD SCROLL LISTENERS ==========");

    itemPositionsListener.itemPositions.addListener(
      _onScrollDateChanged,
    );

    itemPositionsListener.itemPositions.addListener(
      _onScrollForOlderMessages,
    );

    itemPositionsListener.itemPositions.addListener(
      _updateScrollBottomState,
    );

    log("========== CHAT DEBUG 11: onInit COMPLETE ==========");
  }

  // ---- Read state for messages arriving while the private chat is open ----
  String? _privatePeerId;
  Timer? _markReadTimer;
  bool _markReadPending = false;

  /// Debounced chat-list read (`mark_private_chat_read`), so a burst of
  /// messages sends one event. In the background it waits for resume.
  void _scheduleMarkPrivateRead() {
    if (isClosed || _privatePeerId == null) return;
    if (!ActiveChatTracker.isAppInForeground) {
      _markReadPending = true;
      return;
    }
    _markReadTimer?.cancel();
    _markReadTimer = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) _emitPrivateRead();
    });
  }

  void _emitPrivateRead() {
    _markReadPending = false;
    final peerId = _privatePeerId;
    final chatId = privateChatId.value;
    final userId = Global.storageServices.get(PrefConst.userId)?.toString();
    if (peerId == null || chatId.isEmpty || userId == null) return;
    socketService.markPrivateSeen(
      chatId: chatId,
      userId: userId,
      otherUserId: peerId,
    );
    socketService.markPrivateChatRead(userId: userId, chatId: chatId);
  }

  @override
  void onClose() {
    // Everything shown in this chat has been read: send it once more (covers
    // a pending debounce) and clear the list badge locally.
    _markReadTimer?.cancel();
    _joinTimeout?.cancel();
    final peerId = _privatePeerId;
    if (peerId != null) {
      if (ActiveChatTracker.isAppInForeground) _emitPrivateRead();
      ActiveChatTracker.closePrivate(peerId);
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().clearUnreadForOpenedChat(
          chatId: privateChatId.value,
          peerUserId: peerId,
        );
      }
      _syncChatListPreview();
    }
    ChatTranslationService.instance.resetVisibility();
    ChatTranslationService.instance.stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions.removeListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.removeListener(_onScrollForOlderMessages);
    itemPositionsListener.itemPositions.removeListener(_updateScrollBottomState);
    textEditingController.dispose();
    _messageStreamController.close();
    _floatingDateTimer?.cancel();
    _sendPrivateStopTypingNow();
    _peerTypingResetTimer?.cancel();
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString();
    final receiverId = memberData.userId?.toString();
    if (currentUserId != null && receiverId != null) {
      socketService.leavePrivateChat(
        userId: currentUserId,
        receiverId: receiverId,
      );
    }
    socketService.releasePrivateChatEvents(this);
    super.onClose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _sendPrivateStopTypingNow();
    }
    if (state == AppLifecycleState.resumed) {
      if (_markReadPending) _emitPrivateRead();
      // Messages may have arrived while the app was in the background.
      syncNewerMessages();
      final picker = ImagePicker();
      try {
        final LostDataResponse response = await picker.retrieveLostData();
        if (!response.isEmpty && response.files != null) {
          // Android may kill the activity while the picker is open; restore
          // what was picked as the right kind (it used to always be video).
          for (final picked in response.files!) {
            final file = File(picked.path);
            if (!await file.exists()) continue;
            final isVideo = response.type == RetrieveType.video ||
                RegExp(r'\.(mp4|mov|mkv|3gp|webm|avi)$', caseSensitive: false)
                    .hasMatch(file.path);
            if (isVideo) {
              await addVideo(file.path);
            } else if (!imagePaths.any((f) => f.path == file.path)) {
              imagePaths.add(file);
            }
          }
        } else if (response.exception != null) {
          AppLog.d("Lost data exception: ${response.exception}");
        }
      } catch (e) {
        AppLog.d("retrieveLostData error: $e");
      }
    }
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

  void toggleEmoji() {
    showEmoji.toggle();
  }

  void hideEmoji() {
    showEmoji.value = false;
  }

  void onInputTextChanged(String text) {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
    final currentUserName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? "Someone";
    final receiverId = memberData.userId?.toString() ?? "";

    if (receiverId.isEmpty || currentUserId.isEmpty) return;

    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      final now = DateTime.now();
      // Throttle: emit immediately, then re-emit at most once every 2.5 seconds while typing continues
      if (_lastTypingEmitTime == null ||
          now.difference(_lastTypingEmitTime!).inMilliseconds >= 2500) {
        _lastTypingEmitTime = now;
        socketService.sendPrivateTyping(
          chatId: privateChatId.value,
          userId: currentUserId,
          otherUserId: receiverId,
          userName: currentUserName,
        );
      }

      // Debounce: reset inactivity timer. After 2.5s without typing, emit stop typing
      _typingDebounceTimer?.cancel();
      _typingDebounceTimer = Timer(const Duration(milliseconds: 2500), () {
        _sendPrivateStopTypingNow();
      });
    } else {
      _sendPrivateStopTypingNow();
    }
  }

  void _sendPrivateStopTypingNow() {
    _typingDebounceTimer?.cancel();
    _lastTypingEmitTime = null;
    final currentUserId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? "";
    final currentUserName =
        Global.storageServices.get(PrefConst.userName)?.toString() ?? "Someone";
    final receiverId = memberData.userId?.toString() ?? "";
    if (receiverId.isNotEmpty && currentUserId.isNotEmpty) {
      socketService.sendPrivateStopTyping(
        chatId: privateChatId.value,
        userId: currentUserId,
        otherUserId: receiverId,
        userName: currentUserName,
      );
    }
  }

  void onInputFocusLost() {
    _sendPrivateStopTypingNow();
  }

  /// Pushes this chat's real last message to the chat list row (after a
  /// delete, a clear, and on close). Only once history is loaded, so a
  /// failed load never blanks the row.
  void _syncChatListPreview() {
    if (!_historyLoaded || !Get.isRegistered<ChatListController>()) return;
    Get.find<ChatListController>().syncLastMessageFromChat(
      chatId: privateChatId.value,
      peerUserId: _privatePeerId,
      last: _messages.isEmpty ? null : _messages.last,
    );
  }

  /// Loaded message with [id], used to build reply previews.
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

    if (!itemScrollController.isAttached) return;

    highlightedMessageId.value = messageId;

    try {
      await itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!isClosed) {
        highlightedMessageId.value = -1;
      }
    } catch (e) {
      log("Scroll to message error: $e");
    }
  }

  void _initializeChat() {
    final stopwatch = Stopwatch()..start();

    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    final receiverId = memberData.userId.toString();

    // This route is always a one-to-one chat (groups use GroupChatScreen).
    // It used to be inferred from `type`/`groupId`, so opening a member from
    // Group > Members or Search Members (type "", member's real groupId)
    // fell into an empty branch: no history, no socket, an empty chat.
    final bool isPrivateChat = arguments?['chatType']?.toString() != 'group';

    log("=================================");
    log("CHAT TYPE => ${isPrivateChat ? 'PRIVATE' : 'GROUP'}");
    log("CURRENT USER ID => $currentUserId");
    log("RECEIVER ID => $receiverId");
    log("GROUP ID => ${memberData.groupId}");
    log("=================================");
    log("[CHAT-PERF] 1. Initialization started: ${stopwatch.elapsedMilliseconds} ms");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        GroupTrackingController.instance.initializeLocation();
        log("[CHAT-PERF] Location initialization called: ${stopwatch.elapsedMilliseconds} ms");
      } catch (e) {
        log("==============MessageException======${e.toString()}");
      }
    });

    ChatStateTracker.isChatCallScreenOpen = true;
    // This screen now owns the /privateChat listeners (see releasePrivateChatEvents).
    socketService.claimPrivateChatEvents(this);

    if (isPrivateChat) {
      String? passedChatId = arguments?['chatId']?.toString();
      _privatePeerId = receiverId;

      // Auto-resolve chatId from ChatListController if caller didn't supply it
      if ((passedChatId == null ||
              passedChatId.isEmpty ||
              passedChatId == 'null') &&
          Get.isRegistered<ChatListController>()) {
        final existing =
            Get.find<ChatListController>().findPrivateChatByUserId(receiverId);
        final resolved =
            existing?.chatId ?? existing?.conversationId ?? existing?.id;
        if (resolved != null && resolved.toString().isNotEmpty) {
          passedChatId = resolved.toString();
          if (arguments != null) {
            arguments!['chatId'] = passedChatId;
          }
        }
      }

      ActiveChatTracker.openPrivate(peerUserId: receiverId, chatId: passedChatId);

      isLoadingInitialMessages.value = true;
      final hasPassedChatId = passedChatId != null &&
          passedChatId.isNotEmpty &&
          passedChatId != 'null';

      if (!hasPassedChatId) {
        _startJoinTimeout();
        getPrivateMessageHistoryByPeer(receiverId);
      }
      if (hasPassedChatId) {
        final effectiveChatId = passedChatId;
        privateChatId.value = effectiveChatId;

        getPrivateMessageHistory(effectiveChatId).then((_) {
          if (!isClosed) {
            socketService.markPrivateSeen(
              chatId: effectiveChatId,
              userId: currentUserId,
              otherUserId: receiverId,
            );
          }
        });
      }

      log("[CHAT-PERF] 2. Private chat socket initialization starting: ${stopwatch.elapsedMilliseconds} ms");

      socketService.initPrivateChat(
        ConstRes.socketUrl,
        userId: currentUserId,
        receiverId: receiverId,
        onJoined: (data) async {
          log("[CHAT-PERF] 3. Socket joined after: ${stopwatch.elapsedMilliseconds} ms");

          final chatId = data["chatId"]?.toString() ??
              socketService.privateChatId?.toString();

          if (chatId == null || chatId.isEmpty) {
            log("[CHAT-PERF] ERROR: PRIVATE CHAT ID NOT FOUND after ${stopwatch.elapsedMilliseconds} ms");
            if (!_historyLoaded) {
              isLoadingInitialMessages.value = false;
              historyLoadFailed.value = true;
            }
            return;
          }

          _joinTimeout?.cancel();
          privateChatId.value = chatId;
          ActiveChatTracker.setPrivateChatId(receiverId, chatId);

          log("PRIVATE CHAT ID => $chatId");

          // "joined" also fires after every socket reconnect: then only
          // fetch what was missed while offline.
          if (_historyLoaded) {
            await syncNewerMessages();
          } else if (!_historyRequestInFlight) {
            await getPrivateMessageHistory(chatId);
          }

          socketService.markPrivateSeen(
            chatId: chatId,
            userId: currentUserId,
            otherUserId: receiverId,
          );
        },
      );

      // socketService.initPrivateChatListSocket(
      //   ConstRes.socketUrl,
      //   userId: currentUserId,
      // );
      // socketService.listenPrivateChatListUpdated(
      //   callback: (data) {
      //     log("CHAT SCREEN PRESENCE EVENT => $data");
      //
      //     if (data is! Map) return;
      //
      //     final payload = Map<String, dynamic>.from(data);
      //
      //     final user = payload['user'] is Map
      //         ? Map<String, dynamic>.from(payload['user'])
      //         : <String, dynamic>{};
      //
      //     final updatedUserId =
      //         (user['id'] ?? payload['userId'] ?? '').toString();
      //
      //     final receiverId = memberData.userId.toString();
      //
      //     if (updatedUserId.isNotEmpty && updatedUserId != receiverId) {
      //       return;
      //     }
      //
      //     final onlineValue = payload['isOnline'] ?? user['isOnline'];
      //
      //     if (onlineValue is bool) {
      //       isPeerOnline.value = onlineValue;
      //       memberData.isOnline = onlineValue;
      //     } else if (onlineValue is num) {
      //       isPeerOnline.value = onlineValue != 0;
      //       memberData.isOnline = onlineValue != 0;
      //     } else if (onlineValue is String) {
      //       final value = onlineValue.toLowerCase().trim();
      //
      //       if (['true', '1', 'yes'].contains(value)) {
      //         isPeerOnline.value = true;
      //         memberData.isOnline = true;
      //       } else if (['false', '0', 'no'].contains(value)) {
      //         isPeerOnline.value = false;
      //         memberData.isOnline = false;
      //       }
      //     }
      //
      //     final lastSeenValue = payload['lastSeen'] ?? user['lastSeen'];
      //
      //     if (lastSeenValue != null) {
      //       memberData.lastSeen = lastSeenValue.toString();
      //     }
      //
      //     peerLastSeen.value = isPeerOnline.value
      //         ? 'Online'
      //         : (memberData.lastSeen?.trim().isNotEmpty == true
      //             ? memberData.lastSeen!.trim()
      //             : 'Offline');
      //
      //     log(
      //       'PRIVATE CHAT PRESENCE UPDATED => '
      //       'userId=$updatedUserId, '
      //       'isOnline=${isPeerOnline.value}, '
      //       'lastSeen=${peerLastSeen.value}',
      //     );
      //   },
      // );

      socketService.receivePrivateMessage(
        senderId: currentUserId,
        receiverId: receiverId,
        callback: (message) {
          try {
            final messageData =
            MessageData.fromJson(Map<String, dynamic>.from(message));
            // Live messages often carry no sender name: the quote of a reply
            // to them (and the replySender we send) was then blank. In a
            // private chat the other person is known.
            final hasName =
                (messageData.senderName?.toString().trim() ?? '').isNotEmpty &&
                    messageData.senderName?.toString() != 'null';
            if (!hasName &&
                messageData.senderId?.toString() == receiverId.toString()) {
              messageData.senderName = memberData.name;
            }

            final existingIndex = _messages.indexWhere(
              (msg) => msg.id == messageData.id && messageData.id != null,
            );
            rtModel('private socket', messageData,
                extra: 'alreadyInList=${existingIndex != -1}'); // TODO(rt-diagnostics)

            if (existingIndex != -1) {
              final existing = _messages[existingIndex];
              final hasOldContent = (existing.content?.toString().trim().isNotEmpty ?? false) ||
                  (existing.caption?.toString().trim().isNotEmpty ?? false) ||
                  (existing.images?.isNotEmpty ?? false) ||
                  (existing.videos?.isNotEmpty ?? false);
              final hasNewContent = (messageData.content?.toString().trim().isNotEmpty ?? false) ||
                  (messageData.caption?.toString().trim().isNotEmpty ?? false) ||
                  (messageData.images?.isNotEmpty ?? false) ||
                  (messageData.videos?.isNotEmpty ?? false);
              if (!hasOldContent && hasNewContent) {
                existing.content = messageData.content;
                existing.caption = messageData.caption;
                existing.images = messageData.images;
                existing.videos = messageData.videos;
                existing.messageType = messageData.messageType;
                existing.thumbnail = messageData.thumbnail;
                updateMessageStream();
              }
              // receive_message arrives twice for the same id: the first
              // event can lack the attachment (images / video / audio URL),
              // and the content check above then skipped the second one, so
              // the media only showed after re-opening. Fill what's missing.
              if (existing.mergeAttachmentFrom(messageData)) {
                updateMessageStream();
              }
              rtDecision('private list', messageData,
                  'MERGED into index $existingIndex (contentUpdated=${!hasOldContent && hasNewContent}) listLength=${_messages.length}'); // TODO(rt-diagnostics)
            } else {
              final wasAtBottom = isUserAtBottom();
              final isMyMessage =
                  messageData.senderId?.toString() == currentUserId.toString();

              final hasContent = (messageData.content?.toString().trim().isNotEmpty ?? false) ||
                  (messageData.caption?.toString().trim().isNotEmpty ?? false) ||
                  (messageData.images?.isNotEmpty ?? false) ||
                  (messageData.videos?.isNotEmpty ?? false);

              if (messageData.isForwarded == true && !hasContent) {
                final fromId = messageData.forwardedFromMessageId;
                if (fromId != null) {
                  final source = _messages.firstWhereOrNull(
                    (m) => m.id == fromId || m.id?.toString() == fromId.toString(),
                  );
                  if (source != null) {
                    messageData.content = source.content;
                    messageData.caption = source.caption;
                    messageData.images = source.images;
                    messageData.videos = source.videos;
                    messageData.messageType = source.messageType;
                    messageData.thumbnail = source.thumbnail;
                  }
                }

                if ((messageData.content?.toString().trim().isEmpty ?? true) &&
                    (messageData.caption?.toString().trim().isEmpty ?? true) &&
                    (messageData.images?.isEmpty ?? true) &&
                    (messageData.videos?.isEmpty ?? true)) {
                  _resolveForwardedMessageContent(messageData);
                }
              }

              _messages.add(messageData);
              updateMessageStream();
              rtDecision('private list', messageData,
                  'ADDED listLength=${_messages.length} streamEmitted=true'); // TODO(rt-diagnostics)

              if (isMyMessage || wasAtBottom) {
                scrollToBottom();
              } else {
                unreadBelowCount.value++;
                showScrollToBottom.value = true;
              }
            }

            // Receipts are only for the peer's messages: never mark my own
            // message delivered/seen by me.
            final fromPeer =
                messageData.senderId?.toString() != currentUserId.toString();

            if (messageData.id != null && fromPeer) {
              socketService.markPrivateDelivered(
                messageIds: [messageData.id!],
                userId: currentUserId,
                otherUserId: receiverId,
              );
            }

            // "Seen" only while the user is actually looking at the chat;
            // in the background the read is sent on resume.
            if (privateChatId.value.isNotEmpty &&
                fromPeer &&
                ActiveChatTracker.isAppInForeground) {
              socketService.markPrivateSeen(
                chatId: privateChatId.value,
                userId: currentUserId,
                otherUserId: receiverId,
              );
            }

            // The user is in this chat: also clear the chat-list unread count.
            if (messageData.senderId?.toString() != currentUserId.toString()) {
              _scheduleMarkPrivateRead();
            }
          } catch (e) {
            log("Error handling private socket message: $e");
          }
        },
      );

      socketService.listenPrivateChatCleared(
        handlePrivateChatCleared,
      );

      socketService.listenPrivateMessagesDelivered(
        callback: (data) {
          if (data == null) return;
          final dataChatId = (data is Map) ? data["chatId"]?.toString() : null;

          if (privateChatId.value.isNotEmpty &&
              dataChatId != null &&
              dataChatId != privateChatId.value) {
            return;
          }

          final List updatedIds = (data is Map)
              ? (data["messageIds"] is List
                  ? data["messageIds"]
                  : data["messageId"] != null
                      ? [data["messageId"]]
                      : [])
              : [];

          bool changed = false;
          for (var msg in _messages) {
            if (updatedIds.isEmpty ||
                updatedIds.any(
                  (id) => id.toString() == msg.id.toString(),
                )) {
              if (!msg.isDelivered) {
                msg.isDelivered = true;
                changed = true;
              }
            }
          }

          if (changed) {
            updateMessageStream();
          }
        },
      );

      socketService.listenPrivateMessagesSeenUpdate(
        callback: (data) {
          if (data is! Map) return;
          final dataChatId = data["chatId"]?.toString();

          if (privateChatId.value.isNotEmpty &&
              dataChatId != null &&
              dataChatId != privateChatId.value) {
            return;
          }

          final List updatedIds =
              data["messageIds"] is List ? data["messageIds"] : const [];
          final readerId = (data["seenBy"] ??
                  data["readerId"] ??
                  data["userId"] ??
                  data["user_id"])
              ?.toString();

          // Only my messages can be seen, only by the peer, and only once
          // (the old "+1 per event" inflated the count).
          final changed = ChatScreenRules.applyPrivateSeen(
            _messages,
            messageIds: updatedIds,
            readerId: readerId,
            currentUserId:
                Global.storageServices.get(PrefConst.userId)?.toString(),
          );
          if (changed) updateMessageStream();
        },
      );

      socketService.listenPrivateTyping(
        onTyping: (data) {
          try {
            if (data is! Map) return;
            final dataMap = Map<String, dynamic>.from(data);
            final inner = dataMap['message'] is Map
                ? Map<String, dynamic>.from(dataMap['message'])
                : (dataMap['data'] is Map
                    ? Map<String, dynamic>.from(dataMap['data'])
                    : dataMap);

            final currentUserId =
                Global.storageServices.get(PrefConst.userId)?.toString();
            final targetUserId = memberData.userId?.toString();

            final senderId = (inner["userId"] ??
                    inner["user_id"] ??
                    inner["senderId"] ??
                    inner["sender_id"] ??
                    dataMap["userId"] ??
                    dataMap["senderId"])
                ?.toString();

            final eventChatId = (inner["chatId"] ??
                    inner["chat_id"] ??
                    dataMap["chatId"] ??
                    dataMap["chat_id"])
                ?.toString();

            // Ignore events sent by myself
            if (senderId != null && senderId == currentUserId) return;

            // Match if senderId is the peer we are chatting with, or matches chatId
            final isForThisChat = (targetUserId != null &&
                    targetUserId.isNotEmpty &&
                    senderId == targetUserId) ||
                (privateChatId.value.isNotEmpty &&
                    eventChatId != null &&
                    eventChatId == privateChatId.value);

            if (isForThisChat) {
              AppLog.d("[TYPING] Peer typing started: $targetUserId in chat ${privateChatId.value}");
              isPeerTyping.value = true;
              _peerTypingResetTimer?.cancel();
              _peerTypingResetTimer =
                  Timer(const Duration(milliseconds: 4000), () {
                if (!isClosed) {
                  AppLog.d("[TYPING] Peer typing reset timer expired");
                  isPeerTyping.value = false;
                }
              });
            }
          } catch (e) {
            log("Error in onTyping listener: $e");
          }
        },
        onStopTyping: (data) {
          try {
            if (data is Map) {
              final dataMap = Map<String, dynamic>.from(data);
              final inner = dataMap['message'] is Map
                  ? Map<String, dynamic>.from(dataMap['message'])
                  : (dataMap['data'] is Map
                      ? Map<String, dynamic>.from(dataMap['data'])
                      : dataMap);

              final targetUserId = memberData.userId?.toString();
              final senderId = (inner["userId"] ??
                      inner["user_id"] ??
                      inner["senderId"] ??
                      inner["sender_id"] ??
                      dataMap["userId"] ??
                      dataMap["senderId"])
                  ?.toString();

              final eventChatId = (inner["chatId"] ??
                      inner["chat_id"] ??
                      dataMap["chatId"] ??
                      dataMap["chat_id"])
                  ?.toString();

              final isForThisChat = (targetUserId != null &&
                      targetUserId.isNotEmpty &&
                      senderId == targetUserId) ||
                  (privateChatId.value.isNotEmpty &&
                      eventChatId != null &&
                      eventChatId == privateChatId.value);

              if (isForThisChat) {
                AppLog.d("[TYPING] Peer typing stopped: $targetUserId in chat ${privateChatId.value}");
                _peerTypingResetTimer?.cancel();
                isPeerTyping.value = false;
              }
            } else {
              AppLog.d("[TYPING] Peer typing stopped (data not map)");
              _peerTypingResetTimer?.cancel();
              isPeerTyping.value = false;
            }
          } catch (_) {
            _peerTypingResetTimer?.cancel();
            isPeerTyping.value = false;
          }
        },
      );

      socketService.listenMessageEdited(
      scope: ChatSocketScope.private,
        callback: (data) {
          if (data is! Map) {
            return;
          }

          try {
            // Same shape as the group handler: `messageId` (falls back to
            // `id`). Update in place so ticks, reply and media stay; the old
            // full replace lost them and missed payloads keyed `messageId`.
            final map = Map<String, dynamic>.from(data);
            final applied = ChatScreenRules.applyEdit(_messages, map);
            if (applied) updateMessageStream();
          } catch (e) {
            log("Private edit event error: $e");
          }
        },
      );

      socketService.listenMessageDeleted(
      scope: ChatSocketScope.private,
        callback: (data) {
          if (data is! Map) {
            return;
          }

          try {
            final messageId = int.tryParse(
              data["messageId"]?.toString() ?? "",
            );

            final deleteType = data["deleteType"]?.toString();

            if (messageId == null) {
              return;
            }

            final index = _messages.indexWhere(
                  (message) => message.id == messageId,
            );

            if (index == -1) {
              return;
            }

            final me =
                Global.storageServices.get(PrefConst.userId)?.toString();
            if (deleteType == "for_me") {
              // Only the user who deleted it loses it.
              if (!ChatScreenRules.isDeleteForMeByMe(data, me)) return;
              _messages.removeAt(index);
            } else if (deleteType == "for_everyone") {
              ChatScreenRules.markDeletedForEveryone(_messages[index]);
            }

            if (pinnedMessage.value?.id == messageId) {
              pinnedMessage.value = null;
              showPinnedBanner.value = false;
            }

            updateMessageStream();
            // The chat list row must not keep showing the deleted message.
            _syncChatListPreview();
          } catch (e) {}
        },
      );

      socketService.listenMessageSent(
        scope: ChatSocketScope.private,
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
              msg.isDelivered = false;
              updated = true;
              break;
            }
          }
          if (updated) updateMessageStream();
        },
      );
    } else {}

    socketService.listenPinMessage(
      scope: ChatSocketScope.private,
      callback: (data) {
        final messageId = int.tryParse(
          data["messageId"].toString(),
        );

        if (messageId == null) return;

        if (data["chatType"] != "private") return;

        final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

        final otherUserId = memberData.userId.toString();

        final senderId = data["senderId"]?.toString();
        final receiverId = data["receiverId"]?.toString();

        if (senderId != null && receiverId != null) {
          final isSameChat =
              (senderId == currentUserId && receiverId == otherUserId) ||
                  (senderId == otherUserId && receiverId == currentUserId);

          if (!isSameChat) return;
        }

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
      scope: ChatSocketScope.private,
      callback: (data) {
        if (data["chatType"] != "private") return;

        final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

        final otherUserId = memberData.userId.toString();

        // Same rule as pin: only filter when both ids are present
        // (`"null"` used to make every unpin without senderId a no-op).
        final senderId = data["senderId"]?.toString();
        final receiverId = data["receiverId"]?.toString();

        if (senderId != null && receiverId != null) {
          final isSameChat =
              (senderId == currentUserId && receiverId == otherUserId) ||
                  (senderId == otherUserId && receiverId == currentUserId);
          if (!isSameChat) return;
        } else {
          final eventMessageId =
              MessageData.parseIntOrNull(data["messageId"]);
          if (eventMessageId != null &&
              pinnedMessage.value?.id != eventMessageId) {
            return;
          }
        }

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();
      },
    );

    log("[CHAT-PERF] Initialization method completed: ${stopwatch.elapsedMilliseconds} ms");
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

  Future<void> sendMessage({
    required TextEditingController textController,
  }) async {
    if (isSending.value) return;
    // sendPrivateMessage silently drops the emit when the socket is down;
    // stop here so the typed text and attachments are kept, not lost.
    if (!_ensurePrivateSocketOnline()) return;
    _sendPrivateStopTypingNow();
    isSending.value = true;
    var keepDraft = false;

    final text = textController.text.trim();

    final bool hasImages = imagePaths.isNotEmpty;
    final bool hasVideos = videoPaths.isNotEmpty;
    final bool hasDocument = documentPath.value.isNotEmpty;
    final bool hasMedia = hasImages || hasVideos || hasDocument;

    try {
      final bool shouldSendMixedMedia =
          hasImages && hasVideos || videoPaths.length > 1;

      if (shouldSendMixedMedia) {
        final imagesCopy = List<File>.from(imagePaths);
        final videosCopy = List<String>.from(videoPaths);
        final uploadedImages = <String>[];
        final uploadedVideos = <Map<String, dynamic>>[];
        final successfulVideoIndexes = <int>[];

        for (final image in imagesCopy) {
          final result = await MessageRepo.uploadChatImage(image);

          if (result.status == true && result.filename != null) {
            uploadedImages.add(result.filename!);
          } else {
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

            if (thumbnailPath == null) {
              CommonDialog.errorMessage(
                "Failed to generate video thumbnail",
              );
              continue;
            }

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

            if (result.status == true && result.videoUrl != null) {
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
            log("Mixed media video upload error: $e");
          } finally {
            uploadingVideoIndexes.remove(currentIndex);
            videoUploadProgress.remove(currentIndex);
          }
        }

        if (uploadedImages.isNotEmpty || uploadedVideos.isNotEmpty) {
          socketService.sendPrivateMessage(
            messageType: "media",
            receiverId: memberData.userId.toString(),
            content: "",
            images: uploadedImages,
            videos: uploadedVideos,
            caption: text,
            replyId: replyMessage.value?.id,
            replyMessage: replyMessage.value?.content,
            replyType: replyMessage.value?.messageType,
            replySender: replyMessage.value?.senderName,
          );

          imagePaths.clear();

          for (final index in successfulVideoIndexes.reversed) {
            if (index < videoPaths.length) {
              removeVideo(index);
            }
          }
        } else {
          keepDraft = true;
        }
      } else {
        if (hasImages) {
          final imagesCopy = List<File>.from(imagePaths);
          final uploadedImages = <String>[];

          for (final image in imagesCopy) {
            final result = await MessageRepo.uploadChatImage(image);

            if (result.status == true && result.filename != null) {
              uploadedImages.add(result.filename!);
            } else {
              CommonDialog.errorMessage(
                "Failed to upload ${image.path}",
              );
            }
          }

          if (uploadedImages.isNotEmpty) {
            socketService.sendPrivateMessage(
              messageType: "image",
              receiverId: memberData.userId.toString(),
              content: uploadedImages.first,
              images: uploadedImages,
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );
            imagePaths.clear();
          } else {
            // Every upload failed: keep the images and the caption.
            keepDraft = true;
          }
        }

        if (hasVideos) {
          final videosCopy = List<String>.from(videoPaths);

          for (final vPath in videosCopy) {
            final currentIndex = videoPaths.indexOf(vPath);
            if (currentIndex == -1) continue;

            uploadingVideoIndexes.add(currentIndex);
            uploadingVideoIndexes.refresh();

            try {
              final success = await uploadVideoAtIndex(
                vPath,
                text,
                currentIndex,
              );

              if (success) {
                final index = videoPaths.indexOf(vPath);
                if (index != -1) {
                  removeVideo(index);
                }
              }
            } finally {
              uploadingVideoIndexes.remove(currentIndex);
              videoUploadProgress.remove(currentIndex);
            }
          }
        }
      }

      if (hasDocument) {
        await uploadDocument(documentPath.value, text);
        documentPath.value = "";
      }

      if (!hasMedia && text.isNotEmpty) {
        socketService.sendPrivateMessage(
          messageType: "text",
          receiverId: memberData.userId.toString(),
          content: text,
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
      log("Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  /// Private messages go only over the socket. When it is disconnected the
  /// emit is dropped, so tell the user and keep their draft instead.
  bool _ensurePrivateSocketOnline() {
    if (socketService.isPrivateChatSocketConnected) return true;
    Utils().fluttertoast("You're offline. Message not sent.");
    return false;
  }

  Future<void> uploadAudio(String path) async {
    if (!_ensurePrivateSocketOnline()) return;
    var result = await MessageRepo.uploadChatAudio(path);

    final filename = result.filename?.toString() ?? "";
    if (result.status == true && filename.isEmpty) {
      Utils().fluttertoast("Voice message upload failed. Please try again.");
      return;
    }
    if (result.status == true) {
      socketService.sendPrivateMessage(
        messageType: "audio",
        receiverId: memberData.userId.toString(),
        content: filename,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );
      clearReply();
      scrollToBottom();
    }
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
        socketService.sendPrivateMessage(
          messageType: "video",
          receiverId: memberData.userId.toString(),
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
      log("Upload error: $e");
      return false;
    }
  }

  Future<void> uploadVideo(String path, String caption) async {
    try {
      isUploadingVideo.value = true;

      final thumbnailPath = await generateThumbnailFile(path);
      log("Thumbnail: $thumbnailPath");

      if (thumbnailPath == null) {
        isUploadingVideo.value = false;
        return;
      }

      var result = await MessageRepo.uploadChatVideo(
        videoPath: path,
        thumbnailPath: thumbnailPath,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
            log("Progress: ${(sent / total * 100).toInt()}%");
          }
        },
      );

      if (result.status == true) {
        socketService.sendPrivateMessage(
          messageType: "video",
          receiverId: memberData.userId.toString(),
          content:
              "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }
    } catch (e) {
    } finally {
      isUploadingVideo.value = false;
      clearReply();
    }
  }

  Future<void> uploadDocument(String path, String caption) async {
    var result = await MessageRepo.uploadChatDocument(path);

    if (result.status == true) {
      socketService.sendPrivateMessage(
        messageType: "document",
        receiverId: memberData.userId.toString(),
        // originalName may be missing: fall back to the stored file name
        // instead of crashing on `!`.
        content: "${result.filename}||${result.originalName ?? path.split(RegExp(r'[\\/]')).last}",
        caption: caption,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );
      clearReply();
    }
  }

  Future<void> sendLocation({
    required LocationMessage location,
  }) async {
    if (!_ensurePrivateSocketOnline()) return;
    try {
      socketService.sendPrivateMessage(
        receiverId: memberData.userId.toString(),
        content: location.toContent(),
        messageType: "location",
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
    if (!_ensurePrivateSocketOnline()) return;
    try {
      socketService.sendPrivateMessage(
        receiverId: memberData.userId.toString(),
        content: contact.toContent(),
        messageType: "contact",
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
    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    final otherUserId = memberData.userId.toString();

    log("========== PRIVATE DELETE START ==========");
    log("MESSAGE ID: $messageId");
    log("DELETE TYPE: $deleteType");
    log("CURRENT USER: $currentUserId");
    log("OTHER USER: $otherUserId");
    log("PRIVATE SOCKET CONNECTED: "
        "${socketService.isPrivateChatSocketConnected}");

    socketService.deleteMessage(
      messageId: messageId,
      userId: currentUserId,
      deleteType: deleteType,
      otherUserId: otherUserId,
    );

    log("PRIVATE DELETE EMIT CALLED");
  }

  Future<void> _resolveForwardedMessageContent(MessageData target) async {
    try {
      GetMessage? history;
      if (privateChatId.value.isNotEmpty) {
        history = await MessageRepo.privateChatHistory(
          chatId: privateChatId.value,
          page: 1,
          limit: 10,
        );
      } else if (memberData.userId != null) {
        history = await MessageRepo.MessageHistory(
          recieverId: memberData.userId.toString(),
          groupId: 0,
        );
      }

      if (history?.status == true && history?.messageData != null) {
        final found = history!.messageData!.firstWhereOrNull(
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
      log("Error resolving forwarded message content in MessageController: $e");
    }
  }

  Future<void> getMessageHistory(
    String recieverId,
    int groupId,
  ) async {
    try {
      var result = await MessageRepo.MessageHistory(
        recieverId: recieverId,
        groupId: groupId,
      );

      if (result.status == true) {
        _messages
          ..clear()
          ..addAll(result.messageData ?? []);

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
        isCreator.value = result.isCreator ?? false;
        scrollToBottom(instant: true);
      } else {
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      log("History Error: $e");
    }
  }


  /// Direct history fetch by peer user ID (no chatId needed upfront).
  /// Resolves conversationId and loads messages immediately.
  Future<void> getPrivateMessageHistoryByPeer(String peerUserId) async {
    _historyRequestInFlight = true;
    historyLoadFailed.value = false;
    if (_messages.isEmpty) isLoadingInitialMessages.value = true;

    try {
      _pager.reset();
      privateCurrentPage.value = 1;
      hasMoreOlderMessages.value = true;

      final result = await MessageRepo.privateChatHistoryByPeer(
        peerUserId: peerUserId,
        page: 1,
        limit: ChatScreenRules.pageSize,
      );

      if (result.status == true) {
        final resolved = result.chatId?.toString() ??
            result.conversationId?.toString();
        if (resolved != null && resolved.isNotEmpty) {
          privateChatId.value = resolved;
          ActiveChatTracker.setPrivateChatId(peerUserId, resolved);
          if (arguments != null) arguments!['chatId'] = resolved;

          final me = Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
          if (!isClosed && me.isNotEmpty) {
            socketService.markPrivateSeen(
              chatId: resolved,
              userId: me,
              otherUserId: peerUserId,
            );
          }
        }

        memberData.isOnline = result.isOnline ?? memberData.isOnline;
        memberData.lastSeen = result.lastSeen ?? memberData.lastSeen;
        isPeerOnline.value = memberData.isOnline ?? false;

        final messages = result.messageData ?? [];
        final blockStatus = result.blockStatus;
        if (blockStatus != null) {
          isBlocked.value = blockStatus.isBlocked == true;
          blockedByMe.value = blockStatus.blockedByMe == true;
        }

        final merged = ChatScreenRules.merge(
          _messages,
          messages.reversed.toList(),
        );
        _messages
          ..clear()
          ..addAll(merged.messages);

        _pager.complete(
          page: 1,
          receivedCount: messages.length,
          hasNextPage: result.pagination?.hasNextPage,
        );
        _historyLoaded = true;
        for (final m in _messages) {
          rtModel('private history', m); // TODO(rt-diagnostics)
        }

        if (_messages.isNotEmpty) {
          scrollToBottom(instant: true);
        }
      } else {
        _pager.fail();
        if (_messages.isEmpty) historyLoadFailed.value = true;
      }
    } catch (e) {
      log("History by peer error: $e");
      _pager.fail();
      if (_messages.isEmpty) historyLoadFailed.value = true;
    } finally {
      isLoadingInitialMessages.value = false;
      _historyRequestInFlight = false;
    }
  }

  Future<void> getPrivateMessageHistory(String chatId) async {
    final apiStopwatch = Stopwatch()..start();

    log("========== HISTORY DEBUG 1: METHOD START ==========");
    log("HISTORY DEBUG => chatId: $chatId");
    log("HISTORY DEBUG => controller closed: $isClosed");

    _historyRequestInFlight = true;
    historyLoadFailed.value = false;
    if (_messages.isEmpty) isLoadingInitialMessages.value = true;

    try {
      _pager.reset();
      privateCurrentPage.value = 1;
      hasMoreOlderMessages.value = true;

      log("========== HISTORY DEBUG 2: BEFORE API CALL ==========");
      log("HISTORY DEBUG => page: 1, limit: ${ChatScreenRules.pageSize}");

      final result = await MessageRepo.privateChatHistory(
        chatId: chatId,
        page: 1,
        limit: ChatScreenRules.pageSize,
      );

      log("========== HISTORY DEBUG 3: API RESPONSE RECEIVED ==========");
      log("HISTORY DEBUG => elapsed: ${apiStopwatch.elapsedMilliseconds} ms");
      log("HISTORY DEBUG => status: ${result.status}");
      log("HISTORY DEBUG => response message: ${result.message}");
      log("HISTORY DEBUG => response item count: ${result.messageData?.length ?? 0}");

      if (result.status == true) {
        log("========== HISTORY DEBUG 4: PROCESSING SUCCESS RESPONSE ==========");

        memberData.isOnline = result.isOnline ?? memberData.isOnline;
        memberData.lastSeen = result.lastSeen ?? memberData.lastSeen;

        isPeerOnline.value = memberData.isOnline ?? false;

        final lastSeen = memberData.lastSeen?.trim() ?? "";

        if (isPeerOnline.value) {
          peerLastSeen.value = "Online";
        } else if (lastSeen.isNotEmpty) {
          try {
            peerLastSeen.value =
                Tracking().getTimeAgo(DateTime.parse(lastSeen));
          } catch (e) {
            log("HISTORY DEBUG => lastSeen parsing error: $e");
            peerLastSeen.value = lastSeen;
          }
        } else {
          peerLastSeen.value = "Offline";
        }

        final messages = result.messageData ?? [];
        final blockStatus = result.blockStatus;

        log("HISTORY DEBUG => online: ${isPeerOnline.value}");
        log("HISTORY DEBUG => incoming messages: ${messages.length}");

        if (blockStatus != null) {
          isBlocked.value = blockStatus.isBlocked == true;
          blockedByMe.value = blockStatus.blockedByMe == true;
        } else {
          isBlocked.value = false;
          blockedByMe.value = false;
        }

        log("HISTORY DEBUG => isBlocked: ${isBlocked.value}");
        log("HISTORY DEBUG => blockedByMe: ${blockedByMe.value}");

        log("========== HISTORY DEBUG 5: UPDATING MESSAGE LIST ==========");

        // Merge, don't replace: socket messages that arrived before this
        // response must survive, and duplicates are dropped by id.
        final merged = ChatScreenRules.merge(
          _messages,
          messages.reversed.toList(),
        );
        _messages
          ..clear()
          ..addAll(merged.messages);
        _pager.complete(
          page: 1,
          receivedCount: messages.length,
          hasNextPage: result.pagination?.hasNextPage,
        );
        _historyLoaded = true;
        for (final m in _messages) {
          rtModel('private history', m); // TODO(rt-diagnostics)
        }

        log("HISTORY DEBUG => mapped message count: ${_messages.length}");

        final pinnedId = result.pinnedMessageId;

        log("HISTORY DEBUG => pinned message ID: $pinnedId");

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

        log("========== HISTORY DEBUG 6: BEFORE STREAM UPDATE ==========");

        updateMessageStream();

        log("HISTORY DEBUG => stream update completed");
        log("HISTORY DEBUG => stream message count: ${_messages.length}");

        isCreator.value = result.isCreator ?? false;

        hasMoreOlderMessages.value = _pager.hasMore;

        log("HISTORY DEBUG => isCreator: ${isCreator.value}");
        log("HISTORY DEBUG => hasMoreOlderMessages: ${hasMoreOlderMessages.value}");

        if (_messages.isNotEmpty) {
          log("========== HISTORY DEBUG 7: SCROLL TO BOTTOM ==========");
          scrollToBottom(instant: true);
        } else {
          log("HISTORY DEBUG => message list is EMPTY");
        }

        log("========== HISTORY DEBUG 8: PROCESSING COMPLETED ==========");
        log("HISTORY DEBUG => final count: ${_messages.length}");
        log("HISTORY DEBUG => total: ${apiStopwatch.elapsedMilliseconds} ms");
      } else {
        log("========== HISTORY DEBUG ERROR: API STATUS FALSE ==========");
        log("HISTORY DEBUG => ${result.message}");

        _pager.fail();
        if (_messages.isEmpty) historyLoadFailed.value = true;
        CommonDialog.errorMessage(result.message);
      }
    } catch (e, stackTrace) {
      log("========== HISTORY DEBUG ERROR: EXCEPTION ==========");
      log("HISTORY DEBUG => $e");
      log("HISTORY DEBUG STACKTRACE => $stackTrace");
      _pager.fail();
      // Show "Couldn't load messages / Retry" instead of a false
      // "No messages here yet".
      if (_messages.isEmpty) historyLoadFailed.value = true;
    } finally {
      _historyRequestInFlight = false;
      isLoadingInitialMessages.value = false;

      log("========== HISTORY DEBUG 9: FINALLY ==========");
      log("HISTORY DEBUG => loading stopped");
      log("HISTORY DEBUG => total time: ${apiStopwatch.elapsedMilliseconds} ms");
    }
  }

  void setReply(MessageData message) {
    replyMessage.value = message;
  }

  void clearReply() {
    replyMessage.value = null;
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

  /// App-bar back button. The route's PopScope then calls [onRoutePopped].
  void handleBackPressed(
    BuildContext context, {
    required int groupID,
  }) {
    Navigator.of(context).maybePop();
  }

  bool _leftChat = false;

  /// Leaves the chat room once, however the screen was closed: app-bar
  /// back, Android back, or the iOS swipe-back gesture (which the old
  /// WillPopScope blocked).
  void onRoutePopped() {
    if (_leftChat) return;
    _leftChat = true;

    final userId = Global.storageServices.get(PrefConst.userId).toString();

    final receiverId = memberData.userId.toString();

    socketService.leavePrivateChat(
      userId: userId,
      receiverId: receiverId,
    );

    socketService.releasePrivateChatEvents(this);

    _messages.clear();
    messageText.value = "";
    imagePaths.clear();
    clearVideos();
    isSending.value = false;
    clearReply();
    pinnedMessage.value = null;
    showPinnedBanner.value = false;
    ChatStateTracker.isChatCallScreenOpen = false;
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
        .where(
          (msg) =>
              msg.messageType == "text" &&
              (msg.content?.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      ) ??
                  false),
        )
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
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final otherUserId = memberData.userId.toString();

    log("PIN CLICKED => messageId=${message.id}");
    log("PIN USER => $currentUserId");
    log("PIN OTHER USER => $otherUserId");
    log("PRIVATE SOCKET CONNECTED => ${socketService.isPrivateChatSocketConnected}");

    socketService.pinMessage(
      chatType: "private",
      senderId: currentUserId,
      receiverId: otherUserId,
      messageId: message.id!,
      pinnedByName: Global.storageServices.get(PrefConst.userName) ?? "User",
    );
  }

  void unpinMessage() {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final otherUserId = memberData.userId.toString();

    socketService.unpinMessageEvent(
      chatType: "private",
      senderId: currentUserId,
      receiverId: otherUserId,
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

    final newDate =
        formatDateHeader(messageData[firstVisibleIndex].timestamp ?? "");

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

    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    final otherUserId = memberData.userId.toString();

    log(
      "UPDATE EDITED MESSAGE => messageId=${message.id}, userId=$currentUserId, otherUserId=$otherUserId, text=$text",
    );

    socketService.editMessage(
      messageId: message.id!,
      content: text,
      userId: currentUserId,
      otherUserId: otherUserId,
    );

    editingMessage.value = null;

    log(
      "EDIT REQUEST SENT => messageId=${message.id}",
    );
  }

  void _onScrollForOlderMessages() {
    if (isLoadingOlderMessages.value) return;
    if (!hasMoreOlderMessages.value) return;
    if (isLoadingInitialMessages.value) return;
    if (_messages.isEmpty) return;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return;

    final visible =
        positions.where((position) => position.itemTrailingEdge > 0).toList();

    if (visible.isEmpty) return;

    visible.sort((a, b) => a.index.compareTo(b.index));

    final firstVisibleIndex = visible.first.index;

    if (firstVisibleIndex <= 2) {
      loadOlderPrivateMessages();
    }
  }

  /// Set when this screen asks the server to clear the chat, so our own
  /// clear always applies even if the event's id doesn't match.
  DateTime? _clearRequestedAt;

  void handlePrivateChatCleared(Map<String, dynamic> data) {
    final conversationId = int.tryParse(
      (data['conversationId'] ??
                  data['conversation_id'] ??
                  data['chatId'] ??
                  data['chat_id'])
              ?.toString() ??
          '',
    );

    if (conversationId == null) return;

    // Another chat was cleared (e.g. from the list on another device):
    // don't wipe this one. Same id match the chat list uses.
    final requestedHere = _clearRequestedAt != null &&
        DateTime.now().difference(_clearRequestedAt!).inSeconds < 15;
    if (!requestedHere &&
        privateChatId.value.isNotEmpty &&
        privateChatId.value != conversationId.toString()) {
      return;
    }
    _clearRequestedAt = null;

    log(
      "PRIVATE CHAT CLEARED => conversationId=$conversationId",
    );

    messageData.clear();
    updateMessageStream();

    log("CHAT MESSAGES CLEARED FROM UI");
    _syncChatListPreview();
  }

  void clearPrivateChat() {
    if (privateChatId.value.isEmpty) {
      log("CLEAR PRIVATE CHAT => CHAT ID NOT FOUND");
      return;
    }

    log(
      "CLEAR PRIVATE CHAT => chatId=${privateChatId.value}",
    );

    _clearRequestedAt = DateTime.now();
    socketService.clearPrivateChat(
      chatId: privateChatId.value,
    );
  }

  Future<String?> blockUser(int blockedUserId) async {
    if (isBlocking.value) return null;

    isBlocking.value = true;

    try {
      final response = await MessageRepo.blockUser(
        blockedUserId: blockedUserId,
      );

      if (response is Map && response["status"] == true) {
        isBlocked.value = true;
        blockedByMe.value = true;

        return response["message"]?.toString() ?? "User blocked successfully";
      }

      return response is Map
          ? response["message"]?.toString()
          : "Unable to block user";
    } catch (e) {
      log("Block user error: $e");
      return null;
    } finally {
      isBlocking.value = false;
    }
  }

  Future<String?> unblockUser(int blockedUserId) async {
    if (isUnblocking.value) return null;

    isUnblocking.value = true;

    try {
      final response = await MessageRepo.unblockUser(
        blockedUserId: blockedUserId,
      );

      if (response is Map && response["status"] == true) {
        isBlocked.value = false;
        blockedByMe.value = false;

        return response["message"]?.toString() ?? "User unblocked successfully";
      }

      return response is Map
          ? response["message"]?.toString()
          : "Unable to unblock user";
    } catch (e) {
      log("Unblock user error: $e");
      return null;
    } finally {
      isUnblocking.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // History paging and sync (rules in chat_screen_logic.dart)
  // ---------------------------------------------------------------------------

  final HistoryPager _pager = HistoryPager();
  bool _historyLoaded = false;
  bool _historyRequestInFlight = false;
  DateTime? _olderRetryAfter;
  Timer? _joinTimeout;

  /// True when the first load failed and nothing is shown: the list shows
  /// "Couldn't load messages" + Retry instead of "No messages here yet".
  final RxBool historyLoadFailed = false.obs;

  /// Entry points without a chatId wait for the socket "joined" event that
  /// carries it. If it never comes, stop the skeleton and offer Retry.
  void _startJoinTimeout() {
    _joinTimeout?.cancel();
    _joinTimeout = Timer(const Duration(seconds: 10), () {
      if (isClosed || privateChatId.value.isNotEmpty) return;
      isLoadingInitialMessages.value = false;
      if (_messages.isEmpty) historyLoadFailed.value = true;
    });
  }

  /// "Retry" on the load-error state.
  Future<void> retryLoadHistory() async {
    historyLoadFailed.value = false;
    if (privateChatId.value.isNotEmpty) {
      await getPrivateMessageHistory(privateChatId.value);
      return;
    }
    isLoadingInitialMessages.value = true;
    _startJoinTimeout();
    final me = Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    // If the socket is down it reconnects by itself and joins on connect.
    socketService.joinPrivateChat(
      userId: me,
      receiverId: memberData.userId.toString(),
    );
  }

  /// First visible item and its offset, to restore after prepending.
  ItemPosition? _topAnchor() {
    final visible = itemPositionsListener.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return visible.isEmpty ? null : visible.first;
  }

  /// Keeps the message the user was looking at in exactly the same place
  /// after [prepended] older messages were inserted above it.
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
  /// when the API has no more; dedupes by id (page offsets shift when new
  /// messages arrive while the chat is open).
  Future<void> loadOlderPrivateMessages() async {
    if (privateChatId.value.isEmpty || _messages.isEmpty || !_historyLoaded) {
      return;
    }
    final retryAfter = _olderRetryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) return;

    final page = _pager.begin();
    if (page == null) return;

    isLoadingOlderMessages.value = true;
    final anchor = _topAnchor();

    try {
      log("OLDER MESSAGE API CALL => page=$page");
      final result = await MessageRepo.privateChatHistory(
        chatId: privateChatId.value,
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
      final merged = ChatScreenRules.merge(_messages, older.reversed.toList());
      _pager.complete(
        page: page,
        receivedCount: older.length,
        hasNextPage: result.pagination?.hasNextPage,
      );
      privateCurrentPage.value = _pager.lastLoadedPage;

      if (merged.added > 0) {
        _messages
          ..clear()
          ..addAll(merged.messages);
        updateMessageStream();
        _restoreAnchor(anchor, merged.prepended);
      }
    } catch (e) {
      log("Load Older Private Messages Error: $e");
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
    if (!_historyLoaded || privateChatId.value.isEmpty) return;
    if (_historyRequestInFlight) return;
    _historyRequestInFlight = true;

    try {
      final wasAtBottom = isUserAtBottom();
      var appended = 0;

      for (var page = 1; page <= 5; page++) {
        final result = await MessageRepo.privateChatHistory(
          chatId: privateChatId.value,
          page: page,
          limit: ChatScreenRules.pageSize,
        );
        if (isClosed || result.status != true) return;

        final batch = result.messageData ?? [];
        final merged = ChatScreenRules.merge(_messages, batch.reversed.toList());
        final overlapped = merged.added < batch.length;
        if (merged.added > 0) {
          appended += merged.added - merged.prepended;
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
        _scheduleMarkPrivateRead();
      }
    } catch (e) {
      log("Sync newer private messages error: $e");
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
      await loadOlderPrivateMessages();
      final index = _messages.indexWhere((e) => e.id == messageId);
      if (index != -1) return index;
      if (_messages.length == before && !_pager.hasMore) break;
    }
    return _messages.indexWhere((e) => e.id == messageId);
  }
}
