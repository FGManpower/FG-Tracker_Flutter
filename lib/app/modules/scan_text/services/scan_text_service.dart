import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fgtracker/app/Core/util/app_log.dart';
import 'package:fgtracker/app/Core/values/Context_Utility.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/modules/scan_text/views/live_scan_camera_screen.dart';
import 'package:fgtracker/app/modules/scan_text/views/scan_text_result_screen.dart';
import 'package:fgtracker/gen/fonts.gen.dart';

class ScanTextService {
  ScanTextService._();
  static final ScanTextService instance = ScanTextService._();

  final ImagePicker _picker = ImagePicker();
  bool _isScanningDialogOpen = false;

  /// Opens the full-screen live camera text scanner
  Future<String?> openCameraScanner({bool isForChatSelection = false}) async {
    return await Get.to<String>(
      () => LiveScanCameraScreen(isForChatSelection: isForChatSelection),
      transition: Transition.rightToLeft,
    );
  }

  /// Starts the chat scan text flow using the live camera scanner:
  /// Opens the live camera scanner with yellow reticle [  ], torch, and Insert button.
  /// When user taps Send, recognized text is returned to ChatInputArea and sent as a normal message.
  Future<String?> startChatScanFlow([BuildContext? context]) async {
    return await openCameraScanner(isForChatSelection: true);
  }

  /// Bottom sheet to choose between Camera or Gallery
  Future<ImageSource?> selectScanSource([BuildContext? context]) async {
    final ctx = (context != null && context.mounted)
        ? context
        : (ContextUtility.context ?? Get.overlayContext ?? Get.context);
    if (ctx == null) return null;

    return await showModalBottomSheet<ImageSource>(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grab handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.document_scanner_rounded,
                        color: const Color(0xFF5D47F1),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Scan Text",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontFamily: FontFamily.interBold,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E202B),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Select photo source to scan text",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: FontFamily.interRegular,
                              color: const Color(0xFF7A7F93),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildSourceTile(
                  icon: Icons.camera_alt_rounded,
                  title: "Take Photo with Camera",
                  subtitle: "Capture photo of document, paper, book or screen",
                  onTap: () {
                    Navigator.pop(bottomSheetContext, ImageSource.camera);
                  },
                ),
                SizedBox(height: 10.h),
                _buildSourceTile(
                  icon: Icons.photo_library_rounded,
                  title: "Choose from Gallery",
                  subtitle: "Select any existing photo from your device",
                  onTap: () {
                    Navigator.pop(bottomSheetContext, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows bottom sheet with options: Camera or Gallery
  Future<void> showScanSourceSheet([BuildContext? context]) async {
    final source = await selectScanSource(context);
    if (source != null) {
      if (context != null && !context.mounted) return;
      startScanFlow(source, context: context, isForChat: false);
    }
  }

  Widget _buildSourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2DCF3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: const Color(0xFF5D47F1), size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontFamily: FontFamily.interSemiBold,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E202B),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontFamily: FontFamily.interRegular,
                      color: const Color(0xFF7A7F93),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF7E69F7),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Captures an image from Camera or Gallery, shows scanning loader, and extracts text.
  /// Returns the extracted text string, or null if cancelled / no text found.
  Future<String?> captureAndExtractText(
    ImageSource source, {
    BuildContext? context,
    bool preferHindi = false,
  }) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog(
            "Camera permission permanently denied. Please allow camera in Settings.",
            openSettings: true,
          );
          return null;
        }
        if (!status.isGranted) {
          final req = await Permission.camera.request();
          if (req.isPermanentlyDenied) {
            _showPermissionDeniedDialog(
              "Camera permission permanently denied. Please allow camera in Settings.",
              openSettings: true,
            );
            return null;
          } else if (!req.isGranted) {
            Utils().fluttertoast(
              "Camera permission denied. Please allow camera access to scan text.",
            );
            return null;
          }
        }
      }

      XFile? pickedFile;
      try {
        pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 100,
        );
      } catch (e) {
        AppLog.e('ImagePicker pickImage error: $e');
        if (e.toString().toLowerCase().contains("camera_access_denied") ||
            e.toString().toLowerCase().contains("permission")) {
          Utils().fluttertoast(
            "Camera permission denied. Please allow camera in Settings.",
          );
        }
        return null;
      }

      if (pickedFile == null) {
        // User cancelled without taking/picking a photo
        return null;
      }

      final String capturedImagePath = pickedFile.path;

      // Show "Scanning..." loading dialog
      _showScanningDialog();

      final recognizedText = await extractTextFromImage(
        capturedImagePath,
        preferHindi: preferHindi,
      );

      // Dismiss scanning loading dialog
      _dismissScanningDialog();

      final trimmed = recognizedText.trim();
      if (trimmed.isEmpty) {
        Utils().fluttertoast("No text found, try again with clear photo");
        return null;
      }

      return trimmed;
    } catch (e, stack) {
      AppLog.e('Error during capture and extract text: $e', stackTrace: stack);
      _dismissScanningDialog();
      Utils().fluttertoast("No text found, try again with clear photo");
      return null;
    }
  }

  /// Initiates image pick, scanning, and navigates to result screen
  Future<void> startScanFlow(
    ImageSource source, {
    BuildContext? context,
    bool isForChat = false,
  }) async {
    final text = await captureAndExtractText(source, context: context);
    if (text != null && text.isNotEmpty) {
      Get.to(
        () => ScanTextResultScreen(
          scannedText: text,
          isForChat: isForChat,
        ),
        transition: Transition.rightToLeft,
      );
    }
  }

  /// Crops an image to the central reticle zone (with generous safe margin)
  /// to eliminate background desk, keyboard, monitor bezel, and surrounding noise.
  Future<String> cropImageToViewfinder(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return imagePath;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return imagePath;

      final original = img.decodeImage(bytes);
      if (original == null) return imagePath;

      // Ensure orientation is right-side up
      final oriented = img.bakeOrientation(original);

      // Crop the central 82% width and central 60% height
      final cropW = (oriented.width * 0.82).round();
      final cropH = (oriented.height * 0.60).round();
      final cropX = ((oriented.width - cropW) / 2).round().clamp(0, oriented.width - 1);
      final cropY = ((oriented.height - cropH) / 2).round().clamp(0, oriented.height - 1);

      final cropped = img.copyCrop(
        oriented,
        x: cropX,
        y: cropY,
        width: cropW.clamp(1, oriented.width - cropX),
        height: cropH.clamp(1, oriented.height - cropY),
      );

      final croppedPath = imagePath.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '_cropped.jpg');
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));

      return croppedPath;
    } catch (e) {
      AppLog.e("Error cropping image to viewfinder: $e");
      return imagePath;
    }
  }

  /// Extracts text from image supporting both English (Latin) and Hindi (Devanagari).
  /// Latin recognizer runs primarily to ensure 100% crisp English, code, numbers, and symbols
  /// without hallucinating Hindi matras or Devanagari ligatures on English text.
  /// If significant Hindi text is detected (>= 8 Devanagari characters), Devanagari model is used.
  Future<String> extractTextFromImage(
    String imagePath, {
    bool preferHindi = false,
  }) async {
    final file = File(imagePath);
    if (!file.existsSync()) return '';

    final inputImage = InputImage.fromFilePath(imagePath);

    if (preferHindi) {
      final hindiText = await _tryDevanagariRecognition(inputImage);
      if (hindiText.isNotEmpty) return _cleanOcrText(hindiText);
      final latinText = await _tryLatinRecognition(inputImage);
      return _cleanOcrText(latinText);
    }

    // 1. Primary: Run Latin Recognizer (Google ML Kit Latin model).
    // Provides 100% crisp English recognition without hallucinating Hindi letters/matras on English text.
    final latinText = await _tryLatinRecognition(inputImage);

    // 2. Check for Hindi text using Devanagari model
    final devanagariText = await _tryDevanagariRecognition(inputImage);
    final int hindiMatches = RegExp(r'[\u0900-\u097F]').allMatches(devanagariText).length;

    // A real Hindi document or sentence contains multiple Devanagari characters (at least 8+).
    // 1-2 stray matches are typically optical noise/glare on English screens, not genuine Hindi text.
    if (hindiMatches >= 8) {
      return _cleanOcrText(devanagariText);
    }

    // If no significant Hindi is present, use clean Latin text
    if (latinText.isNotEmpty) {
      return _cleanOcrText(latinText);
    }

    if (devanagariText.isNotEmpty) {
      return _cleanOcrText(devanagariText);
    }

    return '';
  }

  String _cleanOcrText(String raw) {
    if (raw.trim().isEmpty) return '';
    final lines = raw.split('\n');
    final cleaned = <String>[];
    bool lastEmpty = false;

    for (var line in lines) {
      var trimmed = line.trim();

      // Strip leading artifact symbols (e.g. '|When', '•Text', '~Word', '¬Line')
      trimmed = trimmed.replaceFirst(RegExp(r'^[|~^•°_¬«»§\\\/]+\s*'), '');

      // Strip trailing artifact symbols
      trimmed = trimmed.replaceFirst(RegExp(r'\s*[|~^•°_¬«»§\\\/]+$'), '');

      // If line is empty after stripping:
      if (trimmed.isEmpty) {
        if (!lastEmpty && cleaned.isNotEmpty) {
          cleaned.add('');
          lastEmpty = true;
        }
        continue;
      }

      // Discard lines that contain NO letters or numbers (pure noise/borders like '-----' or '***')
      final hasLetterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(trimmed);
      if (!hasLetterOrDigit) {
        continue;
      }

      // Discard stray 1-character glitch lines (e.g. lonely consonants like 'o', 'v', 'W')
      if (trimmed.length == 1 && !RegExp(r'[0-9aAI]').hasMatch(trimmed)) {
        continue;
      }

      cleaned.add(trimmed);
      lastEmpty = false;
    }

    return cleaned.join('\n').trim();
  }

  Future<String> _tryLatinRecognition(InputImage inputImage) async {
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      AppLog.e('Latin recognition error: $e');
      return '';
    } finally {
      try {
        await recognizer?.close();
      } catch (_) {}
    }
  }

  Future<String> _tryDevanagariRecognition(InputImage inputImage) async {
    TextRecognizer? recognizer;
    try {
      recognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      AppLog.e('Devanagari recognition error: $e');
      return '';
    } finally {
      try {
        await recognizer?.close();
      } catch (_) {}
    }
  }

  void _showScanningDialog() {
    _isScanningDialogOpen = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 26.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 28.w,
                      height: 28.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF5D47F1)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  "Scanning...",
                  style: TextStyle(
                    fontSize: 16.5.sp,
                    fontFamily: FontFamily.interBold,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E202B),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "Extracting text from image...",
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontFamily: FontFamily.interRegular,
                    color: const Color(0xFF7A7F93),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _dismissScanningDialog() {
    if (_isScanningDialogOpen) {
      _isScanningDialogOpen = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  void _showPermissionDeniedDialog(
    String message, {
    bool openSettings = false,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Permission Required",
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: FontFamily.interBold,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: FontFamily.interRegular,
            color: const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) Get.back();
            },
            child: const Text("Cancel"),
          ),
          if (openSettings)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D47F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                if (Get.isDialogOpen == true) Get.back();
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
        ],
      ),
    );
  }
}
