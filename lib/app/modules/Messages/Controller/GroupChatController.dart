import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
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
import '../../../Core/values/global.dart';

import '../../../Data/Repositories/GetMessageRepo.dart';

import '../../../Model/GetMessage.dart';

import 'Socket_Message_Services.dart';

class GroupMessageController extends GetxController {
  final socketService = SocketMessageService.instance;

  final ItemScrollController itemScrollController =
  ItemScrollController();

  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();
  final List<MessageData> _messages = [];

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
  final Rx<Uint8List?> videoThumbnail = Rx<Uint8List?>(null);
  final RxString videoDuration = ''.obs;
  RxList<LocationData> groupMembers = <LocationData>[].obs;

  RxBool isLoadingMembers = false.obs;
  final RxBool isUploadingVideo = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  RxList<File> imagePaths = <File>[].obs;
  RxString videoPath = "".obs;
  RxString documentPath = "".obs;
  RxBool isSending = false.obs;
  RxBool isLoading = true.obs;
  RxString messageText = "".obs;
  final RxBool showEmoji = false.obs;

  Rx<MessageData?> replyMessage = Rx<MessageData?>(null);
  RxInt highlightedMessageId = (-1).obs;


  Future<void> scrollToMessage(int messageId) async {
    final index =
    _messages.indexWhere((e) => e.id == messageId);

    debugPrint("========== Reply Scroll ==========");
    debugPrint("ReplyId: $messageId");
    debugPrint("Found Index: $index");
    debugPrint("Total Messages: ${_messages.length}");

    if (index != -1) {
      debugPrint("Message at Index: ${_messages[index].id}");
    }

    if (index == -1) return;

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

  late String groupName;

  late String groupImage;

  @override
  void onInit() {
    super.onInit();

    groupId = int.parse(arguments?["groupId"]);

    groupName = arguments?["groupName"] ?? "";

    groupImage = arguments?["groupImage"] ?? "";

    initializeGroupChat();
  }
  void toggleEmoji() {
    showEmoji.toggle();
  }

  void hideEmoji() {
    showEmoji.value = false;
  }
  void initializeGroupChat() {
    final currentUserId =
        Global.storageServices.get(PrefConst.userId).toString();

    socketService.init(
      ConstRes.socketUrl,
      userId: currentUserId,
      groupId: groupId,
    );

    socketService.joinGroupChat(
      groupId: groupId,
      userId: currentUserId,
    );

    socketService.receiveGroupMessage(
      callback: (message) {
        _messages.add(
          MessageData.fromJson(message),
        );

        updateMessageStream();
        scrollToBottom();
      },
    );

    getGroupMessages();

    getGroupMembers();
  }

  Future<void> sendMessage({
    required TextEditingController textController,
  }) async {
    if (isSending.value) {
      return;
    }

    isSending.value = true;

    try {
      final text = textController.text.trim();
print("TEXT=======$text");
      if (imagePaths.isNotEmpty) {
        for (final image in imagePaths) {
          final result = await MessageRepo.uploadChatImage(image);
          print("ttryu=======$result");
          if (result.status == true && result.filename != null) {
            socketService.sendGroupMessage(
              groupId: groupId,
              content: result.filename!,
              messageType: "image",
              caption: text,
              replyId: replyMessage.value?.id,
              replyMessage: replyMessage.value?.content,
              replyType: replyMessage.value?.messageType,
              replySender: replyMessage.value?.senderName,
            );

            clearReply();
          } else {
            CommonDialog.errorMessage("Failed to upload ${image.path}");
          }
        }



        imagePaths.clear();
        textController.clear();
      } else if (videoPath.isNotEmpty) {
        await uploadVideo(videoPath.value, text);
        videoPath.value = "";
        textController.clear();
      } else if (documentPath.isNotEmpty) {
        await uploadDocument(documentPath.value, text);

        documentPath.value = "";
        textController.clear();
      } else if (text.isNotEmpty) {


        socketService.sendGroupMessage(
          groupId: groupId,
          content: text,
          messageType: "text",
          replyId: replyMessage.value?.id,
          replyMessage: replyMessage.value?.content,
          replyType: replyMessage.value?.messageType,
          replySender: replyMessage.value?.senderName,
        );

        clearReply();
        textController.clear();
      }

      scrollToBottom();
    } catch (e) {
      log(
        "GROUP SEND ERROR => $e",
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> uploadAudio(String path) async {
    try {
      var result = await MessageRepo.uploadChatAudio(path);

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: result.filename!,
          messageType: "audio",
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
        socketService.sendGroupMessage(
          groupId: groupId,
          messageType: "video",
          content: "${result.videoUrl}||${result.thumbnail}||${result.duration}",
          caption: caption,
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

  Future<void> uploadDocument(String path,   String caption,
      ) async {
    try {
      var result = await MessageRepo.uploadChatDocument(path);

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: "${result.filename}||${result.originalName!}",
          messageType: "document",
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
    try {
      socketService.sendGroupMessage(
        groupId: groupId,
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

  Future<void> getGroupMessages() async {
    isLoading.value = true;

    _messages
      ..clear()
      ..addAll(
        List.generate(
          8,
              (index) => MessageData(
            senderId: index.isEven ? 1 : 2,
            senderName: "Loading",
            messageType: "text",
            content: "Loading message",
            timestamp: DateTime.now().toIso8601String(),
            seenCount: 0,
            senderImage: "",
          ),
        ),
      );

    updateMessageStream();

    try {
      var result = await MessageRepo.groupMessageHistory(
        groupId: groupId,
      );

      if (result.status == true) {
        _messages
          ..clear()
          ..addAll(result.messageData ?? []);

        updateMessageStream();
        scrollToBottom();
      } else {
        CommonDialog.errorMessage(result.message);
        _messages.clear();
        updateMessageStream();
      }
    } catch (e) {
      log("GROUP HISTORY ERROR => $e");
      _messages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGroupMembers() async {
    print(
      "MY USER ID => ${Global.storageServices.get(PrefConst.userId)}",
    );
    try {
      isLoadingMembers.value = true;

      var result = await MessageRepo.getGroupMembers(
        groupId: groupId,
      );

      print(
        "GROUP MEMBERS => ${result.locations?.length}",
      );

      if (result.status == true) {
        groupMembers.value = result.locations ?? [];
      }
    } catch (e) {
      log(
        "GROUP MEMBERS ERROR => $e",
      );
    } finally {
      isLoadingMembers.value = false;
    }
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

  bool isUserAtBottom() {
    if (_messages.isEmpty) return true;

    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) return false;

    final maxVisible = positions
        .map((e) => e.index)
        .reduce((a, b) => a > b ? a : b);

    return maxVisible >= _messages.length - 2;
  }

  Future<void> generateVideoPreview(
    String path,
  ) async {
    try {
      videoThumbnail.value = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 80,
      );

      final controller = VideoPlayerController.file(
        File(path),
      );

      await controller.initialize();

      final duration = controller.value.duration;

      videoDuration.value = formatDuration(duration);

      await controller.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void handleBackPressed(BuildContext context) {
    socketService.disconnectSocket();

    _messages.clear();

    messageText.value = "";

    imagePaths.clear();

    isSending.value = false;

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
    print("==========MessageText${messageText.value}");
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

    // Filter members
    filteredMembers.value = groupMembers
        .where((member) =>
    (member.name?.toLowerCase().contains(query) ?? false) ||
        (member.name?.toLowerCase().contains(query) ?? false))
        .toList();

    showMentionList.value = filteredMembers.isNotEmpty;
  }

  void insertMention({
    required dynamic member, // Change 'dynamic' to your actual model (e.g. GroupMember)
    required TextEditingController textController,
  }) {
    if (mentionStartIndex!.value < 0) return;

    final text = textController.text;
    final cursorPos = textController.selection.baseOffset;

    final displayName = (member.name ?? member.username ?? "User").toString();

    final start = mentionStartIndex!.value;           // int
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

  @override
  void onClose() {
    focusNode.dispose();
    _messageStreamController.close();
    super.onClose();
  }
}
