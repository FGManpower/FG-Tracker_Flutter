import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';


class FileServices {
  final ImagePicker _picker = ImagePicker();

  Future<List<File>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isEmpty) return [];

      final dir = await path_provider.getTemporaryDirectory();

      final futures = images.asMap().entries.map((entry) async {
        final index = entry.key;
        final image = entry.value;

        final targetPath =
            '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$index.jpg';

        final result = await FlutterImageCompress.compressAndGetFile(
          image.path,
          targetPath,
          quality: 85,
          minWidth: 720,
          minHeight: 720,
        );

        return result != null ? File(result.path) : File(image.path);
      });

      return await Future.wait(futures);
    } catch (e) {
      log("Image Picker Error: $e");
      return [];
    }
  }

  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) {
        return null;
      }

      final file = File(video.path);

      return file;
    } catch (e) {
      return null;
    }
  }

  Future<File?> retrieveLostVideo() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return null;
      if (response.file != null) {
        final file = File(response.file!.path);
        if (await file.exists()) return file;
      }
      if (response.exception != null) {
        debugPrint("Lost data exception: ${response.exception}");
      }
      return null;
    } catch (e) {
      debugPrint("retrieveLostData error: $e");
      return null;
    }
  }

  Future<List<XFile>> pickMultipleMediaFromGallery() async {
    try {
      final ImagePickerPlatform impl = ImagePickerPlatform.instance;
      if (impl is ImagePickerAndroid) {
        impl.useAndroidPhotoPicker = true;
      }

      final picker = ImagePicker();
      final media = await picker.pickMultipleMedia(imageQuality: 80);

      for (var f in media) {
        final ext = f.path.split('.').last;
        log("File: ${f.path} | Ext: $ext");
      }

      return media;
    } catch (e) {
      return [];
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
          'zip',
          'rar',
          '7z',
        ],
      );

      if (result != null && result.files.single.path != null) {
        return File(
          result.files.single.path!,
        );
      }
      return null;
    } catch (e) {
      log(
        "Document Picker Error: $e",
      );
      return null;
    }
  }
}
