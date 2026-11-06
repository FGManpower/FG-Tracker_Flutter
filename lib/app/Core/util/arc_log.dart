import 'package:fgtracker/app/Model/PrivateChatModel.dart';
import 'package:flutter/foundation.dart';

/// TEMPORARY [ARC] diagnostics for "archived chats missing / archived group
/// disappears / Archived row blinks". Debug builds only.
/// TODO(arc-diagnostics): remove after the fix is confirmed.

String _key(PrivateChatModel c) {
  final isGroup = c.isGroup == true || c.chatType == 'group' || c.groupId != null;
  return isGroup
      ? 'group_${c.groupId ?? c.id}'
      : 'private_${c.chatId ?? c.conversationId ?? c.id}(user ${c.userId})';
}

/// One line per chat state change.
void arcLog(String stage, String message) {
  if (!kDebugMode) return;
  debugPrint('[ARC] $stage $message');
}

/// A chat and its archive-relevant fields.
String arcChat(PrivateChatModel c) =>
    '${_key(c)} isArchived=${c.isArchived} unread=${c.unreadCount} '
    'moveToTop=${c.moveToTop} msg="${c.message ?? c.preview}"';

/// Both lists at a glance.
String arcLists(List<PrivateChatModel> main, List<PrivateChatModel> archived) {
  final groups = archived
      .where((c) => c.isGroup == true || c.chatType == 'group' || c.groupId != null)
      .length;
  return 'mainCount=${main.length} archivedCount=${archived.length} '
      '(groups=$groups) archived=[${archived.map(_key).join(', ')}]';
}

/// Raw realtime payload fields that decide main vs archived.
String arcPayload(Map<String, dynamic> p) =>
    'chatId=${p['chatId'] ?? p['conversationId']} groupId=${p['groupId']} '
    'chatType=${p['chatType']} isGroup=${p['isGroup']} '
    'isArchived=${p.containsKey('isArchived') ? p['isArchived'] : '<absent>'} '
    'moveToTop=${p['moveToTop']} unreadCount=${p['unreadCount']}';

/// Archived-row rebuild counter (blink measurement).
int _rowBuilds = 0;
DateTime? _rowWindowStart;

void arcRowBuild(int count, int unread) {
  if (!kDebugMode) return;
  final now = DateTime.now();
  if (_rowWindowStart == null ||
      now.difference(_rowWindowStart!) > const Duration(seconds: 2)) {
    _rowWindowStart = now;
    _rowBuilds = 0;
  }
  _rowBuilds++;
  debugPrint('[ARC] archivedRow build #$_rowBuilds in 2s window '
      'visible=${count > 0} N=$count unread=$unread');
}
