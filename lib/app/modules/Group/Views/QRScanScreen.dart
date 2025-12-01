import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../controller/QrScanController.dart';



class QRScanScreen extends GetView<QRScanController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: controller.qrKey,
            onQRViewCreated: (qrController) =>
                controller.onQRViewCreated(qrController, context),
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blueAccent,
              borderRadius: 12.r,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: 280.w,
            ),
          ),

          Positioned(top: 40, left: 20, child: glassButton(
            Icons.arrow_back_ios_new, () => Get.back(),
          )),
          Positioned(top: 40, right: 20, child: Obx(() =>
              glassButton(
                controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
                    () => controller.toggleFlash(),
              ),
          )),
          Positioned(bottom: 140, left: 0, right: 0,
            child: Text(
              'Align QR inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 16.sp),
            ),
          ),

          // Gallery Button
          Positioned(bottom: 60, left: 0, right: 0, child: Center(
            child: glassButton(Icons.photo, () => controller.decodeFromGallery(context), size: 60),
          )),

          Obx(() => controller.isProcessing.value
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SizedBox.shrink()
          ),
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
                border: Border.all(color: Colors.white24)),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
