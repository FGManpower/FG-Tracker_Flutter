import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Data/Services/chat_translation_service.dart';

/// Card showing translation inside the message bubble
class ChatTranslatedCard extends StatelessWidget {
  final String messageId;
  final String translatedText;
  final String targetLang;
  final VoidCallback onToggleOriginal;

  const ChatTranslatedCard({
    super.key,
    required this.messageId,
    required this.translatedText,
    this.targetLang = 'hi',
    required this.onToggleOriginal,
  });

  @override
  Widget build(BuildContext context) {
    final translationService = ChatTranslationService.instance;
    final isTargetEnglish = targetLang == 'en';
    final headerTitle = isTargetEnglish ? "Translated to English" : "Translated to Hindi";
    final listenTitle = isTargetEnglish ? "Listen (English)" : "Listen (Hindi)";
    final stopTitle = isTargetEnglish ? "Stop (English)" : "Stop (Hindi)";

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      constraints: BoxConstraints(
        minWidth: 230.w,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0FD),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF4818F0).withValues(alpha: 0.10),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    size: 13.5.sp,
                    color: const Color(0xFF4818F0),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    headerTitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF4818F0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggleOriginal,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    "Show Original",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: FontFamily.interMedium,
                      color: const Color(0xFF4818F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            translatedText,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontFamily: FontFamily.interMedium,
              color: const Color(0xFF1E1B4B),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Obx(() {
            final audioId = '${messageId}_$targetLang';
            final isPlaying = translationService.currentlyPlayingId.value == audioId;
            final isLoading = translationService.isAudioLoading.value &&
                translationService.currentlyPlayingId.value == audioId;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                translationService.playAudio(
                  audioId,
                  translatedText,
                  lang: isTargetEnglish ? 'en' : 'hi',
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CupertinoActivityIndicator(radius: 6),
                      ),
                    )
                  else
                    Icon(
                      isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_outlined,
                      size: 14.sp,
                      color: const Color(0xFF4818F0),
                    ),
                  SizedBox(width: 4.w),
                  Text(
                    isPlaying ? stopTitle : listenTitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF4818F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Action row below the message bubble
class ChatMessageActionRow extends StatelessWidget {
  final String messageId;
  final String originalText;
  final bool isSentByMe;

  const ChatMessageActionRow({
    super.key,
    required this.messageId,
    required this.originalText,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText.trim().isEmpty) return const SizedBox.shrink();

    final translationService = ChatTranslationService.instance;
    final isHindiMessage = RegExp(r'[\u0900-\u097F]').hasMatch(originalText);
    final targetLang = isHindiMessage ? 'en' : 'hi';
    final actionTitle = isHindiMessage ? 'Translate to English' : 'Translate to Hindi';
    final cacheKey = '${messageId}_$targetLang';

    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
      child: Obx(() {
        final isTranslating = translationService.isTranslating[messageId] == true;
        final isTranslatedShowing = translationService.showTranslated[cacheKey] == true;
        final hasTranslation = translationService.translations.containsKey(cacheKey);

        if (isTranslatedShowing && hasTranslation) {
          return const SizedBox.shrink();
        }

        final audioId = '${messageId}_orig';
        final isPlaying = translationService.currentlyPlayingId.value == audioId;
        final isAudioLoading = translationService.isAudioLoading.value &&
            translationService.currentlyPlayingId.value == audioId;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (hasTranslation) {
                  translationService.toggleTranslationVisibility(messageId, targetLang: targetLang);
                } else {
                  translationService.translateText(messageId, originalText, targetLang: targetLang);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTranslating)
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CupertinoActivityIndicator(radius: 6),
                      ),
                    )
                  else
                    Icon(
                      Icons.language_outlined,
                      size: 14.sp,
                      color: const Color(0xFF4818F0),
                    ),
                  SizedBox(width: 4.w),
                  Text(
                    isTranslating ? "Translating..." : actionTitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF4818F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Listen Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                translationService.playAudio(
                  audioId,
                  originalText,
                  lang: isHindiMessage ? 'hi' : 'en',
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAudioLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CupertinoActivityIndicator(radius: 6),
                      ),
                    )
                  else
                    Icon(
                      isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_outlined,
                      size: 15.sp,
                      color: const Color(0xFF4818F0),
                    ),
                  SizedBox(width: 4.w),
                  Text(
                    isPlaying ? "Stop" : "Listen",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: FontFamily.interSemiBold,
                      color: const Color(0xFF4818F0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
