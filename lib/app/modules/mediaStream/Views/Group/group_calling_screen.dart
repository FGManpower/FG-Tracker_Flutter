import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/Group/group_screen_share_fullscreen.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_call_controls.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_participant_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../gen/fonts.gen.dart';

class GroupCallingScreen extends GetView<GroupCallingController> {
  const GroupCallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.fullScreenShareUserId.value != null) {
          controller.closeFullScreenShare();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0B29),
        body: GestureDetector(
          onTap: controller.toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  final fullUserId = controller.fullScreenShareUserId.value;

                  if (fullUserId != null && fullUserId.isNotEmpty) {
                    final participant =
                    controller.activeParticipants.firstWhereOrNull(
                          (p) => p.userId.toString().trim() == fullUserId.trim(),
                    );
                    if (participant != null) {
                      return GroupScreenShareFullScreen(
                        controller: controller,
                        participant: participant,
                      );
                    }
                  }

                  return GroupParticipantGrid(
                    pinnedUserId: controller.pinnedUserId.value,
                    onTogglePin: controller.togglePinUser,
                    participants: controller.activeParticipants.toList(),
                    isVideoMode: controller.isVideo,
                    screenSharingUserIds: controller.screenSharingUsers
                        .map((e) => e.toString().trim())
                        .toSet(),
                    onSwitchCamera: controller.switchCamera,
                  );
                }),
              ),
              Obx(() {
                if (controller.fullScreenShareUserId.value != null) {
                  return const SizedBox.shrink();
                }

                final show = controller.showControls.value;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  top: show ? 0 : -150.h,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: show ? 1.0 : 0.0,
                    child: Listener(
                      onPointerDown: (_) => controller.resetControlsTimer(),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: _buildHeader(),
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                if (controller.fullScreenShareUserId.value != null) {
                  return const SizedBox.shrink();
                }

                final show = controller.showControls.value;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: show ? 0 : -200.h,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: show ? 1.0 : 0.0,
                    child: Listener(
                      onPointerDown: (_) => controller.resetControlsTimer(),
                      child: SafeArea(
                        top: false,
                        child: GroupCallControls(controller: controller),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(
                      () {
                        if (!Get.isRegistered<GroupCallingController>()) {
                          return const SizedBox.shrink();
                        }

                       return Text(
                          "${controller.activeParticipants.length} in call · ${controller.totalMemberCount} members",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: FontFamily.interRegular,
                            color: Colors.white70,
                          ),
                        );
                      },
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Obx(
                          () => Text(
                        controller.callStatus.value == "Connected"
                            ? controller.formattedDuration
                            : "${controller.callStatus.value}...",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: FontFamily.interMedium,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44.w,
                height: 44.w,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.people_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: controller.openParticipantsSheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}