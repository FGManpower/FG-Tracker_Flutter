import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

      final dir =
      await path_provider.getTemporaryDirectory();

      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result =
      await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 85,
        minWidth: 720,
        minHeight: 720,
      );

      return result != null
          ? File(result.path)
          : File(image.path);
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(
          minutes: 5,
        ),
      );

      if (video == null) return null;

      return File(video.path);
    } catch (e) {
      return null;
    }
  }

  Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
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
        ],
      );

      if (result == null ||
          result.files.single.path == null) {
        return null;
      }

      return File(
        result.files.single.path!,
      );
    } catch (e) {
      return null;
    }
  }
}