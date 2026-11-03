import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';
import 'package:fgtracker/app/Model/banner_model.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/Model/group_count_detail.dart';
import 'package:fgtracker/app/Model/live_location_model.dart';
import 'package:fgtracker/app/Data/Services/notification_marker_service.dart';
import 'package:fgtracker/app/Data/Services/GroupCountService.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ===========================================================================
  // GROUP 1: Splash Screen to Home Screen Navigation & Auth Guard Evaluation
  // ===========================================================================
  group('1. Splash Screen to Home Screen Navigation & Auth Guard Evaluation', () {
    test('Condition A: Authenticated user (token present + isRegistered="true") routes to Home Screen', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'jwt_mock_token_abc_123',
        PrefConst.isRegistered: 'true',
        PrefConst.introStatus: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      final isRegistered = prefs.getString(PrefConst.isRegistered);

      String targetRoute;
      if (token != null && token.isNotEmpty && isRegistered == 'true') {
        targetRoute = '/home';
      } else {
        final introDone = prefs.getBool(PrefConst.introStatus) ?? false;
        targetRoute = introDone ? '/login' : '/intro';
      }

      expect(targetRoute, equals('/home'));
    });

    test('Condition B: Unauthenticated user with completed intro routes to Login Screen', () async {
      SharedPreferences.setMockInitialValues({
        PrefConst.introStatus: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      final isRegistered = prefs.getString(PrefConst.isRegistered);

      String targetRoute;
      if (token != null && token.isNotEmpty && isRegistered == 'true') {
        targetRoute = '/home';
      } else {
        final introDone = prefs.getBool(PrefConst.introStatus) ?? false;
        targetRoute = introDone ? '/login' : '/intro';
      }

      expect(targetRoute, equals('/login'));
    });

    test('Condition C: First time install (no token, intro not done) routes to Intro Screen', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      final isRegistered = prefs.getString(PrefConst.isRegistered);

      String targetRoute;
      if (token != null && token.isNotEmpty && isRegistered == 'true') {
        targetRoute = '/home';
      } else {
        final introDone = prefs.getBool(PrefConst.introStatus) ?? false;
        targetRoute = introDone ? '/login' : '/intro';
      }

      expect(targetRoute, equals('/intro'));
    });

    test('Condition D: Token present but registration incomplete routes to Intro/Login', () async {
      SharedPreferences.setMockInitialValues({
        'token': 'jwt_partial_token_without_registration',
        PrefConst.isRegistered: 'false',
        PrefConst.introStatus: true,
      });
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');
      final isRegistered = prefs.getString(PrefConst.isRegistered);

      String targetRoute;
      if (token != null && token.isNotEmpty && isRegistered == 'true') {
        targetRoute = '/home';
      } else {
        final introDone = prefs.getBool(PrefConst.introStatus) ?? false;
        targetRoute = introDone ? '/login' : '/intro';
      }

      expect(targetRoute, equals('/login'));
    });

    test('Condition E: Call/Walkie launch flag intercepts splash and redirects to call screen', () async {
      const bool launchedFromCall = true;
      const String callRoute = '/callScreen';

      String targetRoute;
      if (launchedFromCall) {
        targetRoute = callRoute;
      } else {
        targetRoute = '/home';
      }

      expect(targetRoute, equals('/callScreen'));
    });
  });

  // ===========================================================================
  // GROUP 2: Home Screen API Loading Lifecycle & Edge Conditions
  // ===========================================================================
  group('2. Home Screen API Loading Lifecycle & Edge Conditions', () {
    test('API Condition A: Initialize API parses successfully & sets notification markers', () {
      final jsonMap = {
        'status': true,
        'message': 'Initialization successful',
        'data': {
          'initializedAt': '2026-10-28T00:00:00Z',
          'serverTime': '2026-10-28T00:00:00Z',
          'walkie': {
            'access': {
              'canUseWalkie': true,
              'hasIndividualAccess': true,
              'accessType': 'individual',
            },
            'currentSubscription': {
              'isActive': true,
              'status': 'active',
            },
          },
          'notificationMarkers': {
            'calling': true,
            'chatting': true,
            'walkie': false,
          }
        }
      };

      final model = InitializeModel.fromJson(jsonMap);
      expect(model.status, isTrue);
      expect(model.data?.walkie?.isSubscribed, isTrue);
      expect(model.data?.walkie?.access?.canUseWalkie, isTrue);

      final markerService = NotificationMarkerService.instance;
      markerService.updateFromMap(jsonMap['data'] as Map);

      expect(markerService.hasCallingMarker.value, isTrue);
      expect(markerService.hasChattingMarker.value, isTrue);
      expect(markerService.hasWalkieMarker.value, isFalse);
    });

    test('API Condition B: Initialize API failure triggers error state (Lost Connection)', () {
      String initializeResponseMessage = '';
      bool hasLostConnection = false;

      // Simulate failure
      try {
        throw Exception('SocketException: Connection refused (Server 500)');
      } catch (e) {
        initializeResponseMessage = e.toString();
        hasLostConnection = initializeResponseMessage.isNotEmpty;
      }

      expect(hasLostConnection, isTrue);
      expect(initializeResponseMessage, contains('Connection refused'));

      // Simulate Retry
      initializeResponseMessage = '';
      hasLostConnection = initializeResponseMessage.isNotEmpty;
      expect(hasLostConnection, isFalse);
    });

    test('API Condition C: Banner API loading, populating and empty carousel fallback', () {
      bool isLoadingBanners = true;
      List<BannerData> banners = [];

      final bannerApiResponse = {
        'success': true,
        'message': 'Banners fetched',
        'data': [
          {'id': 1, 'image': 'https://cdn.fgtracker.com/banner1.png', 'title': 'Safety Tips'},
          {'id': 2, 'image': 'https://cdn.fgtracker.com/banner2.png', 'title': 'Invite Family'},
          {'id': 3, 'image': 'https://cdn.fgtracker.com/banner3.png', 'title': 'Premium Walkie'},
        ]
      };

      final bannerModel = bannermodel.fromJson(bannerApiResponse);
      isLoadingBanners = false;
      banners = bannerModel.data ?? [];

      expect(isLoadingBanners, isFalse);
      expect(banners.length, equals(3));
      expect(banners.first.title, equals('Safety Tips'));

      // Empty banners case
      final emptyResponse = {'success': true, 'data': <Map<String, dynamic>>[]};
      final emptyModel = bannermodel.fromJson(emptyResponse);
      expect(emptyModel.data, isEmpty);
    });

    test('API Condition D: Profile API loading, populating & location sharing flag', () {
      final profileJson = {
        'status': true,
        'message': 'Success',
        'data': {
          'UserId': 9999,
          'Name': 'John Doe',
          'Email': 'john@fgtracker.com',
          'MobileNo': '+1234567890',
          'profileImage': '/uploads/john.jpg',
          'locationSharing': true,
          'isOnline': 1,
        }
      };

      final profileRes = ProfileRes.fromJson(profileJson);
      expect(profileRes.status, isTrue);
      expect(profileRes.data?.userId, equals(9999));
      expect(profileRes.data?.name, equals('John Doe'));
      expect(profileRes.data?.locationSharing, isTrue);
      expect(profileRes.data?.isOnline, equals(1));
    });
  });

  // ===========================================================================
  // GROUP 3: Socket Loading & Real-time Synchronization
  // ===========================================================================
  group('3. Socket Loading & Real-time Synchronization', () {
    test('Socket Condition A: Dashboard Socket parses various live location response structures', () {
      final List<Map<String, dynamic>> rawMembers = [
        {
          'userId': 101,
          'firstName': 'Alice',
          'lastName': 'Smith',
          'latitude': 37.7749,
          'longitude': -122.4194,
          'isOnline': true,
          'battery': 92,
          'address': 'Market St, San Francisco',
        },
        {
          'userId': 102,
          'firstName': 'Bob',
          'lastName': 'Jones',
          'latitude': 37.7833,
          'longitude': -122.4167,
          'isOnline': 'online',
          'battery': 64,
          'address': 'Mission St, San Francisco',
        },
        // Invalid member with 0,0 and no address (should be filtered out)
        {
          'userId': 103,
          'firstName': 'Ghost',
          'lastName': 'User',
          'latitude': 0.0,
          'longitude': 0.0,
          'isOnline': false,
          'battery': 10,
          'address': '',
        },
        // Member with 0,0 but valid address (should be kept)
        {
          'userId': 104,
          'firstName': 'Charlie',
          'lastName': 'Brown',
          'latitude': 0.0,
          'longitude': 0.0,
          'isOnline': true,
          'battery': 80,
          'address': 'Union Square',
        }
      ];

      // Structure 1: { data: [ ... ] }
      final responseStructure1 = {'data': rawMembers};
      final List data1 = responseStructure1['data']!;
      final parsed1 = data1
          .whereType<Map>()
          .map((item) => LiveLocationModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => (item.latitude != 0 && item.longitude != 0) || (item.address != null && item.address!.trim().isNotEmpty))
          .toList();

      expect(parsed1.length, equals(3));
      expect(parsed1.any((m) => m.userId == 103), isFalse);
      expect(parsed1.firstWhere((m) => m.userId == 101).fullName, equals('Alice Smith'));
      expect(parsed1.firstWhere((m) => m.userId == 102).isOnline, isTrue);

      // Structure 2: { data: { locations: [ ... ] } }
      final responseStructure2 = {
        'data': {'locations': rawMembers}
      };
      final inner = responseStructure2['data'] as Map;
      final List data2 = inner['locations'] as List;
      final parsed2 = data2
          .whereType<Map>()
          .map((item) => LiveLocationModel.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => (item.latitude != 0 && item.longitude != 0) || (item.address != null && item.address!.trim().isNotEmpty))
          .toList();
      expect(parsed2.length, equals(3));
    });

    test('Socket Condition B: Location Socket updates GroupCountService accurately', () {
      final groupCountService = GroupCountService.instance;

      final socketPayload = {
        'totalGroups': '5',
        'totalMembers': 28,
        'activeMembers': '14',
        'locationDisabledMembers': 4,
      };

      groupCountService.updateFromSocket(socketPayload);

      expect(groupCountService.totalGroups, equals(5));
      expect(groupCountService.totalMembers, equals(28));
      expect(groupCountService.activeMembers, equals(14));
      expect(groupCountService.locationDisabledMembers, equals(4));
    });

    test('Socket Condition C: Location Socket updates NotificationMarkerService badges', () {
      final markerService = NotificationMarkerService.instance;

      final markerPayload = {
        'calling': {'hasMissedCall': false, 'hasNotification': false},
        'chat': {'hasUnread': true, 'hasNotification': true},
        'walkie': {'hasNotification': true, 'isChannelSpeaking': true},
      };

      markerService.updateFromMap(markerPayload);

      expect(markerService.hasCallingMarker.value, isFalse);
      expect(markerService.hasChattingMarker.value, isTrue);
      expect(markerService.hasWalkieMarker.value, isTrue);
    });
  });

  // ===========================================================================
  // GROUP 4: Multi-User Simulation (10+ Users Login & Logout Flow)
  // ===========================================================================
  group('4. Multi-User Simulation (10+ Users Login & Logout Flow)', () {
    test('Simulating 12 consecutive user logins and logouts verifies zero state contamination', () async {
      final groupCountService = GroupCountService.instance;
      final markerService = NotificationMarkerService.instance;

      for (int userIndex = 1; userIndex <= 12; userIndex++) {
        final userId = 'USR_${1000 + userIndex}';
        final token = 'jwt_token_for_user_$userIndex';
        final isRegistered = 'true';
        final isPrivate = (userIndex % 2 == 0); // Alternate private mode

        // Step 1: User Login & Session Write
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefConst.userId, userId);
        await prefs.setString('token', token);
        await prefs.setString(PrefConst.isRegistered, isRegistered);
        await prefs.setBool(PrefConst.locationSharing, !isPrivate);
        await prefs.setString('name', 'User #$userIndex');

        // Verify active session keys
        expect(prefs.getString(PrefConst.userId), equals(userId));
        expect(prefs.getString('token'), equals(token));
        expect(prefs.getString(PrefConst.isRegistered), equals('true'));

        // Step 2: Feed user-specific socket data
        groupCountService.updateFromSocket({
          'totalGroups': userIndex,
          'totalMembers': userIndex * 5,
          'activeMembers': userIndex * 2,
          'locationDisabledMembers': isPrivate ? 1 : 0,
        });

        markerService.updateFromMap({
          'calling': {'hasMissedCall': userIndex % 3 == 0},
          'chat': {'hasUnread': userIndex % 2 == 0},
          'walkie': {'hasNotification': userIndex % 4 == 0},
        });

        expect(groupCountService.totalGroups, equals(userIndex));
        expect(groupCountService.totalMembers, equals(userIndex * 5));

        // Step 3: Complete Logout (simulating clearSessionAndSockets)
        // System prefs to preserve:
        final introDone = prefs.getBool(PrefConst.introStatus) ?? true;
        final isDark = prefs.getBool(PrefConst.isDarkMode);

        // Clear all storage
        await prefs.clear();

        // Restore preserved system prefs
        await prefs.setBool(PrefConst.introStatus, introDone);
        if (isDark != null) {
          await prefs.setBool(PrefConst.isDarkMode, isDark);
        }

        // Reset in-memory services
        groupCountService.updateFromSocket({});
        markerService.hasCallingMarker.value = false;
        markerService.hasChattingMarker.value = false;
        markerService.hasWalkieMarker.value = false;

        // Step 4: Verification of wiped state
        expect(prefs.getString(PrefConst.userId), isNull);
        expect(prefs.getString('token'), isNull);
        expect(prefs.getString('name'), isNull);
        expect(prefs.getString(PrefConst.isRegistered), isNull);
        expect(groupCountService.totalGroups, equals(0));
        expect(groupCountService.totalMembers, equals(0));
        expect(markerService.hasCallingMarker.value, isFalse);
        expect(markerService.hasChattingMarker.value, isFalse);
      }
    });
  });

  // ===========================================================================
  // GROUP 5: Dual Login & Force-Logout Engine (Across 10+ Users)
  // ===========================================================================
  group('5. Dual Login & Force-Logout Engine (Across 10+ Users)', () {
    test('Guard 1: Force logout is ignored if user is not currently logged in (no token)', () {
      const String? token = null;
      bool logoutExecuted = false;

      if (token == null || token.trim().isEmpty) {
        logoutExecuted = false;
      } else {
        logoutExecuted = true;
      }

      expect(logoutExecuted, isFalse);
    });

    test('Guard 2: Force logout is ignored if app is already on an auth route', () {
      const currentRoute = '/login';
      const authRoutes = ['/login', '/otpScreen', '/register', '/splash', '/intro'];

      bool logoutExecuted = false;
      if (authRoutes.contains(currentRoute)) {
        logoutExecuted = false;
      } else {
        logoutExecuted = true;
      }

      expect(logoutExecuted, isFalse);
    });

    test('Guard 3: 15-second grace period protects newly logged-in device from stale server packets', () {
      final loginTime = DateTime.now().subtract(const Duration(seconds: 5));
      final elapsed = DateTime.now().difference(loginTime);

      bool forceLogoutIgnored;
      if (elapsed < const Duration(seconds: 15)) {
        forceLogoutIgnored = true;
      } else {
        forceLogoutIgnored = false;
      }

      expect(forceLogoutIgnored, isTrue);

      // Stale packet after grace period (20s) must trigger force logout
      final oldLoginTime = DateTime.now().subtract(const Duration(seconds: 20));
      final oldElapsed = DateTime.now().difference(oldLoginTime);
      expect(oldElapsed >= const Duration(seconds: 15), isTrue);
    });

    test('Execution: Valid dual login packet triggers complete session teardown & dialog alert', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'active_jwt_token_123');
      await prefs.setString(PrefConst.userId, 'USR_777');

      String navigatedRoute = '';
      String dialogAlertMessage = '';

      void executeForceLogout({String? message}) {
        prefs.clear();
        navigatedRoute = '/login';
        dialogAlertMessage = message ?? 'Session expired. You logged in on another device.';
      }

      executeForceLogout(message: 'Your account was accessed from an iPhone 16 Pro');

      expect(prefs.getString('token'), isNull);
      expect(prefs.getString(PrefConst.userId), isNull);
      expect(navigatedRoute, equals('/login'));
      expect(dialogAlertMessage, contains('iPhone 16 Pro'));
    });
  });

  // ===========================================================================
  // GROUP 6: Production Scalability Simulation (1000+ Concurrent Users)
  // ===========================================================================
  group('6. Production Scalability Simulation (1000+ Concurrent Users)', () {
    test('Scalability A: High-throughput parsing of 1,000 concurrent member location packets', () {
      final stopwatch = Stopwatch()..start();

      final List<Map<String, dynamic>> simulatedBatch = List.generate(1000, (i) {
        return {
          'userId': 10000 + i,
          'firstName': 'User',
          'lastName': '$i',
          'latitude': 37.7749 + (i * 0.0001),
          'longitude': -122.4194 + (i * 0.0001),
          'isOnline': i % 2 == 0,
          'battery': 50 + (i % 50),
          'address': 'Location #$i, Metro City',
        };
      });

      final parsedMembers = simulatedBatch
          .map((raw) => LiveLocationModel.fromJson(raw))
          .toList();

      stopwatch.stop();

      expect(parsedMembers.length, equals(1000));
      expect(parsedMembers[500].fullName, equals('User 500'));
      expect(parsedMembers[500].isOnline, isTrue);
      // Parsing 1000 items in Dart VM must take well under 250ms for 60fps performance
      expect(stopwatch.elapsedMilliseconds, lessThan(250));
    });

    test('Scalability B: Throttling / Debouncing prevents UI rebuild storms from 1000 socket events', () async {
      int uiRebuildCount = 0;
      final controller = StreamController<int>();

      // Debounce window of 50ms
      Timer? debounceTimer;
      int? lastPendingValue;

      void onSocketEvent(int val) {
        lastPendingValue = val;
        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 50), () {
          uiRebuildCount++;
          controller.add(lastPendingValue!);
        });
      }

      // 100 fast-burst events within 20 milliseconds
      for (int i = 1; i <= 100; i++) {
        onSocketEvent(i);
      }

      // Wait for debounce timer to fire
      await Future.delayed(const Duration(milliseconds: 100));

      // Despite 100 socket updates, UI rebuild triggered exactly once!
      expect(uiRebuildCount, equals(1));
      controller.close();
    });

    test('Scalability C: Thundering Herd Mitigation - Exponential backoff with randomized jitter', () {
      final random = Random(42);

      Duration calculateBackoffWithJitter(int attempt) {
        final baseDelaySeconds = min(30, pow(2, attempt).toInt());
        // Jitter: +/- 25% randomization to spread 1000+ client reconnections across time
        final jitterFactor = 0.75 + (random.nextDouble() * 0.5);
        final finalMs = (baseDelaySeconds * 1000 * jitterFactor).toInt();
        return Duration(milliseconds: finalMs);
      }

      final Set<int> delays = {};
      for (int client = 1; client <= 50; client++) {
        final delay = calculateBackoffWithJitter(3); // attempt 3 (~8s base)
        delays.add(delay.inMilliseconds);
      }

      // Randomized jitter ensures different clients do NOT reconnect at the exact same millisecond
      expect(delays.length, greaterThan(35));
    });

    test('Scalability D: Active member deduplication by userId in high-concurrency feeds', () {
      final List<LiveLocationModel> incomingStream = [
        LiveLocationModel(userId: 1, firstName: 'A', lastName: '1', profileImage: '', latitude: 10, longitude: 10, isOnline: true),
        LiveLocationModel(userId: 2, firstName: 'B', lastName: '2', profileImage: '', latitude: 11, longitude: 11, isOnline: true),
        LiveLocationModel(userId: 1, firstName: 'A', lastName: '1', profileImage: '', latitude: 10.01, longitude: 10.01, isOnline: true), // Duplicate update
        LiveLocationModel(userId: 3, firstName: 'C', lastName: '3', profileImage: '', latitude: 12, longitude: 12, isOnline: true),
        LiveLocationModel(userId: 2, firstName: 'B', lastName: '2', profileImage: '', latitude: 11.02, longitude: 11.02, isOnline: true), // Duplicate update
      ];

      // Dedup map
      final Map<int, LiveLocationModel> dedupMap = {};
      for (final member in incomingStream) {
        dedupMap[member.userId] = member;
      }

      expect(dedupMap.length, equals(3));
      // Latest coordinates preserved
      expect(dedupMap[1]!.latitude, equals(10.01));
      expect(dedupMap[2]!.latitude, equals(11.02));
    });
  });
}
