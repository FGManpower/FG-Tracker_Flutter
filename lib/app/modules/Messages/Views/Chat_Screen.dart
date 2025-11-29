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

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final MemberController groupController = Get.put(MemberController());

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
            controller.startCall(context,
                callerId:
                    Global.storageServices.get(PrefConst.userId).toString(),
                remoteUserId: controller.memberData.userId.toString());
            // controller.startAudioCall(controller.memberData.userId.toString());
          },
          onVideoTap: () {
            // controller.startVideoCall(controller.memberData.userId.toString());
          },
          onGroupExit: () {
            CommonDialog.ConfirmationDialog(
              title: AppText.areYouSure,
              content: AppText.doYouWantToExitGroup,
              onConfirm: () {
                groupController.exitGroup(context,
                    groupId: userData.groupId.toString());
              },
            );
          },
        ),
        body: SafeArea(
          child: Obx(() {
            final offer = controller.incomingSDPOffer.value;

            if (offer == null) {
              return const SizedBox();
            }

            return Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Card(
                color: Colors.black87,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  title: Text(
                    "Incoming Call from ${offer["callerId"]}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.call_end, color: Colors.redAccent),
                        onPressed: () {
                          controller.incomingSDPOffer.value = null;
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.greenAccent),
                        onPressed: () {
                          controller.startCall(
                            context,
                            callerId: controller
                                .incomingSDPOffer.value!["remoteUserId"]!,
                            remoteUserId: Global.storageServices
                                .get(PrefConst.userId)
                                .toString(),
                            offer:
                                controller.incomingSDPOffer.value?["sdpOffer"],
                          );
                          controller.incomingSDPOffer.value = null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
