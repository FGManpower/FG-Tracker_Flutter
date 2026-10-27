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
        widget.isMe ? const Color(0xFF6C63FF) : Colors.grey.shade200;

    final textColor = widget.isMe ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isMe ? Colors.white24 : Colors.grey.shade400,
                ),
                child: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: textColor,
                  size: 20.sp,
                ),
              ),
            );
          }),
          SizedBox(width: 10.w),
          Obx(() {
            final isCurrent = controller.currentUrl.value == widget.audioUrl;

            final duration = controller.getDuration(widget.audioUrl);

            final position =
                isCurrent ? controller.position.value : Duration.zero;

            double progress = duration.inMilliseconds == 0
                ? 0
                : position.inMilliseconds / duration.inMilliseconds;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (duration.inMilliseconds > 0) {
                  final fraction = (details.localPosition.dx / 120.w).clamp(0.0, 1.0);
                  final targetMs = (duration.inMilliseconds * fraction).round();
                  controller.seek(Duration(milliseconds: targetMs));
                }
              },
              onHorizontalDragUpdate: (details) {
                if (duration.inMilliseconds > 0) {
                  final fraction = (details.localPosition.dx / 120.w).clamp(0.0, 1.0);
                  final targetMs = (duration.inMilliseconds * fraction).round();
                  controller.seek(Duration(milliseconds: targetMs));
                }
              },
              child: SizedBox(
                width: 120.w,
                height: 40.h,
                child: AnimatedWaveList(
                  stream: Stream.value(
                    Amplitude(current: progress * 100, max: 100),
                  ),
                  barBuilder: (animation, amplitude) => WaveFormBar(
                    animation: animation,
                    amplitude: amplitude,
                    color: textColor,
                  ),
                ),
              ),
            );
          }),
          SizedBox(width: 8.w),
          Obx(() {
            final isCurrent = controller.currentUrl.value == widget.audioUrl;

            final playing = isCurrent && controller.isPlaying.value;

            final duration =
                controller.durationCache[widget.audioUrl] ?? Duration.zero;

            final position =
                isCurrent ? controller.position.value : Duration.zero;

            final displayTime = playing ? (duration - position) : duration;

            final currentSpeed = controller.playbackSpeed.value;
            final speedLabel = currentSpeed == 1.0
                ? "1x"
                : (currentSpeed == 1.5 ? "1.5x" : "2x");

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _format(displayTime),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: textColor,
                  ),
                ),
                if (playing)
                  GestureDetector(
                    onTap: controller.toggleSpeed,
                    child: Container(
                      margin: EdgeInsets.only(left: 6.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
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
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
