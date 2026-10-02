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

  const StatusViewScreen({
    super.key,
    this.isOwnStatus = true,
    this.userName = 'My Status',
    this.userAvatar,
    required this.statuses,
    this.currentIndex = 0,
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final current = controller.currentStatus;
        if (current == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final w = MediaQuery.of(context).size.width;
                if (d.localPosition.dx < w * 0.3) {
                  controller.goPrev();
                } else if (d.localPosition.dx > w * 0.7) {
                  controller.goNext();
                }
              },
              onLongPressStart: (_) => controller.pause(),
              onLongPressEnd: (_) => controller.resume(),
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
                    userName: widget.userName,
                    userAvatar: widget.userAvatar,
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
      }),
    );
  }
}