import 'dart:io';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of asking for the camera before taking a banner photo.
enum BannerCameraAccess {
  granted,

  /// Refused this time; the system can ask again next tap (Android).
  denied,

  /// The system won't ask again: Android "Don't allow" twice / "Don't ask
  /// again", iOS after the first refusal, or blocked by parental controls
  /// (`restricted`). Only app Settings can turn it on.
  blocked,
}

class LocalBannerService {
  static const String _prefKey = 'local_custom_banner_path';
  static final ImagePicker _picker = ImagePicker();

  /// True from opening the camera / gallery until the cropped photo is saved
  /// (or cancelled). Camera and cropper are separate native screens; between
  /// them the app resumes on Home. Home skips its resume work (permission +
  /// location check) while this is true and runs it once when it turns
  /// false, so the cropper opens straight after the photo.
  static final ValueNotifier<bool> pickInProgress = ValueNotifier(false);

  /// Camera permission for the banner photo, Android and iOS.
  ///
  /// Android declares CAMERA in the manifest, so the camera intent fails
  /// (`camera_access_denied`) unless it is granted first. iOS needs
  /// NSCameraUsageDescription (Info.plist) and PERMISSION_CAMERA=1 (Podfile),
  /// both present. Asks only when the system still can.
  static Future<BannerCameraAccess> ensureCameraPermission({
    bool retry = false,
  }) =>
      _ensure(Permission.camera, retry: retry);

  /// Shared camera / photos flow. [retry] = the user tapped "Allow" in our
  /// dialog after refusing once.
  static Future<BannerCameraAccess> _ensure(
    Permission permission, {
    required bool retry,
  }) async {
    PermissionStatus status;
    try {
      status = await permission.status;
    } catch (_) {
      // Can't read the status: let the picker try (its own error is handled).
      return BannerCameraAccess.granted;
    }
    if (status.isGranted || status.isLimited) return BannerCameraAccess.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return BannerCameraAccess.blocked;
    }

    // Our dialog has just closed: give the activity / view controller a
    // moment to be in front again, or some phones drop the system popup.
    if (retry) await Future<void>.delayed(const Duration(milliseconds: 350));

    // "A request for permissions is already running" (e.g. another screen
    // is asking): wait and try once more instead of failing silently.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        status = await permission.request();
        break;
      } catch (_) {
        if (attempt == 1) return BannerCameraAccess.blocked;
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }

    if (status.isGranted || status.isLimited) return BannerCameraAccess.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return BannerCameraAccess.blocked;
    }
    // Still "denied" after the user asked us to ask again: the system did
    // not show its popup (some Android skins, e.g. MIUI, block repeat
    // requests). Only Settings can help now; never loop the same dialog.
    return retry ? BannerCameraAccess.blocked : BannerCameraAccess.denied;
  }

  /// Photo access for the banner photo.
  ///
  /// iOS: asks for Photos (NSPhotoLibraryUsageDescription + PERMISSION_PHOTOS
  /// are set); "Limited" counts as allowed.
  /// Android: always allowed. image_picker opens the system Photo Picker,
  /// which needs no permission (the user picks the photo); the manifest has
  /// no READ_MEDIA_IMAGES on purpose (Google Play photo/video policy).
  static Future<BannerCameraAccess> ensureGalleryPermission({
    bool retry = false,
  }) async {
    if (!Platform.isIOS) return BannerCameraAccess.granted;
    return _ensure(Permission.photos, retry: retry);
  }

  static Future<bool> isGalleryGranted() async {
    if (!Platform.isIOS) return true;
    try {
      final s = await Permission.photos.status;
      return s.isGranted || s.isLimited;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openSettings() => openAppSettings();

  /// Status only, never shows the system popup (used after Settings).
  static Future<bool> isCameraGranted() async {
    try {
      final s = await Permission.camera.status;
      return s.isGranted || s.isLimited;
    } catch (_) {
      return false;
    }
  }

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
    pickInProgress.value = true;
    lastAccessDenied = null;
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
    } on PlatformException catch (e) {
      // The picker itself refused (camera / photos off in system settings).
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        lastAccessDenied = source;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      // On an access error the screen shows a dialog first and clears the
      // flag itself, so Home's resume check can't cover that dialog.
      if (lastAccessDenied == null) pickInProgress.value = false;
    }
  }

  /// Set when the last [pickAndSaveBanner] returned null because the camera
  /// or photo library was refused by the system (not a user cancel). The
  /// screen reads it once and resets it to null.
  static ImageSource? lastAccessDenied;

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
