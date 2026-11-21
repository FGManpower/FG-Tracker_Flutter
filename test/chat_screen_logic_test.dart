import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/Model/LocationMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_screen_logic.dart';
import 'package:flutter_test/flutter_test.dart';

MessageData msg(int id, {String? at, dynamic sender = 1, String type = 'text'}) =>
    MessageData(
      id: id,
      senderId: sender,
      messageType: type,
      content: 'm$id',
      timestamp: at ?? DateTime.utc(2026, 1, 1, 0, id).toIso8601String(),
    );

List<int?> ids(List<MessageData> l) => l.map((m) => m.id).toList();

void main() {
  group('history merge + dedupe', () {
    test('older page is prepended in time order and dupes dropped', () {
      final loaded = [msg(5), msg(6), msg(7)];
      // Page 2 overlaps (6) because a new message shifted the offsets.
      final r = ChatScreenRules.merge(loaded, [msg(3), msg(4), msg(6)]);
      expect(ids(r.messages), [3, 4, 5, 6, 7]);
      expect(r.added, 2);
      expect(r.prepended, 2);
    });

    test('a page of only duplicates adds nothing', () {
      final loaded = [msg(1), msg(2)];
      final r = ChatScreenRules.merge(loaded, [msg(1), msg(2)]);
      expect(r.added, 0);
      expect(ids(r.messages), [1, 2]);
      // A copy, never the input list (BUG-CS-18: clear() would empty both).
      expect(identical(r.messages, loaded), isFalse);
    });

    test('socket message that arrived before history survives first load', () {
      final socketFirst = [msg(10)];
      final r = ChatScreenRules.merge(socketFirst, [msg(8), msg(9), msg(10)]);
      expect(ids(r.messages), [8, 9, 10]);
    });

    test('newer sync appends without moving the top', () {
      final r = ChatScreenRules.merge([msg(1), msg(2)], [msg(2), msg(3)]);
      expect(ids(r.messages), [1, 2, 3]);
      expect(r.prepended, 0);
    });

    test('date order holds across pages; ties broken by id', () {
      final same = DateTime.utc(2026, 2, 1).toIso8601String();
      final r = ChatScreenRules.merge(
        [msg(20, at: same)],
        [msg(19, at: same), msg(1, at: DateTime.utc(2025, 12, 31).toIso8601String())],
      );
      expect(ids(r.messages), [1, 19, 20]);
    });
  });

  group('HistoryPager', () {
    test('one call at a time, page always advances, stops at the end', () {
      final p = HistoryPager();
      p.complete(page: 1, receivedCount: 20, hasNextPage: true);
      expect(p.begin(), 2);
      expect(p.begin(), isNull, reason: 'second call while loading');
      p.complete(page: 2, receivedCount: 20, hasNextPage: true);
      expect(p.begin(), 3);
      p.complete(page: 3, receivedCount: 7, hasNextPage: false);
      expect(p.hasMore, isFalse);
      expect(p.begin(), isNull);
    });

    test('empty page stops even if the API says hasNextPage', () {
      final p = HistoryPager()..complete(page: 1, receivedCount: 0, hasNextPage: true);
      expect(p.hasMore, isFalse);
    });

    test('without pagination info, a short page means the end', () {
      final p = HistoryPager()..complete(page: 1, receivedCount: 5);
      expect(p.hasMore, isFalse);
    });

    test('failure allows a retry of the same page', () {
      final p = HistoryPager()..complete(page: 1, receivedCount: 20, hasNextPage: true);
      expect(p.begin(), 2);
      p.fail();
      expect(p.begin(), 2);
    });
  });

  group('message menu', () {
    test('attendance has no delete option for anyone', () {
      for (final mine in [true, false]) {
        final o = ChatScreenRules.menuOptions(messageType: 'attendance', isSentByMe: mine);
        expect(o, isNot(contains(MessageMenuOption.deleteForMe)));
        expect(o, isNot(contains(MessageMenuOption.deleteForEveryone)));
        expect(o, contains(MessageMenuOption.reply));
      }
    },
        // Run 2: passed in Run 1; commit e761f45a (2026-11-16) removed the
        // attendance rule. Guide §5.1 still says "not attendance".
        skip: 'BUG-CS-20 (needs decision): attendance cards show delete '
            'options again (chat_screen_logic.dart:210-225)');

    test('attendance cards have no Forward option for anyone', () {
      for (final type in ['attendance', 'attendance_poll', 'ATTENDANCE']) {
        for (final mine in [true, false]) {
          final o = ChatScreenRules.menuOptions(messageType: type, isSentByMe: mine);
          expect(o, isNot(contains(MessageMenuOption.forward)),
              reason: '$type, mine=$mine');
          expect(o, contains(MessageMenuOption.reply));
        }
      }
    });

    test('other types keep their options', () {
      final mineText = ChatScreenRules.menuOptions(messageType: 'text', isSentByMe: true);
      expect(mineText, containsAll([
        MessageMenuOption.reply, MessageMenuOption.copy, MessageMenuOption.forward,
        MessageMenuOption.edit, MessageMenuOption.pin, MessageMenuOption.info,
        MessageMenuOption.deleteForEveryone, MessageMenuOption.deleteForMe,
      ]));
      final theirImage = ChatScreenRules.menuOptions(messageType: 'image', isSentByMe: false);
      expect(theirImage, contains(MessageMenuOption.deleteForMe));
      expect(theirImage, isNot(contains(MessageMenuOption.deleteForEveryone)));
      expect(theirImage, isNot(contains(MessageMenuOption.edit)));
    });

    test('deleted messages allow ONLY Delete for me, never Edit, Forward, Copy, or Info', () {
      for (final type in ['text', 'image', 'video', 'document', 'audio']) {
        final mineDeleted = ChatScreenRules.menuOptions(
          messageType: type,
          isSentByMe: true,
          isDeleted: true,
        );
        expect(mineDeleted, {MessageMenuOption.deleteForMe}, reason: 'Mine deleted $type must have ONLY deleteForMe');

        final theirDeleted = ChatScreenRules.menuOptions(
          messageType: type,
          isSentByMe: false,
          isDeleted: true,
        );
        expect(theirDeleted, {MessageMenuOption.deleteForMe}, reason: 'Their deleted $type must have ONLY deleteForMe');
      }
    });
  });

  group('seen by', () {
    test('excludes me and the sender, by id', () {
      final m = msg(1, sender: 7)..seenBy = ['7', 9, '42', 9, {'userId': 11}];
      expect(ChatScreenRules.seenByOthers(m, currentUserId: '42'), {'9', '11'});
      expect(ChatScreenRules.seenCount(m, currentUserId: '42', isGroup: true), 2);
    });

    test('private count is 0 or 1', () {
      final m = msg(1)..seenCount = '3';
      expect(ChatScreenRules.seenCount(m, currentUserId: '1'), 1);
    });

    test('my own group mark_seen echo marks nothing', () {
      final list = [msg(1, sender: 42), msg(2, sender: 9)];
      final changed = ChatScreenRules.applyGroupSeen(list, readerId: '42', currentUserId: '42');
      expect(changed, isFalse);
      expect(list.every((m) => m.seenBy == null), isTrue);
    });

    test('a reader is never recorded on their own message', () {
      final list = [msg(1, sender: 42), msg(2, sender: 9)];
      ChatScreenRules.applyGroupSeen(list, readerId: '9', currentUserId: '42');
      expect(list[0].seenBy, ['9']);
      expect(list[1].seenBy, isNull);
    });

    test('private seen: only my messages, once, never by me', () {
      final mine = msg(1, sender: '42');
      final theirs = msg(2, sender: '9');
      final list = [mine, theirs];
      ChatScreenRules.applyPrivateSeen(list, messageIds: [1, 2], readerId: '9', currentUserId: '42');
      ChatScreenRules.applyPrivateSeen(list, messageIds: [1, 2], readerId: null, currentUserId: '42');
      expect(mine.seenCount, 1);
      expect(theirs.seenCount, isNull);
      final echo = ChatScreenRules.applyPrivateSeen(
        [msg(3, sender: '42')], messageIds: [3], readerId: '42', currentUserId: '42');
      expect(echo, isFalse);
    });
  });

  group('safe parsing', () {
    test('string id / string pagination no longer throw away the history', () {
      // Before the fix, `int? id = "3"` and `bool? hasNextPage = "1"` threw
      // inside GetMessage.fromJson and the whole chat showed as empty.
      final res = GetMessage.fromJson({
        'status': true,
        'pagination': {'hasNextPage': '1', 'currentPage': '1'},
        'messages': [
          {'id': 1, 'messageType': 'text', 'content': 'hi', 'senderId': 2},
          {'id': '3', 'messageType': 'text', 'content': 'string id'},
          'not a map',
        ],
      });
      expect(res.messageData!.length, 2);
      expect(res.messageData![1].id, 3);
      expect(res.pagination!.hasNextPage, isTrue);
      expect(res.pagination!.currentPage, 1);
    });

    test('row that throws becomes an unsupported placeholder', () {
      final p = MessageData.unsupported({'id': '9', 'senderId': 4, 'createdAt': '2026-01-01T00:00:00Z'});
      expect(p.id, 9);
      expect(ChatScreenRules.isUnsupported(p), isTrue);
    });

    test('unknown type: placeholder only when content is not readable', () {
      expect(ChatScreenRules.isUnsupported(MessageData(messageType: 'sticker_pack', content: '{"a":1}')), isTrue);
      expect(ChatScreenRules.isUnsupported(MessageData(messageType: 'sticker_pack', content: '')), isTrue);
      expect(ChatScreenRules.isUnsupported(MessageData(messageType: 'brand_new', content: 'Hello')), isFalse);
      expect(ChatScreenRules.isUnsupported(MessageData(messageType: 'attendance')), isFalse);
      expect(ChatScreenRules.isUnsupported(MessageData(messageType: 'image')), isFalse);
    });

    test('isCreator / pinned id / block status tolerate strings and ints', () {
      final res = GetMessage.fromJson({
        'status': 'true',
        'isCreator': 1,
        'pinnedMessageId': '12',
        'blockStatus': {'isBlocked': 0, 'blockedByMe': 'false', 'otherUserId': '5'},
        'messages': <dynamic>[],
      });
      expect(res.status, isTrue);
      expect(res.isCreator, isTrue);
      expect(res.pinnedMessageId, 12);
      expect(res.blockStatus!.isBlocked, isFalse);
      expect(res.blockStatus!.otherUserId, 5);
    });
  });

  group('edit / delete events', () {
    test('edit keyed by messageId updates in place and keeps ticks', () {
      final m = msg(5)..isDelivered = true..seenCount = 1..replyId = 2;
      final ok = ChatScreenRules.applyEdit([m], {'messageId': '5', 'content': 'new'});
      expect(ok, isTrue);
      expect(m.content, 'new');
      expect(m.isEdited, isTrue);
      expect(m.isDelivered, isTrue);
      expect(m.seenCount, 1);
      expect(m.replyId, 2);
    });

    test('edit keyed by id (private payload shape) also works', () {
      final m = msg(7);
      expect(ChatScreenRules.applyEdit([m], {'id': 7, 'content': 'x'}), isTrue);
      expect(m.content, 'x');
    });

    test('edit for an unknown message or without content is ignored', () {
      final m = msg(1);
      expect(ChatScreenRules.applyEdit([m], {'messageId': 99, 'content': 'x'}), isFalse);
      expect(ChatScreenRules.applyEdit([m], {'messageId': 1}), isFalse);
      expect(m.content, 'm1');
    });

    test('delete for me only applies to the user who deleted it', () {
      expect(ChatScreenRules.isDeleteForMeByMe({'userId': 42}, '42'), isTrue);
      expect(ChatScreenRules.isDeleteForMeByMe({'userId': 9}, '42'), isFalse);
      // No user id in the event: old behaviour (remove).
      expect(ChatScreenRules.isDeleteForMeByMe({}, '42'), isTrue);
    });

    test('delete for everyone leaves no media, caption or reply', () {
      final m = MessageData(id: 1, messageType: 'media', images: ['a.jpg'], caption: 'c', replyId: 3);
      ChatScreenRules.markDeletedForEveryone(m);
      expect(m.content, 'This message was deleted');
      expect(m.messageType, 'text');
      expect(m.images, isEmpty);
      expect(m.caption, isNull);
      expect(m.replyId, isNull);
      expect(m.isDeleted, isTrue);
    });

    test('attachment edit with caption preserves media URL and updates caption and edited flag', () {
      final m = MessageData(
        id: 10,
        messageType: 'image',
        content: 'https://storage.example.com/photos/pic.jpg',
        caption: 'Old Caption',
        images: ['https://storage.example.com/photos/pic.jpg'],
      );
      final ok = ChatScreenRules.applyEdit([m], {
        'messageId': 10,
        'caption': 'Updated Caption',
        'content': 'https://storage.example.com/photos/pic.jpg',
        'isEdited': true,
      });
      expect(ok, isTrue);
      expect(m.caption, 'Updated Caption');
      expect(m.content, 'https://storage.example.com/photos/pic.jpg');
      expect(m.isEdited, isTrue);
      expect(m.edited, isTrue);
    });

    test('attachment edit with plain text content updates caption instead of overwriting media', () {
      final m = MessageData(
        id: 11,
        messageType: 'document',
        content: 'https://storage.example.com/docs/invoice.pdf',
        caption: 'Invoice July',
      );
      final ok = ChatScreenRules.applyEdit([m], {
        'id': 11,
        'content': 'Invoice August (Corrected)',
      });
      expect(ok, isTrue);
      expect(m.caption, 'Invoice August (Corrected)');
      expect(m.content, 'https://storage.example.com/docs/invoice.pdf');
      expect(m.isEdited, isTrue);
      expect(m.edited, isTrue);
    });

    test('attachment edit works with nested message payload and text/newContent keys', () {
      final m = MessageData(
        id: 12,
        messageType: 'video',
        content: 'https://storage.example.com/videos/clip.mp4',
        caption: 'My Trip',
      );
      final ok = ChatScreenRules.applyEdit([m], {
        'message': {
          'id': 12,
          'text': 'Trip to Mountains 2026',
          'is_edited': true,
        }
      });
      expect(ok, isTrue);
      expect(m.caption, 'Trip to Mountains 2026');
      expect(m.content, 'https://storage.example.com/videos/clip.mp4');
      expect(m.isEdited, isTrue);
      expect(m.edited, isTrue);
    });

    test('document edit preserves path||name||size content and updates caption', () {
      final m = MessageData(
        id: 13,
        messageType: 'document',
        content: 'uploads/docs/doc_123.pdf||Statement.pdf||1024KB',
        caption: 'Old statement',
      );
      final ok = ChatScreenRules.applyEdit([m], {
        'messageId': 13,
        'newContent': 'Updated statement for Q4',
        'isEdited': true,
      });
      expect(ok, isTrue);
      expect(m.caption, 'Updated statement for Q4');
      expect(m.content, 'uploads/docs/doc_123.pdf||Statement.pdf||1024KB');
      expect(m.isEdited, isTrue);
      expect(m.edited, isTrue);
    });

    test('audio edit with caption candidate updates audio caption', () {
      final m = MessageData(
        id: 14,
        messageType: 'audio',
        content: 'uploads/audio/rec_1.mp3',
        caption: 'Original audio description',
      )..audioUrl = 'uploads/audio/rec_1.mp3';
      final ok = ChatScreenRules.applyEdit([m], {
        'id': 14,
        'content': 'Updated audio transcription description',
        'isEdited': true,
      });
      expect(ok, isTrue);
      expect(m.caption, 'Updated audio transcription description');
      expect(m.audioUrl, 'uploads/audio/rec_1.mp3');
      expect(m.isEdited, isTrue);
    });

    test('isAttachment detects various attachment formats and message instances', () {
      expect(ChatScreenRules.isAttachment('image'), isTrue);
      expect(ChatScreenRules.isAttachment('video'), isTrue);
      expect(ChatScreenRules.isAttachment('document'), isTrue);
      expect(ChatScreenRules.isAttachment('audio'), isTrue);
      expect(ChatScreenRules.isAttachment('file'), isTrue);
      expect(ChatScreenRules.isAttachment('photo'), isTrue);
      expect(ChatScreenRules.isAttachment('voice'), isTrue);
      expect(ChatScreenRules.isAttachment('text'), isFalse);

      final mWithImages =
          MessageData(id: 1, messageType: 'media', images: ['pic.jpg']);
      expect(ChatScreenRules.isAttachment('media', mWithImages), isTrue);

      final mWithCaption = MessageData(
          id: 2,
          messageType: 'forward',
          content: 'https://url.com/a.jpg',
          caption: 'Forwarded Photo');
      expect(ChatScreenRules.isAttachment('forward', mWithCaption), isTrue);
    });

    test('looksLikeMediaUrl identifies media URLs vs plain captions', () {
      expect(ChatScreenRules.looksLikeMediaUrl('https://s3.amazonaws.com/pic.jpg'), isTrue);
      expect(ChatScreenRules.looksLikeMediaUrl('http://example.com/doc.pdf'), isTrue);
      expect(ChatScreenRules.looksLikeMediaUrl('/storage/emulated/0/audio.mp3'), isTrue);
      expect(ChatScreenRules.looksLikeMediaUrl('Hello this is my caption'), isFalse);
      expect(ChatScreenRules.looksLikeMediaUrl('Meeting notes for today'), isFalse);
    });

    test('mergeAttachmentFrom updates caption and isEdited flag when message was edited', () {
      final existing = MessageData(
        id: 25,
        messageType: 'image',
        content: 'https://s3.amazonaws.com/pic.jpg',
        caption: 'Old caption',
        images: ['https://s3.amazonaws.com/pic.jpg'],
      );
      final incoming = MessageData(
        id: 25,
        messageType: 'image',
        content: 'https://s3.amazonaws.com/pic.jpg',
        caption: 'New edited caption',
        isEdited: true,
      );

      final changed = existing.mergeAttachmentFrom(incoming);
      expect(changed, isTrue);
      expect(existing.caption, 'New edited caption');
      expect(existing.isEdited, isTrue);
      expect(existing.edited, isTrue);
      expect(existing.content, 'https://s3.amazonaws.com/pic.jpg');
    });
  });

  group('emoji panel height', () {
    test('uses the last keyboard height so the screen does not jump', () {
      expect(ChatScreenRules.emojiPanelHeight(screenHeight: 900, lastKeyboardHeight: 320), 320);
    });
    test('never more than 40% of a small screen', () {
      expect(ChatScreenRules.emojiPanelHeight(screenHeight: 600, lastKeyboardHeight: 350), 240);
    });
    test('falls back when the keyboard height is unknown', () {
      expect(ChatScreenRules.emojiPanelHeight(screenHeight: 900, fallback: 300), 300);
    });
  });

  group('cursor paging helpers (backend v2.8.0 before/after)', () {
    test('oldestId / newestId skip temp bubbles without an id', () {
      final list = [msg(12), MessageData(messageType: 'text', content: 'temp'), msg(9), msg(30)];
      expect(ChatScreenRules.oldestId(list), 9);
      expect(ChatScreenRules.newestId(list), 30);
      expect(ChatScreenRules.oldestId([MessageData(content: 'temp')]), isNull);
      expect(ChatScreenRules.newestId(const []), isNull);
    });

    test('cursorHonoured: before', () {
      expect(ChatScreenRules.cursorHonoured([msg(8), msg(3)], before: 9), isTrue);
      // Server ignored before= and sent the newest page.
      expect(ChatScreenRules.cursorHonoured([msg(20), msg(3)], before: 9), isFalse);
      expect(ChatScreenRules.cursorHonoured([msg(9)], before: 9), isFalse);
      expect(ChatScreenRules.cursorHonoured(const [], before: 9), isTrue);
    });

    test('cursorHonoured: after', () {
      expect(ChatScreenRules.cursorHonoured([msg(31), msg(40)], after: 30), isTrue);
      expect(ChatScreenRules.cursorHonoured([msg(31), msg(12)], after: 30), isFalse);
      expect(ChatScreenRules.cursorHonoured([msg(30)], after: 30), isFalse);
    });

    test('pagination reads hasMore and oldestId', () {
      final p = MessagePagination.fromJson({'limit': 20, 'hasMore': false, 'oldestId': '183160'});
      expect(p.hasMore, isFalse);
      expect(p.oldestId, 183160);
      expect(p.hasNextPage, isNull);
    });
  });

  group('LocationMessage model serialization and live status', () {
    test('static location fromContent and toContent round-trip', () {
      final loc = LocationMessage(
        latitude: 28.6139,
        longitude: 77.2090,
        locationName: 'India Gate',
        address: 'Rajpath, India Gate, New Delhi',
        isLive: false,
      );
      final jsonStr = loc.toContent();
      final parsed = LocationMessage.fromContent(jsonStr);
      expect(parsed.latitude, closeTo(28.6139, 0.0001));
      expect(parsed.longitude, closeTo(77.2090, 0.0001));
      expect(parsed.locationName, 'India Gate');
      expect(parsed.address, 'Rajpath, India Gate, New Delhi');
      expect(parsed.isLive, isFalse);
    });

    test('live location serialization with duration and comment', () {
      final start = DateTime.now();
      final end = start.add(const Duration(hours: 1));
      final liveLoc = LocationMessage(
        latitude: 19.0760,
        longitude: 72.8777,
        locationName: 'Live Location',
        isLive: true,
        durationMinutes: 60,
        startTime: start,
        endTime: end,
        comment: 'I am on my way',
      );
      final jsonStr = liveLoc.toContent();
      final parsed = LocationMessage.fromContent(jsonStr);
      expect(parsed.isLive, isTrue);
      expect(parsed.durationMinutes, 60);
      expect(parsed.comment, 'I am on my way');
      expect(parsed.isEnded, isFalse);
      expect(parsed.liveUntilText.contains('Live until'), isTrue);
    });

    test('expired live location reports isEnded as true', () {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      final end = start.add(const Duration(hours: 1));
      final expired = LocationMessage(
        latitude: 19.0760,
        longitude: 72.8777,
        locationName: 'Live Location',
        isLive: true,
        startTime: start,
        endTime: end,
      );
      expect(expired.isEnded, isTrue);
    });

    test('stopped live location with isLive=false reports isEnded as true', () {
      final liveLoc = LocationMessage(
        latitude: 19.0760,
        longitude: 72.8777,
        locationName: 'Live Location',
        isLive: true,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
      );
      final stopped = liveLoc.copyWith(isLive: false);
      expect(stopped.isEnded, isTrue);
      expect(stopped.liveUntilText, 'Live location ended');
    });

    test('parses lat/lng from various formats (string, int, double)', () {
      final parsedStr = LocationMessage.fromContent('{"latitude":"28.6139","longitude":"77.2090"}');
      expect(parsedStr.latitude, closeTo(28.6139, 0.0001));

      final parsedInt = LocationMessage.fromContent('{"latitude":28,"longitude":77}');
      expect(parsedInt.latitude, 28.0);
    });
  });
}
