import 'dart:convert';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/storage_services.dart';
import 'package:fgtracker/app/Data/Services/GroupCountService.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/modules/Track/Controller/SocketServices.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Global.storageServices = await StorageServices().init();
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Home Screen Socket Counts & Lifecycle Suite', () {
    test('1. GroupCountService hydrates instantly from local storage cache on init', () async {
      final initialData = {
        'totalGroups': 7,
        'totalMembers': 42,
        'activeMembers': 15,
        'locationDisabledMembers': 3,
      };
      await Global.storageServices.setString(
        GroupCountService.storageKey,
        jsonEncode(initialData),
      );

      final service = GroupCountService.instance;
      service.loadFromCache();

      expect(service.totalGroups, equals(7));
      expect(service.totalMembers, equals(42));
      expect(service.activeMembers, equals(15));
      expect(service.locationDisabledMembers, equals(3));
    });

    test('2. GroupCountService persists updated socket payload to storage cache', () async {
      final service = GroupCountService.instance;

      final backendPayload = {
        'status': true,
        'data': {
          'totalGroups': 12,
          'totalMembers': 88,
          'activeMembers': 34,
          'privateMembers': 6,
        }
      };

      service.updateFromSocket(backendPayload['data']);

      expect(service.totalGroups, equals(12));
      expect(service.totalMembers, equals(88));
      expect(service.activeMembers, equals(34));
      expect(service.locationDisabledMembers, equals(6));

      // Verify persistence in SharedPreferences
      final storedJson = Global.storageServices.get(GroupCountService.storageKey);
      expect(storedJson, isNotNull);
      final decoded = jsonDecode(storedJson!);
      expect(decoded['totalGroups'], equals(12));
      expect(decoded['locationDisabledMembers'], equals(6));
    });

    test('3. SocketDashboardService is a true singleton across multiple constructors and Get.find', () {
      final instance1 = SocketDashboardService.instance;
      final instance2 = SocketDashboardService();
      final instance3 = Get.find<SocketDashboardService>();

      expect(identical(instance1, instance2), isTrue);
      expect(identical(instance1, instance3), isTrue);
    });

    test('4. GroupCountService handles empty, null, and malformed socket payloads gracefully', () {
      final service = GroupCountService.instance;

      service.updateFromSocket(null);
      expect(service.totalGroups, equals(0));

      service.updateFromSocket({});
      expect(service.totalGroups, equals(0));

      service.updateFromSocket({'invalidKey': 'unknown'});
      expect(service.totalGroups, equals(0));
    });

    test('5. GroupCountService clearCache resets counts and removes stored cache key', () async {
      final service = GroupCountService.instance;

      service.updateFromSocket({
        'totalGroups': 5,
        'totalMembers': 10,
        'activeMembers': 2,
        'locationDisabledMembers': 1,
      });

      expect(service.totalGroups, equals(5));
      expect(Global.storageServices.get(GroupCountService.storageKey), isNotNull);

      service.clearCache();

      expect(service.totalGroups, equals(0));
      expect(service.totalMembers, equals(0));
      expect(service.activeMembers, equals(0));
      expect(service.locationDisabledMembers, equals(0));
      expect(Global.storageServices.get(GroupCountService.storageKey), isNull);
    });

    test('6. AppLifecycleState.resumed event triggers count refresh without crashes', () {
      final dashboardService = SocketDashboardService.instance;
      final locationService = SocketService.instance;

      // Verify calling didChangeAppLifecycleState on resumed runs cleanly
      expect(
        () => dashboardService.didChangeAppLifecycleState(AppLifecycleState.resumed),
        returnsNormally,
      );
      expect(
        () => locationService.didChangeAppLifecycleState(AppLifecycleState.resumed),
        returnsNormally,
      );
    });
  });
}
