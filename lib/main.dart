import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app/Core/util/callkit_service.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Data/Services/NotificationServices.dart';
import 'app/Data/Services/SignallingService.dart';
import 'app/modules/Notification/Controller/cubit/notification_count_cubit.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/Track/Controller/SocketServices.dart';
import 'app/modules/Track/Controller/TrackController.dart';
import 'app/modules/Track/Controller/LocationService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

String callIdToUuid(String callId) {
  final padded = callId.padLeft(12, '0');
  return "00000000-0000-4000-8000-$padded";
}

// ============================================================
//  BACKGROUND HANDLER
// ============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log("🔥 BG Message: ${message.data}");

  final screenName = message.data['screen_name'];

  // ======= INCOMING CALL =======
  if (screenName == "incomingCall") {
    try {
      final callData = jsonDecode(message.data['callData']);
      final originalCallId = callData['callId'].toString();
      final sessionId = callIdToUuid(originalCallId);

      final Map<String, String> userInfo = {
        "callId": originalCallId,
        "callerId": callData['callerId'].toString(),
        "receiverId": callData['receiverId'].toString(),
        "isVideo": callData['isVideo'].toString(),
        "callerName": callData['callerName'].toString(),
        "callerProfileImage": callData['callerProfileImage'].toString(),
        "sdpOfferCompressed": callData['sdpOfferCompressed'].toString(),
        "notificationId": callData['notificationId']?.toString() ?? "",
      };

      await ConnectycubeFlutterCallKit.showCallNotification(
        CallEvent(
          sessionId: sessionId,
          callerName: callData['callerName'],
          callType: callData['isVideo'] == true ? 1 : 0,
          opponentsIds: {int.parse(callData['callerId'])},
          callerId: int.parse(callData['callerId']),
          userInfo: userInfo,
        ),
      );

      log("✅ CallKit shown for callId: $originalCallId, sessionId: $sessionId");
    } catch (e) {
      log("❌ showCallNotification error: $e");
    }
  }

  // ======= CALL CANCELLED (Caller cancelled before answer) =======
  else if (screenName == "callCancelled") {
    try {
      final callData = jsonDecode(message.data['callData']);
      final originalCallId = callData['callId'].toString();
      final sessionId = callIdToUuid(originalCallId);

      log("🚫 BG callCancelled: callId=$originalCallId, sessionId=$sessionId");

      // Dismiss CallKit notification
      await ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: sessionId,
      );
      await ConnectycubeFlutterCallKit.clearCallData(
        sessionId: sessionId,
      );

      log("✅ CallKit dismissed after callCancelled in background");
    } catch (e) {
      log("❌ callCancelled BG handler error: $e");
    }
  }

  // ======= MISSED CALL =======
  else if (screenName == "missedCall") {
    try {
      final callData = jsonDecode(message.data['callData']);
      final originalCallId = callData['callId'].toString();
      final sessionId = callIdToUuid(originalCallId);

      // Dismiss any lingering CallKit notification
      await ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: sessionId,
      );
      await ConnectycubeFlutterCallKit.clearCallData(
        sessionId: sessionId,
      );

      log("✅ Missed call CallKit dismissed");
    } catch (e) {
      log("❌ missedCall BG handler error: $e");
    }
  }
}

// ============================================================
//  CALL REJECTED WHEN APP TERMINATED
// ============================================================
@pragma('vm:entry-point')
Future<void> onCallRejectedWhenTerminated(CallEvent event) async {
  await Firebase.initializeApp();

  log("❌ onCallRejectedWhenTerminated: ${event.sessionId}");

  Map<String, dynamic> data = _parseUserInfo(event.userInfo);

  if (data.isEmpty) {
    log("❌ Empty userInfo in onCallRejectedWhenTerminated");
    return;
  }

  final callId = int.tryParse(data['callId'].toString());
  if (callId == null) return;

  try {
    // Always use REST API when terminated (socket not available)
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ?? "";

    if (token.isEmpty) {
      log("❌ Token empty in onCallRejectedWhenTerminated");
      return;
    }

    final response = await http.get(
      Uri.parse("${ConstRes.aBaseUrl}callRejected?callId=$callId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 15));

    log("✅ callRejected API response: ${response.statusCode}");
  } catch (e) {
    log("❌ onCallRejectedWhenTerminated ERROR: $e");
  }

  // Clean up CallKit data
  try {
    await ConnectycubeFlutterCallKit.clearCallData(
      sessionId: event.sessionId,
    );
  } catch (e) {
    log("clearCallData error: $e");
  }
}

// ============================================================
//  CALL ACCEPTED WHEN APP TERMINATED
// ============================================================
@pragma('vm:entry-point')
Future<void> onCallAcceptedWhenTerminated(CallEvent event) async {
  log("✅ onCallAcceptedWhenTerminated: ${event.sessionId}");
  // CallKitService will handle navigation when app opens
}

// ============================================================
//  BACKGROUND CALL EVENT
// ============================================================
@pragma('vm:entry-point')
void onCallEventBackground() {
  CallKitService.instance.init();
}

// ============================================================
//  HELPER: Parse userInfo
// ============================================================
Map<String, dynamic> _parseUserInfo(Map<String, String>? rawUserInfo) {
  if (rawUserInfo == null || rawUserInfo.isEmpty) return {};
  try {
    if (rawUserInfo.length == 1 &&
        rawUserInfo.values.first.trim().startsWith("{")) {
      return jsonDecode(rawUserInfo.values.first);
    }
    return Map<String, dynamic>.from(rawUserInfo);
  } catch (e) {
    log("_parseUserInfo error: $e");
    return {};
  }
}

// ============================================================
//  MAIN
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Global.init();

  // ======= FCM Background Handler =======
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ======= CallKit Terminated Handlers =======
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
      onCallRejectedWhenTerminated;
  ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated =
      onCallAcceptedWhenTerminated;

  // ======= Notification Services =======
  await firebaseNotificationServices().initialized();

  // ======= CallKit Init =======
  CallKitService.instance.init();

  // ======= System UI =======
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // ======= GetX Controllers =======
  Get.put<TrackingController>(TrackingController());
  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());

  // ======= Socket Init =======
  final userId = Global.storageServices.get(PrefConst.userId)?.toString();
  if (userId != null) {
    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId,
    );
    WalkietalkieService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfUserId: userId,
    );
  }

  // ======= FCM Foreground Handler =======
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    log("📱 FG Message: ${message.data}");
    await _handleForegroundMessage(message);
  });

  // ======= FCM App Opened From Notification =======
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    log("📱 App opened from notification: ${message.data}");
    await _handleNotificationTap(message);
  });

  // ======= Check Terminated State Call =======
  await _checkTerminatedStateCall();

  runApp(const MyApp());
}

// ============================================================
//  FOREGROUND MESSAGE HANDLER
// ============================================================
Future<void> _handleForegroundMessage(RemoteMessage message) async {
  final screenName = message.data['screen_name'];

  // ======= INCOMING CALL in Foreground =======
  // (Socket handles this, but FCM is backup)
  if (screenName == "incomingCall") {
    log("📞 FG incomingCall - Socket should handle this");
    // Socket handles foreground incoming calls
    // Only show CallKit if socket missed it
  }

  // ======= CALL CANCELLED in Foreground =======
  else if (screenName == "callCancelled") {
    log("🚫 FG callCancelled received");
    try {
      final callData = jsonDecode(message.data['callData']);
      final originalCallId = callData['callId'].toString();
      final sessionId = callIdToUuid(originalCallId);

      await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
      await ConnectycubeFlutterCallKit.clearCallData(sessionId: sessionId);

      log("✅ FG CallKit dismissed after callCancelled");
    } catch (e) {
      log("❌ FG callCancelled error: $e");
    }
  }

  // ======= MISSED CALL =======
  else if (screenName == "missedCall") {
    log("📵 FG missedCall received");
    try {
      final callData = jsonDecode(message.data['callData']);
      final originalCallId = callData['callId'].toString();
      final sessionId = callIdToUuid(originalCallId);

      await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
      await ConnectycubeFlutterCallKit.clearCallData(sessionId: sessionId);
    } catch (e) {
      log("❌ FG missedCall error: $e");
    }
  }
}

// ============================================================
//  NOTIFICATION TAP HANDLER
// ============================================================
Future<void> _handleNotificationTap(RemoteMessage message) async {
  final screenName = message.data['screen_name'];

  if (screenName == "missedCall") {
    // Navigate to call history
    Get.toNamed(Routes.notificationScreen);
    // Get.toNamed(Routes.CallHistory);
  }
}

// ============================================================
//  CHECK TERMINATED STATE CALL
// ============================================================
Future<void> _checkTerminatedStateCall() async {
  try {
    final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
    if (sessionId == null) return;

    log("🔍 checkTerminatedStateCall sessionId: $sessionId");

    final state = await ConnectycubeFlutterCallKit.getCallState(
      sessionId: sessionId,
    );
    log("🔍 checkTerminatedStateCall state: $state");

    if (state == "accepted") {
      // App was killed while call was accepted
      // CallKitService.checkCallOnLaunch() will handle navigation
      await CallKitService.instance.checkCallOnLaunch();
    } else if (state == "rejected" ||
        state == "missed" ||
        state == "cancelled") {
      // Clean up stale call data
      await ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: sessionId,
      );
      await ConnectycubeFlutterCallKit.clearCallData(
        sessionId: sessionId,
      );
      log("✅ Cleaned up stale $state call");
    }
  } catch (e) {
    log("❌ checkTerminatedStateCall error: $e");
  }
}

// ============================================================
//  APP WIDGET
// ============================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Remove duplicate CallKitService.instance.init() - already called in main()
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("📱 App lifecycle: $state");
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - check for pending calls
      _checkTerminatedStateCall();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationCountCubit>(
          create: (context) => NotificationCountCubit(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: GetMaterialApp(
            navigatorKey: ContextUtility.navigatorkey,
            debugShowCheckedModeBanner: false,
            title: "FG Tracker",
            initialRoute: Routes.Splash,
            getPages: AppPages.routes,
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                actionsIconTheme: IconThemeData(color: Colors.black),
                elevation: 0,
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('hi', 'IN'),
              Locale('ur', 'PK'),
            ],
          ),
        ),
      ),
    );
  }
}