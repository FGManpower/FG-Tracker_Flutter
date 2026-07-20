
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Walkie-talkie/Controller/walkieController.dart';
import '../widgets/ChatInputArea.dart';
import '../widgets/ChatList.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  final wc = Get.put(WalkieController());
  final groupController = Get.put(GroupController());

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
          controller: controller,
          groupName: controller.arguments?['groupName'],
          onBackTap: () {
            controller.handleBackPressed(context,
                groupID: int.parse(userData.groupId.toString()));
          },
          onCallTap: () {
            controller.startCall(
              context,
              callerId: Global.storageServices.get(PrefConst.userId).toString(),
              remoteUserId: controller.memberData.userId.toString(),
              is_video: false,
              callerName: controller.memberData.name,
            );
            // ChatBottomSheet.showCallOptions(context, onAudioCall: () {
            //   controller.startCall(
            //     context,
            //     callerId:
            //         Global.storageServices.get(PrefConst.userId).toString(),
            //     remoteUserId: controller.memberData.userId.toString(),
            //     is_video: false,
            //     callerName: controller.memberData.name,
            //   );
            // },
            //     onWalkieTalkieCall: () async {
            //   WalkieController().startServices(
            //       callerName: controller.memberData.name.toString(),
            //       profileImage: controller.memberData.profileImage,
            //       remoteUserId: controller.memberData.userId.toString());
            // }
            // );
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
          // onGroupExit: () {
          //   CommonDialog.ConfirmationDialog(
          //     title: AppText.areYouSure,
          //     content: AppText.doYouWantToExitGroup,
          //     onConfirm: () {
          //       if (controller.arguments!['isCreator'].toString() == "true") {
          //         MemberController().exitGroup(context,
          //             groupId: userData.groupId.toString(),
          //             userId: userData.userId.toString());
          //       } else {
          //         MemberController().exitGroup(context,
          //             groupId: userData.groupId.toString(),
          //             userId: Global.storageServices
          //                 .get(PrefConst.userId)
          //                 .toString());
          //       }
          //     },
          //   );
          // },
          // onDeleteGroup: () {
          //   CommonDialog.ConfirmationDialog(
          //     title: AppText.areYouSure,
          //     content: AppText.doYouWantToDeleteGroup,
          //     onConfirm: () {
          //       MemberController().deleteGroup(context,
          //           groupId: userData.groupId
          //               .toString());
          //     },
          //   );
          // },
          onUpdateGroupName: () {
            groupController.groupName.text =
                controller.arguments?['groupName'] ?? "";
            DialogBox().showUpdateGroupBottomSheet(
                context: context,
                controller: groupController,
                groupId: userData.groupId.toString());
          },

          onDeleteMember: () {
            CommonDialog.ConfirmationDialog(
              title: "Remove Member",
              content:
                  "Are you sure you want to remove this member from the group? This action cannot be undone.",
              confirm: "Remove",
              onConfirm: () {
                groupController.deleteGroupMember(context,
                    groupId: userData.groupId.toString(),
                    groupMemberId: controller.memberData.userId.toString());
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
                videoPath: controller.videoPath,
                documentPath: controller.documentPath,
                isSending: controller.isSending,
                textController: _controller,
                scrollController: controller.scrollController,
                videoDuration: controller.videoDuration,
                videoThumbnail: controller.videoThumbnail,
                onSend: _sendMessage,
                onImageSelected: (path) {
                  controller.imagePath.value = path;
                },
                onVoiceSend: (voicePath) {
                  if (Utility.isNotNullEmptyOrFalse(voicePath)) {
                    controller.uploadAudio(voicePath);
                  }
                },
                onvideoSelected: (path) async {
                  Navigator.pop(context);
                  if (Utility.isNotNullEmptyOrFalse(path)) {
                    controller.videoPath.value = path;
                    await controller.generateVideoPreview(
                      path,
                    );
                    controller.update();
                  }
                },
                isUploadingVideo: controller.isUploadingVideo,
                uploadProgress: controller.uploadProgress,
                onDocumentSelected: (path) async {
                  Navigator.pop(context);
                  if (Utility.isNotNullEmptyOrFalse(path)) {
                    controller.documentPath.value = path;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
