import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final RxBool isPeerOnline = false.obs;
  final RxString peerLastSeen = "Offline".obs;
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

    log("========== CHAT DEBUG 7: MEMBER DATA ==========");
    log("MEMBER DATA => $memberData");
    log("MEMBER USER ID => ${memberData?.userId}");

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

  @override
  void onClose() {
    ChatTranslationService.instance.resetVisibility();
    ChatTranslationService.instance.stopAudio();
    WidgetsBinding.instance.removeObserver(this);
    itemPositionsListener.itemPositions.removeListener(_onScrollDateChanged);
    itemPositionsListener.itemPositions.removeListener(_onScrollForOlderMessages);
    itemPositionsListener.itemPositions.removeListener(_updateScrollBottomState);
    textEditingController.dispose();
    _messageStreamController.close();
    _floatingDateTimer?.cancel();
    socketService.disconnectPrivateChatSocket();
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
    if (state == AppLifecycleState.resumed) {
      final picker = ImagePicker();
      try {
        final LostDataResponse response = await picker.retrieveLostData();
        if (!response.isEmpty && response.file != null) {
          final file = File(response.file!.path);
          if (await file.exists()) {
            debugPrint("Recovered lost video: ${file.path}");
            await addVideo(file.path);
          }
        } else if (response.exception != null) {
          debugPrint("Lost data exception: ${response.exception}");
        }
      } catch (e) {
        debugPrint("retrieveLostData error: $e");
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
      debugPrint("Video preview error: $e");
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

  Future<void> scrollToMessage(int messageId) async {
    final index = _messages.indexWhere((e) => e.id == messageId);

    if (index == -1 || !itemScrollController.isAttached) return;

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

    final bool isPrivateChat = arguments?['type'] == 'chatScreen' ||
        arguments?['chatType'] == 'private' ||
        arguments?['groupId'] == 0 ||
        memberData.groupId == null ||
        memberData.groupId == 0;

    log("=================================");
    log("CHAT TYPE => ${isPrivateChat ? 'PRIVATE' : 'GROUP'}");
    log("CURRENT USER ID => $currentUserId");
    log("RECEIVER ID => $receiverId");
    log("GROUP ID => ${memberData.groupId}");
    log("=================================");
    log("[CHAT-PERF] 1. Initialization started: ${stopwatch.elapsedMilliseconds} ms");

    try {
      GroupTrackingController.instance.initializeLocation();
      log("[CHAT-PERF] Location initialization called: ${stopwatch.elapsedMilliseconds} ms");
    } catch (e) {
      log("==============MessageException======${e.toString()}");
    }

    ChatStateTracker.isChatCallScreenOpen = true;

    if (isPrivateChat) {
      final passedChatId = arguments?['chatId']?.toString();

      isLoadingInitialMessages.value = true;
      final hasPassedChatId = passedChatId != null &&
          passedChatId.isNotEmpty &&
          passedChatId != 'null';

      if (!hasPassedChatId) {
        Future.delayed(const Duration(seconds: 8), () {
          if (!isClosed && privateChatId.value.isEmpty) {
            isLoadingInitialMessages.value = false;
          }
        });
      }
      if (passedChatId != null &&
          passedChatId.isNotEmpty &&
          passedChatId != 'null') {
        privateChatId.value = passedChatId;

        getPrivateMessageHistory(passedChatId).then((_) {
          if (!isClosed) {
            socketService.markPrivateSeen(
              chatId: passedChatId,
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
            isLoadingInitialMessages.value = false;
            return;
          }

          privateChatId.value = chatId;

          log("PRIVATE CHAT ID => $chatId");

          if (passedChatId == null ||
              passedChatId.isEmpty ||
              passedChatId == 'null') {
            await getPrivateMessageHistory(chatId);

            socketService.markPrivateSeen(
              chatId: chatId,
              userId: currentUserId,
              otherUserId: receiverId,
            );
          }
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

            final alreadyExists = _messages.any(
                  (msg) => msg.id == messageData.id && messageData.id != null,
            );

            if (!alreadyExists) {
              final wasAtBottom = isUserAtBottom();
              final isMyMessage =
                  messageData.senderId?.toString() == currentUserId.toString();

              _messages.add(messageData);
              updateMessageStream();

              if (isMyMessage || wasAtBottom) {
                scrollToBottom();
              } else {
                unreadBelowCount.value++;
                showScrollToBottom.value = true;
              }
            }

            if (messageData.id != null) {
              socketService.markPrivateDelivered(
                messageIds: [messageData.id!],
                userId: currentUserId,
                otherUserId: receiverId,
              );
            }

            if (privateChatId.value.isNotEmpty) {
              socketService.markPrivateSeen(
                chatId: privateChatId.value,
                userId: currentUserId,
                otherUserId: receiverId,
              );
            }
          } catch (e) {}
        },
      );

      socketService.listenPrivateChatCleared(
        handlePrivateChatCleared,
      );

      socketService.listenPrivateMessagesDelivered(
        callback: (data) {},
      );

      socketService.listenPrivateMessagesSeenUpdate(
        callback: (data) {
          final dataChatId = data["chatId"]?.toString();

          if (privateChatId.value.isNotEmpty &&
              dataChatId != null &&
              dataChatId != privateChatId.value) {
            return;
          }

          final List updatedIds = data["messageIds"] ?? [];

          for (var msg in _messages) {
            if (updatedIds.any(
                  (id) => id.toString() == msg.id.toString(),
            )) {
              msg.seenCount = (msg.seenCount ?? 0) + 1;
            }
          }

          updateMessageStream();
        },
      );

      socketService.listenMessageEdited(
        callback: (data) {
          if (data is! Map) {
            return;
          }

          try {
            final editedMessage = MessageData.fromJson(
              Map<String, dynamic>.from(data),
            );

            final index = _messages.indexWhere(
                  (message) => message.id == editedMessage.id,
            );

            if (index == -1) {
              return;
            }

            _messages[index] = editedMessage;

            updateMessageStream();
          } catch (e) {}
        },
      );

      socketService.listenMessageDeleted(
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

            if (deleteType == "for_me") {
              _messages.removeAt(index);
            } else if (deleteType == "for_everyone") {
              _messages[index].content = "This message was deleted";
              _messages[index].messageType = "text";
            }

            updateMessageStream();
          } catch (e) {}
        },
      );
    } else {}

    socketService.listenPinMessage(
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
      callback: (data) {
        if (data["chatType"] != "private") return;

        final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

        final otherUserId = memberData.userId.toString();

        final senderId = data["senderId"].toString();
        final receiverId = data["receiverId"].toString();

        final isSameChat =
            (senderId == currentUserId && receiverId == otherUserId) ||
                (senderId == otherUserId && receiverId == currentUserId);

        if (!isSameChat) return;

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
    isSending.value = true;

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
          }

          imagePaths.clear();
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

      textController.clear();
      messageText.value = "";
      clearReply();
      scrollToBottom();
    } catch (e) {
      log("Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> uploadAudio(String path) async {
    var result = await MessageRepo.uploadChatAudio(path);

    if (result.status == true) {
      socketService.sendPrivateMessage(
        messageType: "audio",
        receiverId: memberData.userId.toString(),
        content: result.filename!,
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
        content: "${result.filename}||${result.originalName!}",
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


  Future<void> getPrivateMessageHistory(String chatId) async {
    final apiStopwatch = Stopwatch()..start();

    log("========== HISTORY DEBUG 1: METHOD START ==========");
    log("HISTORY DEBUG => chatId: $chatId");
    log("HISTORY DEBUG => controller closed: $isClosed");

    try {
      privateCurrentPage.value = 1;
      hasMoreOlderMessages.value = true;

      log("========== HISTORY DEBUG 2: BEFORE API CALL ==========");
      log("HISTORY DEBUG => page: 1, limit: 10");

      final result = await MessageRepo.privateChatHistory(
        chatId: chatId,
        page: 1,
        limit: 10,
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

        _messages
          ..clear()
          ..addAll(messages.reversed);

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

        if (result.pagination != null) {
          hasMoreOlderMessages.value =
              result.pagination!.hasNextPage == true;
        } else {
          hasMoreOlderMessages.value = false;
        }

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

        CommonDialog.errorMessage(result.message);
      }
    } catch (e, stackTrace) {
      log("========== HISTORY DEBUG ERROR: EXCEPTION ==========");
      log("HISTORY DEBUG => $e");
      log("HISTORY DEBUG STACKTRACE => $stackTrace");
    } finally {
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

  void handleBackPressed(
    BuildContext context, {
    required int groupID,
  }) {
    final userId = Global.storageServices.get(PrefConst.userId).toString();

    final receiverId = memberData.userId.toString();

    socketService.leavePrivateChat(
      userId: userId,
      receiverId: receiverId,
    );

    socketService.disconnectPrivateChatSocket();

    _messages.clear();
    messageText.value = "";
    imagePaths.clear();
    clearVideos();
    isSending.value = false;
    clearReply();
    pinnedMessage.value = null;
    showPinnedBanner.value = false;
    ChatStateTracker.isChatCallScreenOpen = false;

    Navigator.of(context).pop();
  }



  void startSearch() {
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

  void handlePrivateChatCleared(Map<String, dynamic> data) {
    final conversationId =
        int.tryParse(data['conversationId']?.toString() ?? '');

    if (conversationId == null) return;

    log(
      "PRIVATE CHAT CLEARED => conversationId=$conversationId",
    );

    messageData.clear();
    updateMessageStream();

    log("CHAT MESSAGES CLEARED FROM UI");
  }

  void clearPrivateChat() {
    if (privateChatId.value.isEmpty) {
      log("CLEAR PRIVATE CHAT => CHAT ID NOT FOUND");
      return;
    }

    log(
      "CLEAR PRIVATE CHAT => chatId=${privateChatId.value}",
    );

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

  Future<void> loadOlderPrivateMessages() async {
    if (isLoadingOlderMessages.value) return;
    if (!hasMoreOlderMessages.value) return;
    if (privateChatId.value.isEmpty) return;
    if (_messages.isEmpty) return;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return;

    final visible =
        positions.where((position) => position.itemTrailingEdge > 0).toList();

    if (visible.isEmpty) return;

    visible.sort((a, b) => a.index.compareTo(b.index));

    final oldFirstVisibleIndex = visible.first.index;

    isLoadingOlderMessages.value = true;

    try {
      final nextPage = privateCurrentPage.value + 1;
      log("OLDER MESSAGE API CALL => page=$nextPage");
      final result = await MessageRepo.privateChatHistory(
        chatId: privateChatId.value,
        page: nextPage,
        limit: 10,
      );

      if (result.status == true) {
        final olderMessages = result.messageData ?? [];

        if (olderMessages.isNotEmpty) {
          final reversedOlderMessages = olderMessages.reversed.toList();

          _messages.insertAll(
            0,
            reversedOlderMessages,
          );

          privateCurrentPage.value = nextPage;

          updateMessageStream();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!itemScrollController.isAttached) return;

            itemScrollController.jumpTo(
              index: oldFirstVisibleIndex + reversedOlderMessages.length,
            );
          });
        }

        if (result.pagination != null) {
          hasMoreOlderMessages.value = result.pagination!.hasNextPage == true;
        } else {
          hasMoreOlderMessages.value = olderMessages.length >= 50;
        }
      }
    } catch (e) {
      log("Load Older Private Messages Error: $e");
    } finally {
      isLoadingOlderMessages.value = false;
    }
  }
}
