import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Views/Group/media_links_docs_screen.dart';

class MediaLinksDocsController extends GetxController {
  List<MessageData> allMessages = [];

  final mediaList = <MessageData>[].obs;
  final docList = <MessageData>[].obs;
  final linkList = <MessageData>[].obs;

  MediaLinksDocsController({List<MessageData>? initialMessages}) {
    if (initialMessages != null && initialMessages.isNotEmpty) {
      allMessages = initialMessages;
      filterMessages();
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (allMessages.isEmpty) {
      final args = Get.arguments;
      if (args is List<MessageData>) {
        allMessages = args;
      } else if (args is Map && args["mediaMessages"] is List<MessageData>) {
        allMessages = List<MessageData>.from(args["mediaMessages"]);
      }
      filterMessages();
    }
  }

  void filterMessages() {
    mediaList.value = allMessages.where((m) {
      final t = (m.messageType ?? "").toLowerCase();
      return t == "image" || t == "video" || t == "image_text";
    }).toList();

    docList.value = allMessages.where((m) {
      return (m.messageType ?? "").toLowerCase() == "document";
    }).toList();

    linkList.value = allMessages.where((m) {
      final t = (m.messageType ?? "").toLowerCase();
      if (t == "link") return true;
      if (t == "text" || t == "link_text") {
        return MediaHelper.extractUrl(m.content ?? "").isNotEmpty;
      }
      if (t != "image" &&
          t != "video" &&
          t != "image_text" &&
          t != "document") {
        return MediaHelper.extractUrl(m.content ?? "").isNotEmpty;
      }
      return false;
    }).toList();
  }

  void openImageGallery(int indexInMedia) {
    final images = mediaList.where((m) => !MediaHelper.isVideo(m)).toList();
    if (images.isEmpty) return;

    final tapped = mediaList[indexInMedia];
    int imgIndex = images.indexWhere((e) => e == tapped);
    if (imgIndex < 0) imgIndex = 0;

    Get.to(
          () => ImageGalleryScreen(images: images, initialIndex: imgIndex),
      transition: Transition.fadeIn,
      opaque: false,
    );
  }

  void openVideo(MessageData m) {
    final url = MediaHelper.fileUrl(m);
    if (url.isEmpty) {
      Utils().fluttertoast("Video not found");
      return;
    }

    Get.toNamed(
      Routes.videoPlayerScreen,
      arguments: {
        "videoUrl": url,
      },
    );
  }

  void openDocument(MessageData m) {
    final url = MediaHelper.fileUrl(m);
    final name = MediaHelper.fileName(m);
    if (url.isEmpty) {
      Utils().fluttertoast("Document not found");
      return;
    }

    Get.toNamed(
      Routes.documentViewerScreen,
      arguments: {
        "documentUrl": url,
        "documentName": name,
      },
    );
  }

  Future<void> openLink(MessageData m) async {
    final url = MediaHelper.linkUrl(m);
    await MediaHelper.launchExternal(url);
  }

  void onMediaTap(int index) {
    final m = mediaList[index];
    if (MediaHelper.isVideo(m)) {
      openVideo(m);
    } else {
      openImageGallery(index);
    }
  }
}


class MediaHelper {
  static bool isVideo(MessageData m) =>
      (m.messageType ?? "").toLowerCase() == "video";

  static String fileUrl(MessageData m) {
    final content = (m.content ?? "").trim();
    if (content.isEmpty) return "";
    final path = content.split("||").first.trim();
    if (path.isEmpty) return "";
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
    if (p.isEmpty) return "";
    if (p.startsWith("http")) return p;
    return "${ConstRes.aImageBaseUrl}$p";
  }

  static String fileName(MessageData m) {
    final p = (m.content ?? "").split("||").first;
    final n = p.split('/').last;
    return n.isEmpty ? "Document" : n;
  }

  static String extractUrl(String text) {
    final reg = RegExp(
      r'(https?:\/\/[^\s]+)|(www\.[^\s]+)',
      caseSensitive: false,
    );
    final match = reg.firstMatch(text);
    if (match == null) return "";
    var url = match.group(0) ?? "";
    if (url.startsWith("www.")) url = "https://$url";
    return url;
  }

  static String linkUrl(MessageData m) {
    final t = (m.messageType ?? "").toLowerCase();
    final content = m.content ?? "";
    if (t == "link") {
      final p = content.split("||").first.trim();
      if (p.startsWith("http") || p.startsWith("www.")) {
        return p.startsWith("www.") ? "https://$p" : p;
      }
      if (p.isNotEmpty) return p.startsWith("http") ? p : "https://$p";
    }
    return extractUrl(content);
  }

  static String linkHost(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return "";
    }
  }

  static Future<void> launchExternal(String url) async {
    if (url.isEmpty) {
      Utils().fluttertoast("Invalid link");
      return;
    }
    var u = url.trim();
    if (u.startsWith("www.")) u = "https://$u";
    final uri = Uri.tryParse(u);
    if (uri == null) {
      Utils().fluttertoast("Cannot open");
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) Utils().fluttertoast("Cannot open");
    } catch (_) {
      Utils().fluttertoast("Cannot open");
    }
  }
}