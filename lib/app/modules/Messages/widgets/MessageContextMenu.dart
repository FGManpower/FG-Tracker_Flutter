import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';

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

  static Future<void> show({
    required BuildContext context,
    required BuildContext bubbleContext,
    required bool isSentByMe,
    required List<MessageContextMenuAction> actions,
  }) async {
    HapticFeedback.mediumImpact();

    final RenderBox? renderBox =
        bubbleContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final bubblePosition = renderBox.localToGlobal(Offset.zero);
    final bubbleSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    final viewPadding = MediaQuery.of(context).padding;

    const double menuWidth = 224.0;
    const double margin = 12.0;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "MessageContextMenu",
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        // Horizontal position
        double left;
        if (isSentByMe) {
          left = bubblePosition.dx + bubbleSize.width - menuWidth;
        } else {
          left = bubblePosition.dx;
        }
        left = left.clamp(
          margin,
          screenSize.width - menuWidth - margin,
        );

        // Vertical space analysis
        final double spaceAbove = bubblePosition.dy - viewPadding.top;
        final double spaceBelow =
            screenSize.height - (bubblePosition.dy + bubbleSize.height) - viewPadding.bottom;

        final double estimatedMenuHeight = (actions.length * 44.0) + 16.0;
        final bool showMenuBelow = spaceBelow >= estimatedMenuHeight || spaceBelow > spaceAbove;

        double menuTop;
        if (showMenuBelow) {
          menuTop = (bubblePosition.dy + bubbleSize.height + 6.0).clamp(
            viewPadding.top + margin,
            screenSize.height - estimatedMenuHeight - viewPadding.bottom - margin,
          );
        } else {
          menuTop = (bubblePosition.dy - estimatedMenuHeight - 6.0).clamp(
            viewPadding.top + margin,
            screenSize.height - estimatedMenuHeight - viewPadding.bottom - margin,
          );
        }

        return Stack(
          children: [
            // Backdrop dismiss
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                behavior: HitTestBehavior.opaque,
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

            // Context Menu Items
            Positioned(
              left: left,
              top: menuTop,
              child: Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  alignment: isSentByMe
                      ? Alignment.topRight
                      : Alignment.topLeft,
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
                            blurRadius: 26,
                            spreadRadius: 1,
                            offset: const Offset(0, 8),
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
                            for (int i = 0; i < actions.length; i++) ...[
                              _buildActionTile(
                                dialogContext: dialogContext,
                                action: actions[i],
                                isLast: i == actions.length - 1,
                              ),
                            ],
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
  }

  static Widget _buildActionTile({
    required BuildContext dialogContext,
    required MessageContextMenuAction action,
    required bool isLast,
  }) {
    final Color itemColor = action.isDestructive
        ? const Color(0xFFE53935)
        : (action.iconColor ?? _purple);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(dialogContext).pop();
        action.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
              size: 19.sp,
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
