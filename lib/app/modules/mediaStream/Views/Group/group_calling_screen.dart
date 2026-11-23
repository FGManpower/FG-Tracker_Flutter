import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/Group/group_screen_share_fullscreen.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_call_controls.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_participant_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import '../../../../../gen/fonts.gen.dart';

class GroupCallingScreen extends GetView<GroupCallingController> {
  const GroupCallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: controller.isMinimized.value,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.fullScreenShareUserId.value != null) {
          controller.closeFullScreenShare();
          return;
        }
        controller.minimizeCall();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B141B),
        body: GestureDetector(
          onTap: controller.toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  final fullUserId = controller.fullScreenShareUserId.value;

                  if (fullUserId != null && fullUserId.isNotEmpty) {
                    final participant = controller.activeParticipants.firstWhereOrNull(
                          (p) => p.userId.toString().trim() == fullUserId.trim(),
                    );
                    if (participant != null) {
                      return GroupScreenShareFullScreen(
                        controller: controller,
                        participant: participant,
                      );
                    }
                  }

                  // Force rebuild when tracks attach / roster changes
                  final _ = controller.participantsUiTick.value;

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
                        child: _buildHeader(context),
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
    ));
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => controller.minimizeCall(),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Obx(
                      () => Text(
                        controller.callStatus.value == "Connected"
                            ? controller.formattedDuration
                            : "${callStatusLabel(context.l10n, controller.callStatus.value)}...",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                          color: const Color(0xFF25D366),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: controller.openParticipantsSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Obx(
                    () => Text(
                      '${controller.activeParticipants.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontFamily: FontFamily.interSemiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
