import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double width = 210,
}) async {
  HapticFeedback.mediumImpact();

  final mediaQuery = MediaQuery.of(context);
  final screenSize = mediaQuery.size;
  final menuWidth = width.w;

  const horizontalMargin = 12.0;
  const verticalMargin = 12.0;
  final menuHeight = items.length * 48.0.h + 16.h;

  final minSafeTop = mediaQuery.padding.top + kToolbarHeight + 12.h;
  final maxSafeTop = (screenSize.height - menuHeight - mediaQuery.padding.bottom - 16.h)
      .clamp(minSafeTop, screenSize.height);

  final maxLeft = screenSize.width - menuWidth - horizontalMargin;
  double left = position.dx == 0 ? (screenSize.width - menuWidth) / 2 : position.dx;
  left = left.clamp(horizontalMargin, maxLeft < horizontalMargin ? horizontalMargin : maxLeft);

  double top;
  if (position == Offset.zero || position.dy < minSafeTop) {
    top = minSafeTop;
  } else if (position.dy + menuHeight <= screenSize.height - mediaQuery.padding.bottom - 16.h) {
    top = position.dy;
  } else {
    top = position.dy - menuHeight;
  }

  top = top.clamp(minSafeTop, maxSafeTop);

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "DropdownMenu",
    barrierColor: Colors.black.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(ctx).pop(),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                alignment: position.dx > screenSize.width / 2
                    ? Alignment.topRight
                    : Alignment.topLeft,
                child: FadeTransition(
                  opacity: animation,
                  child: Container(
                    width: menuWidth,
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height - minSafeTop - mediaQuery.padding.bottom - 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 24,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                        width: 0.8,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
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
        item.isDestructive ? const Color(0xFFE53935) : const Color(0xFF5045B9);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
            Icon(item.icon, color: color, size: 19.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: item.isDestructive ? const Color(0xFFE53935) : Colors.black87,
                  fontFamily: FontFamily.interSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}