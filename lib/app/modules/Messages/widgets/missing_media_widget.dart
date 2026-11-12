import 'package:fgtracker/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Data/Services/media_availability_service.dart';

enum MissingMediaType { image, video, audio, document, media }

extension on MissingMediaType {
  IconData get icon {
    switch (this) {
      case MissingMediaType.image:
        return Icons.hide_image_outlined;
      case MissingMediaType.video:
        return Icons.videocam_off_outlined;
      case MissingMediaType.audio:
        return Icons.music_off_outlined;
      case MissingMediaType.document:
        return Icons.insert_drive_file_outlined;
      case MissingMediaType.media:
        return Icons.perm_media_outlined;
    }
  }

  String unavailableText(AppLocalizations l10n) {
    switch (this) {
      case MissingMediaType.image:
        return l10n.chat_photoUnavailable;
      case MissingMediaType.video:
        return l10n.chat_videoUnavailable;
      case MissingMediaType.audio:
        return l10n.chat_audioUnavailable;
      case MissingMediaType.document:
        return l10n.chat_documentUnavailable;
      case MissingMediaType.media:
        return l10n.chat_mediaUnavailable;
    }
  }
}

/// Full-size "Media is missing" bubble content, used in place of an image,
/// video, audio or document whose file no longer exists.
class MissingMediaCard extends StatelessWidget {
  final MissingMediaType type;
  final bool isSentByMe;
  final String? fileName;
  final double? width;

  const MissingMediaCard({
    super.key,
    required this.type,
    this.isSentByMe = false,
    this.fileName,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final name = fileName?.trim() ?? '';
    final subtitle = name.isNotEmpty
        ? name
        : type.unavailableText(context.l10n);

    return Container(
      width: width ?? 220.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSentByMe
            ? Colors.white.withValues(alpha: 0.55)
            : const Color(0xFFF3F1FB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(type.icon, color: Colors.grey.shade700, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.chat_mediaMissing,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact variant that fills a grid tile (bulk images / mixed media).
class MissingMediaTile extends StatelessWidget {
  final MissingMediaType type;

  const MissingMediaTile({super.key, this.type = MissingMediaType.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, color: Colors.grey.shade600, size: 26.sp),
          SizedBox(height: 4.h),
          Text(
            context.l10n.chat_mediaMissing,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// `errorWidget` for chat images. When an image fails to load it confirms
/// with the server whether the file is really gone: if so it shows
/// "Media is missing", otherwise (e.g. offline) a plain broken-image icon.
class ChatImageErrorTile extends StatefulWidget {
  final String url;

  const ChatImageErrorTile({super.key, required this.url});

  @override
  State<ChatImageErrorTile> createState() => _ChatImageErrorTileState();
}

class _ChatImageErrorTileState extends State<ChatImageErrorTile> {
  /// The server says the file exists after all (the first load hit the
  /// short window right after upload): load it again.
  bool _reload = false;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final status = await MediaAvailabilityService.check(widget.url);
    if (!mounted || status != MediaStatus.available) return;
    await CachedNetworkImage.evictFromCache(widget.url);
    if (mounted) setState(() => _reload = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_reload) {
      return CachedNetworkImage(
        imageUrl: widget.url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const _BrokenImage(),
      );
    }
    return Obx(() {
      if (widget.url.trim().isEmpty ||
          MediaAvailabilityService.isMissing(widget.url)) {
        return const MissingMediaTile();
      }
      return const _BrokenImage();
    });
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade600),
    );
  }
}

/// Shows [child] while the remote file at [url] exists, and a
/// [MissingMediaCard] once the server says it is gone (or the URL is empty).
class MediaAvailabilityGuard extends StatefulWidget {
  final String url;
  final MissingMediaType type;
  final bool isSentByMe;
  final String? fileName;
  final double? width;
  final Widget child;

  const MediaAvailabilityGuard({
    super.key,
    required this.url,
    required this.type,
    required this.child,
    this.isSentByMe = false,
    this.fileName,
    this.width,
  });

  @override
  State<MediaAvailabilityGuard> createState() => _MediaAvailabilityGuardState();
}

class _MediaAvailabilityGuardState extends State<MediaAvailabilityGuard> {
  @override
  void initState() {
    super.initState();
    MediaAvailabilityService.check(widget.url);
  }

  @override
  void didUpdateWidget(covariant MediaAvailabilityGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      MediaAvailabilityService.check(widget.url);
    }
  }

  Widget _missing() => MissingMediaCard(
        type: widget.type,
        isSentByMe: widget.isSentByMe,
        fileName: widget.fileName,
        width: widget.width,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.url.trim().isEmpty) return _missing();
    return Obx(() => MediaAvailabilityService.isMissing(widget.url)
        ? _missing()
        : widget.child);
  }
}
