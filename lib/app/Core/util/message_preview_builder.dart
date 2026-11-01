import 'dart:convert';

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
  static const String fallbackText = 'New message';

  /// Preview for a row of the unified (Common/Private/Group) chat list and
  /// the archived list.
  static MessagePreview forChat(
    PrivateChatModel chat, {
    String? currentUserId,
  }) {
    return build(
      type: chat.messageType,
      backendPreview: chat.preview,
      content: chat.message,
      caption: chat.lastMessageData?['caption']?.toString(),
      data: chat.lastMessageData,
      isDeleted: chat.isDeletedForEveryone == true,
      isGroup: chat.isGroup == true,
      senderId: chat.senderId,
      senderName: chat.senderName,
      currentUserId: currentUserId,
    );
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
  }) {
    final kind = isDeleted ? MessageKind.deleted : MessageTypes.kindOf(type);

    if (kind == MessageKind.deleted) {
      return const MessagePreview(
        kind: MessageKind.deleted,
        icon: '🚫',
        text: deletedText,
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

    final prefix = (isGroup && kind != MessageKind.system)
        ? _senderPrefix(
            senderId: senderId,
            senderName: senderName,
            currentUserId: currentUserId,
            alreadyShown: body.text,
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
  }) {
    final id = senderId?.trim() ?? '';
    final me = currentUserId?.trim() ?? '';
    final String label;
    if (id.isNotEmpty && me.isNotEmpty && me != 'null' && id == me) {
      label = 'You';
    } else {
      final name = senderName?.trim() ?? '';
      if (name.isEmpty) return '';
      label = name;
    }
    // Backend may already prefix the preview; never show it twice.
    if (alreadyShown.startsWith('$label:') || alreadyShown.startsWith('You:')) {
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
