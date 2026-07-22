import 'dart:async';
import 'package:camera/camera.dart';
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

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras.value = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Error", "No camera found");
        return;
      }
      await setupCamera();
    } catch (e) {
      print("Camera init error: $e");
      Get.snackbar("Error", "Failed to initialize camera");
    }
  }

  Future<void> setupCamera() async {
    await cameraController?.dispose();
    cameraController = CameraController(
      cameras[selectedCameraIndex.value],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await cameraController!.initialize();
      isCameraInitialized.value = true;
      update();
    } catch (e) {
      print("Camera setup error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;
    selectedCameraIndex.value =
        (selectedCameraIndex.value + 1) % cameras.length;
    await setupCamera();
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    isFlashOn.value = !isFlashOn.value;
    await cameraController!.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    try {
      final XFile file = await cameraController!.takePicture();
      Get.snackbar("Success", "Photo saved",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to take photo");
    }
  }

  void toggleVideoRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    try {
      if (isRecording.value) {
        final XFile file = await cameraController!.stopVideoRecording();
        _timer?.cancel();
        isRecording.value = false;
        recordingSeconds.value = 0;
        Get.snackbar("Success", "Video saved");
      } else {
        await cameraController!.startVideoRecording();
        isRecording.value = true;
        _startTimer();
      }
    } catch (e) {
      Get.snackbar("Error", "Recording failed");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    recordingSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingSeconds.value++;
    });
  }

  Future<XFile?> takePictureWithReturn() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return null;
    try {
      final XFile file = await cameraController!.takePicture();
      return file;
    } catch (e) {
      Get.snackbar("Error", "Failed to take photo");
      return null;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    cameraController?.dispose();
    super.onClose();
  }
}

