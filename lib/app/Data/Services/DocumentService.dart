import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  Future<void> openDocument(String documentUrl) async {
    try {
      final directory =
      await getTemporaryDirectory();

      final extension =
          documentUrl.split('.').last;

      final filePath =
          "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$extension";

      await Dio().download(
        documentUrl,
        filePath,
      );

      final result =
      await OpenFile.open(filePath);

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