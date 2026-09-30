import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';
import '../../../global_widget/common_widget.dart';
import '../../../Model/group_call_participant.dart';

class GroupParticipantGrid extends StatelessWidget {
  final List<GroupCallParticipant> participants;
  final bool isVideoMode;
  final Set<String> screenSharingUserIds;
  final String? pinnedUserId;
  final void Function(String userId)? onTogglePin;

  const GroupParticipantGrid({
    super.key,
    required this.participants,
    required this.isVideoMode,
    this.screenSharingUserIds = const {},
    this.pinnedUserId,
    this.onTogglePin,
  });

  bool _isSharing(String userId) {
    return screenSharingUserIds
        .map((e) => e.toString().trim())
        .contains(userId.toString().trim());
  }

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox();

    final count = participants.length;

    if (count == 1) {
      return _buildTile(participants[0], isFullScreen: true);
    }

    final pinnedIndex =
    participants.indexWhere((p) => p.userId == pinnedUserId);

    if (pinnedIndex >= 0 && count >= 2) {
      final pinnedUser = participants[pinnedIndex];
      final others = <GroupCallParticipant>[
        for (int i = 0; i < participants.length; i++)
          if (i != pinnedIndex) participants[i],
      ];

      final isPinnedSharing = _isSharing(pinnedUser.userId);

      return Padding(

        padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 8.h,
          bottom: 8.h,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: _buildTile(
                pinnedUser,
                isFullScreen: false,
                isPinned: true,
                forceContain: isPinnedSharing,
              ),
            ),

            SizedBox(height: 6.h),

            SizedBox(
              height: 78.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: others.length,
                separatorBuilder: (_, __) => SizedBox(width: 6.w),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 72.w,
                    child: _buildTile(
                      others[index],
                      isFullScreen: false,
                      isThumbnail: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }


    if (count == 2) {
      return Padding(
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 72.h,
          bottom: 120.h,
        ),
        child: Column(
          children: [
            Expanded(child: _buildTile(participants[0], isFullScreen: false)),
            SizedBox(height: 8.h),
            Expanded(child: _buildTile(participants[1], isFullScreen: false)),
          ],
        ),
      );
    }


    return GridView.builder(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 72.h,
        bottom: 120.h,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 0.78,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (count == 5 && index == 4) {
          return Center(
            child: SizedBox(
              width: 190.w,
              child: _buildTile(participants[index], isFullScreen: false),
            ),
          );
        }
        return _buildTile(participants[index], isFullScreen: false);
      },
    );
  }

  Widget _buildTile(
      GroupCallParticipant participant, {
        required bool isFullScreen,
        bool isThumbnail = false,
        bool isPinned = false,
        bool forceContain = false,
      }) {
    final sharing = _isSharing(participant.userId);

    final useContain = forceContain || sharing;

    Widget tileContent = ClipRRect(
      borderRadius: BorderRadius.circular(
        isFullScreen ? 0 : (isThumbnail ? 12.r : 16.r),
      ),
      child: Container(

        decoration: BoxDecoration(
          color: const Color(0xFF12101F),
          borderRadius: BorderRadius.circular(
            isFullScreen ? 0 : (isThumbnail ? 12.r : 16.r),
          ),
          border: sharing
              ? Border.all(color: const Color(0xFF7B58FF), width: 2)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [

            Obx(() {
              final isVideoOn = participant.isVideoOn.value;
              final rendererReady = participant.renderer != null &&
                  participant.renderer!.textureId != null;

              if ((isVideoMode || sharing) && isVideoOn && rendererReady) {
                return RTCVideoView(
                  participant.renderer!,
                  mirror: participant.isLocal && !sharing,
                  objectFit: useContain
                      ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                      : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                );
              }

              return _buildFallback(
                participant,
                cameraOff: isVideoMode && !isVideoOn && !sharing,
                isFullScreen: isFullScreen,
                isThumbnail: isThumbnail,
              );
            }),

            if (!isThumbnail)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: isPinned ? 70.h : 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),


            if (sharing && !isThumbnail)
              Positioned(
                top: 10.h,
                left: 10.w,
                child: _badge(
                  icon: Icons.present_to_all_rounded,
                  text: participant.isLocal
                      ? "You're sharing"
                      : "${participant.name} is sharing",
                ),
              ),


            if (!isPinned && !isFullScreen && !isThumbnail)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: _roundIconBtn(
                  icon: Icons.fullscreen_rounded,
                  onTap: () => onTogglePin?.call(participant.userId),
                ),
              ),

            if (isPinned && !isFullScreen && !isThumbnail)
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: _pillBtn(
                  icon: Icons.fullscreen_exit_rounded,
                  label: "Zoom Out",
                  onTap: () => onTogglePin?.call(participant.userId),
                ),
              ),


            if (!isFullScreen)
              Positioned(
                left: isThumbnail ? 4.w : 10.w,
                bottom: isThumbnail ? 4.h : 12.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isThumbnail ? 6.w : 8.w,
                    vertical: isThumbnail ? 2.h : 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: reausabletext(
                    participant.isLocal ? "You" : participant.name.toString(),
                    fontsize: isThumbnail ? 10 : 12,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
              ),


            if (!isFullScreen && !isThumbnail)
              Positioned(
                right: 12.w,
                bottom: isPinned ? 52.h : 12.h,
                child: Obx(() {
                  if (!participant.isMuted.value) return const SizedBox.shrink();
                  return Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_off, color: Colors.white, size: 14.sp),
                  );
                }),
              ),
          ],
        ),
      ),
    );


    if (isThumbnail) {
      return GestureDetector(
        onTap: () => onTogglePin?.call(participant.userId),
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _badge({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF7B58FF),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14.sp),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontFamily: FontFamily.interSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: const Color(0xFF7B58FF)),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontFamily: FontFamily.interSemiBold,
                color: const Color(0xFF7B58FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(
      GroupCallParticipant participant, {
        required bool cameraOff,
        required bool isFullScreen,
        bool isThumbnail = false,
      }) {
    final imageUrl = Utility.isNullEmptyOrFalse(participant.profileImage)
        ? MyAppTheme.ProfilenotFoundImg
        : ConstRes.aImageBaseUrl + (participant.profileImage ?? '');

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF1E1147)),
        Center(
          child: CircleAvatar(
            radius: isFullScreen ? 70.r : (isThumbnail ? 18.r : 36.r),
            backgroundColor: Colors.white12,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
            child: Utility.isNullEmptyOrFalse(participant.profileImage)
                ? Icon(
              Icons.person,
              color: Colors.white,
              size: isFullScreen ? 72.r : (isThumbnail ? 20.r : 40.r),
            )
                : null,
          ),
        ),
        if (cameraOff && !isThumbnail)
          Positioned(
            top: isFullScreen ? 100.h : 10.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  reausabletext(
                    "Camera off",
                    fontsize: 11,
                    fontfamily: FontFamily.interMedium,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}