import 'package:fgtracker/app/Data/Services/NotificationServices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isWalkieNotificationPayload', () {
    test('group CHAT notification is not Walkie even with a groupId', () {
      expect(
        isWalkieNotificationPayload(
            {'screen_name': 'groupChatScreen', 'groupId': '7'}),
        isFalse,
      );
    });

    test('Walkie screen names are Walkie', () {
      expect(isWalkieNotificationPayload({'screen_name': 'group_walkie'}), isTrue);
      expect(isWalkieNotificationPayload({'screen_name': 'groupWalkie', 'groupId': 1}), isTrue);
      expect(isWalkieNotificationPayload({'screenName': 'group_walkie'}), isTrue);
    });

    test('legacy payload with only a groupId still counts as Walkie', () {
      expect(isWalkieNotificationPayload({'groupId': 3}), isTrue);
      expect(isWalkieNotificationPayload({'group_id': 3}), isTrue);
    });

    test('private chat and non-map payloads are not Walkie', () {
      expect(isWalkieNotificationPayload({'screen_name': 'chatScreen'}), isFalse);
      expect(isWalkieNotificationPayload('x'), isFalse);
      expect(isWalkieNotificationPayload({}), isFalse);
    });
  });
}
