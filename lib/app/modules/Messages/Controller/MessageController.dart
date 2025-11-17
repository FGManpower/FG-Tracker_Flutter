import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/deep_Link/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../WebRtcCall/call_service.dart';
import 'Socket_Message_Services.dart';

class MessageController extends GetxController {
  final socketService = SocketMessageService.instance;
  final ScrollController scrollController = ScrollController();

  RxList<MessageData> messageData = <MessageData>[].obs;
  RxString imagePath = "".obs;
  RxBool isSending = false.obs;
  RxString messageText = "".obs;

  late MemberData memberData;
  late CallService callService;

  Map<String, dynamic>? arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    memberData = arguments?['userData'];

    _initializeChat();
    _initializeCallService();
  }

  void _initializeChat() {
    final userId = memberData.userId.toString();
    final groupId = memberData.groupId!;

    ChatStateTracker.isChatCallScreenOpen = true;

    socketService.init(groupId: groupId, userId: userId, ConstRes.socketUrl);

    socketService.socket?.off('receive_message');
    socketService.RecievedMessage(
      senderId: Global.storageServices.get(PrefConst.userId).toString(),
      recieverId: userId,
      groupId: groupId,
      callback: (message) {
        messageData.add(MessageData.fromJson(message));
        scrollToBottom();
      },
    );

    getMessageHistory( userId, groupId);
  }

  void _initializeCallService() {
    callService = CallService(
      userId: Global.storageServices.get(PrefConst.userId).toString(),
      debug: true,
    );

    callService.init();

    callService.onIncomingCall = (data) {
      Get.defaultDialog(
        title: "Incoming Call",
        middleText: "From: ${data['caller_name'] ?? data['from']}",
        onConfirm: () async {
          Get.back();
          await callService.acceptCall(incomingCall: data);
        },
        onCancel: () => callService.rejectCall(incomingCall: data),
      );
    };
  }

  Future<void> sendMessage({required TextEditingController textController}) async {
    if (isSending.value) return;
    isSending.value = true;

    final text = textController.text.trim();

    try {
      // Image message
      if (imagePath.isNotEmpty) {
        var result = await MessageRepo.uploadChatImage(imagePath.value);

        if (result.status == true && result.filename != null) {
          socketService.sendMessage(
            messageType: "image",
            receiverId: memberData.userId.toString(),
            groupId: memberData.groupId!,
            content: result.filename!,
          );

          if (text.isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 300));
            socketService.sendMessage(
              messageType: "text",
              receiverId: memberData.userId.toString(),
              groupId: memberData.groupId!,
              content: text,
            );
          }
        } else {
          CommonDialog.errorMessage("Image upload failed.");
        }

        imagePath.value = "";
        textController.clear();
      }

      // Text message
      else if (text.isNotEmpty) {
        socketService.sendMessage(
          messageType: "text",
          receiverId: memberData.userId.toString(),
          groupId: memberData.groupId!,
          content: text,
        );
        textController.clear();
      }

      scrollToBottom();
    } catch (e) {
      log("Error sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  Future<void> getMessageHistory( String recieverId, int groupId) async {
    try {
      // Loading().showloading(context: context);

      var result = await MessageRepo.MessageHistory(recieverId: recieverId, groupId: groupId);



      if (result.status == true) {
        messageData.value = result.messageData!;
        scrollToBottom();
      } else {
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      // Loading().dismissloading(context: context);
      log("History Error: $e");
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
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
    imagePath.value = "";
    isSending.value = false;

    ChatStateTracker.isChatCallScreenOpen = false;

    Navigator.of(context).pop();
  }
}
