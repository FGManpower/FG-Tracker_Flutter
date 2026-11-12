import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/l10n/l10n.dart';

/// Stable value the models use for a forwarded last message (logic id;
/// translated only when shown, see [chatListForwardedLabel]).
const String kForwardedLabel = 'Forwarded';

/// Fallback chat names the models store when the server sends none.
const String kUnknownUserName = 'Unknown User';
const String kGroupFallbackName = 'Group';

/// "Forwarded" label in the app language. A custom label from the server is
/// shown as it comes.
String chatListForwardedLabel(String? label) {
  final l = label?.trim() ?? '';
  if (l.isEmpty || l.toLowerCase() == kForwardedLabel.toLowerCase()) {
    return appL10n.chatList_forwarded;
  }
  return l;
}

/// Chat name for display: the model fallbacks ("Unknown User" / "Group")
/// and an empty name show in the app language, real names as they come.
String chatListDisplayName(String? name) {
  final n = name?.trim() ?? '';
  if (n.isEmpty || n == kUnknownUserName) return appL10n.chatList_unknownUser;
  if (n == kGroupFallbackName) return appL10n.chatList_groupFallback;
  return name!;
}

/// Grey "Deactivated" chip next to a group name (backend v2.5.0): the
/// group was deactivated by its admin.
class DeactivatedGroupBadge extends StatelessWidget {
  const DeactivatedGroupBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        context.l10n.chatList_deactivated,
        maxLines: 1,
        style: TextStyle(
          fontSize: 8.5.sp,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          fontFamily: FontFamily.interMedium,
        ),
      ),
    );
  }
}

/// Replaces the input bar of a group deactivated by its admin.
class DeactivatedGroupBanner extends StatelessWidget {
  const DeactivatedGroupBanner({
    super.key,
    this.text,
  });

  /// Message shown instead of the input bar (default: deactivated by admin).
  final String? text;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        color: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 18.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text ?? context.l10n.chatList_groupDeactivatedBanner,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  fontFamily: FontFamily.interMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                context.l10n.chatList_archivedCount(archivedCount),
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
                    ? context.l10n.chatList_unreadMessages(unreadCount)
                    : context.l10n.chatList_viewArchived,
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
