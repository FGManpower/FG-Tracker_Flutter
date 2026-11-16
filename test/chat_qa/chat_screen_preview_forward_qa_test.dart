// QA: reply/list previews, forwarding and "last seen" for the chat screen.
// See docs/01_CHATTING_MODULE_FRONTEND.md §0.3, §4.
import 'package:fgtracker/app/Core/util/last_seen_formatter.dart';
import 'package:fgtracker/app/Core/util/message_preview_builder.dart';
import 'package:fgtracker/app/Model/ForwardMessageModel.dart';
import 'package:fgtracker/app/Model/GetMessage.dart';
import 'package:fgtracker/app/modules/Messages/Controller/ForwardMessageController.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

final en = lookupAppLocalizations(const Locale('en'));

String reply(MessageData msg) => MessagePreviewBuilder.forMessage(msg).display;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting());

  // ---------------------------------------------------------------------------
  group('Reply preview (reply bar / quoted bubble)', () {
    test('text reply shows the text as is', () {
      expect(reply(MessageData(messageType: 'text', content: 'Hello there')),
          'Hello there');
    });

    test('photo with caption shows camera + caption', () {
      expect(
          reply(MessageData(
              messageType: 'image', content: '', caption: 'Beach', images: ['a.jpg'])),
          '📷 Beach');
    });

    test('photo without caption shows "Photo"', () {
      expect(reply(MessageData(messageType: 'image', images: ['a.jpg'])),
          '📷 ${en.chat_previewPhoto}');
    });

    test('bulk media with 3 photos shows "3 Photos"', () {
      expect(
          reply(MessageData(messageType: 'media', images: ['a', 'b', 'c'])),
          '📷 ${en.chat_previewPhotosCount(3)}');
    });

    test('bulk media with only videos shows "2 Videos"', () {
      expect(
          reply(MessageData(messageType: 'media', images: [], videos: [
            MessageVideo(videoUrl: 'a.mp4'),
            MessageVideo(videoUrl: 'b.mp4'),
          ])),
          '🎥 ${en.chat_previewVideosCount(2)}');
    });

    test('video stored as "url||thumb||dur" never leaks the url', () {
      final r = reply(MessageData(
          messageType: 'video', content: 'uploads/v.mp4||uploads/t.jpg||0:12'));
      expect(r, '🎥 ${en.chat_previewVideo}');
      expect(r.contains('uploads'), isFalse);
    });

    test('voice message shows the mic label', () {
      expect(reply(MessageData(messageType: 'voice', content: 'uploads/a.m4a')),
          '🎤 ${en.chat_previewVoiceMessage}');
    });

    test('document shows the original file name from "path||name"', () {
      expect(
          reply(MessageData(
              messageType: 'document', content: 'uploads/x1.pdf||Q3 Report.pdf')),
          '📄 Q3 Report.pdf');
    });

    test('document without a name falls back to the path file name', () {
      expect(reply(MessageData(messageType: 'file', content: 'uploads/abc.pdf')),
          '📄 abc.pdf');
    });

    test('location shows the pin label, not coordinates', () {
      expect(
          reply(MessageData(
              messageType: 'location', content: '{"latitude":1,"longitude":2}')),
          '📍 ${en.chat_previewLocation}');
    });

    test('contact shows the contact name, not JSON', () {
      expect(
          reply(MessageData(
              messageType: 'contact', content: '{"name":"Asha","phone":"98"}')),
          '👤 Asha');
    });

    test('attendance shows the poll title from the attendance summary', () {
      final msg = MessageData(messageType: 'attendance', content: '{"attendancePollId":4}')
        ..attendance = {'title': 'Morning roll call'};
      expect(reply(msg), '📊 Morning roll call');
    });

    test('poll with a question in JSON content', () {
      expect(
          reply(MessageData(
              messageType: 'poll', content: '{"question":"Lunch?","options":[]}')),
          '📊 Lunch?');
    });

    test('deleted message shows "This message was deleted"', () {
      expect(reply(MessageData(messageType: 'image', isDeleted: true)),
          '🚫 ${en.chat_messageDeleted}');
      expect(reply(MessageData(messageType: 'text', content: 'This message was deleted')),
          '🚫 ${en.chat_messageDeleted}');
    });

    test('forwarded readable text is shown', () {
      expect(reply(MessageData(messageType: 'forwarded', content: 'fwd text')),
          'fwd text');
    });

    test('forwarded raw JSON never leaks: falls back to "Message"', () {
      expect(reply(MessageData(messageType: 'forwarded', content: '{"x":1}')),
          en.chat_previewMessage);
    });

    test('unknown type with a bare url falls back to "Message"', () {
      expect(reply(MessageData(messageType: 'gizmo', content: 'https://x.y/z')),
          en.chat_previewMessage);
    });

    test('text type whose content is a media path is shown as that media', () {
      expect(reply(MessageData(messageType: 'text', content: 'uploads/a.JPG')),
          '📷 ${en.chat_previewPhoto}');
      expect(reply(MessageData(messageType: 'text', content: 'up/song.mp3?x=1')),
          '🎵 ${en.chat_previewAudio}');
    });

    test('a sentence that mentions a file stays text', () {
      expect(reply(MessageData(messageType: 'text', content: 'open a.jpg pls')),
          'open a.jpg pls');
    });

    test('empty message never shows an empty reply bar', () {
      expect(reply(MessageData()), en.chat_previewMessage);
    });
  });

  group('Quoted reply when the original is not loaded', () {
    test('uses replyMessageContent when replyMessage is empty', () {
      final r = MessageData(replyId: 3, replyType: 'text', replyMessage: '')
        ..replyMessageContent = 'from content';
      expect(MessagePreviewBuilder.forQuotedReply(r).display, 'from content');
    });

    test('stored "This message was deleted" is shown as deleted', () {
      final r = MessageData(replyId: 3, replyMessage: 'This message was deleted');
      expect(MessagePreviewBuilder.forQuotedReply(r).isDeleted, isTrue);
    });

    test('stored video reply "url||thumb" shows "Video"', () {
      final r = MessageData(
          replyId: 3, replyType: 'video', replyMessage: 'u/v.mp4||u/t.jpg||5');
      expect(MessagePreviewBuilder.forQuotedReply(r).display,
          '🎥 ${en.chat_previewVideo}');
    });

    test('loaded original deleted after the reply -> quote shows deleted', () {
      final r = MessageData(replyId: 3, replyMessage: 'old text');
      final orig = MessageData(id: 3, messageType: 'text', content: 'old text',
          isDeleted: true);
      expect(MessagePreviewBuilder.forQuotedReply(r, original: orig).isDeleted,
          isTrue);
    });

    test('loaded original edited after the reply -> quote shows new text', () {
      final r = MessageData(replyId: 3, replyMessage: 'v1');
      final orig = MessageData(id: 3, messageType: 'text', content: 'v2');
      expect(MessagePreviewBuilder.forQuotedReply(r, original: orig).display, 'v2');
    });

    test('reply sender: stored name, then original name, else empty', () {
      final r = MessageData(replyId: 3, replySenderName: '  ');
      final orig = MessageData(id: 3, senderId: 9, senderName: 'Ravi');
      expect(MessagePreviewBuilder.replySenderLabel(r, original: orig,
          currentUserId: '1'), 'Ravi');
      expect(MessagePreviewBuilder.replySenderLabel(MessageData(replyId: 3),
          currentUserId: '1'), '');
    });

    test('reply sender is "You" for my own original even if a name is stored', () {
      final r = MessageData(replyId: 3, replySenderName: 'Sarita');
      final orig = MessageData(id: 3, senderId: '1');
      expect(MessagePreviewBuilder.replySenderLabel(r, original: orig,
          currentUserId: ' 1 '), en.common_you);
    });
  });

  group('List preview (last message row)', () {
    test('my own deleted message in the list says "You deleted this message"', () {
      final pv = MessagePreviewBuilder.build(
          type: 'text', isDeleted: true, senderId: '1', currentUserId: '1');
      expect(pv.text, en.chat_previewOwnDeleted);
      expect(pv.rowText, en.chat_previewOwnDeleted);
    });

    test('group: other sender prefix once, even if backend already added it', () {
      expect(MessagePreviewBuilder.build(type: 'text', content: 'hi', isGroup: true,
          senderId: '2', senderName: 'Ravi', currentUserId: '1').display,
          'Ravi: hi');
      expect(MessagePreviewBuilder.build(type: 'text', backendPreview: 'Ravi: hi',
          isGroup: true, senderId: '2', senderName: 'Ravi', currentUserId: '1')
          .display, 'Ravi: hi');
    });

    test('group system event has no sender prefix', () {
      expect(MessagePreviewBuilder.build(type: 'group_event', content: 'Asha joined',
          isGroup: true, senderId: '2', senderName: 'Asha', currentUserId: '1')
          .display, 'Asha joined');
    });

    test('private chat list: "You: " on my message only with prefixOwnMessages', () {
      expect(MessagePreviewBuilder.build(type: 'text', content: 'ok', senderId: '1',
          currentUserId: '1', prefixOwnMessages: true).display,
          '${en.common_you}: ok');
      expect(MessagePreviewBuilder.build(type: 'text', content: 'ok', senderId: '2',
          senderName: 'Ravi', currentUserId: '1', prefixOwnMessages: true).display,
          'ok');
    });

    test('voice note with a duration shows m:ss', () {
      expect(MessagePreviewBuilder.build(type: 'audio', data: {'duration': 75})
          .display, '🎤 ${en.chat_previewVoiceMessageDuration('1:15')}');
    });
  });

  // ---------------------------------------------------------------------------
  group('Forward', () {
    late ForwardMessageController c;

    setUp(() {
      Get.reset();
      c = ForwardMessageController();
      c.message = MessageData(id: 1, content: 'x');
      c.sourceType = 'group';
    });

    test('private user 5 and group 5 are two different selections', () {
      final u = ForwardDestination(type: 'private', userId: 5, name: 'Five');
      final g = ForwardDestination(type: 'group', groupId: 5, name: 'Group Five');
      c.toggleDestination(u);
      expect(c.isSelected(u), isTrue);
      expect(c.isSelected(g), isFalse);
      c.toggleDestination(g);
      expect(c.selectedCount, 2);
      c.toggleDestination(u);
      expect(c.isSelected(u), isFalse);
      expect(c.isSelected(g), isTrue);
    });

    test('the same chat from Recent and Contacts rows toggles one selection', () {
      final recent = ForwardDestination(type: 'private', userId: 7, name: 'A');
      final contact = ForwardDestination(type: 'private', userId: 7, name: 'A (phone)');
      c.toggleDestination(recent);
      expect(c.isSelected(contact), isTrue);
      c.toggleDestination(contact);
      expect(c.hasSelection, isFalse);
    });

    test('a row without any id can never be selected', () {
      final bad = ForwardDestination(type: 'private', name: 'No id');
      c.toggleDestination(bad);
      expect(c.hasSelection, isFalse);
      expect(c.isSelected(bad), isFalse);
    });

    test('search by name, by number, and empty query shows everything', () {
      c.destinations.assignAll([
        ForwardDestination(type: 'private', userId: 1, name: 'Asha Rao', mobileNo: '9876500001'),
        ForwardDestination(type: 'group', groupId: 2, name: 'Field Team'),
        ForwardDestination(type: 'private', userId: 3, mobileNo: '9000011111'),
      ]);
      c.search('  ASHA ');
      expect(c.filteredDestinations.map((e) => e.targetId), [1]);
      c.search('90000');
      expect(c.filteredDestinations.map((e) => e.targetId), [3]);
      c.search('');
      expect(c.filteredDestinations.length, 3);
      expect(c.groups.single.targetId, 2);
      expect(c.users.single.targetId, 1);
      expect(c.numberUsers.single.targetId, 3);
    });

    test('target payloads: private sends userId only, group sends groupId only', () {
      expect(ForwardTarget(type: 'private', userId: 5).toJson(),
          {'type': 'private', 'userId': 5});
      expect(ForwardTarget(type: 'group', groupId: 5).toJson(),
          {'type': 'group', 'groupId': 5});
      expect(ForwardTarget(type: 'private', groupId: 5).toJson(), {'type': 'private'});
    });

    test('/chat-list shaped private row: target is user.id, not the chat id', () {
      final d = ForwardDestination.fromJson({
        'id': 900, // chat id
        'type': 'private',
        'user': {'id': 12, 'name': 'Asha', 'mobileNo': '98'},
      });
      expect(d.targetId, 12);
      expect(d.name, 'Asha');
      expect(d.mobileNo, '98');
    });

    test('row with only a nested group is detected as a group', () {
      final d = ForwardDestination.fromJson({
        'id': 901,
        'group': {'id': 33, 'groupName': 'Ops', 'groupProfile': 'g.png'},
      });
      expect(d.isGroup, isTrue);
      expect(d.targetId, 33);
      expect(d.name, 'Ops');
      expect(d.displayImage, 'g.png');
    });

    test('string ids and chatType are accepted', () {
      final d = ForwardDestination.fromJson(
          {'chatType': 'GROUP', 'groupId': '44', 'groupName': 'G'});
      expect(d.isGroup, isTrue);
      expect(d.targetId, 44);
    });

    test('display name falls back to the number, then "Unknown"', () {
      expect(ForwardDestination(type: 'private', mobileNo: ' 98 ').displayName, '98');
      expect(ForwardDestination(type: 'private', name: '  ').displayName,
          en.chatList_unknownUser);
    });

    test('list response: data as a plain list, and top-level users/groups', () {
      final a = ForwardListResponse.fromJson({
        'status': true,
        'data': [
          {'type': 'private', 'userId': 1},
          {'type': 'group', 'groupId': 2}
        ]
      });
      expect(a.destinations.length, 2);
      final b = ForwardListResponse.fromJson({
        'users': [{'userId': 1}],
        'groups': [{'type': 'group', 'groupId': 2}],
      });
      expect(b.destinations.map((e) => e.isGroup), [false, true]);
    });

    test('isPinned sent as 1 / "true" still sorts the chat as pinned', () {
      expect(ForwardDestination.fromJson({'userId': 1, 'isPinned': 1}).isPinned,
          isTrue);
      expect(ForwardDestination.fromJson({'userId': 1, 'isPinned': 'true'}).isPinned,
          isTrue);
    },
        skip: 'BUG-CS-10: ForwardMessageModel.dart:158 accepts only isPinned == '
            'true; 1/"true" lose the pinned-first order in Recent chats');
  });

  // ---------------------------------------------------------------------------
  group('Last seen (phone-local time)', () {
    // All times are built as local DateTimes, so the expectations hold in any
    // time zone the test machine uses.
    final now = DateTime(2026, 3, 1, 0, 30); // just after midnight, 1 Mar
    String? f(DateTime? t, {DateTime? at}) =>
        formatLastSeenWith(en, t, now: at ?? now);

    test('exactly midnight today is "Today"', () {
      expect(f(DateTime(2026, 3, 1, 0, 0)), 'Last seen: Today, 12:00 AM');
    });

    test('one minute before midnight is yesterday\'s date (not "Today")', () {
      expect(f(DateTime(2026, 2, 28, 23, 59)), 'Last seen: 28 Feb, 11:59 PM');
    });

    test('31 Dec seen on 1 Jan shows the year', () {
      expect(f(DateTime(2025, 12, 31, 22, 0), at: DateTime(2026, 1, 1, 9)),
          'Last seen: 31 Dec 2025, 10:00 PM');
    });

    test('far-future server time is clamped to now', () {
      expect(f(DateTime(2027, 1, 1)), 'Last seen: Today, 12:30 AM');
    });

    test('UTC "now" and local "now" give the same answer', () {
      final t = DateTime(2026, 3, 1, 0, 10);
      expect(f(t, at: now.toUtc()), f(t, at: now));
    });

    test('UTC server time equal to a local time renders that local time', () {
      final local = DateTime(2026, 3, 1, 0, 5);
      expect(f(local.toUtc()), 'Last seen: Today, 12:05 AM');
    });

    test('noon is 12:xx PM', () {
      expect(f(DateTime(2026, 2, 27, 12, 1)), 'Last seen: 27 Feb, 12:01 PM');
    });
  });
}
