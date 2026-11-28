import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

/// Replaces the last-message preview while someone types in that chat.
/// Never affects list order (it only swaps the subtitle text).
class ChatTypingText extends StatelessWidget {
  const ChatTypingText({super.key, required this.label});

  /// "typing..." or "Rahul is typing..." / "Rahul, Priya are typing...".
  final String label;

  static const Color color = Color(0xFF16A765);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      key: const ValueKey('chat_typing_text'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.sp,
        fontStyle: FontStyle.italic,
        color: color,
        fontFamily: FontFamily.interMedium,
      ),
    );
  }
}

/// Title + subtitle of the "Archived (n)" entry at the top of the chat list.
class ArchivedEntryLabels extends StatelessWidget {
  const ArchivedEntryLabels({
    super.key,
    required this.archivedCount,
    required this.unreadCount,
  });

  final int archivedCount;

  /// Unread messages inside archived chats (excluded from main totals).
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Archived ($archivedCount)',
                key: const ValueKey('archived_entry_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interBold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                unreadCount > 0
                    ? '$unreadCount unread message${unreadCount == 1 ? '' : 's'}'
                    : 'View archived conversations',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (unreadCount > 0)
          Container(
            key: const ValueKey('archived_entry_badge'),
            constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            margin: EdgeInsets.only(right: 6.w),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4DFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            alignment: Alignment.center,
            child: Text(
              unreadCount > 99 ? '99+' : '$unreadCount',
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontFamily: FontFamily.interSemiBold,
              ),
            ),
          ),
      ],
    );
  }
}
