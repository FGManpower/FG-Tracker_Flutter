// lib/app/modules/Messages/widgets/PinnedMessageBanner.dart

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
      onLongPress: () => _showUnpinSheet(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: 0.7,
                child: Icon(
                  Icons.push_pin,
                  color: const Color(0xFF25D366),
                  size: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),

            Container(
              width: 3.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 10.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pinnedMessage.senderName ?? "Pinned Message",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF25D366),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _getPreviewText(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Close
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnpinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: 0.7,
                child: Icon(Icons.push_pin_outlined,
                    color: Colors.red, size: 28.sp),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Unpin Message?",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            SizedBox(height: 6.h),
            Text(
              "This message will no longer be\npinned at the top",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onUnpin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r)),
                  elevation: 0,
                ),
                child: Text("Unpin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text("Cancel",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}