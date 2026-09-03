import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Controller/media_links_docs_controller.dart';

class MediaLinksDocsScreen extends StatelessWidget {
  final List<MessageData>? mediaMessages;

  const MediaLinksDocsScreen({super.key, this.mediaMessages});

  static const Color _purple = Color(0xFF5045B9);
  static const Color _bg = Color(0xFFF5F3FB);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(
      MediaLinksDocsController(initialMessages: mediaMessages),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: _purple.withOpacity(0.1),
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Obx(() {
              final m = c.mediaList.length;
              final l = c.linkList.length;
              final d = c.docList.length;
              return TabBar(
                labelColor: _purple,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: _purple,
                indicatorWeight: 3,
                labelStyle:
                TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: m > 0 ? "Media ($m)" : "Media"),
                  Tab(text: l > 0 ? "Links ($l)" : "Links"),
                  Tab(text: d > 0 ? "Docs ($d)" : "Docs"),
                ],
              );
            }),
          ),
        ),
        body: TabBarView(
          children: [
            _MediaTab(controller: c),
            _LinksTab(controller: c),
            _DocsTab(controller: c),
          ],
        ),
      ),
    );
  }
}


class _MediaTab extends StatelessWidget {
  final MediaLinksDocsController controller;
  const _MediaTab({required this.controller});

  static const Color _purple = Color(0xFF5045B9);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.mediaList;
      if (list.isEmpty) {
        return const _Empty(
            icon: Icons.photo_library_outlined, text: "No media found");
      }
      return GridView.builder(
        padding: EdgeInsets.all(4.w),
        gridDelegate: sliverGrid,
        itemCount: list.length,
        itemBuilder: (_, i) {
          final m = list[i];
          final thumb = MediaHelper.thumb(m);
          final isVideo = MediaHelper.isVideo(m);

          return GestureDetector(
            onTap: () => controller.onMediaTap(i),
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
                        color: _purple.withOpacity(0.4),
                        size: 28.sp,
                      ),
                    )
                  else
                    Icon(
                      isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                      color: _purple.withOpacity(0.4),
                      size: 28.sp,
                    ),
                  if (isVideo)
                    Center(
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 18.sp),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  static final sliverGrid = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 4.w,
    mainAxisSpacing: 4.w,
  );
}


class _LinksTab extends StatelessWidget {
  final MediaLinksDocsController controller;
  const _LinksTab({required this.controller});

  static const Color _purple = Color(0xFF5045B9);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.linkList;
      if (list.isEmpty) {
        return const _Empty(icon: Icons.link_rounded, text: "No links found");
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (_, i) {
          final m = list[i];
          final url = MediaHelper.linkUrl(m);
          final host = MediaHelper.linkHost(url);
          return ListTile(
            onTap: () => controller.openLink(m),
            leading: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDFF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.link_rounded, color: _purple, size: 22.sp),
            ),
            title: Text(
              host.isEmpty ? url : host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
            subtitle: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
            trailing: Icon(Icons.open_in_new_rounded,
                size: 18.sp, color: Colors.grey.shade500),
          );
        },
      );
    });
  }
}


class _DocsTab extends StatelessWidget {
  final MediaLinksDocsController controller;
  const _DocsTab({required this.controller});

  static const Color _purple = Color(0xFF5045B9);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.docList;
      if (list.isEmpty) {
        return const _Empty(
            icon: Icons.insert_drive_file_outlined,
            text: "No documents found");
      }
      return ListView.builder(
        padding: EdgeInsets.all(12.w),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final m = list[i];
          final name = MediaHelper.fileName(m);
          return Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: 8.h),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              onTap: () => controller.openDocument(m),
              leading: Icon(Icons.insert_drive_file_rounded,
                  color: _purple, size: 28.sp),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
              ),
              subtitle: Text("Document", style: TextStyle(fontSize: 12.sp)),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400),
            ),
          );
        },
      );
    });
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(text,
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class ImageGalleryScreen extends StatelessWidget {
  final List<MessageData> images;
  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_ImageGalleryController(images, initialIndex));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: c.pageController,
            itemCount: images.length,
            onPageChanged: (i) => c.currentIndex.value = i,
            itemBuilder: (_, i) {
              final url = MediaHelper.fileUrl(images[i]);
              final thumb = MediaHelper.thumb(images[i]);
              return GestureDetector(
                onTap: c.toggleUI,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (thumb.isNotEmpty)
                          Image.network(thumb,
                              fit: BoxFit.contain,
                              cacheWidth: 400,
                              gaplessPlayback: true),
                        if (url.isNotEmpty)
                          Image.network(
                            url,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            loadingBuilder: (_, child, p) =>
                            p == null ? child : const SizedBox(),
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white54,
                              size: 56.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Obx(() {
            final show = c.showUI.value;
            return AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !show,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 4.h,
                      left: 12.w,
                      right: 12.w,
                      bottom: 8.h,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.delete<_ImageGalleryController>();
                            Get.back();
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                color: Colors.white, size: 20.sp),
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
                            "${c.currentIndex.value + 1}/${images.length}",
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
            );
          }),
        ],
      ),
    );
  }
}

class _ImageGalleryController extends GetxController {
  final List<MessageData> images;
  final int initialIndex;
  late final PageController pageController;
  final currentIndex = 0.obs;
  final showUI = true.obs;

  _ImageGalleryController(this.images, this.initialIndex);

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void toggleUI() => showUI.value = !showUI.value;

  @override
  void onClose() {
    pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}