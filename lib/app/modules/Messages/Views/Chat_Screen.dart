import 'dart:io';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';

import 'package:fgtracker/app/Data/Repositories/GetMessageRepo.dart';
import 'package:fgtracker/app/Data/Services/CallStateTracker.dart';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/Socket_Message_Services.dart';
import 'package:fgtracker/app/modules/Messages/widgets/ChatList.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:fgtracker/app/modules/WebRtcCall/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/values/Dialog/Common_dialog.dart';
import '../../../Core/values/global.dart';
import 'package:uuid/uuid.dart';


import '../../WebRtcCall/call_service.dart';
import '../widgets/ChatInputArea.dart';

class ChatPage extends StatefulWidget {
  MemberData userData;
  String? type;
  final String groupName;
  ChatPage(
      {Key? key, required this.userData, this.type, required this.groupName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  late var controller = Get.put(MessageController());

  final SocketMessageService socketService = SocketMessageService.instance;
  RxString selectedImagePath = ''.obs;
  TextEditingController messageController = TextEditingController();
  var chatBackgroundColor = Colors.white.obs;
  var chatBackgroundImage = RxnString(); // nullable
  final ChatThemeController chatThemeController =
      Get.put(ChatThemeController());
  final ScrollController _scrollController = ScrollController();
  final channelId = const Uuid().v4();
  late CallService callService;
  void handleBackPressed() {
    final userId = Global.storageServices.get(PrefConst.userId).toString();
    final groupId = widget.userData.groupId!;

    SocketMessageService.instance.leaveUserFromGroup(userId, groupId);
    SocketMessageService.instance.disconnectSocket();

    controller.messageText.value = '';
    controller.imagePath.value = '';
    controller.isSending.value = false;
    controller.messageData.clear();
    controller.chatBackgroundImagePath.value = null;
    Get.delete<MessageController>(tag: userId);

    ChatStateTracker.isChatCallScreenOpen = false;

    Navigator.of(context).pop();
    // Get.offAllNamed(Routes.Home_Screen);
  }

  @override
  void initState() {
    super.initState();

    ChatStateTracker.isChatCallScreenOpen = true;
    final userId = widget.userData.userId.toString();
    final groupId = widget.userData.groupId!;
    controller.initSocket(userId, groupId: groupId);
    chatThemeController.loadThemePreferences();
    controller.loadThemePreferences(userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMessageHistory(context, userId, groupId).then((_) {
        scrollToBottom(_scrollController, animated: true);
      });
    });

    callService = CallService(userId:Global.storageServices.get(PrefConst.userId).toString(), debug: true);
    callService.init();

    // wire events
    callService.onIncomingCall = (data) {
      // show dialog or IncomingCallScreen
      print("Incoming call: $data");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Incoming Call from ${data['caller_name'] ?? data['from']}"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await callService.acceptCall(incomingCall: data);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      callService: callService,
                      peerId: userId,
                      isVideo: data['is_video'] == true,
                    ),
                  ),
                );
              },
              child: const Text("Accept"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await callService.rejectCall(incomingCall: data);
              },
              child: const Text("Reject"),
            ),
          ],
        ),
      );
    };

    callService.onCallAccepted = (callId) {
      // Caller side: open the call UI when accepted
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callService: callService,
            peerId: userId,
            isVideo: true,
          ),
        ),
      );
    };

    callService.onCallEnded = () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Call ended")),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    };

  }

  bool _isSending = false;

  Future<void> _sendMessage() async {
    final imagePath = controller.imagePath.value;
    final text = _controller.text.trim();
    if (_isSending) return;
    _isSending = true;

    try {
      if (imagePath.isNotEmpty) {
        final result = await MessageRepo.uploadChatImage(imagePath);

        if (result.status == true && result.filename != null) {
          final uploadedImage = result.filename!;

          if (text.isNotEmpty) {
            socketService.sendMessage(
              messageType: "image",
              receiverId: widget.userData.userId.toString(),
              groupId: widget.userData.groupId!,
              content: uploadedImage,
            );

            await Future.delayed(const Duration(milliseconds: 200));

            socketService.sendMessage(
              messageType: "text",
              receiverId: widget.userData.userId.toString(),
              groupId: widget.userData.groupId!,
              content: text,
            );
          } else {
            socketService.sendMessage(
              messageType: "image",
              receiverId: widget.userData.userId.toString(),
              groupId: widget.userData.groupId!,
              content: uploadedImage,
            );
          }
        } else {
          CommonDialog.errorMessage("Image upload failed. Please try again.");
          return;
        }

        controller.imagePath.value = "";
        _controller.clear(); // Clear text if any
      } else if (text.isNotEmpty) {
        socketService.sendMessage(
          receiverId: widget.userData.userId.toString(),
          content: text,
          messageType: "text",
          groupId: widget.userData.groupId!,
        );
        _controller.clear();
      }

// ✅ Scroll after the list updates
      Future.delayed(const Duration(milliseconds: 50), () {
        scrollToBottom(_scrollController, animated: true);
      });
    } catch (e) {
    } finally {
      _isSending = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        handleBackPressed();
        return false;
      },
      child: Scaffold(
          backgroundColor: ToggleThemeData.chatBackground,
          resizeToAvoidBottomInset: true,
          appBar: CommonChatAppBar(
            profileImageUrl: "${ConstRes.aImageBaseUrl}${widget.userData?.profileImage ?? ""}",
            userName: widget.userData?.name ?? "",
            isCreator: widget.userData.isCreator!,
            onBackTap: () {
              handleBackPressed();
            },
            onCallTap: () async {
              // 🔹 Start AUDIO call
              await callService.startCall(
                receiverId: widget.userData.userId.toString(),
                isVideo: false,
                callerName: Global.storageServices.get(PrefConst.userId),
              );



              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    callService: callService,
                    peerId: Global.storageServices.get(PrefConst.userId).toString(),//our UserId
                    isVideo: false,
                  ),
                ),
              );
            },
            onVideoTap: () async {
              // 🔹 Start VIDEO call
              await callService.startCall(
                receiverId: widget.userData.userId.toString(),
                isVideo: true,
                callerName: Global.storageServices.get(PrefConst.userId),//our UserId
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    callService: callService,
                    peerId: Global.storageServices.get(PrefConst.userId).toString(),
                    isVideo: true,
                  ),
                ),
              );
            },
            onMicTap: () {
              // optional mic mute logic
            },
            onThemeTap: () {
              ThemePicker.show(context, controller, widget.userData.userId.toString());
            },
            groupName: widget.groupName,
          ),
          // appBar: CommonChatAppBar(
          //   profileImageUrl:
          //       "${ConstRes.aImageBaseUrl}${widget.userData?.profileImage ?? ""}",
          //   userName: widget.userData?.name ?? "",
          //   onBackTap: () {
          //     handleBackPressed();
          //   },
          //   onCallTap: () {
          //     FireStoreServices().startCall(
          //       context,
          //       false,
          //       receiverId: int.parse(widget.userData.userId.toString()),
          //     );
          //   },
          //   onMicTap: () {
          //     // Handle mic press
          //   },
          //   onVideoTap: () {
          //     FireStoreServices().startCall(
          //       context,
          //       true,
          //       receiverId: int.parse(widget.userData.userId.toString()),
          //     );
          //   },
          //   onThemeTap: () {
          //     ThemePicker.show(
          //         context, controller, widget.userData.userId.toString());
          //   },
          //   groupName: widget.groupName,
          // ),
          body: Obx(() => SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF2F0FF),
                    image: controller.chatBackgroundImagePath.value != null
                        ? DecorationImage(
                            image: FileImage(File(
                                controller.chatBackgroundImagePath.value!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                          child: ChatList(
                              controller: controller,
                              scrollController: _scrollController)),
                      ChatInputArea(
                        messageText: controller.messageText,
                        imagePath: controller.imagePath,
                        isSending: controller.isSending,
                        textController: _controller,
                        scrollController: _scrollController,
                        onSend: () {
                          _sendMessage();
                        },
                        onImageSelected: (path) {
                          controller.imagePath.value = path;
                        },
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
