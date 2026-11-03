import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class ChatTranslationService extends GetxService {
  static ChatTranslationService get instance {
    if (!Get.isRegistered<ChatTranslationService>()) {
      return Get.put(ChatTranslationService(), permanent: true);
    }
    return Get.find<ChatTranslationService>();
  }

  final RxMap<String, String> translations = <String, String>{}.obs;
  final RxMap<String, bool> isTranslating = <String, bool>{}.obs;
  final RxMap<String, bool> showTranslated = <String, bool>{}.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxString currentlyPlayingId = ''.obs;
  final RxBool isAudioLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        currentlyPlayingId.value = '';
        isAudioLoading.value = false;
      }
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  /// Translate given text dynamically via translation APIs
  Future<String?> translateText(String messageId, String text,
      {String targetLang = 'hi'}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return null;

    final cacheKey = '${messageId}_$targetLang';
    if (translations.containsKey(cacheKey)) {
      showTranslated[cacheKey] = true;
      showTranslated.refresh();
      return translations[cacheKey];
    }

    try {
      isTranslating[messageId] = true;
      isTranslating.refresh();

      String? translatedResult;

      // 1. Primary: Transliteration API
      if (targetLang == 'hi') {
        try {
          final translitUrl = Uri.parse(
            'https://inputtools.google.com/request?text=${Uri.encodeComponent(cleanText)}&itc=hi-t-i0-und&num=1',
          );
          final translitRes =
              await http.get(translitUrl).timeout(const Duration(seconds: 8));
          if (translitRes.statusCode == 200) {
            final dynamic trData = jsonDecode(translitRes.body);
            if (trData is List && trData.length > 1 && trData[0] == 'SUCCESS') {
              final items = trData[1];
              if (items is List && items.isNotEmpty) {
                final StringBuffer sb = StringBuffer();
                for (var item in items) {
                  if (item is List &&
                      item.length > 1 &&
                      item[1] is List &&
                      (item[1] as List).isNotEmpty) {
                    sb.write("${item[1][0]} ");
                  }
                }
                final trResult = sb.toString().trim();
                if (trResult.isNotEmpty) {
                  translatedResult = trResult;
                }
              }
            }
          }
        } catch (e) {
          debugPrint(
              '⚠️ [ChatTranslationService] Transliteration API Error: $e');
        }
      }

      // 2. Secondary: Google Translate GTX API
      if (translatedResult == null || translatedResult.isEmpty) {
        try {
          final url = Uri.parse(
            'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(cleanText)}',
          );
          final response =
              await http.get(url).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final dynamic data = jsonDecode(response.body);
            if (data is List && data.isNotEmpty && data[0] is List) {
              final StringBuffer sb = StringBuffer();
              for (var segment in data[0]) {
                if (segment is List &&
                    segment.isNotEmpty &&
                    segment[0] != null) {
                  sb.write(segment[0].toString());
                }
              }
              final res = sb.toString().trim();
              if (res.isNotEmpty) {
                translatedResult = res;
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ [ChatTranslationService] GTX API Error: $e');
        }
      }

      // 3. Fallback: Dict-Chrome API
      if (translatedResult == null || translatedResult.isEmpty) {
        try {
          final fallbackUrl = Uri.parse(
            'https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=auto&tl=$targetLang&q=${Uri.encodeComponent(cleanText)}',
          );
          final fallbackRes =
              await http.get(fallbackUrl).timeout(const Duration(seconds: 8));
          if (fallbackRes.statusCode == 200) {
            final dynamic fbData = jsonDecode(fallbackRes.body);
            if (fbData is List && fbData.isNotEmpty) {
              if (fbData[0] is String && fbData[0].toString().isNotEmpty) {
                translatedResult = fbData[0].toString();
              } else if (fbData[0] is List && fbData[0].isNotEmpty) {
                translatedResult = fbData[0][0].toString();
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ [ChatTranslationService] Dict-Chrome API Error: $e');
        }
      }

      if (translatedResult != null && translatedResult.isNotEmpty) {
        var finalTranslated = translatedResult;

        if (RegExp(r'^(hi|hey|hii|hiii)\b', caseSensitive: false)
            .hasMatch(cleanText)) {
          finalTranslated = finalTranslated.replaceFirst(
              RegExp(r'^(नमस्ते|नमस्कार)\s*([,!।]*)'), 'हाय ');
        } else if (RegExp(r'^(hello|hlo)\b', caseSensitive: false)
            .hasMatch(cleanText)) {
          finalTranslated = finalTranslated.replaceFirst(
              RegExp(r'^(नमस्ते|नमस्कार)\s*([,!।]*)'), 'हैलो ');
        }

        translations[cacheKey] = finalTranslated.trim();
        showTranslated[cacheKey] = true;
        translations.refresh();
        showTranslated.refresh();
        return finalTranslated.trim();
      }
    } catch (e) {
      debugPrint('❌ [ChatTranslationService] Dynamic Translation Error: $e');
    } finally {
      isTranslating[messageId] = false;
      isTranslating.refresh();
    }
    return null;
  }

  /// Reset all open translated cards so messages start closed when entering chat
  void resetVisibility() {
    showTranslated.clear();
    showTranslated.refresh();
  }

  /// Toggle showing the translated box
  void toggleTranslationVisibility(String messageId,
      {String targetLang = 'hi'}) {
    final cacheKey = '${messageId}_$targetLang';
    final current = showTranslated[cacheKey] ?? false;
    showTranslated[cacheKey] = !current;
    showTranslated.refresh();
  }

  /// Play TTS audio for text
  Future<void> playAudio(String audioId, String text,
      {String lang = 'en'}) async {
    try {
      if (currentlyPlayingId.value == audioId) {
        await _audioPlayer.stop();
        currentlyPlayingId.value = '';
        isAudioLoading.value = false;
        return;
      }

      await _audioPlayer.stop();
      currentlyPlayingId.value = audioId;
      isAudioLoading.value = true;

      final cleanText = text.trim();
      final encoded = Uri.encodeComponent(cleanText);
      final ttsUrl =
          'https://translate.google.com/translate_tts?ie=UTF-8&tl=$lang&client=tw-ob&q=$encoded';

      await _audioPlayer.setUrl(
        ttsUrl,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      );
      isAudioLoading.value = false;
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('❌ [ChatTranslationService] Error playing TTS: $e');
      currentlyPlayingId.value = '';
      isAudioLoading.value = false;
    }
  }

  /// Stop current audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      currentlyPlayingId.value = '';
      isAudioLoading.value = false;
    } catch (_) {}
  }
}
