import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
class RealtimeAudioScreen extends StatefulWidget {
  const RealtimeAudioScreen({super.key});

  @override
  State<RealtimeAudioScreen> createState() => _RealtimeAudioScreenState();
}

class _RealtimeAudioScreenState extends State<RealtimeAudioScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  final StreamController<Uint8List> _audioStreamController =
  StreamController<Uint8List>();

  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();

    await _recorder.openRecorder();
    await _player.openPlayer();

    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      bufferSize: 1024,
      interleaved: false,
    );

    _audioStreamController.stream.listen((Uint8List buffer) {
      _player.uint8ListSink?.add(buffer);
    });

  }

  @override
  void dispose() {
    _audioStreamController.close();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _startStreaming() async {
    await _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      toStream: _audioStreamController.sink,
    );

    setState(() => _isStreaming = true);
  }

  Future<void> _stopStreaming() async {
    await _recorder.stopRecorder();
    setState(() => _isStreaming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Realtime Audio Streaming")),
      body: Center(
        child: ElevatedButton(
          onPressed: _isStreaming ? _stopStreaming : _startStreaming,
          child: Text(_isStreaming ? "Stop Streaming" : "Start Streaming"),
        ),
      ),
    );
  }
}
