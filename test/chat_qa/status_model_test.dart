// QA tests for lib/app/Model/status_model.dart (status / stories parsing).
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String get base => ConstRes.socketUrl.replaceAll(RegExp(r'/$'), '');

Map<String, dynamic> item({
  Object id = 1,
  String? type,
  String? expiresAt,
  bool isViewed = false,
  Object? viewsCount,
  List<Map<String, dynamic>> viewers = const [],
  Map<String, dynamic>? user,
  String? mediaUrl,
  bool? isDeleted,
}) =>
    {
      'id': id,
      if (type != null) 'type': type,
      if (expiresAt != null) 'expiresAt': expiresAt,
      'isViewed': isViewed,
      if (viewsCount != null) 'viewsCount': viewsCount,
      'viewers': viewers,
      if (user != null) 'user': user,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (isDeleted != null) 'isDeleted': isDeleted,
    };

void main() {
  group('feed / my-status responses', () {
    test('StatusFeedRes groups statuses per user and skips bad rows', () {
      final res = StatusFeedRes.fromJson({
        'status': true,
        'data': [
          {
            'user': {'id': 7, 'name': 'Asha'},
            'isAllViewed': false,
            'latestTimestamp': '2026-11-16T10:00:00Z',
            'statuses': [item(id: 1), item(id: '2'), 'junk'],
          },
          'not a map',
          {
            'user': {'UserId': '8', 'Name': 'Ravi'},
            'isAllViewed': true,
            'statuses': [item(id: 3, isViewed: true)],
          },
        ],
      });
      expect(res.status, isTrue);
      expect(res.data.map((g) => g.user.id), [7, 8]);
      expect(res.data.first.statuses.map((s) => s.id), [1, 2]);
      expect(res.data.last.user.name, 'Ravi');
    });

    test('non-map payload gives status=false and an empty list', () {
      final feed = StatusFeedRes.fromJson('oops');
      final mine = MyStatusRes.fromJson(null);
      expect(feed.status, isFalse);
      expect(feed.data, isEmpty);
      expect(mine.status, isFalse);
      expect(mine.data, isEmpty);
    });

    test('MyStatusRes parses own statuses, missing data = empty', () {
      expect(MyStatusRes.fromJson({'status': true}).data, isEmpty);
      final r = MyStatusRes.fromJson({
        'status': true,
        'data': [item(id: 10), item(id: 11)]
      });
      expect(r.data.map((s) => s.id), [10, 11]);
    });

    test('StatusCreateRes parses the created status', () {
      final r = StatusCreateRes.fromJson(
          {'status': true, 'message': 'ok', 'data': item(id: 99)});
      expect(r.data?.id, 99);
      expect(StatusCreateRes.fromJson({'status': 'true'}).status, isFalse,
          reason: 'only boolean true counts');
    });
  });

  group('StatusItemModel.fromJson', () {
    test('defaults when fields are missing', () {
      final s = StatusItemModel.fromJson({'id': 'x'});
      expect(s.id, 0);
      expect(s.type, 'image');
      expect(s.content, '');
      expect(s.backgroundColor, '#6B4DFF');
      expect(s.fontStyle, 'default');
      expect(s.durationSeconds, 5);
      expect(s.privacyType, 'ALL_CONTACTS');
      expect(s.isViewed, isFalse);
      expect(s.isDeleted, isFalse);
      expect(s.viewers, isEmpty);
    });

    test('viewsCount falls back to the number of viewers', () {
      final s = StatusItemModel.fromJson(item(viewers: [
        {'viewerId': 1, 'name': 'A'},
        {'viewerId': 2, 'name': 'B'},
      ]));
      expect(s.viewsCount, 2);
      expect(StatusItemModel.fromJson(item(viewsCount: '9')).viewsCount, 9);
    });

    test('userId falls back to creator / user id', () {
      final s = StatusItemModel.fromJson(item(user: {'id': 42, 'name': 'Z'}));
      expect(s.userId, 42);
      expect(s.creator?.name, 'Z');
    });

    test('relative media path is resolved against the server, absolute kept',
        () {
      expect(StatusItemModel.fromJson(item(mediaUrl: '/uploads/s/a.jpg')).mediaUrl,
          '$base/uploads/s/a.jpg');
      expect(
          StatusItemModel.fromJson(item(mediaUrl: 'https://cdn.x/a.jpg'))
              .mediaUrl,
          'https://cdn.x/a.jpg');
      expect(StatusItemModel.fromJson(item(mediaUrl: '  ')).mediaUrl, isNull);
    });

    test('type is lower-cased; video/image/text getters', () {
      expect(StatusItemModel.fromJson(item(type: 'VIDEO')).isVideo, isTrue);
      expect(
          StatusItemModel.fromJson(item(type: 'image', mediaUrl: 'a.MP4'))
              .isVideo,
          isTrue,
          reason: 'video detected by extension too');
      expect(StatusItemModel.fromJson(item(type: 'Photo')).isImage, isTrue);
      expect(StatusItemModel.fromJson(item(type: 'TEXT')).isText, isTrue);
    });
  });

  group('expiry', () {
    test('expiresAt in the past = expired', () {
      final past =
          DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      expect(
          StatusItemModel.fromJson(item(expiresAt: past.toIso8601String()))
              .isExpired,
          isTrue);
    });

    test('expiresAt in the future = not expired', () {
      final future = DateTime.now().toUtc().add(const Duration(hours: 23));
      expect(
          StatusItemModel.fromJson(item(expiresAt: future.toIso8601String()))
              .isExpired,
          isFalse);
    });

    test('no expiresAt is never expired (client has no 24h rule)', () {
      final old = StatusItemModel.fromJson({
        'id': 1,
        'createdAt': DateTime.now()
            .toUtc()
            .subtract(const Duration(hours: 30))
            .toIso8601String(),
      });
      expect(old.isExpired, isFalse);
    });

    test('deleted status counts as expired', () {
      expect(StatusItemModel.fromJson(item(isDeleted: true)).isExpired, isTrue);
    });
  });

  group('viewer / creator / group', () {
    test('viewer parsed from nested user, profile path goes to uploads/Auth',
        () {
      final v = StatusViewerModel.fromJson({
        'user': {'id': '5', 'name': 'Meena', 'profilePic': 'p.jpg'},
        'emoji': '🔥',
        'viewedAt': '2026-11-16T09:00:00Z',
      });
      expect(v.viewerId, 5);
      expect(v.name, 'Meena');
      expect(v.profileImage, '$base/uploads/Auth/p.jpg');
      expect(v.reactionEmoji, '🔥');
      expect(v.viewedAt, isNotNull);
    });

    test('profile path already under uploads/ is not double-prefixed', () {
      final c = StatusCreatorUser.fromJson(
          {'id': 1, 'name': 'A', 'profilePic': '/uploads/x/p.png'});
      expect(c.profilePic, '$base/uploads/x/p.png');
    });

    test('missing name falls back to the localized "User"', () {
      expect(StatusCreatorUser.fromJson({'id': 1}).name, 'User');
    });

    test('ring colour: green when unviewed, grey when all viewed', () {
      final unseen = ContactStatusGroupModel.fromJson(
          {'user': {'id': 1}, 'isAllViewed': false});
      final seen = ContactStatusGroupModel.fromJson(
          {'user': {'id': 1}, 'isAllViewed': true});
      expect(unseen.ringColor, const Color(0xFF22C55E));
      expect(seen.ringColor, const Color(0xFF9CA3AF));
    });
  });

  group('helpers', () {
    test('copyWith marks viewed and keeps identity fields', () {
      final s = StatusItemModel.fromJson(item(id: 3, type: 'text'));
      final v = s.copyWith(isViewed: true, myReaction: '❤️');
      expect(v.id, 3);
      expect(v.type, 'text');
      expect(v.isViewed, isTrue);
      expect(v.myReaction, '❤️');
    });

    test('parsedBgColor handles #RRGGBB, AARRGGBB and garbage', () {
      StatusItemModel withBg(String bg) =>
          StatusItemModel.fromJson({'id': 1, 'backgroundColor': bg});
      expect(withBg('#10B981').parsedBgColor, const Color(0xFF10B981));
      expect(withBg('8010B981').parsedBgColor, const Color(0x8010B981));
      expect(withBg('#zzz').parsedBgColor, const Color(0xFF6B4DFF));
    });

    test('previewLabel: Video / Photo / text content / fallback', () {
      expect(StatusItemModel.fromJson(item(type: 'video')).previewLabel,
          'Video');
      expect(StatusItemModel.fromJson(item(type: 'image')).previewLabel,
          'Photo');
      expect(
          StatusItemModel.fromJson(
              {'id': 1, 'type': 'text', 'content': '  hi  '}).previewLabel,
          'hi');
      expect(StatusItemModel.fromJson({'id': 1, 'type': 'text'}).previewLabel,
          'Status');
    });

    test('formattedTime says "Just now" for a fresh status', () {
      expect(StatusItemModel.fromJson({'id': 1}).formattedTime, 'Just now');
    });

    test('fromReplyStatus fills creator from meta ownerName', () {
      final meta = StatusMetaModel.fromJson(
          {'statusId': 4, 'type': 'IMAGE', 'mediaUrl': 'a.jpg', 'ownerName': 'Om'});
      final s = StatusItemModel.fromReplyStatus({'id': 4}, meta: meta);
      expect(s.creator?.name, 'Om');
      expect(s.mediaUrl, '$base/a.jpg');
      expect(meta.type, 'image');
    });
  });
}
