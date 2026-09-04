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

  const GroupParticipantGrid({
    super.key,
    required this.participants,
    required this.isVideoMode,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox();

    int count = participants.length;

    if (count == 1) {
      return _buildTile(participants[0], isFullScreen: true);
    } else if (count == 2) {
      return Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 90.h, bottom: 140.h),
        child: Column(
          children: [
            Expanded(child: _buildTile(participants[0], isFullScreen: false)),
            SizedBox(height: 10.h),
            Expanded(child: _buildTile(participants[1], isFullScreen: false)),
          ],
        ),
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 90.h, bottom: 140.h),
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
  }

  Widget _buildTile(GroupCallParticipant participant, {required bool isFullScreen}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isFullScreen ? 0 : 15.r),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isFullScreen ? 0 : 15.r),
          color: const Color(0xFF1E1147),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              final isVideoOn = participant.isVideoOn.value;
              final rendererReady =
                  participant.renderer != null && participant.renderer!.textureId != null;

              if (isVideoMode && isVideoOn && rendererReady) {
                return RTCVideoView(
                  participant.renderer!,
                  mirror: participant.isLocal,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                );
              }
              return _buildFallback(
                participant,
                cameraOff: isVideoMode && !isVideoOn,
                isFullScreen: isFullScreen,
              );
            }),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: isFullScreen ? 250.h : 55.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(isFullScreen ? 0.8 : 0.7),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),

            if (!isFullScreen)
              Positioned(
                left: 16.w,
                bottom: 10.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: reausabletext(
                    participant.isLocal ? "${participant.name} (You)" : participant.name,
                    fontsize: 13,
                    fontfamily: FontFamily.interSemiBold,
                    color: Colors.white,
                  ),
                ),
              ),

            if (!isFullScreen)
              Positioned(
                right: 16.w,
                bottom: 10.h,
                child: Obx(() {
                  final isSpeaking = participant.isSpeaking.value;
                  final isMuted = participant.isMuted.value;

                  if (isMuted) {
                    return Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic_off, color: Colors.white, size: 16.sp),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.graphic_eq,
                      color: isSpeaking ? Colors.greenAccent : Colors.white70,
                      size: 18.sp,
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(GroupCallParticipant participant, {required bool cameraOff, required bool isFullScreen}) {
    final imageUrl = Utility.isNullEmptyOrFalse(participant.profileImage)
        ? MyAppTheme.ProfilenotFoundImg
        : ConstRes.aImageBaseUrl + (participant.profileImage ?? '');

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF1E1147)),

        Center(
          child: CircleAvatar(
            radius: isFullScreen ? 75.r : 45.r,
            backgroundColor: Colors.white12,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, __) {},
            child: Utility.isNullEmptyOrFalse(participant.profileImage)
                ? Icon(Icons.person, color: Colors.white, size: isFullScreen ? 80.r : 50.r)
                : null,
          ),
        ),

        if (cameraOff)
          Positioned(
            top: isFullScreen ? 120.h : 10.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white, size: 14.sp),
                  SizedBox(width: 6.w),
                  reausabletext(
                    "Camera off",
                    fontsize: 12,
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