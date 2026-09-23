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
  final void Function(GroupCallParticipant participant)? onParticipantTap;
  final void Function(String userId)? onViewScreenShare;

  const GroupParticipantGrid({
    super.key,
    required this.participants,
    required this.isVideoMode,
    this.screenSharingUserIds = const {},
    this.onParticipantTap,
    this.onViewScreenShare,
  });

  bool _isSharing(String userId) {
    final targetId = userId.toString().trim();
    return screenSharingUserIds.map((e) => e.toString().trim()).contains(targetId);
  }

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox();

    final sharerIndex = participants.indexWhere(
          (p) => _isSharing(p.userId),
    );

    int count = participants.length;

    // 1 Participant (Takes 100% full screen)
    if (count == 1) {
      return _buildTile(participants[0], isFullScreen: true);
    }

    // SCREEN SHARE ACTIVE LAYOUT (Screen Share Tile takes 90% Height)
    if (sharerIndex >= 0 && count >= 2) {
      final sharer = participants[sharerIndex];
      final others = <GroupCallParticipant>[
        for (int i = 0; i < participants.length; i++)
          if (i != sharerIndex) participants[i],
      ];

      return Padding(
        padding: EdgeInsets.only(
          left: 8.w,
          right: 8.w,
          top: 60.h,
          bottom: 90.h,
        ),
        child: Column(
          children: [
            // 90% HEIGHT: Primary Shared Screen View
            Expanded(
              flex: 9,
              child: _buildTile(
                sharer,
                isFullScreen: false,
                emphasizeShare: true,
              ),
            ),
            SizedBox(height: 8.h),

            // 10% HEIGHT: Other Members Horizontal Strip
            Expanded(
              flex: 1,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: others.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 100.w,
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

    // 2 Participants Layout
    if (count == 2) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 90.h,
          bottom: 140.h,
        ),
        child: Column(
          children: [
            Expanded(child: _buildTile(participants[0], isFullScreen: false)),
            SizedBox(height: 10.h),
            Expanded(child: _buildTile(participants[1], isFullScreen: false)),
          ],
        ),
      );
    }

    // 3+ Participants Grid Layout
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 90.h,
        bottom: 140.h,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.8,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (count == 5 && index == 4) {
          return Center(
            child: SizedBox(
              width: 200.w,
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
        bool emphasizeShare = false,
        bool isThumbnail = false,
      }) {
    final sharing = _isSharing(participant.userId);

    return InkWell(
      onTap: () {
        if (sharing) {
          onViewScreenShare?.call(participant.userId.toString().trim());
        } else {
          onParticipantTap?.call(participant);
        }
      },
      borderRadius: BorderRadius.circular(isFullScreen ? 0 : 15.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFullScreen ? 0 : 15.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isFullScreen ? 0 : 15.r),
            color: const Color(0xFF1E1147),
            border: sharing
                ? Border.all(color: const Color(0xFF7B58FF), width: 2.5)
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // -------- Video / Avatar Renderer --------
              Obx(() {
                final isVideoOn = participant.isVideoOn.value;
                final rendererReady = participant.renderer != null &&
                    participant.renderer!.textureId != null;

                if ((isVideoMode || sharing) && isVideoOn && rendererReady) {
                  return RTCVideoView(
                    participant.renderer!,
                    mirror: participant.isLocal && !sharing,
                    objectFit: sharing
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

              // -------- Bottom Gradient Overlay --------
              if (!isThumbnail)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: isFullScreen ? 250.h : 60.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(isFullScreen ? 0.8 : 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // -------- Screen Sharing Badge --------
              if (sharing && !isThumbnail)
                Positioned(
                  top: isFullScreen ? 100.h : 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B58FF),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B58FF).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.present_to_all_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          participant.isLocal
                              ? "You're sharing screen"
                              : "${participant.name} is sharing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontFamily: FontFamily.interSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // -------- View Full Screen Tap Button --------
              if (sharing && !isFullScreen && !isThumbnail)
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onViewScreenShare?.call(
                          participant.userId.toString().trim(),
                        );
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              size: 16.sp,
                              color: const Color(0xFF7B58FF),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Full Screen",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontFamily: FontFamily.interSemiBold,
                                color: const Color(0xFF7B58FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // -------- Participant Name Tag --------
              if (!isFullScreen)
                Positioned(
                  left: isThumbnail ? 4.w : 12.w,
                  bottom: isThumbnail ? 4.h : 12.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isThumbnail ? 6.w : 8.w,
                      vertical: isThumbnail ? 2.h : 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: reausabletext(
                      participant.isLocal
                          ? "You"
                          : participant.name.toString(),
                      fontsize: isThumbnail ? 10 : 12,
                      fontfamily: FontFamily.interSemiBold,
                      color: Colors.white,
                    ),
                  ),
                ),

              // -------- Mute / Speaking Indicator --------
              if (!isFullScreen && !isThumbnail)
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Obx(() {
                    final isSpeaking = participant.isSpeaking.value;
                    final isMuted = participant.isMuted.value;

                    if (isMuted) {
                      return Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic_off,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      );
                    }
                    return Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.graphic_eq,
                        color: isSpeaking
                            ? Colors.greenAccent
                            : Colors.white70,
                        size: 16.sp,
                      ),
                    );
                  }),
                ),
            ],
          ),
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
            radius: isFullScreen
                ? 75.r
                : (isThumbnail ? 20.r : 40.r),
            backgroundColor: Colors.white12,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
            child: Utility.isNullEmptyOrFalse(participant.profileImage)
                ? Icon(
              Icons.person,
              color: Colors.white,
              size: isFullScreen
                  ? 80.r
                  : (isThumbnail ? 22.r : 44.r),
            )
                : null,
          ),
        ),
        if (cameraOff && !isThumbnail)
          Positioned(
            top: isFullScreen ? 120.h : 10.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
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