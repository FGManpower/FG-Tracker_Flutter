import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class DropdownMenuItemData {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  DropdownMenuItemData({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });
}


Future<void> show({
  required BuildContext context,
  required Offset position,
  required List<DropdownMenuItemData> items,
  double width = 200,
}) async {
  final overlay = Overlay.of(context)
      .context
      .findRenderObject() as RenderBox;

  final screenSize = overlay.size;
  final menuWidth = width.w;

  const horizontalMargin = 10.0;
  const verticalMargin = 10.0;

  final menuHeight = items.fold<double>(
    0,
        (height, item) {
      final textStyle = TextStyle(
        fontSize: 12.sp,
        fontFamily: FontFamily.interSemiBold,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: item.title, style: textStyle),
        textDirection: Directionality.of(context),
        maxLines: 2,
      )..layout(maxWidth: menuWidth - 60.w);

      return height +
          (textPainter.height > 18.sp
              ? textPainter.height
              : 18.sp) +
          24.h +
          (height == 0 ? 0 : 0);
    },
  ) +
      (items.isNotEmpty ? (items.length - 1) * 0.8 : 0);

  final maxLeft = screenSize.width - menuWidth - horizontalMargin;

  final left = position.dx
      .clamp(horizontalMargin, maxLeft < horizontalMargin
      ? horizontalMargin
      : maxLeft)
      .toDouble();

  final availableBelow =
      screenSize.height - position.dy - verticalMargin;

  final openAbove = availableBelow < menuHeight &&
      position.dy > menuHeight + verticalMargin;

  final estimatedMenuHeight = menuHeight.clamp(
    0.0,
    screenSize.height - (verticalMargin * 2),
  );

  final double top;

  if (availableBelow >= estimatedMenuHeight) {
    top = position.dy;
  } else {
    top = (position.dy - estimatedMenuHeight)
        .clamp(
      verticalMargin,
      screenSize.height - estimatedMenuHeight - verticalMargin,
    )
        .toDouble();
  }

  await showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (ctx) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ),
          Positioned(
            left: left,
            top: top.clamp(
              verticalMargin,
              screenSize.height - verticalMargin,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: menuWidth,
                constraints: BoxConstraints(
                  maxHeight: screenSize.height -
                      verticalMargin * 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(items.length, (i) {
                      final item = items[i];

                      return _DropdownItem(
                        item: item,
                        isLast: i == items.length - 1,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          item.onTap?.call();
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _DropdownItem extends StatelessWidget {
  final DropdownMenuItemData item;
  final bool isLast;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    item.isDestructive ? Colors.red : const Color(0xFF6B4DFF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: color, size: 18.sp),
            SizedBox(width: 12.w),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12.sp,
                color: item.isDestructive ? Colors.red : Colors.black87,
                fontFamily: FontFamily.interSemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}