import 'package:fgtracker/app/Data/Repositories/status_repo.dart';
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class StatusViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final bool isOwnStatus;
  final RxList<StatusItemModel> statuses;
  final int initialIndex;

  StatusViewController({
    required this.isOwnStatus,
    required List<StatusItemModel> initialStatuses,
    this.initialIndex = 0,
  }) : statuses = initialStatuses.obs;

  late final AnimationController progressController;
  final TextEditingController replyController = TextEditingController();
  final LayerLink menuLink = LayerLink();
  OverlayEntry? _menuOverlay;

  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoBuffering = false.obs;
  final RxBool hasVideoError = false.obs;
  bool _isPausedByUser = false;

  final RxInt currentIndex = 0.obs;
  final RxBool hasText = false.obs;
  final RxBool isLiked = false.obs;
  final RxString selectedReaction = ''.obs;
  final RxBool isSendingReply = false.obs;

  final List<String> allowedReactions = const [
    '❤️',
    '😂',
    '🔥',
    '😮',
    '😢',
    '🙏',
  ];

  int get totalStatuses => statuses.length;

  StatusItemModel? get currentStatus =>
      statuses.isNotEmpty && currentIndex.value < statuses.length
          ? statuses[currentIndex.value]
          : null;

  bool isVideoStatus(StatusItemModel item) {
    final lowerType = item.type.toLowerCase();
    final lowerUrl = (item.mediaUrl ?? '').toLowerCase();
    return lowerType == 'video' ||
        lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.mkv') ||
        lowerUrl.endsWith('.webm');
  }

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex.clamp(
      0,
      statuses.isEmpty ? 0 : statuses.length - 1,
    );

    progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: currentStatus?.durationSeconds ?? 5),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        goNext();
      }
    });

    replyController.addListener(() {
      hasText.value = replyController.text.trim().isNotEmpty;
    });
  }

  @override
  void onReady() {
    super.onReady();
    _loadCurrentStatus();
  }

  Future<void> _disposeVideo() async {
    final oldController = videoController;
    videoController = null;
    isVideoInitialized.value = false;
    isVideoBuffering.value = false;
    hasVideoError.value = false;
    if (oldController != null) {
      oldController.removeListener(_onVideoListener);
      await oldController.pause();
      await oldController.dispose();
    }
  }

  void _onVideoListener() {
    final vc = videoController;
    if (vc == null || !vc.value.isInitialized) return;

    final buffering = vc.value.isBuffering;
    if (isVideoBuffering.value != buffering) {
      isVideoBuffering.value = buffering;
    }

    if (buffering) {
      if (progressController.isAnimating) {
        progressController.stop();
      }
      return;
    }

    if (!_isPausedByUser &&
        _menuOverlay == null &&
        !progressController.isAnimating &&
        progressController.value < 1.0) {
      progressController.forward();
    }

    final totalMs = vc.value.duration.inMilliseconds;
    final posMs = vc.value.position.inMilliseconds;
    if (totalMs > 0) {
      final ratio = (posMs / totalMs).clamp(0.0, 1.0);
      progressController.value = ratio;
      if (posMs >= totalMs && !vc.value.isPlaying) {
        goNext();
      }
    }
  }

  Future<void> _loadCurrentStatus() async {
    progressController.stop();
    progressController.reset();
    _isPausedByUser = false;

    await _disposeVideo();

    final item = currentStatus;
    if (item == null) return;

    selectedReaction.value = item.myReaction ?? '';
    isLiked.value = item.myReaction == '❤️';

    if (!isOwnStatus && item.id > 0) {
      _recordView(statusId: item.id);
    }

    if (isVideoStatus(item) &&
        item.mediaUrl != null &&
        item.mediaUrl!.isNotEmpty) {
      try {
        final vc = VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl!));
        videoController = vc;
        await vc.initialize();

        if (currentStatus?.id != item.id) {
          await vc.dispose();
          return;
        }

        final videoDuration = vc.value.duration;
        progressController.duration = videoDuration.inMilliseconds > 0
            ? videoDuration
            : Duration(
          seconds: item.durationSeconds > 0 ? item.durationSeconds : 15,
        );

        vc.addListener(_onVideoListener);
        isVideoInitialized.value = true;

        if (!_isPausedByUser && _menuOverlay == null) {
          await vc.play();
          progressController.forward();
        }
      } catch (_) {
        hasVideoError.value = true;
        progressController.duration = Duration(
          seconds: item.durationSeconds > 0 ? item.durationSeconds : 5,
        );
        progressController.forward();
      }
    } else {
      progressController.duration = Duration(
        seconds: item.durationSeconds > 0 ? item.durationSeconds : 5,
      );
      progressController.forward();
    }
  }

  void pause() {
    _isPausedByUser = true;
    if (progressController.isAnimating) {
      progressController.stop();
    }
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.pause();
    }
  }

  void resume() {
    if (_menuOverlay != null) return;
    _isPausedByUser = false;

    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.play();
    }
    if (!progressController.isAnimating && progressController.value < 1.0) {
      progressController.forward();
    }
  }

  void goNext() {
    _removeMenu();
    if (currentIndex.value < statuses.length - 1) {
      currentIndex.value++;
      _loadCurrentStatus();
    } else {
      Get.back();
    }
  }

  void goPrev() {
    _removeMenu();
    if (currentIndex.value > 0) {
      currentIndex.value--;
      _loadCurrentStatus();
    } else {
      _loadCurrentStatus();
    }
  }

  void _recordView({required int statusId, String? reactionEmoji}) {
    if (Get.isRegistered<StatusSocketService>()) {
      final socket = Get.find<StatusSocketService>();
      if (socket.isConnected.value) {
        socket.emitStatusView(
          statusId: statusId,
          reactionEmoji: reactionEmoji,
          onResult: (success, _) {
            if (!success) {
              StatusRepo.viewStatus(statusId, reactionEmoji: reactionEmoji);
            }
          },
        );
      } else {
        StatusRepo.viewStatus(statusId, reactionEmoji: reactionEmoji);
      }
    } else {
      StatusRepo.viewStatus(statusId, reactionEmoji: reactionEmoji);
    }

    if (Get.isRegistered<StatusFeedController>()) {
      Get.find<StatusFeedController>().markStatusViewedLocally(
        statusId,
        reactionEmoji: reactionEmoji,
      );
    }
  }

  void reactWithEmoji(String emoji) {
    final item = currentStatus;
    if (item == null) return;
    selectedReaction.value = emoji;
    isLiked.value = emoji == '❤️';
    statuses[currentIndex.value] = item.copyWith(
      isViewed: true,
      myReaction: emoji,
    );
    _recordView(statusId: item.id, reactionEmoji: emoji);
  }

  void toggleLike() {
    final nextReaction = isLiked.value ? '' : '❤️';
    if (nextReaction.isEmpty) {
      selectedReaction.value = '';
      isLiked.value = false;
      return;
    }
    reactWithEmoji(nextReaction);
  }

  Future<void> sendReply() async {
    final comment = replyController.text.trim();
    final item = currentStatus;
    if (comment.isEmpty || item == null || isSendingReply.value) return;

    pause();
    isSendingReply.value = true;
    try {
      final res = await StatusRepo.replyStatus(
        item.id,
        comment: comment,
        reactionEmoji: selectedReaction.value.isNotEmpty
            ? selectedReaction.value
            : null,
      );
      if (res.status == true) {
        replyController.clear();
        FocusManager.instance.primaryFocus?.unfocus();
        Get.snackbar(
          'Sent',
          res.message ?? "Status reply sent directly to creator's chat",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }
    } finally {
      isSendingReply.value = false;
      resume();
    }
  }

  Future<void> deleteCurrentStatus() async {
    _removeMenu();
    final item = currentStatus;
    if (item == null) return;

    pause();
    bool deleted = false;
    if (Get.isRegistered<StatusFeedController>()) {
      deleted = await Get.find<StatusFeedController>().deleteMyStatus(item.id);
    } else {
      final res = await StatusRepo.deleteStatus(item.id);
      deleted = res.status == true;
    }

    if (deleted) {
      statuses.removeAt(currentIndex.value);
      if (statuses.isEmpty) {
        Get.back();
        return;
      }
      if (currentIndex.value >= statuses.length) {
        currentIndex.value = statuses.length - 1;
      }
      _loadCurrentStatus();
    } else {
      resume();
    }
  }

  void showMenu(BuildContext context) {
    if (_menuOverlay != null) {
      _removeMenu();
      resume();
      return;
    }
    pause();

    _menuOverlay = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeMenu();
                  resume();
                },
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: menuLink,
              showWhenUnlinked: false,
              offset: Offset(-110.w, 36.h),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: deleteCurrentStatus,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13.sp,
                              fontFamily: FontFamily.interMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _removeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  @override
  void onClose() {
    _removeMenu();
    _disposeVideo();
    progressController.dispose();
    replyController.dispose();
    super.onClose();
  }
}