import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/Tracking.dart';
import 'package:fgtracker/app/Model/ContactMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/widgets/message_Widgets.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/app/widgets/PinnedMessageBanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/ChatInputArea.dart';
import '../widgets/ChatList.dart';
import 'ContactPickerPage.dart';
import 'LocationPickerPage.dart';

class ChatScreen extends GetView<MessageController> {
  ChatScreen({super.key});

  final TextEditingController _controller = TextEditingController();


  final groupController = Get.put(GroupController());
  final RxString recordedVoicePath = "".obs;

  Future<void> _sendMessage() async {
    await controller.sendMessage(textController: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final userData = controller.memberData;
    String lastSeenText = "Offline";
    bool isOnline = false;

    if (userData.lastSeen != null && userData.lastSeen!.trim().isNotEmpty) {
      final rawLastSeen = userData.lastSeen!.trim();

      try {
        lastSeenText = Tracking().getTimeAgo(DateTime.parse(rawLastSeen));
      } catch (_) {
        lastSeenText = rawLastSeen;
      }

      isOnline = lastSeenText.toLowerCase() == "just now";
    }

    return WillPopScope(
      onWillPop: () async {
        controller.handleBackPressed(context,
            groupID: int.parse(userData.groupId.toString()));
        return false;
      },
      child: Scaffold(
        backgroundColor: ToggleThemeData.chatBackground,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            if (controller.isSearching.value) {
              return AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => controller.stopSearch(),
                ),
                title: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search messages...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: controller.onSearchChanged,
                ),
                actions: [
                  Obx(() {
                    final total = controller.searchResultIds.length;
                    final current = controller.currentSearchIndex.value;
                    final display =
                    total == 0 ? "0/0" : "${total - current}/$total";
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          display,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                  Obx(() =>
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up,
                            color: Colors.black),
                        onPressed: controller.searchResultIds.isEmpty
                            ? null
                            : controller.previousSearchResult,
                      )),
                  Obx(() =>
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black),
                        onPressed: controller.searchResultIds.isEmpty
                            ? null
                            : controller.nextSearchResult,
                      )),
                ],
              );
            }

            return CommonChatAppBar(
              profileImageUrl:
              "${ConstRes.aImageBaseUrl}${userData.profileImage ?? ""}",
              userName: userData.name ?? "",
              controller: controller,
              groupName: controller.arguments?['groupName'],
              isOnline: isOnline,
              lastSeen: lastSeenText,
              isGroupChat: false,
              onBackTap: () {
                controller.handleBackPressed(context,
                    groupID: int.parse(userData.groupId.toString()));
              },
              onCallTap: () {
                controller.startCall(
                  context,
                  callerId:
                  Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: false,
                  callerName: controller.memberData.name,
                );
              },
              onVideoTap: () {
                controller.startCall(
                  context,
                  callerId:
                  Global.storageServices.get(PrefConst.userId).toString(),
                  remoteUserId: controller.memberData.userId.toString(),
                  is_video: true,
                  callerName: controller.memberData.name,
                );
              },
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
                  "Are you sure you want to remove this member from the group?",
                  confirm: "Remove",
                  onConfirm: () {
                    groupController.deleteGroupMember(
                      context,
                      groupId: userData.groupId.toString(),
                      groupMemberId: controller.memberData.userId.toString(),
                      onSuccess: (success) {
                        if (success) {
                          Get.offAllNamed(Routes.Home_Screen);
                        }
                      },
                    );
                  },
                );
              },
              onSearchTap: () => controller.startSearch(),
            );
          }),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Obx(() {
                final pinned = controller.pinnedMessage.value;
                if (pinned == null || !controller.showPinnedBanner.value) {
                  return const SizedBox.shrink();
                }
                return PinnedMessageBanner(
                  pinnedMessage: pinned,
                  onTap: () => controller.scrollToPinnedMessage(),
                  onClose: () => controller.showPinnedBanner.value = false,
                  onUnpin: () => controller.unpinMessage(),
                );
              }),

              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ChatList(
                      controller: controller,
                    ),
                    Obx(() {
                      final isVisible = controller.showFloatingDate.value;
                      final date = controller.floatingDate.value;

                      if (date.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IgnorePointer(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedSlide(
                            offset:
                            isVisible ? Offset.zero : const Offset(0, -0.8),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: AnimatedOpacity(
                              opacity: isVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() {
                final reply = controller.replyMessage.value;

                if (reply == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 42,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reply.senderName?.toString() ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reply.content?.toString() ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.clearReply,
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                );
              }),
              Obx(() {
                if (recordedVoicePath.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return WhatsAppVoicePlayerPreview(
                  voicePath: recordedVoicePath.value,
                  onDelete: () => recordedVoicePath.value = "",
                  onSend: () {
                    controller.uploadAudio(recordedVoicePath.value);
                    recordedVoicePath.value = "";
                  },
                );
              }),
              ChatInputArea(
                messageText: controller.messageText,
                imagePath: controller.imagePaths,
                videoPaths: controller.videoPaths,
                videoThumbnails: controller.videoThumbnails,
                videoDurations: controller.videoDurations,
                documentPath: controller.documentPath,
                isSending: controller.isSending,
                textController: _controller,
                messageController: controller,
                onSend: _sendMessage,
                uploadingVideoIndexes: controller.uploadingVideoIndexes,
                videoUploadProgress: controller.videoUploadProgress,
                onImageSelected: (paths) {
                  controller.imagePaths.addAll(paths);
                },
                onVoiceSend: (voicePath) {
                  if (Utility.isNotNullEmptyOrFalse(voicePath)) {
                    recordedVoicePath.value = voicePath;
                  }
                },
                onVideosSelected: (paths) async {
                  if (paths.isNotEmpty) {
                    await controller.addVideos(paths);
                  }
                },
                isUploadingVideo: controller.isUploadingVideo,
                uploadProgress: controller.uploadProgress,
                onDocumentSelected: (path) async {
                  if (Utility.isNotNullEmptyOrFalse(path)) {
                    controller.documentPath.value = path;
                  }
                },
                onLocationSelected: () async {
                  final location = await Get.to<LocationMessage>(
                        () => const LocationPickerPage(),
                  );
                  if (location != null) {
                    await controller.sendLocation(
                      location: location,
                    );
                  }
                },
                onContactSelected: () async {
                  final contact = await Get.to<ContactMessage>(
                        () => const ContactPickerPage(),
                  );

                  if (contact != null) {
                    await controller.sendContact(
                      contact: contact,
                    );
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

class WhatsAppVoicePlayerPreview extends StatefulWidget {
  final String voicePath;
  final VoidCallback onDelete;
  final VoidCallback onSend;

  const WhatsAppVoicePlayerPreview({
    super.key,
    required this.voicePath,
    required this.onDelete,
    required this.onSend,
  });

  @override
  State<WhatsAppVoicePlayerPreview> createState() =>
      _WhatsAppVoicePlayerPreviewState();
}

class _WhatsAppVoicePlayerPreviewState
    extends State<WhatsAppVoicePlayerPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool isPlaying = false;
  double progress = 0.0;
  final List<double> speeds = [1.0, 1.5, 2.0];
  int speedIndex = 0;

  final List<double> barHeights = [
    12, 18, 28, 14, 22, 36, 16, 24, 32, 10,
    20, 30, 14, 26, 38, 18, 12, 28, 34, 16,
    22, 12, 30, 20, 14, 26, 32, 18, 10, 24
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {
        progress = _animController.value;
      });
      if (_animController.isCompleted) {
        setState(() {
          isPlaying = false;
          _animController.reset();
          progress = 0.0;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _animController.forward(from: progress);
      } else {
        _animController.stop();
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      speedIndex = (speedIndex + 1) % speeds.length;
      final currentSpeed = speeds[speedIndex];
      _animController.duration = Duration(
        milliseconds: (10000 / currentSpeed).round(),
      );
      if (isPlaying) {
        _animController.forward(from: progress);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSpeed = speeds[speedIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: widget.onDelete,
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: const Color(0xFF075E54),
              size: 32,
            ),
            onPressed: _togglePlayPause,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final double tapPos = details.localPosition.dx;
                    final double width = constraints.maxWidth;
                    final double newProgress = (tapPos / width).clamp(0.0, 1.0);
                    setState(() {
                      progress = newProgress;
                      _animController.value = newProgress;
                    });
                  },
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(barHeights.length, (index) {
                        final double barPercent = index / barHeights.length;
                        final bool isPlayed = barPercent <= progress;

                        return Container(
                          width: 3,
                          height: barHeights[index],
                          decoration: BoxDecoration(
                            color: isPlayed
                                ? const Color(0xFF075E54)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${currentSpeed == 1.0 ? '1' : currentSpeed}x",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF075E54)),
            onPressed: widget.onSend,
          ),
        ],
      ),
    );
  }
}

class VoiceMessagePlayerBubble extends StatefulWidget {
  final String audioUrl;
  final bool isSender;

  const VoiceMessagePlayerBubble({
    super.key,
    required this.audioUrl,
    required this.isSender,
  });

  @override
  State<VoiceMessagePlayerBubble> createState() =>
      _VoiceMessagePlayerBubbleState();
}

class _VoiceMessagePlayerBubbleState extends State<VoiceMessagePlayerBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool isPlaying = false;
  double progress = 0.0;
  final List<double> speeds = [1.0, 1.5, 2.0];
  int speedIndex = 0;

  final List<double> barHeights = [
    10, 16, 24, 12, 18, 32, 14, 22, 28, 10,
    18, 26, 12, 22, 34, 16, 10, 24, 30, 14,
    20, 10, 26, 18, 12, 22, 28, 16, 10, 20
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(() {
      setState(() {
        progress = _animController.value;
      });
      if (_animController.isCompleted) {
        setState(() {
          isPlaying = false;
          _animController.reset();
          progress = 0.0;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _animController.forward(from: progress);
      } else {
        _animController.stop();
      }
    });
  }

  void _toggleSpeed() {
    setState(() {
      speedIndex = (speedIndex + 1) % speeds.length;
      final currentSpeed = speeds[speedIndex];
      _animController.duration = Duration(
        milliseconds: (12000 / currentSpeed).round(),
      );
      if (isPlaying) {
        _animController.forward(from: progress);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSpeed = speeds[speedIndex];
    final activeColor =
    widget.isSender ? Colors.white : const Color(0xFF075E54);
    final inactiveColor = widget.isSender
        ? Colors.white.withOpacity(0.4)
        : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: const BoxConstraints(maxWidth: 260),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: activeColor,
              size: 34,
            ),
            onPressed: _togglePlayPause,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) {
                    final double tapPos = details.localPosition.dx;
                    final double width = constraints.maxWidth;
                    final double newProgress = (tapPos / width).clamp(0.0, 1.0);
                    setState(() {
                      progress = newProgress;
                      _animController.value = newProgress;
                    });
                  },
                  child: SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(barHeights.length, (index) {
                        final double barPercent = index / barHeights.length;
                        final bool isPlayed = barPercent <= progress;

                        return Container(
                          width: 2.8,
                          height: barHeights[index],
                          decoration: BoxDecoration(
                            color: isPlayed ? activeColor : inactiveColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _toggleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: widget.isSender
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${currentSpeed == 1.0 ? '1' : currentSpeed}x",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: activeColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

