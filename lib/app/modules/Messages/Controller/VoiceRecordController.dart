import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordController extends GetxController {
  final AudioRecorder _recorder = AudioRecorder();

  RxBool isRecording = false.obs;
  RxBool isCancelled = false.obs;
  RxInt duration = 0.obs;

  Timer? _timer;
  String? filePath;

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {

        if (isRecording.value) return;

        final dir = await getTemporaryDirectory();
        filePath =
        "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath!,
        );

        isRecording.value = true;
        isCancelled.value = false;
        duration.value = 0;

        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          duration.value++;
        });
      }
    } catch (e) {
      print("Recording Error: $e");
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!isRecording.value) return null;

      _timer?.cancel();

      final path = await _recorder.stop();
      isRecording.value = false;

      // Minimum 1 second validation
      if (duration.value < 1) {
        if (path != null) {
          File(path).delete();
        }
        return null;
      }

      if (isCancelled.value) {
        if (path != null) {
          File(path).delete();
        }
        return null;
      }

      return path;
    } catch (e) {
      print("Stop Recording Error: $e");
      return null;
    }
  }

  void cancelRecording() {
    isCancelled.value = true;
  }

  void reset() {
    isRecording.value = false;
    isCancelled.value = false;
    duration.value = 0;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _recorder.dispose();
    super.onClose();
  }
}