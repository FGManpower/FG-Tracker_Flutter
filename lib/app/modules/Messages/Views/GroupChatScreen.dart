import 'package:fgtracker/app/modules/Messages/widgets/ChatInputArea.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';




import '../Controller/GroupChatController.dart';

class GroupChatScreen
    extends GetView<GroupMessageController> {

  GroupChatScreen({super.key});

  final TextEditingController
  textController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          controller.groupName,
        ),
      ),

      body: Column(

        children: [

          Expanded(

            child: GroupChatList(

              controller:
              controller,

              scrollController:
              controller
                  .scrollController,
            ),
          ),

          ChatInputArea(

            messageText:
            controller.messageText,

            imagePath:
            controller.imagePath,

            isSending:
            controller.isSending,

            textController:
            textController,

            scrollController:
            controller
                .scrollController,

            onSend: () {

              controller.sendMessage(
                textController:
                textController,
              );
            },

            onImageSelected:
                (path) {

              controller.imagePath
                  .value = path;
            },

            onVoiceSend:
                (voicePath) {

              controller.uploadAudio(
                voicePath,
              );
            },
          )
        ],
      ),
    );
  }
}