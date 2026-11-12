import 'package:fgtracker/l10n/l10n.dart';

class ChatUtil {
  static String formatLastMessage(String? msg) {
    if (msg == null) return "";
    final value = msg.trim();
    if (value.isEmpty) return "";

    final lower = value.toLowerCase();

    if ((value.startsWith('{') && value.contains('latitude')) ||
        lower.contains('"latitude"') ||
        lower.contains('"longitude"') ||
        lower == 'location' ||
        lower.contains('location message')) {
      return appL10n.util_previewLocation;
    }

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.contains('image message') ||
        lower.startsWith('image/')) {
      return appL10n.util_previewPhoto;
    }

    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.contains('video message') ||
        lower.startsWith('video/')) {
      return appL10n.util_previewVideo;
    }

    if (lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.aac') ||
        lower.contains('audio message') ||
        lower.contains('voice message') ||
        lower.startsWith('audio/')) {
      return appL10n.util_previewVoice;
    }

    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx') ||
        lower.endsWith('.txt') ||
        lower.endsWith('.zip') ||
        lower.endsWith('.rar')) {
      return appL10n.util_previewDocument;
    }

    if (lower.contains('contact message') || lower.contains('vcard')) {
      return appL10n.util_previewContact;
    }

    return value;
  }
}