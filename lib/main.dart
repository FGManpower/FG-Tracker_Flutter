import 'dart:convert';
import 'dart:developer';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app/Core/util/CallUtils.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Data/Services/NotificationServices.dart';
import 'app/Data/Services/SignallingService.dart';

import 'app/Data/Services/walkie_native_service.dart';
import 'app/Model/call_model.dart';
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
  await Global.init();
  log("[Background FCM] Raw Data: ${message.data}");

  if (message.data['screen_name'] == 'incomingCall') {
    try {
      final callMap = jsonDecode(message.data['callData']);
      final callModel = IncomingCallModel.fromMap(callMap);

      await CallUtils().showIncomingCall(callModel);
    } catch (e) {
      log("🔥 Background handler error: $e");
    }
  }
  // else if (message.data['type'] == 'WALKIE_CALL') {
  //   log("🔥 Background Message Data ${message.data}");
  //   final fromUserId = message.data['fromUserId'];
  //
  //   await WalkieNativeService.start(
  //     myUserId: Global.storageServices.get(PrefConst.userId).toString(),
  //     remoteUserId: fromUserId,
  //   );
  // }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await Global.init();
  await firebaseNotificationServices().initialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  Get.put<TrackingController>(TrackingController());
  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());

  SignallingService.instance.init(
    websocketUrl: ConstRes.socketUrl,
    selfCallerID: Global.storageServices.get(PrefConst.userId).toString(),
  );
  CallUtils().listenCallKitEvents();
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
            // home: JoinScreen(selfCallerId: Global.storageServices.get(PrefConst.userId).toString(),),
          ),
        ),
      ),
    );
  }
}
