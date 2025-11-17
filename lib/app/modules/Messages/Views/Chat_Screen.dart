import 'package:fgtracker/app/Core/constant/BottomSheet/ChatBottomSheet.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/Controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:fgtracker/app/modules/WebRtcCall/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/theme/AppText.dart';
import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/global.dart';
import '../widgets/ChatInputArea.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();
  final MemberController groupController = Get.put(MemberController());

  Future<void> _sendMessage() async {
    await controller.sendMessage(textController: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final userData = controller.memberData;

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackPressed(context, groupID: int.parse(userData.groupId.toString()));
        return false;
      },
      child: Scaffold(
        backgroundColor: ToggleThemeData.chatBackground,
        resizeToAvoidBottomInset: true,
        appBar: CommonChatAppBar(
          profileImageUrl: "${ConstRes.aImageBaseUrl}${userData.profileImage ?? ""}",
          userName: userData.name ?? "",
          groupName: controller.arguments?['groupName'],

          onBackTap: () {
            controller.handleBackPressed(context, groupID: int.parse(userData.groupId.toString()));
          },

          onCallTap: () async {
            ChatBottomSheet.showCallOptions(context,onAudioCall: () async {
              await controller.callService.startCall(
                receiverId: userData.userId.toString(),
                isVideo: false,
                callerName: Global.storageServices.get(PrefConst.userId),
              );

              Get.to(() => CallScreen(
                callService: controller.callService,
                peerId: Global.storageServices.get(PrefConst.userId).toString(),
                isVideo: false,
              ));
            },onWalkieTalkieCall: ()async{

            });

          },

          onVideoTap: () async {
            await controller.callService.startCall(
              receiverId: userData.userId.toString(),
              isVideo: true,
              callerName: Global.storageServices.get(PrefConst.userId),
            );

            Get.to(() => CallScreen(
              callService: controller.callService,
              peerId: Global.storageServices.get(PrefConst.userId).toString(),
              isVideo: true,
            ));
          },

          onGroupExit: () {
            CommonDialog.ConfirmationDialog(
              title: AppText.areYouSure,
              content: AppText.doYouWantToExitGroup,
              onConfirm: () {
                groupController.exitGroup(context, groupId: userData.groupId.toString());
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
