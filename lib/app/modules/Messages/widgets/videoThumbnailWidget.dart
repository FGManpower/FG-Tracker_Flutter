import 'dart:io';
import 'dart:typed_data';

import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnail;
  final String duration;
  final VoidCallback onTap;

  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.thumbnail,
    required this.duration,
    required this.onTap,
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220.w,
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CNetworkImage(imageurl: "${ConstRes.aImageBaseUrl}${widget.thumbnail}"),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(.75),
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
                    color: Colors.black45,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(
                      5.r,
                    ),
                  ),
                  child: Text(
                    widget.duration ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
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

Future<String?> generateThumbnailFile(
  String videoPath,
) async {
  final Uint8List? bytes = await VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 300,
    quality: 75,
  );

  if (bytes == null) {
    return null;
  }

  final dir = await getTemporaryDirectory();

  final thumbnailFile = File(
    "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
  );

  await thumbnailFile.writeAsBytes(
    bytes,
  );

  return thumbnailFile.path;
}
