import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/Core/util/CallUtils.dart';
import 'app/Core/util/http/Constant.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Model/call_model.dart';
import 'app/modules/AgoraVideoandAudio_Call/incoming_call_screen.dart';
import 'app/modules/Notification/Controller/cubit/notification_count_cubit.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/Track/Controller/SocketServices.dart';
import 'app/modules/Track/Controller/TrackController.dart';
import 'app/modules/Track/Controller/LocationService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("[Background FCM] Data: ${message.data}");

  if (message.data['type'] == 'call') {
    await CallUtils().showIncomingCall(message.data);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await Global.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Dependency injection
  Get.put<TrackingController>(TrackingController());
  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());

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
    listenCallKitEvents();
  }

  void listenCallKitEvents() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      log("[CallKit Event] ${event.event.name} - ${event.body}");

      switch (event.event) {

        case Event.actionCallAccept:
          final rawExtra = event.body['extra'];


          final extra = (rawExtra as Map?)?.map(
                (key, value) => MapEntry(key.toString(), value),
          ) ?? <String, dynamic>{};
          log("[CallKit] Call Accept");
          _navigateToCallScreen(extra);
          break;


        case Event.actionCallDecline:
          log("[CallKit] Call declined");
          break;

        case Event.actionCallEnded:
          log("[CallKit] Call ended");
          break;

        default:
          break;
      }
    });
  }

  Future<void> _navigateToCallScreen(Map<String, dynamic> data) async {
    final sharedpref = await SharedPreferences.getInstance();


    try {
      CallModel incomingCallData = CallModel(
        callerId: data['callerId'],
        receiverId: sharedpref.get(Constant.userId).toString(),
        channelId: data['channelId'],
        isVideo: data['isVideo'] == 'true',
        status: 'ringing',
        callerName: data['callerName'],
        callerProfileImage: data['callerProfileImage'],
      );

      print('--------------CallData------${data}');

      Navigator.push(
          ContextUtility.navigator!.context,
          MaterialPageRoute(
              builder: (context) =>
                  IncomingCallScreen(call: incomingCallData)));

    } catch (e) {
      log('exception:${e.toString()}');
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
