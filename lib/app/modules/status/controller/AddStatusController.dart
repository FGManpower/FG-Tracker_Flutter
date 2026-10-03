import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fgtracker/app/Data/Repositories/status_repo.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class AddStatusController extends GetxController {
  CameraController? cameraController;
  VideoPlayerController? previewVideoController;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  Timer? _recordTimer;

  final TextEditingController textController = TextEditingController();
  final TextEditingController captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final RxString mode = 'photo'.obs;
  final RxBool isInitializing = false.obs;
  final RxBool isCameraReady = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isVideoFile = false.obs;
  final RxBool isVideoPreviewReady = false.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool isVideoMuted = false.obs;
  final RxDouble videoProgress = 0.0.obs;
  final RxInt videoTotalSeconds = 0.obs;
  final RxBool isPosting = false.obs;
  final RxInt recordDuration = 0.obs;
  final RxInt selectedBgIndex = 0.obs;
  final RxString privacyType = 'ALL_CONTACTS'.obs;
  final RxList<int> targetUserIds = <int>[].obs;
  final Rxn<File> capturedFile = Rxn<File>();
  final RxnString error = RxnString();

  final List<Color> bgColors = const [
    Color(0xFF6B4DFF),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
    Color(0xFF1E293B),
  ];

  String get whoCanSeeLabel {
    switch (privacyType.value) {
      case 'EXCEPT_USERS':
        return 'Except Selected';
      case 'ONLY_SHARE_WITH':
        return 'Only Share With';
      default:
        return 'All Contacts';
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<StatusFeedController>()) {
      final feedCtrl = Get.find<StatusFeedController>();
      privacyType.value = feedCtrl.defaultPrivacyType.value;
      targetUserIds.assignAll(feedCtrl.defaultTargetUserIds);
    }
    initCamera();
  }

  Future<void> initCamera() async {
    isInitializing.value = true;
    error.value = null;
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        error.value = 'No camera available';
        isCameraReady.value = false;
        return;
      }
      await _setupCamera(_cameras[_selectedCameraIndex]);
    } catch (_) {
      error.value = 'Unable to access camera';
      isCameraReady.value = false;
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _setupCamera(CameraDescription description) async {
    await cameraController?.dispose();
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );
    cameraController = controller;
    await controller.initialize();
    await controller.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
    isCameraReady.value = true;
  }

  Future<void> _initVideoPreview(File file) async {
    await _disposeVideoPreview();
    try {
      final vc = VideoPlayerController.file(file);
      previewVideoController = vc;
      await vc.initialize();
      await vc.setLooping(true);
      await vc.setVolume(isVideoMuted.value ? 0.0 : 1.0);
      videoTotalSeconds.value = vc.value.duration.inSeconds > 0
          ? vc.value.duration.inSeconds
          : (recordDuration.value > 0 ? recordDuration.value : 15);
      vc.addListener(_onVideoPreviewTick);
      isVideoPreviewReady.value = true;
      await vc.play();
      isVideoPlaying.value = true;
    } catch (_) {
      isVideoPreviewReady.value = false;
    }
  }

  void _onVideoPreviewTick() {
    final vc = previewVideoController;
    if (vc == null || !vc.value.isInitialized) return;
    isVideoPlaying.value = vc.value.isPlaying;
    final totalMs = vc.value.duration.inMilliseconds;
    final posMs = vc.value.position.inMilliseconds;
    if (totalMs > 0) {
      videoProgress.value = (posMs / totalMs).clamp(0.0, 1.0);
    }
  }

  Future<void> _disposeVideoPreview() async {
    final old = previewVideoController;
    previewVideoController = null;
    isVideoPreviewReady.value = false;
    isVideoPlaying.value = false;
    isVideoMuted.value = false;
    videoProgress.value = 0.0;
    if (old != null) {
      old.removeListener(_onVideoPreviewTick);
      await old.pause();
      await old.dispose();
    }
  }

  void toggleVideoPlayPause() {
    final vc = previewVideoController;
    if (vc == null || !vc.value.isInitialized) return;
    if (vc.value.isPlaying) {
      vc.pause();
      isVideoPlaying.value = false;
    } else {
      vc.play();
      isVideoPlaying.value = true;
    }
  }

  void toggleVideoMute() {
    final vc = previewVideoController;
    if (vc == null || !vc.value.isInitialized) return;
    isVideoMuted.value = !isVideoMuted.value;
    vc.setVolume(isVideoMuted.value ? 0.0 : 1.0);
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    try {
      isFlashOn.value = !isFlashOn.value;
      await cameraController!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {}
  }

  Future<void> flipCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    isCameraReady.value = false;
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> changeMode(String newMode) async {
    if (isRecording.value) return;
    mode.value = newMode;
    if (newMode == 'text') {
      await _disposeVideoPreview();
      capturedFile.value = null;
      isVideoFile.value = false;
    }
  }

  Future<void> onShutterTap() async {
    if (mode.value == 'photo') {
      await _takePhoto();
    } else if (mode.value == 'video') {
      if (isRecording.value) {
        await stopVideoRecording();
      } else {
        await startVideoRecording();
      }
    }
  }

  Future<void> _takePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    try {
      await _disposeVideoPreview();
      final XFile file = await cameraController!.takePicture();
      capturedFile.value = File(file.path);
      isVideoFile.value = false;
    } catch (_) {}
  }

  Future<void> startVideoRecording() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isRecording.value) {
      return;
    }
    try {
      await _disposeVideoPreview();
      await cameraController!.startVideoRecording();
      isRecording.value = true;
      recordDuration.value = 0;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordDuration.value++;
        if (recordDuration.value >= 30) {
          stopVideoRecording();
        }
      });
    } catch (_) {}
  }

  Future<void> stopVideoRecording() async {
    if (cameraController == null || !isRecording.value) return;
    try {
      _recordTimer?.cancel();
      final XFile video = await cameraController!.stopVideoRecording();
      isRecording.value = false;
      final rawFile = File(video.path);
      final preparedFile = await prepareVideoFile(rawFile);
      isVideoFile.value = true;
      capturedFile.value = preparedFile;
      await _initVideoPreview(preparedFile);
    } catch (_) {
      isRecording.value = false;
    }
  }

  Future<void> openGallery() async {
    try {
      if (mode.value == 'video') {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 30),
        );
        if (video != null) {
          final file = File(video.path);
          isVideoFile.value = true;
          capturedFile.value = file;
          await _initVideoPreview(file);
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image != null) {
          await _disposeVideoPreview();
          isVideoFile.value = false;
          capturedFile.value = File(image.path);
          mode.value = 'photo';
        }
      }
    } catch (_) {}
  }

  Future<void> retake() async {
    await _disposeVideoPreview();
    capturedFile.value = null;
    isVideoFile.value = false;
    recordDuration.value = 0;
    captionController.clear();
  }

  String formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#${(r + g + b).toUpperCase()}';
  }

  Future<void> postStatus() async {
    if (isPosting.value) return;

    if (mode.value == 'text' && textController.text.trim().isEmpty) {
      Get.snackbar(
        'Status',
        'Text content is required for text status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    if (mode.value != 'text' && capturedFile.value == null) {
      Get.snackbar(
        'Status',
        'Please capture or select a ${mode.value} first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }

    isPosting.value = true;
    previewVideoController?.pause();

    try {
      final backendType = mode.value == 'text'
          ? 'text'
          : (isVideoFile.value ? 'video' : 'image');

      final content = mode.value == 'text'
          ? textController.text.trim()
          : captionController.text.trim();

      final bgColor = mode.value == 'text'
          ? _colorToHex(bgColors[selectedBgIndex.value])
          : '#000000';

      final durationSeconds = backendType == 'video'
          ? (videoTotalSeconds.value > 0
              ? videoTotalSeconds.value
              : (recordDuration.value > 0 ? recordDuration.value : 15))
          : 5;

      final response = await StatusRepo.createStatus(
        type: backendType,
        content: content,
        backgroundColor: bgColor,
        fontStyle: 'default',
        durationSeconds: durationSeconds,
        privacyType: privacyType.value,
        targetUserIds: targetUserIds.isNotEmpty ? targetUserIds.toList() : null,
        mediaFile: mode.value == 'text' ? null : capturedFile.value,
      );

      if (response.status) {
        if (Get.isRegistered<StatusFeedController>()) {
          await Get.find<StatusFeedController>().refreshAll();
        }
        Get.back();
      } else {
        Get.snackbar(
          'Upload Failed',
          response.message ?? 'Unable to publish status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isPosting.value = false;
    }
  }

  Future<File> prepareVideoFile(File rawFile) async {
    if (!Platform.isIOS && !rawFile.path.toLowerCase().endsWith('.mov')) {
      return rawFile;
    }
    try {
      final info = await VideoCompress.compressVideo(
        rawFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      if (info != null && info.file != null) {
        return info.file!;
      }
    } catch (_) {}
    return rawFile;
  }

  @override
  void onClose() {
    _recordTimer?.cancel();
    _disposeVideoPreview();
    cameraController?.dispose();
    textController.dispose();
    captionController.dispose();
    super.onClose();
  }
}
