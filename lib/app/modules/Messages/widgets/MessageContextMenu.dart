import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class MessageContextMenuAction {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final bool isDestructive;
  final VoidCallback onTap;

  MessageContextMenuAction({
    required this.icon,
    required this.title,
    this.iconColor,
    this.isDestructive = false,
    required this.onTap,
  });
}

class MessageContextMenu {
  static const Color _purple = Color(0xFF5045B9);
  static const List<String> quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  static Future<void> show({
    required BuildContext context,
    required BuildContext bubbleContext,
    required bool isSentByMe,
    required List<MessageContextMenuAction> actions,
    Widget? messageWidget,
    ValueChanged<String>? onReactionSelected,
    String? currentReaction,
  }) async {
    HapticFeedback.mediumImpact();

    final RenderBox? renderBox =
        bubbleContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final bubblePosition = renderBox.localToGlobal(Offset.zero);
    final bubbleSize = renderBox.size;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final viewPadding = mediaQuery.padding;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    const double menuWidth = 230.0;
    const double margin = 12.0;
    const double gap = 6.0;

    final double safeTop = viewPadding.top + 8.0;
    final double safeBottom =
        screenSize.height - viewPadding.bottom - keyboardHeight - 8.0;
    final double availableHeight = safeBottom - safeTop;

    final bool hasReactions = onReactionSelected != null;
    final double reactionHeight = hasReactions ? 44.0 : 0.0;
    final double reactionWidth = 250.0;
    final double menuHeight = (actions.length * 38.0) + 12.0;
    final double totalMenuAndReactionHeight =
        reactionHeight + (hasReactions ? gap : 0.0) + menuHeight + gap;

    // Detect if this is a tall message ("bada msg") as in iOS WhatsApp (Screenshot 1)
    final bool isBadaMsg =
        (bubbleSize.height + totalMenuAndReactionHeight > availableHeight) ||
        (bubbleSize.height > availableHeight * 0.45);

    final double bubbleCenterY = bubblePosition.dy + (bubbleSize.height / 2);
    final double screenCenterY = safeTop + (availableHeight / 2);
    final bool isLowerHalf = bubbleCenterY >= screenCenterY;

    double shiftedBubbleTop;
    double maxBubbleRenderHeight;
    double? reactionTop;
    double menuTop;

    if (isBadaMsg) {
      // Scenario B: Bada / Tall Message (WhatsApp iOS behavior - Screenshot 1)
      // Reactions pinned at top, Menu pinned at bottom, Message centered
      reactionTop = hasReactions ? (safeTop + 4.0) : null;
      menuTop = safeBottom - menuHeight - 4.0;

      shiftedBubbleTop = hasReactions
          ? (reactionTop! + reactionHeight + gap)
          : (safeTop + 4.0);

      maxBubbleRenderHeight = safeBottom - shiftedBubbleTop - 4.0;
    } else if (isLowerHalf) {
      // Scenario C: Bottom Message (WhatsApp behavior: Menu opens UPAR / above bubble)
      // Order from top: Menu -> Reactions -> Message Bubble
      shiftedBubbleTop = bubblePosition.dy;
      maxBubbleRenderHeight = bubbleSize.height;

      final double reactionBottom = shiftedBubbleTop - gap;
      reactionTop = hasReactions ? (reactionBottom - reactionHeight) : null;
      final double menuBottom = (hasReactions ? reactionTop! : shiftedBubbleTop) - gap;
      menuTop = menuBottom - menuHeight;

      // If menu extends above safeTop, nudge bubble slightly down
      if (menuTop < safeTop) {
        final double underflow = safeTop - menuTop;
        shiftedBubbleTop += underflow;
        if (hasReactions) {
          reactionTop = reactionTop! + underflow;
        }
        menuTop = safeTop;
      }
    } else {
      // Scenario A: Top / Middle Message (WhatsApp behavior: Menu opens NEECHE / below bubble)
      // Order from top: Reactions -> Message Bubble -> Menu
      double initialReactionTop = bubblePosition.dy - reactionHeight - gap;
      double initialMenuBottom =
          bubblePosition.dy + bubbleSize.height + gap + menuHeight;

      double shiftY = 0.0;
      if (hasReactions && initialReactionTop < safeTop) {
        shiftY = safeTop - initialReactionTop;
      } else if (initialMenuBottom > safeBottom) {
        shiftY = safeBottom - initialMenuBottom;
      }

      shiftedBubbleTop = bubblePosition.dy + shiftY;
      maxBubbleRenderHeight = bubbleSize.height;

      if (hasReactions) {
        reactionTop = shiftedBubbleTop - reactionHeight - gap;
      }
      menuTop = shiftedBubbleTop + bubbleSize.height + gap;

      if (menuTop + menuHeight > safeBottom) {
        menuTop = safeBottom - menuHeight;
      }
      if (hasReactions && reactionTop! < safeTop) {
        reactionTop = safeTop;
      }
    }

    // Horizontal positioning (align to message edge)
    double reactionLeft;
    double menuLeft;

    if (isSentByMe) {
      reactionLeft = bubblePosition.dx + bubbleSize.width - reactionWidth;
      menuLeft = bubblePosition.dx + bubbleSize.width - menuWidth;
    } else {
      reactionLeft = bubblePosition.dx;
      menuLeft = bubblePosition.dx;
    }

    reactionLeft =
        reactionLeft.clamp(margin, screenSize.width - reactionWidth - margin);
    menuLeft = menuLeft.clamp(margin, screenSize.width - menuWidth - margin);

    bool isActionExecuting = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "MessageContextMenu",
      barrierColor: Colors.black.withValues(alpha: 0.40),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final double animBubbleTop = Tween<double>(
              begin: bubblePosition.dy,
              end: shiftedBubbleTop,
            ).evaluate(curvedAnimation);

            return Stack(
              children: [
                // Backdrop tap to dismiss
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox.expand(),
                  ),
                ),

                // Highlighted unblurred Message Bubble (glides smoothly if shifted)
                if (messageWidget != null)
                  Positioned(
                    left: bubblePosition.dx,
                    top: animBubbleTop,
                    width: bubbleSize.width,
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Material(
                        color: Colors.transparent,
                        child: AbsorbPointer(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxBubbleRenderHeight,
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: messageWidget,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Emoji Reaction Bar
                if (hasReactions && reactionTop != null)
                  Positioned(
                    left: reactionLeft,
                    top: isBadaMsg
                        ? reactionTop
                        : (isLowerHalf
                            ? (animBubbleTop - gap - reactionHeight)
                            : (animBubbleTop - reactionHeight - gap)),
                    child: Material(
                      color: Colors.transparent,
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: FadeTransition(
                          opacity: animation,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.06),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: quickReactions.map((emoji) {
                                final isSelected = currentReaction == emoji;
                                return GestureDetector(
                                  onTap: () {
                                    if (isActionExecuting) return;
                                    isActionExecuting = true;
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(dialogContext).pop();
                                    onReactionSelected(emoji);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEDE7F6)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      emoji,
                                      style: TextStyle(fontSize: 21.sp),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Context Action Menu (All 8 items always visible, attached cleanly)
                Positioned(
                  left: menuLeft,
                  top: isBadaMsg
                      ? menuTop
                      : (isLowerHalf
                          ? (animBubbleTop - gap - reactionHeight - gap - menuHeight)
                          : (animBubbleTop + bubbleSize.height + gap)),
                  child: Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                      alignment: isSentByMe
                          ? (isLowerHalf ? Alignment.bottomRight : Alignment.topRight)
                          : (isLowerHalf ? Alignment.bottomLeft : Alignment.topLeft),
                      child: FadeTransition(
                        opacity: animation,
                        child: Container(
                          width: menuWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < actions.length; i++)
                                  _buildActionTile(
                                    dialogContext: dialogContext,
                                    action: actions[i],
                                    isLast: i == actions.length - 1,
                                    canExecute: () {
                                      if (isActionExecuting) return false;
                                      isActionExecuting = true;
                                      return true;
                                    },
                                  ),
                              ],
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
      },
    );
  }

  static Widget _buildActionTile({
    required BuildContext dialogContext,
    required MessageContextMenuAction action,
    required bool isLast,
    required bool Function() canExecute,
  }) {
    final Color itemColor = action.isDestructive
        ? const Color(0xFFE53935)
        : (action.iconColor ?? _purple);

    return InkWell(
      onTap: () {
        if (!canExecute()) return;
        HapticFeedback.lightImpact();
        Navigator.of(dialogContext).pop();
        action.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.5.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.10),
                    width: 0.7,
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              action.icon,
              size: 18.sp,
              color: itemColor,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                action.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: action.isDestructive
                      ? const Color(0xFFE53935)
                      : const Color(0xFF1F1F24),
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
