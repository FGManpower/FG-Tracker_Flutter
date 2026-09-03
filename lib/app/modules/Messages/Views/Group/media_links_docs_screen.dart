import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MediaLinksDocsScreen extends StatelessWidget {
  final List<MessageData> mediaMessages;

  const MediaLinksDocsScreen({super.key, required this.mediaMessages});

  static const Color _purple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF5F3FB);

  @override
  Widget build(BuildContext context) {
    final mediaList = mediaMessages.where((m) {
      final t = (m.messageType ?? "").toLowerCase();
      return t == "image" || t == "video" || t == "image_text";
    }).toList();

    final docList = mediaMessages.where((m) {
      return (m.messageType ?? "").toLowerCase() == "document";
    }).toList();

    final linkList = <MessageData>[];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: _purple.withValues(alpha: 0.1),
          centerTitle: false,
          iconTheme: const IconThemeData(color: _purple),
          title: Text(
            "Media, links, and docs",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelColor: _purple,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: _purple,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Media"),
              Tab(text: "Links"),
              Tab(text: "Docs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            mediaList.isEmpty
                ? _empty("No media found", Icons.photo_library_outlined)
                : GridView.builder(
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.w,
                      mainAxisSpacing: 4.w,
                    ),
                    itemCount: mediaList.length,
                    itemBuilder: (_, i) {
                      final m = mediaList[i];
                      final thumb = MediaHelper.thumb(m);
                      final isVideo = MediaHelper.isVideo(m);

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => FullScreenMediaViewer(
                              mediaList: mediaList,
                              initialIndex: i,
                            ),
                            transition: Transition.fadeIn,
                            opaque: false,
                          );
                        },
                        child: Container(
                          color: const Color(0xFFEDEBFB),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumb.isNotEmpty)
                                Image.network(
                                  thumb,
                                  fit: BoxFit.cover,
                                  cacheWidth: 250,
                                  gaplessPlayback: true,
                                  errorBuilder: (_, __, ___) => Icon(
                                    isVideo
                                        ? Icons.videocam_rounded
                                        : Icons.image_rounded,
                                    color: _purple.withValues(alpha: 0.4),
                                    size: 28.sp,
                                  ),
                                )
                              else
                                Icon(
                                  isVideo
                                      ? Icons.videocam_rounded
                                      : Icons.image_rounded,
                                  color: _purple.withValues(alpha: 0.4),
                                  size: 28.sp,
                                ),
                              if (isVideo)
                                Center(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black45,
                                    radius: 16.r,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            linkList.isEmpty
                ? _empty("No links found", Icons.link_rounded)
                : const SizedBox(),
            docList.isEmpty
                ? _empty("No documents found", Icons.insert_drive_file_outlined)
                : ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: docList.length,
                    itemBuilder: (_, i) {
                      final m = docList[i];
                      final name = MediaHelper.fileName(m);
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.only(bottom: 8.h),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          onTap: () => _openDoc(m),
                          leading: Icon(Icons.insert_drive_file,
                              color: _purple, size: 28.sp),
                          title: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                          subtitle: Text("Document",
                              style: TextStyle(fontSize: 12.sp)),
                          trailing: Icon(Icons.chevron_right_rounded,
                              color: Colors.grey.shade400),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String t, IconData i) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(i, size: 56.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            t,
            style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _openDoc(MessageData m) {
    final name = MediaHelper.fileName(m);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 20.h),
            Icon(Icons.insert_drive_file_rounded, color: _purple, size: 44.sp),
            SizedBox(height: 12.h),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaHelper {
  static bool isVideo(MessageData m) =>
      (m.messageType ?? "").toLowerCase() == "video";

  static bool isImage(MessageData m) {
    final t = (m.messageType ?? "").toLowerCase();
    return t == "image" || t == "image_text";
  }

  static String fileUrl(MessageData m) {
    final content = (m.content ?? "").trim();
    if (content.isEmpty) return "";
    final parts = content.split("||");
    final path = parts.first.trim();
    if (path.startsWith("http")) return path;
    return "${ConstRes.aImageBaseUrl}$path";
  }

  static String thumb(MessageData m) {
    final content = (m.content ?? "").trim();
    if (content.isEmpty) return "";
    final parts = content.split("||");

    if (isVideo(m)) {
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        final t = parts[1].trim();
        if (t.startsWith("http")) return t;
        return "${ConstRes.aImageBaseUrl}$t";
      }
      return "";
    }

    final p = parts.first.trim();
    if (p.startsWith("http")) return p;
    return "${ConstRes.aImageBaseUrl}$p";
  }

  static String fileName(MessageData m) {
    final p = (m.content ?? "").split("||").first;
    final n = p.split('/').last;
    return n.isEmpty ? "Document" : n;
  }
}

class FullScreenMediaController extends GetxController {
  final List<MessageData> mediaList;
  final int initialIndex;

  FullScreenMediaController({
    required this.mediaList,
    required this.initialIndex,
  });

  late final PageController pageController;
  final currentIndex = 0.obs;
  final showUI = true.obs;

  final Map<int, VideoPlayerController> videos = {};
  final isReady = <int, RxBool>{};
  final isPlaying = <int, RxBool>{};
  final isLoadingVideo = <int, RxBool>{};

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _prepareVideo(initialIndex);
  }

  @override
  void onClose() {
    for (final c in videos.values) {
      c.dispose();
    }
    pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }

  void toggleUI() => showUI.value = !showUI.value;

  void onPageChanged(int i) {
    final oldIndex = currentIndex.value;
    final old = videos[oldIndex];
    if (old != null && old.value.isInitialized) {
      old.pause();
      isPlaying[oldIndex]?.value = false;
    }

    currentIndex.value = i;
    _prepareVideo(i);

    final current = videos[i];
    if (current != null && current.value.isInitialized) {
      current.play();
      isPlaying[i]?.value = true;
    }
  }

  void togglePlay(int i) {
    final c = videos[i];
    if (c == null || !c.value.isInitialized) {
      _prepareVideo(i, autoPlay: true);
      return;
    }
    if (c.value.isPlaying) {
      c.pause();
      isPlaying[i]?.value = false;
    } else {
      c.play();
      isPlaying[i]?.value = true;
    }
  }

  Future<void> _prepareVideo(int i, {bool autoPlay = true}) async {
    if (i < 0 || i >= mediaList.length) return;
    final m = mediaList[i];
    if (!MediaHelper.isVideo(m)) return;
    if (videos.containsKey(i)) return;

    final url = MediaHelper.fileUrl(m);
    if (url.isEmpty) return;

    isReady[i] = false.obs;
    isPlaying[i] = false.obs;
    isLoadingVideo[i] = true.obs;

    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    videos[i] = c;

    try {
      await c.initialize();
      c.setLooping(false);
      isLoadingVideo[i]?.value = false;
      isReady[i]?.value = true;

      c.addListener(() {
        if (isPlaying[i] != null && c.value.isInitialized) {
          isPlaying[i]!.value = c.value.isPlaying;
        }
      });

      if (currentIndex.value == i && autoPlay) {
        c.play();
        isPlaying[i]?.value = true;
      }
    } catch (e) {
      isLoadingVideo[i]?.value = false;
      isReady[i]?.value = false;
      debugPrint("Video load error [$i]: $e | URL: $url");
    }
  }
}

class FullScreenMediaViewer extends StatelessWidget {
  final List<MessageData> mediaList;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tag = "media_viewer_${identityHashCode(mediaList)}_$initialIndex";
    final c = Get.put(
      FullScreenMediaController(
        mediaList: mediaList,
        initialIndex: initialIndex,
      ),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: c.pageController,
            itemCount: mediaList.length,
            onPageChanged: c.onPageChanged,
            itemBuilder: (_, i) {
              final m = mediaList[i];
              if (MediaHelper.isVideo(m)) {
                return _VideoPage(controller: c, index: i, message: m);
              }
              return _ImagePage(message: m, onTap: c.toggleUI);
            },
          ),
          Obx(() {
            final visible = c.showUI.value;
            return AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !visible,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 4.h,
                      bottom: 8.h,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.delete<FullScreenMediaController>(tag: tag);
                              Get.back();
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.white, size: 22.sp),
                            ),
                          ),
                          const Spacer(),
                          Obx(() => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  "${c.currentIndex.value + 1}/${mediaList.length}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ImagePage extends StatelessWidget {
  final MessageData message;
  final VoidCallback onTap;

  const _ImagePage({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = MediaHelper.fileUrl(message);
    final thumb = MediaHelper.thumb(message);

    return GestureDetector(
      onTap: onTap,
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (thumb.isNotEmpty)
                Image.network(
                  thumb,
                  fit: BoxFit.contain,
                  cacheWidth: 400,
                  gaplessPlayback: true,
                ),
              if (url.isNotEmpty)
                Image.network(
                  url,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox();
                  },
                  errorBuilder: (_, __, ___) => thumb.isEmpty
                      ? Icon(Icons.broken_image_rounded,
                          color: Colors.white54, size: 56.sp)
                      : const SizedBox(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPage extends StatelessWidget {
  final FullScreenMediaController controller;
  final int index;
  final MessageData message;

  const _VideoPage({
    required this.controller,
    required this.index,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final thumb = MediaHelper.thumb(message);

    return GestureDetector(
      onTap: controller.toggleUI,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (thumb.isNotEmpty)
            Image.network(
              thumb,
              fit: BoxFit.contain,
              cacheWidth: 600,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            )
          else
            Container(color: Colors.black),
          Obx(() {
            final ready = controller.isReady[index]?.value ?? false;
            final vc = controller.videos[index];

            if (!ready || vc == null || !vc.value.isInitialized) {
              return const SizedBox();
            }

            return Center(
              child: AspectRatio(
                aspectRatio:
                    vc.value.aspectRatio <= 0 ? 16 / 9 : vc.value.aspectRatio,
                child: VideoPlayer(vc),
              ),
            );
          }),
          Obx(() {
            final loading = controller.isLoadingVideo[index]?.value ?? false;
            final ready = controller.isReady[index]?.value ?? false;
            final playing = controller.isPlaying[index]?.value ?? false;
            final show = controller.showUI.value || !playing;

            if (loading) {
              return Center(
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.black54,
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              );
            }

            return IgnorePointer(
              ignoring: !show,
              child: AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: GestureDetector(
                  onTap: () => controller.togglePlay(index),
                  child: CircleAvatar(
                    radius: 32.r,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 38.sp,
                    ),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            final ready = controller.isReady[index]?.value ?? false;
            final show = controller.showUI.value;
            final vc = controller.videos[index];
            if (!ready || vc == null) return const SizedBox();

            return Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: !show,
                child: AnimatedOpacity(
                  opacity: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: _ProgressBar(controller: vc),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  const _ProgressBar({required this.controller});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (_, v, __) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF5045B9),
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                ),
                Row(
                  children: [
                    Text(_fmt(v.position),
                        style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                    const Spacer(),
                    Text(_fmt(v.duration),
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11.sp)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
