import 'package:camera/camera.dart';
import 'package:fgtracker/app/modules/Messages/Controller/CameraControllerX.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CameraScreen extends StatelessWidget {
  CameraScreen({super.key});

  final controller = Get.put(CameraControllerX());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
            fit: StackFit.expand,
            children: [

              if (controller.isCameraInitialized.value &&
                  controller.cameraController != null &&
                  controller.cameraController!.value.isInitialized)
                CameraPreview(controller.cameraController!)
              else
                const Center(
                    child: CircularProgressIndicator(color: Colors.white)),


              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: CircleAvatar(
                            radius: 19.sp,
                            backgroundColor: Colors.grey.withOpacity(0.8),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 24.w),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: controller.toggleFlash,
                              child: CircleAvatar(
                                radius: 19.sp,
                                backgroundColor: Colors.grey.withOpacity(0.8),
                                child: Icon(
                                  controller.isFlashOn.value
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Colors.white,
                                  size: 24.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: controller.switchCamera,
                              child: CircleAvatar(
                                radius: 19.sp,
                                backgroundColor: Colors.grey.withOpacity(0.8),
                                child: Icon(Icons.flip_camera_ios_outlined,
                                    color: Colors.white, size: 24.w),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Controls
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mode Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMode("PORTRAIT"),
                          SizedBox(width: 40.w),
                          _buildMode("PHOTO"),
                          SizedBox(width: 40.w),
                          _buildMode("VIDEO"),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Capture Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // GestureDetector(
                          //   onTap: () async {
                          //     final file =
                          //         await FileServices().pickVideoFromGallery();
                          //     if (file != null) {
                          //       Get.back(result: file.path);
                          //     }
                          //   },
                          //   child: Container(
                          //     width: 55.w,
                          //     height: 55.w,
                          //     decoration: BoxDecoration(
                          //       border:
                          //           Border.all(color: Colors.white70, width: 2),
                          //       borderRadius: BorderRadius.circular(12.r),
                          //       image: const DecorationImage(
                          //         image: NetworkImage(
                          //             "https://picsum.photos/id/1015/200/200"),
                          //         fit: BoxFit.cover,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          GestureDetector(
                            onTap: () async {
                              if (controller.selectedMode.value == "VIDEO") {
                                final XFile? file =
                                    await controller.toggleVideoRecording();
                                if (file != null) {
                                  Get.back(result: file.path);
                                }

                              } else {
                                final XFile? file =
                                    await controller.takePictureWithReturn();
                                if (file != null) {
                                  Get.back(result: file.path);
                                }
                              }
                            },
                            onLongPress: () {
                              if (controller.selectedMode.value == "PHOTO") {
                                controller.toggleVideoRecording();
                              }
                            },
                            child: Container(
                              width: 85.w,
                              height: 85.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 6.w),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: controller.isRecording.value
                                      ? 58.w
                                      : 68.w,
                                  height: controller.isRecording.value
                                      ? 58.w
                                      : 68.w,
                                  decoration: BoxDecoration(
                                    color: controller.isRecording.value
                                        ? Colors.red
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // SizedBox(width: 55.w),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recording Timer
              if (controller.isRecording.value)
                Positioned(
                  top: 140.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fiber_manual_record,
                              color: Colors.red, size: 18),
                          SizedBox(width: 8.w),
                          Text(
                            _formatRecordingTime(
                                controller.recordingSeconds.value),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildMode(String mode) {
    return GestureDetector(
      onTap: () => controller.selectedMode.value = mode,
      child: Obx(() => Text(
            mode,
            style: TextStyle(
              color: controller.selectedMode.value == mode
                  ? Colors.white
                  : Colors.white70,
              fontSize: 16.5.sp,
              fontWeight: controller.selectedMode.value == mode
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          )),
    );
  }

  String _formatRecordingTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }
}
