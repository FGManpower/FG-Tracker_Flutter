import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class FileServices {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return null;

      final dir = await path_provider.getTemporaryDirectory();

      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 85,
        minWidth: 720,
        minHeight: 720,
      );

      return result != null ? File(result.path) : File(image.path);
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickVideoFromGallery() async {
    try {


      final picker = ImagePicker();

      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      debugPrint("Video = $video");

      if (video != null) {
        debugPrint("Path = ${video.path}");
        debugPrint("Name = ${video.name}");

        final file = File(video.path);

        debugPrint("Exists = ${await file.exists()}");
      }

      if (video == null) {
        return null;
      }

      final file = File(video.path);

      if (!await file.exists()) {
        debugPrint("Selected video does not exist");
        return null;
      }

      return file;
    } catch (e) {
      debugPrint("Video Picker Error: $e");
      return null;
    }
  }

  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'csv',
        ],
      );

      if (result != null && result.files.single.path != null) {
        return File(
          result.files.single.path!,
        );
      }

      return null;
    } catch (e) {
      print(
        "Document Picker Error: $e",
      );
      return null;
    }
  }
}
