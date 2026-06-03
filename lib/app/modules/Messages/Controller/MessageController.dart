import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import 'Socket_Message_Services.dart';

class MessageController extends GetxController {
  final socketService = SocketMessageService.instance;
  final ScrollController scrollController = ScrollController();

  RxList<MessageData> messageData = <MessageData>[].obs;
  RxString imagePath = "".obs;
  RxBool isSending = false.obs;
  RxString messageText = "".obs;

  late MemberData memberData;
  Map<String, dynamic>? arguments = Get.arguments;
  RxBool isCreator=false.obs;

  @override
  void onInit() {
    super.onInit();
    memberData = arguments?['userData'];
    _initializeChat();
  }

  void _initializeChat() {
    final userId = memberData.userId.toString();
    final groupId = memberData.groupId!;
    try{
      TrackingController.instance.initializeLocation();
    }catch(e){
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
      } else if (text.isNotEmpty) {
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

  Future<void> uploadAudio(String path) async {

    var result = await MessageRepo.uploadChatAudio(path);

    if (result.status == true) {
      socketService.sendMessage(
        messageType: "audio",
        receiverId: memberData.userId.toString(),
        groupId: memberData.groupId!,
        content: result.filename!,
      );
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
        isCreator.value= result.isCreator!;
        scrollToBottom();
      } else {
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      log("History Error: $e");
    }
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
    imagePath.value = "";
    isSending.value = false;

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
}
