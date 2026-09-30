import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PinnedMessageBanner extends StatelessWidget {
  final MessageData pinnedMessage;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final VoidCallback onUnpin;

  const PinnedMessageBanner({
    super.key,
    required this.pinnedMessage,
    required this.onTap,
    required this.onClose,
    required this.onUnpin,
  });

  static const Color _purple = Color(0xFF5045B9);

  String _getPreviewText() {
    switch (pinnedMessage.messageType ?? "text") {
      case "image":
        return "📷 Photo";
      case "video":
        return "🎥 Video";
      case "audio":
        return "🎤 Voice message";
      case "document":
        return "📄 Document";
      case "location":
        return "📍 Location";
      case "contact":
        return "👤 Contact";
      default:
        return pinnedMessage.content ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      onLongPress: () => _showPinnedPopup(context),

      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEBFB),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Transform.rotate(
              angle: 0.6,
              child: Icon(
                Icons.push_pin,
                color: _purple,
                size: 20.sp,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pinned Message",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _purple,
                      fontSize: 13.sp,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    _getPreviewText(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade500,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showPinnedPopup(BuildContext context) {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: position.dy + 44.h,
        right: 18.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 155.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                entry.remove();
                onUnpin();
              },
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Icon(
                        Icons.push_pin_outlined,
                        color: Colors.red,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    "Unpin Message",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }}