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

      final extension = documentUrl.split('.').last;

      final path = "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$extension";

      await Dio().download(documentUrl, path,);

      log("=========PathData=====$path");
      log("=========PathData=====$documentUrl");
      localFilePath.value = path;
    } catch (e) {
      log("===========DownloadError===${e.toString()}");
      fileExists.value = false;
      isLoading.value = false;
    } finally {
      isLoading.value = false;
      fileExists.value = false;
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