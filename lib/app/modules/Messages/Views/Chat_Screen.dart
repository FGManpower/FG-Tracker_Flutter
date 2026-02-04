import 'package:fgtracker/app/Core/constant/BottomSheet/ChatBottomSheet.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/Controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/theme/AppText.dart';

import '../../../Core/values/Dialog/Common_dialog.dart';


import '../../Walkie-talkie/Controller/walkieController.dart';
import '../widgets/ChatInputArea.dart';
import '../widgets/ChatList.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  final wc = Get.put(WalkieController());

  Future<void> _sendMessage() async {
    await controller.sendMessage(textController: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final userData = controller.memberData;

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackPressed(context,
            groupID: int.parse(userData.groupId.toString()));
        return false;
      },
      child: Scaffold(
        backgroundColor: ToggleThemeData.chatBackground,
        resizeToAvoidBottomInset: true,
        appBar: CommonChatAppBar(
          profileImageUrl:
              "${ConstRes.aImageBaseUrl}${userData.profileImage ?? ""}",
          userName: userData.name ?? "",
          groupName: controller.arguments?['groupName'],
          onBackTap: () {
            controller.handleBackPressed(context,
                groupID: int.parse(userData.groupId.toString()));
          },
          onCallTap: () {
            ChatBottomSheet.showCallOptions(context, onAudioCall: () {
              controller.startCall(
                context,
                callerId:
                    Global.storageServices.get(PrefConst.userId).toString(),
                remoteUserId: controller.memberData.userId.toString(),
                is_video: false,
                callerName: controller.memberData.name,
              );
            }, onWalkieTalkieCall: () async {
              WalkieController().startServices(
                  callerName: controller.memberData.name.toString(),
                  profileImage: controller.memberData.profileImage,
                  remoteUserId: controller.memberData.userId.toString());
            });
          },
          onVideoTap: () {
            controller.startCall(
              context,
              callerId: Global.storageServices.get(PrefConst.userId).toString(),
              remoteUserId: controller.memberData.userId.toString(),
              is_video: true,
              callerName: controller.memberData.name,
            );
          },
          onGroupExit: () {
            CommonDialog.ConfirmationDialog(
              title: AppText.areYouSure,
              content: AppText.doYouWantToExitGroup,
              onConfirm: () {
                MemberController().exitGroup(context,
                    groupId: userData.groupId.toString());
              },
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ChatList(
                  controller: controller,
                  scrollController: controller.scrollController,
                ),
              ),
              ChatInputArea(
                messageText: controller.messageText,
                imagePath: controller.imagePath,
                isSending: controller.isSending,
                textController: _controller,
                scrollController: controller.scrollController,
                onSend: _sendMessage,
                onImageSelected: (path) {
                  controller.imagePath.value = path;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
