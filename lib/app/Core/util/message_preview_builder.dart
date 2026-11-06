import 'dart:convert';

import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/GroupChatListModel.dart';
import 'package:fgtracker/app/Model/PrivateChatModel.dart';

import 'chatutil.dart';

/// Every message type the app knows how to preview.
///
/// To support a new feature: add one value here, map its backend type
/// string(s) in [MessageTypes.kindOf], and add one case in
/// [MessagePreviewBuilder._body]. Nothing else needs to change.
enum MessageKind {
  text,
  image,
  bulkMedia,
  video,
  audio,
  document,
  location,
  contact,
  sticker,
  gif,
  poll,
  attendance,
  forwarded,
  system,
  deleted,
  unknown,
}

/// Backend `messageType` strings, kept in one place.
class MessageTypes {
  MessageTypes._();

  static const String text = 'text';
  static const String image = 'image';
  static const String media = 'media';
  static const String video = 'video';
  static const String audio = 'audio';
  static const String document = 'document';
  static const String location = 'location';
  static const String contact = 'contact';
  static const String sticker = 'sticker';
  static const String gif = 'gif';
  static const String poll = 'poll';
  static const String attendance = 'attendance';
  static const String system = 'system';

  static const Map<String, MessageKind> _aliases = {
    'text': MessageKind.text,
    'text_message': MessageKind.text,
    'emoji': MessageKind.text,
    'link': MessageKind.text,
    'reply': MessageKind.text,
    'image': MessageKind.image,
    'image_text': MessageKind.image,
    'photo': MessageKind.image,
    'media': MessageKind.bulkMedia,
    'images': MessageKind.bulkMedia,
    'multiple_images': MessageKind.bulkMedia,
    'bulk_images': MessageKind.bulkMedia,
    'video': MessageKind.video,
    'audio': MessageKind.audio,
    'voice': MessageKind.audio,
    'voice_note': MessageKind.audio,
    'document': MessageKind.document,
    'file': MessageKind.document,
    'pdf': MessageKind.document,
    'location': MessageKind.location,
    'live_location': MessageKind.location,
    'contact': MessageKind.contact,
    'vcard': MessageKind.contact,
    'sticker': MessageKind.sticker,
    'gif': MessageKind.gif,
    'poll': MessageKind.poll,
    'attendance': MessageKind.attendance,
    'attendance_poll': MessageKind.attendance,
    'forward': MessageKind.forwarded,
    'forwarded': MessageKind.forwarded,
    'forward_message': MessageKind.forwarded,
    'system': MessageKind.system,
    'info': MessageKind.system,
    'notification': MessageKind.system,
    'group_event': MessageKind.system,
    'deleted': MessageKind.deleted,
  };

  /// Missing/empty type is treated as text (matches the existing model
  /// default); any other unrecognised string is [MessageKind.unknown].
  static MessageKind kindOf(String? type) {
    final key = (type ?? '').trim().toLowerCase();
    if (key.isEmpty) return MessageKind.text;
    return _aliases[key] ?? MessageKind.unknown;
  }
}

/// Result of [MessagePreviewBuilder.build].
class MessagePreview {
  final MessageKind kind;

  /// "You: " / "Rahul: " in group chats, otherwise empty.
  final String senderPrefix;

  /// Leading emoji such as "📊", or empty for plain text.
  final String icon;

  /// The preview body without icon or prefix.
  final String text;

  const MessagePreview({
    required this.kind,
    required this.text,
    this.icon = '',
    this.senderPrefix = '',
  });

  bool get isDeleted => kind == MessageKind.deleted;

  /// For rows that draw their own deleted-state UI (icon + italic): the
  /// plain deleted text, otherwise [display].
  String get rowText => isDeleted ? text : display;

  /// Single-line string ready for a list subtitle.
  String get display {
    final body = icon.isEmpty
        ? text
        : (text.isEmpty ? icon : '$icon $text');
    return '$senderPrefix$body';
  }

  @override
  String toString() => display;
}

/// Single source of truth for "last message" previews (chat lists,
/// archived list, group cards and, later, notifications).
class MessagePreviewBuilder {
  MessagePreviewBuilder._();

  static const String deletedText = 'This message was deleted';
  static const String ownDeletedText = 'You deleted this message';
  static const String fallbackText = 'New message';

  /// Preview for a row of the unified (Common/Private/Group) chat list and
  /// the archived list.
  ///
  /// Formats from the RAW last message (`content`/`message` + `senderId`/
  /// `senderName`) whenever the payload has it, and adds the sender label
  /// exactly once: "You: …" for my messages, "Name: …" for others in
  /// groups. The backend's pre-formatted `preview` string is only a fallback
  /// for payloads without raw content (it may already contain a name).
  static MessagePreview forChat(
    PrivateChatModel chat, {
    String? currentUserId,
  }) {
    final raw = _rawLastMessageContent(chat.lastMessageData);
    return build(
      type: chat.messageType,
      backendPreview: raw == null ? chat.preview : null,
      content: raw ?? chat.message,
      caption: chat.lastMessageData?['caption']?.toString(),
      data: chat.lastMessageData,
      isDeleted: chat.isDeletedForEveryone == true,
      isGroup: chat.isGroup == true,
      senderId: chat.senderId,
      senderName: chat.senderName,
      currentUserId: currentUserId,
      prefixOwnMessages: true,
    );
  }

  /// Raw message text from a last-message map, ignoring display fields.
  static String? _rawLastMessageContent(Map<String, dynamic>? data) {
    if (data == null) return null;
    for (final key in const ['content', 'message', 'text', 'body']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  /// Preview for the group cards (`/group-chat-list` model).
  static MessagePreview forGroupLastMessage(
    GroupLastMessage message, {
    String? currentUserId,
  }) {
    return build(
      type: message.messageType,
      content: message.content,
      caption: message.caption,
      isDeleted: message.isDeletedForEveryone == 1,
      isGroup: true,
      senderId: message.senderId?.toString(),
      senderName: message.senderName,
      currentUserId: currentUserId,
    );
  }

  /// Text used when nothing readable can be found for a replied-to message.
  static const String replyFallbackText = 'Message';

  static const String _imageExt = r'jpe?g|png|webp|heic|heif|bmp';
  static const String _videoExt = r'mp4|mov|mkv|avi|3gp|webm';
  static const String _audioExt = r'mp3|m4a|aac|wav|ogg|opus|amr|flac';
  static const String _docExt = r'pdf|docx?|xlsx?|pptx?|txt|csv|zip|rar|apk';

  /// Preview of a full, in-memory message. Used for the reply bar above the
  /// input and for the quoted message inside a reply bubble.
  static MessagePreview forMessage(MessageData message) {
    final type = message.messageType?.toString();
    final raw = message.content?.toString();
    final split = _splitPipeContent(type, raw);
    final data = <String, dynamic>{
      ...split.data,
      if (message.images != null) 'images': message.images,
      if (message.videos != null) 'videos': message.videos,
      if (message.attendance != null) 'attendance': message.attendance,
    };

    final preview = build(
      type: type,
      content: split.content,
      caption: message.caption?.toString(),
      data: data,
      isDeleted: message.isDeleted == true || _clean(raw) == deletedText,
    );
    return _readableReply(preview, split.content);
  }

  /// Preview of the message quoted by a reply. Prefers the original message
  /// when it is loaded (most accurate, reflects edits/deletes); otherwise
  /// uses the reply fields the backend stored. Never returns empty text.
  static MessagePreview forQuotedReply(
    MessageData reply, {
    MessageData? original,
  }) {
    if (original != null) return forMessage(original);

    final type = reply.replyType?.toString();
    var raw = _clean(reply.replyMessage?.toString());
    if (raw.isEmpty) raw = _clean(reply.replyMessageContent?.toString());
    final split = _splitPipeContent(type, raw);

    final preview = build(
      type: type,
      content: split.content,
      data: split.data,
      isDeleted: raw == deletedText,
    );
    return _readableReply(preview, split.content);
  }

  /// Name shown on a quoted reply: "You" for my own message, otherwise the
  /// stored reply sender name, falling back to the original's sender.
  static String replySenderLabel(
    MessageData reply, {
    MessageData? original,
    String? currentUserId,
  }) {
    final me = _clean(currentUserId);
    final originalSender = _clean(original?.senderId?.toString());
    if (me.isNotEmpty && originalSender.isNotEmpty && originalSender == me) {
      return 'You';
    }
    final name = _clean(reply.replySenderName?.toString());
    if (name.isNotEmpty) return name;
    return _clean(original?.senderName?.toString());
  }

  /// Video/document content is stored as "path||name-or-thumb||extra".
  static ({String content, Map<String, dynamic> data}) _splitPipeContent(
    String? type,
    String? content,
  ) {
    final value = _clean(content);
    if (!value.contains('||')) return (content: value, data: const {});
    final parts = value.split('||').map((e) => e.trim()).toList();
    final kind = MessageTypes.kindOf(type);
    final data = <String, dynamic>{
      if (kind == MessageKind.document &&
          parts.length > 1 &&
          parts[1].isNotEmpty)
        'fileName': parts[1],
    };
    return (content: parts.first, data: data);
  }

  /// Guarantees a reply preview never shows empty text, a raw URL/path or a
  /// JSON payload. Real text messages (including links) are kept as is.
  static MessagePreview _readableReply(MessagePreview preview, String content) {
    if (preview.kind == MessageKind.text) {
      final inferred = _inferFromContent(content);
      if (inferred != null) {
        return MessagePreview(
          kind: inferred.$1,
          icon: inferred.$2,
          text: inferred.$3,
        );
      }
    }

    final text = preview.text.trim();
    if ((text.isEmpty && preview.icon.isEmpty) || text == fallbackText) {
      return MessagePreview(kind: preview.kind, text: replyFallbackText);
    }
    return preview;
  }

  /// For replies whose type is missing/"text" but whose content is really a
  /// media path or a JSON payload.
  static (MessageKind, String, String)? _inferFromContent(String content) {
    final value = content.trim();
    if (value.isEmpty) return null;

    final json = _decodeJson(value);
    if (json != null) {
      if (json.containsKey('latitude') || json.containsKey('lat')) {
        return (MessageKind.location, '📍', 'Location');
      }
      final pollTitle = _firstString(json, const ['question', 'pollTitle']);
      if (pollTitle != null || json.containsKey('options')) {
        return (MessageKind.poll, '📊', pollTitle ?? 'Poll');
      }
      final name =
          _firstString(json, const ['name', 'contactName', 'fullName']);
      if (name != null || json.containsKey('phone')) {
        return (MessageKind.contact, '👤', name ?? 'Contact');
      }
      return (MessageKind.unknown, '', replyFallbackText);
    }

    // Only bare paths/URLs that point at a media file; sentences are text.
    if (value.contains(' ')) return null;
    final lower = value.split('?').first.toLowerCase();
    bool ext(String pattern) => RegExp('\\.($pattern)\$').hasMatch(lower);

    if (ext(_imageExt)) return (MessageKind.image, '📷', 'Photo');
    if (ext('gif')) return (MessageKind.gif, '', 'GIF');
    if (ext(_videoExt)) return (MessageKind.video, '🎥', 'Video');
    if (ext(_audioExt)) return (MessageKind.audio, '🎵', 'Audio');
    if (ext(_docExt)) {
      return (
        MessageKind.document,
        '📄',
        _fileNameFromPath(value) ?? 'Document',
      );
    }
    return null;
  }

  /// [backendPreview] is the display string the backend already sends
  /// (`preview`/`message`). [content] is the raw message content. [data] is
  /// the raw last-message map, used for type-specific fields (poll title,
  /// file name, image count, duration, ...). All are optional.
  static MessagePreview build({
    String? type,
    String? backendPreview,
    String? content,
    String? caption,
    Map<String, dynamic>? data,
    bool isDeleted = false,
    bool isGroup = false,
    String? senderId,
    String? senderName,
    String? currentUserId,
    // Chat-list rows: also show "You: " on my own messages in private chats.
    bool prefixOwnMessages = false,
  }) {
    final kind = isDeleted ? MessageKind.deleted : MessageTypes.kindOf(type);

    if (kind == MessageKind.deleted) {
      // Sender's own deleted message in the chat list (WhatsApp wording).
      // Only when the caller passes currentUserId (chat list rows).
      final me = currentUserId?.trim() ?? '';
      final mine = me.isNotEmpty && me != 'null' && senderId?.trim() == me;
      return MessagePreview(
        kind: MessageKind.deleted,
        icon: '🚫',
        text: mine ? ownDeletedText : deletedText,
      );
    }

    final preview = _clean(backendPreview);
    final rawContent = _clean(content);
    final cleanCaption = _clean(caption);
    final contentJson = _decodeJson(rawContent) ?? _decodeJson(preview);

    final body = _body(
      kind: kind,
      preview: preview,
      content: rawContent,
      caption: cleanCaption,
      data: data ?? const {},
      contentJson: contentJson ?? const {},
    );

    final prefix = ((isGroup || prefixOwnMessages) &&
            kind != MessageKind.system)
        ? _senderPrefix(
            senderId: senderId,
            senderName: senderName,
            currentUserId: currentUserId,
            alreadyShown: body.text,
            includeOthers: isGroup,
          )
        : '';

    return MessagePreview(
      kind: kind,
      icon: body.icon,
      text: body.text,
      senderPrefix: prefix,
    );
  }

  // ---------------------------------------------------------------------------
  // Per-type body. One case per MessageKind.
  // ---------------------------------------------------------------------------

  static _Body _body({
    required MessageKind kind,
    required String preview,
    required String content,
    required String caption,
    required Map<String, dynamic> data,
    required Map<String, dynamic> contentJson,
  }) {
    switch (kind) {
      case MessageKind.text:
        // Unchanged behaviour: show the text the backend sent.
        return _Body('', preview.isNotEmpty ? preview : content);

      case MessageKind.image:
      case MessageKind.bulkMedia:
      case MessageKind.video:
        // These already render correctly from the backend preview; keep it
        // whenever it is human-readable, only rebuild when it is raw/empty.
        if (_isReadable(preview)) return _Body('', preview);
        return _mediaBody(kind, caption, data);

      case MessageKind.poll:
      case MessageKind.attendance:
        if (preview.startsWith('📊')) return _Body('', preview);
        final title = _pollTitle(data, contentJson, preview, content);
        if (title.isNotEmpty) return _Body('📊', title);
        return _Body(
          '📊',
          kind == MessageKind.attendance ? 'Attendance poll' : 'Poll',
        );

      case MessageKind.audio:
        final duration = _formatDuration(
          data['duration'] ?? data['audioDuration'] ?? data['audio_duration'],
        );
        return _Body(
          '🎤',
          duration.isNotEmpty ? 'Voice message ($duration)' : 'Voice message',
        );

      case MessageKind.document:
        final fileName = _firstString(data, const [
              'fileName',
              'file_name',
              'originalName',
              'original_name',
              'documentName',
              'document_name',
            ]) ??
            _firstString(contentJson, const ['fileName', 'file_name', 'name']) ??
            _fileNameFromPath(content) ??
            (_isReadable(preview) ? preview : null);
        return _Body('📄', fileName ?? 'Document');

      case MessageKind.location:
        return const _Body('📍', 'Location');

      case MessageKind.contact:
        final name = _firstString(data, const ['contactName', 'contact_name']) ??
            _firstString(contentJson, const ['name', 'contactName', 'fullName']);
        return _Body('👤', name ?? 'Contact');

      case MessageKind.sticker:
        return const _Body('', 'Sticker');

      case MessageKind.gif:
        return const _Body('', 'GIF');

      case MessageKind.system:
        return _Body('', _isReadable(preview) ? preview : content);

      case MessageKind.forwarded:
      case MessageKind.unknown:
        // Never leak raw payloads. Readable backend text is shown (through
        // the legacy extension heuristics), otherwise a safe fallback.
        if (_isReadable(preview)) {
          return _Body('', ChatUtil.formatLastMessage(preview));
        }
        if (_isReadable(content)) {
          return _Body('', ChatUtil.formatLastMessage(content));
        }
        return const _Body('', fallbackText);

      case MessageKind.deleted:
        return const _Body('🚫', deletedText);
    }
  }

  static _Body _mediaBody(
    MessageKind kind,
    String caption,
    Map<String, dynamic> data,
  ) {
    if (kind == MessageKind.video) {
      return _Body('🎥', caption.isNotEmpty ? caption : 'Video');
    }

    final imageCount = _countOf(data, const ['images', 'mediaUrls', 'media']) ??
        _toInt(data['imageCount'] ?? data['mediaCount'] ?? data['media_count']);
    final videoCount = _countOf(data, const ['videos']);

    if (kind == MessageKind.bulkMedia &&
        (imageCount ?? 0) == 0 &&
        (videoCount ?? 0) > 0) {
      return _Body('🎥', videoCount! > 1 ? '$videoCount Videos' : 'Video');
    }
    if ((imageCount ?? 0) > 1) {
      return _Body('📷', '$imageCount Photos');
    }
    return _Body('📷', caption.isNotEmpty ? caption : 'Photo');
  }

  static String _pollTitle(
    Map<String, dynamic> data,
    Map<String, dynamic> contentJson,
    String preview,
    String content,
  ) {
    const keys = ['question', 'title', 'pollTitle', 'poll_title'];
    for (final nestedKey in const ['poll', 'attendance', 'attendancePoll']) {
      final nested = _asMap(data[nestedKey]);
      final fromNested = nested == null ? null : _firstString(nested, keys);
      if (fromNested != null) return fromNested;
    }
    return _firstString(data, keys) ??
        _firstString(contentJson, keys) ??
        (_isReadable(preview) ? preview : null) ??
        (_isReadable(content) ? content : null) ??
        '';
  }

  // ---------------------------------------------------------------------------
  // Group sender prefix
  // ---------------------------------------------------------------------------

  static String _senderPrefix({
    required String? senderId,
    required String? senderName,
    required String? currentUserId,
    required String alreadyShown,
    bool includeOthers = true,
  }) {
    final id = senderId?.trim() ?? '';
    final me = currentUserId?.trim() ?? '';
    final name = senderName?.trim() ?? '';
    final String label;
    if (id.isNotEmpty && me.isNotEmpty && me != 'null' && id == me) {
      label = 'You';
    } else {
      if (!includeOthers || name.isEmpty) return '';
      label = name;
    }
    // Legacy payloads without raw content: the backend preview may already
    // carry "<Name>: " (even for my own message). Never show a name twice.
    if (alreadyShown.startsWith('$label:') ||
        alreadyShown.startsWith('You:') ||
        (name.isNotEmpty && alreadyShown.startsWith('$name:'))) {
      return '';
    }
    return '$label: ';
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _clean(String? value) {
    final v = value?.trim() ?? '';
    return v == 'null' ? '' : v;
  }

  /// True when [value] is something a person should see: not empty, not
  /// JSON, not a URL/server path, not a bare numeric id.
  static bool _isReadable(String value) {
    if (value.isEmpty) return false;
    if (value.startsWith('{') || value.startsWith('[')) return false;
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return false;
    }
    if (!value.contains(' ') &&
        (lower.startsWith('uploads/') ||
            lower.startsWith('/uploads') ||
            lower.startsWith('file://') ||
            RegExp(r'\.(jpe?g|png|gif|webp|heic|mp4|mov|mkv|avi|mp3|m4a|aac|wav|pdf|docx?|xlsx?|pptx?|zip)$')
                .hasMatch(lower))) {
      return false;
    }
    if (RegExp(r'^\d+$').hasMatch(value)) return false;
    return true;
  }

  static Map<String, dynamic>? _decodeJson(String value) {
    if (!value.startsWith('{')) return null;
    try {
      return _asMap(jsonDecode(value));
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) return _decodeJson(value.trim());
    return null;
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static int? _countOf(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is List && value.isNotEmpty) return value.length;
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String _formatDuration(dynamic raw) {
    final seconds = raw is num ? raw.round() : _toInt(raw);
    if (seconds == null || seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String? _fileNameFromPath(String value) {
    if (value.isEmpty || value.contains(' ')) return null;
    final name = value.split('?').first.split('/').last;
    if (!name.contains('.')) return null;
    try {
      return Uri.decodeComponent(name);
    } catch (_) {
      return name;
    }
  }
}

class _Body {
  final String icon;
  final String text;
  const _Body(this.icon, this.text);
}
