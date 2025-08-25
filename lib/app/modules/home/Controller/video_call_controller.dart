import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallController extends GetxController {
  late CameraController cameraController;
  var isMicOn = true.obs;
  var isCameraOn = true.obs;
  var isCameraInitialized = false.obs;

  // ✅ Initialize camera and microphone with permission check
  Future<void> initCamera() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!camStatus.isGranted || !micStatus.isGranted) {
      Get.snackbar('Permission Denied', 'Camera and microphone permissions are required.');
      return;
    }

    try {
      final cameras = await availableCameras();

      // 📸 Use front camera if available, otherwise fallback to rear
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(frontCamera, ResolutionPreset.high);

      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar('Camera Error', e.toString());
    }
  }

  void toggleMic() {
    isMicOn.value = !isMicOn.value;
    // Optional: control mic logic here
  }

  void toggleCamera() {
    isCameraOn.value = !isCameraOn.value;
    if (isCameraOn.value) {
      cameraController.resumePreview();
    } else {
      cameraController.pausePreview();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void onClose() {
    if (isCameraInitialized.value) {
      cameraController.dispose();
    }
    super.onClose();
  }
}
