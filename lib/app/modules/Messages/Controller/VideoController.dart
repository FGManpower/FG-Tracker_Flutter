import 'dart:async';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';

class VideoControllerX extends GetxController {
  late VideoPlayerController videoController;

  final showControls = true.obs;

  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;

  String videoUrl = "";

  Timer? hideTimer;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    videoUrl = "${args["videoUrl"]}";
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

    initializeVideo();
  }

  Future<void> initializeVideo() async {
    await videoController.initialize();

    duration.value = videoController.value.duration;

    videoController.play();

    videoController.addListener(videoListener);

    startHideTimer();

    update();
  }

  void videoListener() {
    position.value = videoController.value.position;
    duration.value = videoController.value.duration;

    update();
  }

  void toggleControls() {
    showControls.toggle();

    if (showControls.value) {
      startHideTimer();
    }
  }

  void togglePlayPause() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
      startHideTimer();
    }

    update();
  }

  void seekForward() {
    videoController.seekTo(
      position.value + const Duration(seconds: 10),
    );
  }

  void seekBackward() {
    final newPosition = position.value - const Duration(seconds: 10);

    videoController.seekTo(
      newPosition.isNegative ? Duration.zero : newPosition,
    );
  }

  void startHideTimer() {
    hideTimer?.cancel();

    hideTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (videoController.value.isPlaying) {
          showControls.value = false;
        }
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;

    final minutes = twoDigits(duration.inMinutes.remainder(60));

    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }

    return "$minutes:$seconds";
  }

  Future<void> shareVideo() async {
    try {
      final tempDir = await getTemporaryDirectory();

      final filePath =
          "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

      await Dio().download(
        videoUrl,
        filePath,
      );

      await Share.shareXFiles(
        [
          XFile(filePath),
        ],
        text: "Shared from FG Tracker",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to share video",
      );
    }
  }

  Future<void> downloadVideo() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final filePath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

      await Dio().download(
        videoUrl,
        filePath,
      );

      Get.snackbar(
        "Success",
        "Video downloaded successfully",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Download failed",
      );
    }
  }

  @override
  void onClose() {
    hideTimer?.cancel();

    videoController.removeListener(
      videoListener,
    );

    videoController.dispose();

    super.onClose();
  }
}
