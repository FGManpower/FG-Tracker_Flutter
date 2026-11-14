import 'dart:io';
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

  /// Pick an image from Camera or Gallery and save to sandboxed app documents
  static Future<File?> pickAndSaveBanner(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1440,
        maxHeight: 720,
      );

      if (pickedFile == null) return null;

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
      final savedFile = await File(pickedFile.path).copy(targetPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, savedFile.path);

      return savedFile;
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

