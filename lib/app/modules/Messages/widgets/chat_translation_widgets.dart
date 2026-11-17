import 'package:fgtracker/l10n/l10n.dart';
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
    final l10n = context.l10n;
    final headerTitle = isTargetEnglish
        ? l10n.chat_translatedToEnglish
        : l10n.chat_translatedToHindi;
    final listenTitle =
        isTargetEnglish ? l10n.chat_listenEnglish : l10n.chat_listenHindi;
    final stopTitle =
        isTargetEnglish ? l10n.chat_stopEnglish : l10n.chat_stopHindi;

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
                    context.l10n.chat_showOriginal,
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
            final isPlaying =
                translationService.currentlyPlayingId.value == audioId;
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
                      isPlaying
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_outlined,
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

  /// False when the bubble already shows [ChatInlineListenButton] (plain
  /// text): the row then only appears for the "Translating…" progress.
  final bool showListen;

  const ChatMessageActionRow({
    super.key,
    required this.messageId,
    required this.originalText,
    required this.isSentByMe,
    this.showListen = true,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText.trim().isEmpty) return const SizedBox.shrink();

    final translationService = ChatTranslationService.instance;
    final isHindiMessage = RegExp(r'[\u0900-\u097F]').hasMatch(originalText);
    final targetLang = isHindiMessage ? 'en' : 'hi';
    final cacheKey = '${messageId}_$targetLang';

    return Obx(() {
        final isTranslating =
            translationService.isTranslating[messageId] == true;
        final isTranslatedShowing =
            translationService.showTranslated[cacheKey] == true;
        final hasTranslation =
            translationService.translations.containsKey(cacheKey);

        if (isTranslatedShowing && hasTranslation) {
          return const SizedBox.shrink();
        }
        // Nothing to show: no empty gap under the bubble.
        if (!showListen && !isTranslating) return const SizedBox.shrink();

        final audioId = '${messageId}_orig';
        final isPlaying =
            translationService.currentlyPlayingId.value == audioId;
        final isAudioLoading = translationService.isAudioLoading.value &&
            translationService.currentlyPlayingId.value == audioId;

        return Padding(
          padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
          child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // "Translate to Hindi/English" link removed: translation is now
            // a left swipe on the message. Only its progress is shown here.
            if (isTranslating) ...[
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: const CupertinoActivityIndicator(radius: 6),
                ),
              ),
              Text(
                context.l10n.chat_translating,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: FontFamily.interSemiBold,
                  color: const Color(0xFF4818F0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16.w),
            ],
            // Listen Button
            if (showListen) GestureDetector(
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
                      isPlaying
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_outlined,
                      size: 15.sp,
                      color: const Color(0xFF4818F0),
                    ),
                  SizedBox(width: 4.w),
                  Text(
                    isPlaying ? context.l10n.chat_stop : context.l10n.chat_listen,
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
        ),
        );
      });
  }
}

/// Small speaker icon inside a received text bubble, between the text and
/// the time (UI, F-1.2.6). Same action as the "Listen" button of
/// [ChatMessageActionRow]: plays / stops the original text.
class ChatInlineListenButton extends StatelessWidget {
  final String messageId;
  final String originalText;

  const ChatInlineListenButton({
    super.key,
    required this.messageId,
    required this.originalText,
  });

  @override
  Widget build(BuildContext context) {
    if (originalText.trim().isEmpty) return const SizedBox.shrink();
    final translationService = ChatTranslationService.instance;
    final isHindiMessage = RegExp(r'[ऀ-ॿ]').hasMatch(originalText);
    final audioId = '${messageId}_orig';

    return Obx(() {
      final isPlaying = translationService.currentlyPlayingId.value == audioId;
      final isAudioLoading =
          translationService.isAudioLoading.value && isPlaying;
      return Semantics(
        button: true,
        label: isPlaying ? context.l10n.chat_stop : context.l10n.chat_listen,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => translationService.playAudio(
            audioId,
            originalText,
            lang: isHindiMessage ? 'hi' : 'en',
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
            child: isAudioLoading
                ? SizedBox(
                    width: 13.w,
                    height: 13.w,
                    child: const CupertinoActivityIndicator(radius: 6),
                  )
                : Icon(
                    isPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.volume_up_outlined,
                    size: 14.sp,
                    color: const Color(0xFF7B6CF6),
                  ),
          ),
        ),
      );
    });
  }
}
