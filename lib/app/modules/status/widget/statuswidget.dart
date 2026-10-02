import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/status_view_controller.dart';


class StatusBackground extends StatelessWidget {
  final StatusItemModel status;
  final StatusViewController controller;

  const StatusBackground({
    super.key,
    required this.status,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (status.type == 'text') {
      return Container(
        color: status.parsedBgColor,
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        alignment: Alignment.center,
        child: Text(
          status.content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.sp,
            fontFamily: FontFamily.interBold,
            height: 1.3,
          ),
        ),
      );
    }

    if (controller.isVideoStatus(status)) {
      return Obx(() {
        if (controller.hasVideoError.value) {
          return const PlaceholderBg();
        }

        final vc = controller.videoController;
        if (!controller.isVideoInitialized.value ||
            vc == null ||
            !vc.value.isInitialized) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B4DFF),
              ),
            ),
          );
        }

        return Stack(
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
            if (controller.isVideoBuffering.value)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        );
      });
    }

    final imageUrl = status.mediaUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const PlaceholderBg(),
        );
      }
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const PlaceholderBg(),
      );
    }
    return const PlaceholderBg();
  }
}

class PlaceholderBg extends StatelessWidget {
  const PlaceholderBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B3A5F),
            Color(0xFF0D1B2A),
            Color(0xFF000000),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_rounded, color: Colors.white24, size: 64.sp),
      ),
    );
  }
}

class StatusGradientOverlays extends StatelessWidget {
  const StatusGradientOverlays({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusProgressBars extends StatelessWidget {
  final StatusViewController controller;
  const StatusProgressBars({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          children: List.generate(controller.totalStatuses, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: AnimatedBuilder(
                  animation: controller.progressController,
                  builder: (_, __) {
                    double value;
                    if (i < controller.currentIndex.value) {
                      value = 1.0;
                    } else if (i == controller.currentIndex.value) {
                      value = controller.progressController.value;
                    } else {
                      value = 0.0;
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 2.5.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.35),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class StatusTopBar extends StatelessWidget {
  final StatusViewController controller;
  final bool isOwnStatus;
  final String userName;
  final String? userAvatar;
  final String timeText;

  const StatusTopBar({
    super.key,
    required this.controller,
    required this.isOwnStatus,
    required this.userName,
    this.userAvatar,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6B4DFF), width: 2),
            ),
            child: ClipOval(
              child: (userAvatar != null && userAvatar!.isNotEmpty)
                  ? Image.network(userAvatar!, fit: BoxFit.cover)
                  : Container(
                color: const Color(0xFFE9E7FF),
                child: Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF6B4DFF),
                  size: 22.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reausabletext(
                  userName,
                  fontsize: 14.sp,
                  fontfamily: FontFamily.interBold,
                  color: Colors.white,
                ),
                reausabletext(
                  timeText,
                  fontsize: 11.sp,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          if (isOwnStatus)
            CompositedTransformTarget(
              link: controller.menuLink,
              child: Builder(
                builder: (btnContext) {
                  return GestureDetector(
                    onTap: () => controller.showMenu(btnContext),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class StatusCaptionArea extends StatelessWidget {
  final String caption;
  final String location;

  const StatusCaptionArea({
    super.key,
    required this.caption,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    if (caption.isEmpty && location.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (caption.isNotEmpty)
              Text(
                caption,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.sp,
                  fontFamily: FontFamily.interBold,
                  height: 1.25,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            if (location.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    reausabletext(
                      location,
                      fontsize: 12.sp,
                      color: Colors.white,
                      fontfamily: FontFamily.interMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusOwnFooter extends StatelessWidget {
  final StatusItemModel status;
  final VoidCallback onOpenViewers;
  final VoidCallback onCloseViewers;

  const StatusOwnFooter({
    super.key,
    required this.status,
    required this.onOpenViewers,
    required this.onCloseViewers,
  });

  void _showViewersBottomSheet() {
    onOpenViewers();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: 420.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
        child: SafeArea(
          top: false,
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
              SizedBox(height: 14.h),
              reausabletext(
                'Viewed by ${status.viewsCount}',
                fontsize: 15.sp,
                fontfamily: FontFamily.interBold,
                color: Colors.black87,
              ),
              SizedBox(height: 12.h),
              if (status.viewers.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: reausabletext(
                      'No views yet',
                      fontsize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: status.viewers.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                    itemBuilder: (_, index) {
                      final viewer = status.viewers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 20.r,
                          backgroundColor: const Color(0xFFE9E7FF),
                          backgroundImage: (viewer.profileImage != null &&
                              viewer.profileImage!.isNotEmpty)
                              ? NetworkImage(viewer.profileImage!)
                              : null,
                          child: (viewer.profileImage == null ||
                              viewer.profileImage!.isEmpty)
                              ? Icon(
                            Icons.person,
                            color: const Color(0xFF6B4DFF),
                            size: 20.sp,
                          )
                              : null,
                        ),
                        title: reausabletext(
                          viewer.name,
                          fontsize: 13.sp,
                          fontfamily: FontFamily.interMedium,
                          color: Colors.black87,
                        ),
                        trailing: (viewer.reactionEmoji != null &&
                            viewer.reactionEmoji!.isNotEmpty)
                            ? Text(
                          viewer.reactionEmoji!,
                          style: TextStyle(fontSize: 20.sp),
                        )
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ).whenComplete(onCloseViewers);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showViewersBottomSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  reausabletext(
                    '${status.viewsCount} Views',
                    fontsize: 12.sp,
                    color: Colors.white,
                    fontfamily: FontFamily.interMedium,
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

class StatusOtherFooter extends StatelessWidget {
  final StatusViewController controller;

  const StatusOtherFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: controller.allowedReactions.map((emoji) {
                  final isSelected = controller.selectedReaction.value == emoji;
                  return GestureDetector(
                    onTap: () => controller.reactWithEmoji(emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6B4DFF)
                            : Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: controller.replyController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontFamily: FontFamily.interMedium,
                    ),
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Reply to status...',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                        fontSize: 13.sp,
                        fontFamily: FontFamily.interMedium,
                      ),
                    ),
                    onTap: controller.pause,
                    onSubmitted: (_) => controller.sendReply(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Obx(() {
                final hasText = controller.hasText.value;
                final isLiked = controller.isLiked.value;

                return GestureDetector(
                  onTap: () {
                    if (hasText) {
                      controller.sendReply();
                    } else {
                      controller.toggleLike();
                    }
                  },
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: hasText
                          ? const Color(0xFF6B4DFF)
                          : Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: hasText
                          ? null
                          : Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      hasText
                          ? Icons.send_rounded
                          : (isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded),
                      color: hasText
                          ? Colors.white
                          : (isLiked ? Colors.redAccent : Colors.white),
                      size: hasText ? 20.sp : 22.sp,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}