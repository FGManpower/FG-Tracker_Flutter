import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:fgtracker/app/modules/mediaStream/Services/call_pip.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/Group/group_call_pip_bubble.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/Group/group_screen_share_fullscreen.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_call_controls.dart';
import 'package:fgtracker/app/modules/mediaStream/Widget/group_participant_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:fgtracker/app/modules/call/widget/call_widget.dart';
import '../../../../../gen/fonts.gen.dart';

class GroupCallingScreen extends StatelessWidget {
  const GroupCallingScreen({super.key});

  GroupCallingController? get _controller =>
      Get.isRegistered<GroupCallingController>()
          ? Get.find<GroupCallingController>()
          : null;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = _controller;
      if (ctrl == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF0E0C14),
          body: SizedBox.shrink(),
        );
      }
      if (CallPip.inPip.value) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: GroupCallPipBubble(),
        );
      }
      return PopScope(
        canPop: ctrl.isMinimized.value,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (ctrl.fullScreenShareUserId.value != null) {
            ctrl.closeFullScreenShare();
            return;
          }
          ctrl.minimizeCall();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0E0C14),
          body: GestureDetector(
            onTap: ctrl.toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Obx(() {
                    final c = _controller;
                    if (c == null) return const SizedBox.shrink();
                    final fullUserId = c.fullScreenShareUserId.value;

                    if (fullUserId != null && fullUserId.isNotEmpty) {
                      final participant = c.activeParticipants.firstWhereOrNull(
                            (p) => p.userId.toString().trim() == fullUserId.trim(),
                      );
                      if (participant != null) {
                        return GroupScreenShareFullScreen(
                          controller: c,
                          participant: participant,
                        );
                      }
                    }

                    // Force rebuild when tracks attach / roster changes
                    final _ = c.participantsUiTick.value;

                    return GroupParticipantGrid(
                      pinnedUserId: c.pinnedUserId.value,
                      onTogglePin: c.togglePinUser,
                      participants: c.activeParticipants.toList(),
                      isVideoMode: c.isVideo,
                      screenSharingUserIds: c.screenSharingUsers
                          .map((e) => e.toString().trim())
                          .toSet(),
                      onSwitchCamera: c.switchCamera,
                    );
                  }),
                ),
                Obx(() {
                  final c = _controller;
                  if (c == null || c.fullScreenShareUserId.value != null) {
                    return const SizedBox.shrink();
                  }

                  final show = c.showControls.value;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: show ? 0 : -150.h,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: show ? 1.0 : 0.0,
                      child: Listener(
                        onPointerDown: (_) => c.resetControlsTimer(),
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
                          child: _buildHeader(context, c),
                        ),
                      ),
                    ),
                  );
                }),
                Obx(() {
                  final c = _controller;
                  if (c == null || c.fullScreenShareUserId.value != null) {
                    return const SizedBox.shrink();
                  }

                  final show = c.showControls.value;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: show ? 0 : -200.h,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: show ? 1.0 : 0.0,
                      child: Listener(
                        onPointerDown: (_) => c.resetControlsTimer(),
                        child: SafeArea(
                          top: false,
                          child: GroupCallControls(controller: c),
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
    });
  }

  Widget _buildHeader(BuildContext context, GroupCallingController controller) {
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
                        color: Color(0xFF16B364),
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
                          color: const Color(0xFF7B61FF),
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
                color: const Color(0xFF261D45),
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
