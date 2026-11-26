import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../Core/constant/const_res.dart';
import '../../../../Core/theme/appTheme.dart';
import '../../../../Core/values/utility.dart';
import 'package:fgtracker/app/Data/Services/group_call_service.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import '../../Controller/group_incoming_call_controller.dart';
import '../AudioCall_screen.dart';

class GroupIncomingCallScreen extends GetView<GroupIncomingCallController> {
  const GroupIncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GroupCallService.isGroupCallEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GroupCallService.showComingSoon();
        if (Get.currentRoute == Routes.groupIncomingCallScreen) {
          Get.back();
        }
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0E0C14),
        body: SizedBox.shrink(),
      );
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0C14),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),

                // Top WhatsApp Call Type & Encryption Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white12, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isVideo
                            ? Icons.videocam_rounded
                            : Icons.call_rounded,
                        color: const Color(0xFF7B61FF),
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        controller.isVideo
                            ? appL10n.call_incomingGroupVideo
                            : appL10n.call_incomingGroupAudio,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: FontFamily.interMedium,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.lock_rounded,
                        color: Colors.white54,
                        size: 13.sp,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Pulsing Group Avatar
                CallPulseAvatar(
                  name: controller.groupName,
                  image: controller.groupProfile ?? controller.callerProfileImage,
                  animate: true,
                  onDark: true,
                  avatarSize: 130,
                  accent: const Color(0xFF5B3FD0),
                ),
                SizedBox(height: 24.h),

                // Group Name
                Text(
                  controller.groupName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontFamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),

                // Caller & Members Subtitle
                Text(
                  context.l10n.call_callerAndOthers(
                    controller.callerName,
                    controller.totalMemberCount > 1
                        ? controller.totalMemberCount - 1
                        : 0,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: FontFamily.interRegular,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12.h),

                // Members in call pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141024),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white12, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16B364),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        appL10n.call_membersInCall(controller.activeMemberCount),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontFamily.interMedium,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom Action Buttons (Decline / Accept / Mute)
                _buildActionButtons(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Decline button (Red)
        _circleAction(
          icon: Icons.call_end_rounded,
          label: appL10n.call_decline,
          color: const Color(0xFFEA4335),
          size: 64,
          iconSize: 30,
          onTap: controller.declineCall,
        ),

        // Mute mic before answering toggle
        Obx(
          () => _circleAction(
            icon: controller.isMuted.value
                ? Icons.mic_off_rounded
                : Icons.mic_rounded,
            label: controller.isMuted.value
                ? appL10n.call_muted
                : appL10n.call_mute,
            color: controller.isMuted.value
                ? const Color(0xFFEA4335).withOpacity(0.3)
                : const Color(0xFF261D45),
            iconColor: controller.isMuted.value
                ? const Color(0xFFFF5252)
                : Colors.white,
            size: 52,
            iconSize: 24,
            onTap: controller.toggleMute,
          ),
        ),

        // Join / Answer button
        _circleAction(
          icon: controller.isVideo
              ? Icons.videocam_rounded
              : Icons.call_rounded,
          label: "Join call",
          color: const Color(0xFF16B364),
          size: 64,
          iconSize: 30,
          onTap: controller.joinCall,
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required String label,
    required Color color,
    Color iconColor = Colors.white,
    required double size,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: size.r,
            width: size.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: iconSize.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: FontFamily.interMedium,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
