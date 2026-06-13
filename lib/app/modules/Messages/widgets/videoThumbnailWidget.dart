import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.onTap,
  });

  @override
  State<VideoThumbnailWidget> createState() =>
      _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState
    extends State<VideoThumbnailWidget> {
  Uint8List? thumbnail;
  String durationText = "";

  @override
  void initState() {
    super.initState();
    _loadVideoData();
  }

  Future<void> _loadVideoData() async {
    try {
      thumbnail = await VideoThumbnail.thumbnailData(
        video: widget.videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 75,
      );

      final controller =
      VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await controller.initialize();

      final duration =
          controller.value.duration;

      durationText =
          _formatDuration(duration);

      await controller.dispose();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  String _formatDuration(
      Duration duration,
      ) {
    String twoDigits(int n) =>
        n.toString().padLeft(2, '0');

    final hours = duration.inHours;

    final minutes = twoDigits(
      duration.inMinutes.remainder(60),
    );

    final seconds = twoDigits(
      duration.inSeconds.remainder(60),
    );

    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220.w,
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(12.r),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnail != null)
                Image.memory(
                  thumbnail!,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child:
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                    Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black
                          .withOpacity(.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color:
                    Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ),
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius:
                    BorderRadius.circular(
                      5.r,
                    ),
                  ),
                  child: Text(
                    durationText.isEmpty
                        ? "--:--"
                        : durationText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}