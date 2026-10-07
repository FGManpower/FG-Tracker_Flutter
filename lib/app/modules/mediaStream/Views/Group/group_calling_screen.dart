import 'package:fgtracker/app/modules/mediaStream/Views/Group/group_screen_share_fullscreen.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_participant_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../Controller/group_calling_controller.dart';
import 'group_call_pip_bubble.dart';

import 'package:fgtracker/app/routes/app_pages.dart';

class GroupCallingScreen extends GetView<GroupCallingController> {
  const GroupCallingScreen({super.key});

  Future<void> _minimizeToPip() async {
    // Show floating bubble over the whole app
    PictureInPicture.startPiP(
      pipWidget: const SizedBox(
        width: GroupCallPipBubble.pipW,
        height: GroupCallPipBubble.pipH,
        child: GroupCallPipBubble(),
      ),
    );

    // Leave call route so other internal screens are usable.
    // Controller is permanent → call/socket/WebRTC keep running.
    if (Get.currentRoute == Routes.groupCallingScreen) {
      if (Navigator.of(Get.context!).canPop()) {
        Get.back();
      } else {
        Get.offNamed(Routes.Home_Screen); // your main shell
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // onPopInvokedWithResult: (didPop, result) async { //uncomment this code
      //   if (didPop) return;
      //   await _minimizeToPip(); // system back → PiP, not end call
      // },
      child: PiPCapableWidget(
        whileNotInPip: Expanded(
          child: _buildCallScaffold(context),
        ),
        whileInPip: const SizedBox(
          width: GroupCallPipBubble.pipW,
          height: GroupCallPipBubble.pipH,
          child: GroupCallPipBubble(),
        ),
      ),
    );
  }

  Widget _buildCallScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B29),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF0F0B29)),
            Obx(() {
              final fullScreenId = controller.fullScreenShareUserId.value;

              if (fullScreenId != null) {
                final matching = controller.activeParticipants
                    .firstWhereOrNull((p) => p.userId == fullScreenId) ??
                    controller.activeParticipants.firstOrNull;
                if (matching != null) {
                  return GroupScreenShareFullScreen(
                    controller: controller,
                    participant: matching,
                  );
                }
              }

              if (controller.activeParticipants.isEmpty) {
                return Center(
                  child: Obx(() => Text(
                    controller.callStatus.value,
                    style: const TextStyle(color: Colors.white70),
                  )),
                );
              }

              return GroupParticipantGrid(
                // controller: controller,
                participants: controller.activeParticipants,
                isVideoMode: controller.isVideoOn.value,
              );
            }),
            Obx(() {
              if (!controller.showControls.value) return const SizedBox.shrink();
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(context),
              );
            }),
            Obx(() {
              if (!controller.showControls.value) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildControlBar(context),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: Colors.black45,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onPressed: () {
                // _minimizeToPip();
              }, // chevron = same as back
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(() => Text(
                    controller.callStatus.value == 'Connected'
                        ? controller.formattedDuration
                        : controller.callStatus.value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  )),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
              onPressed: controller.openParticipantsSheet,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: controller.openMoreSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.black45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => _roundBtn(
              icon: controller.isAudioOn.value ? Icons.mic : Icons.mic_off,
              onTap: controller.toggleMic,
            )),
            Obx(() => _roundBtn(
              icon: controller.isVideoOn.value
                  ? Icons.videocam
                  : Icons.videocam_off,
              onTap: controller.toggleCamera,
            )),
            Obx(() => _roundBtn(
              icon: controller.isSpeakerOn.value
                  ? Icons.volume_up
                  : Icons.volume_down,
              onTap: controller.toggleSpeaker,
            )),
            Obx(() => _roundBtn(
              icon: controller.isScreenSharing.value
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
              onTap: controller.toggleScreenShare,
            )),
            _roundBtn(
              icon: Icons.call_end,
              color: Colors.red,
              onTap: () async {
                try {
                  if (PictureInPicture.isActive) {
                    PictureInPicture.stopPiP();
                  }
                } catch (_) {}
                await controller.endCall();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white24,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}