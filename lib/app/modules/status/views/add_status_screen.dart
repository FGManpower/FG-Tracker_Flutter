import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import '../controller/AddStatusController.dart';

class AddStatusScreen extends StatelessWidget {
  const AddStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddStatusController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(controller),
          _buildTopBar(controller),
          Obx(() {
            if (controller.isRecording.value) {
              return _buildRecordingBadge(controller);
            }
            return const SizedBox.shrink();
          }),
          _buildBottomControls(controller, context),
        ],
      ),
    );
  }

  Widget _buildPreview(AddStatusController controller) {
    return Obx(() {
      if (controller.mode.value == "text") {
        return Container(
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
                    hintText: "Type a status",
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
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, color: Colors.white, size: 48.sp),
                  SizedBox(height: 10.h),
                  reausabletext(
                    "Video ready",
                    fontsize: 14.sp,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  reausabletext(
                    controller.capturedFile.value!.path.split('/').last,
                    fontsize: 11.sp,
                    color: Colors.white70,
                    maxline: 1,
                  ),
                ],
              ),
            ),
          );
        }

        return Image.file(
          controller.capturedFile.value!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
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
              Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 48.sp),
              SizedBox(height: 12.h),
              reausabletext(controller.error.value!, fontsize: 13.sp, color: Colors.white70),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: controller.initCamera,
                child: reausabletext(
                  "Retry",
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

  Widget _buildTopBar(AddStatusController controller) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _roundBtn(
              icon: Icons.close_rounded,
              onTap: () => Get.back(),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  reausabletext(
                    "Add to My Status",
                    fontsize: 16.sp,
                    fontfamily: FontFamily.interBold,
                    color: Colors.white,
                  ),
                  SizedBox(height: 2.h),
                  reausabletext(
                    "Share with your team",
                    fontsize: 11.sp,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            Obx(() {
              return Column(
                children: [
                  if (controller.mode.value != "text") ...[
                    _roundBtn(
                      icon: controller.isFlashOn.value
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: controller.toggleFlash,
                      active: controller.isFlashOn.value,
                    ),
                    SizedBox(height: 10.h),
                    _roundBtn(
                      icon: Icons.cameraswitch_rounded,
                      onTap: controller.flipCamera,
                      label: "Flip",
                    ),
                  ] else
                    _roundBtn(
                      icon: Icons.color_lens_rounded,
                      onTap: () {
                        controller.selectedBgIndex.value =
                            (controller.selectedBgIndex.value + 1) %
                                controller.bgColors.length;
                      },
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingBadge(AddStatusController controller) {
    return Positioned(
      top: 110.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "REC  ${controller.formatDuration(controller.recordDuration.value)}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontFamily: FontFamily.interBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(AddStatusController controller, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
              Colors.black.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (controller.capturedFile.value == null && controller.mode.value != "text") {
                  return _buildCaptureRow(controller);
                } else if (controller.mode.value == "text") {
                  return _buildTextColorRow(controller);
                } else {
                  return _buildRetakeRow(controller);
                }
              }),
              SizedBox(height: 16.h),
              _buildModeTabs(controller),
              SizedBox(height: 16.h),
              _buildPostRow(controller, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureRow(AddStatusController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _sideAction(
          icon: Icons.photo_library_rounded,
          label: "Gallery",
          onTap: controller.openGallery,
        ),
        GestureDetector(
          onTap: controller.onShutterTap,
          onLongPress: controller.mode.value == "video" ? controller.startVideoRecording : null,
          onLongPressUp: controller.mode.value == "video" ? controller.stopVideoRecording : null,
          child: Container(
            width: 78.w,
            height: 78.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: controller.isRecording.value ? Colors.redAccent : const Color(0xFF6B4DFF),
                width: 4,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: controller.isRecording.value ? 28.w : 62.w,
                height: controller.isRecording.value ? 28.w : 62.w,
                decoration: BoxDecoration(
                  color: controller.isRecording.value ? Colors.redAccent : Colors.white,
                  borderRadius: BorderRadius.circular(
                    controller.isRecording.value ? 8.r : 40.r,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 62.w),
      ],
    );
  }

  Widget _buildRetakeRow(AddStatusController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.retake,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                reausabletext(
                  "Retake",
                  fontsize: 13.sp,
                  color: Colors.white,
                  fontfamily: FontFamily.interMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextColorRow(AddStatusController controller) {
    return SizedBox(
      height: 36.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.bgColors.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          return Obx(() {
            final selected = i == controller.selectedBgIndex.value;
            return GestureDetector(
              onTap: () => controller.selectedBgIndex.value = i,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: controller.bgColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : Colors.white24,
                    width: selected ? 3 : 1.5,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildModeTabs(AddStatusController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _modeChip(controller, "Photo", "photo"),
        SizedBox(width: 18.w),
        _modeChip(controller, "Video", "video"),
        SizedBox(width: 18.w),
        _modeChip(controller, "Text", "text"),
      ],
    );
  }

  Widget _modeChip(AddStatusController controller, String label, String value) {
    return Obx(() {
      final selected = controller.mode.value == value;
      return GestureDetector(
        onTap: () => controller.changeMode(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6B4DFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 13.sp,
              fontFamily: selected ? FontFamily.interBold : FontFamily.interMedium,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPostRow(AddStatusController controller, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showWhoCanSeeSheet(controller, context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9E7FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: const Color(0xFF6B4DFF),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          "Who can see?",
                          fontsize: 12.sp,
                          fontfamily: FontFamily.interBold,
                          color: Colors.black87,
                        ),
                        Obx(() {
                          return reausabletext(
                            controller.whoCanSee.value,
                            fontsize: 10.sp,
                            color: const Color(0xFF6B4DFF),
                          );
                        }),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: controller.postStatus,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4DFF),
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Row(
              children: [
                Icon(Icons.send_rounded, color: Colors.white, size: 16.sp),
                SizedBox(width: 8.w),
                reausabletext(
                  "Post to My Status",
                  fontsize: 12.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showWhoCanSeeSheet(AddStatusController controller, BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                reausabletext(
                  "Who can see?",
                  fontsize: 16.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 12.h),
                _whoOption(controller, "My Team", Icons.groups_rounded),
                _whoOption(controller, "Everyone", Icons.public_rounded),
                _whoOption(controller, "Only Me", Icons.lock_outline_rounded),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _whoOption(AddStatusController controller, String title, IconData icon) {
    return Obx(() {
      final selected = controller.whoCanSee.value == title;
      return InkWell(
        onTap: () {
          controller.whoCanSee.value = title;
          Get.back();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9E7FF) : const Color(0xFFF7F7FB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? const Color(0xFF6B4DFF) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF6B4DFF),
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: reausabletext(
                  title,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interMedium,
                  color: Colors.black87,
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF6B4DFF),
                  size: 20.sp,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _sideAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Color(0xFF6B4DFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          reausabletext(
            label,
            fontsize: 11.sp,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
    String? label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF6B4DFF)
                  : Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: active ? Colors.white : const Color(0xFF6B4DFF),
            ),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
            ),
          ),
        ],
      ],
    );
  }
}