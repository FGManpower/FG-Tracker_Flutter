import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

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
  final AudioPlayer _player = AudioPlayer();
  final StreamController<Amplitude> _waveStreamController =
  StreamController<Amplitude>();

  bool isPlaying = false;
  bool isSpeaker = true;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    await _player.setUrl(widget.audioUrl);

    duration = _player.duration ?? Duration.zero;

    _player.positionStream.listen((pos) {
      position = pos;

      double progress = duration.inMilliseconds == 0
          ? 0
          : pos.inMilliseconds / duration.inMilliseconds;

      _waveStreamController.add(
        Amplitude(current: progress * 100, max: 100),
      );

      setState(() {});
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      await _player.pause();
      setState(() => isPlaying = false);
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
      setState(() => isPlaying = true);
    }
  }

  Future<void> _toggleSpeaker() async {
    final session = await AudioSession.instance;
    isSpeaker = !isSpeaker;

    await session.setActive(true);
    await _player.setVolume(1.0);

    setState(() {});
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  void dispose() {
    _player.dispose();
    _waveStreamController.close();
    super.dispose();
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
          GestureDetector(
            onTap: _playPause,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                widget.isMe ? Colors.white24 : Colors.grey.shade400,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: textColor,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 120.w,
            height: 40.h,
            child: AnimatedWaveList(
              stream: _waveStreamController.stream,
              barBuilder: (animation, amplitude) => WaveFormBar(
                animation: animation,
                amplitude: amplitude,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            format(position),
            style: TextStyle(
              fontSize: 11.sp,
              color: textColor,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: _toggleSpeaker,
            child: Icon(
              isSpeaker ? Icons.volume_up : Icons.hearing,
              color: textColor,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}