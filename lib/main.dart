import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';

import 'package:fgtracker/app/Core/util/configureAudioSession.dart';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'app/Core/global/global_notification_handler.dart';
import 'app/Core/util/callkit_service.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Data/Repositories/call_repo.dart';
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

String callIdToUuid(String callId) {
  final padded = callId.padLeft(12, '0');
  return "00000000-0000-4000-8000-$padded";
}

// ✅ Background/Terminated Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("[BGHandler] data: ${message.data}");

  if (message.data['screen_name'] == "incomingCall") {
    final callData = jsonDecode(message.data['callData']);
    final originalCallId = callData['callId'].toString();

    // ✅ Build userInfo - flat string map
    final Map<String, String> userInfo = {
      "callId":             originalCallId,
      "callerId":           callData['callerId'].toString(),
      "receiverId":         callData['receiverId'].toString(),
      "isVideo":            callData['isVideo'].toString(),
      "callerName":         callData['callerName'].toString(),
      "callerProfileImage": callData['callerProfileImage'].toString(),
      "sdpOfferCompressed": callData['sdpOfferCompressed'].toString(),
      "notificationId":     callData['notificationId']?.toString() ?? "",
    };

    try {
      // ✅ Show CallKit notification (Android only - iOS gets VoIP push)
      await ConnectycubeFlutterCallKit.showCallNotification(
        CallEvent(
          sessionId:    callIdToUuid(originalCallId), // ✅ UUID
          callerName:   callData['callerName'],
          callType:     callData['isVideo'] == true ? 1 : 0,
          opponentsIds: {int.parse(callData['callerId'])},
          callerId:     int.parse(callData['callerId']),
          userInfo:     userInfo,
        ),
      );
    } catch (e) {
      log("showCallNotification error: $e");
    }
  }
}
@pragma('vm:entry-point')
void onNotificationResponse(NotificationResponse response) async {
  log("OnNotificationPress");
  NotificationHolder.pendingResponse = response;
}




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Global.init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
    WalkietalkieService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfUserId: userId,
    );
  }
  // WalkieConfiguration.configureSpeakerAudioSession();
  //
  //
  //
  // WalkieUtils().listenWalkieEvents();
  runApp(const MyApp());
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
    // CallUtils.instance.listenCallKitEvents();
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
