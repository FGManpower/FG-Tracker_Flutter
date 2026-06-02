import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          isCreator: userData.isCreator ?? false,
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
            final groupNameController = TextEditingController(
              text: controller.arguments?['groupName'] ?? "",
            );

            showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Container(
                    width: 0.9.sw,
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Container(
                          width: 50.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor:
                          ToggleThemeData.darkPurple.withOpacity(.1),
                          child: Icon(
                            Icons.edit,
                            color: ToggleThemeData.darkPurple,
                            size: 28.sp,
                          ),
                        ),

                        SizedBox(height: 15.h),

                        Text(
                          "Update Group Name",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          "Enter a new name for your group",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        TextField(
                          controller: groupNameController,
                          textCapitalization:
                          TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: "Group Name",
                            prefixIcon: Icon(
                              Icons.group,
                              size: 22.sp,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: ToggleThemeData.darkPurple,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 25.h),

                        Row(
                          children: [

                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  minimumSize:
                                  Size(double.infinity, 48.h),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        12.r),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {

                                  if (groupNameController.text
                                      .trim()
                                      .isEmpty) {
                                    Get.snackbar(
                                      "Validation",
                                      "Please enter group name",
                                    );
                                    return;
                                  }

                                  debugPrint(
                                    "Update Group Name => ${groupNameController.text}",
                                  );

                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  ToggleThemeData.darkPurple,
                                  minimumSize:
                                  Size(double.infinity, 48.h),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        12.r),
                                  ),
                                ),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },

          onDeleteMember: () {
            final memberController = Get.put(
              MemberController(),
            );

            memberController.getMembersData(
              userData.groupId.toString(),
            );

            Get.bottomSheet(
              Container(
                height: Get.height * .65,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [

                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Delete Member",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: Obx(() {

                        if (memberController.memberDataLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (memberController.memberData.isEmpty) {
                          return const Center(
                            child: Text(
                              "No Members Found",
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount:
                          memberController.memberData.length,
                          itemBuilder: (context, index) {

                            final member =
                            memberController.memberData[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "${ConstRes.aImageBaseUrl}${member.profileImage ?? ""}",
                                ),
                              ),

                              title: Text(
                                member.name ?? "",
                              ),

                              trailing: TextButton(
                                onPressed: () {

                                  debugPrint(
                                    "Delete Member => ${member.userId}",
                                  );


                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              isScrollControlled: true,
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
               onVoiceSend: (voicePath) {
                 if(Utility.isNotNullEmptyOrFalse(voicePath)){
                   controller.uploadAudio(voicePath);
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
