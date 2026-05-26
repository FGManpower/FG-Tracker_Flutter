import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

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

  RxString imagePath = "".obs;

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
