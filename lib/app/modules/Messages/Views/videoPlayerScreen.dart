import 'package:fgtracker/app/modules/Messages/Controller/VideoController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

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
          backgroundColor: const Color(0xff090909),
          body: GestureDetector(
            onTap: c.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff111111),
                        Color(0xff000000),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: AspectRatio(
                    aspectRatio: c.videoController.value.aspectRatio,
                    child: VideoPlayer(
                      c.videoController,
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    opacity: c.showControls.value ? 1 : 0,
                    child: Container(
                      color: Colors.black26,
                    ),
                  ),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    top: c.showControls.value ? 5.h : -120.h,
                    left: 15.w,
                    right: 15.w,
                    child: SafeArea(
                      child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                              .45,
                            ),
                            borderRadius: BorderRadius.circular(
                              7.r,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(.08),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: Get.back,
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),

                              // Expanded(
                              //   child: Text(
                              //     fileName,
                              //     maxLines: 1,
                              //     overflow: TextOverflow.ellipsis,
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 14.sp,
                              //       fontWeight: FontWeight.w600,
                              //     ),
                              //   ),
                              // ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: c.shareVideo,
                                    child: Container(
                                      width: 38.w,
                                      height: 38.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.share_outlined,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  InkWell(
                                    onTap: c.downloadVideo,
                                    child: Container(
                                      width: 38.w,
                                      height: 38.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                  ),
                ),
                Obx(
                  () => c.showControls.value
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: c.seekBackward,
                                child: Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                      .55,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.replay_10,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w),
                              GestureDetector(
                                onTap: c.togglePlayPause,
                                child: Container(
                                  width: 90.w,
                                  height: 90.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(
                                          .25,
                                        ),
                                        Colors.white.withOpacity(
                                          .08,
                                        ),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white24,
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
                              SizedBox(width: 20.w),
                              GestureDetector(
                                onTap: c.seekForward,
                                child: Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(
                                      .55,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.forward_10,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
                Obx(
                  () => AnimatedPositioned(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    bottom: c.showControls.value ? 0 : -160.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 30.h,
                        top: 15.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(
                              context,
                            ).copyWith(
                              trackHeight: 4.h,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 7.r,
                              ),
                            ),
                            child: Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.white24,
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
                                  Duration(
                                    milliseconds: value.toInt(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                c.formatDuration(
                                  c.position.value,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                c.formatDuration(
                                  c.duration.value,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
}
