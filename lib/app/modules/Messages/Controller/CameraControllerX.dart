import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CameraControllerX extends GetxController {
  CameraController? cameraController;

  RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  RxInt selectedCameraIndex = 0.obs;

  RxBool isFlashOn = false.obs;
  RxBool isRecording = false.obs;
  RxString selectedMode = "PHOTO".obs;
  RxInt recordingSeconds = 0.obs;
  RxBool isCameraInitialized = false.obs;

  /// Why the preview can't start (shown instead of an endless spinner).
  final RxString cameraError = "".obs;

  /// Camera permission refused: the screen offers "Open Settings".
  final RxBool cameraPermissionDenied = false.obs;

  /// Microphone refused: the camera still works, videos have no sound.
  bool _audioDenied = false;

  Timer? _timer;

  bool _isSwitchingCamera = false;
  bool _isInitializingCamera = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    if (_isInitializingCamera) return;

    _isInitializingCamera = true;
    cameraError.value = "";
    cameraPermissionDenied.value = false;

    try {
      cameras.value = await availableCameras();

      if (cameras.isEmpty) {
        cameraError.value = "No camera found on this device.";
        return;
      }

      final backIndex = cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      selectedCameraIndex.value = backIndex >= 0 ? backIndex : 0;

      await _setupCamera();
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (cameraError.value.isEmpty) {
        cameraError.value = "Couldn't start the camera.";
      }
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _setupCamera() async {
    if (cameras.isEmpty) return;

    final camera = cameras[selectedCameraIndex.value];

    isCameraInitialized.value = false;

    final oldController = cameraController;
    cameraController = null;

    update();

    if (oldController != null) {
      try {
        if (oldController.value.isStreamingImages) {
          await oldController.stopImageStream();
        }
      } catch (_) {}

      try {
        if (oldController.value.isRecordingVideo) {
          await oldController.stopVideoRecording();
        }
      } catch (_) {}

      try {
        await oldController.dispose();
      } catch (e) {
        debugPrint("Old camera dispose error: $e");
      }
    }

    await Future<void>.delayed(Duration.zero);

    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      // A denied microphone used to make initialize() fail, so even photos
      // were impossible. Without the mic, start without audio.
      enableAudio: !_audioDenied,
    );

    try {
      await newController.initialize();
      cameraError.value = "";
      cameraPermissionDenied.value = false;

      if (isClosed) {
        await newController.dispose();
        return;
      }

      try {
        await newController.setFlashMode(FlashMode.off);
      } catch (_) {}

      cameraController = newController;
      isFlashOn.value = false;
      isCameraInitialized.value = true;

      update();
    } catch (e) {
      debugPrint("Camera setup error: $e");

      try {
        await newController.dispose();
      } catch (_) {}

      cameraController = null;
      isCameraInitialized.value = false;

      final code = e is CameraException ? e.code : "";
      if (code.startsWith("AudioAccess") && !_audioDenied) {
        // Retry once without audio so photos still work.
        _audioDenied = true;
        update();
        await _setupCamera();
        return;
      }
      if (code.startsWith("CameraAccess")) {
        cameraPermissionDenied.value = true;
        cameraError.value =
            "Camera access is needed to take photos and videos in chat.";
      } else {
        cameraError.value = "Couldn't start the camera.";
      }

      update();
    }
  }

  Future<void> switchCamera() async {
    if (_isSwitchingCamera) return;
    if (cameras.length < 2) return;

    // Don't switch while recording.
    if (isRecording.value) {
      return;
    }

    _isSwitchingCamera = true;

    try {
      final currentIndex = selectedCameraIndex.value;

      selectedCameraIndex.value = (currentIndex + 1) % cameras.length;

      await _setupCamera();
    } catch (e) {
      debugPrint("Switch camera error: $e");
    } finally {
      _isSwitchingCamera = false;
    }
  }

  Future<void> toggleFlash() async {
    final controller = cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        _isSwitchingCamera) {
      return;
    }

    try {
      final newFlashState = !isFlashOn.value;

      await controller.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );

      isFlashOn.value = newFlashState;
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  Future<XFile?> takePictureWithReturn() async {
    final controller = cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await controller.takePicture();
      return file;
    } catch (e) {
      debugPrint("Take picture error: $e");
      Get.snackbar("Error", "Failed to take photo");
      return null;
    }
  }

  Future<XFile?> toggleVideoRecording() async {
    final controller = cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return null;
    }

    try {
      if (isRecording.value) {
        final XFile file = await controller.stopVideoRecording();

        _timer?.cancel();
        _timer = null;

        isRecording.value = false;
        recordingSeconds.value = 0;

        return file;
      } else {
        await controller.startVideoRecording();

        isRecording.value = true;
        _startTimer();

        return null;
      }
    } catch (e) {
      debugPrint("Recording error: $e");

      _timer?.cancel();
      _timer = null;

      isRecording.value = false;
      recordingSeconds.value = 0;

      Get.snackbar("Error", "Recording failed");

      return null;
    }
  }

  void _startTimer() {
    _timer?.cancel();

    recordingSeconds.value = 0;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        recordingSeconds.value++;
      },
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timer = null;

    final controller = cameraController;
    cameraController = null;

    if (controller != null) {
      controller.dispose();
    }

    super.onClose();
  }
}
