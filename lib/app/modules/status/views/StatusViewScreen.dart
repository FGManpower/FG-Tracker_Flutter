import 'dart:math' as math;
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/status_view_controller.dart';
import '../widget/statuswidget.dart';

class StatusViewScreen extends StatefulWidget {
  final bool isOwnStatus;
  final String userName;
  final String? userAvatar;
  final List<StatusItemModel> statuses;
  final int currentIndex;
  final List<ContactStatusGroupModel> allContactGroups;
  final int initialGroupIndex;

  const StatusViewScreen({
    super.key,
    this.isOwnStatus = true,
    this.userName = 'My Status',
    this.userAvatar,
    required this.statuses,
    this.currentIndex = 0,
    this.allContactGroups = const [],
    this.initialGroupIndex = 0,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  late final StatusViewController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<StatusViewController>()) {
      Get.delete<StatusViewController>(force: true);
    }
    controller = Get.put(
      StatusViewController(
        isOwnStatus: widget.isOwnStatus,
        initialStatuses: widget.statuses,
        initialIndex: widget.currentIndex,
        allContactGroups: widget.allContactGroups,
        initialGroupIndex: widget.initialGroupIndex,
        initialUserName: widget.userName,
        initialUserAvatar: widget.userAvatar,
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<StatusViewController>()) {
      Get.delete<StatusViewController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMultipleUsers =
        !widget.isOwnStatus && widget.allContactGroups.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: hasMultipleUsers
          ? PageView.builder(
        controller: controller.userPageController,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.totalGroups,
        onPageChanged: controller.onUserPageChanged,
        itemBuilder: (context, pageIndex) {
          return Obx(() {
            final double page = controller.currentPageValue.value;
            final double delta = pageIndex - page;
            final bool isCurrentPage =
                pageIndex == controller.currentGroupIndex.value;

            final Matrix4 transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(delta * -math.pi / 4.2);

            return Transform(
              alignment: delta <= 0
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              transform: transform,
              child: isCurrentPage
                  ? _buildActiveStoryPage(context)
                  : _buildPreviewUserPage(pageIndex),
            );
          });
        },
      )
          : _buildActiveStoryPage(context),
    );
  }

  Widget _buildActiveStoryPage(BuildContext context) {
    return Obx(() {
      final current = controller.currentStatus;
      if (current == null) {
        return const SizedBox.shrink();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final w = MediaQuery.of(context).size.width;
              if (d.localPosition.dx < w * 0.3) {
                controller.goPrev();
              } else {
                controller.goNext();
              }
            },
            onLongPressStart: (_) => controller.pause(),
            onLongPressEnd: (_) => controller.resume(),
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 400) {
                controller.closeViewer();
              }
            },
            child: StatusBackground(
              status: current,
              controller: controller,
            ),
          ),
          const StatusGradientOverlays(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 6.h),
                StatusProgressBars(controller: controller),
                SizedBox(height: 10.h),
                StatusTopBar(
                  controller: controller,
                  isOwnStatus: widget.isOwnStatus,
                  userName: controller.activeUserName.value,
                  userAvatar: controller.activeUserAvatar.value,
                  timeText: current.formattedTime,
                ),
                const Spacer(),
                if (current.type != 'text')
                  StatusCaptionArea(
                    caption: current.content,
                    location: '',
                  ),
                if (widget.isOwnStatus)
                  StatusOwnFooter(
                    status: current,
                    onOpenViewers: controller.pause,
                    onCloseViewers: controller.resume,
                  )
                else
                  StatusOtherFooter(controller: controller),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPreviewUserPage(int groupIndex) {
    final group = widget.allContactGroups[groupIndex];
    final firstUnviewed = group.statuses.indexWhere((s) => !s.isViewed);
    final previewStatus = group.statuses.isEmpty
        ? null
        : group.statuses[firstUnviewed >= 0 ? firstUnviewed : 0];

    return Stack(
      fit: StackFit.expand,
      children: [
        if (previewStatus != null)
          StatusStaticPreviewBackground(status: previewStatus)
        else
          const PlaceholderBg(),
        const StatusGradientOverlays(),
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: List.generate(group.statuses.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: group.statuses[i].isViewed ? 1.0 : 0.0,
                            minHeight: 2.5.h,
                            backgroundColor:
                            Colors.white.withValues(alpha: 0.35),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 10.h),
              StatusTopBar(
                controller: controller,
                isOwnStatus: false,
                userName: group.user.name,
                userAvatar: group.user.profilePic,
                timeText: previewStatus?.formattedTime ?? '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}