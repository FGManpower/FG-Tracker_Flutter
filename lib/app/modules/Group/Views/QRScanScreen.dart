import 'dart:ui';
import 'package:fgtracker/app/modules/Group/Controller/JoinGroup_Controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart' as qrplus;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

import '../Controller/Group_Controller.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';


class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final groupController = Get.put(GroupController());
  final joinGroupCtr = Get.put(JoinGroupController());

  bool isFlashOn = false;
  bool isProcessing = false;
  bool _hasScanned = false;
  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();

    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.format == qrplus.BarcodeFormat.qrcode) {
        _hasScanned = true;

        final scannedCode = scanData.code;
        if (scannedCode != null) {
          print("Scanned QR Code: $scannedCode");

          await controller.pauseCamera();

          // Call join group logic
          await joinGroupCtr.joinGroup(
            context,
            groupController: groupController,
            groupCode: scannedCode,
            validateForm: false,
            type: "Qr"
          );

          groupController.handleJoinGroup(scannedCode);

          Navigator.pop(context); // Close scanner screen

          // Optional: wait a bit before unlocking scan again (if needed)
          await Future.delayed(Duration(milliseconds: 500));
        }

        _hasScanned = false; // Unlock for future scans
      }
    });
  }


  /// Handle QR code from gallery image
  Future<void> decodeQRCodeFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);
      for (final barcode in barcodes) {
        final groupCode = barcode.rawValue;
        if (groupCode != null && !isProcessing) {
          setState(() {
            isProcessing = true;
          });

          print("QR from Gallery: $groupCode");

          await joinGroupCtr.joinGroup(context,
              type: "Qr",
              groupController: groupController,
              groupCode: groupCode,
              validateForm: false);

          Navigator.pop(context);

          setState(() {
            isProcessing = false;
          });

          break; // Exit after first successful scan
        }
      }
      await barcodeScanner.close();
    }
  }

  void _toggleFlash() async {
    await controller?.toggleFlash();
    bool? current = await controller?.getFlashStatus();
    setState(() {
      isFlashOn = current ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,

            overlay: QrScannerOverlayShape(
              borderColor: Colors.blueAccent,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,


              // cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
            cameraFacing: CameraFacing.back,
            formatsAllowed: [qrplus.BarcodeFormat.qrcode],

          ),

          // Glass Effect Controls
          Positioned(
            top: 40,
            left: 20,
            child: _glassButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: _glassButton(
              icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
              onTap: _toggleFlash,
            ),
          ),


          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Align the QR code in the box to join a group',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
