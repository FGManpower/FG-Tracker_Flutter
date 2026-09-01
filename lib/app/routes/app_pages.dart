import 'package:fgtracker/app/modules/Application/splashscreen.dart';
import 'package:fgtracker/app/modules/Group/Bindings/Member_binding.dart';
import 'package:fgtracker/app/modules/Group/Bindings/QRScan_Binding.dart';
import 'package:fgtracker/app/modules/Group/Views/MemberScreen.dart';
import 'package:fgtracker/app/modules/IntroScreen/IntroScreen.dart';
import 'package:fgtracker/app/modules/Messages/Bindings/Chat_binding.dart';
import 'package:fgtracker/app/modules/Messages/Bindings/video_binding.dart';
import 'package:fgtracker/app/modules/Messages/Views/DocumentViewerScreen.dart';
import 'package:fgtracker/app/modules/Messages/Views/GroupChatScreen.dart';
import 'package:fgtracker/app/modules/Messages/Views/cameraScreen.dart';
import 'package:fgtracker/app/modules/Messages/Views/videoPlayerScreen.dart';
import 'package:fgtracker/app/modules/Notification/Views/Notification.dart';
import 'package:fgtracker/app/modules/Track/Bindings/track_binding.dart';
import 'package:fgtracker/app/modules/auth/Bindings/auth_binding.dart';
import 'package:fgtracker/app/modules/auth/Views/Otp_Screen.dart';
import 'package:fgtracker/app/modules/auth/Views/login_Page.dart';
import 'package:fgtracker/app/modules/auth/Views/registration_screen.dart';
import 'package:fgtracker/app/modules/home/Views/AboutUs.dart';
import 'package:fgtracker/app/modules/home/Views/home_screen.dart';
import 'package:fgtracker/app/modules/mediaStream/Bindings/call_binding.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/call_screen.dart';
import 'package:get/get.dart';
import '../modules/Group/Views/QRScanScreen.dart';
import '../modules/Group/Views/QrScreen.dart';

import '../modules/Messages/Bindings/ForwardMessageBinding.dart';
import '../modules/Messages/Views/Chat_Screen.dart';
import '../modules/Messages/Views/ForwardMessageScreen.dart';
import '../modules/Messages/Views/create_group_screen.dart';
import '../modules/Messages/Views/groups_list_screen.dart';
import '../modules/Walkie-talkie/Views/walkie_group_select_screen.dart';
import '../modules/Track/Views/Search_Members.dart';
import '../modules/Track/Views/TrackLocationScreen.dart';
import '../modules/Walkie-talkie/WalkieTalkieScreen.dart';
import '../modules/home/Bindings/SosBinding.dart';
import '../modules/home/Views/bottom_actions_bar.dart';
import '../modules/home/Views/sos_screen.dart';
import '../modules/mediaStream/Views/incoming_call_screen.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.Splash;

  static final routes = [
    GetPage(
      name: _Paths.Splash,
      page: () => Splashscreen(),
      binding: Auth_Binding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Intro,
      page: () => IntroScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Login,
      page: () => LoginPage(),
      binding: Auth_Binding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Register,
      page: () => RegistrationScreen(),
      binding: Registeration_Binding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Home_Screen,
      page: () => HomeScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.OTPScreen,
      page: () => OTPScreen(),
      transition: Transition.rightToLeft,
      binding: OtpBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.AboutUs,
      page: () => AboutUs(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.SearchMembers,
      page: () => SearchMembers(),
      transition: Transition.rightToLeft,
      binding: SearchMember_Binding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: _Paths.Memberscreen,
      page: () => MemberscreenScreen(),
      transition: Transition.rightToLeft,
      binding: MemberBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.chatScreen,
      page: () => ChatScreen(),
      transition: Transition.rightToLeft,
      binding: ChatBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: _Paths.forwardMessageScreen,
      page: () => const ForwardMessageScreen(),
      binding: ForwardMessageBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: _Paths.groupChatScreen,
      page: () => GroupChatScreen(),
      transition: Transition.rightToLeft,
      binding: GroupChatBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.LocationTracking,
      page: () => LocationTrackingPage(),
      transition: Transition.rightToLeft,
      binding: LocationTracking_Binding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.QRScanScreen,
      page: () => QRScanScreen(),
      transition: Transition.rightToLeft,
      binding: QrScanBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.callScreen,
      page: () => CallScreen(),
      transition: Transition.rightToLeft,
      binding: StreamBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.IncomingCallScreen,
      page: () => IncomingCallScreen(),
      transition: Transition.rightToLeft,
      binding: IncomingCallBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.groupWalkieScreen,
      page: () => GroupWalkieScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.notificationScreen,
      page: () => NotificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.documentViewerScreen,
      page: () => DocumentViewerScreen(),
      transition: Transition.rightToLeft,
      binding: DocumentBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.videoPlayerScreen,
      page: () => VideoPlayerScreen(),
      transition: Transition.rightToLeft,
      binding: VideoBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.cameraScreen,
      page: () => CameraScreen(),
      transition: Transition.rightToLeft,
      // binding: VideoBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.SOSScreen,
      page: () => SosScreen(),
      transition: Transition.rightToLeft,
      binding: SosBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    // GetPage(
    //   name: Routes.GroupsList,
    //   page: () => GroupsListScreen(),
    // ),

    // GetPage(
    //   name: _Paths.CreateGroup,
    //   page: () => BottomActionsBar(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 400),
    // ),

    GetPage(
      name: Routes.WalkieGroupSelect,
      page: () => const WalkieGroupSelectScreen(),
    ),
  ];
}
