import 'dart:ui';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../routes/app_pages.dart';
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
            const ColoredBox(color: Colors.black),
            Center(
              child: AspectRatio(
                aspectRatio:
                vc.value.aspectRatio > 0 ? vc.value.aspectRatio : 9 / 16,
                child: VideoPlayer(vc),
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
      final bool isNetwork = imageUrl.startsWith('http');
      final ImageProvider provider = isNetwork
          ? NetworkImage(imageUrl)
          : AssetImage(imageUrl) as ImageProvider;

      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Opacity(
                opacity: 0.45,
                child: Image(
                  image: provider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: isNetwork
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B4DFF),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const PlaceholderBg(),
              )
                  : Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const PlaceholderBg(),
              ),
            ),
          ),
        ],
      );
    }

    return const PlaceholderBg();
  }
}

class StatusStaticPreviewBackground extends StatelessWidget {
  final StatusItemModel status;

  const StatusStaticPreviewBackground({
    super.key,
    required this.status,
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

    final previewUrl = status.type == 'video'
        ? status.thumbnailUrl
        : status.mediaUrl;

    if (previewUrl != null &&
        previewUrl.isNotEmpty &&
        !previewUrl.toLowerCase().endsWith('.mp4')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          Center(
            child: Image.network(
              previewUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => const PlaceholderBg(),
            ),
          ),
        ],
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
            onTap: controller.closeViewer,
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      margin: EdgeInsets.only(bottom: 8.h),
      color: Colors.black.withValues(alpha: 0.45),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (caption.isNotEmpty)
            Text(
              caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontFamily: FontFamily.interMedium,
                height: 1.35,
              ),
            ),
          if (location.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 13.sp,
                ),
                SizedBox(width: 4.w),
                reausabletext(
                  location,
                  fontsize: 11.sp,
                  color: Colors.white70,
                  fontfamily: FontFamily.interMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class StatusOwnFooter extends StatelessWidget {
  final StatusItemModel status;
  final StatusViewController controller;
  final VoidCallback onOpenViewers;
  final VoidCallback onCloseViewers;

  const StatusOwnFooter({
    super.key,
    required this.status,
    required this.controller,
    required this.onOpenViewers,
    required this.onCloseViewers,
  });

  Map<String, int> _reactionSummary(List<StatusViewerModel> viewers) {
    final map = <String, int>{};
    for (final v in viewers) {
      final emoji = v.reactionEmoji;
      if (emoji != null && emoji.trim().isNotEmpty) {
        map[emoji] = (map[emoji] ?? 0) + 1;
      }
    }
    return map;
  }

  String? _memberProfilePath(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    if (!url.startsWith('http')) return url;
    final marker = '/uploads/';
    final i = url.indexOf(marker);
    if (i != -1) return url.substring(i + 1);
    return url;
  }

  void _openChatWithViewer(StatusViewerModel viewer) {
    if (viewer.viewerId <= 0) return;

    final myId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';
    if (myId.isNotEmpty && myId == viewer.viewerId.toString()) return;

    final member = MemberData(
      id: viewer.viewerId,
      userId: viewer.viewerId,
      name: viewer.name,
      profileImage: _memberProfilePath(viewer.profileImage),
    );

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    controller.closeViewer();

    Future.delayed(const Duration(milliseconds: 280), () {
      Get.toNamed(
        Routes.chatScreen,
        arguments: {
          "userData": member,
          "type": "",
        },
      );
    });
  }

  void _showViewersBottomSheet() {
    onOpenViewers();
    controller.fetchCurrentStatusViewers();

    Get.bottomSheet(
      Obx(() {
        final current = controller.currentStatus ?? status;
        final myId =
            Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

        final visibleViewers = current.viewers
            .where((v) =>
        myId.isEmpty || v.viewerId.toString() != myId)
            .toList();

        final selfIncluded = myId.isNotEmpty &&
            current.viewers.any((v) => v.viewerId.toString() == myId);

        final displayCount = selfIncluded
            ? (current.viewsCount > 0
            ? current.viewsCount - 1
            : visibleViewers.length)
            : (current.viewsCount > 0
            ? current.viewsCount
            : visibleViewers.length);

        final reactions = _reactionSummary(visibleViewers);

        return Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.78,
            minHeight: Get.height * 0.32,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0B141A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 14.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded,
                          color: Colors.white70, size: 20.sp),
                      SizedBox(width: 8.w),
                      reausabletext(
                        'Viewed by $displayCount',
                        fontsize: 15.sp,
                        fontfamily: FontFamily.interBold,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (reactions.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: reactions.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (_, i) {
                        final emoji = reactions.keys.elementAt(i);
                        final count = reactions[emoji]!;
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2C34),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 6.w),
                              reausabletext(
                                '$count',
                                fontsize: 13.sp,
                                fontfamily: FontFamily.interMedium,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                Flexible(
                  child: visibleViewers.isEmpty
                      ? _buildEmptyState()
                      : _buildViewersList(visibleViewers),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      enterBottomSheetDuration: const Duration(milliseconds: 220),
      exitBottomSheetDuration: const Duration(milliseconds: 180),
    ).whenComplete(onCloseViewers);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_outlined,
              color: Colors.white24, size: 48.sp),
          SizedBox(height: 12.h),
          reausabletext(
            'No views yet',
            fontsize: 13.sp,
            fontfamily: FontFamily.interMedium,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _buildViewersList(List<StatusViewerModel> viewers) {
    final myId =
        Global.storageServices.get(PrefConst.userId)?.toString() ?? '';

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 6.h, bottom: 16.h),
      itemCount: viewers.length,
      itemBuilder: (_, index) {
        final viewer = viewers[index];
        final hasReaction = viewer.reactionEmoji != null &&
            viewer.reactionEmoji!.trim().isNotEmpty;
        final isMe = myId.isNotEmpty &&
            myId == viewer.viewerId.toString();

        String timeText = '';
        if (viewer.viewedAt != null) {
          final now = DateTime.now();
          final diff = now.difference(viewer.viewedAt!.toLocal());
          if (diff.inMinutes < 1) {
            timeText = 'Just now';
          } else if (diff.inMinutes < 60) {
            timeText = '${diff.inMinutes}m ago';
          } else {
            final dt = viewer.viewedAt!.toLocal();
            final hour =
            dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
            final minute = dt.minute.toString().padLeft(2, '0');
            final period = dt.hour >= 12 ? 'PM' : 'AM';
            timeText = '$hour:$minute $period';
          }
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isMe ? null : () => _openChatWithViewer(viewer),
            splashColor: Colors.white.withValues(alpha: 0.05),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: const Color(0xFF1F2C34),
                    backgroundImage: (viewer.profileImage != null &&
                        viewer.profileImage!.isNotEmpty)
                        ? NetworkImage(viewer.profileImage!)
                        : null,
                    child: (viewer.profileImage == null ||
                        viewer.profileImage!.isEmpty)
                        ? Icon(Icons.person_rounded,
                        color: Colors.white54, size: 22.sp)
                        : null,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reausabletext(
                          viewer.name,
                          fontsize: 14.sp,
                          fontfamily: FontFamily.interMedium,
                          color: Colors.white,
                        ),
                        if (timeText.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          reausabletext(
                            timeText,
                            fontsize: 11.sp,
                            color: Colors.white38,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasReaction) ...[
                    Text(
                      viewer.reactionEmoji!,
                      style: TextStyle(fontSize: 22.sp),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  if (!isMe)
                    GestureDetector(
                      onTap: () => _openChatWithViewer(viewer),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2C34),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white70,
                          size: 18.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                  Icon(Icons.visibility_rounded,
                      color: Colors.white, size: 16.sp),
                  SizedBox(width: 6.w),
                  Obx(() {
                    final current = controller.currentStatus ?? status;
                    final myId = Global.storageServices
                        .get(PrefConst.userId)
                        ?.toString() ??
                        '';
                    final selfIncluded = myId.isNotEmpty &&
                        current.viewers
                            .any((v) => v.viewerId.toString() == myId);
                    final visibleLen = current.viewers
                        .where((v) =>
                    myId.isEmpty ||
                        v.viewerId.toString() != myId)
                        .length;
                    final count = selfIncluded
                        ? (current.viewsCount > 0
                        ? current.viewsCount - 1
                        : visibleLen)
                        : (current.viewsCount > 0
                        ? current.viewsCount
                        : visibleLen);
                    return reausabletext(
                      '$count Views',
                      fontsize: 12.sp,
                      color: Colors.white,
                      fontfamily: FontFamily.interMedium,
                    );
                  }),
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