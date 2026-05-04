import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fgtracker/app/modules/Group/controller/QrScanController.dart';

class QRScanScreen extends StatelessWidget {
  final QRScanController controller = Get.find<QRScanController>();

  QRScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final code = barcode.rawValue;
              if (code != null) {
                controller.onCodeScanned(code, context);
              }
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: glassButton(Icons.arrow_back_ios_new, () => Get.back()),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Obx(() => glassButton(
              controller.isFlashOn.value
                  ? Icons.flash_on
                  : Icons.flash_off,
                  () => controller.toggleFlash(),
            )),
          ),
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Text(
              'Align QR inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(.9), fontSize: 16.sp),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: glassButton(
                Icons.photo,
                    () => controller.decodeFromGallery(context),
                size: 60,
              ),
            ),
          ),
          Obx(() => controller.isProcessing.value
              ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget glassButton(IconData icon, VoidCallback onTap, {double size = 50}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}