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
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../routes/app_pages.dart';
import 'Socket_Message_Services.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessageController extends GetxController with WidgetsBindingObserver {
  final socketService = SocketMessageService.instance;
  final ItemScrollController itemScrollController = ItemScrollController();

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final List<MessageData> _messages = [];

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
  Map<String, dynamic>? arguments = Get.arguments;
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

  Timer? _floatingDateTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    memberData = arguments?['userData'];

    _initializeChat();
    itemPositionsListener.itemPositions.addListener(_onScrollDateChanged);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageStreamController.close();
    _floatingDateTimer?.cancel();
    super.onClose();
  }

  @override
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

    if (index == -1) return;

    highlightedMessageId.value = messageId;

    await itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    await Future.delayed(const Duration(seconds: 2));

    highlightedMessageId.value = -1;
  }

  void _initializeChat() {
    final userId = memberData.userId.toString();
    final groupId = memberData.groupId!;
    try {
      TrackingController.instance.initializeLocation();
    } catch (e) {
      log("==============MessageException======${e.toString()}");
    }

    ChatStateTracker.isChatCallScreenOpen = true;

    socketService.init(
      ConstRes.socketUrl,
      userId: userId,
      groupId: groupId,
    );

    socketService.RecievedMessage(
      senderId: Global.storageServices.get(PrefConst.userId).toString(),
      recieverId: userId,
      groupId: groupId,
      callback: (message) {
        print(message);
        _messages.add(MessageData.fromJson(message));
        updateMessageStream();
        scrollToBottom();

        // if (isUserAtBottom()) {
        socketService.markSeen(
          Global.storageServices.get(PrefConst.userId).toString(),
          groupId,
        );
        // }
      },
    );

    socketService.listenSeenUpdate(
      groupId: groupId,
      callback: (data) {
        final List updatedIds = data["messageIds"] ?? [];

        for (var msg in _messages) {
          if (updatedIds.contains(msg.id)) {
            msg.seenCount = (msg.seenCount ?? 0) + 1;
          }
        }

        updateMessageStream();
      },
    );

    socketService.listenMessageEdited(
      callback: (data) {
        final messageId = int.tryParse(
          data["messageId"].toString(),
        );

        if (messageId == null) return;

        final index = _messages.indexWhere(
          (message) => message.id == messageId,
        );

        if (index == -1) return;

        _messages[index].content = data["content"];

        _messages[index].isEdited = data["isEdited"] ?? true;

        _messages[index].editedAt = data["editedAt"];

        updateMessageStream();

        log("PRIVATE MESSAGE EDITED => $messageId");
      },
    );

    socketService.listenMessageDeleted(
      callback: (data) {
        final int? messageId = data["messageId"];
        if (messageId == null) return;

        if (pinnedMessage.value?.id == messageId) {
          pinnedMessage.value = null;
          showPinnedBanner.value = false;
        }

        _messages.removeWhere((e) => e.id == messageId);
        updateMessageStream();
        log("Message Deleted => $messageId");
      },
    );

    socketService.listenPinMessage(
      callback: (data) {
        print("📌 PRIVATE MESSAGE PINNED =====> $data");

        final messageId = int.tryParse(
          data["messageId"].toString(),
        );

        if (messageId == null) return;

        if (data["chatType"] != "private") return;

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
        print("📌 PRIVATE MESSAGE UNPINNED =====> $data");

        if (data["chatType"] != "private") return;

        final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

        final otherUserId = memberData.userId.toString();

        final senderId = data["senderId"].toString();
        final receiverId = data["receiverId"].toString();

        final isSameChat =
            (senderId == currentUserId &&
                receiverId == otherUserId) ||
                (senderId == otherUserId &&
                    receiverId == currentUserId);

        if (!isSameChat) return;

        pinnedMessage.value = null;
        showPinnedBanner.value = false;

        updateMessageStream();

        print("✅ PRIVATE PIN REMOVED FROM UI");
      },
    );
    getMessageHistory(userId, groupId);
  }

  bool isUserAtBottom() {
    if (_messages.isEmpty) return true;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return false;

    final maxVisible =
        positions.map((e) => e.index).reduce((a, b) => a > b ? a : b);

    return maxVisible >= _messages.length - 2;
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
      if (hasImages) {
        final imagesCopy = List<File>.from(imagePaths);

        for (final image in imagesCopy) {
          final result = await MessageRepo.uploadChatImage(image);

          if (result.status == true && result.filename != null) {
            socketService.sendMessage(
              messageType: "image",
              receiverId: memberData.userId.toString(),
              groupId: memberData.groupId!,
              content: result.filename!,
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );
          } else {
            CommonDialog.errorMessage(
              "Failed to upload ${image.path}",
            );
          }
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

          await uploadVideoAtIndex(
            vPath,
            text,
            currentIndex,
          );

          uploadingVideoIndexes.remove(currentIndex);
          videoUploadProgress.remove(currentIndex);
        }

        clearVideos();
      }

      if (hasDocument) {
        await uploadDocument(documentPath.value, text);
        documentPath.value = "";
      }

      if (!hasMedia && text.isNotEmpty) {
        socketService.sendMessage(
          messageType: "text",
          receiverId: memberData.userId.toString(),
          groupId: memberData.groupId!,
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
      socketService.sendMessage(
        messageType: "audio",
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
        content: result.filename!,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );
      clearReply();
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
        socketService.sendMessage(
          messageType: "video",
          receiverId: memberData.userId.toString(),
          groupId: memberData.groupId!,
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
        socketService.sendMessage(
          messageType: "video",
          receiverId: memberData.userId.toString(),
          groupId: memberData.groupId!,
          content:
              "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );
      }
    } catch (e, stack) {
    } finally {
      isUploadingVideo.value = false;
      clearReply();
    }
  }

  Future<void> uploadDocument(String path, String caption) async {
    var result = await MessageRepo.uploadChatDocument(path);

    if (result.status == true) {
      socketService.sendMessage(
        messageType: "document",
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
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
      socketService.sendMessage(
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
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
      socketService.sendMessage(
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
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
    socketService.deleteMessage(
      messageId: messageId,
      userId: Global.storageServices.get(PrefConst.userId).toString(),
      deleteType: deleteType,
    );
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
        scrollToBottom();
      } else {
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      log("History Error: $e");
    }
  }
  void setReply(MessageData message) {
    replyMessage.value = message;
  }

  void clearReply() {
    replyMessage.value = null;
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_messages.isEmpty) return;
      if (itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: _messages.length - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void handleBackPressed(BuildContext context, {required int groupID}) {
    final userId = Global.storageServices.get(PrefConst.userId).toString();

    socketService.leaveUserFromGroup(userId, groupID);
    // socketService.disconnectSocket();

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

  startCall(
    BuildContext context, {
    required String callerId,
    required String remoteUserId,
    required bool is_video,
    dynamic offer,
    dynamic callerName,
  }) {
    Get.toNamed(
      Routes.callScreen,
      arguments: {
        "callerId": callerId,
        "remoteUserId": remoteUserId,
        "offer": offer,
        "is_video": is_video,
        "callerName": callerName,
        "callType": "outGoing",
      },
    );
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
    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    final otherUserId = memberData.userId.toString();

    socketService.pinMessage(
      chatType: "private",
      senderId: currentUserId,
      receiverId: otherUserId,
      messageId: message.id!,
      pinnedByName:
      Global.storageServices.get(PrefConst.userName) ?? "User",
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
}
