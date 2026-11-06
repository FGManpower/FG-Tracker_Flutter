import 'dart:async';
import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/Controller/walkieController.dart';
import 'package:fgtracker/app/modules/Walkie-talkie/widgets/group_info_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemberData notificationsEnabled parsing tests', () {
    test('parses notificationsEnabled from boolean', () {
      final m1 = MemberData.fromJson({'notificationsEnabled': false, 'userId': 101});
      expect(m1.notificationsEnabled, isFalse);

      final m2 = MemberData.fromJson({'notificationsEnabled': true, 'userId': 102});
      expect(m2.notificationsEnabled, isTrue);
    });

    test('parses notifications_enabled from integer (0 and 1)', () {
      final mOff = MemberData.fromJson({'notifications_enabled': 0, 'userId': 201});
      expect(mOff.notificationsEnabled, isFalse);

      final mOn = MemberData.fromJson({'notifications_enabled': 1, 'userId': 202});
      expect(mOn.notificationsEnabled, isTrue);
    });

    test('parses notifications_enabled from strings ("0", "1", "false", "true")', () {
      final mOff1 = MemberData.fromJson({'notifications_enabled': '0', 'userId': 301});
      expect(mOff1.notificationsEnabled, isFalse);

      final mOff2 = MemberData.fromJson({'notifications_enabled': 'false', 'userId': 302});
      expect(mOff2.notificationsEnabled, isFalse);

      final mOn1 = MemberData.fromJson({'notifications_enabled': '1', 'userId': 303});
      expect(mOn1.notificationsEnabled, isTrue);

      final mOn2 = MemberData.fromJson({'notifications_enabled': 'true', 'userId': 304});
      expect(mOn2.notificationsEnabled, isTrue);
    });

    test('parses nested user notifications_enabled', () {
      final m = MemberData.fromJson({
        'user': {
          'id': 401,
          'name': 'Jane Doe',
          'notifications_enabled': 0,
        }
      });
      expect(m.userId, equals(401));
      expect(m.notificationsEnabled, isFalse);
    });
  });

  group('GroupWalkieController Admin Alert & Countdown tests', () {
    late GroupWalkieController controller;

    setUp(() {
      controller = GroupWalkieController();
    });

    tearDown(() {
      controller.reset();
    });

    test('triggerAdminAlertForMember sets countdown to 10s and ticks down', () async {
      const memberId = '999';
      expect(controller.adminAlertCountdown[memberId], isNull);

      // Trigger alert
      controller.triggerAdminAlertForMember(
        groupId: '100',
        memberId: memberId,
        memberName: 'Alice',
        groupName: 'Ops Group',
      );

      // Immediately 10
      expect(controller.adminAlertCountdown[memberId], equals(10));

      // Simulate 1 second timer tick
      await Future.delayed(const Duration(milliseconds: 1100));
      final valAfter1Sec = controller.adminAlertCountdown[memberId];
      expect(valAfter1Sec, inInclusiveRange(8, 9));
    });

    test('triggerAdminAlertForMember ignores duplicate calls while countdown is active', () {
      const memberId = '888';

      controller.triggerAdminAlertForMember(
        groupId: '100',
        memberId: memberId,
        memberName: 'Bob',
        groupName: 'Field Group',
      );

      expect(controller.adminAlertCountdown[memberId], equals(10));

      // Manually set to 7 to verify duplicate call doesn't overwrite it back to 10
      controller.adminAlertCountdown[memberId] = 7;

      controller.triggerAdminAlertForMember(
        groupId: '100',
        memberId: memberId,
        memberName: 'Bob',
        groupName: 'Field Group',
      );

      expect(controller.adminAlertCountdown[memberId], equals(7));
    });

    test('member notification status is scoped per channel', () {
      controller.setCurrentGroup('10');

      // Member 5 turns OFF notifications for group 20 -> must NOT affect group 10
      controller.setMemberNotificationStatus('5', false, groupId: '20');
      expect(controller.memberNotificationEnabledFor('20', '5'), isFalse);
      expect(controller.memberNotificationEnabledFor('10', '5'), isNull);

      // Member 5 turns ON group 20 -> (one-active rule) group 10 becomes OFF
      controller.setMemberNotificationStatus('5', true, groupId: '20');
      expect(controller.memberNotificationEnabledFor('20', '5'), isTrue);
      expect(controller.memberNotificationEnabledFor('10', '5'), isFalse);

      // Member 5 turns ON group 10 -> group 20 becomes OFF
      controller.setMemberNotificationStatus('5', true, groupId: '10');
      expect(controller.memberNotificationEnabledFor('10', '5'), isTrue);
      expect(controller.memberNotificationEnabledFor('20', '5'), isFalse);

      controller.reset();
      expect(controller.memberNotificationStatus.isEmpty, isTrue);
    });

    test('reset clears all countdown timers', () {
      const memberId = '777';
      controller.triggerAdminAlertForMember(
        groupId: '100',
        memberId: memberId,
        memberName: 'Charlie',
        groupName: 'Sec Group',
      );

      expect(controller.adminAlertCountdown.isNotEmpty, isTrue);
      controller.reset();
      expect(controller.adminAlertCountdown.isEmpty, isTrue);
    });
  });

  group('GroupInfoBottomSheet UI and Widget tests', () {
    testWidgets('renders fixed header, notification off icon, and admin bell button', (tester) async {
      final ctrl = GroupWalkieController();
      Get.put<GroupWalkieController>(ctrl);

      final members = [
        MemberData(
          userId: 101,
          name: 'Admin User',
          isCreator: true,
          notificationsEnabled: true,
        ),
        MemberData(
          userId: 102,
          name: 'Field Agent',
          isCreator: false,
          notificationsEnabled: false, // Notification turned off!
        ),
      ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => GetMaterialApp(
            home: Scaffold(
              body: GroupInfoBottomSheet(
                groupId: '55',
                groupName: 'HQ Team',
                groupDesc: 'Field operations channel',
                adminId: '101',
                allGroupMembers: members,
                controller: ctrl,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Fixed Header Section Verification
      expect(find.text('HQ Team'), findsOneWidget);
      expect(find.text('Group Members'), findsOneWidget);
      expect(find.text('2 total'), findsOneWidget);

      // 2. Profile Avatar Notification Off Indicator
      // Field Agent has notification off -> Icons.notifications_off_rounded must be displayed!
      expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);

      // 3. Right Side Notification Button
      // When countdown is 0, the bell icon is displayed
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 4. Admin Countdown Timer: set countdown to 10
      ctrl.adminAlertCountdown['102'] = 10;
      await tester.pump();

      // Should show '10s' countdown pill
      expect(find.text('10s'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      Get.delete<GroupWalkieController>();
    });

    testWidgets('strictly shows Admin badge only for backend creator/admin, never for index 0 if not creator', (tester) async {
      final ctrl = GroupWalkieController();
      Get.put<GroupWalkieController>(ctrl);

      final members = [
        MemberData(
          userId: 201,
          name: 'Regular Member 1',
          isCreator: false, // Index 0 is NOT creator!
          notificationsEnabled: true,
        ),
        MemberData(
          userId: 202,
          name: 'Real Admin User',
          isCreator: true, // Index 1 IS creator!
          notificationsEnabled: true,
        ),
        MemberData(
          userId: 203,
          name: 'Regular Member 2',
          isCreator: false,
          notificationsEnabled: true,
        ),
      ];

      // Case A: adminId is null, should strictly respect isCreator: true from backend
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => GetMaterialApp(
            home: Scaffold(
              body: GroupInfoBottomSheet(
                groupId: '55',
                groupName: 'HQ Team',
                adminId: null, // No explicit adminId in args
                allGroupMembers: members,
                controller: ctrl,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Exactly ONE "Admin" label in the entire list, specifically for Real Admin User!
      expect(find.text('Admin'), findsOneWidget);

      Get.delete<GroupWalkieController>();
    });

    testWidgets('bell hidden for members with notifications ON even if they are OFF in another channel', (tester) async {
      final ctrl = GroupWalkieController();
      Get.put<GroupWalkieController>(ctrl);

      // Member 302 turned notifications OFF in a *different* channel (99)
      ctrl.setMemberNotificationStatus('302', false, groupId: '99');

      final members = [
        MemberData(userId: 304, name: 'Off Member', notificationsEnabled: false),
        MemberData(userId: 301, name: 'Admin', isCreator: true, notificationsEnabled: true),
        MemberData(userId: 302, name: 'On Member', notificationsEnabled: true),
      ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => GetMaterialApp(
            home: Scaffold(
              body: GroupInfoBottomSheet(
                groupId: '55',
                groupName: 'HQ Team',
                adminId: '301',
                allGroupMembers: members,
                controller: ctrl,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only "Off Member" (304) gets the badge + bell.
      expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);
      expect(
        find.byIcon(Icons.notifications_none_rounded).evaluate().length +
            find.byIcon(Icons.notifications_active_rounded).evaluate().length,
        1,
      );

      Get.delete<GroupWalkieController>();
    });
  });
}

