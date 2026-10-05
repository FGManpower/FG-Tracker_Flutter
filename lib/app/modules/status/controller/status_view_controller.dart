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
  final List<ContactStatusGroupModel> allContactGroups;
  final RxInt currentGroupIndex;
  final RxString activeUserName;
  final RxnString activeUserAvatar;

  StatusViewController({
    required this.isOwnStatus,
    required List<StatusItemModel> initialStatuses,
    this.initialIndex = 0,
    this.allContactGroups = const [],
    int initialGroupIndex = 0,
    String initialUserName = 'My Status',
    String? initialUserAvatar,
  })  : statuses = initialStatuses.obs,
        currentGroupIndex = initialGroupIndex.obs,
        activeUserName = initialUserName.obs,
        activeUserAvatar = RxnString(initialUserAvatar);

  late final PageController userPageController;
  late final AnimationController progressController;
  final TextEditingController replyController = TextEditingController();
  final LayerLink menuLink = LayerLink();
  OverlayEntry? _menuOverlay;

  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoBuffering = false.obs;
  final RxBool hasVideoError = false.obs;
  final RxDouble currentPageValue = 0.0.obs;

  bool _isPausedByUser = false;
  bool _isClosing = false;
  bool _isTransitioning = false;
  bool _isProgrammaticPageChange = false;
  bool _startTargetPageFromLast = false;

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

  int get totalGroups =>
      (!isOwnStatus && allContactGroups.isNotEmpty) ? allContactGroups.length : 1;

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
    final safeGroupIndex = (!isOwnStatus && allContactGroups.isNotEmpty)
        ? currentGroupIndex.value.clamp(0, allContactGroups.length - 1)
        : 0;
    currentGroupIndex.value = safeGroupIndex;
    currentPageValue.value = safeGroupIndex.toDouble();

    userPageController = PageController(initialPage: safeGroupIndex)
      ..addListener(_onPageScroll);

    if (!isOwnStatus &&
        allContactGroups.isNotEmpty &&
        safeGroupIndex < allContactGroups.length) {
      final grp = allContactGroups[safeGroupIndex];
      statuses.assignAll(grp.statuses);
      activeUserName.value = grp.user.name;
      activeUserAvatar.value = grp.user.profilePic;
    }

    currentIndex.value = initialIndex.clamp(
      0,
      statuses.isEmpty ? 0 : statuses.length - 1,
    );

    progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: currentStatus?.durationSeconds ?? 5),
    )..addStatusListener(_onProgressStatusChanged);

    replyController.addListener(() {
      hasText.value = replyController.text.trim().isNotEmpty;
    });
  }

  void _onPageScroll() {
    if (!userPageController.hasClients) return;
    final page = userPageController.page ?? currentGroupIndex.value.toDouble();
    currentPageValue.value = page;

    final isDragging = (page - page.roundToDouble()).abs() > 0.01;
    if (isDragging && progressController.isAnimating) {
      progressController.stop();
      videoController?.pause();
    } else if (!isDragging &&
        !_isPausedByUser &&
        !_isTransitioning &&
        !_isClosing &&
        _menuOverlay == null) {
      if (videoController != null && videoController!.value.isInitialized) {
        if (!videoController!.value.isPlaying) {
          videoController!.play();
        }
      } else if (!progressController.isAnimating &&
          progressController.value < 1.0) {
        progressController.forward();
      }
    }
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (_isClosing || _isTransitioning) return;
    if (status == AnimationStatus.completed) {
      goNext();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _loadCurrentStatus();
  }

  void closeViewer() {
    if (_isClosing) return;
    _isClosing = true;
    _removeMenu();
    progressController.removeStatusListener(_onProgressStatusChanged);
    progressController.stop();
    videoController?.removeListener(_onVideoListener);
    videoController?.pause();

    Get.closeAllSnackbars();
    Get.back();
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
    if (_isClosing || _isTransitioning) return;
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

    final totalMs = vc.value.duration.inMilliseconds;
    final posMs = vc.value.position.inMilliseconds;
    if (totalMs > 0) {
      final ratio = (posMs / totalMs).clamp(0.0, 0.999);
      progressController.value = ratio;
      if (posMs >= totalMs) {
        goNext();
      }
    }
  }

  Future<void> _loadCurrentStatus() async {
    if (_isClosing) return;
    _isTransitioning = true;
    progressController.stop();
    progressController.reset();
    _isPausedByUser = false;

    await _disposeVideo();
    if (_isClosing) return;

    final item = currentStatus;
    if (item == null) {
      _isTransitioning = false;
      closeViewer();
      return;
    }

    selectedReaction.value = item.myReaction ?? '';
    isLiked.value = item.myReaction == '❤️';

    if (!isOwnStatus && item.id > 0) {
      _recordView(statusId: item.id);
    } else if (isOwnStatus) {
      fetchCurrentStatusViewers();
    }

    if (isVideoStatus(item) &&
        item.mediaUrl != null &&
        item.mediaUrl!.isNotEmpty) {
      try {
        final vc = VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl!));
        videoController = vc;
        await vc.initialize();

        if (_isClosing || currentStatus?.id != item.id) {
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
        _isTransitioning = false;

        if (!_isPausedByUser && _menuOverlay == null && !_isClosing) {
          await vc.play();
        }
      } catch (_) {
        if (_isClosing) return;
        hasVideoError.value = true;
        progressController.duration = Duration(
          seconds: item.durationSeconds > 0 ? item.durationSeconds : 5,
        );
        _isTransitioning = false;
        progressController.forward();
      }
    } else {
      progressController.duration = Duration(
        seconds: item.durationSeconds > 0 ? item.durationSeconds : 5,
      );
      _isTransitioning = false;
      progressController.forward();
    }
  }

  Future<void> fetchCurrentStatusViewers() async {
    if (!isOwnStatus) return;
    try {
      final res = await StatusRepo.getMyStatus();
      if (res.status && res.data.isNotEmpty) {
        final activeId = currentStatus?.id;
        if (activeId != null) {
          final updated = res.data.firstWhereOrNull((s) => s.id == activeId);
          if (updated != null) {
            final idx = currentIndex.value;
            if (idx >= 0 && idx < statuses.length) {
              statuses[idx] = updated;
            }
          }
        }
      }
    } catch (_) {}
  }

  void pause() {
    if (_isClosing) return;
    _isPausedByUser = true;
    if (progressController.isAnimating) {
      progressController.stop();
    }
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.pause();
    }
  }

  void resume() {
    if (_isClosing || _menuOverlay != null) return;
    _isPausedByUser = false;

    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.play();
      return;
    }
    if (!progressController.isAnimating && progressController.value < 1.0) {
      progressController.forward();
    }
  }

  void onUserPageChanged(int groupIndex) {
    if (_isClosing) return;
    _removeMenu();

    final startFromLast =
    _isProgrammaticPageChange ? _startTargetPageFromLast : false;
    _isProgrammaticPageChange = false;
    _startTargetPageFromLast = false;

    if (groupIndex < 0 || groupIndex >= allContactGroups.length) return;
    final nextGroup = allContactGroups[groupIndex];
    if (nextGroup.statuses.isEmpty) return;

    currentGroupIndex.value = groupIndex;
    activeUserName.value = nextGroup.user.name;
    activeUserAvatar.value = nextGroup.user.profilePic;
    statuses.assignAll(nextGroup.statuses);

    if (startFromLast) {
      currentIndex.value = nextGroup.statuses.length - 1;
    } else {
      final firstUnviewed =
      nextGroup.statuses.indexWhere((s) => !s.isViewed);
      currentIndex.value = firstUnviewed >= 0 ? firstUnviewed : 0;
    }

    replyController.clear();
    _loadCurrentStatus();
  }

  Future<void> _animateToGroupPage(
      int targetGroupIndex, {
        bool startFromLast = false,
      }) async {
    if (_isClosing) return;
    if (targetGroupIndex < 0 || targetGroupIndex >= allContactGroups.length) {
      closeViewer();
      return;
    }

    if (!userPageController.hasClients) {
      onUserPageChanged(targetGroupIndex);
      return;
    }

    _isProgrammaticPageChange = true;
    _startTargetPageFromLast = startFromLast;
    progressController.stop();
    videoController?.pause();

    await userPageController.animateToPage(
      targetGroupIndex,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void goNext() {
    if (_isClosing) return;
    _removeMenu();

    if (currentIndex.value < statuses.length - 1) {
      currentIndex.value++;
      _loadCurrentStatus();
      return;
    }

    if (!isOwnStatus &&
        allContactGroups.isNotEmpty &&
        currentGroupIndex.value < allContactGroups.length - 1) {
      int nextGroupIdx = currentGroupIndex.value + 1;
      while (nextGroupIdx < allContactGroups.length &&
          allContactGroups[nextGroupIdx].statuses.isEmpty) {
        nextGroupIdx++;
      }
      if (nextGroupIdx < allContactGroups.length) {
        _animateToGroupPage(nextGroupIdx, startFromLast: false);
        return;
      }
    }

    closeViewer();
  }

  void goPrev() {
    if (_isClosing) return;
    _removeMenu();

    if (currentIndex.value > 0) {
      currentIndex.value--;
      _loadCurrentStatus();
      return;
    }

    if (!isOwnStatus &&
        allContactGroups.isNotEmpty &&
        currentGroupIndex.value > 0) {
      int prevGroupIdx = currentGroupIndex.value - 1;
      while (prevGroupIdx >= 0 &&
          allContactGroups[prevGroupIdx].statuses.isEmpty) {
        prevGroupIdx--;
      }
      if (prevGroupIdx >= 0) {
        _animateToGroupPage(prevGroupIdx, startFromLast: true);
        return;
      }
    }

    _loadCurrentStatus();
  }

  void goNextUser() {
    if (_isClosing) return;
    _removeMenu();
    if (!isOwnStatus &&
        allContactGroups.isNotEmpty &&
        currentGroupIndex.value < allContactGroups.length - 1) {
      int nextGroupIdx = currentGroupIndex.value + 1;
      while (nextGroupIdx < allContactGroups.length &&
          allContactGroups[nextGroupIdx].statuses.isEmpty) {
        nextGroupIdx++;
      }
      if (nextGroupIdx < allContactGroups.length) {
        _animateToGroupPage(nextGroupIdx, startFromLast: false);
        return;
      }
    }
    closeViewer();
  }

  void goPrevUser() {
    if (_isClosing) return;
    _removeMenu();
    if (!isOwnStatus &&
        allContactGroups.isNotEmpty &&
        currentGroupIndex.value > 0) {
      int prevGroupIdx = currentGroupIndex.value - 1;
      while (prevGroupIdx >= 0 &&
          allContactGroups[prevGroupIdx].statuses.isEmpty) {
        prevGroupIdx--;
      }
      if (prevGroupIdx >= 0) {
        _animateToGroupPage(prevGroupIdx, startFromLast: false);
        return;
      }
    }
    _loadCurrentStatus();
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

    if (!isOwnStatus &&
        currentGroupIndex.value >= 0 &&
        currentGroupIndex.value < allContactGroups.length) {
      final grp = allContactGroups[currentGroupIndex.value];
      final idx = grp.statuses.indexWhere((s) => s.id == statusId);
      if (idx != -1) {
        grp.statuses[idx] = grp.statuses[idx].copyWith(
          isViewed: true,
          myReaction: reactionEmoji ?? grp.statuses[idx].myReaction,
        );
      }
    }

    if (Get.isRegistered<StatusFeedController>()) {
      Get.find<StatusFeedController>().markStatusViewedLocally(
        statusId,
        reactionEmoji: reactionEmoji,
      );
    }
  }

  Future<void> reactWithEmoji(String emoji) async {
    final item = currentStatus;
    if (item == null || item.id <= 0 || isSendingReply.value) return;

    isSendingReply.value = true;
    pause();

    selectedReaction.value = emoji;
    isLiked.value = emoji == '❤️';
    statuses[currentIndex.value] = item.copyWith(
      isViewed: true,
      myReaction: emoji,
    );

    _recordView(statusId: item.id, reactionEmoji: emoji);

    try {
      final res = await StatusRepo.replyStatus(
        item.id,
        comment: emoji,
        reactionEmoji: emoji,
      );

      if (res.status == true) {
        closeViewer();
      } else {
        resume();
      }
    } catch (_) {
      resume();
    } finally {
      isSendingReply.value = false;
    }
  }

  void toggleLike() {
    if (isLiked.value) {
      selectedReaction.value = '';
      isLiked.value = false;
      return;
    }
    reactWithEmoji('❤️');
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
        selectedReaction.value = '';
        FocusManager.instance.primaryFocus?.unfocus();
        closeViewer();
      } else {
        resume();
      }
    } catch (_) {
      resume();
    } finally {
      isSendingReply.value = false;
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
        closeViewer();
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
    _isClosing = true;
    _removeMenu();
    userPageController.removeListener(_onPageScroll);
    userPageController.dispose();
    progressController.removeStatusListener(_onProgressStatusChanged);
    _disposeVideo();
    progressController.dispose();
    replyController.dispose();
    super.onClose();
  }
}