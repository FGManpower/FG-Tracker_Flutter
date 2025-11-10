import 'package:fgtracker/app/modules/Application/splashscreen.dart';
import 'package:fgtracker/app/modules/IntroScreen/IntroScreen.dart';
import 'package:fgtracker/app/modules/QiblaFinder/QiblaDirection.dart';
import 'package:fgtracker/app/modules/auth/Bindings/auth_binding.dart';
import 'package:fgtracker/app/modules/auth/Views/Otp_Screen.dart';
import 'package:fgtracker/app/modules/auth/Views/login_Page.dart';
import 'package:fgtracker/app/modules/auth/Views/registration_screen.dart';
import 'package:fgtracker/app/modules/home/Views/AboutUs.dart';
import 'package:fgtracker/app/modules/home/Views/home_screen.dart';

import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.Splash;

  static final routes = [
    GetPage(
      name: _Paths.Splash,
      page: () => Splashscreen(),
      binding: Auth_Binding(),
    ),

    GetPage(
      name: _Paths.Intro,
      page: () => IntroScreen(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
    ),



    GetPage(
      name: _Paths.Login,
      page: () => LoginPage(),
      binding: Auth_Binding(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Register,
      page: () => RegistrationScreen(),
      binding: Registeration_Binding(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.Home_Screen,
      page: () => HomeScreen(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(
      name: _Paths.OTPScreen,
      page: () => OTPScreen(),
      transition: Transition.topLevel,
      binding: OtpBinding(),
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.AboutUs,
      page: () => AboutUs(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    GetPage(name: _Paths.QiblaScreen, page: () => Qibladirection(),transition: Transition.topLevel,transitionDuration: Duration(milliseconds: 500))
  ];
}
