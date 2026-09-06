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

class CustomDropdownMenu {
  static Future<void> show({
    required BuildContext context,
    required Offset position,
    required List<DropdownMenuItemData> items,
    double width = 200,
  }) async {
    final overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
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
              left: position.dx.clamp(10, overlay.size.width - width - 10),
              top: position.dy,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width.w,
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
          ],
        );
      },
    );
  }
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