import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Incoming-style chat bubble with three animated dots, shown while the
/// other person (private chat) or a group member is typing.
///
/// [label] is shown above the bubble, e.g. "Rahul is typing" in a group.
class TypingIndicatorBubble extends StatelessWidget {
  final String? label;

  const TypingIndicatorBubble({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final text = label?.trim() ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 2.h, 12.w, 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 3.h),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF5045B9),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const TypingDots(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placed between the message list and the input. Slides/fades the
/// [TypingIndicatorBubble] in and out as [visible] changes.
class TypingIndicatorSlot extends StatelessWidget {
  final bool visible;
  final String? label;
  final Color? background;

  const TypingIndicatorSlot({
    super.key,
    required this.visible,
    this.label,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: 1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: visible
          ? Container(
              key: const ValueKey('typing-visible'),
              width: double.infinity,
              color: background,
              child: TypingIndicatorBubble(label: label),
            )
          : const SizedBox(key: ValueKey('typing-hidden'), width: double.infinity),
    );
  }
}

/// Three dots that bounce and fade one after another.
class TypingDots extends StatefulWidget {
  final Color color;
  final double dotSize;

  const TypingDots({
    super.key,
    this.color = const Color(0xFF8E88C8),
    this.dotSize = 8,
  });

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.dotSize.w;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot is a third of a cycle behind the previous one; it
            // rises during the first half of its own phase and rests after.
            final phase = (_controller.value - i * 0.18) % 1.0;
            final wave = phase < 0.5 ? math.sin(phase * 2 * math.pi) : 0.0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w),
              child: Transform.translate(
                offset: Offset(0, -4.h * wave),
                child: Opacity(
                  opacity: 0.4 + 0.6 * wave,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
