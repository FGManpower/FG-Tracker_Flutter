import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/AddStatusController.dart';

class RecordingBadge extends StatelessWidget {
  final AddStatusController controller;

  const RecordingBadge({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70.h,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
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
                  'REC  ${controller.formatDuration(controller.recordDuration.value)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: FontFamily.interBold,
                  ),
                ),
              ],
            ),
          );
        }),
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
        padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
              Colors.black.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final hasCapturedMedia =
                controller.capturedFile.value != null &&
                    controller.mode.value != 'text';

            if (hasCapturedMedia) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CaptionInputBar(controller: controller),
                  SizedBox(height: 14.h),
                  PreviewActionRow(controller: controller),
                  SizedBox(height: 14.h),
                  PostRow(controller: controller),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.mode.value == 'text') ...[
                  TextColorRow(controller: controller),
                  SizedBox(height: 18.h),
                ] else ...[
                  CaptureRow(controller: controller),
                  SizedBox(height: 18.h),
                ],
                ModeTabs(controller: controller),
                if (controller.mode.value == 'text') ...[
                  SizedBox(height: 16.h),
                  PostRow(controller: controller),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

class CaptionInputBar extends StatelessWidget {
  final AddStatusController controller;

  const CaptionInputBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 48.h, maxHeight: 100.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.closed_caption_off_rounded,
            color: Colors.white70,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller.captionController,
              maxLines: 3,
              minLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontFamily: FontFamily.interMedium,
              ),
              cursorColor: const Color(0xFF6B4DFF),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Add a caption...',
                hintStyle: TextStyle(
                  color: Colors.white60,
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewActionRow extends StatelessWidget {
  final AddStatusController controller;

  const PreviewActionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PillControlButton(
          icon: Icons.refresh_rounded,
          label: 'Retake',
          onTap: controller.retake,
        ),
        SizedBox(width: 12.w),
        _PillControlButton(
          icon: Icons.photo_library_outlined,
          label: 'Change Media',
          onTap: controller.openGallery,
        ),
        if (controller.isVideoFile.value) ...[
          SizedBox(width: 12.w),
          Obx(() {
            final playing = controller.isVideoPlaying.value;
            return _PillControlButton(
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              label: playing ? 'Pause' : 'Play',
              onTap: controller.toggleVideoPlayPause,
            );
          }),
        ],
      ],
    );
  }
}

class _PillControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            reausabletext(
              label,
              fontsize: 12.sp,
              color: Colors.white,
              fontfamily: FontFamily.interMedium,
            ),
          ],
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
    return Obx(() {
      final isVideoMode = controller.mode.value == 'video';
      final isRec = controller.isRecording.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SideActionBtn(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: controller.openGallery,
          ),
          GestureDetector(
            onTap: controller.onShutterTap,
            onLongPress: isVideoMode ? controller.startVideoRecording : null,
            onLongPressUp: isVideoMode ? controller.stopVideoRecording : null,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRec
                      ? Colors.redAccent
                      : (isVideoMode
                      ? Colors.redAccent.withValues(alpha: 0.85)
                      : const Color(0xFF6B4DFF)),
                  width: 4,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isRec ? 30.w : 64.w,
                  height: isRec ? 30.w : 64.w,
                  decoration: BoxDecoration(
                    color: isRec || isVideoMode
                        ? Colors.redAccent
                        : Colors.white,
                    borderRadius: BorderRadius.circular(isRec ? 8.r : 40.r),
                  ),
                ),
              ),
            ),
          ),
          SideActionBtn(
            icon: Icons.cameraswitch_rounded,
            label: 'Flip',
            onTap: controller.flipCamera,
          ),
        ],
      );
    });
  }
}

class TextColorRow extends StatelessWidget {
  final AddStatusController controller;

  const TextColorRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.w,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: controller.bgColors.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          return Obx(() {
            final selected = i == controller.selectedBgIndex.value;
            return GestureDetector(
              onTap: () => controller.selectedBgIndex.value = i,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 38.w,
                height: 38.w,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(controller: controller, label: 'Photo', value: 'photo'),
          SizedBox(width: 6.w),
          _ModeChip(controller: controller, label: 'Video', value: 'video'),
          SizedBox(width: 6.w),
          _ModeChip(controller: controller, label: 'Text', value: 'text'),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final AddStatusController controller;
  final String label;
  final String value;

  const _ModeChip({
    required this.controller,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.mode.value == value;
      return GestureDetector(
        onTap: () => controller.changeMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
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
                  'Who can see?',
                  fontsize: 16.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
                SizedBox(height: 12.h),
                _WhoOption(
                  controller: controller,
                  title: 'All Contacts',
                  privacyValue: 'ALL_CONTACTS',
                  icon: Icons.public_rounded,
                ),
                _WhoOption(
                  controller: controller,
                  title: 'Except Selected',
                  privacyValue: 'EXCEPT_USERS',
                  icon: Icons.person_remove_alt_1_rounded,
                ),
                _WhoOption(
                  controller: controller,
                  title: 'Only Share With',
                  privacyValue: 'ONLY_SHARE_WITH',
                  icon: Icons.lock_outline_rounded,
                ),
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
              padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          'Privacy',
                          fontsize: 10.sp,
                          color: Colors.black54,
                          maxline: 1,
                        ),
                        Obx(() {
                          return reausabletext(
                            controller.whoCanSeeLabel,
                            fontsize: 11.sp,
                            fontfamily: FontFamily.interBold,
                            color: const Color(0xFF6B4DFF),
                            maxline: 1,
                          );
                        }),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_less_rounded,
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
          child: Obx(() {
            return GestureDetector(
              onTap: controller.isPosting.value ? null : controller.postStatus,
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4DFF), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4DFF).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.isPosting.value)
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: reausabletext(
                          'Post Status',
                          fontsize: 12.sp,
                          fontfamily: FontFamily.interBold,
                          color: Colors.white,
                          maxline: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _WhoOption extends StatelessWidget {
  final AddStatusController controller;
  final String title;
  final String privacyValue;
  final IconData icon;

  const _WhoOption({
    required this.controller,
    required this.title,
    required this.privacyValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.privacyType.value == privacyValue;
      return InkWell(
        onTap: () {
          controller.privacyType.value = privacyValue;
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

  const SideActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          reausabletext(
            label,
            fontsize: 10.sp,
            color: Colors.white,
            fontfamily: FontFamily.interMedium,
          ),
        ],
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
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF6B4DFF)
                  : Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: Colors.white,
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