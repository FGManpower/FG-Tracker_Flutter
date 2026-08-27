import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';

import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Data/Services/group_Service.dart';
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

final socket = SignallingService.instance.socket;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("====Background-Bg===${message.data}");

  if (message.data['screen_name'] == "incomingCall") {
    if (Platform.isIOS) {
      // await RemoteLoggerTest.log("FCM_BG_HANDLER", "iOS detected in FCM background handler: ${message.data}");
      return;
    }
    final callData = jsonDecode(message.data['callData']);
    final originalCallId = callData['callId'].toString();

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

    try {
      await ConnectycubeFlutterCallKit.showCallNotification(
        CallEvent(
          sessionId: callIdToUuid(originalCallId),
          callerName: callData['callerName'],
          callType: callData['isVideo'] == true ? 1 : 0,
          opponentsIds: {int.parse(callData['callerId'])},
          callerId: int.parse(callData['callerId']),
          userInfo: userInfo,
        ),
      );
    } catch (e) {
      log("showCallNotification error: $e");
    }
  } else if (message.data['screen_name'] == "missedCall") {
    final callData = jsonDecode(message.data['callData']);
    final sessionId = callData['session_id'].toString();
    callEnded(sessionId);
  } else if (message.data['screen_name'] == "callEnded") {
    final sessionId = message.data['sessionId'];
    print("========CallEndedFromBackend===${sessionId}");
    callEnded(sessionId);
  }
}

@pragma('vm:entry-point')
Future<void> onCallRejectedWhenTerminated(CallEvent event) async {
  await Firebase.initializeApp();

  Map<String, dynamic> data = {};
  final rawUserInfo = event.userInfo;

  if (rawUserInfo != null && rawUserInfo.isNotEmpty) {
    if (rawUserInfo.length == 1 &&
        rawUserInfo.values.first.trim().startsWith("")) {
      try {
        data = jsonDecode(rawUserInfo.values.first);
      } catch (e) {
        data = Map<String, dynamic>.from(rawUserInfo);
      }
    } else {
      data = Map<String, dynamic>.from(rawUserInfo);
    }
  }

  if (data.isEmpty) return;

  final callId = int.tryParse(data['callId'].toString());
  if (callId == null) return;
  try {
    final socket = SignallingService.instance.socket;

    if (socket != null && socket.connected) {
      socket.emit("rejectCall", {
        "callId": callId,
        "remoteUserId": data["callerId"].toString(),
      });
      log("========call-rejected via socket");
    } else {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ?? "";

      if (token.isEmpty) return;

      await http.get(
        Uri.parse("${ConstRes.aBaseUrl}callRejected?callId=$callId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));
    }
  } catch (e) {
    log("[TERMINATED-ANDROID] ERROR: $e");
  }

  await ConnectycubeFlutterCallKit.clearCallData(sessionId: event.sessionId);
}

@pragma('vm:entry-point')
void onCallEventBackground() {
  CallKitService.instance.init();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await RemoteLoggerTest.log("MAIN_BOOT", "App process launched/woken up in background! Platform: ${Platform.operatingSystem}");
  await Global.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
      onCallRejectedWhenTerminated;
  await firebaseNotificationServices().initialized();
  CallKitService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  Get.put<TrackingController>(TrackingController());

  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());

  final userId = Global.storageServices.get(PrefConst.userId)?.toString();

  if (userId != null) {
    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId,
    );
    groupWalkieInitialize(userId);
  }

  runApp(const MyApp());
}

groupWalkieInitialize(userId) async {
  // After user login and socket init
  if (userId != null) {
    // 1. Initialize Walkie Service
    await GroupWalkieService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfUserId: userId,
    );

    // 2. Fetch and register groups
    Future.microtask(() async {
      try {
        final List<String> groupIds = await GroupService().getGroupData();

        if (groupIds.isNotEmpty) {
          GroupWalkieService.instance.registerGroups(groupIds);
          log("📻 Registered from main: ${groupIds.length} groups for walkie auto-notify");
        } else {
          log("⚠️ No groups found to register for user $userId");
        }
      } catch (e) {
        log("❌ Failed to register groups from main: $e");
      }
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    CallKitService.instance.init();
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
