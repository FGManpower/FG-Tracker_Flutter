import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Helper service for voice playback generation during Voice-to-Text.
/// Does NOT touch hardware microphone during live speech recognition,
/// avoiding Android OS concurrent AudioRecord conflicts that mute SpeechRecognizer.
/// Instead, provides clean voice audio of the converted text for review playback.
class VoiceToTextAudioRecorder {
  String? _currentAudioPath;

  bool get isRecording => false;
  String? get currentRecordingPath => _currentAudioPath;

  /// Generates voice playback audio for the transcribed text.
  Future<String?> generateAudioForText(String text, String langCode) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return null;

    try {
      // Map language code to standard TTS language:
      // 'hi-IN' -> 'hi', 'mr-IN' -> 'mr', 'en-IN' -> 'en'
      String lang = 'en';
      final lower = langCode.toLowerCase();
      if (lower.startsWith('hi')) {
        lang = 'hi';
      } else if (lower.startsWith('mr')) {
        lang = 'mr';
      } else if (lower.startsWith('en')) {
        lang = 'en';
      }

      // Limit query length to first 300 characters for snappy generation
      final truncated = cleanText.length > 300 ? cleanText.substring(0, 300) : cleanText;
      final encoded = Uri.encodeComponent(truncated);
      final ttsUrl =
          'https://translate.google.com/translate_tts?ie=UTF-8&tl=$lang&client=tw-ob&q=$encoded';

      final response = await http.get(
        Uri.parse(ttsUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            "${tempDir.path}/vtt_audio_${DateTime.now().millisecondsSinceEpoch}.mp3";
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        _currentAudioPath = filePath;
        if (kDebugMode) {
          debugPrint(
              '[VoiceToTextAudioRecorder] Generated audio for review: $filePath (${response.bodyBytes.length} bytes)');
        }
        return filePath;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VoiceToTextAudioRecorder] Audio generation failed: $e');
      }
    }
    return null;
  }

  /// Cleans up any current temporary audio file.
  Future<void> cancel() async {
    if (_currentAudioPath != null) {
      try {
        final file = File(_currentAudioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      _currentAudioPath = null;
    }
  }

  void dispose() {
    cancel();
  }
}
