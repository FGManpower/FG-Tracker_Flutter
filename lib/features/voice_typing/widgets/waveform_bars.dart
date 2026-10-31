import 'dart:math';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedWaveformBars extends StatelessWidget {
  final double soundLevel; // 0.0 to 1.0 normalized

  const AnimatedWaveformBars({
    super.key,
    required this.soundLevel,
  });

  static const int _barCount = 22;

  // Base pattern multiplier for natural-looking visual variance across the 22 bars
  static const List<double> _baseMultipliers = [
    0.30,
    0.45,
    0.65,
    0.85,
    0.95,
    0.75,
    0.90,
    1.00,
    0.80,
    0.60,
    0.90,
    0.95,
    0.70,
    0.85,
    1.00,
    0.80,
    0.90,
    0.75,
    0.60,
    0.45,
    0.35,
    0.25,
  ];

  @override
  Widget build(BuildContext context) {
    const minHeight = 8.0;
    const maxHeight = 42.0;

    return SizedBox(
      height: 48.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          final multiplier = _baseMultipliers[index % _baseMultipliers.length];
          // Target height influenced by live sound level with pseudo-random jitter for vitality
          final levelFactor = max(0.1, soundLevel);
          final computedHeight =
              (minHeight + (maxHeight - minHeight) * levelFactor * multiplier)
                  .clamp(minHeight, maxHeight);

          final color = (index % 2 == 0)
              ? AppColors.primaryDarkblue
              : AppColors.authIconBar;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutQuad,
              width: 5.w,
              height: computedHeight.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class StaticWaveformBars extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Function(double)? onSeek;

  const StaticWaveformBars({
    super.key,
    required this.progress,
    this.onSeek,
  });

  static const int _barCount = 26;

  static const List<double> _fixedHeights = [
    12.0,
    18.0,
    26.0,
    32.0,
    22.0,
    36.0,
    28.0,
    20.0,
    34.0,
    38.0,
    24.0,
    16.0,
    30.0,
    36.0,
    22.0,
    28.0,
    34.0,
    26.0,
    18.0,
    30.0,
    38.0,
    26.0,
    20.0,
    28.0,
    18.0,
    12.0,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (onSeek != null && constraints.maxWidth > 0) {
              final tapFraction =
                  (details.localPosition.dx / constraints.maxWidth)
                      .clamp(0.0, 1.0);
              onSeek!(tapFraction);
            }
          },
          child: SizedBox(
            height: 40.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_barCount, (index) {
                final barFraction = index / (_barCount - 1);
                final isFilled = barFraction <= progress;
                final barHeight = _fixedHeights[index % _fixedHeights.length];

                return Container(
                  width: 4.w,
                  height: barHeight.h,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.primaryDarkblue
                        : AppColors.authIconBar,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
