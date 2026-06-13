import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Model/LocationDataRes.dart';
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

  final ScrollController scrollController = ScrollController();

  RxList<MessageData> messageData = <MessageData>[].obs;
  final Rx<Uint8List?> videoThumbnail = Rx<Uint8List?>(null);
  final RxString videoDuration = ''.obs;
  RxList<LocationData> groupMembers = <LocationData>[].obs;

  RxBool isLoadingMembers = false.obs;

  RxString imagePath = "".obs;
  RxString videoPath = "".obs;
  RxBool isSending = false.obs;

  RxString messageText = "".obs;

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
        messageData.add(
          MessageData.fromJson(message),
        );

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

      if (imagePath.value.isNotEmpty) {
        var result = await MessageRepo.uploadChatImage(
          imagePath.value,
        );

        if (result.status == true && result.filename != null) {
          socketService.sendGroupMessage(
            groupId: groupId,
            content: result.filename!,
            messageType: "image",
          );

          if (text.isNotEmpty) {
            await Future.delayed(
              const Duration(
                milliseconds: 300,
              ),
            );

            socketService.sendGroupMessage(
              groupId: groupId,
              content: text,
              messageType: "text",
            );
          }
        } else {
          CommonDialog.errorMessage(
            "Image upload failed",
          );
        }

        imagePath.value = "";

        textController.clear();
      } else if (videoPath.isNotEmpty) {
        await uploadVideo(videoPath.value);
        if (text.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
          socketService.sendGroupMessage(
            messageType: "text",
            groupId: groupId,
            content: text,
          );
        }

        videoPath.value = "";
        textController.clear();
      } else if (text.isNotEmpty) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: text,
          messageType: "text",
        );

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
        );
      }
    } catch (e) {
      log(
        "GROUP AUDIO ERROR => $e",
      );
    }
  }

  Future<void> uploadVideo(String path) async {
    try {
      var result = await MessageRepo.uploadChatVideo(path);

      if (result.status == true) {
        socketService.sendGroupMessage(
          groupId: groupId,
          content: result.filename!,
          messageType: "video",
        );
      }
    } catch (e) {
      log(
        "GROUP AUDIO ERROR => $e",
      );
    }
  }

  Future<void> getGroupMessages() async {
    try {
      var result = await MessageRepo.groupMessageHistory(
        groupId: groupId,
      );

      if (result.status == true) {
        messageData.value = result.messageData ?? [];

        scrollToBottom();
      } else {
        CommonDialog.errorMessage(
          result.message,
        );
      }
    } catch (e) {
      log(
        "GROUP HISTORY ERROR => $e",
      );
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
    Future.delayed(
      const Duration(
        milliseconds: 100,
      ),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
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

  void handleBackPressed(BuildContext context) {
    socketService.disconnectSocket();

    messageData.clear();

    messageText.value = "";

    imagePath.value = "";

    isSending.value = false;

    Navigator.of(context).pop();
  }

  @override
  void onClose() {
    socketService.disconnectSocket();

    scrollController.dispose();

    super.onClose();
  }
}
