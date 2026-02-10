import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/configureAudioSession.dart';
import 'package:fgtracker/app/Data/Services/Walkie-Talkie-Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/Core/global/global_notification_handler.dart';
import 'app/Core/util/CallUtils.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Data/Services/CallEvents_NotificationServices.dart';
import 'app/Data/Services/NotificationServices.dart';
import 'app/Data/Services/SignallingService.dart';
import 'app/Model/call_model.dart';
import 'app/modules/Notification/Controller/cubit/notification_count_cubit.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/Track/Controller/SocketServices.dart';
import 'app/modules/Track/Controller/TrackController.dart';
import 'app/modules/Track/Controller/LocationService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'gen/assets.gen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("[Background FCM] Raw Data: ${message.data}");

  if (message.data['screen_name'] == 'incomingCall') {
    final callMap = jsonDecode(message.data['callData']);

    print("========callData==${callMap}");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("notificationConsumed", false);
      if (Platform.isIOS) {
        print("===showingincoming inios:");
        // await CallKitService.showIncomingCall(callMap);

        final callModel = IncomingCallModel.fromMap(callMap);

        await CallUtils().showIncomingCall(data: callMap);
      } else {
      // ANDROID: your existing custom notification
      await CustomNotificationServices.showIncomingCall(callMap);
      }
      // CallUtils().showIncomingCall(data: callMap);

      FlutterRingtonePlayer()
          .play(asAlarm: false, fromAsset: Assets.music.incomingCall);
      Future.delayed(const Duration(seconds: 7), () {
        FlutterRingtonePlayer().stop();
      });
    } catch (e) {
      debugPrint("Backgroundexception=======$e");
    }
  } else if (message.data['screen_name'] == 'walkie') {
    final sharedpref = await SharedPreferences.getInstance();
    await sharedpref.setString('fromUserId', message.data['fromUserId']);

    var url = "${ConstRes.DeepLink_Url}/?page=Walkie";
    log("====>AppLaunch Url is ======$url");
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
          action: 'action_view', data: url, package: "com.example.fgtracker");
      await intent.launch().then((value) {
        log("AppLaunch Success");
      }).onError(
        (error, stackTrace) {
          log("AppLaunchIssue:$error,StackTrace is:$stackTrace");
        },
      );
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

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  Get.put<TrackingController>(TrackingController());
  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    notificationCategories: [
      DarwinNotificationCategory(
        'INCOMING_CALL',
        actions: [
          DarwinNotificationAction.plain(
            'CALL_ACCEPT',
            'Accept',
            options: {DarwinNotificationActionOption.foreground},
          ),
          DarwinNotificationAction.plain(
            'CALL_DECLINE',
            'Decline',
            options: {DarwinNotificationActionOption.destructive},
          ),
        ],
      ),
    ],
  );

  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    ),
    onDidReceiveNotificationResponse: onNotificationResponse,
  );

  GlobalNotificationHandler.instance.init();
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
  WalkieConfiguration.configureSpeakerAudioSession();
  // CallUtils().listenCallKitEvents();
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
