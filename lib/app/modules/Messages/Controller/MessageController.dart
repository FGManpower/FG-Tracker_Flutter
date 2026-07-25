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

class MessageController extends GetxController with WidgetsBindingObserver {
  final socketService = SocketMessageService.instance;
  final ScrollController scrollController = ScrollController();

  RxList<MessageData> messageData = <MessageData>[].obs;
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

  Map<int, GlobalKey> messageKeys = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    memberData = arguments?['userData'];
    _initializeChat();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
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
  Future<void> scrollToMessage(int messageId) async {
    debugPrint("========== Scroll ==========");
    debugPrint("ReplyId: $messageId");

    highlightedMessageId.value = messageId;

    await Future.delayed(const Duration(milliseconds: 100));

    final key = messageKeys[messageId];

    debugPrint("Key exists: ${key != null}");
    debugPrint("Context: ${key?.currentContext}");

    if (key?.currentContext != null) {
      debugPrint("Scrollable.ensureVisible called");

      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint("Context is NULL");
    }

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
        messageData.add(MessageData.fromJson(message));
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

        for (var msg in messageData) {
          if (updatedIds.contains(msg.id)) {
            msg.seenCount = (msg.seenCount ?? 0) + 1;
          }
        }

        messageData.refresh();
      },
    );

    getMessageHistory(userId, groupId);
  }

  bool isUserAtBottom() {
    if (!scrollController.hasClients) return false;

    return scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 50;
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

  Future<void> getMessageHistory(String recieverId, int groupId) async {
    try {
      var result = await MessageRepo.MessageHistory(
        recieverId: recieverId,
        groupId: groupId,
      );

      if (result.status == true) {
        // socketService.markSeen(memberData.userId.toString(), groupId);
        messageData.value = result.messageData!;
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
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
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

    messageData.clear();
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
