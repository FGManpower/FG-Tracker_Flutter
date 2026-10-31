import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

import '../Controller/audio_player_controller.dart';

class AudioBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  State<AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<AudioBubble> {
  final GlobalAudioController controller = Get.put(GlobalAudioController());

  @override
  void initState() {
    super.initState();
    controller.loadDuration(widget.audioUrl);
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        widget.isMe ? const Color(0xFF5045B9) : Colors.white;

    final textColor = widget.isMe ? Colors.white : Colors.black87;
    final secondaryTextColor =
        widget.isMe ? Colors.white.withValues(alpha: 0.75) : Colors.black54;
    final activeBarColor = widget.isMe ? Colors.white : const Color(0xFF5045B9);
    final inactiveBarColor =
        widget.isMe ? Colors.white38 : Colors.grey.shade300;

    return Container(
      width: 240.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Play/Pause circular button
              Obx(() {
                final isCurrent = controller.currentUrl.value == widget.audioUrl;
                final playing = isCurrent && controller.isPlaying.value;

                return GestureDetector(
                  onTap: () {
                    if (playing) {
                      controller.pause();
                    } else {
                      controller.play(widget.audioUrl);
                    }
                  },
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isMe
                          ? Colors.white.withValues(alpha: 0.22)
                          : const Color(0xFF5045B9).withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: activeBarColor,
                      size: 24.sp,
                    ),
                  ),
                );
              }),
              SizedBox(width: 10.w),

              // WhatsApp Waveform Scrubbing Bar
              Expanded(
                child: Obx(() {
                  final isCurrent = controller.currentUrl.value == widget.audioUrl;
                  final duration = controller.getDuration(widget.audioUrl);
                  final position =
                      isCurrent ? controller.position.value : Duration.zero;

                  final double progress = duration.inMilliseconds == 0
                      ? 0.0
                      : (position.inMilliseconds / duration.inMilliseconds)
                          .clamp(0.0, 1.0);

                  // 28 realistic waveform bar heights (WhatsApp style)
                  const barHeights = [
                    8, 14, 22, 12, 18, 26, 16, 28, 20, 14, 24, 18, 28, 16,
                    22, 14, 26, 20, 12, 18, 24, 16, 28, 18, 12, 22, 14, 8,
                  ];

                  return Builder(
                    builder: (barCtx) {
                      final totalBars = barHeights.length;
                      final activeCount = (progress * totalBars).round();

                      void seekByPosition(Offset localPos) {
                        final RenderBox? box =
                            barCtx.findRenderObject() as RenderBox?;
                        final barWidth =
                            (box != null && box.hasSize && box.size.width > 0)
                                ? box.size.width
                                : 140.w;
                        if (duration.inMilliseconds > 0 && barWidth > 0) {
                          final fraction =
                              (localPos.dx / barWidth).clamp(0.0, 1.0);
                          final targetMs =
                              (duration.inMilliseconds * fraction).round();
                          controller.seek(Duration(milliseconds: targetMs));
                        }
                      }

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) =>
                            seekByPosition(details.localPosition),
                        onHorizontalDragUpdate: (details) =>
                            seekByPosition(details.localPosition),
                        child: SizedBox(
                          height: 32.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(totalBars, (i) {
                              final isPlayed = i <= activeCount;
                              final barH = barHeights[i].h;
                              return Container(
                                width: 2.4.w,
                                height: barH,
                                decoration: BoxDecoration(
                                  color: isPlayed
                                      ? activeBarColor
                                      : inactiveBarColor,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              SizedBox(width: 8.w),

              // Mic icon badge
              Icon(
                Icons.mic_rounded,
                color: activeBarColor,
                size: 20.sp,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Duration & Speed Row
          Padding(
            padding: EdgeInsets.only(left: 48.w, right: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final isCurrent = controller.currentUrl.value == widget.audioUrl;
                  final playing = isCurrent && controller.isPlaying.value;
                  final duration =
                      controller.durationCache[widget.audioUrl] ?? Duration.zero;
                  final position =
                      isCurrent ? controller.position.value : Duration.zero;

                  final displayTime = playing ? position : duration;

                  return Text(
                    _format(displayTime),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  );
                }),
                Obx(() {
                  final isCurrent = controller.currentUrl.value == widget.audioUrl;
                  final playing = isCurrent && controller.isPlaying.value;
                  final currentSpeed = controller.playbackSpeed.value;
                  final speedLabel = currentSpeed == 1.0
                      ? "1x"
                      : (currentSpeed == 1.5 ? "1.5x" : "2x");

                  if (!playing) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: controller.toggleSpeed,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        speedLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
