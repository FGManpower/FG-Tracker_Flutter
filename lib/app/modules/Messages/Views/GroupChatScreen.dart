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
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(
                Icons.group,
                color: Colors.deepPurple,
              ),
            ),

            SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.groupName,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  "Group Chat",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: GroupChatList(
                controller: controller,
                scrollController: controller.scrollController,
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ChatInputArea(
                messageText: controller.messageText,
                imagePath: controller.imagePath,
                isSending: controller.isSending,
                textController: textController,
                scrollController: controller.scrollController,

                onSend: () {
                  controller.sendMessage(
                    textController: textController,
                  );
                },

                onImageSelected: (path) {
                  controller.imagePath.value = path;
                },

                onVoiceSend: (voicePath) {
                  controller.uploadAudio(voicePath);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}