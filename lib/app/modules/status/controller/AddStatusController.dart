import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../views/StatusViewScreen.dart';

class AddStatusController extends GetxController with WidgetsBindingObserver {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  var isCameraReady = false.obs;
  var isRearCamera = true.obs;
  var isFlashOn = false.obs;
  var isRecording = false.obs;
  var isInitializing = true.obs;
  var error = RxnString();

  var mode = "photo".obs;
  var capturedFile = Rxn<File>();
  var isVideoFile = false.obs;

  final TextEditingController textController = TextEditingController();
  final List<Color> bgColors = [
    const Color(0xFF6B4DFF),
    const Color(0xFF1B1B50),
    const Color(0xFFE11D48),
    const Color(0xFF059669),
    const Color(0xFFD97706),
    const Color(0xFF0EA5E9),
  ];
  var selectedBgIndex = 0.obs;
  var whoCanSee = "My Team".obs;

  var recordDuration = Duration.zero.obs;
  Timer? recordTimer;

  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    recordTimer?.cancel();
    cameraController?.dispose();
    textController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
      cameraController = null;
      isCameraReady.value = false;
    } else if (state == AppLifecycleState.resumed) {
      if (mode.value != "text" && capturedFile.value == null) {
        initCamera();
      }
    }
  }

  Future<void> initCamera() async {
    isInitializing.value = true;
    error.value = null;

    try {
      final camStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (!camStatus.isGranted) {
        error.value = "Camera permission denied";
        isInitializing.value = false;
        return;
      }

      cameras = await availableCameras();
      if (cameras.isEmpty) {
        error.value = "No camera found";
        isInitializing.value = false;
        return;
      }

      final camera = isRearCamera.value
          ? cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      )
          : cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: micStatus.isGranted,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (cameraController != null) {
        await cameraController!.dispose();
      }

      cameraController = controller;
      isCameraReady.value = true;
      isInitializing.value = false;

      if (isFlashOn.value) {
        await cameraController!.setFlashMode(FlashMode.torch);
      } else {
        await cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      error.value = "Failed to open camera";
      isInitializing.value = false;
      isCameraReady.value = false;
    }
  }

  Future<void> flipCamera() async {
    if (cameras.length < 2 || isRecording.value) return;

    isInitializing.value = true;
    isCameraReady.value = false;
    isRearCamera.value = !isRearCamera.value;

    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    await initCamera();
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !isCameraReady.value) return;
    try {
      isFlashOn.value = !isFlashOn.value;
      await cameraController!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {}
  }

  Future<void> capturePhoto() async {
    if (cameraController == null ||
        !isCameraReady.value ||
        isRecording.value ||
        cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      final file = await cameraController!.takePicture();
      capturedFile.value = File(file.path);
      isVideoFile.value = false;
    } catch (_) {}
  }

  Future<void> startVideoRecording() async {
    if (cameraController == null ||
        !isCameraReady.value ||
        isRecording.value ||
        cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      isRecording.value = true;
      recordDuration.value = Duration.zero;

      recordTimer?.cancel();
      recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordDuration.value += const Duration(seconds: 1);
      });
    } catch (_) {}
  }

  Future<void> stopVideoRecording() async {
    if (cameraController == null || !isRecording.value) return;

    try {
      final file = await cameraController!.stopVideoRecording();
      recordTimer?.cancel();
      isRecording.value = false;
      capturedFile.value = File(file.path);
      isVideoFile.value = true;
    } catch (_) {
      recordTimer?.cancel();
      isRecording.value = false;
    }
  }

  Future<void> onShutterTap() async {
    if (mode.value == "photo") {
      await capturePhoto();
    } else if (mode.value == "video") {
      if (isRecording.value) {
        await stopVideoRecording();
      } else {
        await startVideoRecording();
      }
    }
  }

  Future<void> openGallery() async {
    try {
      if (mode.value == "video") {
        final picked = await picker.pickVideo(source: ImageSource.gallery);
        if (picked != null) {
          capturedFile.value = File(picked.path);
          isVideoFile.value = true;
        }
      } else {
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (picked != null) {
          capturedFile.value = File(picked.path);
          isVideoFile.value = false;
          mode.value = "photo";
        }
      }
    } catch (_) {}
  }

  void retake() {
    capturedFile.value = null;
    isVideoFile.value = false;
    textController.clear();

    if (mode.value != "text") {
      if (cameraController == null || !cameraController!.value.isInitialized) {
        initCamera();
      }
    }
  }

  void changeMode(String newMode) {
    if (isRecording.value) return;

    mode.value = newMode;
    capturedFile.value = null;
    isVideoFile.value = false;
    textController.clear();

    if (newMode == "text") {
      cameraController?.dispose();
      cameraController = null;
      isCameraReady.value = false;
    } else {
      if (!isCameraReady.value) {
        initCamera();
      }
    }
  }

  void postStatus() {
    if (mode.value == "text") {
      if (textController.text.trim().isEmpty) {
        Get.snackbar("Error", "Please write something", backgroundColor: Colors.white);
        return;
      }
    } else {
      if (capturedFile.value == null) {
        Get.snackbar("Error", "Please capture or select media", backgroundColor: Colors.white);
        return;
      }
    }

    Get.snackbar(
      "Success",
      "Status posted for ${whoCanSee.value}",
      backgroundColor: const Color(0xFF6B4DFF),
      colorText: Colors.white,
    );

    Get.back();

    Get.to(() => const StatusViewScreen(
      isOwnStatus: true,
      userName: "My Status",
      timeText: "Just now",
      caption: "New Day\nStronger Team 💪",
      location: "Hyderabad",
      viewsCount: 0,
      totalStatuses: 1,
      currentIndex: 0,
    ));
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}