import 'package:fgtracker/app/modules/Messages/Controller/VideoController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class VideoPlayerScreen extends GetView<VideoControllerX> {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoControllerX>(
      builder: (c) {
        if (!c.videoController.value.isInitialized) {
          return Scaffold(
            backgroundColor: const Color(0xff090909),
            body: Center(
              child: SizedBox(
                width: 35.w,
                height: 35.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: c.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: c.videoController.value.aspectRatio,
                    child: VideoPlayer(c.videoController),
                  ),
                ),
                Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: c.showControls.value ? 1 : 0,
                    child: Container(
                      color: Colors.black26,
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: c.showControls.value ? 0 : -120.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 110.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Row(
                            children: [
                              _buildTopButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: Get.back,
                                size: 18,
                              ),
                              const Spacer(),
                              _buildTopButton(
                                icon: Icons.share_outlined,
                                onTap: c.shareVideo,
                                size: 20,
                              ),
                              SizedBox(width: 12.w),
                              _buildTopButton(
                                icon: Icons.download_rounded,
                                onTap: c.downloadVideo,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => c.showControls.value
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCenterSeekButton(
                                icon: Icons.replay_10,
                                onTap: c.seekBackward,
                              ),
                              SizedBox(width: 25.w),
                              GestureDetector(
                                onTap: c.togglePlayPause,
                                child: Container(
                                  width: 85.w,
                                  height: 85.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white30,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    c.videoController.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 50.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 25.w),
                              _buildCenterSeekButton(
                                icon: Icons.forward_10,
                                onTap: c.seekForward,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: c.showControls.value ? 0 : -150.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 40.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.h,
                              thumbColor: Colors.white,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.r,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 12.r,
                              ),
                            ),
                            child: Slider(
                              value: c.position.value.inMilliseconds
                                  .toDouble()
                                  .clamp(
                                    0,
                                    c.duration.value.inMilliseconds.toDouble(),
                                  ),
                              min: 0,
                              max: c.duration.value.inMilliseconds <= 0
                                  ? 1
                                  : c.duration.value.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                c.videoController.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.formatDuration(c.position.value),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                Text(
                                  c.formatDuration(c.duration.value),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: size.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterSeekButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55.w,
        height: 55.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 26.sp),
      ),
    );
  }
}
