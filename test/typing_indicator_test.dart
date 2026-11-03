import 'dart:async';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Private Chat Typing Logic Tests', () {
    test('Basic private typing state transitions', () {
      bool isPeerTyping = false;
      Timer? peerTypingResetTimer;

      void onTypingEvent(Map<String, dynamic> data, String myUserId, String peerUserId) {
        final senderId = (data['userId'] ?? data['senderId'])?.toString();
        if (senderId != null && senderId == peerUserId && senderId != myUserId) {
          isPeerTyping = true;
          peerTypingResetTimer?.cancel();
          peerTypingResetTimer = Timer(const Duration(milliseconds: 4000), () {
            isPeerTyping = false;
          });
        }
      }

      void onStopTypingEvent(Map<String, dynamic> data, String peerUserId) {
        final senderId = (data['userId'] ?? data['senderId'])?.toString();
        if (senderId == peerUserId) {
          peerTypingResetTimer?.cancel();
          isPeerTyping = false;
        }
      }

      expect(isPeerTyping, isFalse);

      // Peer starts typing
      onTypingEvent({'userId': 'peer_1', 'isTyping': true}, 'my_id', 'peer_1');
      expect(isPeerTyping, isTrue);

      // Own typing event must be ignored
      onTypingEvent({'userId': 'my_id', 'isTyping': true}, 'my_id', 'peer_1');
      expect(isPeerTyping, isTrue);

      // Event for a different user must be ignored
      onTypingEvent({'userId': 'random_user', 'isTyping': true}, 'my_id', 'peer_1');
      expect(isPeerTyping, isTrue);

      // Peer stops typing
      onStopTypingEvent({'userId': 'peer_1', 'isTyping': false}, 'peer_1');
      expect(isPeerTyping, isFalse);
    });

    test('Private typing auto-expires after 4 seconds if stop event is lost', () {
      fakeAsync((async) {
        bool isPeerTyping = false;
        Timer? peerTypingResetTimer;

        void onTyping() {
          isPeerTyping = true;
          peerTypingResetTimer?.cancel();
          peerTypingResetTimer = Timer(const Duration(milliseconds: 4000), () {
            isPeerTyping = false;
          });
        }

        onTyping();
        expect(isPeerTyping, isTrue);

        // Advance 2 seconds - still typing
        async.elapse(const Duration(seconds: 2));
        expect(isPeerTyping, isTrue);

        // Advance 2.5 more seconds (total 4.5s) - auto expires
        async.elapse(const Duration(milliseconds: 2500));
        expect(isPeerTyping, isFalse);
      });
    });

    test('Private typing throttle and debounce logic', () {
      fakeAsync((async) {
        int emitTypingCount = 0;
        int emitStopCount = 0;
        DateTime? lastEmitTime;
        Timer? debounceTimer;

        void onInputChanged(String text) {
          final trimmed = text.trim();
          if (trimmed.isNotEmpty) {
            final now = clock.now();
            if (lastEmitTime == null || now.difference(lastEmitTime!).inMilliseconds >= 2500) {
              lastEmitTime = now;
              emitTypingCount++;
            }
            debounceTimer?.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 2500), () {
              debounceTimer?.cancel();
              lastEmitTime = null;
              emitStopCount++;
            });
          } else {
            debounceTimer?.cancel();
            lastEmitTime = null;
            emitStopCount++;
          }
        }

        // Keystroke 1: immediate emit
        onInputChanged('H');
        expect(emitTypingCount, 1);
        expect(emitStopCount, 0);

        // Keystrokes 2 and 3 within 500ms: throttled (no new emit)
        async.elapse(const Duration(milliseconds: 200));
        onInputChanged('He');
        async.elapse(const Duration(milliseconds: 200));
        onInputChanged('Hel');
        expect(emitTypingCount, 1);

        // After 2.5s of continuous typing: periodic re-emit occurs
        async.elapse(const Duration(milliseconds: 2200));
        onInputChanged('Hello ');
        expect(emitTypingCount, 2);

        // Inactivity for 2.5s: debounce sends stop_typing
        async.elapse(const Duration(milliseconds: 2600));
        expect(emitStopCount, 1);

        // Clearing box immediately stops typing
        onInputChanged('A');
        expect(emitTypingCount, 3);
        onInputChanged('');
        expect(emitStopCount, 2);
      });
    });
  });

  group('Group Chat Multi-User Typing Logic Tests', () {
    test('Formatted typing text formatting for 0, 1, 2, and 3+ users', () {
      final Map<String, String> typingUsers = {};

      String formatGroupTyping(Map<String, String> users) {
        final count = users.length;
        if (count == 0) return '';
        final names = users.values.toList();
        if (count == 1) return '${names[0]} is typing...';
        if (count == 2) return '${names[0]}, ${names[1]} are typing...';
        return '$count people are typing...';
      }

      // 0 users
      expect(formatGroupTyping(typingUsers), '');

      // 1 user
      typingUsers['u1'] = 'Rahul';
      expect(formatGroupTyping(typingUsers), 'Rahul is typing...');

      // 2 users
      typingUsers['u2'] = 'Amit';
      expect(formatGroupTyping(typingUsers), 'Rahul, Amit are typing...');

      // 3 users
      typingUsers['u3'] = 'Sneha';
      expect(formatGroupTyping(typingUsers), '3 people are typing...');

      // 4 users
      typingUsers['u4'] = 'Priya';
      expect(formatGroupTyping(typingUsers), '4 people are typing...');

      // User stops typing -> correctly drops down
      typingUsers.remove('u4');
      typingUsers.remove('u3');
      expect(formatGroupTyping(typingUsers), 'Rahul, Amit are typing...');

      typingUsers.remove('u2');
      expect(formatGroupTyping(typingUsers), 'Rahul is typing...');

      typingUsers.remove('u1');
      expect(formatGroupTyping(typingUsers), '');
    });

    test('Group typing filters out own userId and different group IDs', () {
      final Map<String, String> typingUsers = {};
      const int currentGroupId = 100;
      const String currentUserId = 'my_id';

      void handleGroupTyping(Map<String, dynamic> data) {
        final eventGroupId = data['groupId'];
        if (eventGroupId != currentGroupId) return;

        final uid = data['userId']?.toString();
        if (uid == null || uid == currentUserId) return;

        final name = data['userName']?.toString() ?? 'Someone';
        typingUsers[uid] = name;
      }

      // 1. Different group event is ignored
      handleGroupTyping({'groupId': 999, 'userId': 'u1', 'userName': 'Rahul'});
      expect(typingUsers.isEmpty, isTrue);

      // 2. Own user event is ignored
      handleGroupTyping({'groupId': currentGroupId, 'userId': currentUserId, 'userName': 'Myself'});
      expect(typingUsers.isEmpty, isTrue);

      // 3. Other group member event is accepted
      handleGroupTyping({'groupId': currentGroupId, 'userId': 'u1', 'userName': 'Rahul'});
      expect(typingUsers.length, 1);
      expect(typingUsers['u1'], 'Rahul');
    });

    test('Group typing auto-expires per-user timers independently', () {
      fakeAsync((async) {
        final Map<String, String> typingUsers = {};
        final Map<String, Timer> timers = {};

        void userTyping(String uid, String name) {
          typingUsers[uid] = name;
          timers[uid]?.cancel();
          timers[uid] = Timer(const Duration(milliseconds: 4500), () {
            typingUsers.remove(uid);
            timers.remove(uid);
          });
        }

        // User A starts typing at t=0
        userTyping('uA', 'Rahul');
        expect(typingUsers.keys, contains('uA'));

        // At t=2s, User B starts typing
        async.elapse(const Duration(seconds: 2));
        userTyping('uB', 'Amit');
        expect(typingUsers.length, 2);

        // At t=4.6s (total), User A's timer expires, User B is still active
        async.elapse(const Duration(milliseconds: 2600));
        expect(typingUsers.containsKey('uA'), isFalse);
        expect(typingUsers.containsKey('uB'), isTrue);

        // At t=6.6s (total), User B's timer expires
        async.elapse(const Duration(seconds: 2));
        expect(typingUsers.isEmpty, isTrue);
      });
    });

    test('Malformed and nested payloads do not crash parser', () {
      final Map<String, String> typingUsers = {};

      void safeParse(dynamic data) {
        try {
          if (data is! Map) return;
          final dataMap = Map<String, dynamic>.from(data);
          final inner = dataMap['message'] is Map
              ? Map<String, dynamic>.from(dataMap['message'])
              : (dataMap['data'] is Map ? Map<String, dynamic>.from(dataMap['data']) : dataMap);

          final uid = (inner['userId'] ?? inner['user_id'] ?? inner['senderId'] ?? inner['sender_id'])?.toString();
          final name = (inner['userName'] ?? inner['senderName'])?.toString() ?? 'Someone';

          if (uid != null && uid.isNotEmpty) {
            typingUsers[uid] = name;
          }
        } catch (_) {}
      }

      // Null, String, List payloads: safely ignored
      safeParse(null);
      safeParse('invalid payload');
      safeParse([1, 2, 3]);
      expect(typingUsers.isEmpty, isTrue);

      // Nested payload: parsed cleanly
      safeParse({
        'data': {
          'userId': 'u5',
          'userName': 'Kiran',
        }
      });
      expect(typingUsers['u5'], 'Kiran');
    });
  });
}
