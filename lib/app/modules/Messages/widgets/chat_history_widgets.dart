import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small spinner pinned to the top of the message list while an older page
/// is loading.
class ChatHistoryTopLoader extends StatelessWidget {
  final bool visible;

  const ChatHistoryTopLoader({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    // Not built at all when hidden: an invisible spinner would keep
    // animating (and repainting) for the whole life of the chat.
    if (!visible) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            key: const ValueKey('chat_history_top_loader'),
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF5045B9),
              ),
            ),
          ),
      ),
    );
  }
}

/// Small bar over cached messages when the API refresh failed or timed out
/// ("Couldn't refresh · Retry"). The cached messages stay on screen.
class ChatRefreshFailedBar extends StatelessWidget {
  final bool visible;
  final VoidCallback onRetry;

  const ChatRefreshFailedBar({
    super.key,
    required this.visible,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        key: const ValueKey('chat_refresh_failed_bar'),
        color: const Color(0xFF3C3C43),
        borderRadius: BorderRadius.circular(18.r),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onRetry,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 15.sp, color: Colors.white70),
                SizedBox(width: 6.w),
                Text(
                  '${context.l10n.chat_refreshFailed} · ${context.l10n.common_retry}',
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of "No messages here yet" when the history could not be
/// loaded, so a network/API failure is never mistaken for an empty chat.
class ChatHistoryErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ChatHistoryErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44.sp, color: Colors.grey.shade500),
            SizedBox(height: 12.h),
            Text(
              context.l10n.chat_loadFailedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              context.l10n.chat_loadFailedSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              key: const ValueKey('chat_history_retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}
