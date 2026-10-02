import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import '../controller/AddStatusController.dart';

class StatusPreview extends StatelessWidget {
  final AddStatusController controller;

  const StatusPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.videocam_rounded,
                      color: Colors.white, size: 48.sp),
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
              Icon(Icons.videocam_off_rounded,
                  color: Colors.white54, size: 48.sp),
              SizedBox(height: 12.h),
              reausabletext(controller.error.value!,
                  fontsize: 13.sp, color: Colors.white70),
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
}

class StatusTopBar extends StatelessWidget {
  final AddStatusController controller;

  const StatusTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundActionBtn(
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
                    RoundActionBtn(
                      icon: controller.isFlashOn.value
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: controller.toggleFlash,
                      active: controller.isFlashOn.value,
                    ),
                    SizedBox(height: 10.h),
                    RoundActionBtn(
                      icon: Icons.cameraswitch_rounded,
                      onTap: controller.flipCamera,
                      label: "Flip",
                    ),
                  ] else
                    RoundActionBtn(
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
}

class RecordingBadge extends StatelessWidget {
  final AddStatusController controller;

  const RecordingBadge({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class StatusBottomControls extends StatelessWidget {
  final AddStatusController controller;

  const StatusBottomControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                if (controller.capturedFile.value == null &&
                    controller.mode.value != "text") {
                  return CaptureRow(controller: controller);
                } else if (controller.mode.value == "text") {
                  return TextColorRow(controller: controller);
                } else {
                  return RetakeRow(controller: controller);
                }
              }),
              SizedBox(height: 16.h),
              ModeTabs(controller: controller),
              SizedBox(height: 16.h),
              PostRow(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class CaptureRow extends StatelessWidget {
  final AddStatusController controller;

  const CaptureRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SideActionBtn(
          icon: Icons.photo_library_rounded,
          label: "Gallery",
          onTap: controller.openGallery,
        ),
        GestureDetector(
          onTap: controller.onShutterTap,
          onLongPress: controller.mode.value == "video"
              ? controller.startVideoRecording
              : null,
          onLongPressUp: controller.mode.value == "video"
              ? controller.stopVideoRecording
              : null,
          child: Container(
            width: 78.w,
            height: 78.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: controller.isRecording.value
                    ? Colors.redAccent
                    : const Color(0xFF6B4DFF),
                width: 4,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: controller.isRecording.value ? 28.w : 62.w,
                height: controller.isRecording.value ? 28.w : 62.w,
                decoration: BoxDecoration(
                  color: controller.isRecording.value
                      ? Colors.redAccent
                      : Colors.white,
                  borderRadius: BorderRadius.circular(
                    controller.isRecording.value ? 8.r : 40.r,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 48.w),
      ],
    );
  }
}

class RetakeRow extends StatelessWidget {
  final AddStatusController controller;

  const RetakeRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class TextColorRow extends StatelessWidget {
  final AddStatusController controller;

  const TextColorRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class ModeTabs extends StatelessWidget {
  final AddStatusController controller;

  const ModeTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ModeChip(controller: controller, label: "Photo", value: "photo"),
        SizedBox(width: 18.w),
        _ModeChip(controller: controller, label: "Video", value: "video"),
        SizedBox(width: 18.w),
        _ModeChip(controller: controller, label: "Text", value: "text"),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final AddStatusController controller;
  final String label;
  final String value;

  const _ModeChip(
      {required this.controller, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
              fontFamily:
                  selected ? FontFamily.interBold : FontFamily.interMedium,
            ),
          ),
        ),
      );
    });
  }
}

class PostRow extends StatelessWidget {
  final AddStatusController controller;

  const PostRow({super.key, required this.controller});

  void _showWhoCanSeeSheet() {
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
                _WhoOption(
                    controller: controller,
                    title: "My Team",
                    icon: Icons.groups_rounded),
                _WhoOption(
                    controller: controller,
                    title: "Everyone",
                    icon: Icons.public_rounded),
                _WhoOption(
                    controller: controller,
                    title: "Only Me",
                    icon: Icons.lock_outline_rounded),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _showWhoCanSeeSheet,
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9E7FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: const Color(0xFF6B4DFF),
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          "Who can see?",
                          fontsize: 12.sp,
                          fontfamily: FontFamily.interBold,
                          color: Colors.black87,
                          maxline: 1,
                        ),
                        Obx(() {
                          return reausabletext(
                            controller.whoCanSee.value,
                            fontsize: 9.sp,
                            color: const Color(0xFF6B4DFF),
                            maxline: 1,
                          );
                        }),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF6B4DFF),
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: controller.postStatus,
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4DFF),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 16.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: reausabletext(
                      "Post to My Status",
                      fontsize: 11.sp,
                      fontfamily: FontFamily.interBold,
                      color: Colors.white,
                      maxline: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WhoOption extends StatelessWidget {
  final AddStatusController controller;
  final String title;
  final IconData icon;

  const _WhoOption(
      {required this.controller, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
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
}

class SideActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SideActionBtn(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Color(0xFF6B4DFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18.sp),
            ),
            SizedBox(height: 6.h),
            reausabletext(
              label,
              fontsize: 10.sp,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class RoundActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? label;

  const RoundActionBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
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
            label!,
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
