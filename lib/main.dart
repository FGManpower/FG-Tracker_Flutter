import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/global/launchedFromCall.dart';
import 'package:fgtracker/app/Data/Repositories/call_repo.dart';
import 'package:fgtracker/app/Data/Services/IncommingCallKit/callkit_service.dart:.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Dashboard_Service.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Group_Calling.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import 'package:fgtracker/app/Data/Services/screen_share_service.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/calling_controller.dart';
import 'package:fgtracker/app/modules/status/binding/status_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/Core/values/Context_Utility.dart';
import 'app/Core/values/global.dart';
import 'app/Data/Services/GroupCountService.dart';
import 'app/Data/Services/NotificationServices.dart';
import 'app/Data/Services/Socket/Socket_SignallingService.dart';
import 'app/modules/Notification/Controller/cubit/notification_count_cubit.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/Track/Controller/SocketServices.dart';
import 'app/modules/Track/Controller/GroupTrackController.dart';
import 'app/modules/Track/Controller/LocationService.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final socket = SignallingService.instance.socket;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  log("====Background-Bg===${message.data}");

  final d = message.data;

  final handled = await CallKitService.handlePush(d);
  if (handled) {
    final screen = d['screen_name'];
    if (Platform.isAndroid &&
        (screen == 'incomingCall' || screen == 'incomingGroupCall')) {
      try {
        final cd = CallKitService.decodeCallData(d['callData']);
        await CallRepo.updateCallingStatus(
          callId: cd['callId'].toString(),
          callingStatus: 'Ringing',
          remoteUserId: int.tryParse(cd['callerId'].toString()) ?? 0,
        );
      } catch (e) {
        log('ringing status error: $e');
      }
    }
    return;
  }

  if (d['screen_name'] == "group_walkie" ||
      d['screenName'] == "group_walkie" ||
      d['screen_name'] == "groupWalkie" ||
      d['screen'] == "group_walkie" ||
      d['screen'] == "walkie") {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (_) {}

    final rawJoinedCount = d['joinedMemberCount'] ??
        d['joinedCount'] ??
        d['activeMemberCount'] ??
        d['totalJoinedMembers'] ??
        d['membersJoined'];
    final int? joinedCount =
        rawJoinedCount != null ? int.tryParse(rawJoinedCount.toString()) : null;

    final groupId = (d['groupId'] ?? d['group_id'] ?? d['id'] ?? '').toString();
    final groupName =
        (d['groupName'] ?? d['group_name'] ?? d['title'] ?? 'Walkie-Talkie')
            .toString();
    final speakerName =
        (d['speakerName'] ?? d['speaker_name'] ?? d['name'] ?? 'Someone')
            .toString();
    final speakerImage =
        (d['speakerImage'] ?? d['speaker_image'] ?? '').toString();

    try {
      await firebaseNotificationServices.showWalkieNotification(
        groupId: groupId,
        groupName: groupName,
        speakerName: speakerName,
        speakerImage: speakerImage,
        joinedCount: joinedCount,
        extraData: Map<String, dynamic>.from(d),
      );
    } catch (e, st) {
      log("Error calling showWalkieNotification: $e\n$st");
    }
  }
}

void _setupCallKit() {
  final callKit = CallKitService.instance;

  callKit.onAcceptCall = (callId, extra, uuid) async {
    final isGroup = extra['screen_name'] == 'incomingGroupCall';
    CallSessionState.sessionId = uuid ?? '';

    if (isGroup) {
      log('Group call accepted: $extra');
      return;
    }

    final callerId = extra['callerId']?.toString() ?? '';

    if (Get.isRegistered<CallingController>() &&
        Get.currentRoute == Routes.callScreen) {
      return;
    }

    log('Incoming call accepted: $extra');

    Get.toNamed(Routes.callScreen, arguments: {
      'callerId': callerId,
      'remoteUserId': callerId,
      'callId': callId,
      'sessionId': uuid,
      'is_video': extra['isVideo'] == 'true' || extra['isVideo'] == true,
      'profileImage': extra['profileImage'],
      'callType': 'Incoming',
      'fromCallKit': true,
      'callerName': extra['callerName'],
      'offer': CallKitService.decodeOffer(extra['sdpOfferCompressed']),
    });
  };

  callKit.onDeclineCall = (callId, extra, uuid) async {
    if (extra['screen_name'] == 'incomingGroupCall') return;

    final s = SignallingService.instance.socket;
    if (s != null && s.connected) {
      s.emit('rejectCall', {
        'callId': callId,
        'remoteUserId': extra['callerId']?.toString(),
      });
      print("========rejectCallsocketCalled");
    } else {
      await rejectCallViaRest(callId);
      print("========rejectCallApiCalled");
    }
  };

  callKit.onEndCall = (callId, extra, uuid) async {
    if (Get.isRegistered<CallingController>()) {
      await Get.find<CallingController>().endCall(type: 'callkit');
    }
  };

  callKit.onTimeoutCall = (callId, extra, uuid) async {
    log('Incoming call timed out: $callId');
  };

  callKit.getCallStatus = (callId) async => null;

  callKit.onVoipToken = (token) async {
    log('VoIP token: $token');
  };
}

Future<void> rejectCallViaRest(String callId) async {
  try {
    final shared = await SharedPreferences.getInstance();
    final token = shared.getString(PrefConst.STORAGE_USER_TOKEN_KEY) ??
        ''; // adjust key name
    if (token.isEmpty) return;

    final url = Uri.parse('${ConstRes.aBaseUrl}callRejected?callId=$callId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    log('REST reject status: ${response.statusCode}');
  } catch (e) {
    log('REST reject error: $e');
  }
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

  Get.put<GroupTrackingController>(GroupTrackingController());
  Get.put<LocationService>(LocationService());
  Get.put<SocketService>(SocketService());
  Get.put<GroupCountService>(GroupCountService(), permanent: true);
  FacebookAppEvents().setAutoLogAppEventsEnabled(true);
  await FacebookAppEvents().setAdvertiserIdCollectionEnabled(true);
  final shared = await SharedPreferences.getInstance();

  var userId = shared.get(PrefConst.userId);

  _setupCallKit();

  if (userId != null) {
    SignallingService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfCallerID: userId.toString(),
    );
    groupWalkieInitialize(userId);
    Socket_GroupCallService.instance.init(userId.toString());
    SocketDashboardService().init();

    StatusBinding().dependencies();
  }
  ScreenShareForegroundService.init();

  FirebaseMessaging.onMessage.listen((m) => CallKitService.handlePush(m.data));

  await CallKitService.instance.init();

  runApp(const MyApp());
}

groupWalkieInitialize(userId) async {
  if (userId != null) {
    await GroupWalkieService.instance.init(
      websocketUrl: ConstRes.socketUrl,
      selfUserId: userId,
    );
  }
}

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CallKitService.instance.markAppReady();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Drop ringing UIs whose call already ended while we were suspended.
      CallKitService.instance.restoreActiveCalls();

      // Also consume pending accept if app comes back to foreground after
      // user accepted from notification while app was backgrounded.
      CallKitService.instance.markAppReady();
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
