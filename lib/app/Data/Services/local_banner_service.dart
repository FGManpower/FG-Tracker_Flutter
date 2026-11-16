import 'dart:io';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBannerService {
  static const String _prefKey = 'local_custom_banner_path';
  static final ImagePicker _picker = ImagePicker();

  /// Retrieve the locally saved banner file if it exists
  static Future<File?> getLocalBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_prefKey);
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          return file;
        } else {
          await prefs.remove(_prefKey);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Pick an image from Camera or Gallery and save to sandboxed app documents.
  ///
  /// With [cropAspectRatio] (banner width / height) the cropper opens next,
  /// locked to the banner shape, so the photo fits the banner exactly.
  /// Cancelling the crop keeps the current banner (returns null).
  static Future<File?> pickAndSaveBanner(
    ImageSource source, {
    double? cropAspectRatio,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1440,
        maxHeight: 720,
      );

      if (pickedFile == null) return null;

      var sourcePath = pickedFile.path;
      if (cropAspectRatio != null && cropAspectRatio > 0) {
        final cropped = await cropToBanner(sourcePath, cropAspectRatio);
        if (cropped == null) return null; // user cancelled the crop
        sourcePath = cropped;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final targetPath =
          '${appDir.path}/local_custom_banner_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Delete existing banner file if any
      final oldFile = await getLocalBanner();
      if (oldFile != null && await oldFile.exists()) {
        try {
          await oldFile.delete();
        } catch (_) {}
      }

      // Copy picked file to permanent app documents path
      final savedFile = await File(sourcePath).copy(targetPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, savedFile.path);

      return savedFile;
    } catch (_) {
      return null;
    }
  }

  /// Opens the cropper locked to the banner shape ([aspectRatio] = width /
  /// height). Returns the cropped file path, or null when cancelled.
  static Future<String?> cropToBanner(String path, double aspectRatio) async {
    try {
      final title = appL10n.imagePicker_cropTitle;
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: CropAspectRatio(ratioX: aspectRatio, ratioY: 1),
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.darkBlue,
            toolbarWidgetColor: Colors.white,
            statusBarLight: false,
            activeControlsWidgetColor: const Color(0xFF6B4DFF),
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );
      return cropped?.path;
    } catch (_) {
      return null;
    }
  }

  /// Delete the locally saved banner
  static Future<bool> deleteLocalBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_prefKey);
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
        await prefs.remove(_prefKey);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
