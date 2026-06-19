import 'dart:io';
import 'dart:typed_data';

import 'package:fgtracker/app/Core/util/DateTime_Format.dart';
import 'package:fgtracker/app/Core/util/file_helper.dart';
import 'package:fgtracker/app/Core/values/Dialog/DialogBox.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Services/DocumentService.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Views/videoPlayerScreen.dart';
import 'package:fgtracker/app/modules/Messages/widgets/videoThumbnailWidget.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../gen/fonts.gen.dart';
import '../../../Core/constant/const_res.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';

import 'AudioPlayerWidget.dart';
import 'message_Widgets.dart';

class ChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe
        ? const LinearGradient(
      colors: [ToggleThemeData.darkPurple, ToggleThemeData.Appcolor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Colors.white, Colors.white],
    );

    final textColor = isSentByMe ? Colors.white : Colors.black87;

    final borderRadius = isSentByMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(2),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(2),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment:
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: bgColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                )
              ],
            ),
            child: _buildMessageContent(message, textColor, isSentByMe),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(
              left: isSentByMe ? 0 : 6.w,
              right: isSentByMe ? 6.w : 0,
            ),
            child: Align(
              alignment:
              isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  reausabletext(
                    formatTime(message.timestamp ?? ""),
                    fontsize: 10.sp,
                    color: Colors.grey[500],
                  ),
                  if (isSentByMe) SizedBox(width: 4.w),
                  if (isSentByMe)
                    Icon(
                      (message.seenCount ?? 0) > 0
                          ? Icons.done_all
                          : Icons.done,
                      size: 16.sp,
                      color: (message.seenCount ?? 0) > 0
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      MessageData message,
      Color textColor,
      bool isSentByMe,
      ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final parts = message.content?.split("||") ?? [];
      final imagePart = parts.isNotEmpty ? parts[0] : "";
      final textPart = parts.length > 1 ? parts[1] : "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: ImageViewerWidget(
              imageProvider: NetworkImage(
                "${ConstRes.aImageBaseUrl}$imagePart",
              ),
              width: 220,
              height: 200,
              borderRadius: 10,
            ),
          ),
          if (textPart.isNotEmpty) SizedBox(height: 8.h),
          if (textPart.isNotEmpty)
            reausabletext(
              textPart,
              color: textColor,
              fontsize: 11.sp,
            ),
        ],
      );
    } else if (message.messageType == "audio") {
      return AudioBubble(
        audioUrl: "${ConstRes.aImageBaseUrl}${message.content}",
        isMe: false,
      );
    } else if (message.messageType == "video") {
      final videoUrl = "${ConstRes.aImageBaseUrl}${message.content}";

      return ChatMediaDownloadTile(
        fileUrl: videoUrl,
        fileName: message.content?.split('/').last ?? 'video.mp4',
        isVideo: true,
        isSentByMe: isSentByMe,
        textColor: textColor,
        onOpenVideo: () {
          Get.toNamed(
            Routes.videoPlayerScreen,
            arguments: {
              "videoUrl": message.content,
            },
          );
        },
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];

      final documentUrl = parts.isNotEmpty ? parts[0] : "";

      String documentName =
      parts.length > 1 ? parts[1] : documentUrl.split('/').last;

      documentName = removeDuplicateExtension(
        documentName,
      );

      return ChatMediaDownloadTile(
        fileUrl: "${ConstRes.aImageBaseUrl}$documentUrl",
        fileName: documentName,
        isVideo: false,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else {
      return reausabletext(
        message.content.toString(),
        color: textColor,
        fontsize: 12.sp,
        fontfamily: FontFamily.interMedium,
      );
    }
  }
}

class GroupChatBubble extends StatelessWidget {
  final MessageData message;
  final BuildContext context;
  final bool isGroup;
  final int? groupId;
  final String? groupName;

  const GroupChatBubble({
    Key? key,
    required this.message,
    required this.context,
    this.isGroup = false,
    this.groupId,
    this.groupName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId =
    Global.storageServices.get(PrefConst.userId).toString();

    final isSentByMe = message.senderId.toString() == currentUserId;

    final bgColor = isSentByMe
        ? const LinearGradient(
      colors: [ToggleThemeData.darkPurple, ToggleThemeData.Appcolor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [
        Colors.white,
        Colors.white,
      ],
    );

    final textColor = isSentByMe ? Colors.white : Colors.black87;

    final borderRadius = isSentByMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(2),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(2),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isGroup && !isSentByMe)
            Padding(
              padding: EdgeInsets.only(
                right: 8.w,
                top: 18.h,
              ),
              child: GestureDetector(
                onTap: () {
                  DialogBox().showRouteDetailsBottomSheet(
                    destination: const LatLng(0, 0),
                    distance: 0,
                    userId: int.tryParse(
                      message.senderId.toString(),
                    ) ??
                        0,
                    groupId: groupId,
                    groupName: groupName,
                    name: message.senderName,
                    imageUrl: message.senderImage,
                    status: true,
                    lastSeen: "",
                    isGroupChat: true,
                  );
                },
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: message.senderImage != null &&
                      message.senderImage!.isNotEmpty
                      ? NetworkImage(
                    "${ConstRes.aImageBaseUrl}${message.senderImage}",
                  )
                      : null,
                  child: message.senderImage == null ||
                      message.senderImage!.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 18.sp,
                  )
                      : null,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isGroup)
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSentByMe ? 0 : 4.w,
                      right: isSentByMe ? 4.w : 0,
                      bottom: 4.h,
                      top: 20.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isSentByMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isSentByMe) ...[
                          Text(
                            message.senderName?.toString() ?? "",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            formatTime(message.timestamp ?? ""),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            formatTime(message.timestamp ?? ""),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            message.senderName?.toString() ?? "",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: bgColor,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      )
                    ],
                  ),
                  child: _buildMessageContent(
                    message,
                    textColor,
                    isSentByMe,
                  ),
                ),
                SizedBox(height: 4.h),
                if (isSentByMe)
                  Padding(
                    padding: EdgeInsets.only(
                      right: 4.w,
                    ),
                    child: Icon(
                      (message.seenCount ?? 0) > 0
                          ? Icons.done_all
                          : Icons.done,
                      size: 14.sp,
                      color: (message.seenCount ?? 0) > 0
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (isGroup && isSentByMe)
            Padding(
              padding: EdgeInsets.only(
                left: 8.w,
                top: 20.h,
              ),
              child: GestureDetector(
                onTap: () {
                  DialogBox().showRouteDetailsBottomSheet(
                    destination: const LatLng(0, 0),
                    distance: 0,
                    userId: int.tryParse(
                      message.senderId.toString(),
                    ) ??
                        0,
                    groupId: groupId,
                    groupName: groupName,
                    name: message.senderName,
                    imageUrl: message.senderImage,
                    status: true,
                    lastSeen: "",
                    isGroupChat: true,
                  );
                },
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: message.senderImage != null &&
                      message.senderImage!.isNotEmpty
                      ? NetworkImage(
                    "${ConstRes.aImageBaseUrl}${message.senderImage}",
                  )
                      : null,
                  child: message.senderImage == null ||
                      message.senderImage!.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 18.sp,
                  )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      MessageData message,
      Color textColor,
      bool isSentByMe,
      ) {
    if (message.messageType == "image" || message.messageType == "image_text") {
      final parts = message.content?.split("||") ?? [];
      final imagePart = parts.isNotEmpty ? parts[0] : "";
      final textPart = parts.length > 1 ? parts[1] : "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: ImageViewerWidget(
              imageProvider: NetworkImage(
                "${ConstRes.aImageBaseUrl}$imagePart",
              ),
              width: 220,
              height: 200,
              borderRadius: 10,
            ),
          ),
          if (textPart.isNotEmpty) SizedBox(height: 8.h),
          if (textPart.isNotEmpty)
            reausabletext(
              textPart,
              color: textColor,
              fontsize: 11.sp,
            ),
        ],
      );
    } else if (message.messageType == "audio") {
      return AudioBubble(
        audioUrl: "${ConstRes.aImageBaseUrl}${message.content}",
        isMe: false,
      );
    } else if (message.messageType == "video") {
      final videoUrl = "${ConstRes.aImageBaseUrl}${message.content}";

      return ChatMediaDownloadTile(
        fileUrl: videoUrl,
        fileName: message.content?.split('/').last ?? 'video.mp4',
        isVideo: true,
        isSentByMe: isSentByMe,
        textColor: textColor,
        onOpenVideo: () {
          Get.toNamed(
            Routes.videoPlayerScreen,
            arguments: {
              "videoUrl": message.content,
            },
          );
        },
      );
    } else if (message.messageType == "document") {
      final parts = message.content?.split("||") ?? [];

      final documentUrl = parts.isNotEmpty ? parts[0] : "";

      String documentName =
      parts.length > 1 ? parts[1] : documentUrl.split('/').last;

      documentName = removeDuplicateExtension(
        documentName,
      );

      return ChatMediaDownloadTile(
        fileUrl: "${ConstRes.aImageBaseUrl}$documentUrl",
        fileName: documentName,
        isVideo: false,
        isSentByMe: isSentByMe,
        textColor: textColor,
      );
    } else {
      return reausabletext(
        message.content.toString(),
        color: textColor,
        fontsize: 12.sp,
        fontfamily: FontFamily.interMedium,
      );
    }
  }
}

// ============================================================================
// ChatMediaDownloadTile
// ----------------------------------------------------------------------------
// WhatsApp-style download-on-demand tile for VIDEO and DOCUMENT messages.
//
// - On open: checks local app storage for an already-downloaded copy.
//     -> Already downloaded  : shows the "ready" view, no download icon.
//     -> Not downloaded yet  : fetches file size (HEAD request) and shows a
//                              download icon + size, exactly like WhatsApp.
// - Tap on download icon: downloads the file with a visible progress ring.
// - Once downloaded: permanently switches to the "ready" view (never shows
//   the download icon again for that file, since it's cached on disk).
//
// IMPORTANT: For video, "downloaded" only unlocks the existing
// VideoThumbnailWidget + Routes.videoPlayerScreen flow, which still streams
// from the remote URL exactly as before — the local file is only used as the
// "has this been fetched once" marker, per requirement.
// ============================================================================
class ChatMediaDownloadTile extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final bool isVideo;
  final bool isSentByMe;
  final Color textColor;
  final VoidCallback? onOpenVideo;

  const ChatMediaDownloadTile({
    Key? key,
    required this.fileUrl,
    required this.fileName,
    required this.isVideo,
    required this.isSentByMe,
    required this.textColor,
    this.onOpenVideo,
  }) : super(key: key);

  @override
  State<ChatMediaDownloadTile> createState() => _ChatMediaDownloadTileState();
}

enum _TileStatus { checking, notDownloaded, downloading, downloaded, error }

class _ChatMediaDownloadTileState extends State<ChatMediaDownloadTile> {
  _TileStatus _status = _TileStatus.checking;
  double _progress = 0.0;
  String? _localPath;
  String _sizeLabel = '';
  Uint8List? _previewThumbnail;

  @override
  void initState() {
    super.initState();
    if (widget.isSentByMe) {
      // Messages sent by me are already on the server successfully (tick
      // marks confirm that) — never show a download affordance for my own
      // outgoing media, exactly like WhatsApp.
      _status = _TileStatus.downloaded;
      return;
    }
    _checkLocalFile();
  }

  Future<String> _getLocalDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/chat_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir.path;
  }

  Future<void> _checkLocalFile() async {
    try {
      final dirPath = await _getLocalDirPath();
      final filePath = '$dirPath/${widget.fileName}';
      final file = File(filePath);

      if (await file.exists()) {
        if (!mounted) return;
        setState(() {
          _localPath = filePath;
          _status = _TileStatus.downloaded;
        });
        return;
      }

      await _fetchSize();
      if (widget.isVideo) {
        _fetchPreviewThumbnail();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = _TileStatus.notDownloaded);
    }
  }

  // Fetches a single lightweight preview frame for an un-downloaded video so
  // the tile shows a real (lightly tinted) banner instead of a blank box —
  // this does NOT download the full video, just one small thumbnail frame.
  Future<void> _fetchPreviewThumbnail() async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: widget.fileUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 50,
      );
      if (mounted && bytes != null) {
        setState(() => _previewThumbnail = bytes);
      }
    } catch (e) {
      // Silently ignore — falls back to the plain icon banner.
    }
  }

  Future<void> _fetchSize() async {
    try {
      final response = await http
          .head(Uri.parse(widget.fileUrl))
          .timeout(const Duration(seconds: 8));
      final lengthHeader = response.headers['content-length'];
      if (lengthHeader != null) {
        final bytes = int.tryParse(lengthHeader) ?? 0;
        _sizeLabel = _formatBytes(bytes);
      }
    } catch (e) {
      _sizeLabel = '';
    } finally {
      if (mounted) {
        setState(() => _status = _TileStatus.notDownloaded);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }

  Future<void> _startDownload() async {
    if (_status == _TileStatus.downloading) return;

    setState(() {
      _status = _TileStatus.downloading;
      _progress = 0.0;
    });

    File? tempFile;
    try {
      final dirPath = await _getLocalDirPath();
      final filePath = '$dirPath/${widget.fileName}';
      final tempPath = '$filePath.part';
      tempFile = File(tempPath);

      final request = http.Request('GET', Uri.parse(widget.fileUrl));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception('Download failed: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      var received = 0;

      final sink = tempFile.openWrite();
      await for (final chunk in streamedResponse.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (contentLength > 0 && mounted) {
          setState(() {
            _progress = received / contentLength;
          });
        }
      }
      await sink.close();

      final finalFile = await tempFile.rename(filePath);

      if (!mounted) return;
      setState(() {
        _localPath = finalFile.path;
        _status = _TileStatus.downloaded;
      });
    } catch (e) {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      if (!mounted) return;
      setState(() => _status = _TileStatus.error);
    }
  }

  Future<void> _openDocument() async {
    if (_localPath != null) {
      await OpenFile.open(_localPath);
    } else {
      // My own sent document — never downloaded locally by this tile, so
      // fall back to opening it straight from the server, same as before.
      await DocumentService().openDocument(widget.fileUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return _buildVideoTile();
    }
    return _buildDocumentTile();
  }

  // -------------------- VIDEO --------------------
  Widget _buildVideoTile() {
    if (_status == _TileStatus.downloaded) {
      // Already fetched once -> show existing thumbnail/player flow as-is.
      return VideoThumbnailWidget(
        videoUrl: widget.fileUrl,
        onTap: () => widget.onOpenVideo?.call(),
      );
    }

    return GestureDetector(
      onTap: _status == _TileStatus.downloading ? null : _startDownload,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 220.w,
          height: 140.h,
          color: Colors.black.withOpacity(0.06),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Lightweight preview banner (single fetched frame), shown
              // as a "blurred" look via a dark tint overlay on top — the
              // video itself never plays here, only a still preview.
              if (_previewThumbnail != null)
                Image.memory(
                  _previewThumbnail!,
                  fit: BoxFit.cover,
                ),
              if (_previewThumbnail == null)
                Center(
                  child: Icon(
                    Icons.videocam_rounded,
                    size: 40.sp,
                    color: widget.textColor.withOpacity(0.4),
                  ),
                ),
              // Light dark tint so the badge stays readable over the
              // preview frame, like WhatsApp's faded banner look.
              if (_previewThumbnail != null)
                Container(color: Colors.black.withOpacity(0.32)),

              // single combined pill: icon/loader + size/% text together,
              // forced dead-center of the tile regardless of its own size.
              Center(
                child: _buildDownloadBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- DOCUMENT --------------------
  Widget _buildDocumentTile() {
    final extension = widget.fileName.split('.').last.toLowerCase();
    final icon = getFileIcon(widget.fileName);
    final iconColor = getFileColor(widget.fileName);
    final isReady = _status == _TileStatus.downloaded;

    return InkWell(
      onTap: () {
        if (isReady) {
          _openDocument();
        } else if (_status != _TileStatus.downloading) {
          _startDownload();
        }
      },
      child: Container(
        width: 240.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isReady
                        ? extension.toUpperCase()
                        : [
                      extension.toUpperCase(),
                      if (_sizeLabel.isNotEmpty) _sizeLabel,
                    ].join(' · '),
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.6),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildTrailingIcon(isReady: isReady),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingIcon({required bool isReady}) {
    if (isReady) {
      return Icon(
        Icons.insert_drive_file_outlined,
        color: widget.textColor,
        size: 20.sp,
      );
    }

    if (_status == _TileStatus.downloading) {
      return SizedBox(
        width: 22.w,
        height: 22.w,
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
          strokeWidth: 2.5,
          color: widget.textColor,
        ),
      );
    }

    if (_status == _TileStatus.error) {
      return Icon(
        Icons.refresh_rounded,
        color: widget.textColor,
        size: 22.sp,
      );
    }

    // notDownloaded / checking -> download affordance
    return Icon(
      Icons.download_rounded,
      color: widget.textColor,
      size: 22.sp,
    );
  }

  // -------------------- shared bits for video overlay --------------------

  // Single combined pill (icon/loader + text together), WhatsApp-style:
  // one rounded dark badge showing the download icon and size/percentage
  // side by side — not two separate widgets.
  Widget _buildDownloadBadge() {
    Widget leading;
    String? label;

    if (_status == _TileStatus.downloading) {
      leading = SizedBox(
        width: 16.w,
        height: 16.w,
        child: CircularProgressIndicator(
          value: _progress > 0 ? _progress : null,
          strokeWidth: 2,
          color: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.25),
        ),
      );
      label = '${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%';
    } else if (_status == _TileStatus.error) {
      leading = Icon(
        Icons.refresh_rounded,
        color: Colors.white,
        size: 18.sp,
      );
      label = 'Tap to retry';
    } else {
      // notDownloaded / checking
      leading = Icon(
        Icons.download_rounded,
        color: Colors.white,
        size: 18.sp,
      );
      label = _sizeLabel.isNotEmpty ? _sizeLabel : null;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          if (label != null) SizedBox(width: 8.w),
          if (label != null)
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}