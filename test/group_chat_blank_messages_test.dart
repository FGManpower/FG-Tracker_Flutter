// BUG-CS-18: group chat messages went blank.
//
// `ChatScreenRules.merge` used to return the SAME list object it was given
// when the incoming page added nothing new. Controller paths then ran
// `_messages..clear()..addAll(merged.messages)`, so clearing `_messages` also
// emptied `merged.messages` and the chat went blank until reopened.
// Fix: merge() always returns a new list (chat_screen_logic.dart).
//
// Each case below runs the exact controller statements with the real
// ChatScreenRules.merge and MessageData. Before the fix they failed:
// 60 -> 0 and 30 -> 0 messages.
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';

MessageData msg(
  int id, {
  bool delivered = false,
  int? seenCount,
  bool edited = false,
  bool deleted = false,
  String? text,
}) =>
    MessageData(
      id: id,
      senderId: 1,
      messageType: 'text',
      content: text ?? (deleted ? 'This message was deleted' : 'm$id'),
      isDelivered: delivered,
      seenCount: seenCount,
      isEdited: edited,
      isDeleted: deleted,
      timestamp: DateTime.utc(2026, 1, 1, 0, id).toIso8601String(),
    );

List<int?> ids(List<MessageData> l) => l.map((m) => m.id).toList();

/// `_messages..clear()..addAll(merged.messages)`, as in the controllers.
void applyMerge(List<MessageData> messages, MergeResult merged) {
  messages
    ..clear()
    ..addAll(merged.messages);
}

void main() {
  group('merge() never returns the input list', () {
    test('nothing new', () {
      final loaded = [msg(1), msg(2), msg(3)];
      final r = ChatScreenRules.merge(loaded, [msg(2), msg(3)]);
      expect(r.added, 0);
      expect(identical(r.messages, loaded), isFalse);
      expect(ids(r.messages), [1, 2, 3]);
    });

    test('empty page', () {
      final loaded = [msg(1)];
      final r = ChatScreenRules.merge(loaded, const []);
      expect(identical(r.messages, loaded), isFalse);
      expect(ids(r.messages), [1]);
    });

    test('only ticks changed (updated, nothing added)', () {
      final loaded = [msg(1), msg(2)];
      final r = ChatScreenRules.merge(loaded, [msg(2, delivered: true)]);
      expect(r.updated, isTrue);
      expect(identical(r.messages, loaded), isFalse);
      // Same objects are kept, with the new state applied in place.
      expect(identical(r.messages[1], loaded[1]), isTrue);
      expect(r.messages[1].isDelivered, isTrue);
    });

    test('new messages added', () {
      final loaded = [msg(2)];
      final r = ChatScreenRules.merge(loaded, [msg(1), msg(3)]);
      expect(identical(r.messages, loaded), isFalse);
      expect(ids(r.messages), [1, 2, 3]);
    });
  });

  group('group chat cases (GroupChatController)', () {
    test(
        'getGroupMessages() again after add / remove member, rename, icon '
        'keeps all loaded messages', () {
      // 60 on screen: page 1 + an older page already scrolled in.
      final messages = [for (var i = 1; i <= 60; i++) msg(i)];
      // Page 1 again from the server: newest 30, all already loaded.
      final page1 = [for (var i = 31; i <= 60; i++) msg(i)];

      applyMerge(messages, ChatScreenRules.merge(messages, page1));

      expect(messages, hasLength(60));
      expect(ids(messages).first, 1);
      expect(ids(messages).last, 60);
    });

    test('getGroupMessages() with a new system message ("X added Y") adds it',
        () {
      final messages = [for (var i = 1; i <= 30; i++) msg(i)];
      final page1 = [for (var i = 2; i <= 31; i++) msg(i)];

      applyMerge(messages, ChatScreenRules.merge(messages, page1));

      expect(messages, hasLength(31));
      expect(ids(messages).last, 31);
    });

    test('resume / reconnect reconcile when only ticks changed keeps the list',
        () {
      final messages = [for (var i = 1; i <= 30; i++) msg(i)];
      final recent = [
        for (var i = 1; i <= 29; i++) msg(i),
        msg(30, delivered: true, seenCount: 2),
      ];

      // Exact statements from syncNewerMessages() "Reconcile" block.
      final recentMerge = ChatScreenRules.merge(messages, recent);
      expect(recentMerge.updated, isTrue);
      expect(recentMerge.added, 0);
      if (recentMerge.updated || recentMerge.added > 0) {
        applyMerge(messages, recentMerge);
      }

      expect(messages, hasLength(30));
      expect(messages.last.isDelivered, isTrue);
      expect(messages.last.seenCount, 2);
    });

    test('reconnect after an edit / delete made while offline keeps the list',
        () {
      final messages = [for (var i = 1; i <= 30; i++) msg(i)];
      final recent = [
        for (var i = 1; i <= 28; i++) msg(i),
        msg(29, edited: true, text: 'edited text'),
        msg(30, deleted: true),
      ];

      final recentMerge = ChatScreenRules.merge(messages, recent);
      expect(recentMerge.updated, isTrue);
      applyMerge(messages, recentMerge);

      expect(messages, hasLength(30));
      expect(messages[28].content, 'edited text');
      expect(messages[29].isDeleted, isTrue);
    });

    test('older page of only duplicates (scrolling up) keeps the list', () {
      final messages = [for (var i = 31; i <= 60; i++) msg(i)];
      final olderDupes = [for (var i = 31; i <= 40; i++) msg(i)];
      final merged = ChatScreenRules.merge(messages, olderDupes);
      if (merged.added > 0) applyMerge(messages, merged);
      expect(messages, hasLength(30));
    });

    test('1000+ messages: page 1 again keeps all of them', () {
      final messages = [for (var i = 1; i <= 1200; i++) msg(i)];
      final page1 = [for (var i = 1171; i <= 1200; i++) msg(i)];
      applyMerge(messages, ChatScreenRules.merge(messages, page1));
      expect(messages, hasLength(1200));
    });
  });

  group('private chat cases (MessageController, same pattern)', () {
    test('history page that holds only messages already on screen', () {
      // e.g. the first message arrived by socket before history returned.
      final messages = [msg(1), msg(2)];
      final page = [msg(2), msg(1)]; // API order: newest first

      applyMerge(
        messages,
        ChatScreenRules.merge(messages, page.reversed.toList()),
      );

      expect(ids(messages), [1, 2]);
    });
  });
}
