import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/util/CallUtils.dart';
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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("[Background FCM] Raw Data: ${message.data}");

  if (message.data['screen_name'] == "incomingCall") {
    final callMap = jsonDecode(message.data['callData']);

    final callData = jsonDecode(message.data['callData']);
    final Map<String, String> userInfo = callData.map<String, String>(
        (key, value) => MapEntry(key.toString(), value.toString()));

    var pref = await SharedPreferences.getInstance();

    final userId = pref.get(PrefConst.userId);

    if (userId != null) {
      SignallingService.instance.init(
        websocketUrl: ConstRes.socketUrl,
        selfCallerID: userId.toString(),
      );

      socket?.emit("CallingStatus", {
        "callId": callData['callId'].toString(),
        "remoteUserId": int.parse(callData['callerId']),
        "callingStatus": "Ringing",
      });
    }

    try {
      final isActive =
          await CallRepo().isCallActive(callData['callId'].toString());

      if (!isActive) {
        return;
      }

      if (Platform.isIOS) {
        CallUtils.instance.showIncomingCall(data: callMap);
      } else {
        await ConnectycubeFlutterCallKit.showCallNotification(
          CallEvent(
            sessionId: callData['callId'].toString(),
            callerName: callData['callerName'],
            callType: callData['isVideo'] == true ? 1 : 0,
            opponentsIds: {int.parse(callData['callerId'])},
            callerId: int.parse(callData['callerId']),
            userInfo: userInfo,
          ),
        );
      }
    } catch (e) {
      log("callError=======${e.toString()}");
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


// @pragma('vm:entry-point')
// Future<void> callbackDispatcher() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case "fg_partner_fetch_location_taskSamad":
//         try {
//           final pref = await SharedPreferences.getInstance();
//           var token = pref.getString("token");
//
//           if (token != null && token.isNotEmpty) {
//             Position position = await Geolocator.getCurrentPosition(
//                 desiredAccuracy: LocationAccuracy.high);
//
//             LocationPermission permission = await Geolocator.checkPermission();
//             if (permission != LocationPermission.denied &&
//                 permission != LocationPermission.deniedForever) {
//               SharedpUserDataModel userData = SharedpUserDataModel.fromJson(
//                   jsonDecode(pref.getString('userdata')!));
//
//               DatabaseReference? postref;
//               if (Constant.Baseurl == "$ProductionUrl/api") {
//                 postref = FirebaseDatabase.instance
//                     .ref()
//                     .child("ProductionLabourcoordinates");
//               } else if (Constant.Baseurl == "$TestingUrl/api") {
//                 postref = FirebaseDatabase.instance
//                     .ref()
//                     .child("DevelopmentLabourcoordinates");
//               }
//               try {
//                 postref
//                     ?.child(userData.labourId.toString())
//                     .set({
//                   'latitude': position.latitude,
//                   'longitude': position.longitude,
//                   'address': "Mumbai",
//                   "deviceType": Platform.isAndroid ? "android" : "ios",
//                   'Labour_id': userData.labourId.toString(),
//                   'Labour_name': userData.labourName ?? "",
//                   'last_location_time': DateTime.now().toString(),
//                   // "Internet": internetStatus ?? "",
//                   "Permission": permission.toString().split('.').last,
//                   "AppStatus": "Terminated",
//                 })
//                     .then(
//                       (value) async {},
//                 )
//                     .catchError((error) async {
//
//                 });
//               } catch (e) {
//
//               }
//             }
//           } else {
//             log("Authentication failed..");
//           }
//         } catch (e) {
//           log("$e");
//           // await _showNotification(
//           //   title: "FG Partner",
//           //   body: "$e",
//           // );
//         }
//         break;
//     }
//     return Future.value(true);
//   });
// }

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
  //
  // const AndroidInitializationSettings androidInit =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  // final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
  //   notificationCategories: [
  //     DarwinNotificationCategory(
  //       'INCOMING_CALL',
  //       actions: [
  //         DarwinNotificationAction.plain(
  //           'CALL_ACCEPT',
  //           'Accept',
  //           options: {DarwinNotificationActionOption.foreground},
  //         ),
  //         DarwinNotificationAction.plain(
  //           'CALL_DECLINE',
  //           'Decline',
  //           options: {DarwinNotificationActionOption.destructive},
  //         ),
  //       ],
  //     ),
  //   ],
  // );
  //
  // await flutterLocalNotificationsPlugin.initialize(
  //   InitializationSettings(
  //     android: androidInit,
  //     iOS: iosInit,
  //   ),
  //   onDidReceiveNotificationResponse: onNotificationResponse,
  // );
  //
  // GlobalNotificationHandler.instance.init();
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
  setupVoipListener();
  if (Platform.isIOS) {
    CallUtils.instance.listenCallKitEvents();
  }

  // WalkieUtils().listenWalkieEvents();
  runApp(const MyApp());
}

const platform = MethodChannel("voip_channel");

void setupVoipListener() {
  platform.setMethodCallHandler((call) async {
    if (call.method == "voipToken") {
      final token = call.arguments;
    }

    if (call.method == "incomingCall") {
      final data = Map<String, dynamic>.from(call.arguments);

      showIncomingCall(data);
    }
  });
}

void showIncomingCall(Map<String, dynamic> callData) async {
  final userInfo = callData.map(
    (k, v) => MapEntry(k.toString(), v.toString()),
  );

  await ConnectycubeFlutterCallKit.showCallNotification(
    CallEvent(
      sessionId: callData['callId'].toString(),
      callerName: callData['callerName'],
      callType: callData['isVideo'] == true ? 1 : 0,
      opponentsIds: {int.parse(callData['callerId'].toString())},
      callerId: int.parse(callData['callerId'].toString()),
      userInfo: userInfo,
    ),
  );
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
