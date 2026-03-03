import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waveform_flutter/waveform_flutter.dart' as wf;

class VoiceRecordController extends GetxController {
  final AudioRecorder _recorder = AudioRecorder();

  RxBool isRecording = false.obs;
  RxBool isPaused = false.obs;
  RxInt duration = 0.obs;

  Timer? _durationTimer;
  Timer? _waveTimer;

  String? filePath;

  final StreamController<wf.Amplitude> _amplitudeController =
  StreamController<wf.Amplitude>.broadcast();

  Stream<wf.Amplitude> get amplitudeStream =>
      _amplitudeController.stream;

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) return;

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
    isPaused.value = false;
    duration.value = 0;

    _durationTimer?.cancel();
    _waveTimer?.cancel();


    _durationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!isPaused.value) {
            duration.value++;
          }
        });


    _waveTimer =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
          if (!isPaused.value) {
            double fakeAmplitude =
            (DateTime.now().millisecond % 100).toDouble();

            _amplitudeController.add(
              wf.Amplitude(
                current: fakeAmplitude,
                max: 100,
              ),
            );
          }
        });
  }

  Future<void> pauseRecording() async {
    await _recorder.pause();
    isPaused.value = true;
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
    isPaused.value = false;
  }

  Future<String?> stopRecording() async {
    _durationTimer?.cancel();
    _waveTimer?.cancel();

    final path = await _recorder.stop();

    isRecording.value = false;
    isPaused.value = false;

    if (path == null) return null;

    if (duration.value < 1) {
      File(path).delete();
      return null;
    }

    return path;
  }

  Future<void> deleteRecording() async {
    final path = await _recorder.stop();

    if (path != null) {
      File(path).delete();
    }

    _durationTimer?.cancel();
    _waveTimer?.cancel();

    isRecording.value = false;
    isPaused.value = false;
    duration.value = 0;
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    _waveTimer?.cancel();
    _amplitudeController.close();
    _recorder.dispose();
    super.onClose();
  }
}