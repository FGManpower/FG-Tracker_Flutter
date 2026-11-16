// QA tests for status controllers (feed, viewer, add-status) and the status
// socket service. No network: controllers are used without onInit, or with
// a fake feed controller whose fetch methods are stubbed.
import 'package:fgtracker/app/Data/Services/Socket/status_socket_service.dart';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:fgtracker/app/modules/status/controller/AddStatusController.dart';
import 'package:fgtracker/app/modules/status/controller/status_feed_controller.dart';
import 'package:fgtracker/app/modules/status/controller/status_view_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

StatusItemModel st(int id, {bool viewed = false, int? userId}) =>
    StatusItemModel.fromJson({
      'id': id,
      'type': 'text',
      'isViewed': viewed,
      if (userId != null) 'userId': userId,
    });

ContactStatusGroupModel grp(int userId, List<StatusItemModel> statuses,
        {bool allViewed = false}) =>
    ContactStatusGroupModel(
      user: StatusCreatorUser(id: userId, name: 'U$userId'),
      isAllViewed: allViewed,
      latestTimestamp: DateTime(2026, 11, 16),
      statuses: List.of(statuses), // growable, like fromJson
    );

/// Feed controller whose network calls are stubbed out.
class FakeFeed extends StatusFeedController {
  int refreshCalls = 0;
  int myFetchCalls = 0;
  @override
  Future<void> refreshAll() async => refreshCalls++;
  @override
  Future<void> fetchMyStatuses() async => myFetchCalls++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group('StatusFeedController delete handling', () {
    test('deleting my status removes it from myStatuses', () {
      final c = StatusFeedController();
      c.myStatuses.assignAll([st(1), st(2)]);
      c.onStatusDeletedReceived(1, 0);
      expect(c.myStatuses.map((s) => s.id), [2]);
    });

    test('last status of a contact removes the whole group + highlight', () {
      final c = StatusFeedController();
      c.contactGroups.assignAll([grp(7, [st(10)]), grp(8, [st(20)])]);
      c.highlightedUserIds.add(7);
      c.onStatusDeletedReceived(10, 7);
      expect(c.contactGroups.map((g) => g.user.id), [8]);
      expect(c.highlightedUserIds, isNot(contains(7)));
    });

    test('remaining statuses recompute isAllViewed', () {
      final c = StatusFeedController();
      c.contactGroups
          .assignAll([grp(7, [st(10), st(11, viewed: true)])]);
      c.highlightedUserIds.add(7);
      c.onStatusDeletedReceived(10, 7);
      expect(c.contactGroups.single.statuses.map((s) => s.id), [11]);
      expect(c.contactGroups.single.isAllViewed, isTrue);
      expect(c.highlightedUserIds, isEmpty);
    });

    test('unknown creator (0) is found by status id', () {
      final c = StatusFeedController();
      c.contactGroups.assignAll([grp(7, [st(10), st(11)])]);
      c.onStatusDeletedReceived(11, 0);
      expect(c.contactGroups.single.statuses.map((s) => s.id), [10]);
    });

    test('unknown status id changes nothing', () {
      final c = StatusFeedController();
      c.myStatuses.assignAll([st(1)]);
      c.contactGroups.assignAll([grp(7, [st(10)])]);
      c.onStatusDeletedReceived(999, 7);
      expect(c.myStatuses, hasLength(1));
      expect(c.contactGroups.single.statuses, hasLength(1));
    });
  });

  group('StatusFeedController viewed handling', () {
    test('markStatusViewedLocally flags the status and stores the reaction',
        () {
      final c = StatusFeedController();
      c.contactGroups.assignAll([grp(7, [st(10), st(11)])]);
      c.highlightedUserIds.add(7);
      c.markStatusViewedLocally(10, reactionEmoji: '🔥');
      final g = c.contactGroups.single;
      expect(g.statuses.first.isViewed, isTrue);
      expect(g.statuses.first.myReaction, '🔥');
      expect(g.isAllViewed, isFalse, reason: '11 still unviewed');
      expect(c.highlightedUserIds, isEmpty);
    });

    test('viewing the last unviewed status flips the group to all-viewed',
        () {
      final c = StatusFeedController();
      c.contactGroups.assignAll([grp(7, [st(10, viewed: true), st(11)])]);
      c.markStatusViewedLocally(11);
      expect(c.contactGroups.single.isAllViewed, isTrue);
    });

    test('client keeps server order: viewed group is not moved to the end',
        () {
      final c = StatusFeedController();
      c.contactGroups.assignAll([grp(7, [st(10)]), grp(8, [st(20)])]);
      c.markStatusViewedLocally(10);
      expect(c.contactGroups.map((g) => g.user.id), [7, 8]);
    });
  });

  group('StatusFeedController socket events', () {
    late StatusSocketService socket;
    late FakeFeed feed;

    setUp(() {
      socket = Get.put(StatusSocketService(), permanent: true);
      feed = Get.put(FakeFeed());
    });

    test('status:new highlights the poster and refreshes the feed', () async {
      final before = feed.refreshCalls;
      socket.onNewStatusEvent.value = {'userId': '12', 'statusId': 5};
      await Future<void>.delayed(Duration.zero);
      expect(feed.highlightedUserIds, contains(12));
      expect(feed.refreshCalls, before + 1);
    });

    test('status:viewed refetches my statuses (view counts)', () async {
      socket.onStatusViewedEvent.value = {'statusId': 5};
      await Future<void>.delayed(Duration.zero);
      expect(feed.myFetchCalls, 1);
    });

    test('status:deleted with string ids removes the story', () async {
      feed.contactGroups.assignAll([grp(7, [st(10)])]);
      socket.onStatusDeletedEvent.value = {'statusId': '10', 'userId': '7'};
      await Future<void>.delayed(Duration.zero);
      expect(feed.contactGroups, isEmpty);
    });

    test('status:deleted without a valid statusId is ignored', () async {
      feed.contactGroups.assignAll([grp(7, [st(10)])]);
      socket.onStatusDeletedEvent.value = {'statusId': 'abc', 'userId': 7};
      await Future<void>.delayed(Duration.zero);
      expect(feed.contactGroups, hasLength(1));
    });

    test('emitStatusView while disconnected reports failure at once', () {
      bool? ok;
      socket.emitStatusView(statusId: 1, onResult: (s, _) => ok = s);
      expect(ok, isFalse);
    });
  });

  group('StatusViewController.handleStoryDeletionIfActive', () {
    StatusViewController viewer(List<StatusItemModel> items,
            {int index = 0,
            List<ContactStatusGroupModel>? groups,
            int groupIndex = 0}) =>
        StatusViewController(
          isOwnStatus: false,
          initialStatuses: items,
          allContactGroups: groups ?? [],
          initialGroupIndex: groupIndex,
        )..currentIndex.value = index;

    test('deleting an earlier (not current) story shifts the index back', () {
      final v = viewer([st(1), st(2), st(3)], index: 2);
      v.handleStoryDeletionIfActive(1);
      expect(v.statuses.map((s) => s.id), [2, 3]);
      expect(v.currentIndex.value, 1);
      expect(v.currentStatus?.id, 3);
    });

    test('deleting a later story keeps the current one', () {
      final v = viewer([st(1), st(2), st(3)], index: 0);
      v.handleStoryDeletionIfActive(3);
      expect(v.currentStatus?.id, 1);
      expect(v.totalStatuses, 2);
    });

    test('the same deletion event twice is handled once', () {
      final v = viewer([st(1), st(2), st(3)], index: 2);
      v.handleStoryDeletionIfActive(1);
      v.handleStoryDeletionIfActive(1);
      expect(v.currentIndex.value, 1);
    });

    test('an emptied contact group before the current one is pruned', () {
      final groups = [grp(5, [st(50)]), grp(7, [st(1), st(2)])];
      final v = viewer([st(1), st(2)], index: 1, groups: groups, groupIndex: 1);
      v.handleStoryDeletionIfActive(50);
      expect(groups.map((g) => g.user.id), [7]);
      expect(v.currentGroupIndex.value, 0);
      expect(v.statuses, hasLength(2), reason: 'other user, not active');
    });
  });

  group('AddStatusController pure helpers', () {
    test('formatDuration pads mm:ss', () {
      final c = AddStatusController();
      expect(c.formatDuration(0), '00:00');
      expect(c.formatDuration(65), '01:05');
      expect(c.formatDuration(3600), '60:00');
    });

    test('whoCanSeeLabel follows privacyType', () {
      final c = AddStatusController();
      expect(c.whoCanSeeLabel, 'All Contacts');
      c.privacyType.value = 'EXCEPT_USERS';
      expect(c.whoCanSeeLabel, 'Except Selected');
      c.privacyType.value = 'ONLY_SHARE_WITH';
      expect(c.whoCanSeeLabel, 'Only Share With');
    });

    test('switching to text mode clears a captured video flag', () async {
      final c = AddStatusController();
      c.isVideoFile.value = true;
      await c.changeMode('text');
      expect(c.mode.value, 'text');
      expect(c.isVideoFile.value, isFalse);
      expect(c.capturedFile.value, isNull);
    });

    test('mode cannot change while recording', () async {
      final c = AddStatusController();
      c.isRecording.value = true;
      await c.changeMode('text');
      expect(c.mode.value, 'photo');
    });
  });
}
