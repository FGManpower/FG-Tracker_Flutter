import 'package:fgtracker/l10n/l10n.dart';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../Core/constant/const_res.dart';
import '../../Core/values/Utils.dart';
import 'media_availability_service.dart';

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
    final cleanUrl = documentUrl.trim();
    if (cleanUrl.isEmpty) return;

    final String fullUrl = cleanUrl.startsWith("http://") || cleanUrl.startsWith("https://")
        ? cleanUrl
        : "${ConstRes.aImageBaseUrl}${cleanUrl.replaceFirst(RegExp(r'^/+'), '')}";

    if (downloadingDocuments.contains(fullUrl)) return;

    try {
      if (isDownloaded(fullUrl)) {
        final filePath = downloadedFilePaths[fullUrl]!;

        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          log("Unable to open file: ${result.message}");
        }

        return;
      }

      downloadedFilePaths.remove(fullUrl);
      downloadedDocuments.remove(fullUrl);

      downloadingDocuments.add(fullUrl);

      final directory = await getApplicationDocumentsDirectory();

      final uri = Uri.parse(fullUrl);
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
        fullUrl,
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

      downloadedFilePaths[fullUrl] = filePath;
      downloadedDocuments.add(fullUrl);

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        log("Unable to open file: ${result.message}");
      }
    } catch (e, stackTrace) {
      log(
        "Document Open Error => $e",
        stackTrace: stackTrace,
      );
      final statusCode = e is DioException ? e.response?.statusCode : null;
      if (MediaAvailabilityService.isMissingStatusCode(statusCode)) {
        // The bubble listens to this and switches to "Media is missing".
        MediaAvailabilityService.markMissing(fullUrl);
        Utils().fluttertoast(appL10n.chat_mediaMissingToast);
      } else {
        Utils().fluttertoast(appL10n.chat_documentOpenFailed);
      }
    } finally {
      downloadingDocuments.remove(fullUrl);
    }
  }
}