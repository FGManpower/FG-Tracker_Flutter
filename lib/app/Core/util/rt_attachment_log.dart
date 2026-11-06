import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:flutter/foundation.dart';

/// TEMPORARY [RT] diagnostics: "attachments not shown live / just-sent voice
/// note doesn't play". Debug builds only; silent for text messages.
/// TODO(rt-diagnostics): remove after the fix is confirmed.

const Set<String> _attachmentTypes = {
  'image', 'image_text', 'media', 'video', 'document', 'file',
  'audio', 'voice', 'voice_note',
};

bool _isAttachment(dynamic type) =>
    _attachmentTypes.contains(type?.toString().toLowerCase().trim() ?? '');

Map<String, dynamic>? _unwrap(dynamic data) {
  if (data is! Map) return null;
  final map = Map<String, dynamic>.from(data);
  if (map['message'] is Map) return Map<String, dynamic>.from(map['message']);
  if (map['data'] is Map) return Map<String, dynamic>.from(map['data']);
  return map;
}

/// How many times each message id arrived over the socket (#3).
final Map<String, int> _seenCount = {};

/// Same rule the image tiles use today: absolute URL as is, else base + path.
String _tileUrl(String path) {
  final v = path.trim();
  if (v.isEmpty) return '';
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  return '${ConstRes.aImageBaseUrl}$v';
}

/// #2 upload API response.
void rtUpload(String api, dynamic response) {
  if (!kDebugMode) return;
  debugPrint('[RT] $api RESPONSE => $response');
}

/// #3 raw socket payload + count per id.
void rtSocketRaw(String stage, dynamic data) {
  if (!kDebugMode) return;
  final m = _unwrap(data);
  if (m == null || !_isAttachment(m['messageType'] ?? m['type'])) return;
  final id = '${m['id']}';
  final count = (_seenCount[id] ?? 0) + 1;
  _seenCount[id] = count;
  debugPrint('[RT] $stage RAW #$count id=$id type=${m['messageType']} '
      'sender=${m['senderId']} receiver=${m['receiverId']} group=${m['groupId']} '
      'clientMessageId=${m['clientMessageId']} content=${m['content']} '
      'images=${m['images']} mediaUrls=${m['mediaUrls']} audios=${m['audios']} '
      'audioUrl=${m['audioUrl']} files=${m['files']} videos=${m['videos']}');
}

/// #4 listener / list decision.
void rtDecision(String stage, dynamic data, String decision) {
  if (!kDebugMode) return;
  final m = data is MessageData ? null : _unwrap(data);
  final type = data is MessageData ? data.messageType : m?['messageType'];
  if (!_isAttachment(type)) return;
  final id = data is MessageData ? data.id : m?['id'];
  debugPrint('[RT] $stage id=$id type=$type => $decision');
}

/// #1 / #5 / #6 model the bubble reads (+ list state).
void rtModel(String stage, MessageData m, {String extra = ''}) {
  if (!kDebugMode || !_isAttachment(m.messageType)) return;
  final images = m.images ?? const <String>[];
  debugPrint('[RT] $stage MODEL id=${m.id} clientMessageId=${m.clientMessageId} '
      'type=${m.messageType} sender=${m.senderId} content="${m.content}" '
      'images=$images imageUrls=${images.map(_tileUrl).toList()} '
      'videos=${m.videos?.map((v) => v.videoUrl).toList()} $extra');
}

/// #7 voice play.
void rtPlay(String stage, String url, {Object? error}) {
  if (!kDebugMode) return;
  debugPrint('[RT] $stage url="$url"${error != null ? ' ERROR=$error' : ''}');
}
