import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  static final RxSet<String> downloadedDocuments = <String>{}.obs;
  static final Map<String, String> downloadedFilePaths = {};

  static bool isDownloaded(String url) {
    return downloadedDocuments.contains(url);
  }

  Future<void> openDocument(String documentUrl) async {
    try {
      final directory = await getTemporaryDirectory();

      if (downloadedFilePaths.containsKey(documentUrl)) {
        final filePath = downloadedFilePaths[documentUrl]!;

        if (await File(filePath).exists()) {
          await OpenFile.open(filePath);
          return;
        }

        downloadedFilePaths.remove(documentUrl);
        downloadedDocuments.remove(documentUrl);
      }

      final extension = documentUrl.split('.').last.split('?').first;

      final filePath =
          "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$extension";

      await Dio().download(
        documentUrl,
        filePath,
      );

      downloadedFilePaths[documentUrl] = filePath;
      downloadedDocuments.add(documentUrl);

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        log(
          "Unable to open file: ${result.message}",
        );
      }
    } catch (e) {
      log(
        "Document Open Error => $e",
      );
    }
  }
}
