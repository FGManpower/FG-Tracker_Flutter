import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/status_view_controller.dart';
import '../widget/statuswidget.dart';

class StatusViewScreen extends StatelessWidget {
  final bool isOwnStatus;
  final String userName;
  final String timeText;
  final String caption;
  final String location;
  final String? imageUrl;
  final int viewsCount;
  final int totalStatuses;
  final int currentIndex;

  const StatusViewScreen({
    super.key,
    this.isOwnStatus = true,
    this.userName = "My Status",
    this.timeText = "Today, 9:30 AM",
    this.caption = "New Day\nStronger Team 💪",
    this.location = "Hyderabad",
    this.imageUrl,
    this.viewsCount = 24,
    this.totalStatuses = 5,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final StatusViewController controller = Get.put(
      StatusViewController(
        totalStatuses: totalStatuses,
        initialIndex: currentIndex,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
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
            child: StatusBackground(imageUrl: imageUrl),
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
                  isOwnStatus: isOwnStatus,
                  userName: userName,
                  timeText: timeText,
                ),
                const Spacer(),
                StatusCaptionArea(caption: caption, location: location),
                if (isOwnStatus)
                  StatusOwnFooter(viewsCount: viewsCount)
                else
                  StatusOtherFooter(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}