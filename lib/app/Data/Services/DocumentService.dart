import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  static final RxSet<String> downloadedDocuments = <String>{}.obs;

  static final Map<String, String> downloadedFilePaths = {};

  static final RxSet<String> downloadingDocuments = <String>{}.obs;

  static bool isDownloaded(String url) {
    final filePath = downloadedFilePaths[url];

    return downloadedDocuments.contains(url) &&
        filePath != null &&
        File(filePath).existsSync();
  }

  static bool isDownloading(String url) {
    return downloadingDocuments.contains(url);
  }

  Future<void> openDocument(String documentUrl) async {
    if (documentUrl.trim().isEmpty) return;

    if (downloadingDocuments.contains(documentUrl)) return;

    try {
      if (isDownloaded(documentUrl)) {
        final filePath = downloadedFilePaths[documentUrl]!;

        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          log("Unable to open file: ${result.message}");
        }

        return;
      }

      downloadedFilePaths.remove(documentUrl);
      downloadedDocuments.remove(documentUrl);

      downloadingDocuments.add(documentUrl);

      final directory = await getApplicationDocumentsDirectory();

      final uri = Uri.parse(documentUrl);
      final filename = uri.pathSegments.isNotEmpty
          ? Uri.decodeComponent(uri.pathSegments.last)
          : 'document';

      final safeFilename = filename.replaceAll(
        RegExp(r'[^\w.\-]'),
        '_',
      );

      final filePath =
          '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_$safeFilename';

      final response = await Dio().download(
        documentUrl,
        filePath,
        options: Options(
          followRedirects: true,
          validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
        ),
      );

      final file = File(filePath);

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300 ||
          !await file.exists() ||
          await file.length() == 0) {
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception('Document download failed');
      }

      downloadedFilePaths[documentUrl] = filePath;
      downloadedDocuments.add(documentUrl);

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        log("Unable to open file: ${result.message}");
      }
    } catch (e, stackTrace) {
      log(
        "Document Open Error => $e",
        stackTrace: stackTrace,
      );
    } finally {
      downloadingDocuments.remove(documentUrl);
    }
  }
}