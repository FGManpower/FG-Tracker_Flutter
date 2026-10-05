import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DraggableVideoPip extends StatelessWidget {
  final CallingController controller;
  final Widget child;

  const DraggableVideoPip({
    super.key,
    required this.controller,
    required this.child,
  });

  double get pipWidth => 110.w;

  double get pipHeight => 150.h;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final double safeTop =
            MediaQuery.of(context).padding.top;

        final double minLeft = 8.w;
        final double maxLeft =
            screenWidth - pipWidth - 8.w;

        final double minTop = safeTop + 12.h;

        // Keep the floating video above the bottom controls.
        final double maxTop =
            screenHeight - pipHeight - 145.h;

        final double boundedMaxLeft =
        maxLeft < minLeft ? minLeft : maxLeft;

        final double boundedMaxTop =
        maxTop < minTop ? minTop : maxTop;

        final Offset currentPosition =
            controller.pipPosition ??
                Offset(
                  20.w,
                  boundedMaxTop,
                );

        final Offset safePosition = Offset(
          currentPosition.dx.clamp(
            minLeft,
            boundedMaxLeft,
          ),
          currentPosition.dy.clamp(
            minTop,
            boundedMaxTop,
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: safePosition.dx,
              top: safePosition.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  controller.updatePipPosition(
                    delta: details.delta,
                    pipWidth: pipWidth,
                    pipHeight: pipHeight,
                    minLeft: minLeft,
                    maxLeft: boundedMaxLeft,
                    minTop: minTop,
                    maxTop: boundedMaxTop,
                  );
                },
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}