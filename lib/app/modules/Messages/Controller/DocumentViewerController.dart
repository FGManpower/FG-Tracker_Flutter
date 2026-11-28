import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';


class DocumentViewerController extends GetxController {
  final isLoading = true.obs;
  final localFilePath = ''.obs;
  final fileExists = true.obs;
  late String documentUrl;
  late String documentName;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    documentUrl = args["documentUrl"] ?? "";
    documentName = args["documentName"] ?? "";
    log("=========PathData=====$documentUrl");
    log("=========PathDataName=====$documentName");

    downloadFile();
  }

  Future<void> openDocument() async {
    try {
      if (localFilePath.value.isEmpty) {
        await downloadFile();
      }
      if (localFilePath.value.isEmpty) {
        Get.snackbar("Unable to Open", "The document couldn't be downloaded.");
        return;
      }

      final result = await OpenFile.open(
        localFilePath.value,
      );

      if (result.type != ResultType.done) {
        Get.snackbar(
          "Unable to Open",
          result.message,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }
  Future<void> downloadFile() async {
    try {
      isLoading.value = true;

      final directory = await getTemporaryDirectory();

      // Extension from the URL path (a "?token=..." query used to end up
      // in it), falling back to the document name.
      String extension = "";
      final urlName = Uri.tryParse(documentUrl)?.pathSegments.lastOrNull ?? "";
      if (urlName.contains('.')) {
        extension = urlName.split('.').last;
      } else if (documentName.contains('.')) {
        extension = documentName.split('.').last;
      }

      final path = extension.isEmpty
          ? "${directory.path}/${DateTime.now().millisecondsSinceEpoch}"
          : "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$extension";

      await Dio().download(documentUrl, path,);

      log("=========PathData=====$path");
      log("=========PathData=====$documentUrl");
      localFilePath.value = path;
      fileExists.value = true;
    } catch (e) {
      log("===========DownloadError===${e.toString()}");
      // 404 etc: the file is gone; never report it as existing.
      fileExists.value = false;
    } finally {
      // Only the loader here: it used to reset fileExists to false even
      // after a successful download.
      isLoading.value = false;
    }
  }

  String get extension {
    return documentName
        .split('.')
        .last
        .toLowerCase();
  }

  bool get isPdf => extension == "pdf";

  bool get isExcel =>
      extension == "xls" ||
          extension == "xlsx";

  bool get isWord =>
      extension == "doc" ||
          extension == "docx";

  bool get isPpt =>
      extension == "ppt" ||
          extension == "pptx";
}