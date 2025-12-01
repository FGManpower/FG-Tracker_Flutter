
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' hide BarcodeFormat;


import 'package:flutter/material.dart';

import '../controller/Group_Controller.dart';
import '../controller/JoinGroup_Controller.dart';


class QRScanController extends GetxController {
  QRViewController? qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final groupController = Get.find<GroupController>();

  final joinGroupController = Get.find<JoinGroupController>();

  var isFlashOn = false.obs;
  var isProcessing = false.obs;
  var hasScanned = false.obs;

  @override
  void onClose() {
    qrController?.dispose();
    super.onClose();
  }

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    qrController = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.format == BarcodeFormat.qrcode && !hasScanned.value) {
        hasScanned.value = true;

        final scannedCode = scanData.code;
        if (scannedCode != null) {
          await qrController?.pauseCamera();
          await processJoin(context, scannedCode);
        }

        await Future.delayed(const Duration(seconds: 1));
        hasScanned.value = false;
      }
    });
  }


  Future<void> processJoin(BuildContext context, String code) async {
    try {
      isProcessing.value = true;

      // await joinGroupController.joinGroup(
      //   context,
      //   type: "Qr",
      //   groupController: groupController,
      //   groupCode: code,
      //   validateForm: false,
      // );
      //
      // groupController.handleJoinGroup(code);
      Get.back();
    } finally {
      isProcessing.value = false;
    }
  }


  Future<void> toggleFlash() async {
    await qrController?.toggleFlash();
    isFlashOn.value = await qrController?.getFlashStatus() ?? false;
  }


  Future<void> decodeFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final barcodeScanner = BarcodeScanner();
    final input = InputImage.fromFilePath(image.path);

    final barcodes = await barcodeScanner.processImage(input);

    for (var code in barcodes) {
      if (code.rawValue != null && !isProcessing.value) {
        await processJoin(context, code.rawValue!);
        break;
      }
    }
    await barcodeScanner.close();
  }
}
