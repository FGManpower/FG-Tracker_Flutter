import 'package:camera/camera.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/AddStatusController.dart';

class StatusPreview extends StatelessWidget {
  final AddStatusController controller;

  const StatusPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.mode.value == 'text') {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: controller.bgColors[controller.selectedBgIndex.value],
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: TextField(
                  controller: controller.textController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontFamily: FontFamily.interBold,
                    height: 1.3,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type a status...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 28.sp,
                      fontFamily: FontFamily.interBold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (controller.capturedFile.value != null) {
        if (controller.isVideoFile.value) {
          final vc = controller.previewVideoController;
          if (!controller.isVideoPreviewReady.value ||
              vc == null ||
              !vc.value.isInitialized) {
            return const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF6B4DFF)),
              ),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.toggleVideoPlayPause,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: vc.value.aspectRatio > 0
                          ? vc.value.aspectRatio
                          : 9 / 16,
                      child: VideoPlayer(vc),
                    ),
                  ),
                ),
                Obx(() {
                  final playing = controller.isVideoPlaying.value;
                  return AnimatedOpacity(
                    opacity: playing ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Center(
                      child: Container(
                        width: 68.w,
                        height: 68.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  );
                }),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68.h,
                  left: 16.w,
                  right: 16.w,
                  child: Obx(() {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: controller.videoProgress.value,
                        minHeight: 3.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.28),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6B4DFF),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }

        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: Image.file(
            controller.capturedFile.value!,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }

      if (controller.isInitializing.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B4DFF)),
        );
      }

      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                color: Colors.white54,
                size: 48.sp,
              ),
              SizedBox(height: 12.h),
              reausabletext(
                controller.error.value!,
                fontsize: 13.sp,
                color: Colors.white70,
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: controller.initCamera,
                child: reausabletext(
                  'Retry',
                  fontsize: 13.sp,
                  color: const Color(0xFF6B4DFF),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.isCameraReady.value &&
          controller.cameraController != null &&
          controller.cameraController!.value.isInitialized) {
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.cameraController!.value.previewSize?.height ?? 1,
            height: controller.cameraController!.value.previewSize?.width ?? 1,
            child: CameraPreview(controller.cameraController!),
          ),
        );
      }

      return const ColoredBox(color: Colors.black);
    });
  }
}