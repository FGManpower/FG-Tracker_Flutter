import 'dart:math';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceInputWaveformBars extends StatefulWidget {
  final double soundLevel; // 0.0 to 1.0
  final bool isRecording;
  final Color primaryColor;
  final Color secondaryColor;

  const VoiceInputWaveformBars({
    super.key,
    required this.soundLevel,
    this.isRecording = true,
    this.primaryColor = AppColors.primaryDarkblue, // #704AFA
    this.secondaryColor = AppColors.authIconBar, // #B2ACFD
  });

  @override
  State<VoiceInputWaveformBars> createState() => _VoiceInputWaveformBarsState();
}

class _VoiceInputWaveformBarsState extends State<VoiceInputWaveformBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  static const List<double> _baseMultipliers = [
    0.30, 0.45, 0.60, 0.75, 0.85, 0.95, 1.00, 0.95, 0.85, 0.75, 0.65,
    0.70, 0.85, 0.95, 1.00, 0.95, 0.85, 0.75, 0.60, 0.45, 0.35, 0.25,
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return SizedBox(
          height: 48.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(22, (index) {
              final isPrimary = index % 2 == 0;
              final color = isPrimary ? widget.primaryColor : widget.secondaryColor;

              final baseMul = _baseMultipliers[index % _baseMultipliers.length];
              final animShift = sin((_animController.value * 2 * pi) + (index * 0.3));

              double height;
              if (widget.isRecording) {
                final audioBoost = widget.soundLevel * 28.0;
                final waveJitter = animShift * 8.0;
                height = (8.0 + (baseMul * (audioBoost + waveJitter))).clamp(6.0, 44.0);
              } else {
                height = (8.0 + (baseMul * 4.0)).clamp(6.0, 20.0);
              }

              return Container(
                width: 5.w,
                height: height.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5.r),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class VoiceInputReviewWaveform extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color playedColor;
  final Color unplayedColor;
  final ValueChanged<double>? onSeek;

  const VoiceInputReviewWaveform({
    super.key,
    required this.progress,
    this.playedColor = AppColors.primaryDarkblue,
    this.unplayedColor = AppColors.authIconBar,
    this.onSeek,
  });

  static const List<double> _fixedHeights = [
    10.0, 16.0, 22.0, 14.0, 26.0, 18.0, 12.0, 24.0,
    20.0, 16.0, 26.0, 22.0, 14.0, 28.0, 20.0, 12.0,
    18.0, 24.0, 16.0, 22.0, 14.0, 20.0, 16.0, 12.0,
    18.0, 10.0,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (onSeek != null && constraints.maxWidth > 0) {
              final frac = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              onSeek!(frac);
            }
          },
          child: SizedBox(
            height: 28.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(26, (index) {
                final barFrac = index / 26.0;
                final isPlayed = barFrac <= progress;
                final h = _fixedHeights[index % _fixedHeights.length];

                return Container(
                  width: 3.5.w,
                  height: h.h,
                  decoration: BoxDecoration(
                    color: isPlayed ? playedColor : unplayedColor,
                    borderRadius: BorderRadius.circular(3.r),
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
