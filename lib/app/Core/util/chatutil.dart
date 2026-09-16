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
      return "📍 Location";
    }

    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.contains('image message') ||
        lower.startsWith('image/')) {
      return "📷 Photo";
    }

    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.contains('video message') ||
        lower.startsWith('video/')) {
      return "🎥 Video";
    }

    if (lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.aac') ||
        lower.contains('audio message') ||
        lower.contains('voice message') ||
        lower.startsWith('audio/')) {
      return "🎤 Voice message";
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
      return "📄 Document";
    }

    if (lower.contains('contact message') || lower.contains('vcard')) {
      return "👤 Contact";
    }

    return value;
  }
}