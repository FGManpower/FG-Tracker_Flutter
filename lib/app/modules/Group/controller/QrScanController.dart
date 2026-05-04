import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/material.dart';

import '../controller/Group_Controller.dart';
import '../controller/JoinGroup_Controller.dart';

class QRScanController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();

  late GroupController groupController;
  late JoinGroupController joinController;

  var isFlashOn = false.obs;
  var isProcessing = false.obs;
  var hasScanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    groupController = Get.find<GroupController>();
    joinController = Get.find<JoinGroupController>();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void onCodeScanned(String code, BuildContext context) async {
    if (!hasScanned.value && !isProcessing.value) {
      hasScanned.value = true;
      await processJoin(context, code);
      await Future.delayed(const Duration(seconds: 1));
      hasScanned.value = false;
    }
  }

  Future<void> processJoin(BuildContext context, String code) async {
    try {
      isProcessing.value = true;
      final bool isJoined = await joinController.joinGroup(
        context,
        type: "Qr",
        groupController: groupController,
        groupCode: code,
        validateForm: false,
      );
      if (isJoined) {
        groupController.getGroupData();
        Get.back();
      } else {
        hasScanned.value = false;
      }
    } catch (e) {
      hasScanned.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> toggleFlash() async {
    await scannerController.toggleTorch();
    isFlashOn.value = !isFlashOn.value;
  }

  Future<void> decodeFromGallery(BuildContext context) async {
    if (isProcessing.value) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    isProcessing.value = true;
    final barcodeScanner = BarcodeScanner();
    final input = InputImage.fromFilePath(image.path);
    try {
      final barcodes = await barcodeScanner.processImage(input);
      for (var code in barcodes) {
        if (code.rawValue != null) {
          await processJoin(context, code.rawValue!);
          break;
        }
      }
    } finally {
      await barcodeScanner.close();
      isProcessing.value = false;
    }
  }
}