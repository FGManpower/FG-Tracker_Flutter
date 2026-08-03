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
  final ItemScrollController itemScrollController =
  ItemScrollController();

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
  RxString videoPath = "".obs;
  RxString documentPath = "".obs;
  RxBool isSending = false.obs;
  RxString messageText = "".obs;
  final RxBool isUploadingVideo = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  late MemberData memberData;
  Map<String, dynamic>? arguments = Get.arguments;
  RxBool isCreator = false.obs;

  final Rx<Uint8List?> videoThumbnail = Rx<Uint8List?>(null);
  final RxString videoDuration = ''.obs;
  Rx<MessageData?> replyMessage = Rx<MessageData?>(null);
  RxInt highlightedMessageId = (-1).obs;
  final RxBool showEmoji = false.obs;


  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    memberData = arguments?['userData'];
    debugPrint("========== CHAT OPEN ==========");
    debugPrint("USER ID      : ${memberData.userId}");
    debugPrint("USER NAME    : ${memberData.name}");
    debugPrint("USER IMAGE   : ${memberData.profileImage}");
    debugPrint("GROUP ID     : ${memberData.groupId}");
    _initializeChat();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageStreamController.close();
    super.onClose();
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
            videoPath.value = file.path;
            await generateVideoPreview(file.path);
          }
        } else if (response.exception != null) {
          debugPrint("Lost data exception: ${response.exception}");
        }
      } catch (e) {
        debugPrint("retrieveLostData error: $e");
      }
    }
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

    socketService.listenMessageDeleted(
      callback: (data) {
        final int? messageId = data["messageId"];

        if (messageId == null) return;

        _messages.removeWhere(
              (e) => e.id == messageId,
        );

        updateMessageStream();

        log("Message Deleted => $messageId");
      },
    );

    getMessageHistory(userId, groupId);
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

  Future<void> sendMessage(
      {required TextEditingController textController}) async {
    if (isSending.value) return;
    isSending.value = true;

    final text = textController.text.trim();

    try {
      if (imagePaths.isNotEmpty) {
        for (final image in imagePaths) {
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
            CommonDialog.errorMessage("Failed to upload ${image.path}");
          }
        }
        imagePaths.clear();
        ;
        textController.clear();
        clearReply();
      } else if (videoPath.isNotEmpty) {
        await uploadVideo(videoPath.value, text);
        videoPath.value = "";
        textController.clear();
        clearReply();
      } else if (documentPath.isNotEmpty) {
        await uploadDocument(documentPath.value, text);
        documentPath.value = "";
        textController.clear();
        clearReply();
      }
      else if (text.isNotEmpty) {
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

        textController.clear();
        clearReply();
      }
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

  Future<void> uploadVideo(
    String path, String caption,
  ) async {
    isUploadingVideo.value = true;
    final thumbnailPath = await generateThumbnailFile(path);

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
        }
      },
    );
    if (result.status == true) {
      socketService.sendMessage(
        messageType: "video",
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
        content: "${result.videoUrl}||${result.thumbnail}||${result.duration}",
        caption: caption,
        replyId: replyMessage.value?.id,
        replyMessage: replyMessage.value?.content,
        replyType: replyMessage.value?.messageType,
        replySender: replyMessage.value?.senderName,
      );
      isUploadingVideo.value = false;
    }
    clearReply();
  }

  Future<void> uploadDocument(String path,  String caption) async {
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

  Future<void> deleteMessage({
    required int messageId,
    required String deleteType,
  }) async {
    socketService.deleteMessage(
      messageId: messageId,
      userId: Global.storageServices
          .get(PrefConst.userId)
          .toString(),
      deleteType: deleteType,
    );
  }




  Future<void> getMessageHistory(String recieverId, int groupId) async {
    try {
      var result = await MessageRepo.MessageHistory(
        recieverId: recieverId,
        groupId: groupId,
      );

      if (result.status == true) {
        // socketService.markSeen(memberData.userId.toString(), groupId);
        _messages
          ..clear()
          ..addAll(result.messageData!);

        updateMessageStream();
        isCreator.value = result.isCreator!;
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
    socketService.disconnectSocket();

    _messages.clear();
    messageText.value = "";
    imagePaths.clear();
    isSending.value = false;
    clearReply();

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
}
