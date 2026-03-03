import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

import '../Controller/audio_player_controller.dart';

class AudioBubble extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioBubble({
    Key? key,
    required this.audioUrl,
    required this.isMe,
  }) : super(key: key);

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

            return SizedBox(
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
            );
          }),
          SizedBox(width: 10.w),
          Obx(() {
            final isCurrent = controller.currentUrl.value == widget.audioUrl;

            final playing = isCurrent && controller.isPlaying.value;

            final duration =
                controller.durationCache[widget.audioUrl] ?? Duration.zero;

            final position =
                isCurrent ? controller.position.value : Duration.zero;

            final displayTime = playing ? (duration - position) : duration;

            return Text(
              _format(displayTime),
              style: TextStyle(
                fontSize: 11.sp,
                color: textColor,
              ),
            );
          }),
        ],
      ),
    );
  }
}
