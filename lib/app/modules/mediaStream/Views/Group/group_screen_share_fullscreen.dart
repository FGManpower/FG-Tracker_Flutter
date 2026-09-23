import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import '../../../../../gen/fonts.gen.dart';

class GroupScreenShareFullScreen extends StatelessWidget {
  final GroupCallingController controller;
  final GroupCallParticipant participant;

  const GroupScreenShareFullScreen({
    super.key,
    required this.controller,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0B29),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. WebRTC Screen Share Stream with Pinch-to-Zoom
          Obx(() {
            final renderer = participant.renderer;
            final isVideoOn = participant.isVideoOn.value;
            final hasStream = renderer != null &&
                renderer.srcObject != null &&
                renderer.srcObject!.getVideoTracks().isNotEmpty;

            if (hasStream && isVideoOn) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0, // Allows users to pinch-to-zoom into screen share
                child: SizedBox.expand(
                  child: RTCVideoView(
                    renderer,
                    key: ValueKey(
                        'fs_video_${participant.userId}_${renderer.textureId}'),
                    objectFit:
                    RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    mirror: false,
                  ),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B58FF).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.present_to_all_rounded,
                      color: Colors.white,
                      size: 48.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "${participant.name} is sharing screen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: FontFamily.interSemiBold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Connecting video feed...",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interRegular,
                    ),
                  ),
                ],
              ),
            );
          }),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                14.w,
                MediaQuery.of(context).padding.top + 8.h,
                14.w,
                12.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: controller.closeFullScreenShare,
                    borderRadius: BorderRadius.circular(30.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${participant.name}'s Screen",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontFamily: FontFamily.interBold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
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
                            Text(
                              "Live Screen Share",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12.sp,
                                fontFamily: FontFamily.interMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: controller.closeFullScreenShare,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B58FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Grid View",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontFamily: FontFamily.interSemiBold,
                            ),
                          ),
                        ],
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